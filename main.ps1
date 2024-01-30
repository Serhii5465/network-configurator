# Requires -RunAsAdministrator

Set-Location $PSScriptRoot

Import-Module -Name .\src\Logger.psm1 -Force -Verbose
Import-Module -Name .\src\Parser.psm1 -Force -Verbose
Import-Module -Name .\src\InfoNetworkAdapter.psm1 -Force -Verbose
Import-Module -Name .\src\Setter.psm1 -Force -Verbose
Import-Module -Name .\src\Formatter.psm1 -Force -Verbose

$ErrorActionPreference = 'Stop'

function Main {
    $Preset_File = "net_preset.dat"
    $Path_File = $PSScriptRoot + "\" + $Preset_File

    if (!(Test-Path $Path_File)) {
        WriteLog "ERROR" "File $Preset_File doesn't exists"
        throw [System.IO.FileNotFoundException] "$Path_File not found."

    } else {   
        $List_Obj_Network = ParseFile($Preset_File)

        if($List_Obj_Network.Count -eq 0){
            WriteLog "ERROR" "No matching MAC addresses were found"
            throw [ParserError] "No matching MAC addresses were found"

        } else {
            CreateLogDir 

            $Network_Adapter = $List_Obj_Network[0]
            $New_Network_Settings = $List_Obj_Network[1]
            
            WriteLog "INFO" (-join ("Current index: ", $New_Network_Settings.NUM, ", current MAC: ", $Network_Adapter.MACAddress))

            GetConnectStatusAdapter $Network_Adapter.Description $Network_Adapter.MACAddress
            
            ModifyNetworkPrefer $Network_Adapter $New_Network_Settings

            SetHostname $New_Network_Settings.HOSTNAME
        }
    }
}

Main