//
//  JAFButton.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 11/14/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFButton.h"

@implementation JAFButton

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
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
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
