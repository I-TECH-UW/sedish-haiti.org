ARG PLATFORM_VERSION=latest

FROM jembi/platform:$PLATFORM_VERSION
ADD . /implementation

ADD ./utils /instant/utils

RUN chmod +x /implementation/scripts/cmd/override-configs/override-configs
RUN /implementation/scripts/cmd/override-configs/override-configs

