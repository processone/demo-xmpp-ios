# demo-xmpp-ios


## Overview

**XMPPFramework** Basic client relying using [Cocoapods](https://cocoapods.org) package.

### I. Project setup
1. Open Xcode and select *Create a new project*  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.15.32.png?raw=true =350x)
2. Select *Single View Application* in the project editor  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.15.44.png?raw=true =350x)
3. Fill all the required fields and then project location  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Swift_lang.png?raw=true =350x)
4. Now quit Xcode, and open the terminal app    
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.41.50.png?raw=true =350x)
5. Navigate to your project directory and type `pod init` like so:  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.42.02.png?raw=true =350x)
6. Edit the newly created *Podfile* by taping `emacs Podfile` (Feel free to use vim :)). It should look like this:  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-24%20à%2015.16.11.png?raw=true =350x)  
*Press ctrl+x, ctrl+s to save, then ctrl+x, ctrl+c to end editing*

7. Now Type `pod install` and wait for cocoapod to finish  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/XMPPFramework_Swift_lang.png?raw=true =350x)  
From now on you will have to open the xcworkspace file
8. Open your `AppDelegate.h` and add the XMPP import:

	```Swift
		import XMPPFramework
	```

#### Finito ! Build & run to confirm everyting is setup properly before going further



### II.XMPP Demo
1. Add the chat protocol at the top of your `AppDelegate`:
	```Swift
		protocol ChatDelegate {
			func buddyWentOnline(name: String)
			func buddyWentOffline(name: String)
			func didDisconnect()
		}
	```
1. Add the following degegates:
	```Swift
		XMPPRosterDelegate, XMPPStreamDelegate
	```
1. Add XMPP properties:
	```Swift
		var delegate:ChatDelegate! = nil
		let xmppStream = XMPPStream()
		let xmppRosterStorage = XMPPRosterCoreDataStorage()
		var xmppRoster: XMPPRoster

		override init() {
			xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
		}
	```
1. Still in `AppDelegate`, add a new method called `setupStream`, witch will be in charge of configuring the stream, roster and its storage:
	```Swift
		private func setupStream() {
			xmppRoster.activate(xmppStream)
			xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
			xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
		}
	```
	And call it in
	```Swift
		func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	```
1. Implement the following methods:
	```Swift
		private func goOnline() {
			let presence = XMPPPresence()
			let domain = xmppStream.myJID.domain

			if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
				let priority = DDXMLElement.elementWithName("priority", stringValue: "24") as! DDXMLElement
				presence.addChild(priority)
			}
			xmppStream.sendElement(presence)
		}

		private func goOffline() {
			let presence = XMPPPresence(type: "unavailable")
			xmppStream.sendElement(presence)
		}

		func connect() -> Bool {
			if !xmppStream.isConnected() {
				let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
				let myPassword = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")

				if !xmppStream.isDisconnected() {
					return true
				}
				if jabberID == nil && myPassword == nil {
					return false
				}

				xmppStream.myJID = XMPPJID.jidWithString(jabberID)

				do {
					try xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
						print("Connection success")
						return true
					} catch {
						print("Something went wrong!")
						return false
					}
				} else {
					return true
				}
		}

		func disconnect() {
			goOffline()
			xmppStream.disconnect()
		}
	```
1. Call `connect()` in `func applicationDidBecomeActive(application: UIApplication)` and `disconnect()` in `func applicationWillResignActive(application: UIApplication)`
1. Now the last but not the least, implement the xmpp delegates:
	```Swift
		func xmppStreamDidConnect(sender: XMPPStream!) {
			do {
				try	xmppStream.authenticateWithPassword(NSUserDefaults.standardUserDefaults().stringForKey("userPassword"))
			} catch {
				print("Could not authenticate")
			}
		}

		func xmppStreamDidAuthenticate(sender: XMPPStream!) {
			goOnline()
		}

		func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
			print("Did receive IQ")
			return false
		}

		func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
			print("Did receive message \(message)")
		}

		func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
			print("Did send message \(message)")
		}

		func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
			let presenceType = presence.type()
			let myUsername = sender.myJID.user
			let presenceFromUser = presence.from().user

			if presenceFromUser != myUsername {
				print("Did receive presence from \(presenceFromUser)")
				if presenceType == "available" {
					delegate.buddyWentOnline("\(presenceFromUser)@gmail.com")
				} else if presenceType == "unavailable" {
					delegate.buddyWentOffline("\(presenceFromUser)@gmail.com")
				}
			}
		}

		func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
			print("Did receive Roster item")
		}
	```
1. Let's add a `LoginViewController`, you are free to add whatever you want in this ViewController, but your `login` method should look like this:
	```Swift
		@IBAction func login(sender: AnyObject) {
			NSUserDefaults.standardUserDefaults().setObject(loginTextField.text!, forKey: "userID")
			NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text!, forKey: "userPassword")

			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

			if appDelegate.connect() {
				dismissViewControllerAnimated(true, completion: nil)
			}
		}
	```
1. It's nice to be connected, but it'll be even better if we could get our buddies list. Create a ```UITableViewController``` subclass and add ```Chatdelegate``` and an ivar ```var onlineBuddies = NSMutableArray()``` to store the buddy list
1. Now set yourself as delegate for chat, then init your array in viewDidLoad:

	```Swift
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		override func viewDidLoad() {
			super.viewDidLoad()
			// Do any additional setup after loading the view, typically from a nib.
			appDelegate.delegate = self
		}
	```
1. Then in your viewwillappear, check if you are connected like so:

	```Swift
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
	```
1. After that implement the chat delegates methods:
	```Swift
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
	```
1. The rest is pretty straightforward, you need to implement the `UITableView’s Delegates`:
	```Swift
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
	```
1. Now if you want to send a message when the user tap on a row, implement this method:
	```Swift
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
	```
1. Build, run and start chatting with your friends !

#### You can also download the sample project [here](https://github.com/processone/demo-xmpp-ios/archive/master.zip)