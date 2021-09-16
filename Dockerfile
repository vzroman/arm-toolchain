# Target version
ARG OS_VERSION=10.9

FROM debian:${OS_VERSION}
MAINTAINER Roman Vozzhenikov "vzroman@gmail.com"
ENV REFRESHED_AT 2021-04-27

# crosstool-ng version
ARG CROSSTOOL_NG_VERSION=1.24.0-rc3

# Environment
ENV CROSSTOOL_SOURCE=/opt/crosstool-ng-${CROSSTOOL_NG_VERSION}

# Tools
RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install build-essential && \
	apt-get -y install \
		wget \
		git \
		bzip2 \
		bison \
		help2man \
		texinfo \
		flex \
		unzip \
		file \
		gawk \
		libtool libtool-bin \
		ncurses-dev \
		cmake

# Download crosstool-ng
RUN cd /opt &&\
	wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${CROSSTOOL_NG_VERSION}.tar.xz &&\
	for f in *.tar*; do tar xf $f && rm -rf $f; done

# Install crosstool-ng
RUN cd $CROSSTOOL_SOURCE && \
	./bootstrap && \
	./configure --enable-local && \
	make

# Configure ct-ng
COPY .config ${CROSSTOOL_SOURCE}/

# build
RUN mkdir /opt/src &&\
	cd $CROSSTOOL_SOURCE && \
 	./ct-ng build

ENTRYPOINT [ "/bin/bash" ]