FROM erlang:22.1-alpine
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add git \
        curl \
        gcc \
        g++ \
        make \
        perl \
        ncurses-dev \
        openssl-dev \
        coreutils \
        bsd-compat-headers \
        libc-dev \
        openssh \
        libstdc++

ENV EMQX_HOME=/emqx-rel \
    PLUGIN_NAME=emq_plugin \
    EMQX_CONF=rebar.config \
    ACL_CONF=acl.conf \
    EMQX_BUILD_HOME=/emqx-rel/_build/emqx/rel/emqx
ARG SSH_PRI_KEY

RUN git clone -b v4.0.5 --depth 1 git@gitlab.ayla.com.cn:cloudplatform/emqx-rel.git ${EMQX_HOME}

RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh

RUN echo "$SSH_PRI_KEY" > /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN cd ${EMQX_HOME} \
    && make
RUN rm -rf /root/.ssh/
# TODO: change this to env var
COPY emqx.conf ${EMQX_BUILD_HOME}/etc/emqx.conf 
COPY ${PLUGIN_NAME}.config ${EMQX_BUILD_HOME}/etc/plugins/${PLUGIN_NAME}.config

# docker build -t emqx-plugin-demo:latest --build-arg SSH_PRI_KEY="$(cat ~/.ssh/id_rsa)" .
CMD ${EMQX_BUILD_HOME}/bin/emqx foreground
ENTRYPOINT ${EMQX_BUILD_HOME}/bin/emqx foreground
