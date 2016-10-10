//
//  SOTPRSAUtility.h
//  ENTBoostLib
//
//  Created by zhong zf on 13-8-8.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GenerateSuccessBlock)(void);

@interface SOTPRSAUtility : NSObject{
@private
    NSData * publicTag;
	NSData * privateTag;
//    NSOperationQueue * cryptoQueue;
//    GenerateSuccessBlock success;
}

@property (nonatomic,readonly) SecKeyRef publicKeyRef;
@property (nonatomic,readonly) SecKeyRef privateKeyRef;
@property (nonatomic,readonly) NSData   *publicKeyBits;
@property (nonatomic,readonly) NSData   *privateKeyBits;


+ (id)shareInstance;

///**产生一对RAS密钥
// * @param completionBlock 完成后回调
// */
//- (void)generateKeyPairRSACompleteBlock:(GenerateSuccessBlock)completionBlock;

- (NSData *)RSA_EncryptUsingPublicKeyWithData:(NSData *)data;
- (NSData *)RSA_EncryptUsingPrivateKeyWithData:(NSData*)data;
- (NSData *)RSA_DecryptUsingPublicKeyWithData:(NSData *)data;
- (NSData *)RSA_DecryptUsingPrivateKeyWithData:(NSData*)data;

@end
