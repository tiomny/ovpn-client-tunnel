FROM alpine:3.16

RUN apk add --no-cache \
        bash \
        iptables \
        openvpn

COPY entry.sh /usr/bin/
COPY gateway-fix.sh /usr/bin/

ENV KILL_SWITCH=iptables
ENV USE_VPN_DNS=on
ENV VPN_LOG_LEVEL=3

ARG BUILD_DATE
ARG IMAGE_VERSION

LABEL build-date=$BUILD_DATE
LABEL image-version=$IMAGE_VERSION

VOLUME ["/vpn"]

ENTRYPOINT [ "/usr/bin/entry.sh" ]

#ENTRYPOINT [ "/start.sh" ]
#CMD [ "/start.sh" ]