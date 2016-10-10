//
//  EBFileUtility.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-18.
//
//

@interface SOTPFileUtility : NSObject

///获取Home路径,沙盒根目录
+ (NSString*)homeDirectory;

/**获取Documents路径
 * 所有的应用程序数据文件写入到这个目录下
 * 这个目录用于存储用户数据或其它应该定期备份的信息
 */
+ (NSString*)documentDirectory;

///**获取Caches路径
// * 用于存放应用程序专用的支持文件
// * 保存应用程序再次启动过程中需要的信息
// */
//+ (NSString*)cacheDirectory;

/**获取tmp路径
 * 这个目录用于存放临时文件
 * 保存应用程序再次启动过程中不需要的信息
 */
+ (NSString*)tmpDirectory;

//获取entboost的documen目录路径
+ (NSString*)entboostDocumentDirectory;

////获取entboost的cache目录路径
//+ (NSString*)entboostCacheDirectory;

///记录域名与IP映射的文件路径
+ (NSString*)domainMapFilePath;

/**生成接收文件的相对路径
 * @param fileName 文件名
 * @return 文件相对路径
 */
+ (NSString*)relativeFilePathWithFileName:(NSString*)fileName;

/**生成资源文件名(不包括路径)
 * @param resId 资源ID
 * @param extend 文件扩展名
 * @return 文件名
 */
+ (NSString*)resourceFileNameWithResId:(uint64_t)resId extend:(NSString*)extend;

///获取存储资源的根路径(绝对路径)
+ (NSString*)resourceDirectory;

///获取存储资源的根路径(相对路径)
+ (NSString*)relativeResourceDirectory;

/**计算相对路径
 * @param absoluteFilePath 绝对路径
 * @param rootPath 根路径
 * @return 计算得到的相对路径
 */
+ (NSString*)calculateRelativePathWithAbsolurePath:(NSString*)absoluteFilePath inRootPath:(NSString*)rootPath;

/**生成缓存资源文件绝对路径
 * @param resId 资源ID
 * @param extend 文件扩展名
 * @return 文件绝对路径
 */
+ (NSString*)absoluteResourcePathWithResId:(uint64_t)resId extend:(NSString*)extend;

/**生成缓存资源文件相对路径
 * @param resId 资源ID
 * @param extend 文件扩展名
 * @return 文件相对路径
 */
+ (NSString*)relativeResourcePathWithResId:(uint64_t)resId extend:(NSString*)extend;

/**判断文件是否已存在并可写操作
 * @param path 文件路径
 */
+ (BOOL)isWritableFileAtPath:(NSString*)path;

/**判断文件是否已存在并可读操作
 * @param path 文件路径
 */
+ (BOOL)isReadableFileAtPath:(NSString*)path;

/**判断文件是否存在
 * @param path 文件路径
 */
+ (BOOL)fileExistsAtPath:(NSString*)path;

/**以写操作的方式打开一个文件,如果文件不存在，则自动创建
 * @param path 文件路径
 * @return 文件句柄，外部应该用完以后负责关闭
 */
+ (NSFileHandle*)fileHandleForWritingAtPath:(NSString*)path;

/**以读操作的方式打开一个文件
 * @param path 文件路径
 * @return 文件句柄，如果非文件或文件不存在返回nil，外部应该用完以后负责关闭
 */
+ (NSFileHandle*)fileHandleForReadingAtPath:(NSString*)path;

/**搜索目录匹配一个子路径
 * @param pathName 目录名或文件名
 * @param dir 被搜索目录
 * @return 第一个匹配成功的子路径(包括目录和文件)，绝对路径
 */
+ (NSString*)pathWithPathName:(NSString*)pathName inDirectory:(NSString*)dir;

/**搜索子路径并返回匹配的子路径
 * @param dir 被搜索目录
 * @param pattern 匹配的字符串
 * @return 指定目录下所有匹配的子路径(包括目录或文件)，相对路径
 */
+ (NSArray*)searchSubPaths:(NSString*)dir pattern:(NSString*)pattern;

/**获取文件大小
 * @param path 文件路径
 * @return 文件大小(字节数)
 */
+ (uint64_t)fileSizeAtPath:(NSString*)path;

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

/**移动文件
 * @param filePath 源文件路径
 * @param filePath2 目标路径
 * @return 是否成功
 */
+ (BOOL)moveFileAtPath:(NSString*)filePath toPath:(NSString*)filePath2;

/**计算文件内容MD5码
 * @param path 文件路径
 * @return MD5
 */
+ (NSString*)md5AtPath:(NSString*)path;

/**判断指定的MD5与指定的文件MD5是否相等
 * @param md5 指定的MD5，如填入nil则返回NO
 * @param path 文件路径，如文件不存在或不可读则返回NO
 * @return MD5是否相等
 */
+ (BOOL)isEqualWithMD5:(NSString*)md5 atPath:(NSString*)path;

@end
