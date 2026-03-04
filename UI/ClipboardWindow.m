//
//  ClipboardWindow.m
//  SmallClipboard
//

#import "ClipboardWindow.h"
#import "ClipboardHistory.h"
#import "SSWindowStyle.h"

#if defined(GNUSTEP) && !defined(NSAlertDefaultReturn)
#define NSAlertDefaultReturn 1
#define NSAlertAlternateReturn 0
#endif

static const CGFloat kMargin = 12.0;
static const CGFloat kButtonH = 28.0;

@interface ClipboardWindow () <NSTableViewDataSource, NSTableViewDelegate, ClipboardHistoryDelegate>
@end

@implementation ClipboardWindow
{
    ClipboardHistory *_history;
    NSTableView *_tableView;
    NSScrollView *_scrollView;
    NSButton *_copyButton;
    NSButton *_clearButton;
    NSTextField *_previewField;
}

- (instancetype)init {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 480, 360);
    self = [super initWithContentRect:frame
                            styleMask:style
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:@"Clipboard History"];
        [self setReleasedWhenClosed:NO];
        _history = [[ClipboardHistory alloc] init];
        [_history setDelegate:self];
        [_history loadFromDisk];
        [_history startMonitoringPasteboard];
        [self buildContent];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_history stopMonitoringPasteboard];
    [_history setDelegate:nil];
    [_history release];
    [_tableView release];
    [_scrollView release];
    [_copyButton release];
    [_clearButton release];
    [_previewField release];
    [super dealloc];
}
#endif

- (ClipboardHistory *)history {
    return _history;
}

- (void)clearHistory {
    NSArray *entries = [_history entries];
    if ([entries count] == 0) return;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Clear clipboard history?"];
    [alert setInformativeText:[NSString stringWithFormat:@"This will remove %lu item(s).", (unsigned long)[entries count]]];
    [alert addButtonWithTitle:@"Clear"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSInteger result = [alert runModal];
    [alert release];
    if (result == NSAlertDefaultReturn) {
        [_history clear];
    }
#else
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Clear clipboard history?"];
    [alert setInformativeText:[NSString stringWithFormat:@"This will remove %lu item(s).", (unsigned long)[entries count]]];
    [alert addButtonWithTitle:@"Clear"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
        [_history clear];
    }
#endif
}

- (void)buildContent {
    NSView *content = [self contentView];
    NSRect bounds = [content bounds];
    CGFloat w = bounds.size.width;
    CGFloat topY = bounds.size.height - kMargin - kButtonH;

    _clearButton = [[NSButton alloc] initWithFrame:NSMakeRect(kMargin, topY, 100, kButtonH)];
    [_clearButton setTitle:@"Clear History"];
    [_clearButton setButtonType:NSMomentaryPushInButton];
    [_clearButton setBezelStyle:NSRoundedBezelStyle];
    [_clearButton setTarget:self];
    [_clearButton setAction:@selector(clearHistory)];
    [_clearButton setAutoresizingMask:NSViewMinYMargin];
    [content addSubview:_clearButton];

    _copyButton = [[NSButton alloc] initWithFrame:NSMakeRect(w - kMargin - 90, topY, 90, kButtonH)];
    [_copyButton setTitle:@"Copy"];
    [_copyButton setButtonType:NSMomentaryPushInButton];
    [_copyButton setBezelStyle:NSRoundedBezelStyle];
    [_copyButton setTarget:self];
    [_copyButton setAction:@selector(copySelected)];
    [_copyButton setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin];
    [content addSubview:_copyButton];

    CGFloat tableTop = topY - kMargin;
    CGFloat tableBottom = kMargin + 60;
    _scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(kMargin, tableBottom, w - 2 * kMargin, tableTop - tableBottom)];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:NO];
    [_scrollView setBorderType:NSBezelBorder];
    [_scrollView setAutohidesScrollers:YES];

    _tableView = [[NSTableView alloc] initWithFrame:NSZeroRect];
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"text"];
    [col setWidth:[_scrollView contentSize].width - 4];
    [col setMinWidth:80];
    [_tableView addTableColumn:col];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [col release];
#endif
    [_tableView setHeaderView:nil];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setTarget:self];
    [_tableView setDoubleAction:@selector(copySelected)];
    [_scrollView setDocumentView:_tableView];
    [content addSubview:_scrollView];

    _previewField = [[NSTextField alloc] initWithFrame:NSMakeRect(kMargin, kMargin, w - 2 * kMargin, 44)];
    [_previewField setEditable:NO];
    [_previewField setBordered:YES];
    [_previewField setBezeled:YES];
    [_previewField setDrawsBackground:YES];
    [_previewField setBackgroundColor:[NSColor textBackgroundColor]];
    [_previewField setAutoresizingMask:NSViewWidthSizable];
    [_previewField setStringValue:@"Select an entry to preview."];
    [content addSubview:_previewField];
}

- (void)copySelected {
    NSInteger row = [_tableView selectedRow];
    if (row < 0) return;
    [_history copyToPasteboardAtIndex:(NSUInteger)row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    (void)tableView;
    return (NSInteger)[[_history entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    (void)tableView;
    (void)tableColumn;
    NSArray *entries = [_history entries];
    if (row < 0 || (NSUInteger)row >= [entries count]) return @"";
    NSString *s = [entries objectAtIndex:(NSUInteger)row];
    if ([s length] > 80) {
        return [[s substringToIndex:77] stringByAppendingString:@"..."];
    }
    return s;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    (void)notification;
    NSInteger row = [_tableView selectedRow];
    if (row < 0) {
        [_previewField setStringValue:@"Select an entry to preview."];
        return;
    }
    NSArray *entries = [_history entries];
    if ((NSUInteger)row >= [entries count]) return;
    NSString *full = [entries objectAtIndex:(NSUInteger)row];
    [_previewField setStringValue:full];
}

#pragma mark - ClipboardHistoryDelegate

- (void)clipboardHistoryDidChange:(ClipboardHistory *)history {
    (void)history;
    [_tableView reloadData];
}

@end
