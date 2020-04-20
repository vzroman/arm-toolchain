FROM centos:7
MAINTAINER Roman Vozzhenikov "vzroman@gmail.com"
ENV REFRESHED_AT 2020-04-17

# Toolchain version
ARG HOST=x86_64
ARG BINUTILS_VERSION=2.24
ARG GLIBC_VERSION=2.20
ARG GCC_VERSION=4.9.2
ARG LINUX_KERNEL_MAJOR=4
ARG LINUX_KERNEL_MINOR=17.9

# Environment
ENV TARGET=arm-linux-gnueabihf
ENV LINUX_KERNEL=$LINUX_KERNEL_MAJOR.$LINUX_KERNEL_MINOR
ENV SOURCES=/opt/sources
ENV BUILD=/opt/build
ENV TOOLCHAIN=$BUILD/gcc-toolchain
ENV ROOT=$TOOLCHAIN/$TARGET
ENV TC_BUILD=$SOURCES/gcc-toolchain
ENV PATH=$TOOLCHAIN/bin:$PATH

# Tools
RUN yum install -y epel-release && \
	yum -y update && \
	yum -y groupinstall "Development Tools" && \
	yum -y install wget git bzip2 bison patch ncurses-term python3 R

# Download sources
RUN mkdir -p $SOURCES && cd $_ &&\
	wget https://ftpmirror.gnu.org/binutils/binutils-$BINUTILS_VERSION.tar.gz &&\
	wget https://ftpmirror.gnu.org/glibc/glibc-$GLIBC_VERSION.tar.gz &&\
	wget https://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz &&\
	wget https://www.kernel.org/pub/linux/kernel/v${LINUX_KERNEL_MAJOR}.x/linux-${LINUX_KERNEL}.tar.gz &&\
	for f in *.tar*; do tar xf $f && rm -rf $f; done

# Linux kernel headers
RUN cd $SOURCES/linux-${LINUX_KERNEL} &&\
	export KERNEL=kernel${LINUX_KERNEL_MAJOR} &&\
	make ARCH=arm INSTALL_HDR_PATH=$ROOT headers_install

# Binutils
RUN mkdir -p $TC_BUILD/binutils && cd $_ && \
	$SOURCES/binutils-$BINUTILS_VERSION/configure \
		--prefix=$TOOLCHAIN \
		--target=$TARGET \
		--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
		--disable-multilib && \
	make -j4 && \
	make install

# GCC prerequisites
RUN cd $SOURCES/gcc-$GCC_VERSION && \
	contrib/download_prerequisites && \
	rm -rf *.tar.*
# GCC Bootstrap
RUN mkdir -p $TC_BUILD/gcc && cd $_ && \
	$SOURCES/gcc-$GCC_VERSION/configure \
		--prefix=$TOOLCHAIN \
		--target=$TARGET \
		--enable-languages=c,c++,fortran \
		--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
		--disable-multilib &&\
	make -j4 all-gcc && \
	make install-gcc

# Glibc Bootstrap
RUN mkdir -p $TC_BUILD/glibc && cd $_ && \
	$SOURCES/glibc-$GLIBC_VERSION/configure \
		--prefix=$ROOT \
		--build=$MACHTYPE \
		--host=$TARGET \
		--target=$TARGET \
		--with-fpu=vfp \
		--with-float=hard \
		--with-headers=$ROOT/include \
		--disable-multilib \
		libc_cv_forced_unwind=yes && \
	make install-bootstrap-headers=yes install-headers && \
	make csu/subdir_lib && \
	install csu/crt1.o csu/crti.o csu/crtn.o $ROOT/lib && \
	arm-linux-gnueabihf-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $ROOT/lib/libc.so && \
	touch $ROOT/include/gnu/stubs.h

# GCC for glibc
RUN cd $TC_BUILD/gcc && \
	make -j4 all-target-libgcc && \
	make install-target-libgcc

# Glibc full
RUN cd $TC_BUILD/glibc && \
	make -j4 && \
	make install
# GCC full
RUN cd $TC_BUILD/gcc && \
	make -j4 && \
	make install

ENTRYPOINT [ "/bin/bash" ]