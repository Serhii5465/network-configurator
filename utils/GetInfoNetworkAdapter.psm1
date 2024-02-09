function GetNetworkProp {
    <#
    .SYNOPSIS
    Specifies the required properties of network adapters
        
    .OUTPUTS
    Returns list of properties.
    #>

    return @(
        "DNSHostName",
        "MACAddress",
        "Description",
        "DHCPEnabled",
        "InterfaceIndex",
        "IPAddress",
        "IPSubnet",
        "DefaultIPGateway",
        "DNSServerSearchOrder")
}

function GetAdapterList {
    <#    
    .DESCRIPTION
    Getting network adapters which supports TCP/IP using class Win32_NetworkAdapterConfiguration.
    
    .OUTPUTS
    Returns list of adapters.
    #>

    $Net_Prop = GetNetworkProp
    return Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE | Select-Object -Property $Net_Prop
}

function GetAdapterByMAC{
    <#
    .SYNOPSIS
    Getting network adapter by specific MAC 
        
    .PARAMETER MAC_Addr
    MAC address specified adapter
    
    .OUTPUTS
    Returns object type of [PSCustomObject] with propeties which declared in variable $Arr_Prop
    #>

    param (
        [string]$MAC_Addr
    )

    $Net_Prop = GetNetworkProp
    return Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "MACAddress='$MAC_Addr'" | Select-Object -Property $Net_Prop
}

function GetConnectStatusAdapter {
    <#
    .SYNOPSIS
    Checking status of the internet connection specific adapter
    
    .PARAMETER Name_Adapter
    Name of network adapter. Example: Intel(R) PRO/1000 MT Desktop Adapter
    
    .PARAMETER MAC_Addr
    MAC address needed adapter
    #>

    param (
        [string]$Name_Adapter,
        [string]$MAC_Addr
    )

    $Result_Query = (Get-WmiObject -Class Win32_NetworkAdapter -Filter "MACAddress='$MAC_Addr'")

    $Mesg = "Current state connection of the network adapter $Name_Adapter : "  
    $String_Status_Connect = ""
    $Code_Status_Connect = $Result_Query.NetConnectionStatus 

    <#
    Getting current code of status internet connection.
    If code equal value "2", current adapter does not have any hardware 
    or software problems, otherwise status code is being parsed 
    and script terminates.
    #>
    if($Code_Status_Connect -eq 2){
        $String_Status_Connect = $Mesg + "connected (Code 2)"
        Write-Host $String_Status_Connect
        WriteLog "INFO" $String_Status_Connect
    } else {
        switch ($Code_Status_Connect) {
            0 { $String_Status_Connect = $Mesg + "disconnected (Code 0)" }
            1 { $String_Status_Connect = $Mesg + "connecting (Code 1)" }
            3 { $String_Status_Connect = $Mesg + "disconnecting (Code 3)" }
            4 { $String_Status_Connect = $Mesg + "hardware not present (Code 4)" }
            5 { $String_Status_Connect = $Mesg + "hardware disabled (Code 5)" }
            6 { $String_Status_Connect = $Mesg + "hardware malfunction (Code 6)" }
            7 { $String_Status_Connect = $Mesg + "media disconnected (Code 7)" }
            8 { $String_Status_Connect = $Mesg + "authenticating (Code 8)" }
            9 { $String_Status_Connect = $Mesg + "authentication succeeded (Code 9)" }
            10 { $String_Status_Connect = $Mesg + "authentication failed (Code 10)" }
            11 { $String_Status_Connect = $Mesg + "invalid address (Code 11)" }
            12 { $String_Status_Connect = $Mesg + "credentials required (Code 12)" }
        }

        WriteLog "ERROR" $String_Status_Connect
        throw [ResourceUnavailable] $String_Status_Connect
    }
}

Export-ModuleMember -Function GetAdapterList, GetAdapterByMAC, GetConnectStatusAdapter