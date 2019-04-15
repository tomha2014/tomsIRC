//
//  MasterViewController.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    public var channels: [NSManagedObject] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        navigationItem.leftBarButtonItem = editButtonItem

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannels(_:)))
//        navigationItem.rightBarButtonItem = addButton
        
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        channels = try! dbStore.shared.context.fetch(request)
        
        setUpNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func addChannels(_ sender: Any) {
        
    }
    
//    @objc
//    func insertNewObject(_ sender: Any) {
//        let context = self.fetchedResultsController.managedObjectContext
//        let newEvent = Event(context: context)
//
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = Date() as NSDate
//
//        // Save the context.
//        do {
//            try context.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = channels[indexPath.row] as! IRCChannel
                
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true

            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let t = channels[indexPath.row] as! IRCChannel
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyTestCell")
        
        cell.textLabel?.text = t.name
        cell.detailTextLabel?.text = t.desc        
        cell.accessoryType = .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "showDetail", sender: indexPath)
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        let subscribeAction = UITableViewRowAction(style: .default, title: "un-Subscribe" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            let channel = self.channels[indexPath.row] as! IRCChannel
//            let channel = Settings.shared.channels[indexPath.row] as! IRCChannel
            channel.subscribed = false
            dbStore.shared.Save()
            
            Settings.shared.LeaveChannel(channelName: channel.name!)
            
            //            let i = Settings.shared.joinedChannels.firstIndex(of: channel.name!)
            //            Settings.shared.joinedChannels.remove(at: i!)
            //            Settings.shared.chatroom.leaveChannel(channelName: channel.name!)
            
            let predicate = NSPredicate(format: "subscribed == true" )
            let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
            request.predicate = predicate
            
            self.refreshUI()
            
        })
        
        return [ subscribeAction ]
    }
}

extension MasterViewController {
    func setUpNotifications()  {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMasterChannelList(_:)), name: .updateMasterChannelList, object: nil)
    }
    
    @objc func updateMasterChannelList(_ notification:Notification) {
        refreshUI()
    }
    
    func refreshUI()  {
        let predicate = NSPredicate(format: "subscribed == true" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        channels = try! dbStore.shared.context.fetch(request)
        tableView.reloadData()
    }
}

