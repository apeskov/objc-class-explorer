#include <stdio.h>
#include <dlfcn.h>
#include "rt_class_sniffer.h"

int main(int argc, const char * argv[]) {

    rt_class_sniffer_start();

    // Infiniti loop.
    // Allow sniffer thread to complite all actions for test.
    while (true) getchar();
    return 0;
}
