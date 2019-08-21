FROM ubuntu:18.04

	# user settings
ENV HOME=/home/user \
	USER_NAME=user \
	USER_UID=1000 \
	USER_SHELL=/bin/bash \
	USER_SUDOER=yes \
	# vnc settings
	VNC_DPI=100 \
	VNC_GEOMETRY=1920x1080 \
	VNC_PASS=changeme \
	# default language
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8 \
	# init default version
	TINI_VERSION=v0.18.0 \
	TIGERVNC_VERSION=1.9.0 \
	DOCKER_COMPOSE_VERSION=1.24.1 \
	# non interactive mode
	DEBIAN_FRONTEND=noninteractive

RUN set -ex \
	&& apt-get update && apt-get install --no-install-recommends -y \
	# dependencies
	vim wget locales bzip2 sudo gosu zsh git curl \
	apt-transport-https ca-certificates gnupg-agent software-properties-common \
	# x11
	xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all x11-xserver-utils libgtk2.0-common xclip dbus-x11 fonts-noto-color-emoji \
	# terminal
	xfce4-terminal \
	# windows manager
	i3 \
	# python dependencies
	python3 python3-pip python3-setuptools \
	# python modules
	&& pip3 install --upgrade pyyaml \
	# vnc server
	&& wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-${TIGERVNC_VERSION}.x86_64.tar.gz | tar xz --strip 1 -C / \
	# docker cli & docker-compose (for docker in docker purposes)
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
	&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
	&& apt-get update && apt-get install --no-install-recommends -y docker-ce-cli \
	# docker compose
	&& curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose \
	&& chmod +x /usr/bin/docker-compose \
	# configure locale
	&& locale-gen ${LC_ALL} \
	# cleanup
	&& apt-get remove -y apt-transport-https gnupg-agent software-properties-common \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

COPY rootfs/ /

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini 

ENTRYPOINT ["/tini", "-v", "--", "/usr/local/bin/docker-entrypoint"]

WORKDIR $HOME

CMD ["vncstart", "0", "xfce4-terminal", "--wait"]
