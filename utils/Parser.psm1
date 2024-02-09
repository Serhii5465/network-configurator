function ParseFile {
    <#
    .SYNOPSIS
    Parsing file with network data of computers.
    
    .DESCRIPTION
    Parsing file which contains values of IP address,MAC,subnet mask,gateway network,primary/secondary dns and hostname 
    #>
    
    try {
        $Content_File = Import-Csv -Path ((Get-Item -Path $PSScriptRoot).Parent.FullName + '\' + "net_preset.dat") -delimiter "`t" 
    }
    catch {
        WriteLog "ERROR" (GetErrorRecordForLog $PSItem.Exception.Message $PSItem.CategoryInfo $PSItem.InvocationInfo)
        throw $PSItem
    }

    #Getting all network adapters which supports TCP/IP on current local machine. 
    $List_Net_Adap = GetAdapterList 
    
    [System.Collections.ArrayList]$List_Obj_Network = @()

    :outer 
    foreach($i in $List_Net_Adap){
       foreach($j in $Content_File){
           if($i.MACAddress -eq $j.MAC){
                [void]$List_Obj_Network.Add($i) # Information about current network adapter
                [void]$List_Obj_Network.Add($j) # Network preferences which will be installed
                break outer # if true,break outer loop
           }
       }
    }

    if($List_Obj_Network.Count -eq 0){
        WriteLog "ERROR" "No matching MAC addresses were found"
        throw [System.NullReferenceException] "No matching MAC addresses were found"
    } else {
        return $List_Obj_Network.ToArray()
    }
}

Export-ModuleMember -Function ParseFile