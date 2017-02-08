//
//  BleWorker.m
//  tag
//
//  Created by pbk on 16/12/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import "BleWorker.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "YokyTag.h"

@implementation BleWorker
-(id)initWithType:(int)type andData:(NSData *)data andPeripheral:(CBPeripheral *)peripheral andChar:(CBUUID *)characteristic andTag:(YokyTag *)tag{
    self=[super init];
    _type=type;_data=data;_peripheral=peripheral;_characteristic=characteristic;_tag=tag;
    return self;
}
-(BOOL)isPlaySoundForTag:(YokyTag *)yt{
    if(!yt||!yt.identifier||!_peripheral)return NO;if(_type!=2)return NO;
    if(![_characteristic isEqual:[CBUUID UUIDWithString:@"c4215556-3739-ffea-0a7d-802211f186b8"]])return NO;
    NSUUID *ti1=yt.identifier,*ti2=_peripheral.identifier;
    if(![ti1 isEqual:ti2])return NO;
    uint8_t cmd=0;[_data getBytes:&cmd range:NSMakeRange(0, 1)];if(cmd!=18)return NO;
    return YES;
}
-(BOOL)isStopSoundForTag:(YokyTag *)yt{
    if(!yt||!yt.identifier||!_peripheral)return NO;if(_type!=2)return NO;
    if(![_characteristic isEqual:[CBUUID UUIDWithString:@"c4215556-3739-ffea-0a7d-802211f186b8"]])return NO;
    NSUUID *ti1=yt.identifier,*ti2=_peripheral.identifier;
    if(![ti1 isEqual:ti2])return NO;
    uint8_t cmd=0;[_data getBytes:&cmd range:NSMakeRange(0, 1)];if(cmd!=12)return NO;
    return YES;
}
@end
