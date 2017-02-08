//
//  User.m
//  tag
//
//  Created by pbk on 29/11/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import "User.h"
#import "YokyTag.h"
#import "AppDelegate.h"


@implementation User
-(id)init{
    self=[super init];
    _yokyList=[NSMutableArray new];_locations=[NSMutableArray new];_enableCGPS=0;
    return self;
}
+(instancetype)sharedUser{
    static id sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[self loadInstance];
    });
    return sharedInstance;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_signInType forKey:@"signInType"];
    [aCoder encodeObject:_signInUserId forKey:@"signInUserId"];
    [aCoder encodeObject:_iosId forKey:@"iosId"];
    [aCoder encodeObject:_userToken forKey:@"userToken"];
    [aCoder encodeObject:_gidaUserId forKey:@"gidaUserId"];
    [aCoder encodeInt:_deviceNum forKey:@"deviceNum"];
    [aCoder encodeInt:_loggedIn forKey:@"loggedIn"];
    [aCoder encodeObject:_yokyList forKey:@"yokyList"];
    [aCoder encodeObject:_iosToken forKey:@"iosToken"];
    [aCoder encodeObject:_locations forKey:@"locations"];
    [aCoder encodeObject:_shareRequests forKey:@"shareRequests"];
    [aCoder encodeObject:[NSNumber numberWithInt:_enableCGPS] forKey:@"enableCGPS"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        _name=[aDecoder decodeObjectForKey:@"name"];
        _email=[aDecoder decodeObjectForKey:@"email"];
        _signInType=[aDecoder decodeObjectForKey:@"signInType"];
        _signInUserId=[aDecoder decodeObjectForKey:@"signInUserId"];
        _iosId=[aDecoder decodeObjectForKey:@"iosId"];
        _userToken=[aDecoder decodeObjectForKey:@"userToken"];
        _gidaUserId=[aDecoder decodeObjectForKey:@"gidaUserId"];
        _deviceNum=[aDecoder decodeIntForKey:@"deviceNum"];
        _loggedIn=[aDecoder decodeIntForKey:@"loggedIn"];
        _iosToken=[aDecoder decodeObjectForKey:@"iosToken"];
        _yokyList=[aDecoder decodeObjectForKey:@"yokyList"];
        _locations=[aDecoder decodeObjectForKey:@"locations"];
        _shareRequests=[aDecoder decodeObjectForKey:@"shareRequests"];
        if(_yokyList==nil)_yokyList=[[NSMutableArray alloc] init];
        if(_locations==nil)_locations=[NSMutableArray new];
        if(_shareRequests==nil)_shareRequests=[NSMutableArray new];
        _enableCGPS=[[aDecoder decodeObjectForKey:@"enableCGPS"] intValue];
    }
    return self;
}
+(NSString*)filePath{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"user"];
    }
    return filePath;
}
+(instancetype)loadInstance{
    NSData* decodedData = [NSData dataWithContentsOfFile: [User filePath]];
    if (decodedData) {
        User* user = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];return user;
    }
    return [[User alloc] init];
}
-(void)save{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
        [encodedData writeToFile:[User filePath] atomically:YES];
        [self saveExtensionObject];
        NSUserDefaults *ud=[[NSUserDefaults alloc] initWithSuiteName:@"group.io.yoky.tag"];
        NSString *s=[ud objectForKey:@"lastSaveTime"];
        if(s&&s.length>0&&!_forceNetwork){
            NSDate *dt=[User parseDate:s format:@"yyyy-MM-dd HH:mm:ss"];
            if(!dt||[[NSDate new] timeIntervalSinceDate:dt]<24*3600)return;
        }
        [self saveWithNetwork];
    });
}
+(void)nullifyUser{
    User *u=[[User alloc] init];
    NSData *encodedData=[NSKeyedArchiver archivedDataWithRootObject: u];
    [encodedData writeToFile:[User filePath] atomically:YES];
}
-(void)updateUser:(NSDictionary *)u{
    _gidaUserId=[u objectForKey:@"gidaUserId"];_signInType=[u objectForKey:@"signInType"];_signInUserId=[u objectForKey:@"signInUserId"];
    _userToken=[u objectForKey:@"userToken"];_name=[u objectForKey:@"name"];
    _email=[u objectForKey:@"email"];_loggedIn=2;
    if([u objectForKey:@"yokyList"]){
        _yokyList=[NSMutableArray new];NSMutableArray *arr=(NSMutableArray *)[u objectForKey:@"yokyList"];
        for(int i=0;i<arr.count;i++) {
            NSMutableDictionary *y=arr[i];
            YokyTag *yt=[YokyTag initWithDictionary:y];
            if(yt)[_yokyList addObject:yt];
        }
    }
    _locations=[NSMutableArray new];
    if([u objectForKey:@"shareRequests"]){
        NSMutableArray *shareArr=(NSMutableArray *)[u objectForKey:@"shareRequests"];_shareRequests=[NSMutableArray new];
        for(NSMutableDictionary *sod in shareArr){
           // ShareObject *so=[ShareObject initWithDictionary:sod];if(so)[_shareRequests addObject:so];
        }
    }else _shareRequests=[NSMutableArray new];
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[User filePath] atomically:YES];
    
    _enableCGPS=[u objectForKey:@"enableCGPS"]?[[u objectForKey:@"enableCGPS"] intValue]:0;
}
-(void)getUserInfo:(NSDictionary *)u{
    if(u==nil)return;NSMutableDictionary *mapData=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getUserInfo",@"fun",[u objectForKey:@"gidaUserId"],@"gidaUserId",[u objectForKey:@"userToken"],@"userToken", nil];
    
}
-(void)saveExtensionObject{
    NSUserDefaults *ud=[[NSUserDefaults alloc] initWithSuiteName:@"group.io.yoky.tag"];
    if(_loggedIn&&_yokyList&&_yokyList.count){
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        for(int i=0;i<_yokyList.count;i++){
            YokyTag *yt=_yokyList[i];NSMutableDictionary *d=[NSMutableDictionary new];
            [d setObject:[NSNumber numberWithInt:yt.tagId] forKey:@"tagId"];
            [d setObject:yt.userToken forKey:@"userToken"];
            [d setObject:[NSNumber numberWithInt:yt.status] forKey:@"status"];
            if(yt.llAddress)[d setObject:yt.llAddress forKey:@"llAddress"];
            if(yt.llDate)[d setObject:yt.llDate forKey:@"llDate"];
            if(yt.distStr)[d setObject:yt.distStr forKey:@"distStr"];
            [d setObject:yt.name?yt.name:@"Yoky" forKey:@"name"];
            [arr addObject:d];
        }
        [ud setObject:arr forKey:@"yokyList"];
    }
    else [ud removeObjectForKey:@"yokyList"];
}
+(NSDate *)parseDate:(NSString *)s format:(NSString *)f{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale systemLocale]];
    [df setDateFormat:f];
    return [df dateFromString:s];
}
+(NSString *)formatDate:(NSDate *)dt format:(NSString *)f{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale systemLocale]];
    [df setDateFormat:f];
    return [df stringFromDate:dt];
}
@end
