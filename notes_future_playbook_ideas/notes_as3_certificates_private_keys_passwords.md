# AS3 - Certificates and Private Keys, and Passwords

## BIG-IQ Importing of a Cert and Protected Key
Cert and Private Key
Private Key is 'password protected'
- when importing you set password to decrypt (what was originally on the cert)
- In BIG-IQ field 'PKCS12 Password' is the existing password that is used decrypt
- In BIG-IQ field 'Key Password' will be new key password (can be same or different, your choice) , useful to use a common one (for easy remember when configuring BIG-IP)

## BIG-IQ Pushing of Cert and Key to BIG-IP
You must create a reason to push - either with dependency pin or static pin).
When creating VS and other config in BIG-IQ, you can just edit a profile with cert (that is attached to a virtual server, creating a dependency pin)
When managing config outside of BIG-IQ, such as with AS3 direct to BIG-IP, easier to just statically pin the cert (can use a BIG-IQ pinning policy to pin cert and key).
When ready push down the cert and key with a deployment task.

## Using Cert and Protected Key in a profile on BIG-IP in GUI
In GUI of BIG-IP, and a certificate profile can be created (client ssl, server ssl, or other) and when selecting certificate you are prompted for passphrase.

## Using Cert and Protected Key in a profile on BIG-IP in AS3

Unprotected key - does not require any passphrase notation.
```
"certificate": {"bigip":"/Common/default.crt"},
"privateKey": {"bigip":"/Common/default.key"}
```

PKCS12 file with no encryption value (technically it will be an empty encryption - unlikely).
You can choose to ignore the changes as empty encryption will be rewritten encrypted each time it is created triggering a 'changed' status instead of 'no change' status otherwise.
```
# Decodes to ciphertext " "
# Decodes to Protected "{"alg":"dir","enc":"none"}"
"passphrase": {
    "ciphertext": "IA==",
    "protected": "eyJhbGciOiJkaXIiLCJlbmMiOiJub25lIn0",
    "ignoreChanges": true
},
```

```
# If importing a pkcs12 file with pkcs8 option, it saves the private key in PEM format
pkcs12Options: { keyImportFormat: "pkcs8" }
# Default is openssl-legacy format
pkcs12Options: { keyImportFormat: "openssl-legacy" }
```

A password protected pkcs12 file import, or private key PEM import, with plain text password.
Password protected private key can also be imported in this way.
```
# Decodes to ciphertext "password"
# Decodes to Protected "{"alg":"dir","enc":"none"}"
"passphrase": {
    "ciphertext": "cGFzc3dvcmQ=",
    "protected": "eyJhbGciOiJkaXIiLCJlbmMiOiJub25lIn0",
    "ignoreChanges": true
},
```

A password protected key or pkcs12 bundle , can be submitted with an encrypted key using miniJWE, and can be encrypted using F5 pre-existing master key (decodes to $M encrypted value - same as showing in CLI). Useful workaround for including or saving encrypted values but relies on knowing the F5 pre-existing master key value (or pre-existing master key encrypted password value).
```
# Decodes to ciphertext "$ManExamplePassword" , notice the $M in start
# Decodes to Protected "{"alg":"dir","enc":"f5sv"}" , notice the enc value of "f5sv"
"passphrase": {
    "ciphertext": "JE1hbkV4YW1wbGVQYXNzd29yZA==",
    "protected": "eyJhbGciOiJkaXIiLCJlbmMiOiJmNXN2In0=",
    "miniJWE": true
}
```

# Working with master passphrases

## TMSH
```
show sys crypto master-key
# If the hash is different then a different master key is in use (shows a sha256 hash)
modify sys crypto master-key prompt-for-password
# Can prompt here
```

## BASH
```bash
# In bash can view current key with 
f5mku -K
# Will output something like cGFzc2FiYw== which is a base64 of the key (not a hash)

# In bash can change current key with
f5mku -r cGFzc2FiYw==
# This changes the value to cGFzc2FiYw==
```

## Documentation
[F5 Docs for Master-Key Sync](https://techdocs.f5.com/en-us/bigip-13-1-0/big-ip-secure-vault-administration/high-availability-considerations/dsc-ha-same-master-key-techniques.html)


