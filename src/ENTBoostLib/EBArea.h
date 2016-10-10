//
//  EBArea.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/10/23.
//  Copyright © 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

//地区
@interface EBArea : NSObject <NSCopying>

@property(nonatomic) uint64_t field0;   //国家代码
@property(nonatomic) uint64_t field1;   //省份代码
@property(nonatomic) uint64_t field2;   //城市代码
@property(nonatomic) uint64_t field3;   //县级或区代码

@property(nonatomic, strong) NSString* strField0;   //国家名称
@property(nonatomic, strong) NSString* strField1;   //省份名称
@property(nonatomic, strong) NSString* strField2;   //城市名称
@property(nonatomic, strong) NSString* strField3;   //县级或区代码

/**使用l_logon用户登录成功返回的dictionary进行初始化
 * @param dict
 */
- (id)initWithDictionary:(NSDictionary*)dict;

@end


//地区字段
@interface EBAreaField : NSObject

@property(nonatomic) uint64_t aId;              //地区编号
@property(nonatomic, strong) NSString* name;    //地区名称
@property(nonatomic) uint64_t parentId;         //上级地区编号
@property(nonatomic, strong) NSString* code;    //电话区号


- (id)initWithId:(uint64_t)aId name:(NSString*)name parentId:(uint64_t)parentId code:(NSString*)code;


@end