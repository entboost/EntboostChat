//
//  FileUtility.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-7-18.
//
//

@interface FileUtility : NSObject

///获取Home路径,沙盒根目录
+ (NSString*)homeDirectory;

/**获取Documents路径
 * 所有的应用程序数据文件写入到这个目录下
 * 这个目录用于存储用户数据或其它应该定期备份的信息
 */
+ (NSString*)documentDirectory;

/**获取Caches路径
 * 用于存放应用程序专用的支持文件
 * 保存应用程序再次启动过程中需要的信息
 */
+ (NSString*)cacheDirectory;

/**获取tmp路径
 * 这个目录用于存放临时文件
 * 保存应用程序再次启动过程中不需要的信息
 */
+ (NSString*)tmpDirectory;

//获取entboostChat的documen目录路径
+ (NSString*)ebChatDocumentDirectory;

//获取entboostChat的cache目录路径
+ (NSString*)ebChatCacheDirectory;

//获取entboostChat的log目录路径
+ (NSString*)ebChatLogDirectory;

/**生成接收文件的相对路径
 * @param fileName 文件名
 * @param floderName 目录名
 * @return 文件相对路径
 */
+ (NSString*)relativeFilePathWithFileName:(NSString*)fileName floderName:(NSString*)floderName;

/**判断文件是否已存在并可写操作
 * @param path 文件路径
 */
+ (BOOL)isWritableFileAtPath:(NSString*)path;

/**判断文件是否已存在并可读操作
 * @param path 文件路径
 */
+ (BOOL)isReadableFileAtPath:(NSString*)path;

/**判断文件是否已存在
 * @param path 文件路径
 */
+ (BOOL)fileExistAtPath:(NSString*)path;

/**搜索目录匹配一个子路径
 * @param pathName 目录名或文件名
 * @param dir 被搜索目录
 * @return 第一个匹配成功的子路径(包括目录和文件)，绝对路径
 */
+ (NSString*)absolutePathIncludingSubPath:(NSString*)subPath inDirectory:(NSString*)dir;

/**搜索子路径并返回匹配的子路径
 * @param dir 被搜索目录
 * @param pattern 匹配的字符串
 * @return 指定目录下所有匹配的子路径(包括目录或文件)，相对路径
 */
+ (NSArray*)searchSubPaths:(NSString*)dir pattern:(NSString*)pattern;

/**写入文件
 * @param path 文件路径
 * @param data 文件数据
 * @return 是否成功
 */
+ (BOOL)writeFileAtPath:(NSString*)path data:(NSData*)data;

/**创建文件目录
 * @param path 文件路径
 * @return 是否成功
 */
+ (BOOL)createDirectoryAtPath:(NSString*)path;

/**删除文件
 * @param path 文件路径
 * @return 是否成功
 */
+ (BOOL)deleteFileAtPath:(NSString*)path;

/**计算文件内容MD5码
 * @param path 文件路径
 * @return MD5码字符串
 */
+ (NSString*)md5AtPath:(NSString*)path;

/**计算字节数组MD5码
 * @param bytes 字符串数组
 * @param length 长度(字节)
 * @return MD5码字符串
 */
+ (NSString*)md5WithBytes:(const void*)bytes length:(NSUInteger)length;

/**判断指定的MD5与指定的文件MD5是否相等
 * @param md5 指定的MD5，如填入nil则返回NO
 * @param path 文件路径，如文件不存在或不可读则返回NO
 * @return MD5是否相等
 */
+ (BOOL)isEqualWithMD5:(NSString*)md5 atPath:(NSString*)path;

@end
