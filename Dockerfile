################################### STAGE ONE ####################################
ARG ALPINE_VERSION=3.12
FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION} AS alpinebuild

LABEL maintainer="Rakhesh Sasidharan"
ENV S6_VERSION 2.0.0.1
ARG TARGETARCH

# COPY over my script to download s6. Remove /var/run as it's a link to /run and causes issues in the COPY block later. 
# RUN the script and delete it.
COPY ./gets6.sh /tmp
RUN rm -f /var/run && /tmp/gets6.sh $S6_VERSION $TARGETARCH && rm -f /tmp/gets6.sh

################################### STAGE TWO ####################################
# Doing a new build just so I can get rid of that /tmp/gets6.sh from any of the layers coz of my OCD ...
ARG ALPINE_VERSION=3.12
FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION} 

RUN rm -f /var/run 
COPY --from=alpinebuild / /

ENTRYPOINT ["/init"]
