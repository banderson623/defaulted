//
//  BBYAppDelegate.h
//  Defaulted
//
//  Created by Brian Anderson on 1/3/14.
//  Copyright (c) 2014 Brian Anderson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBYAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (void) setStatus:(unsigned int) status;

@end
