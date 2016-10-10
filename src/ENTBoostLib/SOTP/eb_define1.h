// eb_define1.h file here
#ifndef __eb_define1_h__
#define __eb_define1_h__
#include "eb_define.h"

/*==========================================================
 消息类型
 ===========================================================*/
typedef enum EB_MSG_TYPE
{
	EB_MSG_UNKNOWN
	, EB_MSG_RICH		// text&image
	, EB_MSG_FILE
    
	, EB_MSG_DELETE_GROUP			= 0x101		// 解散群
	, EB_MSG_EXIT_GROUP							// 主动退出群
	, EB_MSG_UPDATE_GROUP						// 群资料已经修改，需要重新加载群资料
	, EB_MSG_REMOVE_GROUP						// 被动管理员移出群
	, EB_MSG_CALL_2_GROUP						// 一对一会话转换多人讨论组
    , EB_MSG_ADD_2_GROUP                        // 添加进群组(部门)
    , EB_MSG_REQ_ADD_2_GROUP                    // 申请进入群组(部门)
    , EB_MSG_REJECT_ADD_2_GROUP                 // 拒绝进入群组(部门)
    , EB_MSG_INVITE_ADD_2_GROUP                 // 邀请添加进群组(部门)
	, EB_MSG_USER_LINE_STATE		= 0x111		// 用户在线状态通知
	, EB_MSG_ONLINE_ANOTHER			= 0x112		// 通知自己，已经在其他地方登录，退出前一个连接
    , EB_MSG_USER_ONLINE_INCALL		= 0x113		// 用户上线，邀请用户进现有会话
    
	, EB_MSG_USER_HEAD_CHANGE		= 0x121		// 用户修改头像资源
    , EB_MSG_BROADCAST_MESSAGE      = 0x122     // 广播消息
    , EB_MSG_GROUP_MEMBER_CHANGE    = 0x123     // 群成员资料变更
    
	, EB_MSG_DELETE_RESOURCE		= 0x131		// 删除在线资源
    , EB_MSG_EMOTION_INFO           = 0x132     // 表情资源信息
    , EB_MSG_SUBSCRIBE_FUNC_INFO    = 0x133     // 订购功能信息
    , EB_MSG_ENTGROUP_VER_INFO      = 0x134     // 企业部门版本信息
    , EB_MSG_MYGROUP_VER_INFO       = 0x135     // 个人群组版本信息
    , EB_MSG_GROUP_MEMBER_LINESTATE = 0x136     // 群组(部门)成员在线状态
    , EB_MSG_AREA_DICT_INFO         = 0x137     // 地区字典信息
    , EB_MSG_GROUP_LINESTATE_COUNT  = 0x138     // 群组(部门)成员在线人数
    
    , EB_MSG_REQ_ADD_CONTACT        = 0x141     // 申请好友
    , EB_MSG_ACCEPT_ADD_CONTACT                 // 接受好友
    , EB_MSG_REJECT_ADD_CONTACT                 // 拒绝好友
    , EB_MSG_DELETE_CONTACT                     // 被对方删除好友
} EB_MSG_TYPE;

/*==========================================================
 富文本消息子类型
 ===========================================================*/
typedef enum EB_RICH_SUB_TYPE
{
    EB_RICH_SUB_TYPE_JPG            //JPG图片
    ,EB_RICH_SUB_TYPE_AUDIO = 11    //语音
} EB_RICH_SUB_TYPE;

/*==========================================================
 群组（部门）成员管理权限
 ===========================================================*/
typedef enum EB_MANAGER_LEVEL
{
    EB_LEVEL_NONE
    , EB_LEVEL_DEP_EDIT			= 0x0001
    , EB_LEVEL_DEP_DELETE		= 0x0002
    , EB_LEVEL_EMP_EDIT			= 0x0004
    , EB_LEVEL_EMP_DELETE		= 0x0008
    , EB_LEVEL_DEP_RES_EDIT		= 0x0010
    , EB_LEVEL_DEP_RES_DELETE	= 0x0020
    , EB_LEVEL_DEP_ADMIN		= EB_LEVEL_DEP_EDIT|EB_LEVEL_EMP_EDIT|EB_LEVEL_EMP_DELETE|EB_LEVEL_DEP_RES_EDIT|EB_LEVEL_DEP_RES_DELETE
} EB_MANAGER_LEVEL;

/*==========================================================
 登录类型
 ===========================================================*/
typedef enum EB_LOGON_TYPE
{
	EB_LOGON_TYPE_UNKNOWN			= 0
	, EB_LOGON_TYPE_EMAIL			= 0x0000001
	, EB_LOGON_TYPE_PHONE			= 0x0000002
	, EB_LOGON_TYPE_VISITOR			= 0x0000004
    , EB_LOGON_TYPE_MAIL_TEST       = 0x0000010
	, EB_LOGON_TYPE_PC				= 0x0000100
	, EB_LOGON_TYPE_IOS				= 0x0000200
	, EB_LOGON_TYPE_ANDROID			= 0x0000400
	, EB_LOGON_TYPE_WP				= 0x0000800
	, EB_LOGON_TYPE_WEB				= 0x0001000
    , EB_LOGON_TYPE_SERVER          = 0x0010000
	, EB_LOGON_TYPE_APPID			= 0x0100000
	, EB_LOGON_TYPE_OAUTH			= 0x0200000
} EB_LOGON_TYPE;

/*==========================================================
 消息响应类型
 ===========================================================*/
typedef enum EB_MSG_ACK_TYPE
{
	EB_MAT_SUCCESS
	, EB_MAT_ERROR
	, EB_MAT_CANCEL
	, EB_MAT_REQUEST
} EB_MSG_ACK_TYPE;

/*==========================================================
 数据流响应类型
 ===========================================================*/
typedef enum EB_DATASTREAM_ACK_TYPE
{
	EB_DSAT_UNKNOWN
	, EB_DSAT_OK
	, EB_DSAT_REQUEST
} EB_DATASTREAM_ACK_TYPE;

/*==========================================================
 会话响应类型
 ===========================================================*/
typedef enum EB_CALL_ACK_TYPE
{
	EB_CAT_UNKNOWN
	, EB_CAT_ACCEPT
	, EB_CAT_REJECT
} EB_CALL_ACK_TYPE;

/*==========================================================
 SOTP SIGN：
 ===========================================================*/
typedef enum EB_CALL_SIGN
{
	EB_SIGN_UNKNOWN
	//, EB_CS_CS_ONLINE		= 0x001
	//, EB_CS_CS_OFFLINE
	//, EB_CS_CS_ACTIVE
	//, EB_CS_CS_QUERY
	//, EB_CS_CS_LOAD
	// LC
	, EB_SIGN_S_ONLINE		= 0x101
	, EB_SIGN_S_OFFLINE
	, EB_SIGN_S_ACTIVE
	, EB_SIGN_S_QUERY
	, EB_SIGN_L_LOGON
	, EB_SIGN_L_LOGOUT
	, EB_SIGN_L_QUERY
	// UM
	, EB_SIGN_U_REG				= 0x201
	, EB_SIGN_U_SINFO
	, EB_SIGN_U_SHEAD
	, EB_SIGN_U_ONLINE
	, EB_SIGN_U_LOAD
	, EB_SIGN_U_OFFLINE
    , EB_SIGN_U_QUERY
    
	//, EB_CS_UM_ACTIVE
	, EB_SIGN_V_REQUEST			= 0x211
	, EB_SIGN_FV_REQUEST
	, EB_SIGN_V_ACK
	, EB_SIGN_FV_ACK
	, EB_SIGN_V_END
	, EB_SIGN_FV_END
	, EB_SIGN_C_CALL			= 0x221
	, EB_SIGN_C_ENTER
	, EB_SIGN_FC_CALL
	, EB_SIGN_FC_ENTER
	, EB_SIGN_C_ACK
	, EB_SIGN_FC_ACK
	, EB_SIGN_C_HANGUP
	, EB_SIGN_FC_HANGUP
	, EB_SIGN_U_MSG
	, EB_SIGN_FU_MSG
    , EB_SIGN_U_MACK
    
	, EB_SIGN_AB_EDIT			= 0x231
	, EB_SIGN_AB_DEL
	, EB_SIGN_AB_LOAD
    , EB_SIGN_UG_EDIT
    , EB_SIGN_UG_DEL
    , EB_SIGN_UG_LOAD
	, EB_SIGN_ENT_EDIT		= 0x241
	, EB_SIGN_DEP_EDIT
	, EB_SIGN_DEP_DEL
	, EB_SIGN_EMP_EDIT
	, EB_SIGN_EMP_DEL
	, EB_SIGN_ENT_LOAD
	, EB_SIGN_FENT_INFO
	, EB_SIGN_FDEP_INFO
	, EB_SIGN_FEMP_INFO
	, EB_SIGN_R_EDIT		= 0x251
	, EB_SIGN_R_DEL
	, EB_SIGN_R_LOAD
	, EB_SIGN_R_INFO
    
    , EB_SIGN_CS_LOAD       = 0x261
    , EB_SIGN_CS_ADD
    , EB_SIGN_CS_DEL
    
    , EB_SIGN_FUNC_REQ      =0x271
    , EB_SIGN_FUNC_AUTH
    , EB_SIGN_FUNC_LOAD
    , EB_SIGN_FUNC_EDIT
    , EB_SIGN_FUNC_DEL
    , EB_SIGN_FUNC_SUB
    , EB_SIGN_FUNC_SETICON
    , EB_SIGN_FNAV_SET
    , EB_SIGN_FNAV_DEL
    , EB_SIGN_FNAV_LOAD
    
	, EB_SIGN_VER_CHECK		= 0x281
    
    , EB_SIGN_DICT_LOAD     = 0x291
    
	, EB_SIGN_CM_ENTER		= 0x301
	, EB_SIGN_FCM_ENTER
	, EB_SIGN_CM_EXIT
	, EB_SIGN_FCM_EXIT
	, EB_SIGN_CM_ACTIVE
	, EB_SIGN_CM_MSG
	, EB_SIGN_FCM_MSG
	, EB_SIGN_CM_MACK
	, EB_SIGN_FCM_MACK
	, EB_SIGN_DS_SEND
	, EB_SIGN_FDS_SEND
	, EB_SIGN_DS_CHECK
	, EB_SIGN_DS_ACK
	//, EB_SIGN_CR_SET		= 0x311
	//, EB_SIGN_CR_GET
    
    , EB_SIGN_RTP_ON        = 0X331
    , EB_SIGN_RTP_OFF
    
	, EB_SIGN_A_ON		= 0x401
	, EB_SIGN_A_OFF
	, EB_SIGN_A_MSG
	, EB_SIGN_FA_MSG
	, EB_SIGN_A_MACK
	, EB_SIGN_FA_MACK
    
} EB_CALL_SIGN;

/*==========================================================
 系统常量
 ===========================================================*/
//const int	EB_MAX_REQUEST_OS_COUNT	= 140;		// 一次最多请求数据补偿数据包

///////////////////
#define POP_APP_NAME_CENTER_SERVER		"POPCenterServer"
#define POP_APP_NAME_LOGON_CENTER		"POPLogonCenter"
#define POP_APP_NAME_USERMANAGER        "POPUserManager"
#define POP_APP_NAME_CHATMANAGER        "POPChatManager"
#define POP_APP_NAME_AUDIOMANAGER       "ebmmas"
#define POP_APP_NAME_VIDEOMANAGER       "ebmmvs"
#define EB_APP_NAME_LOGON_CENTER		"eblc"

//#define EB_CALL_NAME_CS_ONLINE			"pop_cs_online"
//#define EB_CALL_NAME_CS_OFFLINE		"pop_cs_offline"
//#define EB_CALL_NAME_CS_ACTIVE			"pop_cs_active"
//#define EB_CALL_NAME_CS_QUERY			"pop_cs_query"
//#define EB_CALL_NAME_CS_LOAD			"pop_cs_load"

#define EB_CALL_NAME_S_ONLINE			"eb_s_online"
#define EB_CALL_NAME_S_OFFLINE			"eb_s_offline"
#define EB_CALL_NAME_S_ACTIVE			"eb_s_active"
#define EB_CALL_NAME_S_QUERY			"eb_s_query"
#define EB_CALL_NAME_LC_LOGON			"eb_l_logon"
#define EB_CALL_NAME_LC_LOGOUT			"eb_l_logout"
#define EB_CALL_NAME_LC_QUERY			"eb_l_query"

#define EB_CALL_NAME_V_REQUEST			"eb_v_request"
#define EB_CALL_NAME_V_ACK				"eb_v_ack"
#define EB_CALL_NAME_V_END				"eb_v_end"
#define EB_CALL_NAME_UM_REG				"eb_u_reg"
#define EB_CALL_NAME_UM_SINFO			"eb_u_sinfo"
#define EB_CALL_NAME_UM_SHEAD			"eb_u_shead"
#define EB_CALL_NAME_UM_ONLINE			"eb_u_online"
#define EB_CALL_NAME_UM_LOAD			"eb_u_load"
#define EB_CALL_NAME_UM_OFFLINE			"eb_u_offline"
#define EB_CALL_NAME_UM_QUERY           "eb_u_query"
//#define EB_CALL_NAME_UMIU_GROUP		"eb_umiu_group"
#define EB_CALL_NAME_UM_MSG				"eb_u_msg"
#define EB_CALL_NAME_UM_MACK            "eb_u_mack"
#define EB_CALL_NAME_UM_CALL			"eb_c_call"
#define EB_CALL_NAME_C_ENTER			"eb_c_enter"
#define EB_CALL_NAME_UM_CACK			"eb_c_ack"
#define EB_CALL_NAME_UM_HANGUP			"eb_c_hangup"

#define EB_CALL_NAME_UG_EDIT			"eb_ug_edit"
#define EB_CALL_NAME_UG_DEL				"eb_ug_del"
#define EB_CALL_NAME_UG_LOAD			"eb_ug_load"

#define EB_CALL_NAME_AB_EDIT			"eb_ab_edit"
#define EB_CALL_NAME_AB_DEL				"eb_ab_del"
#define EB_CALL_NAME_AB_LOAD			"eb_ab_load"

#define EB_CALL_NAME_R_EDIT				"eb_r_edit"
#define EB_CALL_NAME_R_DEL				"eb_r_del"
#define EB_CALL_NAME_R_LOAD				"eb_r_load"

#define EB_CALL_NAME_ENT_EDIT			"eb_ent_edit"
#define EB_CALL_NAME_DEP_EDIT			"eb_dep_edit"
#define EB_CALL_NAME_DEP_DEL			"eb_dep_del"
#define EB_CALL_NAME_DEP_OP				"eb_dep_op"
#define EB_CALL_NAME_EMP_EDIT			"eb_emp_edit"
#define EB_CALL_NAME_EMP_DEL			"eb_emp_del"
#define EB_CALL_NAME_ENT_LOAD			"eb_ent_load"

#define EB_CALL_NAME_FNAV_LOAD          "eb_fnav_load"

#define EB_CALL_NAME_VER_CHECK			"eb_ver_check"

#define EB_CALL_NAME_DICT_LOAD          "eb_dict_load"

//#define EB_CALL_NAME_CR_SET				"eb_cr_set"
//#define EB_CALL_NAME_CR_GET				"eb_cr_get"
#define EB_CALL_NAME_CM_ENTER			"eb_cm_enter"
#define EB_CALL_NAME_CM_EXIT			"eb_cm_exit"
#define EB_CALL_NAME_CM_ACTIVE			"eb_cm_active"
#define EB_CALL_NAME_CM_MSG				"eb_cm_msg"
#define EB_CALL_NAME_CM_QUERY			"eb_cm_query"
#define EB_CALL_NAME_CM_MACK			"eb_cm_mack"
#define EB_CALL_NAME_DS_SEND			"eb_ds_send"
#define EB_CALL_NAME_DS_CHECK			"eb_ds_check"
#define EB_CALL_NAME_DS_ACK				"eb_ds_ack"

#define EB_CALL_NAME_RTP_ON             "eb_rtp_on"
#define EB_CALL_NAME_RTP_OFF            "eb_rtp_off"

#define EB_CALL_NAME_A_MSG				"eb_a_msg"

#endif // __eb_define1_h__


/*==========================================================
 音视频命令command类型
 ===========================================================*/
typedef enum SOTP_RTP_COMMAND_TYPE
{
    SOTP_RTP_COMMAND_TYPE_REGISTER_SOURCE      = 1    //用户登记上线
    , SOTP_RTP_COMMAND_TYPE_UNREGISTER_SOURCE         //用户注销下线
    , SOTP_RTP_COMMAND_TYPE_REGISTER_SINK             //订阅用户数据(例如音视频)
    , SOTP_RTP_COMMAND_TYPE_UNREGISTER_SINK           //取消订阅用户数据
    , SOTP_RTP_COMMAND_TYPE_UNREGISTER_ALL            //取消所有用户订阅数据
    , SOTP_RTP_COMMAND_TYPE_NAK_REQUEST               //请求数据补偿
} SOTP_RTP_COMMAND_TYPE;


#pragma pack(1)
/*==========================================================
 音视频请求数据补偿命令command结构体
 ===========================================================*/
typedef struct _sotp_rtp_data_request
{
    uint16_t seq;   //网络发送顺序号，需要用htons转为网络字节顺序
    uint16_t count; //待补偿分包数量，需要用htons转为网络字节顺序
} sotp_rtp_data_request;

/*==========================================================
 音视频命令command结构体
 ===========================================================*/
typedef struct _sotp_rtp_media_command
{
    uint8_t version;        //版本，目前等于2
    uint8_t command;        //命令类型
    uint64_t roomId;        //聊天室编号，相当于callId，需要用htonll转为网络字节顺序
    uint64_t srcId;         //发出者编号，需要用htonll转为网络字节顺序
    union
    {
        uint64_t destId;       //接收者编号或登记命令使用的房间密钥，需要用htonll转为网络字节顺序
        sotp_rtp_data_request dataRequest; //丢包补偿请求描述
    };
} sotp_rtp_media_command;



///*==========================================================
// 音视频数据包-数据头结构
// ===========================================================*/
//typedef struct _eb_rtp_data_header
//{
//    uint64_t uid;                   //用户编号
//    unsigned short data_id;         //块号
//    unsigned short data_block_size; //块单位大小size
//    unsigned char data_block_k;     //块内k数目(<255)
//    unsigned char data_block_n;     //块内n数目(<255)，由纠错块携带
//    unsigned char data_block_index;  //块内索引(<255)
//    unsigned char data_type;        //数据类型，1-normal数据，2-rtp数据，3-纠错数据
//    unsigned int data_length;       //数据长度，可能包含数据扩展头(rtp+rtp_extern)
//} eb_rtp_data_header;
//
///*==========================================================
// 音视频数据包-rtp头结构
// ===========================================================*/
//typedef struct _eb_rtp_rtp_header
//{
//    unsigned char cc;//:4; //CSRC count    默认填0
//    unsigned char x;//:1;  //header extension flag 是否有扩展数据标识：0=没有，1=有；填1
//    unsigned char p;//:1;  //padding fiag 默认填0
//    unsigned char v;//:2;  //packet type 版本，默认填2
//    unsigned char pt;//:7; //payload type payload类型：0=音频数据，1=视频数据，11=关键帧视频数据
//    unsigned char m;//:1;  //market bit 结束包标识：0=不是结束包，1=是结束包(最后一个包或只有一个包)
//    unsigned short seq; //sequence number 传输序列，自增长整数
//    unsigned int ts;    //timestamp 数据采集时间(相对于程序启动后设置的某一时间点而言的差值)，单位ms(毫秒)；接收方通过该时间判断是否超时掉包
//    uint64_t uid;       //发送者用户编号
////    unsigned int nouse; //用于兼容性占位
//} eb_rtp_rtp_header;
//
///*==========================================================
// 音视频数据包-rtp_ext扩展结构
// ===========================================================*/
//typedef struct _eb_rtp_rtp_ext_header
//{
//    unsigned char extType;      //扩展类型，默认填1
//    unsigned char extLen;       //扩展数量，默认填1
//    unsigned short totalLength; //数据帧总长度(音视频采集压缩后整帧大小)，=htons(data_len)
//    unsigned short offset;      //当前分包偏移位置，=htons(index)
//    unsigned short unitLength;  //每个分包大小(一帧分成多个包)，=htons(payload_len)
//} eb_rtp_rtp_ext_header;

/*==========================================================
 音视频数据补偿类型
 ===========================================================*/
typedef enum SOTP_RTP_NAK_TYPE
{
    SOTP_RTP_NAK_NONE   = 0       //不补偿
    ,SOTP_RTP_NAK_REQUEST_1       //需要补偿
    ,SOTP_RTP_NAK_REQUEST_2       //保留
} SOTP_RTP_NAK_TYPE;

/*==========================================================
 音视频RTP数据类型
 ===========================================================*/
typedef enum SOTP_RTP_DATA_TYPE
{
    SOTP_RTP_DATA_AUDIO = 0     //音频数据
    ,SOTP_RTP_DATA_VIDEO        //视频数据
    ,SOTP_RTP_DATA_VIDEO_I      //视频关键帧数据
    ,SOTP_RTP_DATA_SCREEN       //截屏数据，PC专用
    ,SOTP_RTP_DATA_MOUSE        //鼠标数据，PC专用
    ,SOTP_RTP_DATA_OTHER        //其它数据
} SOTP_RTP_DATA_TYPE;

/*==========================================================
 音视频数据包结构
 ===========================================================*/
typedef struct _sotp_rtp_data_desc
{
    uint64_t roomId;        //聊天室编号，相当于callId，需要用htonll转为网络字节顺序
    uint64_t srcId;         //发出者编号，需要用htonll转为网络字节顺序
    uint16_t seq;           //网络发送顺序号，需要用htons转为网络字节顺序
    uint8_t nakType;        //数据补偿类型，SOTP_RTP_NAK_TYPE
    uint8_t dataType;       //数据类型，SOTP_RTP_DATA_TYPE
    uint32_t ts;            //timestamp 数据采集时间(相对于程序启动后设置的某一时间点而言的差值)，单位ms(毫秒)；接收方通过该时间判断是否超时掉包，需要用htonl转为网络字节顺序
    uint32_t totalLength;   //数据帧总长度(音视频采集压缩后整帧大小)，需要用htonl转为网络字节顺序
    uint16_t unitLength;    //每个分包大小(一帧分成多个包)，需要用htons转为网络字节顺序
    uint16_t index;         //当前分包索引(从0开始)，需要用htons转为网络字节顺序
} sotp_rtp_data_desc;

