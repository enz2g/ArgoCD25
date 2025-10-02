# ArgoCD Bootstrap (Rancher Desktop Edition)

This folder bootstraps a Kubernetes cluster with [Argo CD](https://argo-cd.readthedocs.io) using the **App of Apps pattern**. It automates deployment of applications like Grafana and Guestbook in a GitOps-compliant way.

> ⚠️ Target environment: Local Kubernetes via Rancher Desktop with Traefik as the default Ingress controller.

---

## 🔧 What This Does

- Installs ArgoCD into the cluster.
- Exposes the ArgoCD UI at **https://argocd.local**.
- Bootstraps child ArgoCD applications via a central "App of Apps".
- Deploys each application (e.g., Grafana, Guestbook) with separate configurations (local only for now) 

---

## 📁 Folder Structure

```
bootstrap/
├── app-of-apps.yaml          # Registers all child applications with ArgoCD
├── argocd-ingress.yaml       # Traefik ingress to access ArgoCD locally
├── bootstrap.sh              # Automates install + config + login
├── apps/
│   ├── grafana.yaml
│   └── guestbook.yaml
├── apps-config/
│   ├── environment
|   |  └── local-dev
|   |     ├── grafana.yaml
│   |     └── guestbook.yaml
│   ├── variant
|   |  └── local
|   |    ├── grafana.yaml
│   |    └── guestbook.yaml
│   ├── base
|   |    ├── grafana.yaml
│   └    └── guestbook.yaml
└── README.md                 # You're reading it
```

---

## 🚀 Quick Start

> ⚠️ Assumes: Rancher Desktop is running with Kubernetes, and `kubectl` & `argocd` CLI are installed.

1. **Clone the repository**
   ```bash
   git clone https://github.com/enz2g/ArgoCD25
   cd ArgoCD25/bootstrap
   ```
#### <span style="color: red;"> 📛 BOOTSTRAP Script is for Mac/Linux Machines to run shell. A Powershell script will be available to do Windows</span>

2. **Run the bootstrap script**
   ```bash
   ./bootstrap.sh
   ```

3. **Access ArgoCD UI**
   Open [https://argocd.local](https://argocd.local) in your browser.

4. **Login to ArgoCD**
   - **Username**: `admin`
   - **Password**: Get the server pod name:
     ```bash
     kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f2
     ```

---

## 📦 Applications

| Name       | Source                      | Chart Type | Namespace       |
|------------|-----------------------------|------------|-----------------|
| Grafana    | grafana.github.io Helm repo | External   | `grafana`       |
| Guestbook  |  Helm chart                 | Internal   | `guestbook`     |

Each app has its own `values-dev.yaml` and `values-prod.yaml` in the root of its folder.

---

## 📌 Notes

- All apps are **automatically synced and self-healing** (`syncPolicy: automated`).
- This repo uses the **App of Apps** pattern — one parent Application manages all child apps.
- The script also updates your `/etc/hosts` file so `https://argocd.local` works.
- **Only the parent app** needs to be applied manually — everything else is bootstrapped from Git.

---

## 🧼 Cleanup

To remove everything:
```bash
kubectl delete ns argocd grafana guestbook
```

---

## 🧠 Want to go further?

- Add `AppProject` definitions to control app access per team.
- Add `finalizers` to clean up child apps automatically.
- Set `targetRevision` to a Git tag or commit for prod apps (not just `HEAD`).

---

