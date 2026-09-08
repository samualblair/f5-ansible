<!-- Please open a case (https://support.f5.com/csp/article/K2633) with F5 if this is a critical issue. -->

### Environment
 * Application Services Version: 3.52
 * BIG-IP Version: 17.1.3

### Summary
After troubleshooting a certificate not loading (certificate already on device, but ssl profile unable to be declared), identified problem as a special character in the password, likely a '$' in the middle of password.

As a temporary workaround attempted to URL encode, did not change behavior.
As a temporary workaround attempted to escape with added '\', also did not change behavior.

As a temporary workaround was able to encode with master key (use encrypted form which string has a $M yet works fine). This is a well documented workaround, abut not explain why or how to otherwise deal with problematic characters (or what characters are problematic).

### Steps To Reproduce
Steps to reproduce the behavior:
1. Submit the following declaration:
```json
{
    "class": "ADC",
    "schemaVersion": "3.52.0",
    "id": "test",
    "test": {
        "class": "Tenant",
        "Shared": {
            "class": "Application",
            "template": "shared",
            "cert": {
                "class": "Certificate",
                "passphrase": {
                    "ciphertext": "YW5FeGFtcGxlUGFzJHdvcmQ=",
                    "protected": "eyJhbGciOiJkaXIiLCJlbmMiOiJub25lIn0"
                }
            }
        }
    }
}
```

2. Observe the following error response:
```text

```


3. Alternative - workaround when obscuring same password in master key based encryption:
```json
{
    "class": "ADC",
    "schemaVersion": "3.52.0",
    "id": "test",
    "test": {
        "class": "Tenant",
        "Shared": {
            "class": "Application",
            "template": "shared",
            "cert": {
                "class": "Certificate",
                "passphrase": {
                    "ciphertext": "JE1hbkV4YW1wbGVQYXNzd29yZA==",
                    "protected": "eyJhbGciOiJkaXIiLCJlbmMiOiJmNXN2In0="
                }
            }
        }
    }
}
```

4. Observe the following Success:
```text

```


### Expected Behavior
Expect plain encoding password to work. If there are special characters that need to be escaped or otherwise dealt with this should be documented. URL encoding did not work, and no clear documentation was found regarding what characters are potentially a problem.

An article like this (or maybe this article) for a reference would be a start:
https://my.f5.com/manage/s/article/K2873

But additional documentation in AS3 should be provided in how to deal with the above, as URL encoding and normal escaping (adding \ before $ to try and escape) did not work as expected.

Or, is there potentially a bug in AS3 that needs to be patched to prevent unintended processing of variables/characters passed in a plain password (still passed over JSON encoded in BASE64, or URL-Encoding+BASE64).

### Actual Behavior
Plain password fails, but Master Key encoded password succeeds, when a $ is present in the password.

