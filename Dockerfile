FROM alpine:latest

RUN apk add --no-cache \
        bash \
        iptables \
        openvpn

COPY entry.sh /usr/bin/
RUN chmod +x /usr/bin/install.sh

COPY gateway-fix.sh /usr/bin/
RUN chmod +x /usr/bin/gateway-fix.sh

ENV VPN_LOG_LEVEL=3

ARG BUILD_DATE
ARG IMAGE_VERSION

LABEL build-date=$BUILD_DATE
LABEL image-version=$IMAGE_VERSION

VOLUME ["/vpn"]

ENTRYPOINT [ "/usr/bin/entry.sh" ]
