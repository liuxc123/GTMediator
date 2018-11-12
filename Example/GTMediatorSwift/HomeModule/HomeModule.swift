//
//  HomeModule.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit


//主页面工程

class HomeModule: NSObject, GTModuleProtocol {

    
    func modInit(_ context: GTContext!) {
        switch context.env {
        case .dev:  //开发
            break

        case .prod: //发布
            break

        case .stage://灰度
            break

        case .test://测试
            break
        }

        NSLog("HomeModule 模块初始化中");
    }
    
    func modSetUp(_ context: GTContext!) {
        GTMediator.shareInstance()!.registerService(HomeServiceProtocol.self, service: HomeViewController.self)
        self.routerAddPathComponents()

        print("HomeModule setup")
    }
    
    
    func routerAddPathComponents() {
        GTRouter.global()?.addPathComponent("HomeModule", for: HomeModule.self)
        GTRouter.global()?.addPathComponent("HomeViewController", for: HomeViewController.self)
    }

    

}
