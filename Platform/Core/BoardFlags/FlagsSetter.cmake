macro(DBG)
    message(STATUS ${ARGN})
endmacro(DBG)

macro(add_if_defined key)
    dbg("Checking ${key}")
    _try_get_board_property(${BOARD_ID} ${key} _var)
    if (_var)
        dbg("Yes ${key}: ${_var}")
        list(APPEND flags ${_var})
    endif ()
endmacro()

macro(add_to_compile_flags key prefix)
    dbg("Checking ${key}")
    _try_get_board_property(${BOARD_ID} ${key} _var)
    if (_var)
        dbg("Yes ${key}: ${_var}")
        list(APPEND flags ${prefix}${_var})
    endif ()
endmacro()
#=============================================================================#
# _sanitize_quotes
# [PRIVATE/INTERNAL]
#
# _sanitize_quotes(CMD_LINE_VARIABLE)
#
#       CMD_LINE_VARIABLE - Variable holding a shell command line
#                           or command line flag(s) that potentially
#                           require(s) quotes to be fixed.
#
# Replaces Unix-style quotes with Windows-style quotes.
# '-DSOME_MACRO="foo"' would become "-DSOME_MACRO=\"foo\"".
#
#=============================================================================#
function(_sanitize_quotes CMD_LINE_VARIABLE)
    if (CMAKE_HOST_WIN32)

        # Important: The order of the statements below does matter!

        # First replace all occurences of " with \"
        #
        string(REPLACE "\"" "\\\"" output "${${CMD_LINE_VARIABLE}}")

        # Then replace all ' with "
        #
        string(REPLACE "'" "\"" output "${output}")

        set(${CMD_LINE_VARIABLE} "${output}" PARENT_SCOPE)
    endif ()
endfunction()

# ToDo: Comment
function(set_board_compiler_flags COMPILER_FLAGS BOARD_ID IS_MANUAL)
    set(flags)

    set(ARDUINO_ARCH ${CMAKE_SYSTEM_PROCESSOR})
    string(TOUPPER ${ARDUINO_ARCH} ARDUINO_ARCH)
    list(APPEND flags ARDUINO_ARCH_${ARDUINO_ARCH}) # TODO !!
    include(${ARDUINO_CMAKE_TOP_FOLDER}/Platform/Core/BoardFlags/CompilerFlagsSetter_${CMAKE_SYSTEM_PROCESSOR}.cmake)

    message(FATAL_ERROR ${flags})
    _try_get_board_property(${BOARD_ID} build.vid VID)
    _try_get_board_property(${BOARD_ID} build.pid PID)

    add_if_defined(build.pid USB_PID=)
    add_if_defined(build.vid USB_VID=)

    _try_get_board_property(${BOARD_ID} build.extra_flags EXTRA_FLAGS)
    if ("${EXTRA_FLAGS}")
        _sanitize_quotes(EXTRA_FLAGS)
        list(APPEND flags ${EXTRA_FLAGS})
    endif ()
    # TODO this does not substitute usb flags form platform !! fix
    #    _try_get_board_property(${BOARD_ID} build.usb_flags USB_FLAGS)
    #    if (NOT "${USB_FLAGS}" STREQUAL "")
    #        _sanitize_quotes(USB_FLAGS)
    #        set(COMPILE_FLAGS "${COMPILE_FLAGS} ${USB_FLAGS}")
    #    endif ()

    if (NOT IS_MANUAL)
        _get_board_property(${BOARD_ID} build.core BOARD_CORE)
        #        no -I manually
        #        set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${${BOARD_CORE}.path}\" -I\"${${CMAKE_SYSTEM_PROCESSOR}_LIBRARIES_PATH}\"") # TODO _PATH
        if (${${CMAKE_SYSTEM_PROCESSOR}_PLATFORM_LIBRARIES_PATH})
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${${CMAKE_SYSTEM_PROCESSOR}_PLATFORM_LIBRARIES_PATH}\"")
        endif ()
    endif ()
    if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0 OR ARDUINO_SDK_VERSION VERSION_EQUAL 1.0)
        if (NOT IS_MANUAL)
            _get_board_property(${BOARD_ID} build.variant VARIANT)
            set(PIN_HEADER ${${VARIANT}.path}) # should resolve to path but not
            if (PIN_HEADER)
                #                set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${PIN_HEADER}\"") TODO no -I FIX
            endif ()
        endif ()
    endif ()

    set(${COMPILER_FLAGS} "${COMPILE_FLAGS}" PARENT_SCOPE)

endfunction()

# ToDo: Comment
function(set_board_linker_flags LINKER_FLAGS BOARD_ID IS_MANUAL)
    include(${ARDUINO_CMAKE_TOP_FOLDER}/Platform/Core/BoardFlags/LinkerFlagsSetter_${CMAKE_SYSTEM_PROCESSOR}.cmake)
endfunction()

#=============================================================================#
# set_board_flags
# [PRIVATE/INTERNAL]
#
# set_board_flags(TARGET_NAME BOARD_ID IS_MANUAL)
#
#       TARGET_NAME - lib_name definitions be added
#       BOARD_ID - The board id name
#       IS_MANUAL - (Advanced) Only use AVR Libc/Includes
#
# Configures the build settings for the specified Arduino Board.
#
#=============================================================================#
function(set_board_flags TARGET_NAME BOARD_ID IS_MANUAL)
    set(flags)
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)
    _get_board_property(${BOARD_ID} build.board BOARD)
    list(APPEND flags ARDUINO=${NORMALIZED_SDK_VERSION})

    if (BOARD_CORE)
        if (CMAKE_SYSTEM_PROCESSOR STREQUAL "avr")
            _get_board_property(${BOARD_ID} build.f_cpu FCPU)
            _get_board_property(${BOARD_ID} build.mcu MCU)
            _get_board_property(${BOARD_ID} build.board BOARD)

            list(APPEND flags F_CPU=${FCPU})

            add_compile_options(-mmcu=${MCU})
            set(CMAKE_C_FLAGS "-mmcu=${MCU}")
            set(CMAKE_CXX_FLAGS "-mmcu=${MCU}" PARENT_SCOPE) # TODO hack

            list(APPEND flags ARDUINO_ARCH_AVR)
            list(APPEND flags ARDUINO_${BOARD})
        elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "stm32")
            #                                         TODO check -v- put it for test
            _try_get_board_property(${BOARD_ID} menu.cpu.${BOARD_CPU}.build.flags TRY_CPU_FLAGS)
            if (TRY_CPU_FLAGS)
                list(APPEND flags ${TRY_CPU_FLAGS})
            else ()
                _try_get_board_property(${BOARD_ID} build.flags TRY_CPU_FLAGS)
                if (TRY_CPU_FLAGS)
                    list(APPEND flags ${TRY_CPU_FLAGS})
                endif ()
            endif ()

            # dont set the mcu speed, it is done elsewhere
            # set(COMPILE_FLAGS "-DF_CPU=${FCPU} ${CPU_FLAGS} -D")

            add_if_defined(build.vect)
            add_if_defined(build.series)
            add_if_defined(menu.cpu.${ARDUINO_UPLOAD_METHOD}Method.build.vect)

            # upload flags if any
            add_if_defined(menu.cpu.${ARDUINO_UPLOAD_METHOD}Method.build.upload_flags)

            if (DEFINED menu.cpu.${ARDUINO_CPU}.build.cpu_flags)
                dbg("Yes ${key}: ${${BOARD_ID}.${key}}")
                list(APPEND flags ${${BOARD_ID}.${key}})
            endif ()

            add_to_compile_flags(build.error_led_port "ERROR_LED_PORT=")
            add_to_compile_flags(build.error_led_pin "ERROR_LED_PIN=")

            add_compile_definitions(ARDUINO_ARCH_STM32)
        endif ()
        target_compile_definitions(${TARGET_NAME} PUBLIC ${flags})
        # TODO        set_board_linker_flags(LINK_FLAGS ${BOARD_ID} ${IS_MANUAL})
    else ()
        message(FATAL_ERROR "Invalid Arduino board ID (${BOARD_ID}), aborting.")
    endif ()

endfunction()

