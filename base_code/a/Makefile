obj-m += a.o

INSTALL_DIR := /lib/modules/$(shell uname -r)/build

SYM_DIR := $(INSTALL_DIR)/include/generated

B_SYM_VERS := $(SYM_DIR)/Module_b.symvers

# Specify extra symbols directory
KBUILD_EXTRA_SYMBOLS := $(B_SYM_VERS)

# Build target
all:
	make -C $(INSTALL_DIR) M=$(PWD) modules

clean:
	make -C $(INSTALL_DIR) M=$(PWD) clean
