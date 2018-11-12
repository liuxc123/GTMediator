//
//  AppDelegate.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: GTClientDelegate {


    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        GTContext.shareInstance()?.application = application
        GTContext.shareInstance()?.launchOptions = launchOptions
        //设置模块plist注册文件名
        GTContext.shareInstance()?.moduleConfigName = "GTMediator"

        //是否抛出异常
        GTMediator.shareInstance()?.enableException = true
        //设置全局上下文
        GTMediator.shareInstance()?.context = GTContext.shareInstance()

        super.application(application, didFinishLaunchingWithOptions: launchOptions)

        self.setupWindow()

        //url - >  mediator://call.service.beehive/pathComponentKey.protocolName.selector/...?params={}(value url encode)
        //url - >  mediator://register.beehive/pathComponentKey.protocolName/...?params={}(value url encode)
        //url - >  mediator://jump.vc.beehive/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
        //params -> {pathComponentKey:{paramName:paramValue,...},...}
        //when call service， paramName = @1,@2,...(order of paramValue)
        //        let url = URL(string: "com.liuxc.GTMediatorSwift://jump.vc.beehive/HomeViewController")
        //        let isOpen = GTRouter.canOpen(url! as URL)
        //        print(isOpen)
        //        print(GTRouter.global())

        return true
    }


    func setupWindow() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let HomeTabBarController = GTMediator.shareInstance().createService(HomeServiceProtocol.self) as! UITabBarController
        self.window?.rootViewController = HomeTabBarController
        self.window?.makeKeyAndVisible()
    }

}

