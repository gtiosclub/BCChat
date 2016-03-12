//
//  LoginViewController.swift
//  BCChat
//
//  Created by Brian Wang on 3/8/16.
//  Copyright © 2016 BC. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var facebookButton: UIButton!
    var currentAuthData:FAuthData?
    var currentToken:FBSDKAccessToken?
    var root = Firebase(url: "https://bootcampchat.firebaseio.com")
    let facebookManager = FBSDKLoginManager()
    var name:String = ""
    var fbid:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
   
    //makes the status bar at the top white instead of black
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //login logic. This is disgusting
    @IBAction func loginWithFacebook(sender: UIButton) {
        facebookManager.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                self.loginFailed()
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                self.loginFailed()
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.root.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                            self.loginFailed()
                        } else {
                            print("Logged in! \(authData)")
                            self.facebookButton.setAttributedTitle(NSAttributedString(string: "Logging in..."), forState: .Normal)
                            self.currentAuthData = authData
                            self.currentToken = facebookResult.token
                            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,id"], tokenString:facebookResult.token.tokenString, version: nil, HTTPMethod:"GET")
                            req.startWithCompletionHandler({ (connection, result, error:NSError!) -> Void in
                                if let error = error {
                                    print("error \(error)")
                                } else {
                                    print("name \(result["name"])")
                                    print("id \(result["id"])")
                                    self.name = result["name"] as! String
                                    self.fbid = result["id"] as! String
                                    self.performSegueWithIdentifier("LoginSegue", sender: self)
                                }
                            })
                            
                        }
                })
            }
        })
    }
    
    //called when facebook or firebase fails
    func loginFailed() {
        self.facebookButton.setAttributedTitle(NSAttributedString(string: "Login Failed"), forState: .Normal)
       
    }

    //called before going to the next scene
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ChatViewController
        if let currentAuthData = currentAuthData, currentToken = currentToken {
            dest.authData = currentAuthData
            dest.token = currentToken
            dest.name = self.name
            dest.fbid = self.fbid
            
        }
    }

}
