# gke-commerce-bootstrap
Google Kubernetes Engine starter kit to bootstrap an e-commerce site based on microservices.
Differences with official cluster:
* Prevent cluster destroy
* TODO: Network creation controlling the external IPs
* Environment naming suffix added
* Delete the default cluster
* We always modify the same node pool, do not create and detroy pools like example/official-beta-private-cluster-zonal-ecommerce
* We don't include local scripts to validate readiness of the cluster

## Modules
To facilitate the creation of Google Cloud components we have different modules based on the Google Foundation Kit
More info [here](https://cloud.google.com/foundation-toolkit/)

## Pre-requisites
```bash
gcloud organizations list
gcloud beta billing accounts list

export TF_VAR_organization_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_VAR_project_id=project-gaia-101
export TF_VAR_sa_credentials=./keys/terraform-sa-${TF_VAR_project_id}.json
export TF_VAR_region=us-central1
export GOOGLE_APPLICATION_CREDENTIALS=${TF_VAR_sa_credentials}
export GOOGLE_PROJECT=${TF_VAR_project_id}
```

### Google Project
Create a Google Project outside terraform, one for environment, link it to the proper billing account.

```bash
gcloud projects create ${TF_VAR_project_id} \
  --organization ${TF_VAR_organization_id} \
  --set-as-default
gcloud beta billing projects link ${TF_VAR_project_id} \
  --billing-account ${TF_VAR_billing_account}
````

### Service Account
Create a service account for the specific project the minimum roles:
* Compute Admin
* Kubernetes Engine Admin
* Service Account User
* Log Writer
* Monitor Metric Writer
* Storage Admin
* Storage Object Admin

#### Create Terraform SA
Create a service account to perform the terraform operations
```bash
gcloud iam service-accounts create terraform --display-name "Terraform Service Account"
```

#### Add roles to Terraform SA
Create a key for the service account and download the credentials in `JSON` format.
These credentials are used by the Terraform Google provider and should not be stored in the repository.
The environment variable `GOOGLE_CREDENTIALS`, should be defined as part of the CI configuration.

```bash
gcloud iam service-accounts keys create ${TF_VAR_sa_credentials} \
  --iam-account terraform@${TF_VAR_project_id}.iam.gserviceaccount.com
```

#### Add roles to Terraform SA
```bash
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/cloudkms.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/compute.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/compute.storageAdmin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/container.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountAdmin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id}  \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/storage.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/cloudkms.admin

```

Check the assigned roles
```bash
gcloud projects get-iam-policy ${TF_VAR_project_id}
```

### Create Google Storage Bucket to Store Terraform State

[Bucket Naming Convention](https://cloud.google.com/storage/docs/naming?_ga=2.244857926.-257079089.1557751559)
In the `backend.tf` specification we define the bucket that will be used to store the Terraform state. This bucket
needs to exist and can be created using [gsutil](https://cloud.google.com/storage/docs/gsutil). Each environment can
declare a different `prefix` in the configuration

```bash
gsutil mb -p ${TF_VAR_project_id} -c regional -l ${TF_VAR_region} gs://terraform-${TF_VAR_project_id}/
gsutil versioning set on gs://terraform-${TF_VAR_project_id}/
```

Check the bucket created
```bash
gsutil ls -L
```

### GKE Cluster
Based on the version [Cloud Foundation Toolkit 5.1.1](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/releases/tag/v5.1.1)
of the recommended templates by Google, we can create a Private Cluster with a node pool that can be updated just adding as a source of a [Terraform registry](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/5.1.1)

[Private cluster update variant](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/beta-private-cluster-update-variant)


### VPC
In order to create a private cluster, we need to provide to the GKE module a VPC (Google Compute Network) with a subnet created, along with ingress IP, a NAT and a router.
We import the module from the registry, to create the network [Terraform Registry](https://registry.terraform.io/modules/terraform-google-modules/network/google/1.4.3)

Based on the version [Cloud Foundation Toolkit 1.4.3](https://github.com/terraform-google-modules/terraform-google-network)

## Usage
Export your google credentials
```shell script
export GOOGLE_APPLICATION_CREDENTIALS=../../keys/terraform-sa.json
```
Apply the example available
```shell script
cd examples/simple-regional-private
terraform init
terraform plan
terraform apply
```
