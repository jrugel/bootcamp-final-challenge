Clear-Host

if ($args.Count -lt 3) {
    $scriptName = $MyInvocation.MyCommand.Name

    Write-Output "ERROR: Debe ejecutar el comando con todas los parámetros. Ej.:`n" "`t$scriptName <nombreResourceGroup> <nombreAppServicePlan> <nombreAppServiceWebApplication> <nombreAzureFunction>`n"
    exit
}

Write-Output "OK"
