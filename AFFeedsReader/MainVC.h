//
//  MainVC.h
//  AFFeedsReader
//
//  Created by Álvaro Franco on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMXMLParser.h"

@interface MainVC : UITableViewController <KMXMLParserDelegate> {
    
    UIImageView *postImage;
}

@property (strong, nonatomic) NSMutableArray *parseResults;

@end
