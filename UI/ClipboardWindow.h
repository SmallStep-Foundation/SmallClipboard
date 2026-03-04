//
//  ClipboardWindow.h
//  SmallClipboard
//
//  Main window: table of clipboard history, copy selection to pasteboard, clear.
//

#import <AppKit/AppKit.h>

@class ClipboardHistory;

@interface ClipboardWindow : NSWindow

@property (nonatomic, readonly) ClipboardHistory *history;

- (void)clearHistory;

@end
