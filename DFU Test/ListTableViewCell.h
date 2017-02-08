//
//  ListTableViewCell.h
//  DFU Test
//
//  Created by Aahir Giri on 06/02/17.
//  Copyright © 2017 Aahir Giri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *peripheralLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
