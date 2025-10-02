

    $PAT_USERNAME = read-host "Enter your GitHub username"
    $PAT_SECRET = read-host "Enter your GitHub PAT"
# Substitute variables in the YAML file using sed

$Manifest = Get-Content ./devops-repo-PAT.yaml 
$manifest = $Manifest.Replace('${PAT_USERNAME}',$PAT_USERNAME)
$manifest= $manifest.Replace('${PAT_SECRET}',$PAT_SECRET)
$manifest | Add-Content -Path ./processed-devops-repo-PAT.yaml
kubectl apply -f ./processed-devops-repo-PAT.yaml

