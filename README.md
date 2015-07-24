# demo-xmpp-ios


## Overview

**XMPPFramework** Basic client relying using [Cocoapods](https://cocoapods.org) package.

### I.Project setup
1. Open Xcode and select *Create a new project*  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.15.32.png?raw=true =350x)
2. Select *Single View Application* in the project editor  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.15.44.png?raw=true =350x)
3. Fill all the required fields and then project location  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.15.44.png?raw=true =350x)
4. Now quit Xcode, and open the terminal app    
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.41.50.png?raw=true =350x)
5. Navigate to your project directory and type `pod init` like so:  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.42.02.png?raw=true =350x)
6. Edit the newly created *Podile* by taping `emacs Podfile` it should look like this:  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-24%20à%2015.16.11.png?raw=true =350x)  
*Press ctrl+x, ctrl+s to save, then ctrl+x, ctrl+c to end editing*

7. Now Type `pod install` and wait for cocoapod to finish  
![Xcode setup](https://github.com/processone/demo-xmpp-ios/blob/master/Setup%20resources/Capture%20d’écran%202015-07-22%20à%2011.47.26.png?raw=true =350x)  
From now on you will have to open the xcworkspace file
8. Open your `AppDelegate.h` and add the XMPP import:

 `#import <XMPPFramework/XMPPFramework.h>`

#### Finito ! Build & run to confirm everyting is setup properly before going further



### II.XMPP Demo
1. Add the following to your `AppDelegate.h`:  
```#import <XMPPFramework/XMPPRoster.h>``` and

 ```#import <XMPPFramework/XMPPRosterCoreDataStorage.h>```
2. Add the chat protocol:  
```@protocol ChatDelegate

(void)buddyWentOnline:(NSString *)name;  

(void)buddyWentOffline:(NSString *)name;  

(void)didDisconnect;  
@end```
3. Add the following degegates:
```XMPPRosterDelegate, XMPPStreamDelegate```
4. Add XMPP properties:
```@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;

@property (nonatomic, weak) id <ChatDelegate> chatDelegate;```
5. And the following puclic methods:
```- (BOOL)connect;
- (void)disconnect;```
6. Switch to `AppDelegate.m` and add a new method called `setupStream`, witch will be in charge of configuring the stream, roster and its storage:
```- (void)setupStream {
self.xmppStream = [XMPPStream new];
self.xmppRosterStorage = [XMPPRosterCoreDataStorage new];	
self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];

[self.xmppRoster activate:self.xmppStream];
[self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
[self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}```
	And call it in `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
7. Add the following methods to the private interface:
```
@interface AppDelegate ()

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (BOOL)connect;
- (void)disconnect;

@end```
8. Implement those methods:
```- (void)goOnline {
XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

NSString *domain = [self.xmppStream.myJID domain];

//Google set their presence priority to 24, so we do the same to be compatible.

if([domain isEqualToString:@"gmail.com"]
|| [domain isEqualToString:@"gtalk.com"]
|| [domain isEqualToString:@"talk.google.com"])
{
NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
[presence addChild:priority];
}

[[self xmppStream] sendElement:presence];
}

- (void)goOffline {
XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
[[self xmppStream] sendElement:presence];
}

- (BOOL)connect {

if (!self.xmppStream.isConnected) {

NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];

if (![self.xmppStream isDisconnected]) {
return YES;
}

if (jabberID == nil || myPassword == nil) {
return NO;
}

[self.xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];

NSError *error = nil;
if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
{
NSLog(@"Connection error");
} else {
NSLog(@"Connection succes");
}

return YES;
} else {
return YES;
}
}

- (void)disconnect {

[self goOffline];
[self.xmppStream disconnect];
}```
9. Call `[self connect]` in `- (void)applicationDidBecomeActive:(UIApplication *)application` and `[self disconnect]` in `- (void)applicationWillResignActive:(UIApplication *)application`
10. Now the last but not the least, implement the xmpp delegates:
```- (void)xmppStreamDidConnect:(XMPPStream *)sender {

NSError *error = nil;
if ([[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"] error:&error]) {
NSLog(@"did authenticate");
} else {
NSLog(@"did not authenticate %@", error);
}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {

[self goOnline];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sucess !" message:[NSString stringWithFormat:@"%@", message] preferredStyle:UIAlertControllerStyleAlert];
[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

}]];

[self.window.rootViewController presentViewController:alertController animated:true completion:nil];

NSLog(@"message received %@", message);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
NSLog(@"did send message");
UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sucess !" message:@"Message succesfully sent !" preferredStyle:UIAlertControllerStyleAlert];
[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

}]];

[self.window.rootViewController.presentedViewController presentViewController:alertController animated:true completion:nil];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
NSLog(@"did receive presence");
NSString *presenceType = [presence type]; // online/offline
NSString *myUsername = [[sender myJID] user];
NSString *presenceFromUser = [[presence from] user];

if (![presenceFromUser isEqualToString:myUsername]) {
NSLog(@"presenceFromUser %@", presenceFromUser);
if ([presenceType isEqualToString:@"available"]) {

[_chatDelegate buddyWentOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"gmail.com"]];

} else if ([presenceType isEqualToString:@"unavailable"]) {

[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"gmail.com"]];

}

}

}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
NSLog(@"did receive roster item");
}```
11. Let's add a `LoginViewController`, you are free to add whatever you want in this ViewController, but your `connect` method should look like this:
```- (IBAction)connect:(id)sender {
[[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.text forKey:@"userID"];
[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"userPassword"];
[[NSUserDefaults standardUserDefaults] synchronize];

if ([(AppDelegate *)[UIApplication sharedApplication].delegate connect]) {
//sucess
[self dismissViewControllerAnimated:true completion:nil];
} else {
//error
}
}```
12. It's nice to be connected, but it'll be even better if we could get our buddies list. Create a `UITableViewController` subclass and in the .h file, add the `Chatdelegate` and an ivar ```NSMutableArray *onlineBuddies``` to store the buddy list
13. Now switch to your .m and set yourself as delegates for chat, then init your array in viewdidiload:
```((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
onlineBuddies = [NSMutableArray new];```
14. Then in your viewwillappear, check if you are connected like so:
```if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]) {
if ([((AppDelegate *)[[UIApplication sharedApplication] delegate]) connect]) {
//reload TV
self.title = [[[((AppDelegate *)[[UIApplication sharedApplication] delegate]) xmppStream] myJID] bare];
[((AppDelegate *)[[UIApplication sharedApplication] delegate]).xmppRoster fetchRoster];
}
} else {
[self performSegueWithIdentifier:@"Home.To.Login" sender:self];
}```
15. After that implement the chat delegates methods:
```- (void)buddyWentOnline:(NSString *)name {
if (![onlineBuddies containsObject:name]) {
[onlineBuddies addObject:name];
[self.tableView reloadData];
}
}

- (void)buddyWentOffline:(NSString *)name {
[onlineBuddies removeObject:name];
[self.tableView reloadData];
}

- (void)didDisconnect {
[onlineBuddies removeAllObjects];
[self.tableView reloadData];
}```
16. The rest is pretty straightforward, you need to implement the `UITableView’s Delegates`:
```- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

static NSString *CellIdentifier = @"cellIdentifier";

UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

cell.textLabel.text = [onlineBuddies objectAtIndex:indexPath.row];
NSLog(@"JID %@", cell.textLabel.text);
return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

return [onlineBuddies count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

return 1;
}```
17. Now if you want to send a message when the user tap on a row, implement this method:
```- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning !" message:@"It will send Yo! to the recipient, continue ?" preferredStyle:UIAlertControllerStyleAlert];
[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
[alertController dismissViewControllerAnimated:true completion:nil];
}]];
[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
NSString *message = @"Yo!";

XMPPJID *senderJid = [XMPPJID jidWithString:[onlineBuddies objectAtIndex:indexPath.row]];
XMPPMessage* msg = [[XMPPMessage alloc] initWithType:@"chat" to:senderJid];
[msg addBody:message];

[((AppDelegate *)[[UIApplication sharedApplication] delegate]).xmppStream sendElement:msg];
}]];

[self presentViewController:alertController animated:true completion:nil];	
}```
18. Build, run and start chatting with your friends !

#### You can also download the sample project [here](https://github.com/processone/demo-xmpp-ios/archive/master.zip)