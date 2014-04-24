//
//  AppDelegate.m
//  imageCleaner
//
//  Created by Ruslan Nikolaev on 12/4/13.
//  Copyright (c) 2013 Ruslan Nikolaev. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize pathTextBox, browseButton, searchButton, resultsTextView,progressBar, totalLabel;

- (IBAction)browseButtonClick:(id)sender
{
    NSOpenPanel *openDialog = [NSOpenPanel openPanel];
    
    [openDialog setCanChooseDirectories:true];
    [openDialog setCanChooseFiles:false];
    [openDialog setAllowsMultipleSelection:false];
    
    NSString *filePath;
    if ([openDialog runModal] == NSOKButton)
    {
        filePath = [openDialog URL].path;
    }
    
    if (filePath.length>0)
        [pathTextBox setStringValue:filePath];
}
    
    
- (IBAction)searchButtonClick:(id)sender
{
    [progressBar setStyle:NSProgressIndicatorPreferredAquaThickness];
    mImagesArray = [[NSMutableArray alloc] init];
    mSourceFiles = [[NSMutableArray alloc] init];
    mExtensions = [[NSMutableArray alloc] initWithObjects:@".png", nil];
    mNonUsedImagesArray = [[NSMutableArray alloc] init];
    
    mNonUsedImagesArray = [[NSMutableArray alloc] init];
    mImagesArray = [[NSMutableArray alloc] init];
    mSourceFiles = [[NSMutableArray alloc] init];
    [progressBar setDoubleValue:0.0];
    totalLabel.stringValue = @"";
    
    [self searchForNonusedImagesIn:pathTextBox.stringValue];
}


-(void) searchForNonusedImagesIn: (NSString *) projectPath
{
    [self findAllImagesAndSouce:projectPath];
    
    [progressBar startAnimation:self];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(start:) object:mImagesArray];
    [thread start];
    
}
    
-(void) start: (NSMutableArray *) array
{
    double progressIteration =  100 / (double)mImagesArray.count;
    for (int i=0;i<mImagesArray.count;i++)
    {
        NSString *image = [mImagesArray objectAtIndex:i];
        
        if (![self checkIfImageIsUsed:image])
        {
            NSRange range = [image rangeOfString:@"@2x"];
            if (range.length == 0)
            {
                [mNonUsedImagesArray addObject:[self getFileName:image]];
                [self performSelectorOnMainThread:@selector(setArrayToTextView) withObject:nil waitUntilDone:true];
            }
        }
        [progressBar setDoubleValue:progressBar.doubleValue+progressIteration];
    }
    
    [totalLabel setStringValue:[NSString stringWithFormat:@"Total: %lu",(unsigned long)mNonUsedImagesArray.count]];
    [progressBar stopAnimation:self];
    [progressBar setDoubleValue:0.0];
}

-(void) setArrayToTextView
{
    resultsTextView.string = @"Total:";
    for (NSString *imgStr in mNonUsedImagesArray)
    {
        resultsTextView.string = [resultsTextView.string stringByAppendingString:[NSString stringWithFormat:@"%@\n",imgStr]];
    }
}
    
-(BOOL) checkIfImageIsUsed: (NSString *) image
{
    BOOL imageUsed = false;
    for (int i=0;i<mSourceFiles.count;i++)
    {
        NSString *sourceFile = [mSourceFiles objectAtIndex:i];
        
        NSString *sourceCode = [NSString stringWithContentsOfFile:sourceFile encoding:NSUTF8StringEncoding error:nil];
        
        NSRange range = [sourceCode rangeOfString:[self getFileName:image]];
        if (range.length != 0)
        {
            imageUsed = true;
            break;
        }
        
    }
    
    return imageUsed;
}
    
-(NSString *) getFileName: (NSString *) path
{
    NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
    return fileName;
}
    
-(void) findAllImagesAndSouce: (NSString *) projectPath
{
    NSError *error;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectPath error:&error];
    
    if (error)
    NSLog(@"%@",error);
    else
    {
        // going deep
        
        NSMutableArray *allFiles = [[NSMutableArray alloc] init];
        for (int i=0;i<dirFiles.count;i++)
        {
            NSString *file = [dirFiles objectAtIndex:i];
            file = [NSString stringWithFormat:@"%@/%@",projectPath,file];
            
            [allFiles addObjectsFromArray:[self findFilesAtPath:file]];
        }
        
        [mImagesArray addObjectsFromArray:[self findImages:allFiles]];
        [mSourceFiles addObjectsFromArray:[self findSourceFiles:allFiles]];
    }
}
    
-(NSArray *) findFilesAtPath: (NSString *) filePath
{
    NSMutableArray *allFiles = [[NSMutableArray alloc] init];
    
    BOOL isDir = false;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
    {
        if (isDir)
        {
            NSError *error;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
            
            if (error)
                NSLog(@"%@",error);
            else
            {
                for (int i=0;i<files.count;i++)
                {
                    NSString *file = [files objectAtIndex:i];
                    file = [NSString stringWithFormat:@"%@/%@",filePath,file];
                    
                    [allFiles addObjectsFromArray:[self findFilesAtPath:file]];
                }
            }
            return allFiles;
        }
        else
        {
            return [NSArray arrayWithObject:filePath];
        }
    }
    else
        return nil;
}
    
-(NSArray *) findImages: (NSArray *) files
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i=0;i<mExtensions.count;i++)
    {
        NSArray *extImages = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '%@'",[mExtensions objectAtIndex:i]]]];
        
        [images addObjectsFromArray:extImages];
    }
    
    return images;
}
    
-(NSArray *) findSourceFiles: (NSArray *) files
{
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    for (int i=0;i<mExtensions.count;i++)
    {
        NSArray *mainFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.m'"]];
        NSArray *layoutFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xml'"]];
        
        [sources addObjectsFromArray:mainFiles];
        [sources addObjectsFromArray:layoutFiles];
    }
    
    return sources;
}
    
    
@end
