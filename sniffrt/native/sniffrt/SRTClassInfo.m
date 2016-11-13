#import "SRTClassInfo.h"
#import "Classinfo.pbobjc.h"

#import <objc/runtime.h>

@implementation SRTClassInfo

+(id) classInfoByName:(const char*) name withModuleId:(int64_t) module_id
{
    SRTClassInfo *cls_info = [SRTClassInfo classInfoByName:name];
    [cls_info setModuleId:module_id];
    
    return cls_info;
}

+(id) classInfoByName:(const char*) name
{
    return [[SRTClassInfo alloc] initWithName:name];
}

-(id) initWithName:(const char*) name
{
    self = [super init];
    if (!self) return nil;
    
    Class cls = objc_getClass(name);

    Response_ClassInfo *payload_part = [Response_ClassInfo message];
    payload_part.name = @(name);
    payload_part.id_p = (int64_t)cls; // id is a pointer on Class struct
    payload_part.superClassId = (int64_t)class_getSuperclass(cls);
    
    /**
     * Instance Metghods filling
     */
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);

    for (int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        Response_ClassInfo_MethodInfo *method_payload_part = [Response_ClassInfo_MethodInfo message];
        method_payload_part.selector = @( sel_getName(method_getName(method)) );
        method_payload_part.typeEncoding = @( method_getTypeEncoding(method) );

        [payload_part.methodsArray addObject:method_payload_part];
    }
    free(methods);

    /**
     * Ivars filling
     */
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);

    for (int i = 0; i < ivarCount; i++) {
        Ivar ivar = ivars[i];
        
        Response_ClassInfo_IvarInfo *ivar_payload_part = [Response_ClassInfo_IvarInfo message];
        ivar_payload_part.name = @( ivar_getName(ivar) );
        ivar_payload_part.typeEncoding = @( ivar_getTypeEncoding(ivar) );

        [payload_part.ivarsArray addObject:ivar_payload_part];
    }
    free(ivars);

    /**
     * Protocols filling
     */
    unsigned int prptocolCount = 0;
    Protocol* __unsafe_unretained *protocols = class_copyProtocolList(cls, &prptocolCount);

    for (int i = 0; i < prptocolCount; i++) {
        Protocol *proto = protocols[i];

        Response_ClassInfo_ProtocolInfo *proto_payload_part = [Response_ClassInfo_ProtocolInfo message];
        proto_payload_part.name = @( protocol_getName(proto) );
        
        [payload_part.protocolsArray addObject:proto_payload_part];
    }
    free(protocols);
    
    payload = [Response message];
    payload.type = Response_Type_Class;
    payload.classInfo = payload_part;

    return self;
}

-(void) setModuleId:(int64_t) module_id
{
    payload.classInfo.moduleId = module_id;
}

-(NSData*) serialize
{
    return [payload data];
}

@end
