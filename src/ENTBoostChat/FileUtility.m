//
//  FileUtility.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-7-18.
//
//

#import <CommonCrypto/CommonDigest.h>
#import "FileUtility.h"

#define kEBFileHashDefaultChunkSizeForReadingData 1024*8

/**计算字节数组MD5码
 * @param bytes字节数组
 * @param byteSize 长度(字节)
 * @param chunkSizeForReadingData 文件每次读取块大小
 * @return md5码字符串
 */
CFStringRef md5HashCreateWithBytes(const void* bytes, size_t byteSize, size_t chunkSizeForReadingData) {
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = kEBFileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    for (int inx=0; inx<byteSize;) {
        int pageSize = (int)chunkSizeForReadingData;
        //末端判断
        if (inx+chunkSizeForReadingData > byteSize)
            pageSize = (int)byteSize-inx;
            
//        uint8_t buffer[pageSize];
//        memcpy(buffer, bytes+inx, pageSize);
//        
//        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)pageSize);
        CC_MD5_Update(&hashObject, bytes+inx, (CC_LONG)pageSize);
        
        inx+=pageSize;
    }
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    
    return CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
}

/**计算文件内容MD5码
 * @param filePath 文件绝对路径
 * @param chunkSizeForReadingData 文件每次读取块大小
 * @return md5码字符串
 */
CFStringRef md5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = kEBFileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


@implementation FileUtility

+ (NSString*)homeDirectory
{
    return NSHomeDirectory();
}

+ (NSString*)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString*)cacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString*)tmpDirectory
{
    return NSTemporaryDirectory();
}

+ (NSString*)ebChatDocumentDirectory
{
    return [[NSString alloc] initWithFormat:@"%@/entboostchat", [FileUtility documentDirectory]];
}

+ (NSString*)ebChatCacheDirectory
{
    return [[NSString alloc] initWithFormat:@"%@/entboostchat", [FileUtility cacheDirectory]];
}

+ (NSString*)ebChatLogDirectory
{
    return [[NSString alloc] initWithFormat:@"%@/logs", [FileUtility ebChatDocumentDirectory]];
}

+ (NSString*)relativeFilePathWithFileName:(NSString*)fileName floderName:(NSString*)floderName
{
    NSString* documentFolderName = [[FileUtility documentDirectory] lastPathComponent];
    return [[NSString alloc] initWithFormat:@"/%@/entboostchat/files/%@/%@", documentFolderName, floderName, fileName];
}

+ (NSString*)absolutePathIncludingSubPath:(NSString*)subPath inDirectory:(NSString*)dir
{
    NSArray* arry = [self searchSubPaths:dir pattern:subPath];
    if (arry.count)
        return [NSString stringWithFormat:@"%@/%@", dir, arry[0]];
    
    return nil;
}

+ (NSArray*)searchSubPaths:(NSString*)dir pattern:(NSString*)pattern
{
    NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:dir]; //获取所有子路径
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@", @"lastPathComponent", pattern]; //创建NSPredicate
    return [subPaths filteredArrayUsingPredicate:predicate]; //筛选并返回结果
}

+ (BOOL)isWritableFileAtPath:(NSString*)path
{
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

+ (BOOL)isReadableFileAtPath:(NSString*)path
{
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}

+ (BOOL)fileExistAtPath:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)writeFileAtPath:(NSString*)path data:(NSData*)data
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //获取文件目录，如不存在就创建
    NSString* dirPath = [path stringByDeletingLastPathComponent];
    if(![fileManager fileExistsAtPath:dirPath]) {
        NSLog(@"try to create directory = %@", dirPath);
        NSError* pError;
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&pError];
        if(pError) {
            NSLog(@"create directory = %@ error, code = %li, msg = %@", dirPath, (long)pError.code, pError.localizedDescription);
            return NO;
        }
    }
    
    //写入文件
    return [fileManager createFileAtPath:path contents:data attributes:nil];
}

+ (BOOL)createDirectoryAtPath:(NSString*)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (!isExist) {
        NSLog(@"try to create directory = %@", path);
        NSError* pError;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&pError];
        if(pError) {
            NSLog(@"create directory = %@ error, code = %li, msg = %@", path, (long)pError.code, pError.localizedDescription);
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)deleteFileAtPath:(NSString*)path {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    @synchronized(self) {
        NSError* error;
        BOOL result = [fileManager removeItemAtPath:path error:&error];
        if (error)
            NSLog(@"remove file at path = %@ error, code = %li, msg = %@", path, (long)error.code, error.localizedDescription);
        return result;
    }
}

+ (NSString*)md5AtPath:(NSString*)path
{
    return (__bridge_transfer NSString *)md5HashCreateWithPath((__bridge CFStringRef)path, kEBFileHashDefaultChunkSizeForReadingData);
}

+ (NSString*)md5WithBytes:(const void*)bytes length:(NSUInteger)length
{
    return (__bridge_transfer NSString *)md5HashCreateWithBytes(bytes, length, kEBFileHashDefaultChunkSizeForReadingData);
}

+ (BOOL)isEqualWithMD5:(NSString*)md5 atPath:(NSString*)path
{
    if (!md5) {
        NSLog(@"md5 is nil");
        return NO;
    }
    
    if (![self isReadableFileAtPath:path]) {
        NSLog(@"file not found at path:%@", path);
        return NO;
    }
    
    NSString* localMD5 = [self md5AtPath:path];
    if (localMD5 && [localMD5 isEqualToString:md5]) {
        return YES;
    }
    
    return NO;
}

@end
