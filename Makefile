#GENERIC RULES FOR BUILDING A PROJECT FOR TI TM4C123G
#May Be buggy
#Losely based on TI StellarisWare examples

#Define project name
PROJECT=TEST
#Define BUILDDIR
BUILDDIR=bin
#C source files
SOURCES=TEST.c
SOURCES+=setup.c
SOURCES+=startup_gcc.c
SOURCES+=ISR.c


INCLUDEDIRS=-I./
#objects from the C files
OBJECTS=$(SOURCES:.c=.o)
VERBOSE=""
#DUMMY FILESROM_FPULazyStackingEnable
DUMMYFILES=$(SOURCES:.c=.d)

#Define Compiler, linker, archiver, etc.
COMPILER=gcc
PREFIX=arm-none-eabi-
CC=${PREFIX}${COMPILER}
AR=${PREFIX}ar
LD=${PREFIX}ld
OBJCOPY=${PREFIX}objcopy

#define CPU model and floating point behavior
CPU=-mcpu=cortex-m4
FPU=-mfpu=fpv4-sp-d16 -mfloat-abi=hard

#
# The flags passed to the assembler.
#
AFLAGS=-mthumb \
       ${CPU}  \
       ${FPU}  \
       -MD

LIBRARIES=./driverlib/gcc-cm4f/libdriver-cm4f.a

#
# The flags passed to the compiler.
#
CFLAGS=-mthumb             \
       ${CPU}              \
       ${FPU}              \
       -Os                 \
       -ffunction-sections \
       -fdata-sections     \
       -MD                 \
       -std=c99            \
       -Wall               \
       -pedantic           \
       -DPART_${PART}      \
       -I./								 \

#Locate gcc libraries
LIBGCC=${shell ${CC} ${CFLAGS} -print-libgcc-file-name}
LIBC=${shell ${CC} ${CFLAGS} -print-file-name=libc.a}
LIBM=${shell ${CC} ${CFLAGS} -print-file-name=libm.a}


#
# The rule for building the object file from each C source file.
#
${BUILDDIR}${SUFFIX}/%.o: %.c
	@if [ 'x${VERBOSE}' = x ];                            \
	 then                                                 \
	     echo "  CC    ${<}";                             \
	 else                                                 \
	     echo ${CC} ${INCLUDEDIRS} ${CFLAGS} -D${BUILDDIR} -o ${@} ${<}; \
	 fi
	@${CC} ${INCLUDEDIRS} ${CFLAGS} -D${BUILDDIR} -o ${@} ${<}
ifneq ($(findstring CYGWIN, ${os}), )
	@sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif

#
# The rule for building the object file from each assembly source file.
#
${BUILDDIR}${SUFFIX}/%.o: %.S
	@if [ 'x${VERBOSE}' = x ];                               \
	 then                                                    \
	     echo "  AS    ${<}";                                \
	 else                                                    \
	     echo ${CC} ${AFLAGS} ${INCLUDEDIRS} -D${BUILDDIR} -o ${@} -c ${<}; \
	 fi
	@${CC} ${AFLAGS} ${INCLUDEDIRS} -D${BUILDDIR} -o ${@} -c ${<}
ifneq ($(findstring CYGWIN, ${os}), )
	@sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif

#
# The rule for creating an object library.
#
${BUILDDIR}${SUFFIX}/%.a:
	@if [ 'x${VERBOSE}' = x ];     \
	 then                          \
	     echo "  AR    ${@}";      \
	 else                          \
	     echo ${AR} -cr ${@} ${^}; \
	 fi
	@${AR} -cr ${@} ${^}

#
# The rule for linking the application.
#

${BUILDDIR}${SUFFIX}/%.axf:
	@if [ 'x${SCATTERgcc_${notdir ${@:.axf=}}}' = x ];                    \
	 then                                                                 \
	     ldname="${ROOT}/gcc/standalone.ld";                              \
	 else                                                                 \
	     ldname="${SCATTERgcc_${notdir ${@:.axf=}}}";                     \
	 fi;                                                                  \
	 if [ 'x${VERBOSE}' = x ];                                            \
	 then                                                                 \
	     echo "  LD    ${@} ${LNK_SCP}";                                  \
	 else                                                                 \
	     echo ${LD} -T $${ldname}                                         \
	          --entry ${ENTRY_${notdir ${@:.axf=}}}                       \
	          ${LDFLAGSgcc_${notdir ${@:.axf=}}}                          \
	          ${LDFLAGS} -o ${@} $(filter %.o %.a, ${^})                  \
	          '${LIBRARIES}' '${LIBM}' '${LIBC}' '${LIBGCC}' ;                            \
	 fi;                                                                  \
	${LD} -T $${ldname}                                                   \
	      --entry ${ENTRY_${notdir ${@:.axf=}}}                           \
	      ${LDFLAGSgcc_${notdir ${@:.axf=}}}                              \
	      ${LDFLAGS} -o ${@} $(filter %.o %.a, ${^})                      \
	      '${LIBRARIES}' '${LIBM}' '${LIBC}' '${LIBGCC}'
	@${OBJCOPY} -O binary ${@} ${@:.axf=.bin}
#endif


all: ${BUILDDIR}
all: ${BUILDDIR}/${PROJECT}.axf


#
# The rule to clean out all the build products.
#
clean:
	@rm -rf ${BUILDDIR} ${wildcard *~}
	@echo rm -rf ${BUILDDIR}
	rm ${OBJECTS}
	rm ${DUMMYFILES}

#
# The rule to create the target directory.
#
${BUILDDIR}:
	@mkdir -p ${BUILDDIR}

#
# Rules for building the blinky example.
#
${BUILDDIR}/${PROJECT}.axf: ${OBJECTS}
${BUILDDIR}/${PROJECT}.axf: ${LIBRARIES}
${BUILDDIR}/${PROJECT}.axf: ${PROJECT}.ld
SCATTERgcc_${PROJECT}=${PROJECT}.ld
ENTRY_${PROJECT}=ResetISR

#
# Include the automatically generated dependency files.
#
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${BUILDDIR}/*.d} __dummy__
endif

flash: 
	echo "Flashing chip"
	sudo lm4flash bin/${PROJECT}.bin
