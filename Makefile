m Target to be built.
TARGET ?= main

# Part's name.
PART = tm4c123gxl

# Base directory to TivaWare.
ROOT = ${HOME}/dev/embedded/tiva

#
# ${ROOT}/makedefs includes implicit rules and variables for building
# a TIVA's project.
#
include ${ROOT}/makedefs

# Where to find header files which do not live in the project.
IPATH = ${ROOT}

SCATTERgcc_${TARGET} = ${PART}.ld
ENTRY_${TARGET} = ResetISR
CFFLAGSgcc = -DTARGET_IS_TM4C123_RB1

all: ${COMPILER}
all: ${COMPILER}/$(TARGET).axf

${COMPILER}:
	@mkdir -p ${COMPILER}

${COMPILER}/${TARGET}.axf:  ${COMPILER}/${TARGET}.o \
 							${COMPILER}/startup_${COMPILER}.o \
 							${ROOT}/driverlib/${COMPILER}/libdriver.a \
 							${PART}.ld
#
# Download necessary files from my GitHub.
# Includes: startup_gcc.c
#			tm4c123gxl.ld
#
.PHONY: configure
configure:
	@curl -OO https://raw.githubusercontent.com/ngharry/tiva-config\
	/master/tiva-config/{startup_gcc.c,${PART}.ld}

.PHONY: clean
clean: 
	@rm -rf ${COMPILER} ${wildcard *~}

# Dependencies
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${COMPILER}/*.d} __dummy__
endif
