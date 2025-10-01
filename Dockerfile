FROM ghcr.io/actions/actions-runner:2.328.0
# for latest release, see https://github.com/actions/runner/releases

USER root

# install curl and jq
RUN apt-get update && apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY cert/gitrunnertestdto-private-key.pem ./gitrunnertestdto-private-key.pem
COPY github-actions-runner/jwt.sh ./jwt.sh
COPY github-actions-runner/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
RUN chmod +x ./jwt.sh
RUN chmod +x ./gitrunnertestdto-private-key.pem

USER runner

ENTRYPOINT ["./entrypoint.sh"]
