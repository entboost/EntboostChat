//
//  ENTBoostChat.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-21.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#ifndef ENTBoostChat_ENTBoostChat_h
#define ENTBoostChat_ENTBoostChat_h

//#define COPYRIGHT_KEY_PATH @"com.entboost.ENTBoostChat" //公司KeyPath
#define ENTBOOST_PASTE_BOARD_NAME @"com.entboost.pasteboard"   //剪切板名称
#define ENTBOOST_PASTE_BOARD_TYPE_MESSAGE_KEY @"com.entboost.pasteboard.type.message.key" //剪切板类型-消息key

#define STAMP_CUSTOM_DATA_EMOTION_NAME @"stamp_custom_data_emotion"     //标记表情图片
#define COMMON_CUSTOM_DATA_MESSAGE_NAME @"common_custom_data_message"   //标记普通图片

//判断IOS版本
#define IOS_VERSION [[[UIDevice currentDevice]systemVersion] floatValue]
//高于或等于IOS7
#define IOS7 (IOS_VERSION >= 7.0)
//高于或等于IOS8
#define IOS8 (IOS_VERSION >= 8.0)
//高于或等于IOS9
#define IOS9 (IOS_VERSION >= 9.0)
//高于或等于IOS10
#define IOS10 (IOS_VERSION >= 10.0)

//会话邀请状态类型
typedef enum CALL_ACTION_TYPE {
    CALL_ACTION_TYPE_REJECT, //对方拒绝
    CALL_ACTION_TYPE_BUSY, //对方忙，未响应
    CALL_ACTION_TYPE_CONNECTED, //会话就绪
} CALL_ACTION_TYPE;

//联系人类型
typedef enum RELATIONSHIP_TYPE {
    RELATIONSHIP_TYPE_ENTGROUP = 1,  //企业部门
    RELATIONSHIP_TYPE_PERSONALGROUP, //个人群组
    RELATIONSHIP_TYPE_MYDEPARTMENT, //我的部门或讨论组
    RELATIONSHIP_TYPE_CONTACTGROUP, //个人通讯录分组
    RELATIONSHIP_TYPE_MEMBER, //部门或群组成员
    RELATIONSHIP_TYPE_CONTACT //个人通讯录
} RELATIONSHIP_TYPE;

//音视频通话工作状态
typedef enum AV_WORK_STATE
{
    AV_WORK_STATE_IDLE,         //空闲，没有任何业务动作
    AV_WORK_STATE_HANGUP,       //通话结束
    AV_WORK_STATE_REJECTED,     //拒绝通话
    AV_WORK_STATE_TIMEOUT,      //呼叫超时
    AV_WORK_STATE_INCOMING = 10,//正在被叫响铃
    AV_WORK_STATE_ALERTING     ,//正在呼叫对方
    AV_WORK_STATE_CONNECTED     //正在进行通话
} AV_WORK_STATE;


//联系人点击切换到聊天界面的通知标识
#define EBCHAT_NOTIFICATION_RELATIONSHIP_DIDSELECT @"notification_relationship_didselect"
//应用功能点击切换到聊天界面的通知标识
#define EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT @"notification_application_didselect"
//用户(群组)属性界面点击切换聊天界面的通知标识
#define EBCHAT_NOTIFICATION_SHOW_TALK @"notification_information_show_talk"
//浏览文件目录
#define EBCHAT_NOTIFICATION_BROWSE_FOLDER @"notification_information_browse_folder"

//显示指定应用界面的通知标识
#define EBCHAT_NOTIFICATION_SHOW_APPLICATION @"notification_information_show_application"

//创建个人群组
#define EBCHAT_NOTIFICATION_CREATE_PERSONAL_GROUP @"notification_create_personal_group"
//退出群组的通知标识
#define EB_CHAT_NOTIFICATION_EXIT_GROUP @"notification_exit_group"
//解散/删除群组的通知标识
#define EB_CHAT_NOTIFICATION_DELETE_GROUP @"notification_delete_group"
//删除联系人的通知标识
#define EB_CHAT_NOTIFICATION_DELETE_CONTACT @"notification_delete_contact"
//添加联系人的通知标识
#define EB_CHAT_NOTIFICATION_ADD_CONTACT @"notification_add_contact"
//重载联系人的通知标识
#define EB_CHAT_NOTIFICATION_RELOAD_CONTACT @"notification_reload_contact"
//邀请成员进入群组的通知标识
#define EB_CHAT_NOTIFICATION_INVITE_MEMBER @"notification_invite_member"
//删除群组成员的通知标识
#define EB_CHAT_NOTIFICATION_DELETE_MEMBER @"notification_delete_member"

//手动退出登录通知标识
#define EBCHAT_NOTIFICATION_MANUAL_LOGOFF @"notification_manual_logoff"
//手动登录成功通知标识
#define EBCHAT_NOTIFICATION_MANUAL_LOGON_SUCCESS @"notification_manual_logon_success"
//手动登录失败通知标识
#define EBCHAT_NOTIFICATION_MANUAL_LOGON_FAILURE @"notification_manual_logon_failure"
//正在执行登录通知标识
#define EBCHAT_NOTIFICATION_LOGON_EXECUTING @"notification_logon_executing"

#endif

//storyboard NAME
#define EBCHAT_STORYBOARD_NAME_LOGON @"Logon"
#define EBCHAT_STORYBOARD_NAME_MAIN @"Main"
#define EBCHAT_STORYBOARD_NAME_TALK @"Talk"
#define EBCHAT_STORYBOARD_NAME_APP @"App"
#define EBCHAT_STORYBOARD_NAME_SETTING @"Setting"
#define EBCHAT_STORYBOARD_NAME_CONTACT @"Contact"
#define EBCHAT_STORYBOARD_NAME_OTHER @"Other"
#define EBCHAT_STORYBOARD_NAME_IMAGEVIEW @"ImageView"

//main storyboard ID
#define EBCHAT_MAIN_STORYBOARD_ID_TALKS_CONTROLLER @"talksController_ID"
#define EBCHAT_MAIN_STORYBOARD_ID_RELATIONSHIP_CONTROLLER @"relationshipController_ID"
#define EBCHAT_MAIN_STORYBOARD_ID_APPLICATIONS_CONTROLLER @"applicationsController_ID"
#define EBCHAT_MAIN_STORYBOARD_ID_SETTINGS_CONTROLLER @"settingsController_ID"

//sub storyboard ID
#define EBCHAT_STORYBOARD_ID_LOGON_CONTROLLER @"logonController_ID"
#define EBCHAT_STORYBOARD_ID_SPLASH_SCREEN_CONTROLLER @"splashScreenController_ID"
#define EBCHAT_STORYBOARD_ID_TABBAR_CONTROLLER @"tabBarController_ID"
#define EBCHAT_STORYBOARD_ID_SERVERCONFIG_CONTROLLER @"serverConfigController_ID"
#define EBCHAT_STORYBOARD_ID_REGISTUSER_CONTROLLER @"registUserController_ID"
#define EBCHAT_STORYBOARD_ID_RESETPASSWORD_CONTROLLER @"resetPasswordController_ID"

#define EBCHAT_STORYBOARD_ID_TALK_CONTROLLER @"talkController_ID"
#define EBCHAT_STORYBOARD_ID_SEARCH_PERSON_CONTROLLER @"searchPersonController_ID"

#define EBCHAT_STORYBOARD_ID_FILES_CONTROLLER @"filesBrowserController_ID"
#define EBCHAT_STORYBOARD_ID_DOCUMENT_CONTROLLER @"documentViewController_ID"
#define EBCHAT_STORYBOARD_ID_COMMON_TEXT_INPUT_CONTROLLER @"commonTextInputViewController_ID"
#define EBCHAT_STORYBOARD_ID_CAPTION_EDIT_CONTROLLER @"captionEditViewController_ID"

#define EBCHAT_STORYBOARD_ID_IMAGE_VIEW_CONTROLLER @"imageViewController_ID"
#define EBCHAT_STORYBOARD_ID_AQS_VIEW_CONTROLLER @"AQSController_ID"

#define EBCHAT_STORYBOARD_ID_APP_CONTROLLER @"appController_ID"
#define EBCHAT_STORYBOARD_ID_CONVERSATION_CONTROLLER @"conversationController_ID"

#define EBCHAT_STORYBOARD_ID_MY_INFORMATION_CONTROLLER @"myInformationController_ID"
#define EBCHAT_STORYBOARD_ID_CONTACT_INFORMATION_CONTROLLER @"contactInformationController_ID"
#define EBCHAT_STORYBOARD_ID_USER_INFORMATION_CONTROLLER @"userInformationController_ID"
#define EBCHAT_STORYBOARD_ID_GROUP_INFORMATION_CONTROLLER @"groupInformationController_ID"
#define EBCHAT_STORYBOARD_ID_MEMBER_LIST_CONTROLLER @"memberListViewController_ID"

#define EBCHAT_STORYBOARD_ID_HEAD_PHOTO_SETTING_CONTROLLER @"HeadPhotoSettingViewController_ID"
#define EBCHAT_STORYBOARD_ID_VCARD_SETTINGS_CONTROLLER @"VCardSettingsViewController_ID"
#define EBCHAT_STORYBOARD_ID_SECRITY_SETTINGS_CONTROLLER @"secritySettingsViewController_ID"
#define EBCHAT_STORYBOARD_ID_CHANGE_PASSWORD_CONTROLLER @"changePasswordViewController_ID"
#define EBCHAT_STORYBOARD_ID_TALK_SETTING_CONTROLLER @"talkSettingController_ID"
#define EBCHAT_STORYBOARD_ID_PHOTO_EDITOR_CONTROLLER @"PhotoEditorViewController_ID"

#define EBCHAT_STORYBOARD_ID_RELATIONSHIP_DEEPIN_CONTROLLER @"relationshipDeepInController_ID"

#define EBCHAT_STORYBOARD_ID_MEMBER_SELECTED_CONTROLLER @"memberSelectedController_ID"
#define EBCHAT_STORYBOARD_ID_MEMBER_SELECTED_DEEPIN_CONTROLLER @"memberSelectedDeepInController_ID"
#define EBCHAT_STORYBOARD_ID_CONTACT_GROUP_CONTROLLER @"contactGroupController_ID"

//界面默认主色调
#define EBCHAT_DEFAULT_COLOR [UIColor colorWithHexString:@"#00a2e8"]
//默认边框颜色
#define EBCHAT_DEFAULT_BORDER_CORLOR [UIColor colorWithHexString:@"#e0e0e0"]
//默认背景颜色
#define EBCHAT_DEFAULT_BACKGROUND_COLOR [UIColor whiteColor]
//框架背景颜色
#define EBCHAT_DEFAULT_BLANK_COLOR [UIColor colorWithHexString:@"#fafafa"]
//框架背景颜色-深
#define EBCHAT_DEFAULT_BLANK_DEEP_COLOR [UIColor colorWithHexString:@"#eaeaea"]
//默认选中颜色
#define EBCHAT_DEFAULT_SELECTED_COLOR [UIColor colorWithHexString:@"#35c2ff"]
//TabBar选中时字体颜色
#define EBCHAT_TABBAR_SELECTED_FONT_COLOR [UIColor colorWithHexString:@"#2bb33f"]
//默认字体颜色
#define EBCHAT_DEFAULT_FONT_COLOR [UIColor colorWithHexString:@"#404040"]
//浅字体颜色
#define EBCHAT_LIGHT_FONT_COLOR [UIColor colorWithHexString:@"#a0a0a0"]

//默认边框线宽度
#define EBCHAT_DEFAULT_BORDER_WIDTH 1.0f
//默认圆角直径
#define EBCHAT_DEFAULT_CORNER_RADIUS 3.0f
#define EBCHAT_DEFAULT_CORNER_RADIUS1 2.0f

//设置圆角边框
#define EBCHAT_UI_SET_CORNER_VIEW_RADIUS(view, border, color, radius) [view setCornerRadius:radius borderWidth:border borderColor:color]
#define EBCHAT_UI_SET_CORNER_VIEW(view, border, color) EBCHAT_UI_SET_CORNER_VIEW_RADIUS(view, border, color, EBCHAT_DEFAULT_CORNER_RADIUS)
#define EBCHAT_UI_SET_CORNER_VIEW1(view, border, color) EBCHAT_UI_SET_CORNER_VIEW_RADIUS(view, border, color, EBCHAT_DEFAULT_CORNER_RADIUS1)
#define EBCHAT_UI_SET_CORNER_VIEW_WHITE(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor whiteColor])
#define EBCHAT_UI_SET_CORNER_VIEW_CLEAR(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor clearColor])
#define EBCHAT_UI_SET_CORNER_VIEW_CLEAR1(view) EBCHAT_UI_SET_CORNER_VIEW1(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor clearColor])
#define EBCHAT_UI_SET_CORNER_BUTTON_1(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor colorWithHexString:@"#3dadd3"])
#define EBCHAT_UI_SET_CORNER_BUTTON_2(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor colorWithHexString:@"#6fd9a3"])
#define EBCHAT_UI_SET_CORNER_BUTTON_3(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor colorWithHexString:@"#D4F4FF"])
#define EBCHAT_UI_SET_CORNER_BUTTON_4(view) EBCHAT_UI_SET_CORNER_VIEW(view, EBCHAT_DEFAULT_BORDER_WIDTH, [UIColor lightGrayColor])

//设置默认边框
#define EBCHAT_UI_SET_DEFAULT_BORDER(view) EBCHAT_UI_SET_CORNER_VIEW_RADIUS(view, EBCHAT_DEFAULT_BORDER_WIDTH, EBCHAT_DEFAULT_BORDER_CORLOR, 0.0f)

//联系人界面视图tag
#define EB_RELATIONSHIPS_VC_MY_DEPARTMENT_VIEW_TAG 200
#define EB_RELATIONSHIPS_VC_ENTERPRISE_VIEW_TAG 201
#define EB_RELATIONSHIPS_VC_PERSONALGROUP_VIEW_TAG 202
#define EB_RELATIONSHIPS_VC_CONTACT_VIEW_TAG 203

//查看属性界面功能操作定义

//显示发送消息界面
#define INFORMATION_FUNCTION_SHOW_TALK @"showTalk"
//删除联系人
#define INFORMATION_FUNCTION_DELETE_CONTACT @"deleteContact"
//验证联系人
#define INFORMATION_FUNCTION_VERIFY_CONTACT @"verifyContact"
//退出群组或部门
#define INFORMATION_FUNCTION_EXIT_GROUP @"exitGroup"
//删除群组或部门
#define INFORMATION_FUNCTION_DELETE_GROUP @"deleteGroup"
//删除成员
#define INFORMATION_FUNCTION_DELETE_MEMBER @"deleteMember"
//邀请成员(群组或部门)
#define INFORMATION_FUNCTION_INVITE_MEMBER @"inviteMember"
//设置为默认电子名片
#define INFORMATION_FUNCTION_SET_DEFAULT_EMP @"setDefaultEmp"

//分隔线属性定义
//#define CUSTOM_SEPARATOR_DEFAULT_COLOR [UIColor colorWithHexString:@"#c1dce5"]
#define CUSTOM_SEPARATOR_DEFAULT_COLOR [UIColor colorWithHexString:@"#e0e0e0"]
#define CUSTOM_SEPARATOR_DEFAULT_LINE_HEIGHT 0.5f

//空指针显示
#define REALVALUE(value) value?value:@""

//加载提示框标题
#define LOADING_ALERT_VIEW_TITLE @"加载中..."
//显示提示框
#define ShowAlertView()\
[FVCustomAlertView showDefaultLoadingAlertOnView:[UIApplication sharedApplication].keyWindow withTitle:LOADING_ALERT_VIEW_TITLE];
//关闭提示框
#define CloseAlertView()\
[BlockUtility performBlockInMainQueue:^{\
    [FVCustomAlertView hideAlertFromView:[UIApplication sharedApplication].keyWindow fading:YES];\
}];

//普通提示框
#define ShowCommonAlertView(title)\
[FVCustomAlertView showDefaultDoneAlertOnView:[UIApplication sharedApplication].keyWindow withTitle:title];

//聊天内容渲染参数
#define CHAT_RICH_CONTENT_HORI_SAPCE 15.0f
#define CHAT_FILE_CONTENT_HORI_SPACE 10.0f
#define CHAT_CONTENT_VERT_SAPCE 8.0f
#define CHAT_CONTENT_GAP_WIDTH 130.0f
#define CHAT_CONTENT_MAX_HEIGHT 10000.0f
