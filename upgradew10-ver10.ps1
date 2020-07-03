Write-Warning "Please make sure you have followed exactly the README file!"
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path;
$computer = Import-csv -Path "${ScriptDir}\source\computername.csv" -Header computername
#Get credential
$password = "yourpassword" | ConvertTo-SecureString -asPlainText -Force;            #update your password domain admin
$username = "domainadmin@abc.com"                                               #update your domain admin account
$cred = New-object System.Management.Automation.PSCredential($username,$password)
#create the ISO file and share automatically
function mountISO{
    param(
        [string]$imagepath 
    );
    $iso = $imagepath;
    $getdriveletter = (Get-Volume | Where-Object {$_.DriveType -eq "CD-ROM"} | Where-Object {$_.OperationalStatus -eq "OK"}).DriveLetter;
    $number = $getdriveletter.Length;
    #remove ISO remaining
    if ($number -gt 0){
        for ($i=0;$i -le $number;$i++){
            Dismount-DiskImage -DevicePath \\.\CDROM$i -ErrorAction SilentlyContinue;
        }
    }
    Mount-DiskImage -ImagePath $iso -ErrorAction SilentlyContinue;
    $getdriveletter2 = (Get-Volume | Where-Object {$_.DriveType -eq "CD-ROM"} | Where-Object {$_.OperationalStatus -eq "OK"}).DriveLetter;
    $checksharefolder = Test-Path "C:\upgrade"
    if ($checksharefolder -eq "True"){
        Remove-Item -Path "C:\upgrade" -Force -Recurse -ErrorAction SilentlyContinue;
    }      
    Copy-Item -Force -Recurse -Verbose -Path "${getdriveletter2}:\" -Destination "C:\upgrade\wd1903\";
    #compare two files
    $fileoriginal = Get-ChildItem -Recurse -Path "${getdriveletter2}:\";
    $fileoriginalcount = $fileoriginal.count;
    $filepasted = Get-ChildItem -Recurse "C:\upgrade\wd1903";
    $filepastedcount = $filepasted.count;
    if ("$fileoriginalcount" -eq "$filepastedcount")
    {
        new-smbshare -Name "upgrade" -Path "C:\upgrade" -FullAccess "everyone" -ErrorAction SilentlyContinue;
        Dismount-DiskImage -ImagePath $iso -ErrorAction SilentlyContinue;
        Write-Host "Shared folder has been created successfully!" -ForegroundColor green;
        Write-Host "--------------------------------";

    }else {
        Write-Host "Copy process has been corrupted! Please re-run ..." -ForegroundColor Red;
        exit;   
    }
}
#copy and install windows update
function upgradewindows {
    foreach ($pc in $computer)
{
    $testcn = Test-Connection -ComputerName $pc.computername -Quiet
    if ($testcn -eq "True"){   
        Invoke-Command -ComputerName $pc.computername -Credential $cred -ScriptBlock {
            #create the credential variable
            $password = "yourpassword" | ConvertTo-SecureString -asPlainText -Force;    #update your password
            $username = "domainadmin@abc.com"                                           #update your domain admin account
            $cred = New-object System.Management.Automation.PSCredential($username,$password)
            $hostname = "saiwks1919";                                                   #update your computer name
            $ho = HOSTNAME.EXE;
            #Turn of hibernate
            powercfg -h off;
            Powercfg /Change standby-timeout-ac 0;
            #Map network drive to remote computer
            New-PSDrive -Name "L" -PSProvider FileSystem -Root \\$hostname\upgrade -Persist -Credential $cred;
            #check windows version
            $getwdversion = (Get-ComputerInfo).WindowsVersion
            if ("$getwdversion" -gt 1809){                              #change windows version
                write-host "$ho has windows version $getwdversion. There is no need to upgrade. EXIT now :D" -ForegroundColor Green;
                write-host "---------------------------------------------------------------------------";
                exit;
            }else{
                #check free space
                $checkfreespace = ((get-psdrive C).free/1Gb);
                if ("$checkfreespace" -gt 10){
                    Get-PSDrive C;
                    Write-Host "The update is processing on $ho. Please wait ...";
                    #checkssdorHDD to alert
                    $checkSSD = (Get-PhysicalDisk).MediaType
                    If ($checkSSD -eq "SSD"){
                    Write-Host "windows is using SSD. The process will be done soon :D " -ForegroundColor Green;
                    }else {
                    Write-Warning "windows is using HDD. The updating process will be done in the long time (ETA: 1 hour)" -ForegroundColor Red;
                    }
                    #Get-PSDrive -Name "L";
                    Write-Host "Folder wd1903 is copying to remote computer...";
                    Copy-Item -Path L:\wd1903 -Destination C:\ -Recurse -ErrorAction SilentlyContinue;
                    #copy paste done, remove PSdrive
                    $getdate = get-date -Format HH:mm:ss;
                    Write-Host "File has been copied done! windows is updating ... from $getdate";
                    #check windows version
                    $checkpath = Test-Path C:\wd1903;
                    if ($checkpath -eq "True")
                        {
                            $source = "C:\wd1903\setup.exe /auto upgrade /noreboot /migratedrivers all /copylogs \\$hostname\upgrade\log /quiet"; #remove /noreboot if you want to user's computer force reboot after installing done.
                            & cmd.exe /c $source;
                            $getdate2 = get-date -Format HH:mm:ss;
                            Write-Host "The updating process complete at $getdate2 ... It will be done in 30 minutes after restarting.";
                            write-host "---------------------------------------------------------------------" -ForegroundColor Blue;            
                        }
                        else {
                            write-host "Update folder haven't esixted or changed name on $pc.computername! trying to run again!"
                            Write-Host "File wd1903 is trying to copying again ..."
                            Copy-Item -Path L:\wd1903 -Destination C:\ -Recurse -ErrorAction SilentlyContinue;
                            $source = "C:\wd1903\setup.exe /auto upgrade /noreboot /migratedrivers all /copylogs \\$hostname\upgrade\log /quiet";
                            & cmd.exe /c $source;
                            Write-Host "The computer is restarting to complete the installation ... It will be done in 30 minutes.";
                            write-host "---------------------------------------------------------------------" -ForegroundColor Blue;
                        }

                }else{
                    Write-Warning "Free space is less than 10Gb! The updating process on $ho has been stopped right now" 
                    Start-Sleep -Seconds 3;
                    Write-Host "The update has stopped. Please take a little time to do clean particion C and try again!";
                    Write-Host "----------------------------------------------------------------------------------------";
                    exit;   
                }
    }
        #remove PSdrive
        Remove-PSdrive L; 
}
    }
    else {
        Write-Host "$pc is offline." -ForegroundColor Red;
    }
}
}
function checkupdate {
    foreach ($pcs in $computer){
        $testconnection = Test-Connection -ComputerName $pcs.computername -Quiet
        if ($testconnection -eq "True"){
            Invoke-Command -ComputerName $pcs.computername -Credential $cred -ScriptBlock {
                #check windows version
                $getwdversion = (Get-ComputerInfo).WindowsVersion;
                $hot = HOSTNAME.EXE;
                if ("$getwdversion" -gt 1809){
                    Write-Host "Windows update SUCCESSFULLY! on $hot"
                    Get-ComputerInfo | Select-Object WindowsVersion, CsName, CsUserName;
                }else{
                    write-host "Windows update FAILED on $hot" -ForegroundColor Red;
                    Get-ComputerInfo | Select-Object WindowsVersion, CsName;
                    $checkfreespace = ((get-psdrive C).free/1Gb);
                    #rounding a number
                    $number = [math]::Truncate($checkfreespace);
                    $comparevalue = ($number -gt 10);
                    if ("$comparevalue" -eq "True"){
                            $checkarchitecture = (Get-WmiObject win32_operatingsystem).osarchitecture;
                            if ("$checkarchitecture" -eq "64-bit"){
                                write-host "Reason: There is no reason detected!" -ForegroundColor Gray;
                            }else{
                                Write-Host "Reason: Windows is using the 32Bit version! upgrade to 64bit to go on!" -ForegroundColor Blue;
                            }   
                        Write-Host "Free space still remains: ${number} Gb" -ForegroundColor Green;
                        }
                    else{
                        write-host "Reason: There is not enough free space to upgrade! " -ForegroundColor Red;
                        Write-Host "Free space is ${number}" -ForegroundColor red;;  
                        }
                    }
                #remove file windows update
                $checkwd1903 = Test-Path -Path C:\wd1903;
                if ($checkwd1903 -eq "True"){
                    Remove-Item -Path C:\wd1903 -Force -Recurse;
                    Write-Host "File wd1903 has been deleted successfully!" -ForegroundColor Green;
                }
                else{
                    Write-Host "File wd1903 no longer exists" -ForegroundColor Green;
                }
            }
        }
        else {
            Write-Host "$pcs.computername is offline" -ForegroundColor Red;
        } 
    }
}

mountISO -imagepath "$ScriptDir\source\windows10.iso";
upgradewindows;



