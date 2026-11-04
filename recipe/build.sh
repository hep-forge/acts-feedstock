#! /usr/bin/bash
set -e

mkdir -p build
cd build

# DD4hep installs its CMake config to $PREFIX/cmake (not the standard
# lib/cmake/DD4hep CMake would auto-discover) -- see the
# eic-stack-roadmap memory.
# macOS: Geant4Config's find_dependency(EXPAT) reads the SDK's expat.h
# (2.2.5 < 2.9.0) even with CMAKE_PREFIX_PATH; name conda's expat directly.
EXTRA_ARGS=()
if [[ "$(uname)" == "Darwin" ]]; then
  # std::is_base_of_v is used without <type_traits>; libc++ does not pull it
  # in through other headers
  export CXXFLAGS="${CXXFLAGS} -include type_traits"
  EXTRA_ARGS+=(-DCMAKE_FIND_FRAMEWORK=LAST
               -DEXPAT_INCLUDE_DIR="${PREFIX}/include"
               -DEXPAT_LIBRARY="${PREFIX}/lib/libexpat${SHLIB_EXT}")
fi

cmake .. "${EXTRA_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DACTS_USE_SYSTEM_LIBS=ON \
  -DACTS_BUILD_PLUGIN_DD4HEP=ON \
  -DACTS_BUILD_PLUGIN_JSON=ON \
  -DDD4hep_DIR="${PREFIX}/cmake" \
  -DCMAKE_PREFIX_PATH="${PREFIX}/cmake;${PREFIX}"

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j"$NPROC"
make install
