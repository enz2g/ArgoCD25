#!/bin/bash
set -e
#########################################################################
# This script is for Mac/Linux systems with kubectl and argocd CLI installed
# It checks for the correct kubectl context, installs ArgoCD if not present,
# NEED TO CREATE A POWERSHELL VERSION FOR WINDOWS
#########################################################################
EXPECTED_CONTEXT="rancher-desktop"
argocdServerURL="argocd.local" #update to the correct URL for the cluster

echo "🔍 Checking current kubectl context..."
CURRENT_CONTEXT=$(kubectl config current-context)
EXPECTED_NAMESPACE="argocd"
# Define the namespace and deployment name
NAMESPACE="argocd"
DEPLOYMENT_NAME="argocd-server"

if [[ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]]; then
  echo "You are not connected to the expected Kubernetes context: '$EXPECTED_CONTEXT'"
  echo "   Current context is: '$CURRENT_CONTEXT'"
  echo "Run 'kubectl config use-context $EXPECTED_CONTEXT' to switch."
  exit 1
fi

echo "Connected to expected context: '$CURRENT_CONTEXT'"


# Check if the namespace exists
echo "checking for namespace ${EXPECTED_NAMESPACE}..."
if ! kubectl get namespace | grep "${EXPECTED_NAMESPACE}" &> /dev/null; then
  echo "Namespace '${EXPECTED_NAMESPACE}' does not exist. Creating it..."
  kubectl create namespace "${EXPECTED_NAMESPACE}"
else
  echo "Namespace '${EXPECTED_NAMESPACE}' already exists."
fi

# Check if the Argo CD deployment exists
if ! kubectl get deployment "${DEPLOYMENT_NAME}" -n "${NAMESPACE}" &> /dev/null; then
  echo "Argo CD is not installed. Installing it now..."
  kubectl apply -n "${NAMESPACE}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
else
  echo "Argo CD is already installed in the '${NAMESPACE}' namespace."
fi


###### Replace Ingress here for NON-Local Clusters to pick up correct ingress with SSL etc.
# Add ${argocdServerURL} to /etc/hosts if it's not already present
if ! grep -q "${argocdServerURL}" /etc/hosts; then
  echo "🔧 Adding ${argocdServerURL} to /etc/hosts (requires sudo)..."
  echo "127.0.0.1 ${argocdServerURL}" | sudo tee -a /etc/hosts > /dev/null
else
  echo "✅ argocd.local already present in /etc/hosts"
fi

echo "🌐 Applying ArgoCD Ingress for Traefik (${argocdServerURL})..."
kubectl apply -f argocd-cmd-params-cm.yaml

# Generate self-signed TLS cert if not exists
if [[ ! -f "argocd.crt" || ! -f "argocd.key" ]]; then
  echo "🔐 Generating self-signed TLS cert for ${argocdServerURL}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout argocd.key -out argocd.crt -subj "/CN=${argocdServerURL}/O=${argocdServerURL}"
else
  echo "🔐 Reusing existing argocd.crt and argocd.key"
fi


echo "🔐 Creating/updating TLS secret in argocd namespace..."
kubectl delete secret argocd-tls -n argocd --ignore-not-found
kubectl create secret tls argocd-tls --cert=argocd.crt --key=argocd.key -n argocd

# Restart argocd-server to pick up --insecure config
echo "🔄 Restarting argocd-server..."
kubectl -n argocd rollout restart deployment argocd-server

# Wait for rollout to complete
kubectl -n argocd rollout status deployment argocd-server


# Server Ingress so we're reachable
if ! kubectl get ingress "argocd-server-ingress" -n "${NAMESPACE}" &> /dev/null; then
    echo "Argo CD ingress is not deployed. Deploying it now..."
    kubectl apply -n "${NAMESPACE}" -f argocd-ingress.yaml
  else
    echo "Argo CD Ingress is already Deployed in the '${NAMESPACE}' namespace. Continuing..."
fi


#git Repo Connector
if ! kubectl get secret "edx-platform-gitops-repo" -n "${NAMESPACE}" &> /dev/null; then
    echo "🧩 Registering Git Connector..."
    echo "..."
  if  "$CURRENT_CONTEXT" !=  "rancher-desktop" ; then
  echo "Rancher Desktop Detected... Setting up git with PAT Token"
  . ./scripts/update-PAT-Repoyaml.sh
  Get_DevOps_PAT
else
  echo "Rancher Desktop not detected"
fi
else
  echo "Git Connector Already Deployed. Continuing..."
fi


echo "🧩 Registering App of Apps..."
kubectl apply -f ./project-platform.yaml
kubectl apply -f ../apps/app-of-apps.yaml

echo "🚀 Setup complete. Access ArgoCD at: https://argocd.local"


# Ask the user if they want to set the ArgoCD admin password
updateArgoAdminPW=true
read -p "Do you want to set the ArgoCD admin password? (yes/no): " response
if [[ "$response" == "yes" || "$response" == "y" ]]; then
# moving off cmdline to pipline switch this out of the prompt
  ArgoPW=$(argocd admin initial-password -n argocd | head -n 1)
  # Prompt the user for their ADO PAT (hidden input for security)
  read -s -p "Enter your preferred admin PW"
  echo
  export $ArgoMainPW
  argocd login argocd.local --insecure --username admin --password $ArgoPW --grpc-web
  argocd account update-password --account admin --current-password $ArgoPW --new-password $ArgoMainPW --insecure --grpc-web --server $argocdServerURL
  # Testing SWAP BACK
  #  argocd account update-password --account admin --current-password $ArgoMainPW --new-password $ArgoPW --insecure --grpc-web --server $argocdServerURL

  echo "✅ ArgoCD admin password has been updated."
else
  echo "❌ Skipping ArgoCD admin password setup. if DEFAULT Password still active, Please change it!"
fi