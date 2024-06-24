#!/bin/bash -e

function show_cmake_logs() {
  echo "Content of CMakeFiles/CMakeOutput.log:"
  cat CMakeFiles/CMakeOutput.log

  echo "Content of CMakeFiles/CMakeError.log:"
  cat CMakeFiles/CMakeError.log
}

# Workaround https://github.com/dealii/dealii/issues/7937
CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++[0-9][0-9]//g")
CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-stdlib=libc++//g")

# https://github.com/dealii/dealii/issues/12549
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DPython_ROOT_DIR="${PREFIX}" \
      -DPython_Executable="${PREFIX}/bin/python" \
      -DPython3_ROOT_DIR="${PREFIX}" \
      -DPython3_Executable="${PREFIX}/bin/python" \
      -DCMAKE_BUILD_TYPE=Release \
      -DDEAL_II_COMPONENT_EXAMPLES=OFF \
      -DDEAL_II_ALLOW_BUNDLED=OFF \
      -DEAL_II_WITH_LAPACK=OFF \
      -DDEAL_II_COMPONENT_PYTHON_BINDINGS=ON \
      -DBOOST_DIR="${PREFIX}" \
      -DBOOST_ROOT="${PREFIX}" \
      -DTBB_DIR="${PREFIX}" \
      -DMUPARSER_DIR="${PREFIX}" \
      .. || (show_cmake_logs && exit 1)

make -j${CPU_COUNT}
make install
make test
