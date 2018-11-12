//
//  HomeServiceProtocol.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import Foundation

@objc protocol HomeServiceProtocol: GTServiceProtocol {

    /// 注册tab页面
    func registerViewController(vc: UIViewController, title: String, iconName: String?)

}
