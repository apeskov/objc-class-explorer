#include "rt_class_sniffer.h"
#import "SRTObjcClassObserver.h"

/*
 *
 *
 */
void rt_class_sniffer_start() {
    
    dispatch_queue_t sniff_q = dispatch_queue_create("sniff_rt", NULL);
    dispatch_async(sniff_q, ^{

        NSRunLoop * runloop = [NSRunLoop currentRunLoop];
        SRTObjcClassObserver *observer = [SRTObjcClassObserver new];
        [observer start];
        
        [runloop run];
    });
}
