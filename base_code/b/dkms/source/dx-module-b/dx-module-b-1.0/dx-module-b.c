#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init b_init(void) {
    printk(KERN_INFO "Module B loaded\n");
    return 0;
}

static void __exit b_exit(void) {
    printk(KERN_INFO "Module B unloaded\n");
}

void b_function(void) {
    printk(KERN_INFO "Function in Module B called\n");
}
EXPORT_SYMBOL_GPL(b_function); // Export the function

module_init(b_init);
module_exit(b_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("KOO Bongyu <kbg@deepx.ai>");
MODULE_DESCRIPTION("Module B");
