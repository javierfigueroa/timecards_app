//
//  JAFSettingsCell.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 5/13/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSettingsCell.h"
#import "UIColor+Timecards.h"

@implementation JAFSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected && self.selectionStyle != UITableViewCellSelectionStyleNone) {
        
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor timecardsDarkBlueColor];
    }else{
        
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor timecardsLightGrayColor];
        self.textLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:17];
    }
    
}

@end
