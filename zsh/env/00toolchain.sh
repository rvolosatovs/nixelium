if [[ $distro == "exherbo" ]]; then
    export CHOST=$(readlink '/usr/host')
    export CROSS_COMPILE=${CHOST}-

    export CC=${CHOST}-gcc
    export HOSTCC=${CHOST}-gcc
    export CXX=${CHOST}-c++
    export CLANG=${CHOST}-clang
    export LD=${CHOST}-ld
    export AR=${CHOST}-ar
    export AS=${CHOST}-as
    export NM=${CHOST}-nm
    export STRIP=${CHOST}-strip
    export RANLIB=${CHOST}-ranlib
    export DLLTOOL=${CHOST}-dlltool
    export OBJDUMP=${CHOST}-objdump
    export RESCOMP=${CHOST}-windres
    export WINDRES=${CHOST}-windres
    export PKG_CONFIG=${CHOST}-pkg-config
fi 
