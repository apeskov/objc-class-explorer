#import <Foundation/Foundation.h>
#import "Classinfo.pbobjc.h"

@interface SRTClassInfo : NSObject
{
    Response *payload;
}

+(id) classInfoByName:(const char*) name;
+(id) classInfoByName:(const char*) name withModuleId:(int64_t) module_id;


-(id) initWithName:(const char*) name;
-(void) setModuleId:(int64_t) module_id;
-(NSData*) serialize;

@end
