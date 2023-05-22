function Exit-Log {
    param(
        [Parameter(Mandatory = $false)][string]$descripcionError
    )

    Disconnect-AzAccount
    $endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
    Write-Output "`n$descripcionError" "Finalizando ejecución: $endTime`n"
    exit
}

# Clear-Host

$beginTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
Write-Output "Iniciando ejecución: $beginTime"

if ($args.Count -ne 5) {
    $scriptName = $MyInvocation.MyCommand.Name

    Write-Output "ERROR: Debe ejecutar el comando con todas los parámetros. Ej.:`n" "`t$scriptName <nombreUbicacion> <nombreResourceGroup> <nombreAppServicePlan> <nombreWebApplication> <nombreAzureFunction>`n"
    Exit-Log
}

$nombreUbicacion = $args[0]
$nombreResourceGroup = $args[1]
$nombreAppServicePlan = $args[2]
$nombreWebApplication = $args[3]
$nombreAzureFunction = $args[4]


# Conectarme a Azure
Disconnect-AzAccount
try {
    Connect-AzAccount | Out-Null;
    $ctx = Get-AzContext;
    if ( $null -eq $ctx ) {
        Exit-Log "No se pudo adquirir el contexto."
    }
}
catch {
    Exit-Log "No se pudo conectar a Azure"
}

# Verificar Resource Group / Crear
Get-AzResourceGroup -Name $nombreResourceGroup -Location $nombreUbicacion -ErrorVariable noExisteResourceGroup -ErrorAction SilentlyContinue

if ($noExisteResourceGroup) {
    try {
        Write-Output "Creando grupo de recursos $nombreResourceGroup en la ubicación $nombreUbicacion..."
        New-AzResourceGroup -Name $nombreResourceGroup -Location $nombreUbicacion
    }
    catch {
        Exit-Log "Ocurrió un error creando el grupo de recursos $nombreResourceGroup en la ubicación $nombreUbicacion"
    }
}
else {
    Exit-Log "Ya existe un grupo de recursos con el nombre $nombreResourceGroup."
}


# Verificar App Service Plan / Crear
Get-AzResource -Name $nombreAppServicePlan -ResourceGroupName $nombreResourceGroup -ResourceType Microsoft.Web/serverfarms -ErrorVariable noExisteAppServicePlan -ErrorAction SilentlyContinue

if ($noExisteAppServicePlan) {
    try {
        Write-Output "Creando el App Service plan $nombreAppServicePlan en $nombreResourceGroup..."
        $plan = New-AzAppServicePlan -Name $nombreAppServicePlan -ResourceGroupName $nombreResourceGroup -Location $nombreUbicacion
    }
    catch {
        Exit-Log "Hubo un error creando el App Service plan $nombreAppServicePlan en $nombreResourceGroup"
    }
}
else {
    Exit-Log "Ya existe un App Service Plan con el nombre $nombreAppServicePlan."
}

# Verificar App Service Web Application / Crear
Get-AzResource -Name $nombreWebApplication -ResourceGroupName $nombreResourceGroup -ResourceType Microsoft.Web/sites -ErrorVariable noExisteWebApplication -ErrorAction SilentlyContinue

if ($noExisteWebApplication) {
    try {
        Write-Output "Creando Web Application $nombreWebApplication en $nombreResourceGroup..."
        New-AzResource -Location $nombreUbicacion -ResourceName $nombreWebApplication -ResourceType "microsoft.Web/sites" -ResourceGroupName $nombreResourceGroup -Force -Properties @{
            Createdby    = "AZPowershell"
            serverFarmId = $sf.Id
        }
    }
    catch {
        Exit-Log "Hubo un error creando Web Application $nombreWebApplication en $nombreResourceGroup"
    }
}
else {
    Exit-Log "Ya existe una Web Application $nombreWebApplication en $nombreResourceGroup"
}

# Verificar Azure Function / Crear
Get-AzResource -Name $nombreAzureFunction -ResourceGroupName $nombreResourceGroup -ResourceType Microsoft.Web/sites -ErrorVariable noExisteAzureFunction -ErrorAction SilentlyContinue

if ($noExisteAzureFunction) {
    try {
        Write-Output "Creando Web Function $nombreAzureFunction en $nombreResourceGroup..."
        
        New-AzResource -Location $nombreUbicacion -Kind "functionapp" -Force -ResourceName $nombreAzureFunction -ResourceGroupName $nombreResourceGroup -ResourceType "microsoft.Web/sites" -Properties @{Createdby = "AZPowershell" }
    }
    catch {
        Exit-Log "Hubo un error creando la función $nombreAzureFunction en $nombreResourceGroup"
    }
}
else {
    Exit-Log "Ya existe una función $nombreAzureFunction en $nombreResourceGroup"
}

Exit-Log "Finalizando sin errores..."
