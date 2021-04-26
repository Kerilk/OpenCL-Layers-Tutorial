#!/bin/sh
mkdir -p "$HOME/OpenCL-Layers-Tutorial-Folder"
export CL_LAYERS_TUT_BASE="$HOME/OpenCL-Layers-Tutorial-Folder"
cd "$CL_LAYERS_TUT_BASE"

# Get OpenCL Headers
export OPENCL_HEADERS_DIR="$CL_LAYERS_TUT_BASE/OpenCL-Headers"
git -C "$OPENCL_HEADERS_DIR" pull 2> /dev/null || git clone https://github.com/KhronosGroup/OpenCL-Headers.git "$OPENCL_HEADERS_DIR"

# Get OpenCL ICD Loader
export OPENCL_ICD_LOADER_DIR="$CL_LAYERS_TUT_BASE/OpenCL-ICD-Loader"
git -C "$OPENCL_ICD_LOADER_DIR" pull 2> /dev/null || git clone https://github.com/KhronosGroup/OpenCL-ICD-Loader.git "$OPENCL_ICD_LOADER_DIR"

# Build OpenCL ICD Loader
cd "$OPENCL_ICD_LOADER_DIR"
ln -sf "$OPENCL_HEADERS_DIR/CL" inc
mkdir -p build
cd build
cmake ..
cmake --build .
export LIBRARY_PATH="$OPENCL_ICD_LOADER_DIR/build":$LIBRARY_PATH
export LD_LIBRARY_PATH="$OPENCL_ICD_LOADER_DIR/build":$LD_LIBRARY_PATH

# Get clinfo
export CLINFO_DIR="$CL_LAYERS_TUT_BASE/clinfo"
git -C "$CLINFO_DIR" pull 2> /dev/null || git clone https://github.com/Oblomov/clinfo.git "$CLINFO_DIR"

# Build clinfo
cd "$CLINFO_DIR"
make

# Testing loader and clinfo
$CLINFO_DIR/clinfo
OPENCL_LAYERS="$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so" $CLINFO_DIR/clinfo

# Building Layer from Toturial
cd "$CL_LAYERS_TUT_BASE"
export OPENCL_LAYERS_TUTORIAL_DIR="$CL_LAYERS_TUT_BASE/OpenCL-Layers-Tutorial"
git -C "$OPENCL_LAYERS_TUTORIAL_DIR" pull 2> /dev/null || git clone https://github.com/Kerilk/OpenCL-Layers-Tutorial.git "$OPENCL_LAYERS_TUTORIAL_DIR"
cd "$OPENCL_LAYERS_TUTORIAL_DIR/example_layer"
mkdir -p build
cd build
cmake -DOPENCL_HEADER_PATH="$OPENCL_HEADERS_DIR" ..
cmake --build .

# Run clinfo with the newly built layer
OPENCL_LAYERS="$OPENCL_LAYERS_TUTORIAL_DIR/example_layer/build/libExampleLayer.so" $CLINFO_DIR/clinfo
OPENCL_LAYERS="$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so":"$OPENCL_LAYERS_TUTORIAL_DIR/example_layer/build/libExampleLayer.so" $CLINFO_DIR/clinfo
OPENCL_LAYERS="$OPENCL_LAYERS_TUTORIAL_DIR/example_layer/build/libExampleLayer.so":"$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so" $CLINFO_DIR/clinfo

# Building Examples Layers
cd "$CL_LAYERS_TUT_BASE"
export OPENCL_LAYERS_DIR="$CL_LAYERS_TUT_BASE/OpenCL-Layers"
git -C "$OPENCL_LAYERS_DIR" pull 2> /dev/null || git clone https://github.com/Kerilk/OpenCL-Layers.git "$OPENCL_LAYERS_DIR"
cd "$OPENCL_LAYERS_DIR"
ln -sf $OPENCL_HEADERS_DIR/CL inc
mkdir -p build
cd build
cmake ..
cmake --build .

# Running the memory leak checker against clinfo
OPENCL_LAYERS="$OPENCL_LAYERS_DIR/build/object-lifetime/libCLObjectLifetimeLayer.so" $CLINFO_DIR/clinfo

# Real life example
cd "$CL_LAYERS_TUT_BASE"
export MIXBENCH_DIR="$CL_LAYERS_TUT_BASE/mixbench"
git -C "$MIXBENCH_DIR" pull 2> /dev/null || git clone https://github.com/ekondis/mixbench.git "$MIXBENCH_DIR"
cd "$MIXBENCH_DIR"
git checkout 514c7577f139871266d9535583bd78a6878af47e
cd mixbench-opencl
mkdir -p build
cd build
cmake ..
cmake --build .

# Running the memory leak checker against mixbench-ocl-ro
OPENCL_LAYERS="$OPENCL_LAYERS_DIR/build/object-lifetime/libCLObjectLifetimeLayer.so" ./mixbench-ocl-ro

# Running the latest patch version
git checkout master
cmake --build .
OPENCL_LAYERS="$OPENCL_LAYERS_DIR/build/object-lifetime/libCLObjectLifetimeLayer.so" ./mixbench-ocl-ro
