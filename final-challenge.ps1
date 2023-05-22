function Exit-Log {
    param(
        [Parameter(Mandatory = $false)][string]$descripcionError
    )

    Disconnect-AzAccount | Out-Null;
    $endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
    Write-Output $descripcionError "Finalizando ejecución: $endTime"
    exit
}

Clear-Host

$beginTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
Write-Output "Iniciando ejecución: $beginTime"

if ($args.Count -ne 5) {
    $scriptName = $MyInvocation.MyCommand.Name

    Write-Output "ERROR: Debe ejecutar el comando con todas los parámetros. Ej.:`n" "`t$scriptName <nombreUbicacion> <nombreResourceGroup> <nombreAppServicePlan> <nombreAppServiceWebApplication> <nombreAzureFunction>`n"
    Exit-Log
}

$nombreUbicacion = $args[0]
$nombreResourceGroup = $args[1]
$nombreAppServicePlan = $args[2]
$nombreAppServiceWebApplication = $args[3]
$nombreAzureFunction = $args[4]


# Conectarme a Azure
Disconnect-AzAccount | Out-Null;
try {
    Connect-AzAccount    
}
catch {
    Exit-Log "No se pudo conectar a Azure"
}

# Verificar Resource Group / Crear
# Get-AzResourceGroup -Name $nombreResourceGroup -Location $nombreUbicacion -ErrorVariable noExisteResourceGroup -ErrorAction SilentlyContinue

# if ($noExisteResourceGroup) {
#     try {
#         Write-Output "Creando grupo de recursos $nombreResourceGroup en la ubicación $nombreUbicacion..."
#         New-AzResourceGroup -Name $nombreResourceGroup -Location $nombreUbicacion
#     }
#     catch {
#         Exit-Log "Ocurrió un error creando el grupo de recursos $nombreResourceGroup en la ubicación $nombreUbicacion"
#     }
# }
# else {
#     Exit-Log "Ya existe un grupo de recursos con el nombre $nombreResourceGroup."
# }


# Verificar App Service Plan / Crear
Get-AzResource -Name $nombreAppServicePlan -ResourceGroupName $nombreResourceGroup -ResourceType Microsoft.Web/serverfarms -ErrorVariable noExisteAppServicePlan -ErrorAction SilentlyContinue

if ($noExisteAppServicePlan) {
    try {
        Write-Output "Creando el App Service plan $nombreAppServicePlan en $nombreResourceGroup..."
        New-AzAppServicePlan -Name $nombreAppServicePlan -ResourceGroupName $nombreResourceGroup
    }
    catch {
        Exit-Log "Hubo un error creando el App Service plan $nombreAppServicePlan en $nombreResourceGroup"
    }
}
else {
    Exit-Log "Ya existe un App Service Plan con el nombre $nombreAppServicePlan."
}

# Verificar App Service Web Application / Crear

# Verificar Azure Function / Crear



Exit-Log


