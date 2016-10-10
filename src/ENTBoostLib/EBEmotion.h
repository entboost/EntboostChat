//
//  EBEmotion.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-18.
//
//

///表情、头像资源描述信息
@interface EBEmotion : NSObject

@property(nonatomic) uint64_t resId; //资源ID
@property(nonatomic) uint64_t index; //顺序索引
@property(strong, nonatomic, readonly) NSString* dynamicFilepath; //文件保存路径, 在文件未下载完毕之前返回nil
@property(nonatomic, readonly) BOOL isLoaded; //文件是否已下载到本地

@property(nonatomic) uint64_t emoClass; //分类

///获取本实例的资源字符串
- (NSString*)resourceString;

///获取本实例的描述
- (NSString*)descri;

@end
