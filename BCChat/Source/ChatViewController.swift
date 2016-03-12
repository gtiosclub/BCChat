//
//  ChatViewController.swift
//  BCChat
//
//  Created by Brian Wang on 3/9/16.
//  Copyright © 2016 BC. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //===========================================================================
    //MARK: - VARIABLES
    //===========================================================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var containerViewBottom: NSLayoutConstraint!
    var name:String = ""
    var fbid:String = ""
    var root = Firebase(url: "https://bootcampchat.firebaseio.com")
    var token: FBSDKAccessToken!
    var authData:FAuthData!
    var sortedMessages:[Message] = [] {
        didSet {
            self.sortedMessages.sortInPlace({ leftMessage, rightMessage in
                let leftDate = leftMessage.date()
                let rightDate = rightMessage.date()
                return leftDate > rightDate
            })
            reloadTable()
        }
    }
    
    //===========================================================================
    //MARK: - SETUP
    //===========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView Setup
        tableView.delegate = self
        tableView.dataSource = self
        
        //rotate the tableView upside down so that messages appear from bottom-top, not top-bottom
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        
        //makes it so that row height is dynamic for each cell, which wraps around the text.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        //TapGesture Setup
        self.view.userInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: Selector("touchReceived:"))
        self.view.addGestureRecognizer(gesture)
        
        //Keyboard Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidAppear:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidDisappear", name: UIKeyboardWillHideNotification, object: nil)
    }
   
    //every time the view loads up, load up messages
    override func viewWillAppear(animated: Bool) {
        receiveMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //===========================================================================
    //MARK: - FIREBASE
    //===========================================================================
    
    func receiveMessages() {
        let messagesRoot = root.childByAppendingPath("messages")
        //query for every message. This block gets called for each individual message
        messagesRoot.observeEventType(.ChildAdded, withBlock: {messageSnapshot in
            //print("\(messageSnapshot)\n")
            var m = Message()
            m.timeStamp = String(messageSnapshot.value["timestamp"])
            m.uid = messageSnapshot.value["uid"] as! String
            m.message = messageSnapshot.value["message"] as! String
            let uidRoot = self.root.childByAppendingPath("users/\(m.uid)")
            
            
            //after you get uid from message, query for name and platform from users/{uid from message}
            uidRoot.observeEventType(.Value, withBlock: {uidSnapshot in
                //print("\(uidSnapshot)\n")
                if let snapshotValue = uidSnapshot.value {
                    //if it exists, set name/platform of message. Otherwise, skip.
                    if snapshotValue["name"] != nil {
                        m.name = snapshotValue["name"] as! String
                    }
                    if snapshotValue["platform"] != nil {
                        m.platform = snapshotValue["platform"] as! String
                    }
                }
                self.sortedMessages.append(m)
            })
        })
    }

    @IBAction func sendMessage(sender: UIButton) {
        //check if message is empty
        if messageField.text == "" {
            shakeMessageFieldX()
            return
        }
        
        //add message
        let messagesRoot = root.childByAppendingPath("messages")
        let messageKeyRoot = messagesRoot.childByAutoId()
        let messagePOST = [
            "uid": authData.uid,
            "timestamp": FirebaseServerValue.timestamp(),
            "message": messageField.text!,
        ]
        messageKeyRoot.setValue(messagePOST)
        
        //add user
        let uid = authData.uid
        let uidRoot = root.childByAppendingPath("users/\(uid)")
        let userPOST = [
            "name":self.name,
            "platform": "ios"
        ]
        uidRoot.setValue(userPOST)
        
        //clear message
        messageField.text = ""
        
    }
    
    
    //===========================================================================
    //MARK: - KEYBOARD
    //===========================================================================
    
    //removes keyboard when touched
    func touchReceived(gesture:UITapGestureRecognizer) {
        let touch = gesture.locationInView(self.view)
        if !CGRectContainsPoint(containerView.frame, touch) {
            messageField.resignFirstResponder()
        }
    }
    
    //keyboard appearing animation
    //makes messageField and Send button visible above keyboard
    func keyboardDidAppear(notification:NSNotification) {
        if let userInfo = notification.userInfo, frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue {
            let height = frame().height
            UIView.animateWithDuration(0.3, animations: {
                self.containerViewBottom.constant = height
                self.view.layoutIfNeeded()
            })
            scrollToBottom()
        }
    }
    
    //keyboard disappearing animation
    //makes messageField and Send button back to the bottom of screen.
    func keyboardDidDisappear() {
        UIView.animateWithDuration(0.3, animations: {
            self.containerViewBottom.constant = 0
            self.view.layoutIfNeeded()
        })
        scrollToBottom()
    }
}

extension ChatViewController {
    
    //===========================================================================
    //MARK: - TABLE VIEW
    //===========================================================================
    
    //creates a message for how ever many messages there are. This function gets called for each index.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! ChatTableViewCell
        let row = Int(indexPath.row)
        let m = sortedMessages[row]
        cell.nameLabel.text = m.name
        cell.messageLabel.text = m.message
        cell.dateLabel.text = m.dateString()
        
        //since tableView is rotated, cell has to be rotated to be upright.
        cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        return cell
    }
    
    //returns number of messages
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedMessages.count
    }
    
    //animates the table every time the table is reloaded
    func reloadTable() {
        tableView.reloadData()
        scrollToBottom()
    }
    
    //===========================================================================
    //MARK: - ANIMATIONS
    //===========================================================================
    
    //shakes on an message error
    func shakeMessageFieldX() {
        let animations:[CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0.0]
        
        for i in 0..<animations.count {
            let frameOrigin = CGPointMake(self.messageField.frame.origin.x + animations[i], self.messageField.frame.origin.y)
            UIView.animateWithDuration(0.075, delay: 0.075 * Double(i), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.messageField.frame.origin = frameOrigin
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    //scrolls the table to the bottom of the messages.
    func scrollToBottom() {
        if sortedMessages.isEmpty {
            return
        }
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
}

