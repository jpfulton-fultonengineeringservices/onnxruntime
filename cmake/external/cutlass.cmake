include(FetchContent)
onnxruntime_fetchcontent_declare(
  cutlass
  URL ${DEP_URL_cutlass}
  URL_HASH SHA1=${DEP_SHA1_cutlass}
  EXCLUDE_FROM_ALL
)

FetchContent_GetProperties(cutlass)
if(NOT cutlass_POPULATED)
  FetchContent_Populate(cutlass)
  # CUTLASS 3.5.1's cuda_host_adapter.hpp checks (__CUDACC_VER_MAJOR__ >= 12 &&
  # __CUDACC_VER_MINOR__ >= 5) to decide whether to use cudaGetDriverEntryPointByVersion.
  # CUDA 13.0 has major=13, minor=0, so the condition evaluates to false and falls back to
  # the older path that casts to PFN_cuTensorMapEncodeTiled (unversioned) — which CUDA 13
  # no longer defines.  Patch the condition to also accept CUDA major >= 13.
  set(_cutlass_adapter "${cutlass_SOURCE_DIR}/include/cutlass/cuda_host_adapter.hpp")
  if (EXISTS "${_cutlass_adapter}")
    execute_process(
      COMMAND sed -i
        "s|(__CUDACC_VER_MAJOR__ >= 12 && __CUDACC_VER_MINOR__ >= 5)|(__CUDACC_VER_MAJOR__ > 12 || (__CUDACC_VER_MAJOR__ == 12 \&\& __CUDACC_VER_MINOR__ >= 5))|g"
        "${_cutlass_adapter}"
    )
  endif()
endif()
