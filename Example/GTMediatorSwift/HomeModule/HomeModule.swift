//
//  HomeModule.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class HomeModule: NSObject, GTModuleProtocol {
    
    func bundleName() -> String! {
        return "GTMediatorSwift"
    }
    
    func isSwift() -> Bool {
        return true
    }
    
    func modInit(_ context: GTContext!) {
        
    }
    
    func modSetUp(_ context: GTContext!) {
//        GTMediator.shareInstance()!.registerService(HomeServiceProtocol.self, service: HomeViewController.self)
        self.routerAddPathComponents()
    }
    
    
    func routerAddPathComponents() {
        GTRouter.global()?.addPathComponent("HomeModule", for: HomeModule.self)
        GTRouter.global()?.addPathComponent("HomeViewController", for: HomeViewController.self)
        
        
    }
}
