//
//  GTViewController.m
//  GTMediator
//
//  Created by liuxc123 on 10/30/2018.
//  Copyright (c) 2018 liuxc123. All rights reserved.
//

#import "GTViewController.h"
#import "HomeServiceProtocol.h"
#import "GTMediator.h"
#import "GTRouter.h"

@interface GTViewController ()

@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        id<HomeServiceProtocol> homeVC = [[GTMediator shareInstance] createService:@protocol(HomeServiceProtocol)];
//        [self presentViewController:(UIViewController *)homeVC animated:true completion:nil];\
        
        NSURL *url = [NSURL URLWithString:@"mediator://jump.vc.beehive/HomeViewController#modal"];
        
        //url - >  mediator://call.service.beehive/pathComponentKey.protocolName.selector/...?params={}(value url encode)
        //url - >  mediator://register.beehive/pathComponentKey.protocolName/...?params={}(value url encode)
        //url - >  mediator://jump.vc.beehive/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
        //params -> {pathComponentKey:{paramName:paramValue,...},...}
        //when call service， paramName = @1,@2,...(order of paramValue)
        [GTRouter openURL:url withParams:@{@"HomeViewController": @{@"user_id": @15}} andThen:^(NSString *pathComponentKey, id obj, id returnValue) {
            NSLog(@"%@", pathComponentKey);
        }];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
