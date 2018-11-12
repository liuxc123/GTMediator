//
//  TradeModule.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/12.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class TradeModule: NSObject, GTModuleProtocol {

    func modSetUp(_ context: GTContext!) {
        GTMediator.shareInstance().registerService(TradeServiceProtocol.self, service: TradeServiceImpl.self)

        print("TradeModule setup")
    }

    func modInit(_ context: GTContext!) {
        print("TradeModule 模块初始化")
    }

}
