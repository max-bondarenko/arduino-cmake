SET(CMAKE_TOOLCHAIN_FILE ArduinoToolchain.cmake)
cmake_minimum_required(VERSION 3.8)

file(GLOB_RECURSE SRCS_HELLO test-lib/*)

#SET(PLATFORM_PATH $ENV{HOME}/.platformio/packages/framework-arduinoststm32)
#SET(TOOLCHAIN_PATH "$ENV{HOME}/.platformio/packages/toolchain-gccarmnoneeabi")

project(test-cmake C CXX)

SET(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

#print_board_list() # todo done
#print_board_settings(Nucleo_144) todo done
#print_board_settings(nano) # todo done
#print_programmer_list() todo done

#generate_arduino_firmware(hello
#        SRCS ${SRCS_HELLO}
#        BOARD GenF1
#        BOARD_CPU BLUEPILL_F103C6
#        PORT /dev/ttyACM0
#        )
# todo done stm
#set(BOARD_CPU GENERIC_F103CBTX)
#make_core_library(ASD "GenF1.GENERIC_F103CBTX")
# todo  avr
set(BOARD_CPU atmega168)
make_core_library(ASD "nano.atmega168")


# TODO use CMakeDependentOption !
# TODO set standarts CMAKE_C_STANDARD!!
# todo  MCPU set for stm32
# TODO done add arduino-* as independent part. some libs are in arduino not in stm32
# todo : use CMAKE_LIBRARY_PATH in all libs
# TODO LINK flags
# TODO done CMSIS setup

set(test_LIB_SRC test-lib/for_lib_test.cpp test-lib/for_lib_test2.cpp)
#find_arduino_libraries(FOUND_LIBS ${test_LIB_SRC} "")
set(lib_name)
set(C_FLAGS)
set(L_FLAGS)
set(ARDUINO_DEBUG TRUE)

# Possible choice for STM32
#  BMP    : BlackMagic
#  STLink : ST link v2
#  DFUUpload: Arduino
#
# that changes the way the binary is linked, better to use DFU in all cases !

#
##
##set(ARDUINO_DEFAULT_BOARD GenF1) # Default Board ID, when not specified
#set(ARDUINO_DEFAULT_PORT  ttyACM0) # Default Port, when not specified


#make_arduino_library (lib_name "GenF1.GENERIC_F103CBTX" ${lib_EEPROM-src} "-DA" "-lg")

# TODO done
#generate_library(test_lib
#        BOARD GenF1.GENERIC_F103CBTX
#        BOARD_CPU GENERIC_F103CBTX
#        SRCS ${test_LIB_SRC}
#        )

## TODO done
#generate_library(test_lib
#        BOARD GenF1.GENERIC_F103CBTX
#        BOARD_CPU GENERIC_F103CBTX
#        SRCS ${test_LIB_SRC}
#        LIBS EEPROM Wire
#        NO_AUTOLIBS
#        )

# TODO done
#generate_inplace_library(test_lib
#        BOARD GenF1.GENERIC_F103CBTX
#        BOARD_CPU GENERIC_F103CBTX
#        DIR test-lib/printfloat
#        NO_AUTOLIBS
#        )

# TODO done
#make_arduino_example(blink "Blink" ALL_SRCS "Basics" )
# TODO done

# TODO ArduinoFirmwareTargetCreator_stm32.cmake
#generate_arduino_example(blink
#        EXAMPLE "Blink"
#        CATEGORY "Basics"
#        BOARD GenF1.GENERIC_F103CBTX
#        BOARD_CPU GENERIC_F103CBTX
#        )
#make_arduino_sketch(blink "/opt/arduino-1.8.19/examples/01.Basics/Blink" SKETCH_CPP )


# reference
#add_definitions(-D'LOG_DEBUG')
#add_definitions(-D'PLATFORMIO=60111')
#add_definitions(-D'STM32F103xB')
#add_definitions(-D'STM32F1')
#add_definitions(-D'USBCON')
#add_definitions(-D'USBD_USE_CDC')
#add_definitions(-D'ENABLE_HWSERIAL1')
#add_definitions(-D'U8G2_16BIT')
#add_definitions(-D'STM32F1xx')
#add_definitions(-D'ARDUINO=10808')
#add_definitions(-D'ARDUINO_ARCH_STM32')
#add_definitions(-D'ARDUINO_GENERIC_F103CBTX')
#add_definitions(-D'BOARD_NAME=GENERIC_F103CBTX')
#add_definitions(-D'HAL_UART_MODULE_ENABLED')
#add_definitions(-D'USE_FULL_LL_DRIVER')
#add_definitions(-D'VARIANT_H="variant_generic.h"')
#add_definitions(-D'HAL_PCD_MODULE_ENABLED')

#include_directories("${FRAMEWORK}/cores/arduino")
#include_directories("${FRAMEWORK}/cores/arduino/stm32")
#include_directories("${FRAMEWORK}/cores/arduino/stm32/LL")
#include_directories("${FRAMEWORK}/cores/arduino/stm32/usb")
#include_directories("${FRAMEWORK}/variants/STM32F1xx/F103C8T_F103CB(T-U)")
#include_directories("${FRAMEWORK_CMSIS}/CMSIS/Core/Include")
#include_directories("${FRAMEWORK_CMSIS}/Core/Include")
#include_directories("${FRAMEWORK_CMSIS}/DSP/Include")
#include_directories("${FRAMEWORK_CMSIS}/DSP/PrivateInclude")
#
#include_directories("${FRAMEWORK}/system/STM32F1xx")
#include_directories("${FRAMEWORK}/system/Drivers/CMSIS/Device/ST/STM32F1xx/Include")
#include_directories("${FRAMEWORK}/system/Drivers/CMSIS/Device/ST/STM32F1xx/Include")
#include_directories("${FRAMEWORK}/system/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc")
#include_directories("${FRAMEWORK}/system/Drivers/STM32F1xx_HAL_Driver/Inc")
#include_directories("${FRAMEWORK}/system/Drivers/STM32F1xx_HAL_Driver/Src")
#include_directories("${FRAMEWORK}/system/Middlewares/ST/STM32_USB_Device_Library/Core/Inc")
#include_directories("${FRAMEWORK}/system/Middlewares/ST/STM32_USB_Device_Library/Core/Src")
#
