#include "rt_class_sniffer.h"
#include <objc/runtime.h>
#include <dlfcn.h>
#include <netinet/in.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

void* rt_class_sniffer_routine();

void rt_class_sniffer_start(void* addres) {

    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    pthread_t       posixThreadID;
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    if (returnVal) return;
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (returnVal) return;
    
    int threadError = pthread_create(&posixThreadID, &attr, &rt_class_sniffer_routine, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    if (returnVal) return;
    if (threadError != 0)
    {
        // Report an error.
    }
}

void* rt_class_sniffer_routine() {
    int listenfd = 0,connfd = 0;
    
    struct sockaddr_in serv_addr;
    
    char sendBuff[1025];
    
    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    printf("socket retrieve success\n");
    
    memset(&serv_addr, '0', sizeof(serv_addr));
    memset(sendBuff, '0', sizeof(sendBuff));
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(2000);
    
    bind(listenfd, (struct sockaddr*)&serv_addr,sizeof(serv_addr));
    
    if(listen(listenfd, 10) == -1){
        printf("Failed to listen\n");
        return NULL;
    }
    
    while(1)
    {
        connfd = accept(listenfd, (struct sockaddr*)NULL ,NULL); // accept awaiting request
        
        strcpy(sendBuff, "Message from server");
        write(connfd, sendBuff, strlen(sendBuff));
        
        close(connfd);
        sleep(1);
    }

}

void print_classes(void* addres) {

    unsigned int count;
    const char **classes;
    Dl_info info;
    
    dladdr(addres, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    
    for (int i = 0; i < count; i++) {
        printf("Class(%i) name: %s\n", i, classes[i]);
    }
}
