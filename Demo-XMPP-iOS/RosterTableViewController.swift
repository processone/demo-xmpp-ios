//
//  ViewController.swift
//  testSWIFTXMPPF
//
//  Created by Paul on 29/07/2015.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework

class RosterTableViewController: UITableViewController, ChatDelegate {
	
	var onlineBuddies = NSMutableArray()
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		appDelegate.delegate = self
	}

	override func viewDidAppear(animated: Bool) {
		if (NSUserDefaults.standardUserDefaults().objectForKey("userID") != nil) {
			if appDelegate.connect() {
				self.title = appDelegate.xmppStream.myJID.bare()
				appDelegate.xmppRoster.fetchRoster()
			}
		} else {
			performSegueWithIdentifier("Home.To.Login", sender: self)
		}
	}
	
	//MARK: TableView Delegates
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)
		
		cell.textLabel?.text = onlineBuddies[indexPath.row] as? String
		
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return onlineBuddies.count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let alertController = UIAlertController(title: "Warning!", message: "It will send Yo! to the recipient, continue ?", preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
			alertController.dismissViewControllerAnimated(true, completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			let message = "Yo!"
			let senderJID = XMPPJID.jidWithString(self.onlineBuddies[indexPath.row] as? String)
			let msg = XMPPMessage(type: "chat", to: senderJID)
			
			msg.addBody(message)
			self.appDelegate.xmppStream.sendElement(msg)
		}))
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	//MARK: Chat delegates
	func buddyWentOnline(name: String) {
		if !onlineBuddies.containsObject(name) {
			onlineBuddies.addObject(name)
			tableView.reloadData()
		}
	}
	
	func buddyWentOffline(name: String) {
		onlineBuddies.removeObject(name)
		tableView.reloadData()
	}
	
	func didDisconnect() {
		onlineBuddies.removeAllObjects()
		tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

