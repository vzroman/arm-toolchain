FROM centos:7
MAINTAINER Roman Vozzhenikov "vzroman@gmail.com"
ENV REFRESHED_AT 2020-04-17

# crosstool-ng version
ARG CROSSTOOL_NG_VERSION=1.24.0-rc3

# Environment
ENV CROSSTOOL_SOURCE=/opt/crosstool-ng-${CROSSTOOL_NG_VERSION}

# Tools
RUN yum install -y epel-release && \
	yum -y update && \
	yum -y groupinstall "Development Tools" && \
	yum -y install \
		wget \
		git \
		bzip2 \
		bison \
		help2man \
		texinfo \
		which \
		ncurses-devel

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