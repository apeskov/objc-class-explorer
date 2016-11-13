#import <XCTest/XCTest.h>
#import "SRTObjcModuleParser.h"

@interface ObjcModuleParserTest : XCTestCase
@end

@implementation ObjcModuleParserTest

- (void)testGetModuleList {

    SRTObjcModuleParser *parser = [SRTObjcModuleParser new];
    NSData *data = [parser getModuleList];

    XCTAssertNotEqual(data.length, 0);
}

- (void)testGetSomeModuleClasses {

    SRTObjcModuleParser *parser = [SRTObjcModuleParser new];
    NSArray<NSData*> *data = [parser getClassListForModule:1];

    XCTAssertNotEqual(data[0].length, 0);
}

@end
