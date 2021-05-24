# https://github.com/dgiagio/warp/issues/50
ARG RUST_TARGET=x86_64-unknown-linux-musl
FROM ekidd/rust-musl-builder as build

ARG WARP_VERSION=v0.3.0
ARG PATCH_FILE=/tmp/warp-musl.path
ARG RUST_TARGET

COPY warp-musl.patch ${PATCH_FILE}

RUN git clone -v --depth 1 --single-branch --branch ${WARP_VERSION} https://github.com/dgiagio/warp . \
    && patch ~/src/warp-packer/src/main.rs ${PATCH_FILE} \
    && cargo build --release --target=${RUST_TARGET}

FROM busybox
WORKDIR /app
ARG RUST_TARGET
USER 1000:1000

COPY --from=build /home/rust/src/target/${RUST_TARGET}/release/warp-packer .

ENTRYPOINT [ "./warp-packer" ]
CMD [ "--help" ]
