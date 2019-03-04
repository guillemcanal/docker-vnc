FROM ubuntu:latest

	# user settings
ENV HOME=/home/user \
	USER_NAME=user \
	USER_UID=1000 \
	USER_SHELL=/bin/bash \
	USER_SUDOER=yes \
	# vnc settings
	VNC_DPI=100 \
	VNC_GEOMETRY=1280x1024 \
	VNC_PASS=vncpassword \
	# default language
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8 \
	# init default version
	TINI_VERSION=v0.18.0 \
	# non interactive mode
	DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	# dependencies
	vim wget locales bzip2 sudo gosu zsh git curl \
	apt-transport-https ca-certificates gnupg-agent software-properties-common \
	# x11
	xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all x11-xserver-utils libgtk2.0-common xclip dbus-x11 \
	# terminal
	xfce4-terminal \
	# windows manager
	i3 \
	# vnc server
	&& wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.9.0.x86_64.tar.gz | tar xz --strip 1 -C / \
	# docker cli & docker-compose (for docker in docker purposes)
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
	&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
	&& apt-get update && apt-get install -y docker-ce-cli docker-compose \
	# configure locale
	&& locale-gen ${LC_ALL}

COPY rootfs/ /

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini 

ENTRYPOINT ["/tini", "-v", "--", "/usr/local/bin/docker-entrypoint"]

WORKDIR $HOME

CMD ["vncstart", "0", "xfce4-terminal", "--wait"]
