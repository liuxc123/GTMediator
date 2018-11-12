//
//  TradeServiceImpl.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/12.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class TradeServiceImpl: NSObject, TradeServiceProtocol {

    @objc func getTradeViewController() -> TradeViewController {
        return TradeViewController()
    }

}
