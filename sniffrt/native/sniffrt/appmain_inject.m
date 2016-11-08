#include "rt_class_sniffer.h"
#include <dlfcn.h>

int (*original_NSApplicationMain) (int argc, const char * argv[]) = 0;

/* Try to inject non blocking call of rt_class_sniffer_start() in NSApplicationMain 
 * if it's possible. For other cases will ask customer to call it manually.
 */
int NSApplicationMain(int argc, const char * argv[]) {

    if (!original_NSApplicationMain) {
        void * appkit_hdl = dlopen("/System//Library/Frameworks/AppKit.framework/AppKit", RTLD_LAZY);
        original_NSApplicationMain = dlsym(appkit_hdl, "NSApplicationMain");
    }

    void* exec_entry= dlsym(RTLD_DEFAULT, "_mh_execute_header");
    rt_class_sniffer_start(exec_entry);

    // transfer call to original function
    return original_NSApplicationMain(argc, argv);
}
