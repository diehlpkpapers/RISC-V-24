#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${LIB_DIR_NAME:?} ${GCC_VERSION:?} ${BUILD_TYPE:?} \
    ${CMAKE_VERSION:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${CUDA_SM:?} \
    ${BOOST_VERSION:?} ${BOOST_BUILD_TYPE:?} \
    ${JEMALLOC_VERSION:?} ${HWLOC_VERSION:?} ${VC_VERSION:?} ${HPX_VERSION:?} \
    ${OCT_WITH_PARCEL:?}

#Disable VC for HPX, since we do not use HPX's VC suuport anymore
#case $(uname -i) in
#    ppc64le)
#        USE_VC=OFF
#	;;
#    x86_64)
#        USE_VC=ON
#	;;
#
#    *)
#        echo 'Unknown architecture encountered.' 2>&1
#        exit 1
#        ;;
#esac





DIR_SRC=${SOURCE_ROOT}/hpx
DIR_BUILD=${INSTALL_ROOT}/hpx/build
DIR_INSTALL=${INSTALL_ROOT}/hpx
FILE_MODULE=${INSTALL_ROOT}/modules/hpx/${HPX_VERSION}-${BUILD_TYPE}

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        # Github doesn't allow fetching a specific changeset without cloning
        # the entire repository (fetching unadvertised objects). We can, 
        # however, download the commit in form of a .zip or a .tar.gz file
        #wget -O- https://github.com/stellar-group/hpx/archive/${HPX_VERSION}.tar.gz \
         #   | tar xz --strip-components=1
        # Legacy command. Clone the entire repository and use master/HEAD
	cd ..
        git clone https://github.com/STEllAR-GROUP/hpx.git
	cd hpx
	git checkout ${HPX_VERSION}
	cd ..
    )
fi

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDCXXFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDCXXFLAGS}" \
    -DHPX_WITH_CUDA=${OCT_WITH_CUDA} \
    -DHPX_WITH_CUDA_CLANG=OFF \
    -DHPX_WITH_CXX_STANDARD=20 \
    -DHPX_WITH_FETCH_ASIO=ON\
    -DHPX_WITH_PAPI=${OCT_WITH_PAPI} \
    -DPAPI_ROOT=${INSTALL_ROOT}/papi/ \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DHPX_WITH_THREAD_IDLE_RATES=ON \
    -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
    -DHPX_WITH_MALLOC=JEMALLOC \
    -DJEMALLOC_ROOT=${INSTALL_ROOT}/jemalloc \
    -DBoost_NO_BOOST_CMAKE=TRUE \
    -DBoost_NO_SYSTEM_PATHS=TRUE \
    -DBOOST_ROOT=${INSTALL_ROOT}/boost \
    -DLIBFABRIC_ROOT=$INSTALL_ROOT/libfabric \
    -DHPX_WITH_CUDA_ARCH=${CUDA_SM} \
    -DHPX_WITH_NETWORKING=${OCT_WITH_PARCEL} \
    -DHPX_WITH_MORE_THAN_64_THREADS=ON \
    -DHPX_WITH_MAX_CPU_COUNT=256 \
    -DHPX_WITH_EXAMPLES=OFF \
    -DHPX_WITH_TESTS=OFF \
    -DHPX_WITH_PARCELPORT_MPI=${OCT_WITH_MPI} \
    -DHPX_WITH_PARCELPORT_LIBFABRIC=${OCT_WITH_LIBFABRIC} \
    -DHPX_PARCELPORT_LIBFABRIC_PROVIDER=gni \
    -DHPX_PARCELPORT_LIBFABRIC_64K_PAGES:STRING=20 \
    -DHPX_PARCELPORT_LIBFABRIC_DEBUG_LOCKS:BOOL=OFF \
    -DHPX_PARCELPORT_LIBFABRIC_ENDPOINT:STRING=rdm \
    -DHPX_PARCELPORT_LIBFABRIC_MAX_PREPOSTS:STRING=512 \
    -DHPX_PARCELPORT_LIBFABRIC_MAX_SENDS:STRING=128 \
    -DHPX_PARCELPORT_LIBFABRIC_MEMORY_CHUNK_SIZE:STRING=4096 \
    -DHPX_PARCELPORT_LIBFABRIC_MEMORY_COPY_THRESHOLD:STRING=4096 \
    -DHPX_PARCELPORT_LIBFABRIC_WITH_BOOTSTRAPPING:BOOL=TRUE \
    -DHPX_PARCELPORT_LIBFABRIC_WITH_DEV_MODE:BOOL=OFF \
    -DHPX_PARCELPORT_LIBFABRIC_WITH_LOGGING:BOOL=OFF \
    -DHPX_PARCELPORT_LIBFABRIC_WITH_PERFORMANCE_COUNTERS:BOOL=OFF \
    -DHPX_WITH_APEX=${OCT_WITH_APEX} \
    -DAPEX_WITH_CUDA=${OCT_WITH_CUDA} \
    -DAPEX_WITH_ACTIVEHARMONY=FALSE \
    -DAPEX_WITH_OTF2=${HPX_WITH_OTF2} \
    -DOTF2_ROOT=$INSTALL_ROOT/otf2/ \
    -DAPEX_WITH_BFD=FALSE \
    -DHPX_WITH_APEX_NO_UPDATE=FALSE \
    -DHPX_WITH_APEX_TAG=develop \
    -DAPEX_WITH_MPI=${OCT_WITH_MPI} \
    -DHPX_WITH_FETCH_ASIO=ON \
    -DHPX_WITH_CXX20_COROUTINES=On \
    -G Ninja

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} 
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install
cp ${DIR_BUILD}/compile_commands.json ${DIR_SRC}/compile_commands.json

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {HPX}
}
module-whatis {HPX}
set root    ${DIR_INSTALL}
conflict    hpx

module load gcc/${GCC_VERSION}
module load boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}
module load cmake/${CMAKE_VERSION}
module load jemalloc/${JEMALLOC_VERSION}
module load hwloc/${HWLOC_VERSION}
module load Vc/${VC_VERSION}-${BUILD_TYPE}

prereq      gcc/${GCC_VERSION}
prereq      boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}
prereq      cmake/${CMAKE_VERSION}
prereq      jemalloc/${JEMALLOC_VERSION}
prereq      hwloc/${HWLOC_VERSION}
prereq      Vc/${VC_VERSION}-${BUILD_TYPE}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
setenv          HPX_DIR            \$root/${LIB_DIR_NAME}/cmake/HPX
setenv          HPX_VERSION        ${HPX_VERSION}
EOF

