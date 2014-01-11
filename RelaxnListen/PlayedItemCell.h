//
//  PlayedItemCell.h
//  RelaxnListen
//
//  Created by Stephen on 1/8/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayedItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * bookName;
@property (nonatomic, weak) IBOutlet UILabel * lastAtLbl;
@property (nonatomic, weak) IBOutlet UIImageView * image;

@end
