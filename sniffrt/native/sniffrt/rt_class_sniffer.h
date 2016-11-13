#ifndef rt_class_sniffer_h
#define rt_class_sniffer_h

/*
 * Entry point for class sniffer server. Will start additional thread 
 * with sniffer server routine. Can be called from any place of main
 * application.
 */
void rt_class_sniffer_start();

#endif /* rt_class_sniffer_h */
