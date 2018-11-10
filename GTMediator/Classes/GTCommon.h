//
//  GTCommon.h
//  Pods
//
//  Created by liuxc on 2018/11/10.
//

#ifndef GTCommon_h
#define GTCommon_h

// Debug Logging
#ifdef DEBUG
#define GTLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define GTLog(x, ...)
#endif

#endif /* GTCommon_h */
