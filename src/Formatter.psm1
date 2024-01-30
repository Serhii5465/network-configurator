function CheckIsLastProperty {
    <#    
    .DESCRIPTION
    Check if parameter $NameProperty equals value 
    "DNSServerSearchOrder".Otherwise return false.
    
    .PARAMETER NameProperty
    Network property like as Hostname,MAC,Gateway,Mask subnet,etc
    #>

    param (
        [string]$NameProperty
    )

    if($NameProperty -eq "DNSServerSearchOrder"){
        return $true
    } else {
        return $false
    }
}

function GetNetworkConfForLog {
    <#    
    .DESCRIPTION
    Function formats properties object type of PSObject to human-readable 
    format for logging
    
    .PARAMETER Network_Adapter
    Instance of object which contains info 
    about Ethernet adapter
    #>

    param (
        [PSObject]$Network_Adapter
    )

    $line = ''

    foreach($object_properties in $Network_Adapter.PsObject.Properties){
        if($object_properties.Value.GetType().FullName.toString() -eq "System.String[]"){        
            $temp_arr = $object_properties.Value
            $temp_str = ''
    
            if($temp_arr.Length -eq 1){
                if(CheckIsLastProperty($object_properties.Name)){
                    $temp_str += $temp_arr.GetValue(0)
                } 
                else {
                    $temp_str += $temp_arr.GetValue(0) + "; " 
                }
            } else {
                for ($i = 0; $i -lt $temp_arr.Count; $i++) {
                    if($i -eq $temp_arr.Length - 1){
                        if(CheckIsLastProperty($object_properties.Name)){
                            $temp_str += $temp_arr.GetValue($i)
                        } else {
                            $temp_str += $temp_arr.GetValue($i) + "; " 
                        }
                    } else {
                        $temp_str += $temp_arr[$i] + ", "
                    }  
                }
            } 
            $line += $object_properties.Name + ": " + $temp_str
        }  else {
            $line += $object_properties.Name + ": " + $object_properties.Value + "; "
        } 
    }
    return $line
}

function GetErrorRecordForLog {
    <#    
    .SYNOPSIS
    Formats text errors for logging to file
    
    .PARAMETER Main_Message
    This is the general message that describes the exception
    
    .PARAMETER Category_Err_Rec
    Describes category of error which was thrown
    
    .PARAMETER Invocation_Err_Rec
    This property contains additional information collected by 
    PowerShell about the function or script where the exception was thrown
    #>

    param (
        [string]$Main_Message,
        [System.Object]$Category_Err_Rec,
        [System.Object]$Invocation_Err_Rec
    )
    
    return (-join (
                "Exeption:",$Main_Message,"`n",
                "Category error:",$Category_Err_Rec.Category,"`n",
                "Path to script:",$Invocation_Err_Rec.PSCommandPath,"`n",
                "Name of invoked command:", $Invocation_Err_Rec.InvocationName,"`n",
                "Number of line:",$Invocation_Err_Rec.ScriptLineNumber,"`n",
                "Line:",$Invocation_Err_Rec.Line,"`n",
                "PositionMessage:",$Invocation_Err_Rec.PositionMessage,"`n"))   
}

function GetNetworkPreferForLog {
    <#
    .SYNOPSIS
    Formats text of message for logging about all current network setting 
    
    .DESCRIPTION
    If DHCP enabled, message will be contains full network info (IP,subnet,gateway,DNS),
    otherwise will be logged values of IP address and subnet mask.
    
    .PARAMETER Network_Prefer
    Storing all network information be like IP,DNS,etc
    
    .PARAMETER isDHCP
    Indicates if DHCP is enabled 
    #>

    param (
        [PSObject]$Network_Prefer,
        [boolean]$isDHCP
    )

    $Message = $null
    $str_set_pref = "Setting the following network parameters: "

    if($isDHCP -eq $true){
        $Message + (-join (
                    "DHCP enabled.",$str_set_pref,
                    "Local IP: ",$Network_Prefer.IP,', ',
                    "MASK: ",$Network_Prefer.MASK,', ',
                    "Gateway: ",$Network_Prefer.GATEWAY ,', ',
                    "DNS1: ",$Network_Prefer.DNS1,', ',
                    "DNS2: ",$Network_Prefer.DNS2))
    } else {
        $Message + (-join (
            "DHCP disabled.",$str_set_pref,
            "Local IP: ",$Network_Prefer.IP,', ',
            "MASK: ",$Network_Prefer.MASK))
    }

    return $Message
}

function PrintNetworkConfigToConsole {
    <#
    .SYNOPSIS
    Prints to terminal information about network setting of adapter
    
    .PARAMETER Status_Config
    Parameter which marked, if the network settings of the adapter have been changed.
    This variable can be have 2 values: "Current" or "Updated"
    
    .PARAMETER Network_Adapter
    Contains specific information about network adapter (name,ip,etc)
    #>

    param (
        [string]$Status_Config,
        [PSObject]$Network_Adapter
    )
           
    Write-Host "$Status_Config network configuration" ($Network_Adapter | Format-List  * | Out-String) -NoNewline  
}

Export-ModuleMember -Function CheckIsLastProperty, 
                            PrintNetworkConfigToConsole, 
                            GetErrorRecordForLog, 
                            GetNetworkConfForLog,
                            GetNetworkPreferForLog