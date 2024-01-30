function ParseFile {
    <#
    .SYNOPSIS
    Parsing file with network data of computers.
    
    .DESCRIPTION
    Parsing file which contains values of IP address,MAC,subnet mask,gateway network,primary/secondary dns and hostname 
    #>

    param (
        #Data file
        [string]$File
    )
        
    $Content_File = import-csv $File -delimiter "`t" 

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
    return $List_Obj_Network.ToArray()
}

Export-ModuleMember -Function ParseFile