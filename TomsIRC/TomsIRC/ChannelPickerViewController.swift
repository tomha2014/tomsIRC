//
//  ChannelPickerViewController.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/20/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import UIKit
import CoreData

class ChannelPickerViewController: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive:Bool = false
//    private let refreshControl = UIRefreshControl()
public var AllChannels: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchbar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        let predicate = NSPredicate(format: "subscribed == false" )
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
//        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        AllChannels = try! dbStore.shared.context.fetch(request)
        
//        if #available(iOS 10.0, *) {
//            tableView.refreshControl = refreshControl
//        } else {
//            tableView.addSubview(refreshControl)
//        }
        
        self.navigationItem.title = "Channel Tuner"
//        refreshControl.addTarget(self, action: #selector(refreshChannelList(_:)), for: .valueChanged)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addChannel))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let userInfo = notification.userInfo
        {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
            UIView.animate(withDuration: 0.25)
            {
                if (notification.name == UIResponder.keyboardWillShowNotification)
                {
                    self.tableView.frame.size.height = self.tableView.frame.size.height - (endFrame.height-30 )
//                    self.view.frame.origin.y = -endFrame.height
//                    self.view.frame.size.height = self.view.frame.size.height - (endFrame.height + 100)
                    
                }
                else{
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
//    @objc private func addChannel(_ sender: Any) {
//        Settings.shared.chatroom.save(name: "BubbleTest", count: 0, desc: "Bubble Test channel")
//         dbStore.shared.Save()
//
////        let predicate = NSPredicate(format: "subscribed == false" )
//        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
//        //        request.predicate = predicate
//
//        Settings.shared.channels = try! dbStore.shared.context.fetch(request)
//
//
//
//        self.tableView.reloadData()
//    }
    
    @objc private func refreshChannelList(_ sender: Any) {
        // Fetch Weather Data
        Settings.shared.chatroom.listChannels()
//        refreshControl.beginRefreshing()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ChannelPickerViewController: UITableViewDelegate{

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        let subscribeAction = UITableViewRowAction(style: .default, title: "Subscribe" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in

            let channel = self.AllChannels[indexPath.row] as! IRCChannel
            channel.subscribed = true
            dbStore.shared.Save()
            
            NotificationCenter.default.post(name: .updateMasterChannelList, object:nil)
            
        })
        
        return [ subscribeAction ]
    }
    
}

extension ChannelPickerViewController: UISearchBarDelegate{
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        AllChannels = try! dbStore.shared.context.fetch(request)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        if (searchText.count > 0)
        {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            request.predicate = predicate
        }
        
        AllChannels = try! dbStore.shared.context.fetch(request)
        
        self.tableView.reloadData()
    }
}


extension ChannelPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return AllChannels.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            print ("\(AllChannels.count) \(indexPath.row)")
            
            let t = AllChannels[indexPath.row] as! IRCChannel
            
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyTestCell")
            
            cell.textLabel?.text = t.name
            cell.detailTextLabel?.text = t.desc
            
            cell.accessoryType = .none
            
            if t.subscribed
            {
                cell.accessoryType = .checkmark
            }

            return cell
    }
}

//extension ChannelPickerViewController: ChatRoomDelegate {
//
//    func commandReceived(cmd: String) {
//
//    }
//    func LoginComplete() {
//        Settings.shared.chatroom.listChannels()
//    }
//
//    func receivedMessage(message: Message) {
//        //        insertNewMessageCell(message)
//    }
//
//    func sentMessage(message: String) {
//        //        insertNewMessageCell( Message(message: message, messageSender: MessageSender.ourself, username: username))
//    }
//
//
//
//    func channelListComplete()  {
//        let predicate = NSPredicate(format: "subscribed == false" )
//        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
////        request.predicate = predicate
//
////        refreshControl.endRefreshing()
//        Settings.shared.channels = try! dbStore.shared.context.fetch(request)
//        self.tableView.reloadData()
//    }
//
//}
