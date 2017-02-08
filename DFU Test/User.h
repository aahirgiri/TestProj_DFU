//
//  User.h
//  tag
//
//  Created by pbk on 29/11/14.
//  Copyright (c) 2014 Gida Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>
@property NSString *name,*email,*signInType,*signInUserId,*gidaUserId,*userToken,*iosId,*iosToken;
@property uint8_t deviceNum,loggedIn,enableCGPS,forceNetwork;
@property NSMutableArray *yokyList;
@property NSMutableArray *locations,*shareRequests;
+(instancetype)sharedUser;
+(void)nullifyUser;
-(void)save;
-(void)saveWithNetwork;
-(void)updateUser:(NSDictionary *)u;
-(void)getUserInfo:(NSDictionary *)u;
-(void)saveExtensionObject;
+ (NSDate*)parseDate:(NSString*)s format:(NSString*)f;
+ (NSString *)formatDate:(NSDate *)dt format:(NSString *)f;
@end
