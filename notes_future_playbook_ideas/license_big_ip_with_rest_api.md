# License BIG-IP with REST API
https://my.f5.com/manage/s/article/K45305307

## Workflow Example 1 - Uploading the license file first, then licensing
```bash
## Upload license.
## Place license in file the local directory (same as this script location), with the file name of license_file_data
cat ./license_file_data | sed s'/"//'g > ./license_file_data_cleaned
LICENSE=$(< ./license_file_data_cleaned)
curl -v -k -u admin:<password> -X PUT -H "Content-type:application/json" https://<ip address>/mgmt/tm/shared/licensing/registration --data-binary "{\"licenseText\":\"$LICENSE\"}"
```

## Workflow Example 2 - With embedded license - more difficult
Important: The license text contains quotation marks (") that must be removed or the REST command fails. 
```bash
# One way to resolve this is save the license to a file on your local device, and you can use the following Linux command syntax to strip the quotation marks from the license file:
cat ./<you license file name> | sed s'/"//'g 

# For Example - download then run:
cat ./f5_lab_license.txt | sed s'/"//'g > f5_lab_license_restready.txt

# Now use new file in REST Post:
f5_lab_license_restready.txt
```
