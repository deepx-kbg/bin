obj-m += dx-module-b.o

MODULE_NAME := dx-module-b
KERNEL_DIR := /lib/modules/$(shell uname -r)/build
INSTALL_DIR := /lib/modules/$(shell uname -r)/kernel/drivers/misc

B_SYM_DIR := /tmp/module-b
B_SYM_VERS := $(B_SYM_DIR)/Module_b.symvers

DESTDIR ?=

all: modules

modules:
	make -C $(KERNEL_DIR) M=$(shell pwd) modules

install: modules
	mkdir -p $(DESTDIR)$(INSTALL_DIR)
	cp $(MODULE_NAME).ko $(DESTDIR)$(INSTALL_DIR)

	@if [ -n "$(DESTDIR)" ]; then \
		sudo depmod -a -b $(DESTDIR); \
	else \
		sudo depmod -a; \
	fi

	mkdir -p $(B_SYM_DIR)
	cp Module.symvers $(B_SYM_VERS)

uninstall:
	make -C $(KERNEL_DIR) M=$(shell pwd) modules_install CLEAN=1
	rm -f $(DESTDIR)$(INSTALL_DIR)/$(MODULE_NAME).ko

clean:
	make -C $(KERNEL_DIR) M=$(shell pwd) clean
