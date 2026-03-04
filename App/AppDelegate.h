//
//  AppDelegate.h
//  SmallClipboard
//
//  App lifecycle and menu; creates the main clipboard manager window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SSAppDelegate.h"

@class ClipboardWindow;

@interface AppDelegate : NSObject <SSAppDelegate>
{
    ClipboardWindow *_mainWindow;
}
@end
