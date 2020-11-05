FROM amd64/rust:1.41 as build
RUN apt-get update && apt-get install -y --no-install-recommends \
      g++ ca-certificates curl libssl-dev pkg-config
RUN rustup component add rustfmt --toolchain 1.41.1-x86_64-unknown-linux-gnu

WORKDIR /nessie
COPY Cargo.toml Cargo.lock ./

# Create build for dependencies ... should only run when deps change
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build && \
    rm -rf ./target/debug/.fingerprint/reqwest-test-*
 
# Create actual build ... should run if deps and/or src changes
COPY ./src ./src
RUN cargo build
RUN ls -lh target/debug/reqwest-test

FROM amd64/debian:buster-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libssl-dev openssl && \
      apt-get clean
COPY --from=build ./nessie/target/debug/reqwest-test /reqwest-test

# Expose port used by broker service
# EXPOSE 8083

# Enable HTTPS from https://github.com/rust-embedded/cross/issues/119
# ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
# ENV SSL_CERT_DIR=/etc/ssl/certs

ENTRYPOINT ["/reqwest-test"]

