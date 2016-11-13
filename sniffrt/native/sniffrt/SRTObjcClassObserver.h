#import <Foundation/Foundation.h>
#import "SRTConnectionHandler.h"
#import "SRTObjcModuleParser.h"

@interface SRTObjcClassObserver : NSObject <SRTConnectionHandlerDelegate>
{
    SRTConnectionHandler *connection;
    SRTObjcModuleParser *moduleParser;

    // End Of List message
    NSData* eolMsg;
}

-(void) start;

@end
