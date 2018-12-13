TARGET = main

# COMPILER := gcc

PART = tm4c123gxl

ROOT = ${HOME}/dev/embedded/tiva

include ${ROOT}/makedefs

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
.PHONY: configure
configure:
	@curl -OO https://raw.githubusercontent.com/ngharry/tiva-config\
	/master/tiva-config/{startup_gcc.c,${PART}.ld}

.PHONY: clean
clean: 
	@rm -rf ${COMPILER} ${wildcard *~}

ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${COMPILER}/*.d} __dummy__
endif
