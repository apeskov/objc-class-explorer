#import "SRTConnectionHandler.h"

#include <sys/socket.h>
#include <netinet/in.h>

#define HOST CFSTR("localhost")
#define PORT 2000

@implementation SRTConnectionHandler
{
    CFSocketRef socket;
    CFSocketContext ctx;
    CFRunLoopSourceRef socketsource;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    bool haveToSend;
    bool ableToSend;
    
    NSMutableArray<NSData*> *queueToSend;
}

-(id) initWithDelegate:(id<SRTConnectionHandlerDelegate>) delegate
{
    if ( self = [super init] ) {
        
        socket = NULL;
        inputStream = nil;
        outputStream = nil;
        haveToSend = false;
        ableToSend = false;
        
        self.delegate = delegate;
        
        queueToSend = [NSMutableArray<NSData*> array];
        
        return self;
    } else return nil;
}

-(void) start
{
    // store self in socket context.
    // To use in in handleConnect() callback
    memset(&ctx, 0, sizeof(ctx));
    ctx.info = (__bridge void*)self;
    
    NSLog(@"Try to start");
    socket = CFSocketCreate(kCFAllocatorDefault,
                            PF_INET,
                            SOCK_STREAM,
                            IPPROTO_TCP,
                            kCFSocketAcceptCallBack, handleConnect, &ctx);
    

    // specify socket port param
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(PORT);
    sin.sin_addr.s_addr= INADDR_ANY;
    
    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault,
                                    (UInt8 *)&sin,
                                    sizeof(sin));
    
    CFSocketError err = CFSocketSetAddress(socket, sincfd);
    if (err != kCFSocketSuccess) NSLog(@"[ERROR] was not able to set port.");
    CFRelease(sincfd);

    socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault,
                                               socket, 0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       socketsource,
                       kCFRunLoopDefaultMode);
}

/**
 * Callback for CFSocketCreate
 * Function will be called on socket connection acceptance.
 */
void handleConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    if (type == kCFSocketAcceptCallBack) {
        
        CFSocketNativeHandle *socket = (CFSocketNativeHandle*)data;
        SRTConnectionHandler *handler = (__bridge SRTConnectionHandler*)info;
        
        // transfer to class method
        [handler handleSocketAccept:socket];
    }
}

/**
 * Hadnler of socket accept event
 */
-(void) handleSocketAccept:(CFSocketNativeHandle*)in_socket
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, *in_socket, &readStream, &writeStream);
    
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

/**
 * Routine of communication events.
 * Stream read/write, and handling close/error events
 */
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        
        case NSStreamEventHasBytesAvailable:

            [self readData];
            break;
        
        case NSStreamEventHasSpaceAvailable:
            // try to send data if it's available
            ableToSend = true;
            [self trySendData];
            break;
            
        case NSStreamEventEndEncountered:

            [self finish];
            break;
            
        case NSStreamEventErrorOccurred:

            NSLog(@"Socket error string: %@", [[theStream streamError] localizedDescription]);
            break;
            
        default:
            break;
    }
}

-(void) readData
{
    uint8_t data[1024];
    long len;
    len = [inputStream read:data maxLength:sizeof(int32_t)];
    
    if (len == 0) return;
    if (len != sizeof(int32_t)) @throw [NSException exceptionWithName:@"WrangFormatException"
                                                               reason:nil
                                                             userInfo:nil ];

    /* Client send message size as 32-bit int with reverse order */
    int32_t msg_size = CFSwapInt32BigToHost(*(int32_t*)data);

    // TODO: Implement data sending by slices. (len != msg_size) is very hard requirement
    len = [inputStream read:data maxLength:msg_size];
    if (len != msg_size) @throw [NSException exceptionWithName:@"WrangFormatException"
                                                        reason:nil
                                                      userInfo:nil ];

    NSData *msg = [NSData dataWithBytes:data length:len];
    [_delegate handleMsg:msg];
}

/************************************************
 * Send message routine
 ************************************************/

-(void) trySendData
{
    if (haveToSend && ableToSend) {
        
        NSData *data = [queueToSend objectAtIndex:0] ;
        [queueToSend removeObjectAtIndex:0];
        NSInteger len;
        
        int32_t size = CFSwapInt32BigToHost((int32_t)data.length);
        
        len = [outputStream write:(const uint8_t*)&size
                        maxLength:sizeof(int32_t)];
        
        if (len != sizeof(int32_t)) @throw [NSException exceptionWithName:@"RuntimeException"
                                                                   reason:@"Unable to send response"
                                                                 userInfo:nil ];
        
        len = [outputStream write:data.bytes
                        maxLength:data.length];
        
        if (len != data.length) @throw [NSException exceptionWithName:@"RuntimeException"
                                                               reason:@"Unable to send response"
                                                             userInfo:nil ];
        
        NSLog(@"Was sent %ld", len);
        
        haveToSend = (queueToSend.count != 0);
        ableToSend = false;
    }
}

-(void) sendMsg:(NSData *)data
{
    haveToSend = true;
    [queueToSend addObject:data];

    [[NSRunLoop currentRunLoop] performBlock: ^{
        [self trySendData];
    }];
}

-(void) sendMsgs:(NSArray<NSData *> *)data
{
    for (NSData *data_part in data)
        [self sendMsg:data_part];
}

-(void) cancel
{
    haveToSend = false;
}

-(void) finish
{
    NSLog (@"[XXX] Try to invalidate");
    
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    
    [inputStream close];
    [outputStream close];
    
    inputStream = nil;
    outputStream = nil;

    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), socketsource, kCFRunLoopDefaultMode);
    CFRelease(socketsource);

    CFSocketInvalidate(socket);
    CFRelease(socket);
}


@end
