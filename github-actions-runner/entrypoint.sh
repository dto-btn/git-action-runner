#!/bin/bash

set -o pipefail
# CLIENT_ID=$1 # Client ID as first argument

# pem=$( cat $2 ) # file path of the private key as second argument.  comment this out and use ${PEM} to bring in env var from terraform

now=$(date +%s)
iat=$((${now} - 60)) # Issues 60 seconds in the past
exp=$((${now} + 600)) # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${CLIENT_ID}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
# ${pem} here to ${PEM} after bring in from env var in terraform
signature=$(
    openssl dgst -sha256 -sign <(echo -n "${PEM}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWTTOKEN="${header_payload}"."${signature}"


# JWTTOKEN=$(./jwt.sh $CLIENT_ID "./$KEY_FILE_NAME.pem")
echo "12312: $JWTTOKEN"

# get an access token
ACCESS_TOKEN="$(curl --request POST -fsSL --http1.1 \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $JWTTOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
  | jq -r '.token')"

echo "access: $ACCESS_TOKEN"

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL --http1.1 \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"

echo "reg: $REGISTRATION_TOKEN"

./config.sh --url $GH_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh