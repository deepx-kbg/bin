#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleloader.h>

// Declare the function prototype for the function in module B
extern void b_function(void);

static int __init a_init(void) {
    printk(KERN_INFO "Module A loading\n");

    // Call the function from module B
    b_function();

    return 0;
}

static void __exit a_exit(void) {
    printk(KERN_INFO "Module A unloaded\n");
}

module_init(a_init);
module_exit(a_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("KOO Bongyu <kbg@deepx.ai>");
MODULE_DESCRIPTION("DeepX module A");
