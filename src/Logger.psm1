#Full path to root folder of project
$Parent_Dir = ((Get-Item -Path $PSScriptRoot).Parent.FullName)
#Combines variable $Parent_Dir with child path of log file
$Path_logs = (Join-Path -Path $Parent_Dir -ChildPath 'logs\ip_setter.log')

function CreateLogDir {
    <#
    .DESCRIPTION
    Checking if exist log folder.If false,directory will be create.
    #>

    if(!(Test-Path $Path_logs)){
        New-Item -Path $Path_logs -ItemType File -Force | Out-Null
    }
}

function WriteLog {
    <#
    .SYNOPSIS
    Logging all events into file.
    #>

    Param(
        #Level of logging message. The level can be marked be like "INFO" or "ERROR"
        [string]$Level,
        #Contains text of event
        [string]$Message
    )

    $Time_stamp = (Get-Date).toString("[yyyy/MM/dd HH:mm:ss] ")
    $Res = $Time_stamp + $Level + ": " + $Message
    
    Add-Content $Path_logs -Value $Res
}

Export-ModuleMember -Function WriteLog, CreateLogDir