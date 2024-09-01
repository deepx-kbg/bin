obj-m += b.o

INSTALL_DIR := /lib/modules/$(shell uname -r)/build

SYM_DIR := $(INSTALL_DIR)/include/generated
B_SYM_VERS := $(SYM_DIR)/Module_b.symvers

all: modules

modules:
	make -C $(INSTALL_DIR) M=$(shell pwd) modules

install: modules
	make -C $(INSTALL_DIR) M=$(shell pwd) modules_install

	cp Module.symvers $(B_SYM_VERS)

clean:
	make -C $(INSTALL_DIR) M=$(shell pwd) clean
