FROM erlang:22.1-alpine
# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.docker.dockerfile="Dockerfile" 

RUN apk add --no-cache git \
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
libstdc++ \
openssh