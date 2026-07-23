FROM alpine:3.19

RUN apk add --no-cache curl \
    && BORE_VERSION=$(curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | grep tag_name | cut -d '"' -f4) \
    && curl -sL "https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/bore \
    && apk del curl

EXPOSE 7835 10000-10100

CMD ["bore", "server", "--min-port", "10000", "--max-port", "10100", "--secret", "railwayfree2026"]
