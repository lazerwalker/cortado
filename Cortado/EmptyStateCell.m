//
//  EmptyStateCell.m
//  Cortado
//
//  Created by Michael Walker on 3/16/15.
//  Copyright (c) 2015 Lazerwalker. All rights reserved.
//

#import "EmptyStateCell.h"

@implementation EmptyStateCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
