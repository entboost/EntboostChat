//
//  SOTPErrorHelper.h
//  ENTBoostLib
//
//  Created by zhong zf on 14-6-20.
//
//

#import <Foundation/Foundation.h>

@interface SOTPErrorHelper : NSObject

/** 获取错误信息对象
 * @param code 错误代码
 * @param msg
 */
+ (NSError*)errorWithCode:(NSInteger)code message:(NSString*)msg;

@end
