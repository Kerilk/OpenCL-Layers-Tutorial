#define CL_TARGET_OPENCL_VERSION 300
#define CL_USE_DEPRECATED_OPENCL_1_0_APIS
#define CL_USE_DEPRECATED_OPENCL_1_1_APIS
#define CL_USE_DEPRECATED_OPENCL_1_2_APIS
#define CL_USE_DEPRECATED_OPENCL_2_0_APIS
#define CL_USE_DEPRECATED_OPENCL_2_1_APIS
#define CL_USE_DEPRECATED_OPENCL_2_2_APIS
#include <CL/cl_layer.h>

CL_API_ENTRY cl_int CL_API_CALL clGetLayerInfo(
    cl_layer_info  param_name,
    size_t         param_value_size,
    void          *param_value,
    size_t        *param_value_size_ret) {
  if (param_value_size && !param_value)
    return CL_INVALID_VALUE;
  switch (param_name) {
  case CL_LAYER_API_VERSION:
    if (param_value) {
      if (param_value_size < sizeof(cl_layer_api_version))
        return CL_INVALID_VALUE;
      *((cl_layer_api_version *)param_value) = CL_LAYER_API_VERSION_100;
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_layer_api_version);
    break;
  default:
    return CL_INVALID_VALUE;
  }
  return CL_SUCCESS;
}

static struct _cl_icd_dispatch dispatch;
static const struct _cl_icd_dispatch *tdispatch;
static void _init_dispatch();
CL_API_ENTRY cl_int CL_API_CALL clInitLayer(
    cl_uint                         num_entries,
    const struct _cl_icd_dispatch  *target_dispatch,
    cl_uint                        *num_entries_out,
    const struct _cl_icd_dispatch **layer_dispatch_ret) {
  if (!target_dispatch || !num_entries_out || !layer_dispatch_ret)
    return CL_INVALID_VALUE;
  /* Check that the loader does not provide us with a dispatch table
   * smaller than the one we've been compiled with. */
  if(num_entries < sizeof(dispatch)/sizeof(dispatch.clGetPlatformIDs))
    return CL_INVALID_VALUE;

  tdispatch = target_dispatch;
  _init_dispatch();
  *layer_dispatch_ret = &dispatch;
  *num_entries_out = sizeof(dispatch)/sizeof(dispatch.clGetPlatformIDs);
  return CL_SUCCESS;
}

#include <stdio.h>
static CL_API_ENTRY cl_int CL_API_CALL clGetPlatformIDs_wrap(
    cl_uint num_entries,
    cl_platform_id* platforms,
    cl_uint* num_platforms) {
  fprintf(stderr, "clGetPlatformIDs(num_entries: %d, platforms: %p, num_platforms: %p)\n",
          num_entries, platforms, num_platforms);
  cl_int res = tdispatch->clGetPlatformIDs(num_entries, platforms, num_platforms);
  fprintf(stderr, "clGetPlatformIDs result: %d", res);
  if (res == CL_SUCCESS && num_platforms)
    fprintf(stderr, ", *num_platforms: %d", *num_platforms);
  fprintf(stderr, "\n");
  return res;
}

static void _init_dispatch() {
  dispatch.clGetPlatformIDs = &clGetPlatformIDs_wrap;
}
