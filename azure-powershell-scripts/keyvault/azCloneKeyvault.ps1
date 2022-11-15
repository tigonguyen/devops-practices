Function Clone-KeyVault(
    [string]$subscriptionName,
    [string]$sourceVaultName,
    [string]$destVaultName
)
{
    $secretList = @()

    # Get source and destination ENV
    $sourceVaultNameArray = $sourceVaultName.Split("-")
    $destVaultNameArray = $destVaultName.Split("-")
    $sourceEnv = $sourceVaultNameArray[1]
    $destEnv = $destVaultNameArray[1]

    # Get list of source secrets' ID
    az account set --subscription $subscriptionName
    $keyVaultEntries = (az keyvault secret list --vault-name $sourceVaultName | ConvertFrom-Json) | Select-Object id
    
    # Get secrets' value based on IDs
    foreach($entry in $keyVaultEntries)
    {
        # Get source keyvalt secrets, then store to a list
        $secret = (az keyvault secret show --id $entry.id | ConvertFrom-Json) | Select-Object name, value
        $destSecretName = $secret.name
        if ($secret.name.Contains($sourceEnv)) {
            $destSecretName = $secret.name.replace($sourceEnv, $destEnv)
        }

        $secretDict = [Ordered]@{name=$destSecretName;value=$secret.value}
        $secretList += $secretDict
        Write-Host "Cloned" $destSecretName
    }

    # Set secrets to destination vault
    echo $secretList.Length
    foreach($entry in $secretList) {
        az keyvault secret set --name $entry.name --vault-name $destVaultName --value $entry.value
        Write-Host "Added" $entry.name
    }
}

Clone-KeyVault "XXX YYY" "xxx-qa1" "xxx-qa2"