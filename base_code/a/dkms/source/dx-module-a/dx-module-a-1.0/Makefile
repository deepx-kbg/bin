obj-m += dx-module-a.o

MODULE_NAME := dx-module-a
KERNEL_DIR := /lib/modules/$(shell uname -r)/build
INSTALL_DIR := /lib/modules/$(shell uname -r)/kernel/drivers/misc

B_SYM_DIR := /tmp/module-b
B_SYM_VERS := $(B_SYM_DIR)/Module_b.symvers

DESTDIR ?=

# Specify extra symbols directory
KBUILD_EXTRA_SYMBOLS := $(B_SYM_VERS)

all: modules

modules:
	make -C $(KERNEL_DIR) M=$(shell pwd) modules

install: modules
	mkdir -p $(DESTDIR)$(INSTALL_DIR)
	cp $(MODULE_NAME).ko $(DESTDIR)$(INSTALL_DIR)

	@if [ -n "$(DESTDIR)" ]; then \
		depmod -a -b $(DESTDIR); \
	else \
		depmod -a; \
	fi

uninstall:
	make -C $(KERNEL_DIR) M=$(shell pwd) modules_install CLEAN=1
	rm -f $(DESTDIR)$(INSTALL_DIR)/$(MODULE_NAME).ko

clean:
	make -C $(KERNEL_DIR) M=$(shell pwd) clean
