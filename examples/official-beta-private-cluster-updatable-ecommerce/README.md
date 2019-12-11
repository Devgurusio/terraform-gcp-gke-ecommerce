Simplified example showing of how to create a cluster **using official Google Module** to create a cluster with **Rolling Updates** 

If we change the _force_node_pool_recreation_resources_ (e.g. machine_type) a new pool is created and then the old one is removed

## Pre-requisites
```shell script
export SERVICE_ACCOUNT=ci-lab
export TF_VAR_project_id=playground-s-11-5f629e
export GOOGLE_APPLICATION_CREDENTIALS=../../playground-key.json
```

Create Service Account, a key and bind the proper permissions
```shell script
gcloud iam service-accounts create ${SERVICE_ACCOUNT} --display-name "Service Account"
gcloud iam service-accounts keys create ${SERVICE_ACCOUNT}-key.json \
  --iam-account ${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/cloudkms.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/compute.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/compute.storageAdmin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/container.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountAdmin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id}  \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/storage.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/logging.admin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.roleAdmin

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
--member serviceAccount:${SERVICE_ACCOUNT}@${TF_VAR_project_id}.iam.gserviceaccount.com \
--role roles/iam.securityAdmin
```

Enable K8s apply
```shell script
gcloud services enable container.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

## Deploy Istio and a demo application
Install helm
```shell script
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
````

Install Istio
```shell script
helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.4.0/charts/
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.4.1/
kubectl create namespace istio-system
helm template install/kubernetes/helm/istio-init --namespace istio-system | kubectl apply -f -
# wait to get all the CRD installed
kubectl -n istio-system wait --for=condition=complete job --all
# Demo version
helm template install/kubernetes/helm/istio --namespace istio-system \
    --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -
```

Deploy bookinfo app
```shell script
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get svc istio-ingressgateway -n istio-system
# Go to http://IP/productpage
```
