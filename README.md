# Tutorial for OpenCL Layers

## Presentation

Presentation: [LayersForOpenCL.pdf](https://github.com/Kerilk/OpenCL-Layers-Tutorial/blob/main/presentation/LayersForOpenCL.pdf)

## Demonstration

### Prerequisites

 * CMake v3.1+ though older versions might work
 * A working C/C++ compiler
 * git

### Setting things up

#### Creating a Work Directory

```sh
mkdir -p $HOME/OpenCL-Layers-Tutorial-Folder
export CL_LAYERS_TUT_BASE=$HOME/OpenCL-Layers-Tutorial-Folder
cd $CL_LAYERS_TUT_BASE
```

#### Getting OpenCL Headers

```sh
git clone https://github.com/KhronosGroup/OpenCL-Headers.git
export OPENCL_HEADERS_DIR=$CL_LAYERS_TUT_BASE/OpenCL-Headers
```

### Building an OpenCL ICD Loader

For layer support in the OpenCL ICD Loader, you need an up-to-date loader. The tip of master of [https://github.com/KhronosGroup/OpenCL-ICD-Loader](https://github.com/KhronosGroup/OpenCL-ICD-Loader) or [ocl-icd](https://github.com/OCL-dev/ocl-icd) v2.3.0+. In this tutorial we will be using the official Khronos Loader:

```sh
git clone https://github.com/Kerilk/OpenCL-ICD-Loader
export OPENCL_ICD_LOADER_DIR=$CL_LAYERS_TUT_BASE/OpenCL-ICD-Loader
cd "$OPENCL_ICD_LOADER_DIR"
ln -sf "$OPENCL_HEADERS_DIR/CL" inc
mkdir -p build && cd build
cmake ..
cmake --build .
```


