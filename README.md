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
  Platform Extensions                             cl_khr_byte_addressable_store cl_khr_fp16 cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_icd cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_intel_command_queue_families cl_intel_subgroups cl_intel_required_subgroup_size cl_intel_subgroups_short cl_khr_spir cl_intel_accelerator cl_intel_driver_diagnostics cl_khr_priority_hints cl_khr_throttle_hints cl_khr_create_command_queue cl_intel_subgroups_char cl_intel_subgroups_long cl_khr_il_program cl_intel_mem_force_host_memory cl_khr_subgroup_extended_types cl_khr_subgroup_non_uniform_vote cl_khr_subgroup_ballot cl_khr_subgroup_non_uniform_arithmetic cl_khr_subgroup_shuffle cl_khr_subgroup_shuffle_relative cl_khr_subgroup_clustered_reduce cl_khr_subgroups cl_intel_spirv_device_side_avc_motion_estimation cl_intel_spirv_media_block_io cl_intel_spirv_subgroups cl_khr_spirv_no_integer_wrap_decoration cl_intel_unified_shared_memory_preview cl_khr_mipmap_image cl_khr_mipmap_image_writes cl_intel_planar_yuv cl_intel_packed_yuv cl_intel_motion_estimation cl_intel_device_side_avc_motion_estimation cl_intel_advanced_motion_estimation cl_khr_int64_base_atomics cl_khr_int64_extended_atomics cl_khr_image2d_from_buffer cl_khr_depth_images cl_khr_3d_image_writes cl_intel_media_block_io cl_intel_va_api_media_sharing cl_intel_subgroup_local_block_io 
  Platform Extensions with Version                cl_khr_byte_addressable_store                                    0x400000 (1.0.0)
                                                  cl_khr_fp16                                                      0x400000 (1.0.0)
                                                  cl_khr_global_int32_base_atomics                                 0x400000 (1.0.0)
                                                  cl_khr_global_int32_extended_atomics                             0x400000 (1.0.0)

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
clGetPlatformInfo
clGetPlatformInfo
  Platform Extensions                             cl_khr_byte_addressable_store cl_khr_fp16 cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_icd cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_intel_command_queue_families cl_intel_subgroups cl_intel_required_subgroup_size cl_intel_subgroups_short cl_khr_spir cl_intel_accelerator cl_intel_driver_diagnostics cl_khr_priority_hints cl_khr_throttle_hints cl_khr_create_command_queue cl_intel_subgroups_char cl_intel_subgroups_long cl_khr_il_program cl_intel_mem_force_host_memory cl_khr_subgroup_extended_types cl_khr_subgroup_non_uniform_vote cl_khr_subgroup_ballot cl_khr_subgroup_non_uniform_arithmetic cl_khr_subgroup_shuffle cl_khr_subgroup_shuffle_relative cl_khr_subgroup_clustered_reduce cl_khr_subgroups cl_intel_spirv_device_side_avc_motion_estimation cl_intel_spirv_media_block_io cl_intel_spirv_subgroups cl_khr_spirv_no_integer_wrap_decoration cl_intel_unified_shared_memory_preview cl_khr_mipmap_image cl_khr_mipmap_image_writes cl_intel_planar_yuv cl_intel_packed_yuv cl_intel_motion_estimation cl_intel_device_side_avc_motion_estimation cl_intel_advanced_motion_estimation cl_khr_int64_base_atomics cl_khr_int64_extended_atomics cl_khr_image2d_from_buffer cl_khr_depth_images cl_khr_3d_image_writes cl_intel_media_block_io cl_intel_va_api_media_sharing cl_intel_subgroup_local_block_io 
clGetPlatformInfo
clGetPlatformInfo
  Platform Extensions with Version                cl_khr_byte_addressable_store                                    0x400000 (1.0.0)
                                                  cl_khr_fp16                                                      0x400000 (1.0.0)
                                                  cl_khr_global_int32_base_atomics                                 0x400000 (1.0.0)
                                                  cl_khr_global_int32_extended_atomics                             0x400000 (1.0.0)
```
