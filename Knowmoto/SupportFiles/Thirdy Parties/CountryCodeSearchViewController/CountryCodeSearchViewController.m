//
//  CountryCodeSearchViewController.m
//  PezcadoVendor
//
//  Created by CodeBrew on 2/22/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

#import "CountryCodeSearchViewController.h"
#import "TableViewCellCountryCode.h"

@interface CountryCodeSearchViewController ()<UISearchBarDelegate , UITableViewDelegate , UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tblViewCountryCode;
@property (strong,nonatomic) NSArray *countryCodeArray;
@property (strong,nonatomic) NSArray *searchResultArray;
@property (strong , nonatomic) NSMutableArray * arrDataSource;
@property (assign) BOOL searchBarActive;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation CountryCodeSearchViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _countryCodeArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CallingCodes" ofType:@"plist"]];
    [self setNeedsStatusBarAppearanceUpdate];
    _arrDataSource = [[NSMutableArray alloc] init];
    _arrDataSource = _countryCodeArray.mutableCopy;
    
    _tblViewCountryCode.delegate   = self;
    _tblViewCountryCode.dataSource = self;
    
 
//    [self configureTableDataWithArray:_countryCodeArray];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
      [_searchBar endEditing:YES];
}

- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table DataSource

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _arrDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCellCountryCode *cell = [tableView dequeueReusableCellWithIdentifier:@"countryCodeCell"];
    
    [cell configureCell:_arrDataSource[indexPath.row] indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    NSDictionary *currDict = nil;
    
    if(_searchBarActive)
        currDict = [_searchResultArray objectAtIndex:indexPath.row];
    else
        currDict = [_countryCodeArray objectAtIndex:indexPath.row];
    
    [self.delegate didTapOnCode: currDict];
    
    [self dismissViewControllerAnimated: YES completion : nil];
}


#pragma mark - Search Bar Delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSDictionary *dict = (NSDictionary*)evaluatedObject;
        NSString *stringName;
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if (([searchText rangeOfCharacterFromSet:notDigits].location == NSNotFound) ||     ([searchText containsString:@"+"])){
            // newString consists only of the digits 0 through 9
            stringName = [dict valueForKey:@"dial_code"];
        }else{
            stringName = [dict valueForKey:@"name"];
        }
        
        BOOL nameMatches = [[stringName lowercaseString] hasPrefix:[searchText lowercaseString]];
        
        if(nameMatches){
            return YES;
        }
        return NO;
    }];
    _searchResultArray  = [_countryCodeArray filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0) {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText
                                   scope:[[self.searchBar scopeButtonTitles]
                                          objectAtIndex:[self.searchBar
                                                         selectedScopeButtonIndex]]];
        _arrDataSource = [NSMutableArray new];
        _arrDataSource = _searchResultArray.mutableCopy;
        
        [self.tblViewCountryCode reloadData];
        
    }else{
        // if text length == 0
        // we will consider the searchbar is not active
        _arrDataSource = [NSMutableArray new];
        _arrDataSource = _countryCodeArray.mutableCopy;
        [self.tblViewCountryCode reloadData];
        self.searchBarActive = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    _arrDataSource = [NSMutableArray new];
    _arrDataSource = _countryCodeArray.mutableCopy;
    [self.tblViewCountryCode reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [searchBar endEditing:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.searchBarActive = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark- Search Cancel Button Action

-(void)cancelSearching{
    self.searchBarActive = NO;
    [self.searchBar resignFirstResponder];
}

@end
