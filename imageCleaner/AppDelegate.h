//
//  AppDelegate.h
//  imageCleaner
//
//  Created by Ruslan Nikolaev on 12/4/13.
//  Copyright (c) 2013 Ruslan Nikolaev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
    {
        NSString        *mProjectPath;
        NSMutableArray  *mImagesArray;
        NSMutableArray  *mNonUsedImagesArray;
        NSMutableArray  *mSourceFiles;
        NSMutableArray  *mExtensions;
    }
@property (assign) IBOutlet NSWindow *window;
    
@property (weak) IBOutlet NSTextField *pathTextBox;
@property (weak) IBOutlet NSButton *browseButton;
@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *totalLabel;
@property (unsafe_unretained) IBOutlet NSTextView *resultsTextView;
    

@end
