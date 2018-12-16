# Target to be built.
TARGET ?= main

# Part's name.
PART = tm4c123gxl

# Base directory to TivaWare.
TIVAWARE = ${HOME}/dev/embedded/tiva

#
# ${TIVAWARE}/makedefs includes implicit rules and variables for building
# a TIVA's project.
#
include ${TIVAWARE}/makedefs

# Where to find header files which do not live in the project.
IPATH = ${TIVAWARE}

SCATTERgcc_${TARGET} = ${PART}.ld
ENTRY_${TARGET} = ResetISR
CFFLAGSgcc = -DTARGET_IS_TM4C123_RB1

all: gcc/$(TARGET).axf

gcc/${TARGET}.axf: gcc/${TARGET}.o
gcc/${TARGET}.axf: gcc/startup_gcc.o 
gcc/${TARGET}.axf: ${TIVAWARE}/driverlib/gcc/libdriver.a
gcc/${TARGET}.axf: ${PART}.ld

#
# Download necessary files from my GitHub.
# Includes: startup_gcc.c
#			tm4c123gxl.ld
#
.PHONY: configure
configure:
	@echo Configuring...
	@mkdir -p gcc
	@curl -OO https://raw.githubusercontent.com/ngharry/tiva-config\
	/master/tiva-config/{startup_gcc.c,${PART}.ld}
	@echo Finished.

.PHONY: clean
clean:
	@echo Cleaning...
	@rm -rf gcc ${wildcard *~}
	@echo Finished.

# Dependencies
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard gcc/*.d} __dummy__
endif
