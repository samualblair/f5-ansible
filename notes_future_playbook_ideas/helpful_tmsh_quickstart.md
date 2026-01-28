# Most basic management IP setup via CLI

## Option 1 use 'setup' command/script
```bash
# From Bash
config
# Will be prompted for management IP , subnet , dhcp or not, etc.
```

## Option 2 run TMSH commands
```bash
# First check if current DHCP IP and/or Mangement Route are present and will need to be replaced
tmsh list sys global-settings mgmt-dhcp
tmsh list sys management-ip
tmsh list sys management-route

# Will need to disable dhcp to set static IP
tmsh modify sys global-settings mgmt-dhcp disabled

# Not remove (delete addresses and routes based on names seen before - examples below are '10.1.1.1/24' and 'default' could be different
tmsh delete sys management-ip 10.1.1.1/24
tmsh delete sys management-route default

# Create new up and default route
tmsh create sys management-ip 192.168.1.10/24
tmsh create sys management-route default gateway 192.168.1.1 network default

# May want to disable gui setup - if so
tmsh modify sys global-settings gui-setup disabled

# Should be able to test connectivity now and/or remotely connect if mgmt network is online
# After testing, or when ready, good idea to save
tmsh save sys config
```

# Additional TMSH interface configuration example
Additional example commands for basic interface configuration with TMSH
This is a data plane interface but can also used for some management
```bash
# Define vlan - example shown is defined as vlan 4 but is assigned to interface 1.1 untagged
tmsh create net vlan VLAN4 { interfaces add { 1.1 { } } tag 4 }
# Define Self-IP with traffic-group-local-only , so non-floating self ip
tmsh create net self VLAN4_SELF { address 172.16.4.4/24 allow-service replace-all-with { default } traffic-group traffic-group-local-only vlan VLAN4 }
# Define Network Route (default gateway for tmm data plane, default route domain 0, not management routing table)
tmsh create net route VLAN4_ROUTE { gw 172.16.4.1 network default }

# Optional - Can Define a DNS server as well - otherwise auto licensing for example will not work
tmsh modify sys dns name-server add { 1.1.1.1 8.8.8.8 }
```

# Management TLS and SSH Lockdown with TMSH

Implementing SSH Lockdown in CLI with TMSH

Reference [F5 Article K02321234](https://my.f5.com/manage/s/article/K02321234)
```bash
tmsh modify sys httpd ssl-protocol "ALL -TLSv1.1 -TLSv1 -SSLv2 -SSLv3"
tmsh modify sys httpd ssl-ciphersuite "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384"
# Alternativly could match expected cert
# RSA Cert Key
# tmsh modify sys httpd ssl-ciphersuite "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384"
# ECDSA Cert Key
# tmsh modify sys httpd ssl-ciphersuite "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384"
tmsh modify sys httpd auth-pam-idle-timeout 900

# To add gui-banner use global-settings, and set gui-security-banner-text
# Also note, Note: To enter a carriage return in the text type Ctrl-V followed by Ctrl-J. 
# Additionally, you must escape special characters, such as a question mark(?), with a back slash.

tmsh modify sys sshd banner enabled
# When using this method must be 1 line
tmsh modify sys sshd banner-text "****THIS SYSTEM IS PROVIDED FOR USE BY AUTHORIZED USERS ONLY.  UNAUTHORIZED USE PROHIBITED. VIOLATORS WILL BE PROSECUTED.****"
tmsh modify sys sshd auth-pam-idle-timeout 900

# Can also add post-login banner that is multi-line by creating a file with multi-line banner, and then include in sshd config - see cipher includes
# Example would be, add data to file '/config/ssh/ssh_banner' then add:
# tmsh modify /sys sshd include "Banner /config/ssh/ssh_banner"
# Alternatively just enable post-login motd banner by adding data to file: /etc/motd
# nano /etc/motd

# Reference https://my.f5.com/manage/s/article/K80425458
# Still pretty secure, allow for slightly weaker keys which seem to be default on many f5s so easier to say ssh from one F5 to another with this (keeps ecdh-sha2-nistp256)

tmsh modify sys sshd include  "
Ciphers chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512
Protocol 2
"

# Or alternatively, slightly more secure but requires new keys to be generate on most F5s, otherwise scripts like bigip_add don't want to work. This is my default go to personally.

tmsh modify sys sshd include  "
Ciphers chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp384,ecdh-sha2-nistp521
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512
Protocol 2
"

tmsh modify sys sshd protocol 2
tmsh modify sys sshd allow { 10.0.0.0/8 }
```


# HTTP Lockdown with DO
Strong HTTP Segment , at time of writing note this cannot yet support or lock down to http 1.3
```json
"HTTPD": {
            "class": "HTTPD",
            "allow": [
                "10.0.0.0/8",
                "172.16.0.0/12",
                "192.168.0.0/16"
            ],
            "authPamIdleTimeout": 900,
            "sslProtocol": "TLSv1.2",
            "sslCiphersuite": [
                "ECDHE-RSA-AES128-GCM-SHA256",
                "ECDHE-RSA-AES256-GCM-SHA384",
                "ECDHE-ECDSA-AES128-GCM-SHA256",
                "ECDHE-ECDSA-AES256-GCM-SHA384"
            ]
        }
```

# SSH Lockdown with DO
Stronger DO Segment, but has issues with default generated f5 private keys
```json
"SSHD": {
            "class": "SSHD",
            "inactivityTimeout": 900,
            "ciphers": [
                "chacha20-poly1305@openssh.com",
                "aes128-gcm@openssh.com",
                "aes256-gcm@openssh.com",
                "aes128-ctr",
                "aes192-ctr",
                "aes256-ctr"
            ],
            "MACS": [
                "hmac-sha2-256-etm@openssh.com",
                "hmac-sha2-512-etm@openssh.com",
                "umac-128-etm@openssh.com",
                "hmac-sha2-512"
            ],
            "kexAlgorithms": [
                "curve25519-sha256",
                "curve25519-sha256@libssh.org",
                "diffie-hellman-group14-sha256",
                "diffie-hellman-group16-sha512",
                "diffie-hellman-group18-sha512",
                "ecdh-sha2-nistp521"
            ],
            "protocol": 2,
            "allow": [
                "10.0.0.0/8"
            ]
        }
```

Alternatively weaker DO , but works with default keys on F5.

This specifically benefits scripts like 'bigip_add' work right away (no need to generate new keys) with he downside of lowering security slightly to accommodate the weaker keys already present.
```json
"SSHD": {
            "class": "SSHD",
            "inactivityTimeout": 900,
            "ciphers": [
                "chacha20-poly1305@openssh.com",
                "aes128-gcm@openssh.com",
                "aes256-gcm@openssh.com",
                "aes128-ctr",
                "aes192-ctr",
                "aes256-ctr"
            ],
            "MACS": [
                "hmac-sha2-512-etm@openssh.com",
                "hmac-sha2-256-etm@openssh.com",
                "umac-128-etm@openssh.com",
                "hmac-sha2-512"
            ],
            "kexAlgorithms": [
                "curve25519-sha256",
                "curve25519-sha256@libssh.org",
                "diffie-hellman-group14-sha256",
                "diffie-hellman-group16-sha512",
                "diffie-hellman-group18-sha512",
                "ecdh-sha2-nistp256",
                "ecdh-sha2-nistp384",
                "ecdh-sha2-nistp521"
            ],
            "protocol": 2,
            "allow": [
                "10.0.0.0/8"
            ]
        }
```
