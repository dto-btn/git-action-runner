FROM ghcr.io/actions/actions-runner:2.328.0
# for latest release, see https://github.com/actions/runner/releases

USER root

COPY github-actions-runner/GOC-GDC-ROOT-A.crt /usr/local/share/ca-certificates/
#ensure certs are added
RUN update-ca-certificates

# install curl and jq
RUN apt-get update && apt-get install -y curl jq ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY github-actions-runner/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]
