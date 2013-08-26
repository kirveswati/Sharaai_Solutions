//
//  ViewController.h
//  Tap Me
//
//  Created by Swati K. on 18/08/13.
//
//

#import <UIKit/UIKit.h>

#define MAX_WATER_CAPACITY 150
#define HOT_WATER_SPEED_PER_MIN 10
#define COLD_WATER_SPEED_PER_MIN 12

//dummy data
#define HOT_WATER_TEMP 50
#define COLD_WATER_TEMP 10

typedef enum {
    WATER_OVERFLOW,
    MAX_TEMP,
    MIN_TEMP
} WarningAlertType;

@class TapModelObject;

@interface ViewController : UIViewController<UIAlertViewDelegate>{        
    WarningAlertType warningAlertType;
    
    NSInteger waterImageHeight;
    NSInteger count;
    NSInteger seconds;
    
    NSTimer *timerHot;
    NSTimer *timerCold;

}

@property (nonatomic, strong) IBOutlet UILabel *tempLabel;
@property (nonatomic, strong) IBOutlet UIButton *hotTapButton;
@property (nonatomic, strong) IBOutlet UIButton *coldTapButton;
@property (nonatomic, strong) IBOutlet UIImageView *waterImage;
@property (nonatomic, strong) IBOutlet UIImageView *handImage;

@property (nonatomic, strong) TapModelObject* hotTapObject;
@property (nonatomic, strong) TapModelObject* coldTapObject;

- (IBAction) hotTapPressed;
- (IBAction) coldTapPressed;
@end
