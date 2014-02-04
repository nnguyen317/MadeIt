//
//  AddFavoritesViewController.m
//  OnTime - LA Metro
//
//  Created by Nam Nguyen on 1/7/14.
//  Copyright (c) 2014 Nam Nguyen. All rights reserved.
//

#import "AddFavoritesViewController.h"

@interface AddFavoritesViewController ()
{
    NSString *agencyId;
    NSString *routeId;
    NSString *stopId;
    NSString *directionId;
    NSString *stopName;
}

@property (nonatomic, strong) UITextField *pickerViewTextField;
@property (nonatomic, strong) NSMutableArray *pickerContainer;
@property (nonatomic, strong) UIPickerView *pickerView;
@property int lastTag;


@end


@implementation AddFavoritesViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize agencyLabel = _agencyLabel;
@synthesize lineLabel = _lineLabel;
@synthesize stationLabel = _stationLabel;
@synthesize directionLabel = _directionLabel;
@synthesize customPicker = _customPicker;
@synthesize agencyList = _agencyList;
@synthesize routeList = _routeList;
@synthesize stopList = _stopList;
@synthesize stopTimes = _stopTimes;
@synthesize agencyButton = _agencyButton;
@synthesize lineButton = _lineButton;
@synthesize stationButton = _stationButton;
@synthesize agency = _agency;
@synthesize stops = _stops;
@synthesize routes = _routes;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.pickerViewTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pickerViewTextField];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.pickerViewTextField.inputView = _pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.pickerViewTextField.inputAccessoryView = toolBar;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buttonSelect:(id)sender {
    Metro *metro = [[Metro alloc] init];
    UIButton *button = (UIButton *)sender;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [_pickerContainer removeAllObjects];
    
    switch (button.tag) {
        case 100:
            _lineButton.enabled = NO;
            _agencyList = [[NSMutableArray alloc]init];
            _agencyList = [metro getMetroAgencyList:@""];
            
            for (int i=0; i<_agencyList.count; i++) {
                _agency = _agencyList[i];
                [tempArray addObject:_agency.agencyName];
            }
            
            break;
            
        case 101:
            self.routeList = [metro getRoutes:agencyId forDatabase:agencyId];
            for (int i=0; i<_routeList.count; i++) {
                _routes = _routeList[i];
                [tempArray addObject:_routes.routeName];
            }
            break;
        case 102:
            self.stopList = [metro getStopsForRoute:routeId forAgency:agencyId forDatabase:agencyId];
            for (int i=0; i<_stopList.count; i++) {
                _stops = _stopList[i];
                [tempArray addObject:_stops.stopName];
            }
            break;
        case 103:
            [tempArray addObject:@"0"];
            [tempArray addObject:@"1"];
            break;
        default:
            break;
    }

    _pickerContainer = tempArray;
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:0 inComponent:0 animated:YES];

    [self.pickerViewTextField becomeFirstResponder];
    self.lastTag = button.tag;

}

- (IBAction)cancelAddFavorites:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveFavorites:(id)sender {
        
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Favorites" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *stationArray = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    BOOL update = YES;
    
    for (Favorites *favorites in stationArray) {
        if([favorites.route_id isEqualToString:routeId] && [favorites.agency_id isEqualToString:agencyId] && [favorites.direction_id isEqualToString:directionId] && [favorites.stop_id isEqualToString:stopId]){
            update = NO;
        }
    }

    if(update){
        Favorites *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites"
                                                      inManagedObjectContext:self.managedObjectContext];
    
        newEntry.agency_id = agencyId;
        newEntry.route_id = routeId;
        newEntry.stop_id = stopId;
        newEntry.stop_name = stopName;
        newEntry.direction_id = directionId;
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.pickerViewTextField resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.pickerViewTextField resignFirstResponder];
    NSInteger row = [_pickerView selectedRowInComponent:0];
    
    
    switch (self.lastTag) {
        case 100:
            [_lineButton setTitle:@"Select....." forState:UIControlStateNormal];
            [_stationButton setTitle:@"Select....." forState:UIControlStateNormal];
            [_directionButton setTitle:@"Select....." forState:UIControlStateNormal];
            
            [_agencyButton setTitle:_pickerContainer[row] forState:UIControlStateNormal];
            _lineButton.enabled = YES;
            _stationButton.enabled = NO;
            _directionButton.enabled = NO;
            _agency = _agencyList[row];
            agencyId = _agency.agencyId;
            break;
        case 101:
            [_stationButton setTitle:@"Select....." forState:UIControlStateNormal];
            [_directionButton setTitle:@"Select....." forState:UIControlStateNormal];
            
            [_lineButton setTitle:_pickerContainer[row] forState:UIControlStateNormal];
            _stationButton.enabled = YES;
            _directionButton.enabled = NO;
            _routes = _routeList[row];
            routeId = _routes.routeId;
            break;
        case 102:
            [_directionButton setTitle:@"Select....." forState:UIControlStateNormal];

            [_stationButton setTitle:_pickerContainer[row] forState:UIControlStateNormal];
            _directionButton.enabled = YES;
            _stops = _stopList[row];
            stopId = _stops.stopId;
            stopName = _stops.stopName;
            break;
        case 103:
            [_directionButton setTitle:_pickerContainer[row] forState:UIControlStateNormal];
            directionId = _pickerContainer[row];
            break;
        default:
            break;
    }
    
    // perform some action
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if ([pickerView isEqual:pickerView]){
        return 1;
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if ([pickerView isEqual:pickerView]) {
        return _pickerContainer.count;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if([pickerView isEqual:pickerView]){
        
        return _pickerContainer[row];
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
}

@end
