#=============================================================================#
# make_core_library
# [PRIVATE/INTERNAL]
#
# make_core_library(OUTPUT_VAR BOARD_ID)
#
#        OUTPUT_VAR - Variable name that will hold the generated library name
#        BOARD_ID - Arduino board id
#
# Creates the Arduino Core library for the specified board,
# each board gets it's own version of the library.
#
#=============================================================================#
function(make_core_library OUTPUT_VAR BOARD_ID)
    string(TOLOWER ${BOARD_ID} b_id)
    set(CORE_LIB_NAME core_${b_id})

    _get_board_property(${BOARD_ID} build.core BOARD_CORE)

    if (BOARD_CORE)
        if (NOT TARGET ${CORE_LIB_NAME})
            set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
            find_sources(CORE_SRCS ${BOARD_CORE_PATH} FALSE)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")

            # TODO HAL ??
            #find_sources(HAL_SRCS ${PLATFORM_PATH}/system/Drivers/STM32F1xx_HAL_Driver/Src FALSE)
            #find_sources(HAL2_SRCS ${PLATFORM_PATH}/system/STM32F1xx FALSE)
            #add_library(HAL ${HAL_SRCS};${HAL2_SRCS})

            include_directories(${BOARD_CORE_PATH})

            _try_get_board_property(${BOARD_ID} build.series BUILD_SERIES)
            if (BUILD_SERIES)
                include_directories(${PLATFORM_PATH}/system/${BUILD_SERIES}
                        ${PLATFORM_PATH}/system/Drivers/CMSIS/Device/ST/${BUILD_SERIES}/Include
                        ${PLATFORM_PATH}/system/Drivers/${BUILD_SERIES}_HAL_Driver/Inc)
            endif ()
            _try_get_board_property(${BOARD_ID} build.variant VARIANT)
            if (VARIANT)
                include_directories(${PLATFORM_PATH}/variants/${VARIANT})
            endif ()

            if (CMAKE_SYSTEM_PROCESSOR STREQUAL "stm32")
                add_compile_definitions(ARDUINO_ARCH_STM32)
                include_directories(${CMSIS_PATH}/Core/Include) #  TODO CMSIS setup
                include_directories(
                        ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}
                        ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/LL
                        ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/usb
                        ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/OpenAMP)
            else ()
                add_compile_definitions(ARDUINO_ARCH_AVR)
                add_compile_definitions(ARDUINO_ARCH_NANO) # TODO hack!!

            endif ()

            if (BUILD_SERIES)
                _try_get_board_property(${BOARD_ID} build.product_line P_LINE)
                if (P_LINE)
                    add_compile_definitions(${P_LINE})
                endif ()
            endif ()

            _try_get_board_property(${BOARD_ID} build.variant_h VARIANT_H)
            if (VARIANT_H)
                add_compile_definitions(VARIANT_H="${VARIANT_H}")
            endif ()

            add_compile_definitions(${BUILD_SERIES}
                    ARDUINO=${NORMALIZED_SDK_VERSION}
                    ARDUINO_${BOARD_CPU}
                    )
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})

            set_board_flags(${CORE_LIB_NAME} ${BOARD_ID} FALSE)
        endif ()
        set(${OUTPUT_VAR} ${CORE_LIB_NAME} PARENT_SCOPE)
    else ()
        message(FATAL_ERROR "no board: ${BOARD_CORE}")
    endif ()
endfunction()
