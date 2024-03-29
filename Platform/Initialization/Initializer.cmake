#=============================================================================#
#                          Initialization
#=============================================================================#

#=============================================================================#
#                              C Flags
#=============================================================================#
include(${ARDUINO_CMAKE_TOP_FOLDER}/Platform/Initialization/DefaultCFlags_${CMAKE_SYSTEM_PROCESSOR}.cmake)

if (NOT DEFINED ARDUINO_C_FLAGS) # todo may be for adnv setup
    set(ARDUINO_C_FLAGS "${ARDUINO_DEFAULT_CFLAGS}" CACHE INTERNAL "")
endif ()

#set(CMAKE_C_FLAGS "-g -Os ${ARDUINO_C_FLAGS}" CACHE STRING "")
#set(CMAKE_C_FLAGS_DEBUG "-g" CACHE STRING "")
#set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG" CACHE STRING "")
#set(CMAKE_C_FLAGS_RELEASE "-Os -DNDEBUG -w" CACHE STRING "")
#set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -g -w " CACHE STRING "")

#=============================================================================#
#                             C++ Flags
#=============================================================================#
#=============================================================================#
# setup_c_flags
# [PRIVATE/INTERNAL]
#
# setup_cxx_flags()
#
# Setups some basic flags for the g++ compiler to use later.
#=============================================================================#
if (NOT DEFINED ARDUINO_CXX_FLAGS)
    if (DEFINED ARDUINO_DEFAULT_CXXFLAGS)
        set(ARDUINO_CXX_FLAGS "${ARDUINO_DEFAULT_CXXFLAGS}" CACHE INTERNAL "")
    else ()
        set(ARDUINO_CXX_FLAGS "${ARDUINO_C_FLAGS} -fno-exceptions" CACHE INTERNAL "")
    endif ()
endif ()

if (NOT DEFINED ARDUINO_LINKER_FLAGS)
    #    set(ARDUINO_LINKER_FLAGS "-nostdlib -lgcc -Wl,--gc-sections -lm ")
endif ()
SET(CMAKE_TRY_COMPILE_CONFIGURATION "Debug" CACHE STRING "")

#todo  this may depend on PLATFORM
set(${CMAKE_SYSTEM_PROCESSOR}_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load
        --no-change-warnings --change-section-lma .eeprom=0 CACHE STRING "")
set(${CMAKE_SYSTEM_PROCESSOR}_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom CACHE STRING "")
set(${CMAKE_SYSTEM_PROCESSOR}_AVRDUDE_FLAGS -V CACHE STRING "")

include(DetectVersion)
include(FindHardwarePlatform)
include(FindPrograms)

set(ARDUINO_LIBRARY_BLACKLIST "" CACHE STRING
        "A list of absolute paths to Arduino libraries that are meant to be ignored during library search")

if (ARDUINO_SDK_PATH)
    set(ARDUINO_CMAKE_RECURSION_DEFAULT True CACHE BOOL "Default Arduino lib recursion.")
    set(ARDUINO_DEFAULT_BOARD uno CACHE STRING "Default Arduino Board ID when not specified.")
    set(ARDUINO_DEFAULT_BOARD_CPU CACHE STRING "Default Arduino Board CPU when not specified.")
    set(ARDUINO_DEFAULT_PORT CACHE STRING "Default Arduino port when not specified.")
    set(ARDUINO_DEFAULT_SERIAL CACHE STRING "Default Arduino Serial command when not specified.")
    set(ARDUINO_DEFAULT_PROGRAMMER CACHE STRING "Default Arduino Programmer ID when not specified.")
    #    set(ARDUINO_CMAKE_RECURSION_DEFAULT FALSE CACHE BOOL "The default recursion behavior during library setup")
    # Ensure that all required paths are found
    validate_variables_not_empty(
            VARS ARDUINO_SDK_PATH
            MSG "Invalid Arduino SDK path (${ARDUINO_SDK_PATH}).\n")
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "avr")
        validate_variables_not_empty(VARS
                avr_CORES_PATH
                avr_BOOTLOADERS_PATH
                ARDUINO_PLATFORM_LIBRARIES_PATH
                avr_LIBS_PATH
                avr_BOARDS_PATH
                avr_PROGRAMMERS_PATH
                AVRSIZE_PROGRAM
                avr_AVRDUDE_PROGRAM
                avr_AVRDUDE_FLAGS
                avr_AVRDUDE_CONFIG_PATH
                MSG "Invalid Arduino SDK path (${PLATFORM_PATH}).\n"
                )
    else ()
        validate_variables_not_empty(VARS
                ${CMAKE_SYSTEM_PROCESSOR}_CORES_PATH
                ${CMAKE_SYSTEM_PROCESSOR}_BOOTLOADERS_PATH

                ${CMAKE_SYSTEM_PROCESSOR}_LIBS_PATH
                ${CMAKE_SYSTEM_PROCESSOR}_BOARDS_PATH
                ${CMAKE_SYSTEM_PROCESSOR}_PROGRAMMERS_PATH
                MSG "Invalid PLATFORM path (${PLATFORM_PATH}).\n"
                )
    endif ()
endif ()