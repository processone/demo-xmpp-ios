//
//  LoginViewController.swift
//  testSWIFTXMPPF
//
//  Created by Paul on 30/07/2015.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet var loginTextField: UITextField!
	@IBOutlet var passwordTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		loginTextField.text = "yourLogin@gmail.com"
		passwordTextField.text = "yourPassword"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func login(sender: AnyObject) {
		NSUserDefaults.standardUserDefaults().setObject(loginTextField.text!, forKey: "userID")
		NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text!, forKey: "userPassword")
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if appDelegate.connect() {
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	@IBAction func done(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}
