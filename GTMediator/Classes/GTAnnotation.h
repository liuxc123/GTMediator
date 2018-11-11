//
//  GTAnnotation.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>
#import "GTMediator.h"

/**
 Annotation注释
 1. 添加Module模块
 2. 添加Service服务
 */

#ifndef GTMediatorModSectName

#define GTMediatorModSectName "GTMediatorMods"

#endif

#ifndef GTMediatorServiceSectName

#define GTMediatorServiceSectName "GTMediatorServices"

#endif


#define GTMediatorDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))



#define GTMediatorMod(name) \
class GTMediator; char * k##name##_mod GTMediatorDATA(GTMediatorMods) = ""#name"";

#define GTMediatorService(servicename,impl) \
class GTMediator; char * k##servicename##_service GTMediatorDATA(BeehiveServices) = "{ \""#servicename"\" : \""#impl"\"}";




@interface GTAnnotation : NSObject

@end

