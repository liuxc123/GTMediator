//
//  HomeViewController.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, HomeServiceProtocol {

    var registerViewControllers = [UIViewController]()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        if let userTrackService = GTMediator.shareInstance().createService(UserTrackServiceProtocol.self) as? UserTrackServiceProtocol {
            let userTrackVC = userTrackService.getUserTrackViewController()
            let userTrackNavi = UINavigationController(rootViewController: userTrackVC)
            self.registerViewController(vc: userTrackNavi, title: "userTrack", iconName: "")
        }


        if let tradeService = GTMediator.shareInstance().createService(TradeServiceProtocol.self) as? TradeServiceProtocol {
            let tradeVC = tradeService.getTradeViewController()
            let tradeNavi = UINavigationController(rootViewController: tradeVC)
            self.registerViewController(vc: tradeNavi, title: "trade", iconName: nil)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white


    }


    func registerViewController(vc: UIViewController, title: String, iconName: String?) {
        vc.tabBarItem.image = UIImage(named: "Home.bundle\(String(describing: iconName))")
        vc.tabBarItem.title = title;
        self.registerViewControllers.append(vc)
        self.viewControllers = self.registerViewControllers
    }



    


    //设置为单例
    static func singleton() -> Bool {
        return true
    }

}
