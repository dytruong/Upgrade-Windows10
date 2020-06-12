$computer = Import-csv -Path "D:\Canhan\Upgrade windows 10\computername.csv" -Header computername
#$credential = Get-Credential -Credential "yourdomainadmin"
Write-Warning "Please make sure you have followed exactly the guideline!"
#Get credential
$password = "yourpassword" | ConvertTo-SecureString -asPlainText -Force;
$username = "yourdomainadmin"
$cred = New-object System.Management.Automation.PSCredential($username,$password)

foreach ($pc in $computer)
{ 
    $testcn = Test-Connection -ComputerName $pc.computername -Quiet
    if ($testcn -eq "True"){   
        Invoke-Command -ComputerName $pc.computername -Credential $cred -ScriptBlock {
            #create the credential variable
            $password = "yourpassword" | ConvertTo-SecureString -asPlainText -Force;
            $username = "yourdomainadmin"
            $cred = New-object System.Management.Automation.PSCredential($username,$password)
            #Turn of hibernate
            powercfg -h off;
            Powercfg /Change standby-timeout-ac 0;
            #check free space
            Get-PSDrive C
            Write-Warning "if free space is less than 5Gb, Please STOP it! Ctrl + C to stop.."
            Start-Sleep -Seconds 5;
            Write-Host "The update is processing ...";   
            #Map network drive to remote computer
            New-PSDrive -Name "L" -PSProvider FileSystem -Root \\saiwks1919\upgrade -Persist -Credential $cred;
            #Get-PSDrive -Name "L";
            Write-Host "Folder wd1903 is copying to remote computer...";
            Copy-Item -Path L:\wd1903 -Destination C:\ -Recurse -ErrorAction SilentlyContinue;
            #copy paste done, remove PSdrive
            Remove-PSdrive L;
            $getdate = get-date -Format HH:mm:ss;
            Write-Host "File has been copied done! windows is updating ... from $getdate"; 
            #start L:\wd1903\setup.exe
            #install update after copy paste completely
            $checkpath = Test-Path C:\wd1903;
            if ($checkpath -eq "True")
            {
                $source = "C:\wd1903\setup.exe /auto upgrade /noreboot /migratedrivers all /copylogs \\saiwks1919\upgrade\log /quiet";
                & cmd.exe /c $source;
                Write-Host "The computer is restarting to complete the installation... It will done in 30 minutes.";                 
            }
            else {
                write-host "Update folder haven't esixted or changed name on $pc.computername! trying to run again!"
                Write-Host "File wd1903 is trying to copying again ..."
                New-PSDrive -Name "X" -PSProvider FileSystem -Root \\saiwks1919\upgrade -Persist -Credential $cred;
                Get-PSDrive -Name "X";
                Copy-Item -Path X:\wd1903 -Destination C:\ -Recurse -ErrorAction SilentlyContinue;
                #copy paste done, remove PSdrive
                Remove-PSdrive X;
                $source = "C:\wd1903\setup.exe /auto upgrade /noreboot /migratedrivers all /copylogs \\saiwks1919\upgrade\log /quiet";
                & cmd.exe /c $source;
                Write-Host "The computer is restarting to complete the installation ... It will done in 30 minutes."; 
            }
        }
    } 
    else {
        Write-Host "$pc is offline." -ForegroundColor Red;
    }
}

