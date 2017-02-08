//
//  YokyTag.h
//  tag
//
//  Created by pbk on 11/12/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
@class ShareObject;

@interface YokyTag : NSObject<NSCoding>
@property NSString *name,*addedOn,*llAddress,*llDate,*muteUntil;
@property NSString *timeStr,*distStr;
@property double llLat,llLng;
@property int tagId,mode,saveCfgFlag,rssi,rawRssi,status,softwareVersion,hardwareVersion,battery,disown,enableDisconnectAlert,useProxBeep,reconnectAlert,oneshotReconnectAlert,connectStatus;
@property int tagAlert,phoneAlert,tagAlertTone,alertDuration,alertVolume,tagSearchTone;
@property NSString *phoneAlertTone,*phoneSearchTone;
@property NSMutableArray *locationSettings;
@property NSMutableArray *sharedWith;
@property NSUUID *identifier;
@property CBPeripheral *peripheral;
@property ShareObject *sharedBy;
@property int cTagAlert,cPhoneAlert,cAlertVolume,cAlertDuration,isMuted;
@property NSDate *disconnected,*connected;
@property NSString *userToken;
@property NSDate *searchShown,*lastRssiUpdate;
@property UILocalNotification *ln;

-(id)initWithName:(NSString *)name andId:(int)tagId andAddedDate:(NSString *)dt andPeripheral:(CBPeripheral *)peripheral andUserToken:(NSString *)userToken;
-(NSMutableDictionary *)getDictionary;
+(id)initWithDictionary:(NSDictionary *)d;
-(void)doPostInitCheck;
@end
