//
//  GTDefines.h
//  Pods
//
//  Created by liuxc on 2018/11/10.
//

#ifndef GTDefines_h
#define GTDefines_h

#if defined(__cplusplus)
#define GT_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define GT_EXTERN extern __attribute__((visibility("default")))
#endif

#endif /* GTDefines_h */
