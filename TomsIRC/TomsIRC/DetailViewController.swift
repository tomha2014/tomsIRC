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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputArea: UIView!
    @IBOutlet weak var sendTextInput: UITextField!
    
//    var messages = [Message]()
    public var channelName = ""
    
    var grpManger = GroupManager()
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            self.channelName = detail.name!
//            print (detail.name)
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
        
        grpManger.buildOutTableDate(channelName: channelName)
    }
    
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = self.channelName;
        self.tableView.separatorColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewMessageRecieved(_:)), name: .NewMessageRecieved, object: nil)
        
    }
    
    @objc func NewMessageRecieved(_ notification:Notification) {
        let msg = notification.object as! Message
        
        if (msg.channelName == channelName)
        {
            insertNewMessageCell(msg)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let txt = sendTextInput!.text
        if ((txt?.count)!>0)
        {
            let msg1 = Message(message: txt!, messageSender: MessageSender.ourself, username: Settings.shared.userName)
            
            Settings.shared.chatroom.sendMessage(message: txt!, channelName: self.channelName)
            
            let msg = IRCMessage(context: dbStore.shared.context)
            msg.timestamp = Date() as NSDate
            msg.timestampMilli = Int64( Date().millisecondsSince1970 )
            msg.channelName = channelName
            msg.from = Settings.shared.userName
            msg.message = txt!
            dbStore.shared.Save()
            
            insertNewMessageCell( msg1 )
            
            self.sendTextInput.text = ""
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
        
        let mGrp = grpManger.getGroupByIndex(index: indexPath.section)
        
        
        let message = mGrp!.messages[indexPath.row]
        
        let cell = MessageTableViewCell(style: .default, reuseIdentifier: "MessageCell")
        cell.selectionStyle = .none
        
         //messages[indexPath.row]
        cell.apply(message: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = grpManger.getGroupByIndex(index: section)?.getMessageCount()
        return count!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return grpManger.getNumberOfGroups()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let mGrp = grpManger.getGroupByIndex(index: section)
        return "\(mGrp!.date.toHeaderString())  "
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mGrp = grpManger.getGroupByIndex(index: indexPath.section)
        let message = (mGrp?.getMessageByIndex(index: indexPath.row))!
        let height = MessageTableViewCell.height(for: message)
        return height
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: tableView.separatorInset.left, y: footerView.frame.height+10, width: tableView.frame.width - tableView.separatorInset.right - tableView.separatorInset.left, height: 30))
        label.textAlignment = .left
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        let mGrp = grpManger.getGroupByIndex(index: section)
        
        label.text = "\(mGrp!.date.toHeaderString())"
        footerView.addSubview(label)
        
        
        let separatorView = UIView(frame: CGRect(x: tableView.separatorInset.left, y: footerView.frame.height+40, width: tableView.frame.width - tableView.separatorInset.right - tableView.separatorInset.left, height: 1))
        separatorView.backgroundColor = UIColor.blue
        footerView.addSubview(separatorView)
        return footerView
    }
    
    
    
    func insertNewMessageCell(_ message: Message) {
        
        grpManger.buildOutTableDate(channelName: channelName)
        self.tableView.reloadData()
    
        
        
//
//        let msgGrp = grpManger.findTodaysGroup()
//        print (msgGrp?.getMessageCount())
//        //msgGrp!.getMessageCount() - 1
//
//
//        let c = tableView.numberOfRows(inSection: msgGrp!.id-1)
//        let indexPath = IndexPath(row: c, section: msgGrp!.id-1)
//        tableView.beginUpdates()
//        tableView.insertRows(at: [indexPath], with: .bottom)
//        tableView.endUpdates()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

