#=============================================================================#
# make_arduino_library
# [PRIVATE/INTERNAL]
#
# make_arduino_library(VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        LIB_PATH    - Path of the library
#        COMPILE_FLAGS - Compile flags
#        LINK_FLAGS    - Link flags
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#
#=============================================================================#
function(make_arduino_library VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)

    string(REGEX REPLACE "/src[/]?$" "" LIB_PATH_STRIPPED ${LIB_PATH})
    get_filename_component(LIB_NAME ${LIB_PATH_STRIPPED} NAME)
    set(TARGET_LIB_NAME ${BOARD_ID}_${LIB_NAME})

    # Detect if recursion is needed
    if (NOT DEFINED ${LIB_NAME}_RECURSE)
        set(${LIB_NAME}_RECURSE ${ARDUINO_CMAKE_RECURSION_DEFAULT})
    endif ()

    # As make_arduino_library is called recursively, LIB_SRCS and LIB_HDRS
    # might be defined in parent scope and must therefore be cleared.
    set(LIB_SRCS)
    set(LIB_HDRS)

    find_sources(LIB_SRCS ${LIB_PATH} TRUE)
    find_headers(LIB_HDRS ${LIB_PATH} FALSE)

    if (LIB_SRCS)
        if (NOT TARGET ${TARGET_LIB_NAME})
            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            set_board_flags(${TARGET_LIB_NAME} ${BOARD_ID} FALSE)

#            find_arduino_libraries(LIB_DEPS "${LIB_SRCS};${LIB_HDRS}" "")

            foreach (LIB_DEP ${LIB_DEPS})
                make_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP}
                        "${COMPILE_FLAGS}" "${LINK_FLAGS}")
                list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
                list(APPEND LIB_INCLUDES ${DEP_LIB_SRCS_INCLUDES})
            endforeach ()

            if (LIB_INCLUDES)
                string(REPLACE ";" " " LIB_INCLUDES_SPACE_SEPARATED "${LIB_INCLUDES}")
            endif ()
            if (${LIB_NAME}_EXTRA_CFLAGS)
                set(EXTRA ${${LIB_NAME}_EXTRA_CFLAGS})
                message(STATUS "Adding new flags for lib ${LIB_NAME}: ${EXTRA}")
            endif (${LIB_NAME}_EXTRA_CFLAGS)

            set_target_properties(${TARGET_LIB_NAME} PROPERTIES
                    COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${LIB_INCLUDES_SPACE_SEPARATED} -I\"${LIB_PATH}\" -I\"${LIB_PATH}/utility\" ${COMPILE_FLAGS} ${EXTRA}"
                    LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")
            list(APPEND LIB_INCLUDES "-I\"${LIB_PATH}\";-I\"${LIB_PATH}/utility\"")

            if (LIB_TARGETS)
                list(REMOVE_ITEM LIB_TARGETS ${TARGET_LIB_NAME})
            endif ()

            if (NOT ARDUINO_CMAKE_GENERATE_SHARED_LIBRARIES)
                # MEANX: this will duplicate core libs target_link_libraries(${TARGET_LIB_NAME} ${BOARD_ID}_CORE ${LIB_TARGETS})
            endif ()

        endif ()

        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

    else ()
        # Target not build due to lack of sources. However, the library might contain
        # headers.
        #
        list(APPEND LIB_INCLUDES "${LIB_PATH}")
    endif ()

    if (LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif ()
    if (LIB_INCLUDES)
        list(REMOVE_DUPLICATES LIB_INCLUDES)
    endif ()

    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
    set(${VAR_NAME}_INCLUDES ${LIB_INCLUDES} PARENT_SCOPE)

endfunction()

#=============================================================================#
# make_arduino_libraries
# [PRIVATE/INTERNAL]
#
# make_arduino_libraries(VAR_NAME BOARD_ID SRCS COMPILE_FLAGS LINK_FLAGS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        COMPILE_FLAGS - Compile flags
#        LINK_FLAGS    - Linker flags
#
# Finds and creates all dependency libraries based on sources.
#
#=============================================================================#
function(make_arduino_libraries VAR_NAME BOARD_ID ARDLIBS COMPILE_FLAGS LINK_FLAGS)

    set(LIB_TARGETS "")
    set(LIB_INCLUDES "")

    foreach (TARGET_LIB ${ARDLIBS})
        # Create static library instead of returning sources
        make_arduino_library(LIB_DEPS ${BOARD_ID} ${TARGET_LIB}
                "${COMPILE_FLAGS}" "${LINK_FLAGS}")
        list(APPEND LIB_TARGETS ${LIB_DEPS})
        list(APPEND LIB_INCLUDES ${LIB_DEPS_INCLUDES})
    endforeach ()

    list(REMOVE_DUPLICATES LIB_TARGETS)
    list(REMOVE_DUPLICATES LIB_INCLUDES)

    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
    set(${VAR_NAME}_INCLUDES ${LIB_INCLUDES} PARENT_SCOPE)
endfunction()
