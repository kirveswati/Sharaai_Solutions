//
//  ViewController.m
//  Tap Me
//
//  Created by Swati K. on 18/08/13.
//
//

#import "ViewController.h"
#import "TapModelObject.h"
#import <QuartzCore/QuartzCore.h>

#define bgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define jsonUrl [NSURL URLWithString:@"http://localhost/bath.json"]


@interface ViewController (PrivateMethods)
//define private methods here
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tiles_bg.png"]];
    [self intialSetup];
    [self startBackgroundThread]; //on app launch only
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)intialSetup{
    
    //set dummy Data till we get json response
    _hotTapObject = [[TapModelObject alloc] initTapModelObject:0 andWaterTemp:HOT_WATER_TEMP andWaterSpeeds:HOT_WATER_SPEED_PER_MIN];
    _coldTapObject = [[TapModelObject alloc] initTapModelObject:0 andWaterTemp:COLD_WATER_TEMP andWaterSpeeds:COLD_WATER_SPEED_PER_MIN];
    
    waterImageHeight = CGRectGetHeight(_waterImage.frame);

    _handImage.center = CGPointMake(_handImage.frame.origin.x + (_handImage.frame.size.width), _handImage.frame.origin.y + (_handImage.frame.size.height * 0.5));
    _handImage.layer.anchorPoint = CGPointMake(1, 0.5);
    
    [self resetSetup];
}


- (void)resetSetup{
   
    _hotTapObject.waterLevel = 0;
    _coldTapObject.waterLevel = 0;
    
    _hotTapObject.currentMode = TAP_OFF;
    _coldTapObject.currentMode = TAP_OFF;
    
    //reset Tap images to off
    [_coldTapButton setImage:[UIImage imageNamed:@"cold_tap_off.png"] forState:UIControlStateNormal];
    [_hotTapButton setImage:[UIImage imageNamed:@"hot_tap_off.png"] forState:UIControlStateNormal];
    
    float degrees = 0; //default temp reading
    _handImage.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    
    [self setWaterLevel];
}


- (void) startBackgroundThread
{
    dispatch_async(bgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:jsonUrl];
        [self performSelectorOnMainThread:@selector(fetchedJsonData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedJsonData:(NSData *)responseData {
    
    if(responseData == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messaging error" message:@"Invalid json data" delegate:self cancelButtonTitle:@"Try with default data" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"hot water temp: %@", [json objectForKey:@"hot_water"]);
    NSLog(@"cold water temp: %@", [json objectForKey:@"cold_water"]);
    
    _hotTapObject.waterTemp = [[json objectForKey:@"hot_water"] floatValue];
    _coldTapObject.waterTemp = [[json objectForKey:@"cold_water"] floatValue];
    
    [self calculateWaterTemp];
    
}

- (void) hotWaterOn{
    
    if((_hotTapObject.waterLevel + _coldTapObject.waterLevel) < MAX_WATER_CAPACITY)
    {
        _hotTapObject.waterLevel += _hotTapObject.waterSpeed / 60;
        [self setWaterLevel];
    }
    else
    {
        //to do
        //code for handling condition if water level reached maximum
        warningAlertType = WATER_OVERFLOW;
        [self displayAlert];
    }
}


- (void) coldWaterOn{
    
    if((_hotTapObject.waterLevel + _coldTapObject.waterLevel) < MAX_WATER_CAPACITY)
    {
        _coldTapObject.waterLevel += _coldTapObject.waterSpeed / 60;
        [self setWaterLevel];
    }
    else
    {
        //to do
        //code for handling condition if water level reached maximum
        warningAlertType = WATER_OVERFLOW;
        [self displayAlert];
    }
}

-(void) displayAlert{
    [timerCold invalidate];
    [timerHot invalidate];
    
    NSString* warningMessage = @"";
    NSString* warningTitle = @"";
    
    if(warningAlertType == WATER_OVERFLOW){
        warningTitle = @"Water overflow Warning";
        warningMessage = @"Beaware! Water level reached its maximum capacity of 150 ltrs";
    }
    else if(warningAlertType == MAX_TEMP){
        warningTitle = @"Maximum temperature";
        warningMessage = @"Beaware! Water temperature is about to cross maximum temp. Water is too HOT";
    }
    else if(warningAlertType == MIN_TEMP){
        warningTitle = @"Minimum temperature";
        warningMessage = @"Beaware! Water temperature is about to cross minimum temp. Water is too COLD";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:warningTitle message:warningMessage delegate:self cancelButtonTitle:@"Tap to reset" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self resetSetup];
}

- (IBAction) hotTapPressed{
    switch (_hotTapObject.currentMode){
        case TAP_OFF:
            [_hotTapButton setImage:[UIImage imageNamed:@"hot_tap_on.png"] forState:UIControlStateNormal];
            _hotTapObject.currentMode = TAP_ON;
            
            timerHot = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hotWaterOn) userInfo:nil repeats:YES];
            
            break;
        case TAP_ON:
            [_hotTapButton setImage:[UIImage imageNamed:@"hot_tap_off.png"] forState:UIControlStateNormal];
            _hotTapObject.currentMode = TAP_OFF;
            
            [timerHot invalidate];
            break;
        default:
            break;
    }
}

- (IBAction) coldTapPressed{
    switch (_coldTapObject.currentMode){
        case TAP_OFF:
            [_coldTapButton setImage:[UIImage imageNamed:@"cold_tap_on.png"] forState:UIControlStateNormal];
            _coldTapObject.currentMode = TAP_ON;
            
            timerCold = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(coldWaterOn) userInfo:nil repeats:YES];
            
            break;
        case TAP_ON:
            [_coldTapButton setImage:[UIImage imageNamed:@"cold_tap_off.png"] forState:UIControlStateNormal];
            _coldTapObject.currentMode = TAP_OFF;
            
            [timerCold invalidate];
            break;
        default:
            break;
    }
}

- (void) setWaterLevel{
    float waterLevelHight = ((_hotTapObject.waterLevel + _coldTapObject.waterLevel) * waterImageHeight) / (MAX_WATER_CAPACITY);
    _waterImage.frame = CGRectMake(CGRectGetMinX(_waterImage.frame), CGRectGetMaxY(_waterImage.frame) - waterLevelHight, CGRectGetWidth(_waterImage.frame), waterLevelHight);
    
    [self calculateWaterTemp];    
}

//min temp - 0, max temp - 180 (assumption)
- (void) calculateWaterTemp{
    float avgTemp = (_hotTapObject.waterLevel + _coldTapObject.waterLevel) > 0 ? ((_hotTapObject.waterLevel * _hotTapObject.waterTemp) + (_coldTapObject.waterLevel * _coldTapObject.waterTemp)) / (_hotTapObject.waterLevel + _coldTapObject.waterLevel) : 0.0f;
    
    //safety check for maximum temp caution
    if(avgTemp > 180){
        //to do
        //code for handling condition if water temp reached maximum
        warningAlertType = MAX_TEMP;
        [self displayAlert];
    }
    else if(avgTemp < 0){
        //to do
        //code for handling condition if water temp reached minimum
        warningAlertType = MIN_TEMP;
        [self displayAlert];
    }
    else{
        _handImage.transform = CGAffineTransformMakeRotation(avgTemp * M_PI/180);
        _tempLabel.text = [NSString stringWithFormat:@"%.02f", avgTemp];
    }
}

@end
