//
//  BBYAppDelegate.m
//  Defaulted
//
//  Created by Brian Anderson on 1/3/14.
//  Copyright (c) 2014 Brian Anderson. All rights reserved.
// -------------------------------------------------------------
//  Based on http://context-macosx.googlecode.com/svn-history/r138/trunk/Tools/Applications/Pennyworth/PowerObserver.m
//  Created by Chris Karr on 4/19/08.
//  Copyright 2008 Northwestern University. All rights reserved.
// --------------------------------------------------------------


#import "BBYAppDelegate.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>

#define POWER_WALL 1
#define POWER_BATTERY 0
#define POWER_UNKNOWN -1

static bool stringsAreEqual (CFStringRef a, CFStringRef b)
{
	if (a == nil || b == nil){
		return 0;
    } else {
        return (CFStringCompare (a, b, 0) == kCFCompareEqualTo);
    }
}

static void update (void * context)
{
	BBYAppDelegate * self = (BBYAppDelegate *) CFBridgingRelease(context);

	CFTypeRef blob = IOPSCopyPowerSourcesInfo ();
	CFArrayRef list = IOPSCopyPowerSourcesList (blob);

	unsigned int count = CFArrayGetCount (list);

	if (count == 0)
		[self setStatus:POWER_WALL];

	unsigned int i = 0;
	for (i = 0; i < count; i++)
	{
		CFTypeRef source;
		CFDictionaryRef description;

		source = CFArrayGetValueAtIndex (list, i);
		description = IOPSGetPowerSourceDescription (blob, source);

		if (stringsAreEqual (CFDictionaryGetValue (description, CFSTR (kIOPSTransportTypeKey)), CFSTR (kIOPSInternalType)))
		{
			CFStringRef currentState = CFDictionaryGetValue (description, CFSTR (kIOPSPowerSourceStateKey));

			if (stringsAreEqual (currentState, CFSTR (kIOPSACPowerValue))){
                [self setStatus:POWER_WALL];
            } else if (stringsAreEqual (currentState, CFSTR (kIOPSBatteryPowerValue))){
                [self setStatus:POWER_BATTERY];
            } else{
                [self setStatus:POWER_UNKNOWN];
            }
		}
	}

	CFRelease (list);
	CFRelease (blob);
}

@implementation BBYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CFRunLoopSourceRef loopSource = IOPSNotificationCreateRunLoopSource (update, CFBridgingRetain(self));

	if (loopSource)
		CFRunLoopAddSource (CFRunLoopGetCurrent(), loopSource, kCFRunLoopDefaultMode);

	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh:) userInfo:nil repeats:NO];

}

- (void) setStatus:(unsigned int) status
{
    NSString* powerType = status == POWER_WALL ? @"wall" : @"battery";
//	NSMutableDictionary * note = [NSMutableDictionary dictionary];
//
//	[note setValue:@"Power Observer" forKey:@"Observation Name"];
//
//	if (status == POWER_WALL)
//		[note setValue:@"Wall" forKey:@"Observation Description"];
//	else if (status == POWER_BATTERY)
//		[note setValue:@"Battery" forKey:@"Observation Description"];
//	else
//		[note setValue:@"Unknown" forKey:@"Observation Description"];
//
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"GKB: Observation Update"
//                                                        object:self userInfo:note];

    NSLog(@"setStatus called: %@",powerType);
    
}

- (void) refresh:(NSTimer *) theTimer
{
	update ((__bridge void *)(self));
}

@end
