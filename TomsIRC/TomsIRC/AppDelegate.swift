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

    var alertDlg:UIAlertController = UIAlertController(title: "Start up", message: "Please wait while I connect to your IRC sever", preferredStyle: .alert)
    var window: UIWindow?
    public var channels: [NSManagedObject] = []

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
        
        Settings.shared.chatroom.sendQuitCommand()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        if Settings.shared.okToConnect()
        {
            if (!Settings.shared.connected())
            {
                self.window?.rootViewController!.present(self.alertDlg, animated: true)
                Settings.shared.chatroom.setupNetworkCommunication()
            }
        }
        setUpNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Settings.shared.chatroom.sendQuitCommand()
        dbStore.shared.Save()
        Settings.shared.chatroom.stopChatSession()
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
        NotificationCenter.default.addObserver(self, selector: #selector(commandRecieved(_:)), name: .commandRecieved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewPrivateMessageRecieved(_:)), name: .NewPrivateMessageRecieved, object: nil)

    }
    
    @objc func NewPrivateMessageRecieved(_ notification:Notification) {
        
        print ("new private mesg")

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
        
        Settings.shared.AllChannels = try! dbStore.shared.context.fetch(request)
        
        if (Settings.shared.AllChannels.count > 0)
        {
            joinChannels()
//            Settings.shared.chatroom.listChannels()
        }
        
        self.alertDlg.dismiss(animated: true, completion: nil)
    }
    
    @objc func channelListComplete(_ notification:Notification) {
        // Do something now
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        
        Settings.shared.AllChannels = try! dbStore.shared.context.fetch(request)
        
    }
    
    
    
    @objc func readyToLogin(_ notification:Notification) {
        // Do something now
        
//        self.alertDlg = UIAlertController(title: "Start", message: "Please wait while I connect to your sever", preferredStyle: .alert)
        
        
        Settings.shared.chatroom.loginMode = true
        var message = "NICK \(Settings.shared.userName)"
        Settings.shared.chatroom.sendCmd(message: message)
        
        message = "user \(Settings.shared.userName) localhost localhost :I'm nobody nick nobody"
        Settings.shared.chatroom.sendCmd(message: message)
        
        Settings.shared.chatroom.login(nickName: Settings.shared.userName, pw: Settings.shared.password)
        
    }
    
    @objc func commandRecieved(_ notification:Notification)
    {
        let cmdCode = notification.object as! CmdMsg
        print (cmdCode.msg)
        if (cmdCode.cmd == "465")
        {
            let alert = UIAlertController(title: "Alert", message: cmdCode.msg, preferredStyle: .alert)
            self.window?.rootViewController!.present(alert, animated: true, completion: nil)
        }
        
        if (cmdCode.cmd=="INVITE")
        {
            
            let parts = cmdCode.msg.split(separator: ":")
            
            let msg = "Would you like to join channel :"+parts.last!            
            
            let alert = UIAlertController(title: "Invitation", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let channel = IRCChannel(context: dbStore.shared.context)
                channel.name = String(parts.last!)
                channel.count = Int32(-1)
                channel.desc = ""
                channel.serverID = Settings.shared.serverID
                channel.subscribed = true
                dbStore.shared.Save()
                
                let splitViewController = self.window!.rootViewController as! UISplitViewController
                let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
                let controller = masterNavigationController.topViewController as! MasterViewController
                controller.refreshUI()
                
                Settings.shared.chatroom.joinChannel(channelName: channel.name!)
                Settings.shared.joinedChannels.append(channel.name!)
            }))
            
            self.window?.rootViewController!.present(alert, animated: true)
        }
    }
    
    func joinChannels()
    {
        
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        channels = try! dbStore.shared.context.fetch(request)
        
        
        for i in 0..<channels.count
        {
            let c = channels[i] as! IRCChannel
            Settings.shared.chatroom.joinChannel(channelName: c.name!)
            Settings.shared.joinedChannels.append(c.name!)
        }
    }
    
    

}
