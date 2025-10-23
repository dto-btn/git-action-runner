Custom imagefor Github runner when authenticating with GitHub Apps.

**Needed env variables**

| Variables | Description |
| --------- | ----------- |
| CLIENT_ID | Client id of GitHub App. Different from APP ID. |
| PEM | PEM file contents of installed GitHub App|
| GH_URL | GitHub url you will be using the registration token against |
| REGISTRATION_TOKEN_API_URL| URL endpoint used to get a registration token. |