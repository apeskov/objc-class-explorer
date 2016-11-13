#import "SRTObjcClassObserver.h"
#import "SRTObjcModuleParser.h"
#import "Classinfo.pbobjc.h"

@implementation SRTObjcClassObserver

-(id) init
{
    self = [super init];
    if (!self) return nil;

    connection = [[SRTConnectionHandler alloc] initWithDelegate:self];
    moduleParser = [SRTObjcModuleParser new];

    Response *msg = [Response message];
    msg.type = Response_Type_EndOfList;
    eolMsg = [msg data];

    return self;
}

-(void) start
{
    [connection start];
}



/**************************************
 * SRTMessageHandlerDelegate methods
 **************************************/

-(void) handleMsg:(NSData*)data
{
    NSError *err;
    Request *request = [Request parseFromData:data error:&err];

    switch (request.type) {
        case Request_Type_GetModuleList:
        {
            NSData *msg = [moduleParser getModuleList];
            [connection sendMsg:msg];
        }
            break;
            
        case Request_Type_GetClassesForModule:
        {
            NSArray<NSData*> *msg = [moduleParser getClassListForModule:request.moduleId];
            [connection sendMsgs:msg];
            [connection sendMsg:eolMsg];
            
        }
            break;

        case Request_Type_Cancel:
            
            [connection cancel];
            break;
            
        case Request_Type_Close:
            
            [connection finish];
            break;
    }
}

-(void) errorEvent
{
    // To be implemented
}

-(void) closedEvent
{
    // To be implemented
}



@end
