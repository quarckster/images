$BASE_URL = "http://metadata.google.internal/computeMetadata/v1/instance/"

$VM_NAME = (Invoke-WebRequest -UseBasicParsing -URI "$BASE_URL/name" -Headers @{"Metadata-Flavor" = "Google"}).ToString()
$TOKEN = (Invoke-WebRequest -UseBasicParsing -URI "$BASE_URL/attributes/token" -Headers @{"Metadata-Flavor" = "Google"}).ToString()
$REPO_URL = (Invoke-WebRequest -UseBasicParsing -URI "$BASE_URL/attributes/repo_url" -Headers @{"Metadata-Flavor" = "Google"}).ToString()
$LABELS = Get-Content C:\actions-runner\runner_labels

Set-Location "C:\actions-runner" 

./config.cmd --url $REPO_URL --token $TOKEN --ephemeral --unattended --name $VM_NAME --disableupdate --labels $LABELS

./run.cmd
