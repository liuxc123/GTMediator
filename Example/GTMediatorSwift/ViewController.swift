//
//  ViewController.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "首页"


        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            //url - >  mediator://call.service.beehive/pathComponentKey.protocolName.selector/...?params={}(value url encode)
            //url - >  mediator://register.beehive/pathComponentKey.protocolName/...?params={}(value url encode)
            //url - >  mediator://jump.vc.beehive/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
            //params -> {pathComponentKey:{paramName:paramValue,...},...}
            //when call service， paramName = @1,@2,...(order of paramValue)

            //params={"HomeViewController":{"user_id":5}}
//            let url = URL(string: "com.liuxc.mediator://jump.vc.mediator/HomeViewController?params=%7b%22HomeViewController%22%3a%7b%22user_id%22%3a5%7d%7d")
//
//            GTRouter.open(url)
//            GTRouter.open(url, withParams: ["HomeViewController": ["userId": 15]], andThen: { (pathComponentKey, obj, returnValue) in
//
//                print(pathComponentKey)
//                print(obj)
//                print(returnValue)
//            });

            let homeVC = GTMediator.shareInstance().createService(HomeServiceProtocol.self)
            GTMediatorNavigator.shareInstance().show(homeVC as! UIViewController, baseViewController: self, routeMode: .push)
        }
    }


}

