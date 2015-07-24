//
//  AppDelegate.m
//  Demo-XMPP-iOS
//
//  Created by Paul on 24/07/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

/* Will setup XMPP Variables */
- (void)setupStream;

/* Will send a available presence element to the server */
- (void)goOnline;

/* Will send a unavailable presence element to the server */
- (void)goOffline;

/* Connect will user given credentials to connect the stream */
- (BOOL)connect;

/* Disconnect the stream */
- (void)disconnect;

@end

@implementation AppDelegate

#pragma mark == APPLICATION DELEGATES ==
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	[self setupStream];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	
	[self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	[self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark == PRIVATE METHODS ==
/* Will setup XMPP Variables */
- (void)setupStream {
	self.xmppStream = [XMPPStream new];
	self.xmppRosterStorage = [XMPPRosterCoreDataStorage new];
	self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];

	[self.xmppRoster activate:self.xmppStream];
	
	[self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

/* Will send a available presence element to the server */
- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence];
	NSString *domain = [self.xmppStream.myJID domain];
	
	//Google set their presence priority to 24, so we do the same to be compatible.
	if ([domain isEqualToString:@"gmail.com"] || [domain isEqualToString:@"gtalk.com"] || [domain isEqualToString:@"talk.google.com"]) {
		NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
		[presence addChild:priority];
	}
	
	[[self xmppStream] sendElement:presence];
}

/* Will send a unavailable presence element to the server */
- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[[self xmppStream] sendElement:presence];
}

/* Connect will user given credentials to connect the stream */
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
		if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
			//Handle error
		}
		
		return YES;
	} else {
		return YES;
	}
}

/* Disconnect the stream */
- (void)disconnect {
	
	[self goOffline];
	[self.xmppStream disconnect];
}

#pragma mark == XMPP DELEGATES ==
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	NSError *error = nil;
	if (![[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"] error:&error]) {
		//NSLog(@"did not authenticate %@", error);
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
	[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		
	}]];
	
	[self.window.rootViewController presentViewController:alertController animated:true completion:nil];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sucess !" message:@"Message succesfully sent !" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		
	}]];
	
	[self.window.rootViewController.presentedViewController presentViewController:alertController animated:true completion:nil];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
	NSString *presenceType = [presence type];
	NSString *myUsername = [[sender myJID] user];
	NSString *presenceFromUser = [[presence from] user];
	
	if (![presenceFromUser isEqualToString:myUsername]) {
		if ([presenceType isEqualToString:@"available"]) {
			[_chatDelegate buddyWentOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"gmail.com"]];//replace by your server
		} else if ([presenceType isEqualToString:@"unavailable"]) {
			[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"gmail.com"]];//replace by your server
		}
	}
}

@end
