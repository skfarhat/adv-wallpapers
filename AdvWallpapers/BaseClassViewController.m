//
//  BaseClassViewController.m
//   
//
//  Created by Sami Farhat on 18/04/2016.
//  Copyright © 2016 Sami Farhat. All rights reserved.
//

#import "BaseClassViewController.h"

@interface BaseClassViewController ()

@end

@implementation BaseClassViewController
@synthesize filenames;
@synthesize slideshow;

// UI
@synthesize imageView;
@synthesize pathControl;
@synthesize randomCheckbox, rotationComboBox;
@synthesize daysTextField, hoursTextField, secTextField, minTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    index = 0;
    IMAGE_EXTENSIONS = @[@"jpg", @"JPG", @"jpeg", @"JPEG", @"png", @"PNG", @"BMP", @"bmp",
                         @"tiff", @"TIFF"];
    
    NSArray *rotationStrings = [NSArray arrayWithObjects:
                                @"Off", @"Interval", @"Login", @"Sleep", nil];
    [self.rotationComboBox addItemsWithObjectValues:rotationStrings];
    if ([rotationStrings count] > 0)
        [self.rotationComboBox selectItemAtIndex:0];
}

-(void)refresh {
    if (!slideshow) return;
    
    // get all files from the selected directory path, then filter it leaving
    // only jpg and png files
    filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:slideshow.path error:nil];
    filenames = [filenames filteredArrayUsingPredicate:
                 [NSPredicate predicateWithFormat:@"(pathExtension IN %@)", IMAGE_EXTENSIONS]];
    [self updateImageView];
    
    [pathControl setURL:[NSURL URLWithString:slideshow.path]];
    
}

-(void) updateImageView {
    if (filenames == NULL || [filenames count] < 1)
        return;
    
    /* update ImageView */
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@", slideshow.path, filenames[index]];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPath];
    [imageView setImage:img];
}

-(void)setSlideshow:(Slideshow *)slideshow1{
    slideshow = slideshow1;
    [self refresh];
    
}

#pragma mark -
#pragma mark KeyDelegate

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
            [self prevImage:nil];
            break;
        }
        case NSRightArrowFunctionKey:
        {
            [self nextImage:nil];
            break;
        }
        case 27:
        {
            [self handleEscape];
            break;
        }
        default:
        {
            NSLog(@"key: %d", code);
        }
    }
}

-(void)handleEscape {
    // do nothing
    // this method is to be overridden by child classes
}

-(void)updateRotationCombobox {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger i =  slideshow.rotation.integerValue;
    NSLog(@"%ld %@", i, slideshow.rotation);
    if ( i > -1 && i < rotationComboBox.numberOfItems) {
        [rotationComboBox selectItemAtIndex:i];
    }
}

-(void)updateRandomCheckbox {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSInteger i = self.slideshow.random.integerValue;
    NSLog(@"index; %ld", i);
    if (i == 0 || i == 1) {
        [randomCheckbox setState:i];
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)nextImage:(id)sender {
    if (++index == [filenames count])
        index = 0;
    
    [self refresh];
}

-(IBAction)prevImage:(id)sender {
    if (--index < 0)
        index = [filenames count] - 1;
    
    [self refresh];
}

- (IBAction)pathControlClicked:(id)sender {
    NSURL *url = [pathControl objectValue];
    [slideshow setPath:url.path];
    [slideshow save];
    [self refresh];
}

-(BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id<NSDraggingInfo>)info{
    return YES;
}
@end
