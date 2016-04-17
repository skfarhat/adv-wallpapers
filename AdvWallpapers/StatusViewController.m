//
//  StatusWindowController.m
//  AdvWallpapers
//
//  Created by Sami Farhat on 13/04/2016.
//  Copyright © 2016 Sami Farhat. All rights reserved.
//

#import "StatusViewController.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1
#define STATUS_ITEM_VIEW_WIDTH 24.0
#define SEARCH_INSET 17
#define POPUP_HEIGHT 122
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1
#define ARROW_WIDTH 12
#define ARROW_HEIGHT 8


@interface StatusViewController ()

@end

@implementation StatusViewController
@synthesize slideshow;
@synthesize pathControl;
@synthesize imageView;
@synthesize statusMainView;

-(id)initWithCoder:(NSCoder *)coder{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self  = [super initWithCoder: coder];
    if (self)
    {
        NSImage *img = [NSImage imageNamed:@"instagram"];
        
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        [statusItem setHighlightMode:YES];
        [statusItem setImage:img];
        [statusItem setAction:@selector(togglePanel:)];
        
        statusView = [[StatusView alloc] init];
        [statusView setStatusItem:statusItem];
        
        [statusView setAction:@selector(togglePanel:)];
        [statusView setTarget:self];
        [statusView setNeedsDisplay:YES];
        
        [statusItem setView: statusView];
        
        alreadyOpen = false;
        
    }
    return self;
}

-(BOOL)acceptsFirstResponder{
    return YES; 
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    StatusMainView *view = (StatusMainView*) self.view;
    [view setKeyDelegate:self];
    
}
- (void)flagsChanged:(NSEvent *)theEvent {
    commandDown = false;
    
    // command pressed
    if ([theEvent modifierFlags] & NSCommandKeyMask) {
        commandDown = true;
    }
}

-(void)keyDown:(NSEvent *)theEvent{
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    
    switch (code)
    {
        case NSUpArrowFunctionKey:
        {
            break;
        }
        case NSDownArrowFunctionKey:
        {
            break;
        }
        case NSLeftArrowFunctionKey:
        {
            [self prevImageButtonPressed:nil];
            //            [self navigateToPreviousImage];
            break;
        }
        case NSRightArrowFunctionKey:
        {
            [self nextImageButtonPressed:nil];
            //            [self navigateToNextImage];
            break;
        }
        case 27:
        {
            [self closePanel];
            break;
        }
        case 44:
        {
            if (commandDown) [self settingsButtonPressed:nil];
        }
        default:
        {
            NSLog(@"key: %d", code);
        }
    }
}

#pragma mark -
- (void)openPanel
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // some config
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSWindow *panel = [[self view] window];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    // the panel of this window
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    // new panel
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect panelRect = [panel frame];
    panelRect.size.width = 300.0f;
    panelRect.size.height = 400.0f;
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
//    [panel performSelector:@selector(makeFirstResponder:) withObject:nil afterDelay:openDuration];
//    
    [self.view.window makeFirstResponder:statusMainView];
}

- (void)closePanel
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[[self view] window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.view.window orderOut:nil];
    });
    [self.view.window makeFirstResponder:nil]; 
}

- (IBAction)togglePanel:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (alreadyOpen)    [self closePanel];
    else                [self openPanel];
    
    alreadyOpen = !alreadyOpen;
}

#pragma mark -


- (NSRect)statusRectForWindow:(NSWindow *)window {
    NSRect statusRect = NSZeroRect;
    if (statusView)
    {
        statusRect = statusView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    return statusRect;
}

-(void)refresh {
    // set the image
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",
                           slideshow.path, filenames[index]];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    [imageView setImage:image];
}

- (IBAction)prevImageButtonPressed:(id)sender {
    if (index-- == 0) {
        index = [filenames count] - 1;
    }
    
    [self refresh];
}

- (IBAction)nextImageButtonPressed:(id)sender {
    if (index++ == [filenames count] - 1) {
        index = 0;
    }
    
    [self refresh];
}

- (IBAction)applyButtonPressed:(id)sender {
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"SetDesktopPicture" ofType:@"applescript"];
    NSString *contents = [NSString stringWithContentsOfFile:scriptPath encoding:
                          NSUTF8StringEncoding error:nil];
    NSString *s = [NSString stringWithFormat:contents, [self getcurrentFilename]];
    NSDictionary *errorDict;
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:s];
    [scriptObject executeAndReturnError: &errorDict];
    
    NSLog(@"%@", errorDict.description);
}

- (IBAction)settingsButtonPressed:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // tell app delegate to open the mainview controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMainViewController" object:nil userInfo:nil];
}

-(void)setSlideshow:(Slideshow *)slideshow1{
    slideshow = slideshow1;
    filenames = [[NSFileManager defaultManager]
                 contentsOfDirectoryAtPath:slideshow.path
                 error:nil];
    
    filenames = [filenames filteredArrayUsingPredicate:
                 [NSPredicate predicateWithFormat:@"(pathExtension IN %@)", @[@"jpg", @"png", @"JPG"]]];
    
    
    NSURL *url = [NSURL URLWithString:slideshow.path];
    [pathControl setURL:url];
    // TODO: refresh the view here
    [self refresh];
}

/** returns the fullpath to the currently selected image */
-(NSString*)getcurrentFilename {
    return [NSString stringWithFormat:@"%@/%@", slideshow.path, filenames[index]];
}

#pragma mark -
#pragma mark PathControl 


-(BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id<NSDraggingInfo>)info{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}
- (IBAction)pathControlClicked:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSURL *url = [pathControl objectValue];
    [slideshow setPath:url.path];
    [slideshow save];
    [self refresh];
}



@end