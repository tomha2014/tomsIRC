//
//  DetailViewController.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import UIKit
import CoreData


class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    public var msgs: [NSManagedObject] = []
    
//    var messages = [Message]()
    public var channelName = ""
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            self.channelName = detail.name!
            print (detail.name)
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: IRCChannel? {
        didSet {
            // Update the view.
//            configureView()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let predicate = NSPredicate(format: "channelName == '\(channelName)'" )
        let request: NSFetchRequest<IRCMessage> = IRCMessage.fetchRequest()
        request.predicate = predicate
        //        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        //        request.sortDescriptors = [sortDescriptor]
        
        var groupCount = Settings.shared.groups.count
        msgs = try! dbStore.shared.context.fetch(request)
        let c = msgs.count
        for i in 0..<msgs.count
        {
            let msg = msgs[i] as! IRCMessage
            let group = findGroupId(date: msg.timestamp! as Date)
            let m = Message(message: msg.message!, messageSender: .someoneElse, username: msg.from!, date: msg.timestamp! as Date, groupID: group.id)
//            messages.append(m)
            group.messages.append(m)
        }
        
        if (c>0)
        {
            groupCount = Settings.shared.groups.count
            groupCount = Settings.shared.groups.count
        }
    }
    
    
    
    func findGroupId(date:Date) -> MessageGroup {
        
        let dStr = date.toDateString()
//        print ( dStr )

        if (Settings.shared.groups.isEmpty)
        {
            Settings.shared.todaysGroupID = Settings.shared.todaysGroupID + 1;
            let group = MessageGroup(date: date, id: Settings.shared.todaysGroupID)
            group.msgCount = group.msgCount + 1
            Settings.shared.groups.append(group)
            return group
        }
        
        for g in Settings.shared.groups
        {
            let ds = g.date.toDateString()
            if (ds == dStr)
            {
                g.msgCount = g.msgCount + 1
                return g
            }
        }
        
        let group = MessageGroup(date: date, id: Settings.shared.todaysGroupID)
        group.msgCount = group.msgCount + 1
        Settings.shared.groups.append(group)
        return group
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = self.channelName;
        self.tableView.separatorColor = .clear
        
        //        if (Settings.shared.chatroom.inputStream.streamStatus == .open)
        //        {
        //            Settings.shared.chatroom.joinChannel(channelName: channelName)
        //            Settings.shared.chatroom.namesChannel(channelName: channelName)
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let txt = self.textInput.text
        if ((txt?.count)!>0)
        {
            
            Settings.shared.chatroom.sendMessage(message: txt!, channelName: self.channelName)
            insertNewMessageCell( Message(message: txt!, messageSender: MessageSender.ourself, username: Settings.shared.userName,groupID: Settings.shared.todaysGroupID))
            self.textInput.text = ""
        }
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let userInfo = notification.userInfo
        {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
            UIView.animate(withDuration: 0.25)
            {
                if (notification.name == UIResponder.keyboardWillShowNotification)
                {
                    self.view.frame.origin.y = -endFrame.height
                }
                else{
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
    
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mGrp = Settings.shared.groups[indexPath.section]
        let message = mGrp.messages[indexPath.row]
        
        let cell = MessageTableViewCell(style: .default, reuseIdentifier: "MessageCell")
        cell.selectionStyle = .none
        
         //messages[indexPath.row]
        cell.apply(message: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = Settings.shared.groups[section].msgCount
        return count

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Settings.shared.groups.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let mGrp = Settings.shared.groups[section]
        return "\(mGrp.date.toHeaderString())"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mGrp = Settings.shared.groups[indexPath.section]
        let message = mGrp.messages[indexPath.row]
        let height = MessageTableViewCell.height(for: message)
        return height
    }
    
    func insertNewMessageCell(_ message: Message) {
//        messages.append(message)
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.beginUpdates()
//        tableView.insertRows(at: [indexPath], with: .bottom)
//        tableView.endUpdates()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

