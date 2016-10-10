//
//  SOTP_defines.h
//  SOTP
//
//  Created by zhong zf on 13-8-6.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#ifndef SOTP_SOTP_defines_h
#define SOTP_SOTP_defines_h

#import "eb_define1.h"

//seq 判断重复数组最大数
#define MAX_SEQ_MASKS_SIZE 768
//seq 判断重复数组最大数，用于音视频服务
#define MAX_AV_SEQ_MASKS_SIZE 1024

#endif

//基本类型转换为NSString对象
#define INT2STRING(val) [NSString stringWithFormat:@"%i", val]
#define LONG2STRING(val) [NSString stringWithFormat:@"%li", val]
#define ULONG2STRING(val) [NSString stringWithFormat:@"%lu", val]
#define LONGLONG2STRING(val) [NSString stringWithFormat:@"%lli", val]
#define ULONGLONG2STRING(val) [NSString stringWithFormat:@"%llu", val]
#define FLOAT2STRING(val) [NSString stringWithFormat:@"%f", val]
#define BOOL2STRING(val) [NSString stringWithFormat:@"%i", val?1:0]

#define CSTRING2STRING(val) [NSString stringWithFormat:@"%s", val]

//单个参数加入到参数集
#define SOTPPARAM(parameters, nameVal, typeVal, valueVal) [parameters setObject:[[SOTPParameter alloc] initWithName:nameVal type:typeVal value:valueVal] forKey:nameVal]
//#define SOTPPARAM_STREAM(parameters, nameVal, bytesVal, length) [parameters setObject:[[SOTPParameter alloc] initWithName:nameVal bytes:bytesVal byteLength:length] forKey:nameVal]

//生成线程安全的parameters dictionary 已废弃
//#define SOTPPARAM_MAKE_THREAD_SAFE(parameters) [NSDictionary dictionaryWithDictionary:parameters]
#define SOTPPARAM_MAKE_THREAD_SAFE(parameters) parameters

//判断参数变量是否存在
#define SOTPPARAM_EXISTS(parameters, nameVal) [parameters objectForKey:nameVal]?YES:NO

//按类型读取参数值
#define SOTPPARAM_GET_STR(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] stringValue]
#define SOTPPARAM_GET_BOOL(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] booleanValue]
#define SOTPPARAM_GET_INT(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] intValue]
#define SOTPPARAM_GET_ULONG(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] unsignedLongValue]
#define SOTPPARAM_GET_LONG(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] longValue]
#define SOTPPARAM_GET_ULONGLONG(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] unsignedLongLongValue]
#define SOTPPARAM_GET_LONGLONG(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] longLongValue]
#define SOTPPARAM_GET_FLOAT(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] floatValue]
#define SOTPPARAM_GET_DOUBLE(parameters, nameVal) [(SOTPParameter*)[parameters objectForKey:nameVal] doubleValue]

#define SOTPPARAM_GET_INT_DEFAULT(parameters, nameVal, defaultVal) [(SOTPParameter*)[parameters objectForKey:nameVal] integerValueWithDefault:defaultVal]

//生成一个NSError对象
#define EBERR(codeVal, messageVal) [SOTPErrorHelper errorWithCode:codeVal message:messageVal]

//消息分包最大长度
#define EB_SEND_MSG_PACK_LEN 1024

//音视频分包最大长度
#define EB_SEND_AV_PACK_LEN 1024

//时间格式化字符串
//#define DATE_TRANS_PATTENT @"yyyy-MM-dd HH:mm:ss.SSSSSS"

//服务端调用等待时间长 6秒
#define EB_WAIT_TIME_OUT dispatch_time(DISPATCH_TIME_NOW, 6.0f * NSEC_PER_SEC)
//CALL数据清理任务触发间隔时长(秒)
#define EB_CALL_TIMEOVER_CLEAR_TASK_TIME_INTERVAL 7.0
//RTP数据清理任务触发间隔时长(秒)
#define EB_RTP_EXPIRED_CLEAR_TASK_TIME_INTERVAL 10.0

////清理闲置UM连接任务触发间隔时长(秒)
//#define IDEL_USERMANAGER_CLEAR_TASK_TIME_INTERVAL 60.0
////业务闲置时长(秒)
//#define IDEL_TIME_USERMANAGER_CONNECTION 5*60

////用户内部状态
//typedef enum UserStatus
//{
//    US_Logonout
//    , US_DevAppIdLogoning
//    , US_Logoning
//    , US_LogonError
//    , US_OAuthForward
//    , US_Logoned
//    , US_Invalidate //-103使用
//    , US_OnlineAnother	// 在其他地方登录
//} UserStatus;

////SDK API调用返回状态
//typedef enum
//{
//    API_CALL_STATE_ERROR =-1,
//    API_CALL_STATE_SUCESS =0,
//    API_CALL_STATE_TIMEOUT =1,
//    
//} APICallState;

//会话状态
typedef enum EB_CALL_STATE
{
    EB_CALL_STATE_UNKNOWN,
    EB_CALL_STATE_INCOMING,
    EB_CALL_STATE_ALERTING,
    EB_CALL_STATE_CONNECTED,
    EB_CALL_STATE_INVALIDATE,//网络故障－103
    EB_CALL_STATE_EXIT,//上层关闭聊天界面
    EB_CALL_STATE_HANGUP,//本端或对方调用c_hangup挂断
    EB_CALL_STATE_ONLINE_INCALL,
    EB_CALL_STATE_AUTO_ACK //同群组呼叫，内部自动响应
} EB_CALL_STATE;

//本地缓存资料版本类型
typedef enum EB_CACHE_VERSION_INFO_TYPE
{
//    EB_CACHE_VERSION_INFO_TYPE_ENTERPRISE = 1, //企业自身资料版本
    EB_CACHE_VERSION_INFO_TYPE_ENTERPRISE_DEPARTMENT = 2, //企业部门自身资料版本
    EB_CACHE_VERSION_INFO_TYPE_PERSONAL_GROUP = 4, //个人群组自身资料版本
    EB_CACHE_VERSION_INFO_TYPE_CONTACT = 8, //个人联系人信息总版本
    
    EB_CACHE_VERSION_INFO_TYPE_EMOTION_CLASS_COUNT = 100 //表情、头像资源分类数量
} EB_CACHE_VERSION_INFO_TYPE;

//消息内容模块类型
typedef enum MSG_ITEM_TYPE
{
    MSG_ITEM_TYPE_TXT,
    MSG_ITEM_TYPE_JPG,
    MSG_ITEM_TYPE_RESOURCE
} MSG_ITEM_TYPE;

//talk类型
typedef enum EB_TALK_TYPE
{
    EB_TALK_TYPE_CHAT = 0,          //聊天
    EB_TALK_TYPE_SYS_NOTICE = 10,  //系统通知，例如加群、退群等一些通知
//    EB_TALK_TYPE_CALL_NOTICE,       //呼叫消息，与CALL相关的操作
    EB_TALK_TYPE_MY_MESSAGE = 100,  //我的消息，内嵌webapp
    EB_TALK_TYPE_BROADCAST_MESSAGE = 101,       //群发广播消息
    EB_TALK_TYPE_BROADCAST_MESSAGE_NEW_EMAIL,   //新邮件通知
    EB_TALK_TYPE_BROADCAST_MESSAGE_EMAIL_COUNT  //未读邮件通知
} EB_TALK_TYPE;

