#!/bin/sh -l

JWTTOKEN=$(./jwt.sh Iv23liUSavN8izwHxrgV ./gitrunnertestdto-private-key.pem)
echo "12312: $JWTTOKEN"

# get an access token
ACCESS_TOKEN="$(curl --request POST -fsSL \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $JWTTOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  'https://api.github.com/app/installations/87587800/access_tokens' \
  | jq -r '.token')"

echo "access: $ACCESS_TOKEN"

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  'https://api.github.com/orgs/dto-btn/actions/runners/registration-token' \
  | jq -r '.token')"

echo "reg: $REGISTRATION_TOKEN"

./config.sh --url $GH_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh