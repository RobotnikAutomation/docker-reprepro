FROM debian:buster-20210208-slim
MAINTAINER Guillem Gari <ggari@robotnik.es>

ENV DEBIAN_FRONTEND=noninteractive \
	REPREPRO_BASE_DIR=/data/debian

RUN apt-get update \
  && apt-get install -yq --no-install-recommends \
      gnupg \
      reprepro \
      openssh-server \
  && apt-get clean -q -y \
  && apt-get autoremove -q -y \
  && rm -rf /var/lib/apt/lists/* \
  && true

RUN mkdir /var/run/sshd

# Configure an reprepro user (admin)
RUN adduser --system --group --shell /bin/bash --uid 600 --disabled-password reprepro

# Configure an apt user (read only)
RUN adduser --system --group --shell /bin/bash --uid 601 --disabled-password apt

ADD sshd_config /etc/ssh/sshd_config
ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN true \
	&& mkdir -p /home/reprepro/.ssh \
	&& chown reprepro:reprepro /home/reprepro/.ssh \
	&& chmod 700 /home/reprepro/.ssh \
	&& mkdir -p /home/apt/.ssh \
	&& chown apt:apt /home/apt/.ssh \
	&& chmod 700 /home/apt/.ssh


ENV REPREPRO_DEFAULT_NAME Reprepro

VOLUME ["/config"]
VOLUME ["/data"]

# sshd
EXPOSE 22

CMD ["/run.sh"]
