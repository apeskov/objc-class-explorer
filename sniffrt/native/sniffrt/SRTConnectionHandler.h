#import <Foundation/Foundation.h>

@protocol SRTConnectionHandlerDelegate

-(void) handleMsg:(NSData*)data;
-(void) closedEvent;
-(void) errorEvent;

@end


@interface SRTConnectionHandler : NSObject <NSStreamDelegate>

@property (weak) id<SRTConnectionHandlerDelegate> delegate;

-(id) initWithDelegate:(id<SRTConnectionHandlerDelegate>) delegate;

/**
 * General methods.
 */
-(void) start;
-(void) finish;

/**
 * Will submit data to send.
 * 
 * Non blocking operation. Just add in queue operation
 */
-(void) sendMsg:(NSData*)data;
-(void) sendMsgs:(NSArray<NSData*>*)data;

/**
 * Cancel sending.
 * Connection handler finish sending of message already in progress 
 * and will skip remaining messages in queue.
 */
-(void) cancel;


@end
