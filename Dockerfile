################################### STAGE ONE ####################################
ARG ALPINE_VERSION=3.13
FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION} AS alpinebuild

LABEL maintainer="Rakhesh Sasidharan"
ENV S6_VERSION 2.2.0.3
ARG TARGETARCH
ARG TARGETVARIANT

# Install GnuPG so I can install the public key of the s6 folks. Remove it later. 
RUN apk add --update --no-cache gnupg
RUN wget -qO - https://keybase.io/justcontainers/key.asc | gpg --import

# COPY over my script to download s6. Remove /var/run as it's a link to /run and causes issues in the COPY block later. 
# RUN the script and delete it.
COPY ./gets6.sh /tmp
RUN rm -f /var/run 
RUN /tmp/gets6.sh $S6_VERSION $TARGETARCH $TARGETVARIANT

# At this point the build will either exit or continue depending on the exit status of gets6.sh
RUN rm -f /tmp/gets6.sh
RUN rm -rf /root/.gnupg
# I have to remove this stuff lest it gets copied over in the next stage (as I am copying from /)
RUN apk -q --no-cache del gnupg
RUN rm -rf /var/cache/apk/*

################################### STAGE TWO ####################################
# Doing a new build just so I can get rid of that /tmp/gets6.sh from any of the layers coz of my OCD ...
ARG ALPINE_VERSION=3.13
FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION} 

LABEL maintainer="Rakhesh Sasidharan"
LABEL org.opencontainers.image.source=https://github.com/rakheshster/docker-alpine-s6

RUN rm -f /var/run 
COPY --from=alpinebuild / /

ENTRYPOINT ["/init"]
