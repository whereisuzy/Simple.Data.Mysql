include ".\wget.ps1"

Properties {
    $BuildDirectory = Split-Path $psake.build_script_file
    $ToolsDirectory = "$BuildDirectory\..\Tools"
    $MysqlDirectory = "$ToolsDirectory\Mysql"
    $Mysql40Directory = "$MysqlDirectory\4.0"
    $Mysql40DirectoryName = (resolve-path $Mysql40Directory).Path
    $Mysql40Executable = "`"$Mysql40DirectoryName\bin\mysqld-nt.exe`""
    $Mysql55Directory = "$MysqlDirectory\5.5"
    $Mysql55DirectoryName = (resolve-path $Mysql55Directory).Path
    $Mysql55Executable = "`"$Mysql55DirectoryName\bin\mysqld.exe`""
}

FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

function UnzipFiles($zipfile, $targetDir) {
    $shell = new-object -com shell.application
    $zipFileObject = $shell.namespace($zipfile)
    $targetDirObject = $shell.namespace($targetDir)
    $targetDirObject.CopyHere($zipFileObject.items())
}

Task Default -Depends start_mysql_55

Task Start_mysql_40 -depends Make_sure_Mysql40_is_available {
   Start-Process -FilePath $Mysql40Executable "--no-defaults --basedir=`"$Mysql40DirectoryName`" --standalone"
}

Task Stop_mysql_40 {
   Stop-Process -Name "mysqld-nt"
}

Task Start_mysql_55 -depends Make_sure_Mysql55_is_available {
    Start-Process -FilePath $Mysql55Executable "--no-defaults --basedir=`"$Mysql55DirectoryName`" --standalone"    
}

Task Stop_mysql55 {
    Stop-Process -Name "mysqld"
}

Task Make_sure_Mysql40_is_available -depends Make_sure_Mysql_directory_is_created {
    if(!(Test-Path $Mysql40Directory)) {
        if (!(Test-Path "$BuildDirectory\MySql4.0.zip")) {
            Get-WebFile "https://github.com/downloads/Vidarls/Simple.Data.Mysql/MySql4.0.zip"
        }
        
        $targetDir = Resolve-Path $MysqlDirectory
        UnzipFiles (Dir "$BuildDirectory\MySql4.0.zip").FullName $targetDir.Path
    }  
}

Task Make_sure_Mysql55_is_available -depends Make_sure_Mysql_directory_is_created {
    if(!(Test-Path $Mysql55Directory)) {
        if (!(Test-Path "$BuildDirectory\MySql5.5.zip")) {
            Get-WebFile "https://github.com/downloads/Vidarls/Simple.Data.Mysql/MySql5.5.zip"
        }
        
        $targetDir = Resolve-Path $MysqlDirectory
        UnzipFiles (Dir "$BuildDirectory\MySql5.5.zip").FullName $targetDir.Path
    }  
}

Task Make_sure_tools_directory_is_created {
    if (!(Test-Path $ToolsDirectory)) {
        mkdir $ToolsDirectory
    }
}

Task Make_sure_Mysql_directory_is_created -Depends Make_sure_tools_directory_is_created{
    if (!(Test-Path $MysqlDirectory)) {
        mkdir $MysqlDirectory
    }
}

