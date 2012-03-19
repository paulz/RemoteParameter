//
//  ParameterServerAppDelegate.m
//  ParameterServer
//
//  Created by Joachim Bengtsson on 2010-03-02.


#import "ParameterControllerAppDelegate.h"
#import "ClientController.h"

@implementation ParameterControllerAppDelegate

@synthesize window;
-(id)init;
{
	foundServices = [NSMutableArray new];
	browser = [NSNetServiceBrowser new];
	browser.delegate = self;
	return self;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[ParameterClient performSearchOnBrowser:browser];
	[tableView setTarget:self];
	[tableView setDoubleAction:@selector(connect:)];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] addObject:aNetService];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] removeObject:aNetService];
}

-(IBAction)connect:(NSTableView*)sender;
{
	NSInteger r = sender.selectedRow;
	if(r < 0 || r >= [foundServices count]) return;
	NSNetService *service = [foundServices objectAtIndex:r];
	service.delegate = self;
	[service resolveWithTimeout:5.0];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service;
{
	ParameterClient *client = [[[ParameterClient alloc] initWithService:service] autorelease];
	ClientController *controller = [[(ClientController*)[ClientController alloc] initWithClient:client] autorelease];
	[controller showWindow:nil];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
	NSRunAlertPanel(@"Couldn't resolve", @"Sorry, couldn't resolve the domain of the instance you clicked.", @"Bummer", nil, nil);
}

@end
