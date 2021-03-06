ARG BUILD_FROM=releases_erlang22.1
ARG RUN_FROM=alpine:3.10
FROM ${BUILD_FROM} AS builder

ARG EMQX_VSN=v4.0.7
ARG EMQX_NAME=emqx
ARG DEPS_GITHUB_HOST=github.com
ARG DEPS_GITHUB_USER=
ARG DEPS_GITHUB_TOKEN=


WORKDIR /codes
COPY . .

ENV EMQX_DEPS_DEFAULT_VSN="$EMQX_VSN"

RUN echo "machine ${DEPS_GITHUB_HOST}" > ~/.netrc \
    echo "login ${DEPS_GITHUB_USER}" >> ~/.netrc \
    echo "password ${DEPS_GITHUB_TOKEN}" >> ~/.netrc \
    cat ~/.netrc

RUN mv deploy/docker/aylanetworks/rebar.config rebar.config

RUN make ${EMQX_NAME} DEBUG=1 

FROM $RUN_FROM

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.docker.dockerfile="Dockerfile" \
    org.label-schema.license="GNU" \
    org.label-schema.name="emqx" \
    org.label-schema.version=${EMQX_VSN} \
    org.label-schema.description="EMQ (Erlang MQTT Broker) is a distributed, massively scalable, highly extensible MQTT messaging broker written in Erlang/OTP." \
    org.label-schema.url="http://emqx.io" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/emqx/emqx-docker" \
    maintainer="Raymond M Mouthaan <raymondmmouthaan@gmail.com>, Huang Rui <vowstar@gmail.com>, EMQ X Team <support@emqx.io>"

COPY --from=builder /codes/deploy/docker/docker-entrypoint.sh /usr/bin/
COPY --from=builder /codes/deploy/docker/start.sh /usr/bin/
COPY --from=builder /codes/_build/emqx*/rel/emqx /opt/emqx

RUN ln -s /opt/emqx/bin/* /usr/local/bin/ 
RUN apk add --no-cache curl ncurses-libs openssl sudo libstdc++

WORKDIR /opt/emqx

RUN adduser -D -u 1000 emqx \
    && echo "emqx ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

RUN chgrp -Rf emqx /opt/emqx && chmod -Rf g+w /opt/emqx \
      && chown -Rf emqx /opt/emqx

USER emqx

VOLUME ["/opt/emqx/log", "/opt/emqx/data", "/opt/emqx/lib", "/opt/emqx/etc"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8080 for mgmt API
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8883 port for MQTT(SSL)
# - 11883 port for internal MQTT/TCP
# - 18083 for dashboard
# - 4369 for port mapping
# - 5369 for gen_rpc port mapping
# - 6369 for distributed node
EXPOSE 1883 8080 8083 8084 8883 11883 18083 4369 5369 6369

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["/usr/bin/start.sh"]
