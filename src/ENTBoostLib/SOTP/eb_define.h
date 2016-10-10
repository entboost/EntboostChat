// eb_define.h file here
#ifndef __eb_define_h__
#define __eb_define_h__
#ifdef WIN32
#include "Windows.h"
#endif // WIN32

#ifndef min
#define min(a, b)  (((a) < (b)) ? (a) : (b))
#endif // min

/*==========================================================
 系统设置定义
 ===========================================================*/
typedef enum SYSTEM_SETTING_VALUE
{
    SYSTEM_SETTING_VALUE_AUTH_CONTACT           = 0x1 //添加联系人模式：与运算(&)等于YES表示好友模式(需验证)，等于NO表示普通联系人模式(免验证)
    ,SYSTEM_SETTING_VALUE_AUTH_INVITEADD2GROUP  = 0X2 //邀请进入群组是否需要对方验证通过
    ,SYSTEM_SETTING_VALUE_SEND_REG_MAIL         = 0X4
    ,SYSTEM_SETTING_VALUE_AUTOHIDE_MAINFRAME_PC = 0X8
    ,SYSTEM_SETTING_VALUE_HIDE_MAINFRAME_PC     = 0x10
    
} SYSTEM_SETTING_VALUE;

/*==========================================================
 资源类型
 ===========================================================*/
typedef enum EB_RESOURCE_TYPE
{
	EB_RESOURCE_UNKNOWN
	, EB_RESOURCE_NOTE				// 文本笔记
	, EB_RESOURCE_MSG				// 消息资源 rich&image need cm
	, EB_RESOURCE_HEAD				// 头像资源 need cm
	, EB_RESOURCE_DIR				// 目录资源
	, EB_RESOURCE_FILE				// 文件资源 need cm
    , EB_RESOURCE_EMOTION           // 表情资源 need cm
} EB_RESOURCE_TYPE;

/*==========================================================
 视频类型
 ===========================================================*/
typedef enum EB_VIDEO_TYPE
{
	EB_VIDEO_UNKNOWN	= 0				// 未知
	, EB_VIDEO_AUDIO	= 1				// 语音
	, EB_VIDEO_BOTH		= 2				// 语音&视频
} EB_VIDEO_TYPE;

/*==========================================================
 性别
 ===========================================================*/
typedef enum EB_GENDER_TYPE
{
	EB_GENDER_UNKNOWN
	, EB_GENDER_MALE				// 男性
	, EB_GENDER_FEMALE				// 女性
} EB_GENDER_TYPE;

/*==========================================================
 群组类型
 ===========================================================*/
typedef enum EB_GROUP_TYPE
{
	EB_GROUP_TYPE_DEPARTMENT		// 企业部门 （由公司人员设定，不能随意添加用户，或退出）
	, EB_GROUP_TYPE_PROJECT			// 项目组 （同上）
	, EB_GROUP_TYPE_GROUP			// 固定群组 （所有人可以创建，管理员随时添加成员，或退出）
	, EB_GROUP_TYPE_TEMP = 9		// 临时讨论组 （由聊天成员动态创建，所有人随时添加成员，或退出）
} EB_GROUP_TYPE;

/*==========================================================
 在线状态
 ===========================================================*/
typedef enum EB_USER_LINE_STATE
{
	EB_LINE_STATE_UNKNOWN       = 0
//    , EB_LINE_STATE_ONLINE_OLD  = 1 //在线(废弃)
	, EB_LINE_STATE_OFFLINE     = 2	// 离线
	, EB_LINE_STATE_BUSY            // 忙
	, EB_LINE_STATE_AWAY            // 离开
    , EB_LINE_STATE_ONLINE          // 在线
	, EB_USER_CHANGE_STATE		= 0x100
} EB_USER_LINE_STATE;

/*==========================================================
 状态码
 ===========================================================*/
typedef enum EB_STATE_CODE
{
    EB_STATE_INVALID_SESSION            = -103 //SOTP会话无效
    ,EB_STATE_NOT_CONNECT                = -100 //服务器未连接[自定义码]
	,EB_STATE_OK							= 0
	, EB_STATE_ERROR					= 1
	, EB_STATE_NOT_AUTH_ERROR					// 没有权限
	, EB_STATE_ACC_PWD_ERROR					// 帐号或密码错误
	, EB_STATE_NEED_RESEND						// 需要重发数据
	, EB_STATE_TIMEOUT_ERROR					// 超时错误
	, EB_STATE_EXIST_OFFLINE_MSG				// 存在离线消息
	, EB_STATE_USER_OFFLINE						// 用户离线状况
	, EB_STATE_USER_BUSY						// 用户线路忙
	, EB_STATE_USER_HANGUP						// 用户挂断会话
	, EB_STATE_OAUTH_FORWARD					// OAUTH转发
    , EB_STATE_UNAUTH_ERROR                     // 未验证错误
    , EB_STATE_ACCOUNT_FREEZE                   //账号被冻结
	, EB_STATE_PARAMETER_ERROR			= 15	// 参数错误
	, EB_STATE_DATABASE_ERROR					// 数据库操作错误
	, EB_STATE_NEW_VERSION						// 新版本
	, EB_STATE_FILE_ALREADY_EXIST				// 文件已经存在
	, EB_STATE_ACCOUNT_NOT_EXIST		= 20	// 帐号不存在
	, EB_STATE_ACCOUNT_ALREADY_EXIST			// 帐号已经存在
	, EB_STATE_ACCOUNT_DISABLE_OFFCALL			// 禁止离线会话
	, EB_STATE_ACCOUNT_DISABLE_EXTCALL			// 禁止外部会话
    , EB_STATE_DISABLE_REGISTER_USER    =  25   // 禁止用户注册功能
    , EB_STATE_DISABLE_REGISTER_ENT             // 禁止企业注册功能
	, EB_STATE_ENTERPRISE_ALREADY_EXIST	= 30	// 公司名称已经存在
	, EB_STATE_ENTERPRISE_NOT_EXIST				// 没有公司信息（企业不存在）
	, EB_STATE_DEP_NOT_EXIST					// 不存在群组（部门）
	, EB_STATE_EXIST_SUB_DEPARTMENT				// 存在子部门
	, EB_STATE_DEP_ACC_ERROR					// 群组或成员不存在
    , EB_STATE_ENT_ACC_ERROR                    // 企业员工成员不存在
    , EB_STATE_CS_MAX_ERROR                     // 超过客服座席最大数量
    , EB_STATE_NOT_CS_ERROR                     // 没有客服座席
    , EB_STATE_EXCESS_QUOTA_ERROR               // 超过最大流量配额
    , EB_STATE_ENT_GROUP_ERROR                  // 企业部门
	, EB_STATE_ONLINE_KEY_ERROR			= 40
	, EB_STATE_UM_KEY_ERROR
	, EB_STATE_CM_KEY_ERROR
	, EB_STATE_DEVID_KEY_ERROR
	, EB_STATE_APPID_KEY_ERROR
    , EB_STATE_DEVID_NOT_EXIST
    , EB_STATE_APPID_NOT_EXIST
	, EB_STATE_APP_ONLINE_KEY_TIMEOUT
	, EB_STATE_CALL_NOT_EXIST			= 50
	, EB_STATE_CHAT_NOT_EXIST
	, EB_STATE_MSG_NOT_EXIST
	, EB_STATE_RES_NOT_EXIST
	, EB_STATE_NOT_MEMBER_ERROR
	, EB_STATE_ATTACHMENT_NOT_EXIST
	, EB_STATE_NO_UM_SERVER				= 60
	, EB_STATE_NO_CM_SERVER
	, EB_STATE_NO_VM_SERVER
	, EB_STATE_NO_AP_SERVER
    , EB_STATE_ENT_BLACKLIST			= 70	// 企业黑名单用户
    , EB_STATE_ANOTHER_ENT_ACCOUNT				// 其他企业帐号
    , EB_STATE_MAX_CAPACITY_ERROR				// 最大容量错误
    , EB_STATE_NOT_SUPPORT_VERSION_ERROR		// 不支持当前版本
    , EB_STATE_FORWARD_MSG						// 转发消息
    , EB_STATE_MAX_RETRY_ERROR					// 错误次数太多，请三十分钟后再试！
    , EB_STATE_TOKEN_ERROR						// TOKEN错误
    , EB_STATE_MAX_UG_ERROR						// 超过最大分组数量
    , EB_STATE_MAX_CONTACT_ERROR				// 超过最大联系人数量
    , EB_STATE_CONTACT_NOT_EXIST				// 联系人不存在
    
} EB_STATE_CODE;

/*==========================================================
 用户类型
 ===========================================================*/
typedef enum EB_ACCOUNT_TYPE
{
    EB_ACCOUNT_TYPE_OFFLINE     = -1 //离线
	,EB_ACCOUNT_TYPE_VISITOR	// 游客
	, EB_ACCOUNT_TYPE_IN_ENT	// 同企业或同群组
	, EB_ACCOUNT_TYPE_OUT_ENT	// 外部成员
	, EB_ACCOUNT_TYPE_USER		// 普通用户
} EB_ACCOUNT_TYPE;

/*==========================================================
 请求类型
 ===========================================================*/
typedef enum EB_REQUEST_TYPE
{
    EB_REQUEST_TYPE_UNKNOWN
    ,EB_REQUEST_TYPE_REG        //用户注册请求
    ,EB_REQUEST_TYPE_LOGON      //登录请求
    ,EB_REQUEST_TYPE_INVITE     //呼叫请求
    ,EB_REQUEST_TYPE_DEP
    ,EB_REQUEST_TYPE_FINPWD
    ,EB_REQUEST_TYPE_USER_INFO  //用户信息
} EB_REQUEST_TYPE;

/*==========================================================
 应用功能应用模式
 ===========================================================*/
typedef enum EB_FUNC_MODE
{
    EB_FUNC_MODE_BROWSER			// 浏览器模式
    , EB_FUNC_MODE_MAINFRAME		// 主面板（默认）
    , EB_FUNC_MODE_MODAL			// 对话框模式（模式）
    , EB_FUNC_MODE_PROGRAM			// 打开应用程序
    , EB_FUNC_MODE_SERVER			// 服务模式（HTTP POST）
    , EB_FUNC_MODE_WINDOW			// 窗口模式（无模式）
} EB_FUNC_MODE;

/*==========================================================
 个人设置
 ===========================================================*/
typedef enum EB_SETTING_VALUE
{
	EB_SETTING_ENABLE_OUTENT_CALL		= 0x0001    //开放外部企业用户通讯权限
	, EB_SETTING_AUTO_OUTENT_ACCEPT		= 0x0002    //自动接通企业用户会话
	, EB_SETTING_ENABLE_USER_CALL		= 0x0004    //开放注册用户通讯权限
	, EB_SETTING_AUTO_USER_ACCEPT		= 0x0008    //自动接通普通注册用户会话
	, EB_SETTING_ENABLE_VISITOR_CALL	= 0x0010    //开放游客通讯权限
	, EB_SETTING_AUTO_VISITOR_ACCEPT	= 0x0020    //自动接通游客会话
	, EB_SETTING_ENABLE_OFF_CALL		= 0x0040    //自动接收离线信息
	, EB_SETTING_ENABLE_OFF_FILE		= 0x0080    //开放接收离线文件权限
//	, EB_SETTING_CONNECTED_OPEN_CHAT	= 0x0100
//    , EB_SETTING_AUTO_CONTACT_ACCEPT	= 0x0200    //自动接通好友(联系人)会话
} EB_SETTING_VALUE;
//(EB_SETTING_ENABLE_OUTENT_CALL|EB_SETTING_AUTO_OUTENT_ACCEPT|EB_SETTING_ENABLE_USER_CALL|EB_SETTING_AUTO_USER_ACCEPT|EB_SETTING_ENABLE_VISITOR_CALL|EB_SETTING_AUTO_VISITOR_ACCEPT|EB_SETTING_ENABLE_OFF_CALL)
#define EB_SETTING_DEFAULT 127 // EB_SETTING_ENABLE_OUTENT_CALL-EB_SETTING_ENABLE_OFF_CALL


#endif // __eb_define_h__
