#=============================================================================#
# generate_library
# [PUBLIC/USER]
#       Generate user libraryr from sources
#
#
#   BOARD - board id
#   BOARD_CPU - board cpu id
#   SRCS <..> - lib sources list
#   HDRS <..> - lib headers list
#   [NO_AUTOLIBS] - do not parse sources for Arduino SDK library includes
#   [LIBS] <..> - Arduino SDK lib names if NO_AUTOLIBS provided
#
#=============================================================================#
function(generate_library INPUT_NAME)
    message(STATUS "Generating Library ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS"                         # Options
            "BOARD;BOARD_CPU"                     # One Value Keywords
            "SRCS;HDRS;LIBS"                      # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_BOARD_CPU AND ARDUINO_DEFAULT_BOARD_CPU)
        set(INPUT_BOARD_CPU ${ARDUINO_DEFAULT_BOARD_CPU})
    endif ()

    if (NOT INPUT_NO_AUTOLIBS)
        set(INPUT_NO_AUTOLIBS FALSE)
    else ()
        if (NOT INPUT_LIBS)
            message(FATAL_ERROR "No lib names specified with LIBS: ${LIBS}")
        endif ()
    endif ()
    validate_variables_not_empty(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    if (INPUT_NO_AUTOLIBS)
        find_arduino_libraries(TARGET_LIBS "" "${INPUT_LIBS}")
    else ()
        find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    endif ()

    set(LIB_DEP_INCLUDES)
    foreach (LIB_DEP ${TARGET_LIBS})
        list(APPEND LIB_DEP_INCLUDES ${LIB_DEP})
    endforeach ()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    add_library(${INPUT_NAME} ${ALL_SRCS})
    target_include_directories(${INPUT_NAME} PUBLIC ${LIB_DEP_INCLUDES})
endfunction()

# TODO DOC
# make better
function(generate_inplace_library INPUT_NAME)
    message(STATUS "Generating user Library ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS"                  # Options
            "BOARD;BOARD_CPU;DIR"          # One Value Keywords
            ""                             # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_BOARD_CPU AND ARDUINO_DEFAULT_BOARD_CPU)
        set(INPUT_BOARD_CPU ${ARDUINO_DEFAULT_BOARD_CPU})
    endif ()

    if (NOT INPUT_NO_AUTOLIBS)
        set(INPUT_NO_AUTOLIBS FALSE)
    endif ()
    validate_variables_not_empty(VARS INPUT_DIR INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)

    set(ALL_LIBS)

    get_filename_component(LIB_NAME ${INPUT_DIR} NAME)
    get_filename_component(LIB_BASE_PATH ${INPUT_DIR} PATH)
    set_directory_properties(PROPERTIES LIBRARY_SEARCH_PATH ${LIB_BASE_PATH})

    find_libs(LIB_PATH ${LIB_NAME})

    set(LIB_DEP_INCLUDES)
    find_sources(ALL_SRCS ${LIB_PATH} TRUE)
    add_library(${INPUT_NAME} "${ALL_SRCS}")
    foreach (LIB_DEP ${ARDUINO_LIBS})
        list(APPEND LIB_DEP_INCLUDES ${LIB_DEP})
        target_include_directories(${INPUT_NAME} PUBLIC ${LIB_DEP_INCLUDES})
        list(APPEND ALL_LIBS ${LIB_NAME})
    endforeach ()
endfunction()
