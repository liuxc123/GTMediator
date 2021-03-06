//
//  HomeModule.m
//  GTMediator_Example
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

#import "HomeModule.h"
#import "HomeViewController.h"

@implementation HomeModule

- (void)modInit:(GTContext *)context
{
    switch (context.env) {
        case GTEnvironmentTypeDev:
            //开发环境
            break;

        case GTEnvironmentTypeProd:
            //发布环境
            break;

        default:
            break;
    }
}

- (void)modSetUp:(GTContext *)context
{
    //动态注册Service
    [[GTMediator shareInstance] registerService:@protocol(HomeServiceProtocol) service:[HomeViewController class]];
}

@end
