//
//  TableViewCellCountryCode.m
//  PezcadoVendor
//
//  Created by CodeBrew on 2/22/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

#import "TableViewCellCountryCode.h"

@implementation TableViewCellCountryCode

-(void)configureCell:(id)model indexPath:(NSIndexPath *) indexPath{
    
    NSDictionary *dict = (NSDictionary*)model;
    
    _lblCountryCode.text = [dict valueForKey:@"dial_code"];
    
    _lblCountryName.text = [dict valueForKey:@"name"];
    
    _imgViewCountry.image = [UIImage imageNamed:[[dict valueForKey:@"code"] lowercaseString]];
}
@end
