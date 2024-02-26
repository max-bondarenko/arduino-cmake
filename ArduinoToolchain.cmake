set(CMAKE_SYSTEM_NAME Arduino)
set(CMAKE_SYSTEM_VERSION 1.0)
set(BUILD_SHARED_LIBS OFF CACHE INTERNAl "Arduino do not use SHARED libs")

set(PLATFORM "arduino" CACHE STRING "Arduino SDK platform")
if (DEFINED PLATFORM_PATH AND DEFINED PLATFORM_TOOLCHAIN_PATH)
    MESSAGE(STATUS "Skip setup in SubBuild")
    return()
endif ()

# Add current directory to CMake Module path automatically
if (NOT DEFINED ARDUINO_CMAKE_TOP_FOLDER)
    if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/Platform/Arduino.cmake)
        set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
    endif ()
    set(ARDUINO_CMAKE_TOP_FOLDER ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
endif ()

macro(fatal_banner msg)
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "${msg}")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(FATAL_ERROR)
endmacro()

#=============================================================================#
#                         System Paths                                        #
#=============================================================================#
if (CMAKE_HOST_UNIX)
    include(Platform/UnixPaths)
    if (CMAKE_HOST_APPLE)
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH ~/Applications
                /Applications
                /Developer/Applications
                /sw        # Fink
                /opt/local) # MacPorts
    endif ()
elseif (CMAKE_HOST_WIN32)
    include(Platform/WindowsPaths)
endif ()

#=============================================================================#
#                         Detect Arduino SDK                                  #
#=============================================================================#
if (CMAKE_HOST_UNIX)
    file(GLOB SDK_PATH_HINTS
            /usr/share/arduino*
            /opt/local/arduino*
            /opt/arduino*
            /usr/local/share/arduino*)
elseif (CMAKE_HOST_WIN32)
    set(SDK_PATH_HINTS
            "C:\\Program Files\\Arduino"
            "C:\\Program Files (x86)\\Arduino")
endif ()
list(SORT SDK_PATH_HINTS)

if (DEFINED ENV{ARDUINO_SDK_PATH})
    list(APPEND SDK_PATH_HINTS $ENV{ARDUINO_SDK_PATH})
endif ()

find_path(PATH
        NAMES lib/version.txt
        PATH_SUFFIXES share/arduino Arduino.app/Contents/Resources/Java/ Arduino.app/Contents/Java/
        HINTS ${SDK_PATH_HINTS})

if (EXISTS ${PATH})

    set(ARDUINO_SDK_PATH ${PATH} CACHE PATH "Arduino SDK base directory")

    if (NOT DEFINED PLATFORM_PATH)
        set(CMAKE_C_COMPILER_ID "GNU" CACHE INTERNAL "")
        set(CMAKE_SYSTEM_PROCESSOR "avr" CACHE INTERNAL "")

        # Work with Arduino SDK only
        set(PLATFORM_PATH ${PATH}/hardware/${PLATFORM}/${CMAKE_SYSTEM_PROCESSOR} CACHE PATH "Arduino platform path")
        set(PLATFORM_TOOLCHAIN_PATH ${PATH}/hardware/tools CACHE PATH "Arduino SDK base directory")

        set(CMAKE_C_COMPILER_HINTS ${PLATFORM_TOOLCHAIN_PATH}/avr)
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${PLATFORM_TOOLCHAIN_PATH}/avr)
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${PLATFORM_TOOLCHAIN_PATH}/avr/utils)
        set(_CMAKE_TOOLCHAIN_PREFIX avr-)
    endif ()
endif ()


if (DEFINED PLATFORM_PATH)
    set(_CMAKE_TOOLCHAIN_PREFIX arm-none-eabi-)
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

    file(GLOB PLATFORM_TOOLCHAIN_PATH_HINTS
            ${PLATFORM_PATH}/*
            ${TOOLCHAIN_PATH}/*
            )

    find_program(PLATFORM_TOOLCHAIN_GCC
            ${_CMAKE_TOOLCHAIN_PREFIX}gcc
            PATHS ${PLATFORM_TOOLCHAIN_PATH_HINTS}
            DOC "stm32 gcc"
            REQUIRED
            )

    find_program(PLATFORM_TOOLCHAIN_GPP
            ${_CMAKE_TOOLCHAIN_PREFIX}g++
            PATHS ${PLATFORM_TOOLCHAIN_PATH_HINTS}
            DOC "stm32 g++"
            REQUIRED
            )

    if (NOT DEFINED CMSIS_PATH)
        #       set(CMAKE_FIND_DEBUG_MODE TRUE)
        # TODO temporary huck
        find_file(CMSIS_PATH
                NAMES cmsis CMSIS
                PATHS ${PLATFORM_PATH}/.. ${PLATFORM_PATH}/../*
                PATH_SUFFIXES framework-*)
    endif ()
    if (NOT CMSIS_PATH)
        message(SEND_ERROR "CMSIS path for stm32 not found, please define\nset(CMSIS_PATH <math>)\n")
    endif ()

    #        set(CMAKE_FIND_DEBUG_MODE TRUE)
    get_filename_component(PATH ${PLATFORM_TOOLCHAIN_GCC} DIRECTORY)
    get_filename_component(PATH ${PATH} DIRECTORY)

    if (EXISTS ${PATH})
        #            list(APPEND CMAKE_LIBRARY_PATH ${PLATFORM_PATH}) # for lib.a search
        set(CMAKE_INCLUDE_PATH ${PLATFORM_PATH}/libraries CACHE INTERNAL "")
        set(PLATFORM_TOOLCHAIN_PATH ${PATH} CACHE PATH "" FORCE)
        set(CMAKE_C_COMPILER_HINTS ${PLATFORM_TOOLCHAIN_PATH}) # TODO ?
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH "${PLATFORM_TOOLCHAIN_PATH}")
    endif ()

    set(CMAKE_SYSTEM_PROCESSOR "stm32" CACHE STRING "Stm32 platform")
    set(ARDUINO_SDK_VERSION "1.8.6" CACHE STRING "Arduino SDK Version") # todo workaround
endif ()

set(CMAKE_LIBRARY_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT CACHE INTERNAL "")

if (NOT DEFINED PLATFORM_TOOLCHAIN_PATH)
    fatal_banner("NO platform specified")
endif ()

SET(CMAKE_VERBOSE_MAKEFILE BOOL CACHE TRUE "" FORCE)
#
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        CMAKE_SYSTEM_NAME
        ARDUINO_SDK_PATH
        ARDUINO_SDK_VERSION
        ARDUINO_PLATFORM_LIBRARIES_PATH
        ARDUINO_EXAMPLES_PATH
        CMAKE_CXX_COMPILER
        CMAKE_C_COMPILER
        CMAKE_ASM_COMPILER
        PLATFORM_PATH
        PLATFORM_TOOLCHAIN_PATH
        PLATFORM
        )
