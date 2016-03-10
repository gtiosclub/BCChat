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
    
    var currentAuthData:FAuthData?
    var currentToken:FBSDKAccessToken?

    var root = Firebase(url: "https://bootcampchatapp.firebaseio.com")
    let facebookManager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }
    
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
    
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        facebookManager.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.root.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            self.currentAuthData = authData
                            self.currentToken = facebookResult.token
                            self.performSegueWithIdentifier("LoginSegue", sender: self)
                            
                        }
                })
            }
        })
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ChatViewController
        if let currentAuthData = currentAuthData, currentToken = currentToken {
            dest.authData = currentAuthData
            dest.token = currentToken
            
        }
    }

}
