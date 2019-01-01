#
# User Configuration
#
TARGET = main

MCU = tm4c123gxl

# Path to Tiva software
TIVAPATH = $(HOME)/dev/embedded/tiva

OUTDIR = build

# Path to header files
IPATH = inc
IPATH += ${TIVAPATH}

# If $(quiet) is empty, the whole command will be printed.
# If it is set to "quiet_", only the short version will be printed.
# If it is set to "silent_", nothing will be printed at all, since
# the variable $(silent_cmd_cc_o_c) doesn't exist.
# -------
# Taken from Linux Makefile
Q = quiet_

# End of User Configuration

#
# Fixed Configuration (Should Not Be Changed!)
#
PREFIX = arm-none-eabi

CC = ${PREFIX}-gcc
LD = ${PREFIX}-ld
OBJCOPY = ${PREFIX}-objcopy

MKDIR = mkdir -p

CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16 -mfloat-abi=hard

CFLAGS = -mthumb ${CPU} ${FPU}
CFLAGS += -ffunction-sections -fdata-sections -MD -std=c99 -Wall
CFLAGS += -pedantic -DPART_$(MCU) -c
CFLAGS += -DTARGET_IS_TM4C123_RB1
CFLAGS += ${patsubst %,-I%,${subst :, ,${IPATH}}}

# For debug information in ${TARGET}.axf
ifdef DEBUG
	CFLAGS += -g -D DEBUG -O0
else
	CFLAGS += -Os
endif

LDSCRIPT = $(MCU).ld
LDFLAGS = -T ${LDSCRIPT} --entry ResetISR --gc-sections
LIBDRIVER = ${TIVAPATH}/driverlib/gcc/libdriver.a

#
# Building rules
#
quiet_COMPILE_RULE = Compiling $^...
COMPILE_RULE = $(CC) -o $@ $^ $(CFLAGS)

quiet_LINK_RULE = Linking $^...
LINK_RULE = $(LD) -o $@ $^ ${LIBDRIVER} $(LDFLAGS) # Rule for linking

quiet_BIN_RULE = Dumping $^...
BIN_RULE = $(OBJCOPY) -O binary $< $@

SOURCES = $(wildcard src/**/*.c src/*.c)
OBJECTS = $(addprefix $(OUTDIR)/,$(notdir $(SOURCES:.c=.o)))

# End if fixed configuration

#
# Building 
#
all: $(OUTDIR)/$(TARGET).bin

$(OUTDIR)/%.o: src/%.c
	@echo ${${Q}COMPILE_RULE}
	@${COMPILE_RULE}

$(OUTDIR)/$(TARGET).axf: $(OBJECTS)
	@echo ${${Q}LINK_RULE}
	@${LINK_RULE}

$(OUTDIR)/$(TARGET).bin: $(OUTDIR)/$(TARGET).axf
	@echo ${${Q}BIN_RULE}
	@${BIN_RULE}

config:
	@echo Configuring...
	@echo Creating ${OUTDIR}...
	@${MKDIR} $(OUTDIR)

	@echo Downloading startup_gcc.c to src/...
	@(cd src/ && curl -O https://raw.githubusercontent.com/ngharry/tiva-config\
	/master/tiva-config/startup_gcc.c)

	@echo Downloading ${MCU}.ld...
	@curl -O https://raw.githubusercontent.com/ngharry/tiva-config\
	/master/tiva-config/${MCU}.ld

	@echo Finished.

flash:
	@echo Flashing to ${MCU}...
	@lm4flash build/${TARGET}.bin
	@echo Loaded to ${MCU}

clean:
	@echo Cleaning $(OUTDIR)/*...
	@$(RM) $(OUTDIR)/*
	@echo Finished.

.PHONY: all clean

# Header dependencies
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard gcc/*.d} __dummy__
endif
