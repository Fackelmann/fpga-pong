MODULE = pong_kb_dec

SRC_FILES = \
	../src/${MODULE}.vhd \
	../../parity_checker/src/parity_checker.vhd

TBENCH_FILES = ../tbench/${MODULE}_tb.vhd

LIB_DIR = $$QUARTUS_ROOTDIR/libraries/vhdl
LIBS = altera_mf

SIM_LIB_DIR = $$QUARTUS_ROOTDIR/eda/sim_lib
SIM_LIBS = altera_mf_primitives altera_mf_components altera_mf

LIBS_COMPILATION = $(foreach LIB, ${LIBS}, $(shell echo "rm -rf ${LIB}; vlib ${LIB}; vcom ${LIB_DIR}/${LIB}/*.vhd -work ${LIB};"))
SIM_LIBS_COMPILATION = $(foreach LIB, ${SIM_LIBS}, $(shell echo "vcom ${SIM_LIB_DIR}/${LIB}.vhd;"))

all: libs proj

proj:
	@vcom ${SRC_FILES}
	@vcom ${TBENCH_FILES}

libs:
	@rm -rf work
	@vlib work
	@vmap work work
	@${LIBS_COMPILATION}
	@${SIM_LIBS_COMPILATION}

sim:
	@vsim -novopt ${MODULE}_tb

clean:
	@rm -rf work transcript ${LIBS} modelsim.ini *.wlf

.DEFAULT_GOAL = all
