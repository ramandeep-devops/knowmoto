//
//  CountryCodeSearchViewController.h
//  PezcadoVendor
//
//  Created by CodeBrew on 2/22/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryCodeSearchDelegate <NSObject>

-(void)didTapOnCode:(NSDictionary*)detail;

@end

@interface CountryCodeSearchViewController : UIViewController

@property(weak , nonatomic) id <CountryCodeSearchDelegate> delegate;

@end
