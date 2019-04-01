//
//  AppDelegate.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import UIKit
import CoreData
//import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
//        controller.managedObjectContext = self.persistentContainer.viewContext
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if Settings.shared.okToConnect(){
            if (!Settings.shared.connected())
            {
//                Settings.shared.chatroom.delegate = self
                Settings.shared.chatroom.setupNetworkCommunication()
            }
        }
        setUpNotifications()
    }
    
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        dbStore.shared.Save()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    

}

extension AppDelegate {
    func setUpNotifications()  {
        NotificationCenter.default.addObserver(self, selector: #selector(loginComplete(_:)), name: .loginComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(channelListComplete(_:)), name: .channelListComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readyToLogin(_:)), name: .readyToLogin, object: nil)

    }
    
    @objc func loginComplete(_ notification:Notification) {
        // Do something now
        //        self.removeSpinner()
        print ("Login Complete")
        
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        Settings.shared.channels = try! dbStore.shared.context.fetch(request)
        
        if (Settings.shared.channels.count == 0)
        {
            Settings.shared.chatroom.listChannels()
        }
        
    }
    
    @objc func channelListComplete(_ notification:Notification) {
        // Do something now
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        
        Settings.shared.channels = try! dbStore.shared.context.fetch(request)
    }
    
    @objc func readyToLogin(_ notification:Notification) {
        // Do something now
        
        Settings.shared.chatroom.loginMode = true
        var message = "NICK \(Settings.shared.userName)"
        Settings.shared.chatroom.sendCmd(message: message)
        
        message = "user \(Settings.shared.userName) localhost localhost :I'm nobody nick nobody"
        Settings.shared.chatroom.sendCmd(message: message)
        
        Settings.shared.chatroom.login(nickName: Settings.shared.userName, pw: Settings.shared.password)
        
    }

}

//extension AppDelegate: ChatRoomDelegate {
//
//    func commandReceived(cmd: String) {}
//    func receivedMessage(message: Message) {}
//    func sentMessage(message: String) {}
//}
