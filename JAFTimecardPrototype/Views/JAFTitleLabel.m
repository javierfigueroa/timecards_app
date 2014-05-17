//
//  JAFTitleLabel.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 11/14/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFTitleLabel.h"

@implementation JAFTitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.font = [UIFont fontWithName:@"OpenSans-Light" size:self.font.pointSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
