//
//  UIViewController+NavigationTip.m
//  GTMediator-iOS12.0
//
//  Created by liuxc on 2018/11/11.
//

#import "UIViewController+NavigationTip.h"
#import "GTMediatorTipViewController.h"

@implementation UIViewController (NavigationTip)

+(nonnull UIViewController *) paramsError{
    return [GTMediatorTipViewController paramsErrorTipController];
}


+(nonnull UIViewController *) notFound{
    return [GTMediatorTipViewController notFoundTipConctroller];
}


+(nonnull UIViewController *) notURLController{
    return [GTMediatorTipViewController notURLTipController];
}

@end
