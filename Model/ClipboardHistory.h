//
//  ClipboardHistory.h
//  SmallClipboard
//
//  Model: clipboard history entries, persistence via SSFileSystem, sync from NSPasteboard.
//

#import <Foundation/Foundation.h>

@protocol ClipboardHistoryDelegate;

@interface ClipboardHistory : NSObject

@property (nonatomic, assign) NSUInteger maxEntries;  // default 100
@property (nonatomic, readonly) NSArray *entries;     // NSStrings, newest first
@property (nonatomic, assign) id<ClipboardHistoryDelegate> delegate;

- (void)addEntry:(NSString *)string;
- (void)removeEntryAtIndex:(NSUInteger)index;
- (void)clear;
- (void)copyToPasteboardAtIndex:(NSUInteger)index;

/// Start polling the general pasteboard and appending new copies to history.
- (void)startMonitoringPasteboard;
- (void)stopMonitoringPasteboard;

/// Load/save from app support directory (SmallClipboard/history.plist).
- (void)loadFromDisk;
- (void)saveToDisk;

@end

@protocol ClipboardHistoryDelegate <NSObject>
@optional
- (void)clipboardHistoryDidChange:(ClipboardHistory *)history;
@end
