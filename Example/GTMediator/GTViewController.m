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

@interface GTViewController ()

@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id<HomeServiceProtocol> homeVC = [[GTMediator shareInstance] createService:@protocol(HomeServiceProtocol)];
        [self presentViewController:homeVC animated:true completion:nil];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
