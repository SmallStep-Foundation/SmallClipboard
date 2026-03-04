//
//  AppDelegate.m
//  SmallClipboard
//

#import "AppDelegate.h"
#import "ClipboardWindow.h"
#import "SSMainMenu.h"
#import "SSHostApplication.h"
#import "SSWindowStyle.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[ClipboardWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallClipboard"];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"Show History" action:@selector(showWindow:) keyEquivalent:@"h" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Clear History" action:@selector(clearHistory:) keyEquivalent:@"" modifierMask:0 target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallClipboard" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
#endif
}

- (void)showWindow:(id)sender {
    (void)sender;
    [_mainWindow makeKeyAndOrderFront:nil];
}

- (void)clearHistory:(id)sender {
    (void)sender;
    [_mainWindow clearHistory];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
