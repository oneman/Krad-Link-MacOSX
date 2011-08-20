//
//  Krad_LinkAppDelegate.h
//  Krad Link
//
//  Created by Sage Wood on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#include "kradlink.h"

@interface Krad_LinkAppDelegate : NSObject <NSApplicationDelegate> {
@private
    int do_shutdown;
	NSMenuItem *open_menu_item;
	NSMenuItem *options_menu_item;
	NSMenuItem *connect_menu_item;
	NSMenuItem *disconnect_menu_item;
    NSStatusItem *trayItem;
    NSWindow *window;
    NSTimer *status_update_timer;
    NSTimer *levels_update_timer;
    IBOutlet NSMenu *station_menu;
    IBOutlet NSMenu *mode_menu;
    NSPopUpButton *station_list;
    NSMenu *input_devices_menu;
    NSMenu *output_devices_menu;
    NSPopUpButton *mode_list;
    NSButton *disconnect_button;
    NSButton *connect_button;
    NSPopUpButton *station_change;
    NSWindow *options_window;
    NSMenu *audio_backend_menu;
    NSPopUpButton *input_devices_popup;
    NSButton *options_button;
    NSPopUpButton *output_devices_popup;
    NSTextField *status_text;
    NSTextField *buffer_status_text;
    NSLevelIndicator *buffer_level;
    NSLevelIndicator *left_level;
    NSLevelIndicator *right_level;
    NSLevelIndicator *left_input_level;
    NSLevelIndicator *right_input_level;
    NSButton *status_icon_checkbox;
}
- (IBAction)options_okay_button:(id)sender;
- (IBAction)send_rec_change:(id)sender;
@property (assign) IBOutlet NSLevelIndicator *left_input_level;
@property (assign) IBOutlet NSLevelIndicator *right_input_level;
- (IBAction)status_icon_checkbox_clicked:(id)sender;
@property (assign) IBOutlet NSButton *status_icon_checkbox;

@property (assign) IBOutlet NSLevelIndicator *right_level;
@property (assign) IBOutlet NSLevelIndicator *left_level;
@property (assign) IBOutlet NSLevelIndicator *buffer_level;
@property (assign) IBOutlet NSTextField *buffer_status_text;
@property (assign) IBOutlet NSTextField *status_text;
@property (assign) IBOutlet NSPopUpButton *output_devices_popup;
@property (assign) IBOutlet NSPopUpButton *input_devices_popup;
@property (assign) IBOutlet NSButton *options_button;
@property (assign) IBOutlet NSMenu *audio_backend_menu;
- (IBAction)input_device_selected:(id)sender;
- (IBAction)audio_backend_changed:(id)sender;
- (IBAction)output_device_selected:(id)sender;
@property (assign) IBOutlet NSWindow *options_window;
- (IBAction)station_change:(id)sender;
@property (assign) IBOutlet NSPopUpButton *station_list;
@property (assign) IBOutlet NSMenu *input_devices_menu;
@property (assign) IBOutlet NSMenu *output_devices_menu;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopUpButton *mode_list;
- (IBAction)mode_menu_change:(id)sender;
- (IBAction)options_button_clicked:(id)sender;

@property (assign) IBOutlet NSButton *disconnect_button;
@property (assign) IBOutlet NSButton *connect_button;

- (IBAction)connect_button_clicked:(id)sender;
- (IBAction)disconnect_button_clicked:(id)sender;

@end
