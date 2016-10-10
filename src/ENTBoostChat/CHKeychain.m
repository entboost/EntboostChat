//
//  CHKeychain.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-5.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "CHKeychain.h"
#import "UserNamePassword.h"

//#define KEY_USERNAME_PASSWORD  @"com.entboost.chat.usernamepassword"
#define KEY_USERNAME @"com.entboost.chat.username"
#define KEY_PASSWORD @"com.entboost.chat.password"
#define KEY_USERNAMES_PASSWORDS @"com.entboost.chat.usernamespasswords"

@implementation CHKeychain

//+ (void)saveUserName:(NSString*)userName AndPassword:(NSString*)password
//{
//    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
//    
//    if (userName)
//        [usernamepasswordKVPairs setObject:userName forKey:KEY_USERNAME];
//    
//    if (password)
//        [usernamepasswordKVPairs setObject:password forKey:KEY_PASSWORD];
//        
//    [CHKeychain save:KEY_USERNAME_PASSWORD data:usernamepasswordKVPairs];
//}

+ (void)saveUserName:(NSString*)userName AndPassword:(NSString*)password
{
    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[CHKeychain load:KEY_USERNAMES_PASSWORDS];
    if (!usernamepasswordKVPairs)
        usernamepasswordKVPairs = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    if (userName && userName.length>0) {
//        NSObject* passwordObj = password;
//        if (!password)
//            passwordObj = [NSNull null];
        
        [usernamepasswordKVPairs setObject:[[UserNamePassword alloc] initWithUserName:userName password:password updatedDate:[NSDate date]] forKey:userName];
        [CHKeychain save:KEY_USERNAMES_PASSWORDS data:usernamepasswordKVPairs];
    }
}

//+ (void)removePassword
//{
//    [self saveUserName:[self userName] AndPassword:nil];
//}

+ (void)removeUserName:(NSString*)userName
{
    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[CHKeychain load:KEY_USERNAMES_PASSWORDS];
    [usernamepasswordKVPairs removeObjectForKey:userName];
    
    [CHKeychain save:KEY_USERNAMES_PASSWORDS data:usernamepasswordKVPairs];
}

+ (UserNamePassword*)lastUserNamePassword
{
    NSArray* sortedArry = [self userNamePasswords];
    
    if (sortedArry.count>0) {
        return sortedArry[0];
    } else
        return nil;
}

+ (NSArray*)userNamePasswords
{
    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[CHKeychain load:KEY_USERNAMES_PASSWORDS];
    //去除空值行
    [usernamepasswordKVPairs enumerateKeysAndObjectsUsingBlock:^(NSString* key, UserNamePassword* up, BOOL* stop) {
        if ([key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0)
            [usernamepasswordKVPairs removeObjectForKey:key];
    }];
    
    //按先部门后成员排序
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate * d1 = obj1;
        NSDate * d2 = obj2;
        return [d1 compare:d2];
    }];
    NSArray* sortedArry = [[usernamepasswordKVPairs allValues] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return sortedArry;
}

//+ (NSString*)password
//{
//    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[CHKeychain load:KEY_USERNAME_PASSWORD];
//    return [usernamepasswordKVPairs objectForKey:KEY_PASSWORD];
//}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)del:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end
