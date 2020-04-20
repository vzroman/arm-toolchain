# cross-toolchain
This is a dockerfile for building a gcc based cross compiler for ARM architecture.
There are next arguments defined in the script:
* HOST - the host platform (default x86_64)
* BINUTILS_VERSION - the version of binutils (default 2.24)
* GLIBC_VERSION the version of glibc library (default 2.20)
* GCC_VERSION - the version of GCC (default 4.9.2)
* LINUX_KERNEL_VERSION - the version of linux kernel for target pltatform (default 4.17.9)
You can pass these arguments to the docker build command to get required versions of the components. 
For example:

docker build --build-arg GCC_VERSION=5.3.0 -t="my cross toolchain" .
