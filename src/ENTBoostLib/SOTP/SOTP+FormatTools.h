//
//  SOTP+Tools.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-6-14.
//
//

#import <Foundation/Foundation.h>

///NSString 类别Category
@interface NSString(FormatTools)

/// 转换为MD5十六进制字符串
- (NSString *)md5Hex;

/** 转换为NSDate对象
 * @param  formatStr 日期时间格式化字符串，如填入nil空值，则自动使用默认值 yyyy-MM-dd HH:mm:ss
 *
 * @return 返回NSDate对象
 */
- (NSDate *)dateWithFormat:(NSString*)formatStr;

///转换为长整数
- (long)longValue;

///转换为无符号长整数
- (unsigned long)unsignedLongValue;

/////转换为64位长整数
//- (int64_t)longLongValue;

///转换为64位无符号长整数
- (uint64_t)unsignedLongLongValue;

/////转换为浮点数
//- (float_t)floatValue;
//
/////转换为双精度浮点数
//- (double_t)doubleValue;

@end

///NSDate 类别Category
@interface NSDate (FormatTools)

/** 转换为NSString字符串对象
 * @param formatStr 日期时间格式化字符串，如填入nil空值，则自动使用默认值 yyyy-MM-dd HH:mm:ss
 *
 * @return 返回NSSring对象
 */
- (NSString *)stringWithformat:(NSString*)formatStr;

@end

/////NSDictionary 类别Category
//@interface NSDictionary (Tools)
//
///**从dictionary中获取SOTPParameter对象并解析为NSString对象
// * @param key dictionar中对象的key
// */
//- (NSString*)stringFromSOTPPForKey:(NSString*)key;
//
///**从dictionary中获取SOTPParameter对象并解析为int类型
// * @param key dictionar中对象的key
// */
//- (int)intFromSOTPPForKey:(NSString*)key;
//
///**从dictionary中获取SOTPParameter对象并解析为long类型
// * @param key dictionar中对象的key
// */
//- (long)longFromSOTPPForKey:(NSString*)key;
//
///**从dictionary中获取SOTPParameter对象并解析为double类型
// * @param key dictionar中对象的key
// */
//- (double_t)doubleFromSOTPPForKey:(NSString*)key;
//
//@end