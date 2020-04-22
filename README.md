# cross-toolchain
This is a dockerfile for building a docker image with gcc based cross compiler for ARM architecture.
The cross toolchain is build with crosstoll-ng utility. The build process can accept the version of the crosstool-ng as an argument:
* CROSSTOOL_NG_VERSION (default 1.24.0-rc3)
The versions of components (binutils, gcc, glibc etc.) are defined in the .config file 
(see the docimentation on crosstool-ng https://crosstool-ng.github.io/docs/configuration/)

Example of command for building the image:

docker build --build-arg CROSSTOOL_NG_VERSION=1.24.0-rc3 -t="my cross toolchain" .
