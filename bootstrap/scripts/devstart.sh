helm repo add jetstack https://charts.jetstack.io
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.7.1 --set installCRDs=true
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml





####
#

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install guestbook-nginx ingress-nginx/ingress-nginx --version v4.12.1 --set controller.ingressClass=nginx --namespace=sample-guestbook --set controller.watchNamespace=sample-guestbook --set controller.replicaCount=2 --set controller.metrics.enabled=true --set-string controller.podAnnotations."prometheus\.io/scrape"="true" --set-string controller.podAnnotations."prometheus\.io/port"="10254"

####