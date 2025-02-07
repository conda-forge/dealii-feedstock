#!/bin/bash -e

# {{{ test.cc

cat <<'EOF'>test.cpp
#include <deal.II/grid/tria.h>
#include <deal.II/grid/tria_accessor.h>
#include <deal.II/grid/tria_iterator.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_out.h>

#include <iostream>
#include <fstream>
#include <cmath>

using namespace dealii;

int main ()
{
  Triangulation<2> triangulation;
  GridGenerator::hyper_cube (triangulation);
  triangulation.refine_global (2);
  std::ofstream out ("grid.eps");
  GridOut grid_out;
  grid_out.write_eps (triangulation, out);
  std::cout << "Grid generated and written to grid.eps" << std::endl;
}
EOF

# }}}

# {{{ CMakeLists.txt
cat <<'EOF'>CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(DealIISimpleExample LANGUAGES CXX)
find_package(deal.II 9.0.0 QUIET HINTS ${deal.II_DIR} ${DEAL_II_DIR} ../ ../../ $ENV{DEAL_II_DIR} CONFIG REQUIRED)
deal_ii_initialize_cached_variables()
add_executable(test test.cpp)
deal_ii_setup_target(test)
EOF

# }}}

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

mkdir build && cd build
cmake -DDEAL_II_DIR=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DPython3_EXECUTABLE="$PYTHON" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DEAL_II_WITH_LAPACK=ON \
      -DBOOST_DIR="${PREFIX}" \
      -DTBB_DIR="${PREFIX}" \
      -DMUPARSER_DIR="${PREFIX}" \
  .. || (show_cmake_logs && exit 1)

make VERBOSE=1
make run
