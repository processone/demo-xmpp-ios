//
//  AppDelegate.h
//  Demo-XMPP-iOS
//
//  Created by Paul on 24/07/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

@import UIKit;

#import <XMPPFramework/XMPPRoster.h>
#import <XMPPFramework/XMPPRosterCoreDataStorage.h>

@protocol ChatDelegate
- (void)buddyWentOnline:(NSString *)name;
- (void)buddyWentOffline:(NSString *)name;
- (void)didDisconnect;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPRosterDelegate, XMPPStreamDelegate>

@property (strong, nonatomic) UIWindow *window;

/* XMPP related properties */
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;

/* Chat delegate property */
@property (nonatomic, weak) id <ChatDelegate> chatDelegate;

/* Public methods */
- (BOOL)connect;
- (void)disconnect;

@end

