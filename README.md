# SmallClipboard

A clipboard manager for GNUstep that keeps a history of copied text. Uses [SmallStepLib](../SmallStepLib) for application lifecycle, menus, window style, and file system (persistence).

## Features

- **History**: Records text copied to the system clipboard (general pasteboard). Newest first; duplicates are moved to the top.
- **Persistence**: History is saved to disk using SmallStepLib’s `SSFileSystem` (on Linux: `~/.local/share/SmallClipboard/history.plist`).
- **UI**: Main window with a table of entries, preview field, **Copy** (copy selected back to clipboard), **Clear History**.
- **Menu**: SmallClipboard menu with “Show History”, “Clear History”, and “Quit SmallClipboard”.

## Build

1. Build and install SmallStepLib (from its directory):
   ```bash
   cd ../SmallStepLib && make && make install
   ```
2. Build SmallClipboard:
   ```bash
   . /usr/share/GNUstep/Makefiles/GNUstep.sh   # or your GNUStep env
   make
   ```

Run the app from the build directory, e.g. `./SmallClipboard.app/SmallClipboard` or open `SmallClipboard.app`.

## Requirements

- GNUstep (gnustep-gui, gnustep-base)
- SmallStepLib built as a framework (see SmallStepLib README; if the library fails to build due to non-ARC on GNUstep, you may need to fix or build it with ARC)

## How it works

- **Pasteboard monitoring**: The app polls `[NSPasteboard generalPasteboard]` every 0.5 s. When `changeCount` changes, it reads the string (type `NSPasteboardTypeString` / `NSStringPboardType`) and prepends it to the in-memory history.
- **Persistence**: History is stored as a plist array of strings. It’s loaded at startup and saved whenever the history changes.
- **Max entries**: Default cap is 100 entries (configurable via `ClipboardHistory.maxEntries`).

## License

See the LICENSE file in this repository.
