FROM gcc:9.2 AS wolfssl

ARG WOLFSSL_VERSION=4.1.0-stable

# Copied from https://github.com/wolfssl/Dockerfile/blob/master/debian/lib/Dockerfile
RUN set -eux \
    # download source files
    && curl \
        -LS https://github.com/wolfSSL/wolfssl/archive/v${WOLFSSL_VERSION}.zip \
        -o v${WOLFSSL_VERSION}.zip \
    && unzip v${WOLFSSL_VERSION}.zip \
    && rm v${WOLFSSL_VERSION}.zip \

    # build and install wolfssl
    && cd wolfssl-${WOLFSSL_VERSION} \
    && ./autogen.sh \
    && ./configure \
        --build=x86_64-linux-gnu \
        --prefix=/usr \
        --includedir=\${prefix}/include \
        --mandir=\${prefix}/share/man \
        --infodir=\${prefix}/share/info \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --libdir=\${prefix}/lib/x86_64-linux-gnu \
        --libexecdir=\${prefix}/lib/x86_64-linux-gnu \
        --disable-dependency-tracking \
        --enable-sha224 \
        --enable-distro \
        --disable-silent-rules \
        --disable-examples \
    && make \
    && make install-exec

RUN find . -name options.h

FROM gcc:9.2

ARG WOLFSSL_VERSION=4.1.0-stable

COPY --from=wolfssl /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=wolfssl /wolfssl-${WOLFSSL_VERSION}/ /usr/include/

COPY . /build

WORKDIR /build

RUN make all

ENTRYPOINT ["/build/dohd"]
CMD []
