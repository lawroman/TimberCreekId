//
//  ViewController.m
//  TimberCreekId
//
//  Created by Roman Law on 8/25/16.
//  Copyright © 2016 Roman Law. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void) writeToTextFile:(NSString *)infoString;
- (NSString *) getStudentIdContent;
- (CIImage *) createQRForString:(NSString *)qrString;
- (void) setWidgetsVisible:(Boolean)value;
- (NSString *) getTimeStamp;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *registeredInfo = [self getStudentIdContent];

    if (!registeredInfo)
    {
        // hide the inputs
        [self setWidgetsVisible:true];
        
        NSString *idInfo = [registeredInfo stringByAppendingString:@"#"];
        idInfo = [idInfo stringByAppendingString:[self getTimeStamp]];
        
        CIImage *qr = [self createQRForString:idInfo];
        UIImage *uiImage = [[UIImage alloc] initWithCIImage:qr];
        self.qrCodeView.image = uiImage;

        NSString *titleString = @"Registered to ";
        NSUInteger startRange =[registeredInfo rangeOfString:@"#"].location +1;
        NSRange range = NSMakeRange(startRange, registeredInfo.length - startRange);
        self.bannerLabel.text = [titleString stringByAppendingString:[registeredInfo substringWithRange:range]];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButton:(UIButton *)sender {
    // save student info to a permanent storage
    NSString *myInfo;
    NSString *myId = _idText.text;
    NSString *myName = _nameText.text.uppercaseString;
    
    if (!myId && !myName)
    {
    myInfo = myId;
    myInfo = [myInfo stringByAppendingString:@"#"];
    myInfo = [myInfo stringByAppendingString:myName];
    
    // local location
    [self writeToTextFile:myInfo];
    // and icloud if possible
    
    NSString *titleString = @"Registered to ";
    _bannerLabel.text = [titleString stringByAppendingString:myName ];
    
    // append current timestamp
    myInfo = [myInfo stringByAppendingString:@"#"];
    myInfo = [myInfo stringByAppendingString:[self getTimeStamp]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Home of the Wolves" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [alert show];
    
    // show only the new QR code on screen
    [self setWidgetsVisible:true];
    CIImage *qr = [self createQRForString:myInfo];
    UIImage *uiImage = [[UIImage alloc] initWithCIImage:qr];
    self.qrCodeView.image = uiImage;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter the ID and Name." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

//Method writes a string to a text file
-(void) writeToTextFile:(NSString *)infoString{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/id.txt",
                          documentsDirectory];
    
    //create content
    NSString *content = infoString;
    //save content to the documents directory
    [content writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    
}


//Method retrieves content from documents directory
-(NSString *) getStudentIdContent{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to read the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/id.txt",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    return content;
}

//Method to set the widgets
- (void) setWidgetsVisible:(Boolean)value {
    //
    self.nameLabel.hidden = value;
    self.nameText.hidden = value;
    self.idLabel.hidden = value;
    self.idText.hidden = value;
    self.registerButton.hidden = value;
    
}

//Method generates a QR image
- (CIImage *) createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    return qrFilter.outputImage;
}

// Method to create a timestamp string
- (NSString *) getTimeStamp {
    NSDate *todaysDate = [NSDate new];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"DDDHHmm"];
    NSString *dateTimeString = [formatter stringFromDate:todaysDate];
    
    return dateTimeString;
}
@end
