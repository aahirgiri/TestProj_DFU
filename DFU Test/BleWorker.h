//
//  BleWorker.h
//  tag
//
//  Created by pbk on 16/12/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class YokyTag;

@interface BleWorker : NSObject
@property int type;//1:Read,2:Write
@property NSData *data;
@property CBUUID *characteristic;
@property CBPeripheral *peripheral;
@property YokyTag *tag;

-(id)initWithType:(int)type andData:(NSData *)data andPeripheral:(CBPeripheral *)peripheral andChar:(CBUUID *)characteristic andTag:(YokyTag *)tag;
-(BOOL)isPlaySoundForTag:(YokyTag *)yt;
-(BOOL)isStopSoundForTag:(YokyTag *)yt;
@end
