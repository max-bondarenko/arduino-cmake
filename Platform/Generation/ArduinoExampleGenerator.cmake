#=============================================================================#
# generate_arduino_example
# [PUBLIC/USER]
#    CATEGORY      Optional name of the example's parent category, such as 'Basics' is for 'Blink'.
#    EXAMPLE
#    [PORT]
#    [PROGRAMMER]
#    BOARD - board id
#    BOARD_CPU - board cpu id
#    [NO_AUTOLIBS] - do not parse sources for Arduino SDK library includes
#    [LIBS] <..> - Arduino SDK lib names if NO_AUTOLIBS provided

#=============================================================================#
function(generate_arduino_example INPUT_NAME)
    parse_generator_arguments(${INPUT_NAME} INPUT
            ""                                                  # Options
            "CATEGORY;EXAMPLE;BOARD;BOARD_CPU;PORT;PROGRAMMER"  # One Value Keywords
            "SERIAL;AFLAGS"                                     # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_BOARD_CPU AND ARDUINO_DEFAULT_BOARD_CPU)
        set(INPUT_BOARD_CPU ${ARDUINO_DEFAULT_BOARD_CPU})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    validate_variables_not_empty(VARS INPUT_EXAMPLE INPUT_BOARD
            MSG "must define for target ${INPUT_NAME}")
    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)
    message(STATUS "Generating ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS)

    make_core_library(CORE_LIB ${BOARD_ID})

    make_arduino_example("${INPUT_NAME}" "${INPUT_EXAMPLE}" ALL_SRCS "${INPUT_CATEGORY}")

    if (NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif ()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES) # TODO use include not just -I
    foreach (LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    make_arduino_libraries(ALL_LIBS ${BOARD_ID} "${TARGET_LIBS}" "" "")

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    create_arduino_firmware_target(${INPUT_NAME} ${BOARD_ID} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" FALSE)
            message(FATAL_ERROR ${})
    if (INPUT_PORT)
        create_arduino_upload_target(${BOARD_ID} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        create_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()
endfunction()
