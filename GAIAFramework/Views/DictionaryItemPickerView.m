//
//  DictionaryItemPickerView.m
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import "DictionaryItemPickerView.h"
#import "DictionaryManager.h"

@implementation DictionaryItemPickerView {
@private
    UIGestureRecognizer *_tapper;
    whenConfirmChoose _onConfirmChoose;
    NSArray<NSDictionary*>* _dictionary;
    NSArray<NSDictionary*>* _cloneDictionary;
    NSDictionary* _choosedItem;
    UIActivityIndicatorView *_activityIndicatorView;
}



-(void) awakeFromNib {
    [super awakeFromNib];
    
    _tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(onBackgrouTap:)];
    _tapper.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_tapper];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.frame = screenRect;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
    [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
    [_activityIndicatorView setBackgroundColor:[UIColor clearColor]];
    [_activityIndicatorView setColor:[UIColor grayColor]];
    _activityIndicatorView.hidesWhenStopped = YES;
    _activityIndicatorView.center = self.center;
    
    [_tableView addSubview:_activityIndicatorView];
}

- (void)onBackgrouTap:(UITapGestureRecognizer *) sender
{
    [self endEditing:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setCallback:(whenConfirmChoose) whenConfirmChoose
{
    _onConfirmChoose = whenConfirmChoose;
}

- (void)handlerMaskViewTap:(UITapGestureRecognizer *)recognizer {
    [self dismissView];
}

-(void) dismissView{
    [self goBack: self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dictionary?_dictionary.count:0;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    _btnOK.enabled = YES;
    [self confirmChoose:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSDictionary* data = _dictionary[indexPath.row];
    NSLog(@"%@", data);
    
    cell.textLabel.text = data[@"name"];
    
    return cell;
}

-(NSArray<NSDictionary*>*) searchText:(NSString*) searchText
{
    NSMutableArray* found = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in _dictionary) {
        if([dict[@"name"] rangeOfString:searchText].location != NSNotFound) {
            [found addObject:dict];
        }
    }
    
    return found;
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* searchText = searchBar.text;
    if(searchText.length > 0) {
        _cloneDictionary = [_dictionary copy];
        _dictionary = [self searchText:searchText];
    } else {
        if(_cloneDictionary)
        {
            _dictionary = [_cloneDictionary copy];
            _cloneDictionary = nil;
        }
    }
    
    [_tableView reloadData];
    [searchBar resignFirstResponder];
}

-(void) requestDictionary:(NSString*) dictionaryName  queryParams:(NSDictionary*) queryParams
{
    [_activityIndicatorView startAnimating];
    [[DictionaryManager shareInstance] getDictionaryByName:dictionaryName queryParams:queryParams whenGot:^(NSArray<NSDictionary *> *data) {
        self->_dictionary = data;
        [self->_tableView reloadData];
        [self->_activityIndicatorView stopAnimating];
    }];
}

+(void) popup:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams multiSelection:(BOOL) multiSelection parentView:(UIView*) superView callback:(whenConfirmChoose) confirmChoose
{
    UINib* nib = [UINib nibWithNibName:@"DictionaryItemPickerView" bundle:nil];
    NSArray* views = [nib instantiateWithOwner:self options:nil];
    
    DictionaryItemPickerView *pickerView = views[0];
    [pickerView setCallback:confirmChoose];
    if(multiSelection)
        pickerView.tableView.allowsMultipleSelection = YES;
    else
        pickerView.tableView.allowsSelection = YES;
    
    [superView addSubview:pickerView];
    [pickerView requestDictionary:dictionaryName queryParams:queryParams];
}

+(void) popup:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams parentView:(UIView*) superView callback:(whenConfirmChoose) confirmChoose{
    [DictionaryItemPickerView popup:dictionaryName queryParams:queryParams multiSelection:false parentView:superView callback:confirmChoose];
}

-(void)goBack:(id)sender {
    [self removeFromSuperview];
}

-(void)confirmChoose:(id)sender{
    if(_tableView.allowsMultipleSelection) {
        NSArray<NSIndexPath *> *indexPathsForSelectedRows = [_tableView indexPathsForSelectedRows];
        NSMutableArray<NSDictionary*>* selectedDatas = [[NSMutableArray alloc] init];
        for(NSIndexPath* indexPath in indexPathsForSelectedRows) {
            [selectedDatas addObject:_dictionary[indexPath.row]];
        }
        
        if(_onConfirmChoose) {
            _onConfirmChoose([[NSArray alloc] initWithArray:selectedDatas]);
        }
        else {
            NSLog(@"未指定会调函数");
        }
        
        [self dismissView];
    } else {
        NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
        if(selectedIndexPath.row >= 0 && selectedIndexPath.row < _dictionary.count)
        {
            _choosedItem = _dictionary[selectedIndexPath.row];
            
            if(_onConfirmChoose) {
                _onConfirmChoose(_choosedItem);
            }
            else {
                NSLog(@"未指定会调函数");
            }
            
            [self dismissView];
        }
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
