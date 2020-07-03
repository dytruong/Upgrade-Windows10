1. Add multiple computernames (hostname) that you want to upgrade into source\computername.csv, you should put it into one column. 

2. Update your username and password to file updradew10-ver10.ps1 as below:
- Change the username and password in the HEADER and in the function upgradewindows
  + Username must to include @domainname (ex: a.nguyenvan@abc.com)  
- Change the hostname to your computername in the function upgradewindows
  + $hostname = yourcomputername or IP address (ex: comp1234)

3. Because of the uploading limit, I cannot upload file ISO windows into the folder source\. Thus, please download and copy-paste file ISO windows you want into the path directory here source\windows10.iso. (change name of ISO file to windows10.iso)

4. Run file RunasAdministrator.bat to begin upgrading. 
 
5. After everything goes smoothly. Run "checkupdate" function to check the version on each computer in CSV file.
 - Add # to the headline the name of the function at the end to disable it. For ex: #upgradewindows to skip this function when you run again. 

*Note:
 - "Powershell is not recognized as an internal or external command operable ..". Please add %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\ to the Path environment.
 - Windows will upgrade to the higher or equal version 1809
 - File ISO in the source is the windows 10 version 1909 (downloaded from Microsfoft page)
 - There are two options: 
      + /noreboot - it will not restart the computer client when installing done. (It enables default)
      + Without /noreboot option, the computer client will be force restart instantly after installing done. 
 - For more information, please refer the article here - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options

---------------------------------------------------------------------------------------
Please contact me: duytruongtran1997@gmail.com if you have any issues related.
