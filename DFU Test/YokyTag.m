
//
//  YokyTag.m
//  tag
//
//  Created by pbk on 11/12/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import "YokyTag.h"
#import "User.h"

@implementation YokyTag
-(id)initWithName:(NSString *)name andId:(int)tagId andAddedDate:(NSString *)dt andPeripheral:(CBPeripheral *)peripheral andUserToken:(NSString *)userToken{
    if((self=[super init])){
        self.name=name&&name.length?name:@"Yoky";self.tagId=tagId;self.addedOn=dt;self.identifier=[peripheral identifier];self.peripheral=peripheral;self.userToken=userToken;
        _mode=0;_tagAlert=1;_phoneAlert=1;_alertDuration=0;_isMuted=0;_alertVolume=2;_useProxBeep=1;_reconnectAlert=0;
        if(_tagId==255){_softwareVersion=1;_hardwareVersion=1;_battery=100;}_llDate=@"";
        [self doPostInitCheck];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    _tagId=[aDecoder decodeIntForKey:@"tagId"];
    _name=[aDecoder decodeObjectForKey:@"name"];if(_name==nil||!_name.length)_name=@"Yoky";
    _addedOn=[aDecoder decodeObjectForKey:@"addedOn"];
    _userToken=[aDecoder decodeObjectForKey:@"userToken"];
    _llAddress=[aDecoder decodeObjectForKey:@"llAddress"];
    _llDate=[aDecoder decodeObjectForKey:@"llDate"];
    _llLat=[aDecoder decodeDoubleForKey:@"llLat"];
    _llLng=[aDecoder decodeDoubleForKey:@"llLng"];
    _mode=[aDecoder decodeIntForKey:@"mode"];
    _saveCfgFlag=[aDecoder decodeIntForKey:@"saveCfgFlag"];
    _identifier=[aDecoder decodeObjectForKey:@"identifier"];
    _locationSettings=[aDecoder decodeObjectForKey:@"locationSettings"];
    _tagAlert=[aDecoder decodeIntForKey:@"tagAlert"];
    _phoneAlert=[aDecoder decodeIntForKey:@"phoneAlert"];
    _isMuted=[aDecoder decodeIntForKey:@"isMuted"];
    _muteUntil=[aDecoder decodeObjectForKey:@"muteUntil"];
    _tagAlertTone=[aDecoder decodeIntForKey:@"tagAlertTone"];
    _alertDuration=[aDecoder decodeIntForKey:@"alertDuration"];
    _alertVolume=[aDecoder decodeIntForKey:@"alertVolume"];
    _phoneAlertTone=[aDecoder decodeObjectForKey:@"phoneAlertTone"];
    _phoneSearchTone=[aDecoder decodeObjectForKey:@"phoneSearchTone"];
    _tagSearchTone=[aDecoder decodeIntForKey:@"tagSearchTone"];
    _sharedBy=[aDecoder decodeObjectForKey:@"sharedBy"];
    _sharedWith=[aDecoder decodeObjectForKey:@"sharedWith"];
    _battery=[aDecoder decodeIntForKey:@"battery"];
    _softwareVersion=[aDecoder decodeIntForKey:@"softwareVersion"];
    _hardwareVersion=[aDecoder decodeIntForKey:@"hardwareVersion"];
    _useProxBeep=[aDecoder decodeIntForKey:@"useProxBeep"];if(!_useProxBeep)_useProxBeep=1;
    _reconnectAlert=[aDecoder decodeIntForKey:@"reconnectAlert"];
    [self doPostInitCheck];return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_tagId forKey:@"tagId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_addedOn forKey:@"addedOn"];
    [aCoder encodeObject:_userToken forKey:@"userToken"];
    [aCoder encodeObject:_llAddress forKey:@"llAddress"];
    if(_llDate)[aCoder encodeObject:_llDate forKey:@"llDate"];
    [aCoder encodeDouble:_llLat forKey:@"llLat"];
    [aCoder encodeDouble:_llLng forKey:@"llLng"];
    [aCoder encodeInt:_mode forKey:@"mode"];
    [aCoder encodeInt:_saveCfgFlag forKey:@"saveCfgFlag"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_locationSettings forKey:@"locationSettings"];
    [aCoder encodeInt:_tagAlert forKey:@"tagAlert"];
    [aCoder encodeInt:_phoneAlert forKey:@"phoneAlert"];
    [aCoder encodeInt:_isMuted forKey:@"isMuted"];
    [aCoder encodeObject:_muteUntil forKey:@"muteUntil"];
    [aCoder encodeInt:_tagAlertTone forKey:@"tagAlertTone"];
    [aCoder encodeInt:_alertDuration forKey:@"alertDuration"];
    [aCoder encodeInt:_alertVolume forKey:@"alertVolume"];
    [aCoder encodeObject:_phoneAlertTone forKey:@"phoneAlertTone"];
    [aCoder encodeObject:_phoneSearchTone forKey:@"phoneSearchTone"];
    [aCoder encodeInt:_tagSearchTone forKey:@"tagSearchTone"];
    [aCoder encodeObject:_sharedBy forKey:@"sharedBy"];
    [aCoder encodeObject:_sharedWith forKey:@"sharedWith"];
    [aCoder encodeInt:_battery forKey:@"battery"];
    [aCoder encodeInt:_softwareVersion forKey:@"softwareVersion"];
    [aCoder encodeInt:_hardwareVersion forKey:@"hardwareVersion"];
    [aCoder encodeInt:_useProxBeep forKey:@"useProxBeep"];
    [aCoder encodeInt:_reconnectAlert forKey:@"reconnectAlert"];
}
-(NSMutableDictionary *)getDictionary{
    NSMutableDictionary *d=[[NSMutableDictionary alloc] init];
    [d setObject:[NSNumber numberWithInt:_tagId] forKey:@"tagId"];
    if(_name)[d setObject:_name forKey:@"name"];
    if(_addedOn)[d setObject:_addedOn forKey:@"addedOn"];
    if(_userToken)[d setObject:_userToken forKey:@"userToken"];
    if(_llDate)[d setObject:_llDate forKey:@"llDate"];
    [d setObject:[NSNumber numberWithInt:_mode] forKey:@"mode"];
    [d setObject:[NSNumber numberWithInt:_saveCfgFlag] forKey:@"saveCfgFlag"];
    if(_identifier)[d setObject:[_identifier UUIDString] forKey:@"identifier"];
    [d setObject:[NSNumber numberWithInt:_tagAlert] forKey:@"tagAlert"];
    [d setObject:[NSNumber numberWithInt:_phoneAlert] forKey:@"phoneAlert"];
    [d setObject:[NSNumber numberWithInt:_isMuted] forKey:@"isMuted"];
    if(_muteUntil)[d setObject:_muteUntil forKey:@"muteUntil"];
    [d setObject:[NSNumber numberWithInt:_tagAlertTone] forKey:@"tagAlertTone"];
    [d setObject:[NSNumber numberWithInt:_alertDuration] forKey:@"alertDuration"];
    [d setObject:[NSNumber numberWithInt:_alertVolume] forKey:@"alertVolume"];
    [d setObject:_phoneAlertTone forKey:@"phoneAlertTone"];
    [d setObject:_phoneSearchTone forKey:@"phoneSearchTone"];
    [d setObject:[NSNumber numberWithInt:_tagSearchTone] forKey:@"tagSearchTone"];
    if(_sharedWith.count)[d setObject:_sharedWith forKey:@"sharedWith"];
    [d setObject:[NSNumber numberWithInt:_battery] forKey:@"battery"];
    [d setObject:[NSNumber numberWithInt:_softwareVersion] forKey:@"softwareVersion"];
    [d setObject:[NSNumber numberWithInt:_hardwareVersion] forKey:@"hardwareVersion"];
    [d setObject:[NSNumber numberWithInt:_useProxBeep] forKey:@"useProxBeep"];
    [d setObject:[NSNumber numberWithInt:_reconnectAlert] forKey:@"reconnectAlert"];
    return d;
}
+(id)initWithDictionary:(NSDictionary *)d{
    if(!d)return nil;YokyTag *yt=[[YokyTag alloc] init];
    NSString *s=[d objectForKey:@"tagId"];
    yt.tagId=[s intValue];
    yt.name=[d objectForKey:@"name"];if(yt.name==nil||!yt.name.length)yt.name=@"Yoky";
    yt.status=0;yt.addedOn=[d objectForKey:@"addedOn"];
    yt.userToken=[d objectForKey:@"userToken"];
    yt.llDate=[d objectForKey:@"llDate"];
    yt.mode=[[d objectForKey:@"mode"] intValue];
    yt.saveCfgFlag=(int)[d objectForKey:@"saveCfgFlag"];
    yt.identifier=[[NSUUID alloc] initWithUUIDString:[d objectForKey:@"identifier"]];
    yt.tagAlert=[[d objectForKey:@"tagAlert"] intValue];
    yt.phoneAlert=[[d objectForKey:@"phoneAlert"] intValue];
    yt.isMuted=[[d objectForKey:@"isMuted"] intValue];
    yt.muteUntil=[d objectForKey:@"muteUntil"];
    yt.tagAlertTone=[[d objectForKey:@"tagAlertTone"] intValue];
    yt.alertDuration=[[d objectForKey:@"alertDuration"] intValue];
    yt.alertVolume=[[d objectForKey:@"alertVolume"] intValue];
    yt.phoneAlertTone=[d objectForKey:@"phoneAlertTone"];
    yt.phoneSearchTone=[d objectForKey:@"phoneSearchTone"];
    yt.tagSearchTone=[[d objectForKey:@"tagSearchTone"] intValue];
    yt.sharedWith=[d objectForKey:@"sharedWith"];
    yt.battery=[[d objectForKey:@"battery"] intValue];
    yt.softwareVersion=[[d objectForKey:@"softwareVersion"] intValue];
    yt.hardwareVersion=[[d objectForKey:@"hardwareVersion"] intValue];
    yt.useProxBeep=[[d objectForKey:@"useProxBeep"] intValue];if(!yt.useProxBeep)yt.useProxBeep=1;
    yt.reconnectAlert=[[d objectForKey:@"reconnectAlert"] intValue];
    [yt doPostInitCheck];return yt;
}
-(void)doPostInitCheck{
    _status=0;_timeStr=@"";_distStr=@"";
    if(!_alertDuration){
        _alertDuration=10;_tagAlert=1;_phoneAlert=1;_tagAlertTone=2;_tagSearchTone=5;
        _phoneSearchTone=@"bright";_phoneAlertTone=@"sunlight";
    }
    if(_locationSettings==nil)_locationSettings=[NSMutableArray new];
    if(_sharedWith==nil)_sharedWith=[NSMutableArray new];
    _cTagAlert=_tagAlert;_cPhoneAlert=_phoneAlert;_cAlertDuration=_alertDuration;_cAlertVolume=_alertVolume;
}
@end
