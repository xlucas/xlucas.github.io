#---------------------------------------------------#
DOT_DIR ?= graphs
IMG_DIR ?= images
DOT = $(notdir $(wildcard $(DOT_DIR)/*.dot))
IMG = $(addprefix $(IMG_DIR)/, $(DOT:%.dot=%.png))
#---------------------------------------------------#

all: $(IMG)

$(IMG): $(IMG_DIR)/%.png: $(DOT_DIR)/%.dot
	dot -Tpng $< -o $@
