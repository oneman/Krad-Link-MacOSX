//
//  Krad_LinkAppDelegate.m
//  Krad Link
//
//  Created by Sage Wood on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Krad_LinkAppDelegate.h"

#include <assert.h>
#include <pthread.h>

kradlink_client_t *kradlink;

@implementation Krad_LinkAppDelegate
@synthesize left_input_level;
@synthesize right_input_level;
@synthesize status_icon_checkbox;
@synthesize right_level;
@synthesize left_level;
@synthesize buffer_level;
@synthesize buffer_status_text;
@synthesize status_text;
@synthesize output_devices_popup;
@synthesize input_devices_popup;
@synthesize options_button;
@synthesize audio_backend_menu;
@synthesize options_window;

@synthesize station_list;
@synthesize input_devices_menu;
@synthesize output_devices_menu;
@synthesize window;
@synthesize mode_list;
@synthesize disconnect_button;
@synthesize connect_button;





-(NSMenu *) buildMenu
{
	NSZone *zone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:zone] init];
	NSMenuItem *item;
	
    [menu setAutoenablesItems:false];

	//item = [menu addItemWithTitle:@"Testing" action:@selector(testing:) keyEquivalent:@""];
	//[item setTarget:self];

	open_menu_item = [menu addItemWithTitle:@"Open" action:@selector(open_button_clicked:) keyEquivalent:@""];
	[open_menu_item setTarget:self];
    
	connect_menu_item = [menu addItemWithTitle:@"Connect" action:@selector(connect_button_clicked:) keyEquivalent:@""];
	[connect_menu_item setTarget:self];
    
	disconnect_menu_item = [menu addItemWithTitle:@"Disconnect" action:@selector(disconnect_button_clicked:) keyEquivalent:@""];
	[disconnect_menu_item setTarget:self];

	options_menu_item = [menu addItemWithTitle:@"Options" action:@selector(options_button_clicked:) keyEquivalent:@""];
	[options_menu_item setTarget:self];
    
	[disconnect_menu_item setEnabled:NO];

    
	item = [menu addItemWithTitle:@"Quit" action:@selector(quitApp:) keyEquivalent:@""];
	[item setTarget:self];
	
	return menu;
	
}

-(void)testing:(id)sender
{
	NSLog(@"Hello World");
}

-(void) quitApp:(id)sender
{
    do_shutdown = TRUE;
	//[NSApp terminate:sender];
}

-(void) addTrayIcon:(id)sender
{

NSMenu *menu;
    menu= [self buildMenu];
trayItem = [[[NSStatusBar systemStatusBar]
             statusItemWithLength:NSSquareStatusItemLength] retain];
[trayItem setMenu:menu];
[trayItem setHighlightMode:YES];
[trayItem setTitle:@"K"];
[trayItem setToolTip:@"Krad Link"];

[menu release];

}

-(void) removeTrayIcon:(id)sender
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    [bar removeStatusItem:trayItem];
    [trayItem release];
    trayItem = NULL;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if (trayItem != NULL) {
        [self removeTrayIcon:(self)];
    }
    [window close];
    shutdown_kradlink();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [NSThread detachNewThreadSelector:@selector(myThreadMainMethod:) toTarget:self withObject:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowClosing:) name:NSWindowWillCloseNotification object:nil];
    
    trayItem = NULL;
    do_shutdown = FALSE;
    kradlink = init_kradlink();
    
    status_update_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(status_update) userInfo:nil repeats:YES];

    levels_update_timer = [NSTimer scheduledTimerWithTimeInterval:((1000 / kradlink->meter_update_rate) * 0.001f) target:self selector:@selector(levels_update) userInfo:nil repeats:YES];
            
    NSMenuItem* newItem;
	NSString* astring;
    
    int i = 0;
	// populate stations popmenu
	while (kradlink->stations[i].port != 0) {
        astring = [[NSString alloc] initWithCString:kradlink->stations[i].name encoding: NSASCIIStringEncoding];
        newItem = [[NSMenuItem alloc] initWithTitle:astring action:NULL keyEquivalent:@""];
        [newItem setTag:kradlink->stations[i].port];
        //[newItem setTarget:self];
        [station_menu addItem:newItem];
        [newItem release];
        [astring release];
		i++;
	}
    
    //populate audio devices popmenu
    
    
	for ( i=0; i<kradlink->portaudio->input_device_count; i++ ) {
        
        sprintf(kradlink->portaudio->input_devices[i].device_name, "%s", kradlink->portaudio->input_devices[i].device.name);
        printf("%s\n\n", kradlink->portaudio->input_devices[i].device_name);
        
        
        astring = [[NSString alloc] initWithCString:kradlink->portaudio->input_devices[i].device_name encoding: NSASCIIStringEncoding];
        newItem = [[NSMenuItem alloc] initWithTitle:astring action:NULL keyEquivalent:@""];
        [newItem setTag:kradlink->portaudio->input_devices[i].device_num];
        
        //[newItem setTarget:self];
        [input_devices_menu addItem:newItem];
        [newItem release];
        [astring release];

        
	}
    
    [input_devices_popup selectItemWithTag:kradlink->portaudio->input_device];
    
	
	for ( i=0; i<kradlink->portaudio->output_device_count; i++ ) {
        
        sprintf(kradlink->portaudio->output_devices[i].device_name, "%s", kradlink->portaudio->output_devices[i].device.name);
        printf("%s\n\n", kradlink->portaudio->output_devices[i].device_name);
        astring = [[NSString alloc] initWithCString:kradlink->portaudio->output_devices[i].device_name encoding: NSASCIIStringEncoding];
        newItem = [[NSMenuItem alloc] initWithTitle:astring action:NULL keyEquivalent:@""];
        [newItem setTag:kradlink->portaudio->output_devices[i].device_num];
        
        if (kradlink->portaudio->output_device == kradlink->portaudio->output_devices[i].device_num) {
            [newItem setState:NSOnState];
        }
        
        //[newItem setTarget:self];
        [output_devices_menu addItem:newItem];
        [newItem release];
        [astring release];
	
    }
    
    [output_devices_popup selectItemWithTag:kradlink->portaudio->output_device];


    [station_list setEnabled:YES];
    [connect_button setEnabled:YES];
    

}

-(void)myThreadMainMethod:(id)param
{
    
    usleep(100000);
    
}

- (IBAction)connect_button_clicked:(id)sender {
	[connect_menu_item setEnabled:NO];
	[options_menu_item setEnabled:NO];
    [connect_button setEnabled:NO];
    [options_button setEnabled:NO];
    [mode_list setEnabled:NO];
    [station_list setEnabled:NO];
    start_connection(kradlink);
    [disconnect_button setEnabled:YES];
	[disconnect_menu_item setEnabled:YES];

}

- (IBAction)disconnect_button_clicked:(id)sender {
	[disconnect_menu_item setEnabled:NO];
    [disconnect_button setEnabled:NO];
    end_connection(kradlink);
    [connect_button setEnabled:YES];
    [mode_list setEnabled:YES];
    [station_list setEnabled:YES];
    [options_button setEnabled:YES];
	[connect_menu_item setEnabled:YES];
	[connect_menu_item setEnabled:NO];
	[options_menu_item setEnabled:YES];

}

- (IBAction)mode_menu_change:(id)sender {
    kradlink->codec = [[sender selectedItem] tag];
}

- (IBAction)options_button_clicked:(id)sender {
    [connect_button setEnabled:NO];
	[connect_menu_item setEnabled:NO];
    [options_window makeKeyAndOrderFront:self];
    
}

- (void)windowClosing:(NSNotification*)aNotification {

}

- (IBAction)station_change:(id)sender {
    
    
    int i = 0;
	
	while (kradlink->stations[i].port != 0) {
        
        if ([[sender selectedItem] tag] == kradlink->stations[i].port) {
            
            select_station (kradlink, kradlink->stations[i].name);
        }
        
		i++;
	}
    
}

- (IBAction)audio_backend_changed:(id)sender {
    
    set_kradlink_audio_backend(kradlink, [[sender selectedItem] tag]);
    
    if ([[sender selectedItem] tag] == JACK) {
        [input_devices_popup setEnabled:NO];
        [output_devices_popup setEnabled:NO];

    } else {
        [input_devices_popup setEnabled:YES];
        [output_devices_popup setEnabled:YES];
    
    }
    
    
}

- (void)levels_update {
    
    update_levels(kradlink);
    
	//kradlink->output_peak[0];
	//kradlink->output_peak[1];
	//kradlink->output_level[0];
	//kradlink->output_level[1];
    
    [left_level setFloatValue:(kradlink->output_level[0] / 10.0f)];
    [right_level setFloatValue:(kradlink->output_level[1] / 10.0f)];

    [left_input_level setFloatValue:(kradlink->input_level[0] / 10.0f)];
    [right_input_level setFloatValue:(kradlink->input_level[1] / 10.0f)];
    
}


- (void)status_update {
    
	//kradlink_client_t *kradlink = (kradlink_client_t *)data;
	NSString* astring;
	if (kradlink->status_updated == TRUE) {
        
        astring = [[NSString alloc] initWithCString:kradlink->status encoding: NSASCIIStringEncoding];

		[status_text setStringValue:astring];
        
		[astring release];
        
	}
	
    astring = [[NSString alloc] initWithCString:kradlink->buffer_status encoding: NSASCIIStringEncoding];
    
    [buffer_status_text setStringValue:astring];
    [buffer_level setIntValue:(kradlink->buffered_ms / 160)];
    [astring release];
    
    if (kradlink->disconnected == TRUE) {
        if ([options_window isVisible]) {
            [connect_button setEnabled:NO];
        } else {
            [connect_button setEnabled:YES];
        }
    }
    
    if (do_shutdown == TRUE) {
        [NSApp terminate:self]; 
    }
    
}


- (IBAction)input_device_selected:(id)sender {
    
    //select_input_device(kradlink, string);
    kradlink->portaudio->input_device = [[sender selectedItem] tag];
    
}


- (IBAction)output_device_selected:(id)sender {
    
	//select_output_device(kradlink, string);
    kradlink->portaudio->output_device = [[sender selectedItem] tag];

    
}
- (IBAction)options_okay_button:(id)sender {
    [options_window close];
	[connect_menu_item setEnabled:YES];
}

-(void)open_button_clicked:(id)sender
{
    [window makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
	if( !flag )
		[window makeKeyAndOrderFront:nil];
	
	return YES;
}

- (IBAction)send_rec_change:(id)sender {
    
    if ([[sender selectedItem] tag] == 0) {
        set_kradlink_receiving(kradlink, TRUE);
        set_kradlink_sending(kradlink, FALSE);
    }
    
    if ([[sender selectedItem] tag] == 1) {
        set_kradlink_receiving(kradlink, FALSE);
        set_kradlink_sending(kradlink, TRUE);
    }
    
    if ([[sender selectedItem] tag] == 2) {
        set_kradlink_receiving(kradlink, TRUE);
        set_kradlink_sending(kradlink, TRUE);
    }
    
}
- (IBAction)status_icon_checkbox_clicked:(id)sender {
    if([[self status_icon_checkbox] state] == NSOnState) {
        [self addTrayIcon:(self)];
        [connect_menu_item setEnabled:NO];
    } else {
        [self removeTrayIcon:(self)];
    }
}
@end
