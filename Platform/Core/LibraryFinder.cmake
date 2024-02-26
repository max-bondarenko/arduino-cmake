#=============================================================================#
# find_arduino_libraries
# [PRIVATE/INTERNAL]
#
# find_arduino_libraries(VAR_NAME SRCS ARDLIBS)
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analized
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
#
#  Also adds Arduino libraries specifically names in ALIBS.  We add ".h" to the
#  names and then process them just like the Arduino libraries found in the sources.
#
#  A Arduino library is a folder that has the same name as the include header.
#  For example, if we have a include "#include <LibraryName.h>" then the following
#  directory structure is considered a Arduino library:
#
#     LibraryName/
#                src/ <-- optional
#                    |- LibraryName.h
#                    `- LibraryName.c
#
#  If such a directory is found then all sources within that directory are considered
#  to be part of that Arduino library.
#
#=============================================================================#
function(find_arduino_libraries VAR_NAME SRCS ARDLIBS)
    #    include(CheckPathExistsCaseSensitive)
    set(ARDUINO_LIBS)
    if (ARDLIBS) # Libraries are known in advance, just find their absoltue paths
        find_libs(ARDUINO_LIBS "${ARDLIBS}")
    else ()
        find_in_srcs(ARDUINO_LIBS "${SRCS}")
    endif ()
    if (ARDUINO_LIBS)
        list(REMOVE_DUPLICATES ARDUINO_LIBS)
    endif ()
    _remove_blacklisted_libraries("${ARDUINO_LIBS}" FILTERED_LIBRARIES)
    set(${VAR_NAME} "${FILTERED_LIBRARIES}" PARENT_SCOPE)
endfunction()

#=============================================================================#
# find_arduino_libraries
# [PRIVATE/INTERNAL]
#
# find_libs(VAR_NAME ARDLIBS)
#
#      VAR_NAME - Variable name which will hold the results
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#
#=============================================================================#
function(find_libs RET_LIBS_NAME ARDLIBS)
    set(RET_LIBS) # may called with same parent scope
    set(CMAKE_FIND_DEBUG_MODE TRUE)

    get_property(LIBRARY_SEARCH_PATH
            DIRECTORY     # Property Scope
            PROPERTY LIBRARY_SEARCH_PATH)
    message(STATUS ${LIBRARY_SEARCH_PATH})
    # TODO why it not work on first run
    foreach (LIB ${ARDLIBS})
        find_file(LIB_PATH
                NAMES ${LIB}/src/${LIB}.h ${LIB}/${LIB}.h
                HINTS ${CMAKE_SOURCE_DIR} ${LIBRARY_SEARCH_PATH}
                PATHS ${ARDUINO_PLATFORM_LIBRARIES_PATH}
                NO_CACHE
                NO_CMAKE_ENVIRONMENT_PATH
                NO_SYSTEM_ENVIRONMENT_PATH)

        if (LIB_PATH)
            get_filename_component(LIB_PATH ${LIB_PATH} PATH)
            list(APPEND RET_LIBS ${LIB_PATH})
            unset(LIB_PATH)
        endif ()
    endforeach ()
    set(CMAKE_FIND_DEBUG_MODE FALSE)
    set(${RET_LIBS_NAME} "${RET_LIBS}" PARENT_SCOPE)
endfunction()

#=============================================================================#
# find_in_srcs
# [PRIVATE/INTERNAL]
#
# find_arduino_libraries(VAR_NAME SRCS )
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analyzed
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries .
# TODO add in  ${CMAKE_CURRENT_SOURCE_DIR}
#=============================================================================#
function(find_in_srcs VAR_NAME SRC_LIST)
    if (SRC_LIST)
        if (CMAKE_HOST_UNIX)
            # fail if SRC_LIST is to long, especially with abs paths
            execute_process(COMMAND grep -iohE --max-count 20 "^\\s*#\\s*include\\s+[<\"][^<>\"]+[>\"]" ${SRC_LIST}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    TIMEOUT 3
                    OUTPUT_VARIABLE RESULT
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    )
            if (RESULT)
                string(REPLACE "\n" ";" RESULT ${RESULT})
            endif ()
        endif ()

        foreach (SRC ${RESULT})
            # HERE
            foreach (SRC_LINE ${RESULT})
                if ("${SRC_LINE}" MATCHES "[<\"]([^>\"]+)[>\"]")
                    get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                    find_libs(LIBS ${INCLUDE_NAME})
                    list(APPEND ARDUINO_LIBS ${LIBS})
                endif ()
            endforeach ()
            # todo ??? this
            #        # Skipping generated files. They are, probably, not exist yet.
            #        # : Maybe it's possible to skip only really nonexisting files,
            #        # but then it wiil be less deterministic.
            #        get_source_file_property(_srcfile_generated ${SRC} GENERATED)
            #        # Workaround for sketches, which are marked as generated
            #        get_source_file_property(_sketch_generated ${SRC} GENERATED_SKETCH) # TODO fix it
            #
            #        if (NOT ${_srcfile_generated} OR ${_sketch_generated})
            #            _check_path_exists_case_sensitive(exists_case_sensitive_1 "${SRC}")
            #            _check_path_exists_case_sensitive(exists_case_sensitive_2 "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
            #            _check_path_exists_case_sensitive(exists_case_sensitive_3 "${CMAKE_CURRENT_BINARY_DIR}/${SRC}")
            #
            #            if (NOT (exists_case_sensitive_1 OR
            #                    exists_case_sensitive_2 OR
            #                    exists_case_sensitive_3))
            #                message(FATAL_ERROR "Invalid source file: ${SRC}")
            #            endif ()
            #            #HERE
            #
            #
            #        endif ()
        endforeach ()
    endif ()
    set(${VAR_NAME} "${ARDUINO_LIBS}" PARENT_SCOPE)
endfunction()