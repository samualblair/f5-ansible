# Primary Use

This mass as3 declaration powershell script can be used to quickly declare many AS3 files to an F5 BIG-IP.
The primary purpose of this script is to easily deploy many declarations one time, from a system with powershell.
More specifically essentially any windows device, without additional software.
This can also be used on other systems if they have PowerShell installed, for example MacOS and Linux.

NOTE: Up to 10 second delay will occur to allow declaration to process, after that id sand status will simply be displayed

# Run Example

* Example below is a run of the script on a MacOS system that has PowerShell installed.
* In the below example run the script is located at "/Users/user1/mass_as3_declarations/mass_as3_deployment.ps1"
* There is a folder with AS3 declarations lcoated at "/Users/user1/AS3/"
* This folder has two sub folders, each with files "dmz-apps" and "internal-apps"
* To reference those folders, and recursivly find files in each the following path was used in the prompt "../AS3/"


```pwsh
PS /Users/user1/mass_as3_declarations> pwsh ./mass_as3_deployment.ps1
Base Folder for Recursive AS3 Deployment for example - Must be Folder ending in '\' or '/' : '../AS3_Files/' or 'C:\AS3_files\'
NOTE: Must be Folder Path ending in '\' or '/' such as: '../AS3_Files/' or 'C:\AS3_files\'
Enter Base Folder: ../AS3/
Enter F5 Hostname or IP Address: bigip1.example.com
Enter F5 User Name (e.g. admin): admin
Enter F5 Password: *********
Login Process Finished


AS3 Service Status:
{
  "version": "3.57.0",
  "release": "13",
  "schemaCurrent": "3.57.0",
  "schemaMinimum": "3.0.0"
}


Found the following AS3 Files:
../AS3/dmz-apps/dmz-app1.as3.json
../AS3/internal-apps/internal-app1.as3.json
../AS3/internal-apps/internal-app2.as3.json
../AS3/internal-apps/internal-app3.as3.json


"18d4a064-e5d8-4dc2-82ad-89b2232b9d45"
{
  "code": 200,
  "message": "success",
  "lineCount": 36,
  "host": "localhost",
  "tenant": "t_dmz-app1",
  "runTime": 1089,
  "declarationId": "urn:uuid:f3d1cf02-06b4-4f53-84b3-215a27504624"
}


"93e4e858-9ac5-4c17-a257-fe27b9463beb"
{
  "code": 200,
  "message": "success",
  "lineCount": 27,
  "host": "localhost",
  "tenant": "t_internal-app1",
  "runTime": 990,
  "declarationId": "urn:uuid:3b263335-2f81-4931-a0e9-e802a569176a"
}


"2b9d41b9-9e0e-494d-a1b5-7112677bc6be"
{
  "code": 200,
  "message": "success",
  "lineCount": 26,
  "host": "localhost",
  "tenant": "t_internal-app2",
  "runTime": 974,
  "declarationId": "urn:uuid:38eaf189-facc-4ef8-ac36-7bce89ad201d"
}


"27bf2e41-6d4e-4ae6-8b53-28a210d3d691"
{
  "code": 200,
  "message": "success",
  "lineCount": 27,
  "host": "localhost",
  "tenant": "t_internal-app3",
  "runTime": 977,
  "declarationId": "urn:uuid:d38ddff4-92ae-4cea-be90-52215df43912"
}


List of all Declaration Job IDs:
"18d4a064-e5d8-4dc2-82ad-89b2232b9d45"
"93e4e858-9ac5-4c17-a257-fe27b9463beb"
"2b9d41b9-9e0e-494d-a1b5-7112677bc6be"
"27bf2e41-6d4e-4ae6-8b53-28a210d3d691"


PS /Users/user1/mass_as3_declarations>
```