#!/bin/sh -l

JWTTOKEN=$(./jwt.sh $CLIENT_ID "./$KEY_FILE_NAME.pem")
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