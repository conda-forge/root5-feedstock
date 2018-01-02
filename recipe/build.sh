#!/bin/bash

cd build

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    
    CC=clang
    CXX=clang++
    
    cmake .. -Dall=ON -Dkrb5=ON -Dcocoa=ON -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON -DBUILD_SHARED_LIBS=ON \
             -Dccache=ON -Dfortran=OFF -Dexplicit_link=ON -Dgsl_shared=ON -Dcling=OFF -Dopengl=ON \
             -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root \
             -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}

else
    
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++
    
    cmake .. -Dall=ON -Dkrb5=ON -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON -DBUILD_SHARED_LIBS=ON \
             -Dccache=ON -Dfortran=OFF -Dexplicit_link=ON -Dgsl_shared=ON -Dcling=OFF -Dopengl=ON  \
             -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root \
             -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}

fi

cmake --build . --target install -- -j ${CPU_COUNT}

# Install pyROOT in the site-packages so there is no need for
# setting PYTHONPATH
cp ${PREFIX}/lib/root/libPyROOT.* ${PREFIX}/lib/python2.7/site-packages/
cp ${PREFIX}/lib/root/ROOT.py ${PREFIX}/lib/python2.7/site-packages/

# Now add the location of the CINT Dynamic Link Library (dll) to the system path
# for ROOT, so that we do not need to set LD_LIBRARY_PATH at runtime
sed "s|Unix\.\*\.Root\.DynamicPath\:.*|Unix\.\*\.Root\.DynamicPath\:    \.:${PREFIX}/lib/root/cint/cint/stl:${PREFIX}/lib/root/cint/cint/include|g" ${PREFIX}/etc/root/system.rootrc > new_system.rootrc
mv new_system.rootrc ${PREFIX}/etc/root/system.rootrc
