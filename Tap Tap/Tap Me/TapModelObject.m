//
//  TapModelObject.m
//  Tap Me
//
//  Created by SK on 18/08/2013.
//
//

#import "TapModelObject.h"

@implementation TapModelObject

-(id) initTapModelObject:(double)waterLevel andWaterTemp: (double) waterTemp andWaterSpeeds:(double)waterSpeed
{
    if ( (self = [super init]) != nil )
    {
        _waterLevel = waterLevel;
        _waterTemp = waterTemp;
        _waterSpeed = waterSpeed;
        _currentMode = TAP_OFF;
    }
    return self;
}


@end
