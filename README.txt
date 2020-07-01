1. Add the computername that you want to upgrade into source\computername.csv, you should put it into one column. 

2. Update your username and password to file updradew10-ver10.ps1 as below:
- Change the username and password in the HEADER and in the function upgradewindows
  + Username must to include @domainname (ex: a.nguyenvan@abc.com)  
- Change the hostname to your computername in the function upgradewindows
  + $hostname = yourcomputername or IP address (ex: comp1234)

3. If you want to change the ISO file, please copy your file ISO you want, to the source folder and replace with the same name. (windows10.iso)

4. Run file RunasAdministrator.bat to upgrade.

*Note:
 - "Powershell is not recognized as an internal or external command operable ..". Please add %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\ to the Path enviroment.
 - Windows will upgrade to the higher or equal versio 1809
 - File ISO in source is the windows 10 version 1909. 
5. After everything goes smoothly. Run "checkupdate" function to check the new version.

---------------------------------------------------------------------------------------
Please contact me: tranduytruong0311@gmail.com if you have any issues related.
