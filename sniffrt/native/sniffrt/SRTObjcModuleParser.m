#import "SRTObjcModuleParser.h"
#import "SRTClassInfo.h"
#import "Classinfo.pbobjc.h"

#include <objc/runtime.h>
#include <mach/task.h>
#include <mach-o/dyld_images.h>
#include <dlfcn.h>

typedef struct dyld_image_info image_info;

@implementation SRTObjcModuleParser
{
    const char **modules;
    uint32_t modules_count;
    
    int main_module_id;
}

-(id) init
{
    if ( self = [super init] ) {

        modules = NULL;
        modules_count = 0;
        main_module_id = -1;

        [self readModuleList];

        return self;
    } else return nil;
}


/**
 * Return message with all classes in requested module.
 */
-(NSArray<NSData*>*) getClassListForModule:(uint64_t) module_id
{
    if (module_id >= modules_count) @throw [NSException exceptionWithName:@"SRTException"
                                                                   reason:@"Wrong module id"
                                                                 userInfo:nil];
    
    NSMutableArray<NSData*> *ret_data = [NSMutableArray<NSData*> array];
    
    unsigned int classes_count;
    const char ** classes = objc_copyClassNamesForImage(modules[module_id], &classes_count);
    for (int i = 0; i < classes_count; i++) {
        SRTClassInfo *cls_info = [SRTClassInfo classInfoByName:classes[i]
                                                  withModuleId:module_id];
        [ret_data addObject: cls_info.serialize];
    }

    return ret_data;
}

/**
 * Return ModuleList information in serialized form.
 */
-(NSData*) getModuleList
{
    Response *responce = [Response message];

    responce.type = Response_Type_ModuleList;
    responce.moduleList.mainModuleId = main_module_id;
    
    for (int i = 0; i < modules_count; i++) {
        
        Response_ModulesListInfo_ModuleInfo *module = [Response_ModulesListInfo_ModuleInfo message];
        module.name = [NSString stringWithUTF8String:modules[i]];
        module.id_p = i; // module Id is an index in modules array
        
        /**
         * There is no function to get only number of classes.
         * So we use objc_copyClassNamesForImage and free result array. 
         */
        unsigned int classes_count;
        const char ** classes = objc_copyClassNamesForImage(modules[i], &classes_count);
        free(classes);
        
        module.classesCount = classes_count;
        
        [responce.moduleList.modulesArray addObject:module];
    }

    return [responce data];
}

-(void) readModuleList
{
    modules = objc_copyImageNames(&modules_count);
    
    void* executable_entry= dlsym(RTLD_DEFAULT, "_mh_execute_header");
    
    Dl_info info;
    int res = dladdr(executable_entry, &info);
    if (res == 0) @throw [NSException exceptionWithName:@"RuntimeException"
                                                 reason:@"Was not able to find main executable module"
                                               userInfo:nil];
    
    /** Try to find main executable in loaded module list */
    for (int i = 0; i<modules_count; i++) {
        if ( !strcmp(info.dli_fname, modules[i]) ) {
            main_module_id = i;
            break;
        }
    }
    if (main_module_id == -1) @throw [NSException exceptionWithName:@"RuntimeException"
                                                             reason:@"Was not able to find main executable module loaded"
                                                           userInfo:nil];
}

-(void) dealloc {
    if (modules) free(modules);
}

@end
