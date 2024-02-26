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
    set(CORE_LIB_NAME core_${BOARD_ID})
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)

    if (BOARD_CORE)
        if (NOT TARGET ${CORE_LIB_NAME})
            set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
            find_sources(CORE_SRCS ${BOARD_CORE_PATH} FALSE)
            #            find_headers(CORE_HDRS ${BOARD_CORE_PATH} True)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})

#            find_sources(HAL_SRCS ${PLATFORM_PATH}/system/Drivers/STM32F1xx_HAL_Driver/Src FALSE)
#            find_sources(HAL2_SRCS ${PLATFORM_PATH}/system/STM32F1xx FALSE)
#            add_library(HAL ${HAL_SRCS};${HAL2_SRCS})

            target_include_directories(${CORE_LIB_NAME}
                    PUBLIC ${BOARD_CORE_PATH};${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}
                    PUBLIC ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/LL
                    PUBLIC ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/usb
                    PUBLIC ${BOARD_CORE_PATH}/${CMAKE_SYSTEM_PROCESSOR}/OpenAMP
                    )
            _get_board_property(${BOARD_ID} build.core BOARD_CORE)
            _get_board_property(${BOARD_ID} build.series BUILD_SERIES)
            _get_board_property(${BOARD_ID} build.variant_h VARIANT_H)
            _get_board_property(${BOARD_ID} build.variant VARIANT)

            target_include_directories(${CORE_LIB_NAME}
                    PUBLIC ${PLATFORM_PATH}/system/Drivers/CMSIS/Device/ST/${BUILD_SERIES}/Include
                    PUBLIC ${CMSIS_PATH}/Core/Include
                    PUBLIC ${PLATFORM_PATH}/system/Drivers/${BUILD_SERIES}_HAL_Driver/Inc
                    PUBLIC ${PLATFORM_PATH}/system/${BUILD_SERIES}
                    PUBLIC ${PLATFORM_PATH}/variants/${VARIANT}


                    )


            if (BUILD_SERIES)
                _try_get_board_property(${BOARD_ID} build.product_line P_LINE)
                if (P_LINE)
                    target_compile_definitions(${CORE_LIB_NAME}
                            PUBLIC ${P_LINE}
                            )
                endif ()
            endif ()
            target_compile_definitions(${CORE_LIB_NAME}
                    PUBLIC ${BUILD_SERIES}
                    PUBLIC ARDUINO=${NORMALIZED_SDK_VERSION}
                    PUBLIC ARDUINO_ARCH_STM32
                    PUBLIC ARDUINO_${BOARD_CPU}
                    PUBLIC VARIANT_H="${VARIANT_H}"
                    )

            set_board_flags(${CORE_LIB_NAME} ${BOARD_ID} FALSE)
            #            set_target_properties(${CORE_LIB_NAME} PROPERTIES
            #                    COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS}"
            #                    LINK_FLAGS "${ARDUINO_LINK_FLAGS}")
        endif ()
        set(${OUTPUT_VAR} ${CORE_LIB_NAME} PARENT_SCOPE)
    endif ()
endfunction()
