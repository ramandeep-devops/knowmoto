//
//  TableViewCellCountryCode.h
//  PezcadoVendor
//
//  Created by CodeBrew on 2/22/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellCountryCode : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblCountryName;

@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewCountry;

-(void)configureCell:(id)model indexPath:(NSIndexPath *) indexPath;

@end
