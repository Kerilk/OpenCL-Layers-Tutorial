# Tutorial for OpenCL Layers

## Presentation

Presentation: [LayersForOpenCL.pdf](https://github.com/Kerilk/OpenCL-Layers-Tutorial/blob/main/presentation/LayersForOpenCL.pdf)

## Demonstration

### Prerequisites

 * CMake v3.1+ though older versions might work
 * A working C/C++ compiler
 * git
 * an installed OpenCL driver

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

#### Building an OpenCL ICD Loader

For layer support in the OpenCL ICD Loader, you need an up-to-date loader. The tip of master of [https://github.com/KhronosGroup/OpenCL-ICD-Loader](https://github.com/KhronosGroup/OpenCL-ICD-Loader) or [ocl-icd](https://github.com/OCL-dev/ocl-icd) v2.3.0+. In this tutorial we will be using the official Khronos Loader:

```sh
git clone https://github.com/Kerilk/OpenCL-ICD-Loader.git
export OPENCL_ICD_LOADER_DIR=$CL_LAYERS_TUT_BASE/OpenCL-ICD-Loader
cd $OPENCL_ICD_LOADER_DIR
ln -sf $OPENCL_HEADERS_DIR/CL inc
mkdir -p build && cd build
cmake ..
cmake --build .
export LIBRARY_PATH=$OPENCL_ICD_LOADER_DIR/build:$LIBRARY_PATH
export LD_LIBRARY_PATH=$OPENCL_ICD_LOADER_DIR/build:$LD_LIBRARY_PATH
```

#### Building clinfo

An up-to-date `clinfo` is better, so we will be building it also:
```sh
cd $CL_LAYERS_TUT_BASE
git clone https://github.com/Oblomov/clinfo.got
export CLINFO_DIR=$CL_LAYERS_TUT_BASE/clinfo
cd $CLINFO_DIR
make
```

#### Testing the Loader and clinfo

```sh
$CLINFO_DIR/clinfo
```

If you have a recent Intel GPU and OpenCL driver, it should output:
```
Number of platforms                               1
  Platform Name                                   Intel(R) OpenCL HD Graphics
  Platform Vendor                                 Intel(R) Corporation
  Platform Version                                OpenCL 3.0 
  Platform Profile                                FULL_PROFILE
```

We can test layer support using the test layer provided with the ICD loader:
```sh
OPENCL_LAYERS=$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so $CLINFO_DIR/clinfo
```

The output of `clinfo` should be changed:
```
clGetPlatformIDs
Number of platforms                               1
clGetPlatformIDs
clGetPlatformInfo
clGetPlatformInfo
  Platform Name                                   Intel(R) OpenCL HD Graphics
clGetPlatformInfo
clGetPlatformInfo
  Platform Vendor                                 Intel(R) Corporation
clGetPlatformInfo
clGetPlatformInfo
  Platform Version                                OpenCL 3.0 
clGetPlatformInfo
clGetPlatformInfo
  Platform Profile                                FULL_PROFILE
```

### Getting Example Layers

#### Building the Layer from the Presentation

First we can build the demonstration layer fron the presentation:

```sh
cd $CL_LAYERS_TUT_BASE
git clone git@github.com:Kerilk/OpenCL-Layers-Tutorial.git
export OPENCL_LAYERS_TUTORIAL_DIR=$CL_LAYERS_TUT_BASE/OpenCL-Layers-Tutorial
cd $OPENCL_LAYERS_TUTORIAL_DIR/presentation
mkdir -p build && cd build
cmake -DOPENCL_HEADER_PATH="$OPENCL_HEADERS_DIR" ..
cmake --build .
```

This generated a `libExampleLayer.so` that we can use with clinfo:
```sh
OPENCL_LAYERS=$OPENCL_LAYERS_TUTORIAL_DIR/presentation/build/libExampleLayer.so $CLINFO_DIR/clinfo
```

This time, the output is:
```
clGetPlatformIDs(num_entries: 0, platforms: (nil), num_platforms: 0x7ffd55c9f180)
clGetPlatformIDs result: 0, *num_platforms: 1
Number of platforms                               1
clGetPlatformIDs(num_entries: 1, platforms: 0x56216202d4d0, num_platforms: (nil))
clGetPlatformIDs result: 0
  Platform Name                                   Intel(R) OpenCL HD Graphics
  Platform Vendor                                 Intel(R) Corporation
  Platform Version                                OpenCL 3.0 
  Platform Profile                                FULL_PROFILE
```

We can also combine both layers:

```sh
OPENCL_LAYERS="$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so":"$OPENCL_LAYERS_TUTORIAL_DIR/presentation/build/libExampleLayer.so" $CLINFO_DIR/clinfo
```

This yields:
```
clGetPlatformIDs(num_entries: 0, platforms: (nil), num_platforms: 0x7ffebcf7a860)
clGetPlatformIDs
clGetPlatformIDs result: 0, *num_platforms: 1
Number of platforms                               1
clGetPlatformIDs(num_entries: 1, platforms: 0x55aa6855b4d0, num_platforms: (nil))
clGetPlatformIDs
clGetPlatformIDs result: 0
clGetPlatformInfo
clGetPlatformInfo
  Platform Name                                   Intel(R) OpenCL HD Graphics
clGetPlatformInfo
clGetPlatformInfo
  Platform Vendor                                 Intel(R) Corporation
clGetPlatformInfo
clGetPlatformInfo
  Platform Version                                OpenCL 3.0 
clGetPlatformInfo
clGetPlatformInfo
  Platform Profile                                FULL_PROFILE
```
As we can see the simple prin layer is called between the entry and the exit of the example layer.
We can reverse this order by changing the order of the layers on the command line:

```sh
OPENCL_LAYERS="$OPENCL_LAYERS_TUTORIAL_DIR/presentation/build/libExampleLayer.so":"$OPENCL_ICD_LOADER_DIR/build/test/layer/libPrintLayer.so" $CLINFO_DIR/clinfo
```

As we can witness, the result changes as expected:
```
clGetPlatformIDs
clGetPlatformIDs(num_entries: 0, platforms: (nil), num_platforms: 0x7ffd078e4910)
clGetPlatformIDs result: 0, *num_platforms: 1
Number of platforms                               1
clGetPlatformIDs
clGetPlatformIDs(num_entries: 1, platforms: 0x556fda8dc4d0, num_platforms: (nil))
clGetPlatformIDs result: 0
clGetPlatformInfo
clGetPlatformInfo
  Platform Name                                   Intel(R) OpenCL HD Graphics
clGetPlatformInfo
clGetPlatformInfo
  Platform Vendor                                 Intel(R) Corporation
clGetPlatformInfo
clGetPlatformInfo
  Platform Version                                OpenCL 3.0 
clGetPlatformInfo
clGetPlatformInfo
  Platform Profile                                FULL_PROFILE
```

#### Example Layers

```sh
cd $CL_LAYERS_TUT_BASE
git clone git@github.com:Kerilk/OpenCL-Layers.git
export OPENCL_LAYERS_DIR=$CL_LAYERS_TUT_BASE/OpenCL-Layers
cd $OPENCL_LAYERS_DIR
ln -sf $OPENCL_HEADERS_DIR/CL inc
mkdir -p build && cd build
cmake ..
cmake --build .
```
