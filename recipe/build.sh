#! /usr/bin/bash
set -e

mkdir -p build
cd build

# DD4hep installs its CMake config to $PREFIX/cmake (not the standard
# lib/cmake/DD4hep CMake would auto-discover) -- see the
# eic-stack-roadmap memory.
cmake .. \
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
