#!/bin/bash

set -x

cd build

case "${target_platform}" in
    osx-*)
        platform_options='-Dcocoa=ON -Dlibcxx=ON -DCMAKE_VERBOSE_MAKEFILE=ON'

export CFLAGS="-isystem ${PREFIX}/include"
export CPPFLAGS="-isystem ${PREFIX}/include -mmacosx-version-min=10.9"
export LDFLAGS="-Wl,-headerpad_max_install_names -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
export LDFLAGS_LD="-headerpad_max_install_names -rpath ${PREFIX}/lib -L${PREFIX}/lib"
export CXXFLAGS="-stdlib=libc++ -std=c++14 -isystem ${PREFIX}/include"

    ;;
    linux-*)
        platform_options='-Dx11=ON -Dxft=ON'
    ;;
esac
cmake .. ${platform_options} \
    -Dall=OFF -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON -DBUILD_SHARED_LIBS=ON \
    -Dexplicit_link=ON -Dgsl_shared=ON -Dccache=OFF \
    -Dfftw3=ON -Dfitsio=OFF -Dmathmore=ON -Dminuit2=ON -Dreflex=ON \
    -Dpython=ON -Droofit=ON -Dtable=ON -Dthread=ON -Dunuran=ON -Dvdt=ON -Dxml=ON \
    -Dasimage=ON -Dastiff=OFF -Dbonjour=OFF -Dfortran=OFF -Dsqlite=OFF -Dtmva=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root \
    -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_BUILD_TYPE=Release \
    -Dbuiltin_afterimage=OFF \
    -Dbuiltin_ftgl=OFF \
    -Dbuiltin_freetype=OFF \
    -Dbuiltin_glew=OFF \
    -Dbuiltin_openssl=OFF \
    -Dbuiltin_pcre=OFF \
    -Dbuiltin_zlib=OFF \
    -Dbuiltin_lzma=OFF \
    -Dbuiltin_lz4=OFF \
    -Dbuiltin_davix=OFF \
    -Dbuiltin_gsl=OFF \
    -Dbuiltin_cfitsio=OFF \
    -Dbuiltin_xrootd=OFF \
    -Dcxx11=OFF \
    -Dcxx14=ON \
    ;

cmake --build . --target install -- -j "${CPU_COUNT}"

# Install pyROOT in the site-packages so there is no need for
# setting PYTHONPATH
cp ${PREFIX}/lib/root/libPyROOT.* ${PREFIX}/lib/python2.7/site-packages/
cp ${PREFIX}/lib/root/ROOT.py ${PREFIX}/lib/python2.7/site-packages/

# Now add the location of the CINT Dynamic Link Library (dll) to the system path
# for ROOT, so that we do not need to set LD_LIBRARY_PATH at runtime
sed "s|Unix\.\*\.Root\.DynamicPath\:.*|Unix\.\*\.Root\.DynamicPath\:    \.:${PREFIX}/lib/root:${PREFIX}/lib/root/cint/cint/stl:${PREFIX}/lib/root/cint/cint/include|g" ${PREFIX}/etc/root/system.rootrc > new_system.rootrc
mv new_system.rootrc ${PREFIX}/etc/root/system.rootrc
