#import <XCTest/XCTest.h>

#import "SRTClassInfo.h"

@interface ClassInfoTest : XCTestCase
@end

@implementation ClassInfoTest

int64_t module_id = 100500;

- (void)testMessageConstruct {
    
    SRTClassInfo *class_info = [SRTClassInfo classInfoByName:"StubA"];
    class_info.moduleId = module_id; //to complite class_info description
    NSData* msg = [class_info serialize];

    XCTAssertNotNil(msg, "Unable build message");
}

- (void)testNameCheck {
    
    SRTClassInfo *class_info = [SRTClassInfo classInfoByName:"StubA"];
    class_info.moduleId = module_id; //to complite class_info description
    NSData* msg = [class_info serialize];
    
    NSError *err;
    Response *resp = [Response parseFromData:msg error:&err];
    XCTAssertNil(err, "Unable to decode message");
    XCTAssertEqual(resp.type, Response_Type_Class);
    XCTAssertTrue([resp.classInfo.name isEqualToString:@"StubA"]);
}

- (void)testInheritanceCheck {
    
    SRTClassInfo *class_info_A = [SRTClassInfo classInfoByName:"StubA"];
    SRTClassInfo *class_info_B = [SRTClassInfo classInfoByName:"StubB"];

    class_info_A.moduleId = module_id;
    class_info_B.moduleId = module_id;

    NSData* msg_A = [class_info_A serialize];
    NSData* msg_B = [class_info_B serialize];

    NSError *err;
    Response *resp_A = [Response parseFromData:msg_A error:&err];
    Response *resp_B = [Response parseFromData:msg_B error:&err];
    
    XCTAssertEqual(resp_A.classInfo.id_p, resp_A.classInfo.superClassId);
}

@end

/**********
 * Stubs
 **********/
@interface StubA : NSObject
@end

@interface StubB : StubA
@end

