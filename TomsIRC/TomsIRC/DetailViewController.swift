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
    
    var messages = [Message]()
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
        
        msgs = try! dbStore.shared.context.fetch(request)
        //        let c = msgs.count
        for i in 0..<msgs.count
        {
            let msg = msgs[i] as! IRCMessage
            let m = Message(message: msg.message!, messageSender: .someoneElse, username: msg.from!, date: msg.timestamp! as Date)
            messages.append(m)
        }
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
            insertNewMessageCell( Message(message: txt!, messageSender: MessageSender.ourself, username: Settings.shared.userName))
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
        let cell = MessageTableViewCell(style: .default, reuseIdentifier: "MessageCell")
        cell.selectionStyle = .none
        
        let message = messages[indexPath.row]
        cell.apply(message: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = MessageTableViewCell.height(for: messages[indexPath.row])
        return height
    }
    
    func insertNewMessageCell(_ message: Message) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

