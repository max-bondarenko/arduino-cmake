#=============================================================================#
# find_sources
# [PRIVATE/INTERNAL]
#
# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#       EXCLUDE_PATTERN - obviouse
#
# Finds all C/C++ sources located at the specified path.
#
#=============================================================================#
function(find_sources VAR_NAME LIB_PATH RECURSE )
#    set(OPTIONAL_ARGUMENTS ${ARGN})
#    list(LENGTH OPTIONAL_ARGUMENTS ARGC)
#    if (${ARGC} GREATER 0)
#        list(GET OPTIONAL_ARGUMENTS 0 EXCLUDE_PATTERN)
#    endif ()

    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.cpp
            ${LIB_PATH}/*.c
            ${LIB_PATH}/*.cc
            ${LIB_PATH}/*.cxx
            ${LIB_PATH}/*.[sS]
            )

    if (RECURSE)
        file(GLOB_RECURSE SOURCE_FILES ${FILE_SEARCH_LIST})
    else ()
        file(GLOB SOURCE_FILES ${FILE_SEARCH_LIST})
    endif ()

    # MEANX filter out examples and extra
    foreach (file ${SOURCE_FILES})
        if ((${file} MATCHES ".*/examples/.*") OR (${file} MATCHES ".*/extra/.*") OR (${file} MATCHES ".*/Template/.*"))
            message(VERBOSE "${file} skipped")
        else ()
            list(APPEND SOURCE_FILES2 ${file})
        endif ()
    endforeach ()
    if (SOURCE_FILES2)
        set(${VAR_NAME} ${SOURCE_FILES2} PARENT_SCOPE)
    endif ()
endfunction()

#=============================================================================#
# find_headers
# [PRIVATE/INTERNAL]
#
# find_headers(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected headers
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ headers located at the specified path.
#
#=============================================================================#
function(find_headers VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.h
            ${LIB_PATH}/*.hh
            ${LIB_PATH}/*.hxx
            )

    if (RECURSE)
        file(GLOB_RECURSE HEADER_FILES ${FILE_SEARCH_LIST})
    else ()
        file(GLOB HEADER_FILES ${FILE_SEARCH_LIST})
    endif ()

    if (HEADER_FILES)
        set(${VAR_NAME} ${HEADER_FILES} PARENT_SCOPE)
    endif ()
endfunction()

