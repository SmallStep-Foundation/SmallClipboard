//
//  ClipboardHistory.m
//  SmallClipboard
//

#import "ClipboardHistory.h"
#import "SSFileSystem.h"
#import <AppKit/AppKit.h>

#if !defined(NSPasteboardTypeString) && defined(NSStringPboardType)
#define NSPasteboardTypeString NSStringPboardType
#endif

static NSString * const kHistoryFileName = @"history.plist";
static const NSUInteger kDefaultMaxEntries = 100;
static const NSTimeInterval kPollInterval = 0.5;

@interface ClipboardHistory ()
@property (nonatomic, retain) NSMutableArray *mutableEntries;
@property (nonatomic, assign) NSInteger lastPasteboardChangeCount;
@property (nonatomic, retain) NSTimer *pollTimer;
@end

@implementation ClipboardHistory

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableEntries = [[NSMutableArray alloc] init];
        _maxEntries = kDefaultMaxEntries;
        _lastPasteboardChangeCount = -1;
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mutableEntries release];
    [_pollTimer invalidate];
    [_pollTimer release];
    [super dealloc];
}
#endif

- (NSArray *)entries {
    return [[_mutableEntries copy] autorelease];
}

- (NSString *)historyFilePath {
    id<SSFileSystem> fs = [SSFileSystem sharedFileSystem];
    NSString *base = [fs applicationSupportDirectory];
    NSString *dir = [base stringByAppendingPathComponent:@"SmallClipboard"];
    NSError *err = nil;
    if (![fs createDirectoryAtPath:dir error:&err]) {
        return [dir stringByAppendingPathComponent:kHistoryFileName];
    }
    return [dir stringByAppendingPathComponent:kHistoryFileName];
}

- (void)addEntry:(NSString *)string {
    if (!string || [string length] == 0) return;
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] == 0) return;
    [_mutableEntries removeObject:trimmed];
    [_mutableEntries insertObject:trimmed atIndex:0];
    while ([_mutableEntries count] > _maxEntries) {
        [_mutableEntries removeLastObject];
    }
    [self saveToDisk];
    if ([_delegate respondsToSelector:@selector(clipboardHistoryDidChange:)]) {
        [_delegate clipboardHistoryDidChange:self];
    }
}

- (void)removeEntryAtIndex:(NSUInteger)index {
    if (index >= [_mutableEntries count]) return;
    [_mutableEntries removeObjectAtIndex:index];
    [self saveToDisk];
    if ([_delegate respondsToSelector:@selector(clipboardHistoryDidChange:)]) {
        [_delegate clipboardHistoryDidChange:self];
    }
}

- (void)clear {
    [_mutableEntries removeAllObjects];
    [self saveToDisk];
    if ([_delegate respondsToSelector:@selector(clipboardHistoryDidChange:)]) {
        [_delegate clipboardHistoryDidChange:self];
    }
}

- (void)copyToPasteboardAtIndex:(NSUInteger)index {
    if (index >= [_mutableEntries count]) return;
    NSString *s = [_mutableEntries objectAtIndex:index];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [pb clearContents];
    [pb setString:s forType:NSPasteboardTypeString];
#else
    [pb clearContents];
    [pb setString:s forType:NSPasteboardTypeString];
#endif
    _lastPasteboardChangeCount = [pb changeCount];
}

- (void)pollPasteboard {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSInteger count = [pb changeCount];
    if (_lastPasteboardChangeCount < 0) {
        _lastPasteboardChangeCount = count;
        return;
    }
    if (count == _lastPasteboardChangeCount) return;
    _lastPasteboardChangeCount = count;
    NSString *str = [pb stringForType:NSPasteboardTypeString];
    if (str && [str length] > 0) {
        [self addEntry:str];
    }
}

- (void)startMonitoringPasteboard {
    [self stopMonitoringPasteboard];
    _lastPasteboardChangeCount = -1;
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:kPollInterval
                                                  target:self
                                                selector:@selector(pollPasteboard)
                                                userInfo:nil
                                                 repeats:YES];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_pollTimer retain];
#endif
    [[NSRunLoop currentRunLoop] addTimer:_pollTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopMonitoringPasteboard {
    [_pollTimer invalidate];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_pollTimer release];
#endif
    _pollTimer = nil;
}

- (void)loadFromDisk {
    NSString *path = [self historyFilePath];
    id<SSFileSystem> fs = [SSFileSystem sharedFileSystem];
    if (![fs fileExistsAtPath:path]) return;
    NSError *err = nil;
    NSData *data = [fs readFileAtPath:path error:&err];
    if (!data) return;
    NSArray *loaded = [NSPropertyListSerialization propertyListWithData:data
                                                               options:NSPropertyListImmutable
                                                                format:NULL
                                                                 error:&err];
    if (![loaded isKindOfClass:[NSArray class]]) return;
    [_mutableEntries removeAllObjects];
    for (id obj in loaded) {
        if ([obj isKindOfClass:[NSString class]]) {
            [_mutableEntries addObject:obj];
        }
    }
    if ([_delegate respondsToSelector:@selector(clipboardHistoryDidChange:)]) {
        [_delegate clipboardHistoryDidChange:self];
    }
}

- (void)saveToDisk {
    NSString *path = [self historyFilePath];
    id<SSFileSystem> fs = [SSFileSystem sharedFileSystem];
    NSString *dir = [path stringByDeletingLastPathComponent];
    NSError *err = nil;
    [fs createDirectoryAtPath:dir error:&err];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:_mutableEntries
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&err];
    if (data) {
        [fs writeData:data toPath:path error:&err];
    }
}

@end
