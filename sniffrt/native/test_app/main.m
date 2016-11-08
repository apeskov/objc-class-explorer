#include <stdio.h>
#include <dlfcn.h>
#include "rt_class_sniffer.h"

int main(int argc, const char * argv[]) {

    void* exec_entry= dlsym(RTLD_DEFAULT, "_mh_execute_header");
    rt_class_sniffer_start(exec_entry);

    // wait for any input. Just for test
    getchar();
    return 0;
}
