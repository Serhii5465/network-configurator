function ModifyNetworkPrefer{
    <#
    .SYNOPSIS
    Setting new network setting to specific Ethernet adapter
    
    .DESCRIPTION
    This function setting new IP address and subnet mask if DHCP enabled.
    Otherwise, will be set new values of IP,subnet mask,gateway and DNS servers.
    
    .PARAMETER Network_Adapter
    Variable type of [PSObject] which contains propeties be like: name,MAC,status Internet connection, etc.

    .PARAMETER Network_Preference
    [PSObject] which contains IP,subnet mask,gateway and primary/secondary DNS servers.
    
    #>

    param (
        [PSObject]$Network_Adapter,
        [PSObject]$Network_Preference
    )

    printNetworkConfigToConsole "Current" $Network_Adapter
    WriteLog "INFO" (GetNetworkConfForLog $Network_Adapter)
    
    $isDHCP_On = $Network_Adapter.DHCPEnabled
    $Message_Set_Pref = "New network configuration, which will be installed"

    if($isDHCP_On -eq $true){
        WriteLog "INFO" (GetNetworkPreferForLog $Network_Preference $isDHCP_On)
        Write-Host $Message_Set_Pref ($Network_Preference | Select-Object -Property * -ExcludeProperty NUM | Format-List | Out-String)
        
        try {
            #Setting new values of IP,subnet mask and gateway 
            New-NetIPAddress -InterfaceIndex $Network_Adapter.InterfaceIndex `
            -IPAddress $Network_Preference.IP `
            -PrefixLength $Network_Preference.MASK `
            -DefaultGateway $Network_Preference.GATEWAY | Out-Null

            #Setting new DNS
            Set-DnsClientServerAddress -InterfaceIndex $Network_Adapter.InterfaceIndex -ServerAddresses ($Network_Preference.DNS1,$Network_Preference.DNS2) | Out-Null 
            
        }
        catch {
            WriteLog "ERROR" (GetErrorRecordForLog $PSItem.Exception.Message $PSItem.CategoryInfo $PSItem.InvocationInfo)
            throw $PSItem
        }
    } else {   
        WriteLog "INFO" (GetNetworkPreferForLog $Network_Preference $isDHCP_On)
        Write-Host $Message_Set_Pref ($Network_Preference | Select-Object -Property IP,MASK | Format-List | Out-String) -NoNewline
       
        try {
            Remove-NetIPAddress -InterfaceIndex $Network_Adapter.InterfaceIndex -Confirm:$false

            New-NetIPAddress -InterfaceIndex $Network_Adapter.InterfaceIndex `
            -IPAddress $Network_Preference.IP -PrefixLength $Network_Preference.MASK | Out-Null
        }
        catch {
            WriteLog "ERROR" (GetErrorRecordForLog $PSItem.Exception.Message $PSItem.CategoryInfo $PSItem.InvocationInfo)
            throw $PSItem
        }
    } 
    
    $Updated_Network_Adpt = GetAdapterByMAC($Network_Adapter.MACAddress)
    PrintNetworkConfigToConsole "Updated" $Updated_Network_Adpt
    WriteLog "INFO" "Good. $(GetNetworkConfForLog $Updated_Network_Adpt)"
}

function SetHostname{
    <#
    .SYNOPSIS
    Setting new hostname
        
    .PARAMETER Name
    New domain name, which will be assingned to current machine    
    #>

    param (
        [string]$Name
    )
    
    try {
        Write-Output "The new computer name will be $Name"
        Rename-Computer -NewName $Name -Confirm -Restart
    }
    catch {
        WriteLog "ERROR" (GetErrorRecordForLog $PSItem.Exception.Message $PSItem.CategoryInfo $PSItem.InvocationInfo)
        throw $PSItem
    }
}

Export-ModuleMember -Function ModifyNetworkPrefer, SetHostname