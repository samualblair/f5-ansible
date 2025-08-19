
# HSTS AS3 Configuration Examples

* With HSTS you want to be very carful with enforcing, how long, scope (domains and subdomains), as well as pre-load or not.
* HSTS is set and enforced by inserting the HTTP Header "Strict-Transport-Security" header
* HSTS is important to help ensure secure web traffic, it tells the browser to use HTTPS (TLS) only not plaintext HTTP.
* Preload ensures this is set when the browser opens, before even connecting the first time.
* When HSTS is enabled it prevents you from bypassing security errors (the normal 'ok, click I understand to continue').
* For security a client own't accept changes to policy until the period is done, but that also means breakage could last until the period is done.

``` JSON
                "http_profile_hsts_base_30min_nosubdomains": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 1800,
                    "hstsIncludeSubdomains": false,
                    "hstsPreload": false
                },
                "http_profile_hsts_base_30min_subdomains": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 1800,
                    "hstsIncludeSubdomains": true,
                    "hstsPreload": false
                },
                "http_profile_hsts_base_30min_preload": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 1800,
                    "hstsIncludeSubdomains": true,
                    "hstsPreload": true
                },
                "http_profile_hsts_base_4hours": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 14400,
                    "hstsIncludeSubdomains": true,
                    "hstsPreload": false
                },
                "http_profile_hsts_base_91days": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 7862400,
                    "hstsIncludeSubdomains": true,
                    "hstsPreload": true
                },
                "http_profile_hsts_base_5yr": {
                    "class": "HTTP_Profile",
                    "hstsInsert": true,
                    "hstsPeriod": 157680000,
                    "hstsIncludeSubdomains": true,
                    "hstsPreload": true
                }
```
