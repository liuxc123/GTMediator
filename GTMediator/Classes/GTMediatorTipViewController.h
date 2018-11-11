//
//  GTMediatorTipViewController.h
//  GTMediator-iOS12.0
//
//  Created by liuxc on 2018/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTMediatorTipViewController : UIViewController

@property (nonatomic, readonly) BOOL isparamsError;
@property (nonatomic, readonly) BOOL isNotURLSupport;
@property (nonatomic, readonly) BOOL isNotFound;

+(nonnull UIViewController *)paramsErrorTipController;

+(nonnull UIViewController *)notURLTipController;

+(nonnull UIViewController *)notFoundTipConctroller;

-(void)showDebugTipController:(nonnull NSURL *)URL
               withParameters:(nullable NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
