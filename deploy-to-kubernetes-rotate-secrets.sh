#!/bin/bash

set -x

TARGET_ENV=$1

if [ -z "$2" ]; then
   echo "Secret env file is not provided"
   exit -1
else
   echo "Secret env file is provided ok"
fi

SECRET_ENV_FILE_PATH=$2

if [ -f "$SECRET_ENV_FILE_PATH" ]
then
    echo "$SECRET_ENV_FILE_PATH found."
else
    echo "SECRET_ENV_FILE_PATH $SECRET_ENV_FILE_PATH not found."
    exit -1
fi

SECRETS_API_SEED_TMPL_FILE_PATH=$3

if [ -f "$SECRETS_API_SEED_TMPL_FILE_PATH" ]
then
    echo "$SECRETS_API_SEED_TMPL_FILE_PATH found."
else
    echo "SECRETS_API_SEED_TMPL_FILE_PATH $SECRETS_API_SEED_TMPL_FILE_PATH not found."
    exit -1
fi

SECRETS_FRONT_SEED_TMPL_FILE_PATH=$4

if [ -f "$SECRETS_FRONT_SEED_TMPL_FILE_PATH" ]
then
    echo "$SECRETS_FRONT_SEED_TMPL_FILE_PATH found."
else
    echo "SECRETS_FRONT_SEED_TMPL_FILE_PATH $SECRETS_FRONT_SEED_TMPL_FILE_PATH not found."
    exit -1
fi


VALUES_API_SEED_TMPL_FILE_PATH=$5

if [ -f "$VALUES_API_SEED_TMPL_FILE_PATH" ]
then
    echo "$VALUES_API_SEED_TMPL_FILE_PATH found."
else
    echo "VALUES_API_SEED_TMPL_FILE_PATH $VALUES_API_SEED_TMPL_FILE_PATH not found."
    exit -1
fi


VALUES_FRONT_SEED_TMPL_FILE_PATH=$6

if [ -f "$VALUES_FRONT_SEED_TMPL_FILE_PATH" ]
then
    echo "$VALUES_FRONT_SEED_TMPL_FILE_PATH found."
else
    echo "VALUES_FRONT_SEED_TMPL_FILE_PATH $VALUES_FRONT_SEED_TMPL_FILE_PATH not found."
    exit -1
fi

DOCKER_REG_API_SEED_TMPL_FILE_PATH=$7

if [ -f "$DOCKER_REG_API_SEED_TMPL_FILE_PATH" ]
then
    echo "$DOCKER_REG_API_SEED_TMPL_FILE_PATH found."
else
    echo "DOCKER_REG_API_SEED_TMPL_FILE_PATH $DOCKER_REG_API_SEED_TMPL_FILE_PATH not found."
    exit -1
fi

DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH=$8

if [ -f "$DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH" ]
then
    echo "$DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH found."
else
    echo "DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH $DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH not found."
    exit -1
fi


MICROSERVICE_TYPE_INSTALL=$9

if [ -f "$MICROSERVICE_TYPE_INSTALL" ]
then
    echo "$MICROSERVICE_TYPE_INSTALL found."
else
MICROSERVICE_TYPE_INSTALL="both"
fi

KUBERNETES_CLUSTER_NAME=$10

if [ -f "$KUBERNETES_CLUSTER_NAME" ]
then
    echo "$KUBERNETES_CLUSTER_NAME found."
else
KUBERNETES_CLUSTER_NAME="rancher-desktop"
fi

which kubeseal>/dev/null || echo "Kubeseal is not installed";

if [ "$KUBERNETES_CLUSTER_NAME" == "rancher-desktop" ]; then
kubectl config use-context rancher-desktop
elif [ "$KUBERNETES_CLUSTER_NAME" == "aks" ]; then

if [ "$TARGET_ENV" == "test" ]; then
export KUBECONFIG=/Users/balinderwalia/.kube/aks-hsv3-acc-original.yaml
kubectl config use-context SCN-HSV3-ACC

elif [ "$TARGET_ENV" == "acc" ]; then
export KUBECONFIG=/Users/balinderwalia/.kube/aks-hsv3-acc-original.yaml
kubectl config use-context SCN-HSV3-ACC

elif [ "$TARGET_ENV" == "prod" ]; then
export KUBECONFIG=/Users/balinderwalia/.kube/aks-hsv3-prod.yaml
kubectl config use-context SCN-HSV3-PRD
fi

else
kubectl config use-context rancher-desktop
fi

kubectl config current-context

echo "Generating Kubesealed secrets for env...$SECRET_ENV_FILE_PATH"

rm -Rf temp_secret_api_0.yaml
rm -Rf temp_secret_front_0.yaml
rm -Rf temp_secret_api.yaml
rm -Rf temp_secret_front.yaml
rm -Rf temp_secrets_api_0.yaml
rm -Rf temp_secrets_api_1.yaml
rm -Rf temp_secrets_front_0.yaml
rm -Rf temp_secrets_front_1.yaml
rm -Rf temp_nexus_secrets_api_0.yaml
rm -Rf temp_nexus_secrets_front_0.yaml
rm -Rf secret-nexus-image-api-sealed.yaml
rm -Rf secret-nexus-image-api-sealed.yaml

#generate secret file from seed template
if [[ -e "$SECRET_ENV_FILE_PATH" ]]; then
    # 
    echo "The $SECRET_ENV_FILE_PATH file exists."
        # Encode the contents of the .env file to base64
    encoded_content=$(cat "$SECRET_ENV_FILE_PATH" | base64)

    awk -v encoded_content="$encoded_content" '/env_file:/ {$2=encoded_content} 1' "$SECRETS_API_SEED_TMPL_FILE_PATH" > temp_secret_api.yaml
    #awk -v replacement_value="int" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' /tmp/temp.yaml > /tmp/temp.yaml
    #cat /tmp/temp.yaml | awk -v srch=__target_environment_ref__ -v repl=int '{ sub(srch,repl,$0); print $0 }' > /tmp/temp.yaml
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_api.yaml > temp_secrets_api_0.yaml
    awk -v replacement_value="  env_file" '{ gsub(/env_file/, replacement_value) } 1' temp_secrets_api_0.yaml > temp_secrets_api_1.yaml

    awk -v encoded_content="$encoded_content" '/env_file:/ {$2=encoded_content} 1' "$SECRETS_FRONT_SEED_TMPL_FILE_PATH" > temp_secret_front.yaml
    #awk -v replacement_value="int" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' /tmp/temp.yaml > /tmp/temp.yaml
    #cat /tmp/temp.yaml | awk -v srch=__target_environment_ref__ -v repl=int '{ sub(srch,repl,$0); print $0 }' > /tmp/temp.yaml
    replacement_value=$TARGET_ENV
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_front.yaml > temp_secrets_front_0.yaml
    awk -v replacement_value="  env_file" '{ gsub(/env_file/, replacement_value) } 1' temp_secrets_front_0.yaml > temp_secrets_front_1.yaml

else
    echo "The secret seed template file does not exist. Please add the secret seed template file"
    exit
fi

if [[ -e "$DOCKER_REG_API_SEED_TMPL_FILE_PATH" ]]; then
    
    echo "The $DOCKER_REG_API_SEED_TMPL_FILE_PATH file exists."
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' $DOCKER_REG_API_SEED_TMPL_FILE_PATH > temp_nexus_secrets_api_0.yaml

else
    echo "Docker registry credentials file not found. Please try again!"
    exit
fi

if [[ -e "$DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH" ]]; then
    
    echo "The $DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH file exists."
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' $DOCKER_REG_FRONT_SEED_TMPL_FILE_PATH > temp_nexus_secrets_front_0.yaml

else
    echo "Docker registry credentials file not found. Please try again!"
    exit
fi


CLUSTER_NAME=aks
CLUSTER_NAME=rancher-desktop
#kubeseal --fetch-cert > /tmp/cert.pem
#--cert /tmp/cert.pem #--scope cluster-wide 
kubeseal --format yaml <temp_secrets_api_1.yaml> secret-api-env-file-sealed.yaml
kubeseal --format yaml <temp_secrets_front_1.yaml> secret-front-env-file-sealed.yaml
kubeseal --format yaml <temp_nexus_secrets_api_0.yaml> secret-nexus-image-api-sealed.yaml
kubeseal --format yaml <temp_nexus_secrets_front_0.yaml> secret-nexus-image-front-sealed.yaml
#cat secret-api-env-file-sealed.yaml

SEALED_SECRET_ENV_FILE_CONTENT=$(yq eval '.spec.encryptedData.env_file' secret-api-env-file-sealed.yaml)
SEALED_SECRET2_ENV_FILE_CONTENT=$(yq eval '.spec.encryptedData.env_file' secret-front-env-file-sealed.yaml)
SEALED_NEXUS_IMAGE_SECRET_API=$(yq eval '.spec.encryptedData.".dockerconfigjson"' secret-nexus-image-api-sealed.yaml)
echo $SEALED_NEXUS_IMAGE_SECRET_API
SEALED_NEXUS_IMAGE_SECRET_FRONT=$(yq eval '.spec.encryptedData.".dockerconfigjson"' secret-nexus-image-front-sealed.yaml)
echo $SEALED_NEXUS_IMAGE_SECRET_FRONT

#VALUES_API_SEED_TMPL_FILE_PATH="/tmp/sealed-secret-tmp.yaml"
#VALUES_API_SEED_TMPL_FILE_PATH="/Users/balinderwalia/Documents/Work/Tenthmatrix_Ltd/dmz-api-gw/devops/helm-charts/dmz/values-api-seed-template.yaml"

if [[ -n "$SEALED_SECRET_ENV_FILE_CONTENT" && -n "$SEALED_SECRET2_ENV_FILE_CONTENT" ]]; then
    awk -v encoded_content="$SEALED_SECRET_ENV_FILE_CONTENT" '/secure_env_file:/ {$2=encoded_content} 1' "$VALUES_API_SEED_TMPL_FILE_PATH" > temp_secret_api_0.yaml
    awk -v encoded_content="$SEALED_SECRET2_ENV_FILE_CONTENT" '/secure_env_file:/ {$2=encoded_content} 1' "$VALUES_FRONT_SEED_TMPL_FILE_PATH" > temp_secret_front_0.yaml
    #awk -v replacement_value="int" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' /tmp/temp.yaml > /tmp/temp.yaml
    #cat /tmp/temp.yaml | awk -v srch=__target_environment_ref__ -v repl=int '{ sub(srch,repl,$0); print $0 }' > /tmp/temp.yaml

    awk -v encoded_content="$SEALED_NEXUS_IMAGE_SECRET_API" '/regcred_nexus_healthdata:/ {$2=encoded_content} 1' "temp_secret_api_0.yaml" > temp_secret_api.yaml
    awk -v encoded_content="$SEALED_NEXUS_IMAGE_SECRET_FRONT" '/regcred_nexus_healthdata:/ {$2=encoded_content} 1' "temp_secret_front_0.yaml" > temp_secret_front.yaml

if [ "$MICROSERVICE_TYPE_INSTALL" == "api" ]; then
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_api.yaml > values-$TARGET_ENV-api-$CLUSTER_NAME.yaml
    mv values-$TARGET_ENV-api-$CLUSTER_NAME.yaml devops/helm-charts/dmz/values-$TARGET_ENV-api-$CLUSTER_NAME.yaml

elif [ "$MICROSERVICE_TYPE_INSTALL" == "front" ]; then
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_front.yaml > values-$TARGET_ENV-front-$CLUSTER_NAME.yaml
    mv values-$TARGET_ENV-front-$CLUSTER_NAME.yaml devops/helm-charts/dmz/values-$TARGET_ENV-front-$CLUSTER_NAME.yaml
else
    echo "Both microservices are being installed"
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_api.yaml > values-$TARGET_ENV-api-$CLUSTER_NAME.yaml
    mv values-$TARGET_ENV-api-$CLUSTER_NAME.yaml devops/helm-charts/dmz/values-$TARGET_ENV-api-$CLUSTER_NAME.yaml
    awk -v replacement_value="$TARGET_ENV" '{ gsub(/__target_environment_ref__/, replacement_value) } 1' temp_secret_front.yaml > values-$TARGET_ENV-front-$CLUSTER_NAME.yaml
    mv values-$TARGET_ENV-front-$CLUSTER_NAME.yaml devops/helm-charts/dmz/values-$TARGET_ENV-front-$CLUSTER_NAME.yaml
fi
    stat devops/helm-charts/dmz/values-$TARGET_ENV-api-$CLUSTER_NAME.yaml
    stat devops/helm-charts/dmz/values-$TARGET_ENV-front-$CLUSTER_NAME.yaml
#    echo "Encoded .env file and saved the result in $VALUES_API_SEED_TMPL_FILE_PATH."
else
    echo "The .env file does not exist. Please add the .env file"
    exit
fi

if [ -z "$CLUSTER_NAME" ]; then
   echo "Cluster name is not provided"
   exit -1
else
   echo "Cluster name is provided ok"
fi

echo "Deploying to the currently selected kubernetes cluster"
# Init kubeconfig for the cluster
HELM_CMD="helm"
KUBECTL_CMD="kubectl"

# $HELM_CMD upgrade -i node-app ./devops/helm-charts/node-app/ -f devops/helm-charts/node-app/values-$CLUSTER_NAME.yaml
# $KUBECTL_CMD rollout restart deployment/node-app
# $KUBECTL_CMD rollout history deployment/node-app

if [ "$MICROSERVICE_TYPE_INSTALL" == "both" ]; then
   $HELM_CMD upgrade -i dmz-api-$TARGET_ENV ./devops/helm-charts/dmz/ -f devops/helm-charts/dmz/values-$TARGET_ENV-api-$CLUSTER_NAME.yaml --set TARGET_ENV=$TARGET_ENV --namespace $TARGET_ENV --create-namespace
   $KUBECTL_CMD rollout restart deployment/dmz-api-$TARGET_ENV -n $TARGET_ENV
   $KUBECTL_CMD rollout history deployment/dmz-api-$TARGET_ENV -n $TARGET_ENV
   $HELM_CMD upgrade -i dmz-front-$TARGET_ENV ./devops/helm-charts/dmz/ -f devops/helm-charts/dmz/values-$TARGET_ENV-front-$CLUSTER_NAME.yaml --set TARGET_ENV=$TARGET_ENV --namespace $TARGET_ENV --create-namespace
   $KUBECTL_CMD rollout restart deployment/dmz-front-$TARGET_ENV -n $TARGET_ENV
   $KUBECTL_CMD rollout history deployment/dmz-front-$TARGET_ENV -n $TARGET_ENV
elif [ "$MICROSERVICE_TYPE_INSTALL" == "api" ]; then
   $HELM_CMD upgrade -i dmz-api-$TARGET_ENV ./devops/helm-charts/dmz/ -f devops/helm-charts/dmz/values-$TARGET_ENV-api-$CLUSTER_NAME.yaml --set TARGET_ENV=$TARGET_ENV --namespace $TARGET_ENV --create-namespace
   $KUBECTL_CMD rollout restart deployment/dmz-api-$TARGET_ENV -n $TARGET_ENV
   $KUBECTL_CMD rollout history deployment/dmz-api-$TARGET_ENV -n $TARGET_ENV
elif [ "$MICROSERVICE_TYPE_INSTALL" == "front" ]; then
   $HELM_CMD upgrade -i dmz-front-$TARGET_ENV ./devops/helm-charts/dmz/ -f devops/helm-charts/dmz/values-$TARGET_ENV-front-$CLUSTER_NAME.yaml --set TARGET_ENV=$TARGET_ENV --namespace $TARGET_ENV --create-namespace
   $KUBECTL_CMD rollout restart deployment/dmz-front-$TARGET_ENV -n $TARGET_ENV
   $KUBECTL_CMD rollout history deployment/dmz-front-$TARGET_ENV -n $TARGET_ENV
fi

rm -Rf temp_secret_api_0.yaml
rm -Rf temp_secret_front_0.yaml
rm -Rf temp_secret_api.yaml
rm -Rf temp_secret_front.yaml
rm -Rf temp_secrets_api_0.yaml
rm -Rf temp_secrets_api_1.yaml
rm -Rf temp_secrets_front_0.yaml
rm -Rf temp_secrets_front_1.yaml
rm -Rf temp_nexus_secrets_api_0.yaml
rm -Rf temp_nexus_secrets_front_0.yaml
rm -Rf secret-nexus-image-api-sealed.yaml
rm -Rf secret-nexus-image-api-sealed.yaml

echo "Deploying to the currently selected kubernetes cluster"
sleep 30
$KUBECTL_CMD get deploy,svc,pods,ing -n $TARGET_ENV



