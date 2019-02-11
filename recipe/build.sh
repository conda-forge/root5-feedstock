#!/bin/bash

set -x

cd build

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

export COMMON_OPTIONS="-Dall=OFF -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON -DBUILD_SHARED_LIBS=ON \
                       -Dexplicit_link=ON -Dgsl_shared=ON -Dccache=OFF \
                       -Dfftw3=ON -Dfitsio=OFF -Dmathmore=ON -Dminuit2=ON -Dreflex=ON \
                       -Dpython=ON -Droofit=ON -Dtable=ON -Dthread=ON -Dunuran=ON -Dvdt=ON -Dxml=ON \
                       -Dasimage=OFF -Dastiff=OFF -Dbonjour=OFF -Dfortran=OFF -Dsqlite=OFF -Dtmva=OFF \
                       -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root \
                       -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_BUILD_TYPE=Release"

if [ "$(uname)" == "Darwin" ]; then
    
    cmake .. -std=cxx11 -Dcocoa=ON -Dlibcxx=ON ${COMMON_OPTIONS}

else

    cmake .. -std=cxx11 -Dx11=ON -Dxft=ON ${COMMON_OPTIONS}

fi

cmake --build . --target install -- -j 4

# Install pyROOT in the site-packages so there is no need for
# setting PYTHONPATH
cp ${PREFIX}/lib/root/libPyROOT.* ${PREFIX}/lib/python2.7/site-packages/
cp ${PREFIX}/lib/root/ROOT.py ${PREFIX}/lib/python2.7/site-packages/

# Now add the location of the CINT Dynamic Link Library (dll) to the system path
# for ROOT, so that we do not need to set LD_LIBRARY_PATH at runtime
sed "s|Unix\.\*\.Root\.DynamicPath\:.*|Unix\.\*\.Root\.DynamicPath\:    \.:${PREFIX}/lib/root:${PREFIX}/lib/root/cint/cint/stl:${PREFIX}/lib/root/cint/cint/include|g" ${PREFIX}/etc/root/system.rootrc > new_system.rootrc
mv new_system.rootrc ${PREFIX}/etc/root/system.rootrc
