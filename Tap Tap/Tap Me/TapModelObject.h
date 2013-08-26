//
//  TapModelObject.h
//  Tap Me
//
//  Created by SK on 18/08/2013.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    TAP_OFF,
    TAP_ON
} TapMode;


@interface TapModelObject : NSObject

@property (readwrite, nonatomic) double waterLevel;
@property (readwrite, nonatomic) double waterTemp;
@property (readwrite, nonatomic) double waterSpeed;
@property (nonatomic) TapMode currentMode;

-(id) initTapModelObject:(double)waterLevel andWaterTemp: (double) waterTemp andWaterSpeeds:(double)waterSpeed;

@end
