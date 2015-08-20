//
//  AreaNameAndCodeViewController.m
//  SugarNursing
//
//  Created by Dan on 14-12-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AreaNameAndCodeViewController.h"

@interface AreaNameAndCodeViewController ()<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *indexKeys;
@property (strong, nonatomic) NSDictionary *allNameAndCode;
@property (strong, nonatomic) NSMutableDictionary *areaNameAndCode;

@end

@implementation AreaNameAndCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"countrychoose", nil);
    [self getCountryCodeFromPlist];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)getCountryCodeFromPlist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.allNameAndCode = dict;
    [self setSearchKeys];
}

- (void)setSearchKeys
{
    self.areaNameAndCode = [self.allNameAndCode mutableDeepCopy];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObject:UITableViewIndexSearch];
    [keyArray addObjectsFromArray:[[self.areaNameAndCode allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    self.indexKeys = keyArray;
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
    
    [self setSearchKeys];
    
    for (NSString *key in self.indexKeys) {
        NSMutableArray *array = [self.areaNameAndCode valueForKey:key];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (NSString *name in array) {
            if ([name rangeOfString:searchTerm
                            options:NSCaseInsensitiveSearch].location == NSNotFound)
                [toRemove addObject:name];//add the  unfit object to remove array
        }
        
        //if all of the object in this section are unfit
        //add whole array's key to  section remove array
        if ([array count] == [toRemove count])
            [sectionsToRemove addObject:key];
        
        //remove the unfit objects in toRemove array
        [array removeObjectsInArray:toRemove];
        //[toRemove release];
    }
    // remove the unfit sections in sectionsToRemove array
    [self.indexKeys removeObjectsInArray:sectionsToRemove];
    //[sectionsToRemove release];
    
    //reload tableView data
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.indexKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.indexKeys == 0) {
        return 0;
    }
    NSString *key = [self.indexKeys objectAtIndex:section];
    NSArray *rowArray = [self.areaNameAndCode objectForKey:key];
    return [rowArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCodeIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCountryCodeCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCountryCodeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nameSection = self.areaNameAndCode[self.indexKeys[indexPath.section]];
    NSString *areaNameCodeString = nameSection[indexPath.row];
    NSRange range = [areaNameCodeString rangeOfString:@"+"];
    NSString *areaCode = [[areaNameCodeString substringFromIndex:range.location] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *areaName = [areaNameCodeString substringToIndex:range.location];
    
    cell.textLabel.text = areaName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",areaCode];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.indexKeys count] == 0) {
        return nil;
    }
    NSString *key = [self.indexKeys objectAtIndex:section];
    if (key == UITableViewIndexSearch) {
        return nil;
    }
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexKeys;
}

#pragma mark - TableView delegate

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //you can selectd a row to exit the searching mode
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.isSearching = NO;
    [self.tableView reloadData];
    return indexPath;
}
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    NSString *key = [self.indexKeys objectAtIndex:index];
    //if it is click the search title,show the search bar,else show the section at index
    if (key == UITableViewIndexSearch)
    {
        //show the search bar
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    else return index;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nameSection = self.areaNameAndCode[self.indexKeys[indexPath.section]];
    NSString *areaNameCodeString = nameSection[indexPath.row];
    NSRange range = [areaNameCodeString rangeOfString:@"+"];
    NSString *areaCode = [[areaNameCodeString substringFromIndex:range.location] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *areaName = [areaNameCodeString substringToIndex:range.location];
    
    self.countryAndAreaCode.countryName = areaName;
    self.countryAndAreaCode.areaCode = areaCode;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //click search button at keyboard,will do something
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.isSearching = YES;
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchTerm
{
    if ([searchTerm length] == 0)
    {
        [self setSearchKeys];
        [self.tableView reloadData];
        return;
    }
    
    //when you type something in text field,the search is beginning(synchronization)
    [self handleSearchForTerm:searchTerm];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //reset Search bar
    self.isSearching = NO;
    self.searchBar.text = @"";
    
    [self setSearchKeys];
    [self.tableView reloadData];
    
    //dismiss the keyboard
    [searchBar resignFirstResponder];
}



@end
