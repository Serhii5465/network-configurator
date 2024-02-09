#Requires -RunAsAdministrator

Set-Location $PSScriptRoot

$ErrorActionPreference = 'Stop'

Import-Module -Name .\utils\Logger.psm1 -Force
Import-Module -Name .\utils\Parser.psm1 -Force
Import-Module -Name .\utils\GetInfoNetworkAdapter.psm1 -Force
Import-Module -Name .\utils\Setter.psm1 -Force
Import-Module -Name .\utils\Formatter.psm1 -Force

function Main {
    CreateLogDir 

    $List_Obj_Network = ParseFile($Preset_File)

    $Network_Adapter = $List_Obj_Network[0]
    $New_Network_Settings = $List_Obj_Network[1]
    
    WriteLog "INFO" (-join ("Current index: ", $New_Network_Settings.NUM, ", current MAC: ", $Network_Adapter.MACAddress))

    GetConnectStatusAdapter $Network_Adapter.Description $Network_Adapter.MACAddress
    
    ModifyNetworkPrefer $Network_Adapter $New_Network_Settings

    SetHostname $New_Network_Settings.HOSTNAME
}

Main