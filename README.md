
##  Quick Start

> ⚠️ Assumes: Rancher Desktop is running with Kubernetes, and `kubectl` & `argocd` CLI are installed.

1. **Clone the repository**
   ```bash
   git clone https://github.com/enz2g/ArgoCD25
   cd ArgoCD25/bootstrap
   ```

2. **Run the bootstrap script**
This is a linux/Mac script, windows isn't bootstrapped the same (walkthrough bootstrap script to run commands)

   ```bash
   ./bootstrap.sh
   ```

3. **Access ArgoCD UI**
   Open [https://argocd.local](https://argocd.local) in your browser.

4. **Login to ArgoCD**
   - **Username**: `admin`
   - **Password**: Run argocd CLI command
     ```bash
     argocd admin initial-password -n argocd 
     ```

---

##  Application sets

| Name       | Source                      | Chart Type | Namespace       |
|------------|-----------------------------|------------|-----------------|
| Grafana    | grafana.github.io Helm repo | External   | `grafana`       |
| Brads App  |  Helm chart                 | Internal   | `bradsapp`      |

Each app has its own `values-dev.yaml` and `values-prod.yaml` in the root of its folder.

---

## Deployment structure

- This repo uses the **App of Apps** pattern — one parent Application manages all child apps.
- There are also helper scripts to update your `/etc/hosts` file so `https://argocd.local` works.
- **Only the App of Apps** needs to be applied manually — everything else is bootstrapped from Git.

---

## Manual Self Sign Certificates
Because it is a local environment we need to create self signed certificates, below is to create Brads App self signed certificates with Bash.
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout bradsapp.key -out bradsapp.crt -subj /"/CN=bradsapp.local/O=bradsapp.local/"
```
Apply certificate files to webapp tls certificate secret 
```
kubectl create secret tls webapp-tls --cert=bradsapp.crt --key=bradsapp.key -n bradsapp
```