Get_DevOps_PAT(){
  if ! echo $PAT_USERNAME &> /dev/null; then

# Prompt the user for their ADO username
    read -p "Enter your ADO username: " PAT_USERNAME
    export PAT_USERNAME
  else
    echo "PAT_USERNAME already set. Continuing..."
  fi
if ! echo $PAT_SECRET &> /dev/null; then
# Prompt the user for their ADO PAT (hidden input for security)
  read -s -p "Enter your ADO PAT: " PAT_SECRET
  echo
  export PAT_SECRET
else
echo "PAT_SECRET already set. Continuing..."
fi
# Substitute variables in the YAML file using sed
sed "s|\${PAT_USERNAME}|$PAT_USERNAME|g; s|\${PAT_SECRET}|$PAT_SECRET|g" devops-repo-PAT.yaml > processed-devops-repo-PAT.yaml
echo "Checking if processed-devops-repo-PAT.yaml was created..."
ls -l processed-devops-repo-PAT.yaml
kubectl apply -f ./processed-devops-repo-PAT.yaml
}
