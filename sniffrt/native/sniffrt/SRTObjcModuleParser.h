#import <Foundation/Foundation.h>

@interface SRTObjcModuleParser : NSObject

-(NSData *) getModuleList;
-(NSArray<NSData *> *) getClassListForModule:(uint64_t) module;

@end
