MESSAGE(STATUS "ARDUINO DETERMINE C")
set(CMAKE_C_COMPILER ${_CMAKE_TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${_CMAKE_TOOLCHAIN_PREFIX}gcc)