<?php
 /*******************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * Copyright (C) 2005-2012 sunhopeit.net
 * 
 * [sunhopeit.net ]
 * http://www.sunhopeit.net
 * http://www.sunhopeit.net
 *
 * CONTACT
 * support@sunhopeit.net
 *
 * ---------------------------------------------
 * [A] GNU GENERAL PUBLIC LICENSE GNU/LGPL
 * [B] Apache License, Version 2.0
 *
 * ---------------------------------------------
 *********************************************/

$mod_strings = Array(
'LBL_ROLE_HELP'=>'使用帮助：',
//'LBL_ROLE_HELP1'=>'1.把鼠标放在某个角色上，会出现添加下级角色、编辑角色、复制角色和删除角色的图标，点击相应图标可以维护角色权限。',
'LBL_ROLE_HELP2'=>'1.角色是用来定义可以对系统中哪些模块具备操作权限，角色的层次关系可以视作公司的组织架构。',
'LBL_ROLE_HELP3'=>'2.通过角色可以控制模块权限，可以新增、编辑、查看和删除模块的记录。',
'LBL_ROLE_HELP4'=>'3.通过角色可以控制字段权限，可以只读和编辑模块字段的值。',
'LBL_ROLE_HELP5'=>'4.角色之间的差异主要体现在对模块的操作权限上，即对系统中哪些模块具备什么样的操作权限。',
'LBL_ROLE_HELP6'=>'5.上级可以查看和编辑下级的记录，下级不能查看和编辑上级的记录，同级之间不能互相查看。',
'LBL_ROLE_HELP7'=>'6.一个用户对应一个角色，一个角色可以对应多个用户。',
'LBL_ROLE_HELP8'=>'7.实际工作中不同部门同一岗位应该设置不同角色，以确定上下级关系。',
'LBL_DATAINTERFACE_EXPLAIN'=>'使用说明：',
'LBL_DATAINTERFACE_STEP1'=>'1.订单接口：本系统合同订单保存（包括新增和编辑）后，同时自动保存到接口账套中。',
'LBL_DATAINTERFACE_STEP2'=>'2.凭证接口：本系统销售发票保存（包括新增和编辑）后，同时自动保存到接口账套中。',
'LBL_DATAINTERFACE_STEP3'=>'3.金蝶标准版和迷你版只支持凭证接口，金蝶KIS专业版和K3系统可以支持订单接口和凭证接口。',
'LBL_DATAINTERFACE_STEP4'=>'4.数据接口为单向接口，即只能由本系统到接口账套。',
'LBL_DATAINTERFACE_STEP5'=>'5.数据同步过程中，若接口账套中缺少相关相关客户或商品时，则系统自动向接口账套中增加相关信息。',
'LBL_ROLES'=>'角色',
'LBL_MODULE_NAME'=>'控制面板',
'Hide_Menu'=>'隐藏菜单',
'Show_Menu'=>'显示菜单',
'LBL_MODULE_TITLE'=>'系统设置： 首页',

//'LBL_LIST_CONTACT_ROLE'=>'角色',
'LBL_LIST_CONTACT_ROLE'=>'角色',

'US English'=>'英语（美国）',
'British English'=>'英语（英国）',
'PT Brasil'=>'葡萄牙语',
'DE Deutsch'=>'德语',
'NL-Dutch'=>'荷兰语',
'Francais'=>'法语',
'HU Magyar'=>'马扎尔语',
'ES Mexico'=>'西班牙语（墨西哥）',
'ES Spanish'=>'西班牙语',
'Potential No'=>'销售机会编号',
'Next Step'=>'下一步',
'MailManager'=>'邮件管理',
'Integration'=>'合并',
'ConfigEditor'=>'配置编辑器',
//'CronTasks'=>'时间调度',
'CronTasks'=>'计划任务',

'LBL_LIST_LAST_NAME'=>'姓名',
'Emails' => '邮件管理',
'LBL_FIRST_NAME'=>'英文名：',

'LBL_LAST_NAME'=>'姓名：',

'LBL_PHONE'=>'电话：',

'LBL_EMAIL_ADDRESS'=>'邮件',

'LBL_TRANSCURR'=>'转移用户货币到',

'LBL_CURRDEL'=>'将删除的货币',

'LBL_NEW_FORM_TITLE'=>'新增联系人',

'LBL_NEW_CURRENCY'=>'新增货币',

'LBL_VIEWING'=>'查看',

'LBL_CURRENCY_NAME'=>'货币名称',

'LBL_CURRENCY_CODE'=>'货币编码',

'LBL_CURRENCY_SYMBOL'=>'货币符号',

'LBL_CURRENCY_CRATE'=>'汇率',

'LBL_CURRENCY_STATUS'=>'状态',

'LBL_CURRENCY_TOOL'=>'工具',

'LBL_CURRENCY_LIST'=>'货币列表',
'LBL_PRINT_TEMPLATE'=>'打印模板定制',
'LBL_PRINT_TEMPLATE_DESCRIPTION'=>'定制单据打印和PDF导出模板',
'NTC_DELETE_CONFIRMATION'=>'您确定要删除这条记录？',

'LEADCUSTOMFIELDS'=>'潜在客户自定义字段',
'LBL_TEMPLATEPRINT_NAME'=>'模板名称',
'LBL_ISDEFAULT'=>'是否默认',
'LBL_TEMPLATEPRINT'=>'打印模板定制',
'LBL_TEMPLATEPRINT_LIST'=>'打印模板列表',
'LBL_TEMPLATE'=>'模板',
'LBL_NEW_TEMPLATE'=>'新增模板',
'ACCOUNTCUSTOMFIELDS'=>'客户自定义字段',

'CONTACTCUSTOMFIELDS'=>'联系人自定义字段',

'OPPORTUNITYCUSTOMFIELDS'=>'销售机会自定义字段',

'HELPDESKCUSTOMFIELDS'=>'服务单自定义字段',

'PRODUCTCUSTOMFIELDS'=>'产品自定义字段',

'VENDORCUSTOMFIELDS'=>'供应商自定义字段',

'PRICEBOOKCUSTOMFIELDS'=>'价格表自定义字段',

'POCUSTOMFIELDS'=>'采购订单自定义字段',
'SOCUSTOMFIELDS'=>'合同订单自定义字段',
'QUOTESCUSTOMFIELDS'=>'报价单自定义字段',
'INVOICECUSTOMFIELDS'=>'发票自定义字段',
'LBL_DATAINTERFACE_SETTING'=>'数据接口信息',
'LBL_SETTING_DATAINTERFACE_DEMOINFO'=>'设置数据接口账套信息',
'LBL_SOFT_FACTORY'=>'软件厂商',
'LBL_SOFT_VERSION'=>'软件版本',
'LBL_DEMO_NAME'=>'账套名称',
'LBL_SALSORDER_USING'=>'启用订单接口',
'LBL_CREDENCE_USING'=>'启用凭证接口',
'LBL_DATAINTERFAC_INFO'=>'数据接口信息',
'LBL_SETTING_DATAINTERFACE_DEMOINF'=>'设置数据接口账套信息',
'EDITLEADPICKLISTVALUES'=>'编辑潜在客户模块下拉框 ',
'LBL_K3'=>'K3系统',
'LBL_KIS_STANDARD'=>'KIS标准版',
'LBL_KIS_MINI'=>'KIS迷你版',
'LBL_KIS_MAJOR'=>"KIS专业版",
'EDITACCOUNTPICKLISTVALUES'=>'编辑客户模块下拉框 ',

'EDITCONTACTPICKLISTVALUES'=>'编辑联系人模块下拉框 ',

'EDITOPPORTUNITYPICKLISTVALUES'=>'编辑销售机会模块下拉框 ',

'EDITHELPDESKPICKLISTVALUES'=>'编辑服务单模块下拉框 ',

'EDITPRODUCTPICKLISTVALUES'=>'编辑产品模块下拉框',

'EDITEVENTPICKLISTVALUES'=>'编辑事件模块下拉框 ',

'EDITTASKPICKLISTVALUES'=>'编辑任务模块下拉框 ',

'EDITRSSPICKLISTVALUES'=>'编辑RSS模块下拉框',
'EDITVENDORPICKLISTVALUES'=>'编辑供应商模块下拉框',
'EDITPBPICKLISTVALUES'=>'编辑价格表模块下拉框',
'EDITPOPICKLISTVALUES'=>'编辑采购订单模块下拉框',
'EDITSOPICKLISTVALUES'=>'编辑合同订单模块下拉框',
'EDITQUOTEPICKLISTVALUES'=>'编辑报价单模块下拉框',
'EDITINVOICEPICKLISTVALUES'=>'编辑发票模块下拉框',


// Added for Release lingdangCRM 3.2 PATCH 1.0

//Settings/index.php


'LBL_PICKLIST_FIELD_SETTINGS'=>'下拉框字段设定：',


//SETTINGS/CustomFieldList.php,ComboFieldList.php,CreateCustomField.php

'Leads'=>'潜在客户',
'Status'=>'关闭',
'Activity Type'=>'类型',
'Subject'=>'标题',
'Date Sent' => '发送日期',
'Access Count' => '阅读次数',
'Related To'=>'收件人',
'Start Date & Time'=>'开始日期',
'Due Date'=>'结束日期',
'Recurrence'=>'重复类型',
'Activity Type '=>'主题',
'Accounts'=>'客户',
'Ticket No' => '服务单编号',
'Title'=>'主题',
'Priority'=>'优先级',
'Price Book Name'=>'价格表名称',
'Active'=>'启用',
'Quote No'=> '报价单号',
'Project Milestone Name'=>'里程碑名称',
'Project Milestone No'=>'里程碑编号',
'Total'=>'合计',
'PurchaseOrder No'=>'订单编号',
'Vendor Name'=>'供应商',
'SalesOrder No'=>'订单编号',
'Invoice No'=>'发票编号',
'Expense' =>'费用报销',
'Sales Order'=>'合同订单',
'Expected Revenue'=>'预期收益',
'Used Units'=>'使用单位',
'Project Task Name'=>'任务名称',
'Project Task No'=>'任务编号',
'Project Task Number'=>'任务数量',
'Project No'=>'项目编号',
'Due date' => '交付日期',
'PriceBook No'=>'价格表编号',
'Target Budget'=>'项目预算',
'Start Date'=>'开始日期',
'Approvestatus'=>'审批状态',
'Target End Date'=>'预计完成日期',
'Discount Amount'=>'折扣金额',
'Sub Total'=>'小计',
'Discount Percent'=>'折扣百分比',
'Approveby'=>'审批人',
'End Date'=>'结束日期',
'Actual End Date'=>'实际完成日期',
'Type'=>'类型',
'Project Name'=>'项目名称',
'PaymentPlan No'=>'回款计划编号',
'Note'=>'描述',
'Download Type'=>'下载类型',
'Version'=>'版本',
'File Type'=>'文件类型',
'File Size'=>'大小',
'Download Count'=>'下载次数',
'Document No'=>'文档编号', 
'periodtime'=>'期次',
'Documents'=>'知识管理',
'amount'=>'金额',
'CashBill'=>'收款单',
'subject'=>'主题',
'Mailing Country'=>'国家',
'Salutation'=>'称谓',
'Birthdate'=>'生日',
'Contact Id'=>'联系人编号',
'Department'=>'部门',
'Reference'=>'首要联系人',
'Email Opt Out'=>'拒绝邮件打扰',
'nextcontactdate'=>'下次回访日期',
'contactdate'=>'联系日期',
'content'=>'内容',
'creator'=>'创建人',
'createdtime'=>'创建时间',
'ProjectMilestone'=>'项目里程碑',
'plandate'=>'计划收款日期',
'SendPayment No'=>'付款计划编号',
'cpperiodtime'=>'期次',
'SendCashBill No'=>'付款单编号',
'cashbilldate'=>'付款日期',
'crpaymentmethod'=>'付款方式',
'criscashbill'=>'是否开票',
'office phone'=>'办公电话',
'File Name'=>'附件',
'paymentstatus'=>'状态',
'Contacts'=>'联系人',
'Related to'=>'收件人',
'Potentials'=>'销售机会',
'Calendar'=>'日程管理',
'HelpDesk'=>'服务单',
'Products'=>'产品',
'Faq'=>'常见问题',
'Events'=>'日程管理',
'Campaigns'=>'市场活动',
'Vendors'=>'供应商', 
'ServiceContracts'=>'服务合同',
'Services'=>'服务',
'Assets' => '资产',
'ProjectTask' => '项目任务',
'Project' => '项目',
'SMSNotifier' => 'SMS短信通知器',
'PaymentPlan'=>'回款计划',
'PriceBooks'=>'价格表', 
'Activities'=>'任务',
'ContactRecords'=>'联系记录',
'CustomFields'=>' 自定义字段',
'Potential Name'=> '销售机会',
'Sales Stage'=>'销售阶段',
'Mobile' =>'手机',
'NewCustomField'=>'新增自定义字段',

'NewCustomFieldAltC'=>'新增自定义字段 [Alt+c]：',

'FieldName'=>'字段名称',

'FieldType'=>'字段类型',

'FieldLabel'=>'字段标签',

'Delete'=>'删除',

'NEW'=>'新增',

'CUSTOMFIELD'=>'自定义字段',

'LBL_CUSTOM_FIELDS'=>'自定义字段',

'LBL_ADD_FIELD'=>'新增自定义字段',

'LBL_CUSTM_MSG'=>'允许您...',

'PicklistFields'=>' 下拉框',


'Edit'=>'编辑',

'LBL_EDIT_FIELD_TYPE'=>'编辑字段类型',

//Settings/CustomField.html

'LBL_PROVIDE_FIELD_INFORMATION'=>'提供字段信息： ',

'LBL_SELECT_FIELD_TYPE'=>'选择字段类型： ',

'LBL_PROVIDE_FIELD_DETAILS'=>'提供字段详细信息： ',

'LBL_LABEL'=>'标签： ',

'LBL_LENGTH'=>'长度： ',

'LBL_DECIMAL_PLACES'=>'小数点： ',

'LBL_PICK_LIST_VALUES'=>'下拉框列表值： ',



//Settings/EditComboField.php

'EditPickListValues'=>'编辑下拉框 ',



//Settings/EditField.html

'LBL_FIELD_INFORMATION'=>'字段信息：',

'Values'=>'值',

'EnterListOfValues'=>'请输入列表值。每个值占一行。',



//Settings/fieldtypes.php

'Text'=>'文本',

'Number'=>'数字',

'Percent'=>'百分比',

'Currency'=>'货币',

'Date'=>'日期',

'DateTime'=>'日期时间',

'Email'=>'Email',

'Phone'=>'电话',
'Account Name' => '客户名称',
'Billing City'=>'账单城市及区',
'Website' => '网站',
'PickList'=>'下拉框',
'Assigned To' => '负责人',
'LBL_MULTISELECT_COMBO'=>'多选框',

'Skype'=>'Skype网络电话',
'mobilephone'=>'手机',
'rfax'=>'传真',
'QQ'=>'QQ',

//added for patch2

'USERGROUPLIST'=>'部门',

'EMAILTEMPLATES'=>'Email模版',

'WORDINTEGRATION'=>'邮件合并模版',

'LBL_MAIL_MERGE'=>'邮件合并',

'NOTIFICATIONSCHEDULERS'=>'通知列表',
//currency status
'LBL_ACTIVE'=>'启用',

'LBL_INACTIVE'=>'停用',

'LBL_NOTIFICATION'=>'提醒',
'LBL_DESCRIPTION'=>'描述',
'LBL_TOOL'=>'工具',


//Added fields for Title Informations -- after 4 Beta

'LBL_EMAIL_CONFIG'=>'外寄邮件服务器配置',

'LBL_WORD_INTEGRATION'=>'集成WORD:',

'LBL_GROUP_SETTINGS'=>'部门设置:',

'LBL_TEMPLATE_SETTINGS'=>'模版设置:',

'LBL_NOTIFICATION_SETTINGS'=>'通知设置:',

'LBL_EMAIL_SETTINGS'=>'Email设置:',

'LBL_SECURITY_SETTINGS'=>'安全设置:',



//Added fields after RC1 - Release

'LBL_MAIL_SERVER_INFO'=>'邮件服务器信息',

'LBL_OUTGOING_MAIL_SERVER'=>'SMTP服务器信息',

'LBL_OUTGOING_MAIL_SERVER_LOGIN_USER_NAME'=>'外寄邮件服务器登录名',

'LBL_OUTGOING_MAIL_SERVER_PASSWORD'=>'外寄邮件服务器密码',

'LBL_MAIL_SERVER_SMTP'=>'邮件服务器设置(SMTP)',

'LBL_BACKUP_SERVER_CONFIG'=>'备份服务器配置',

'LBL_SERVER_ADDRESS'=>'服务器地址',

'LBL_FTP_SERVER_NAME'=>'FTP服务器名',

'LBL_FTP_USER_NAME'=>'FTP用户名',

'LBL_FTP_PASSWORD'=>'FTP密码',

'LBL_FTP'=>'FTP',

'LBL_SYSTEM_CONFIG'=>'系统配置',
'LBL_SYSTEM_INFO'=>'系统详细信息',
'LBL_PROXY_SETTINGS'=>'代理服务器',
'LBL_AUDIT_TRAIL'=>'操作日志',
'LBL_ENABLE_AUDIT_TRAIL'=>'启用操作日志',
'LBL_USER_AUDIT'=>'选择用户',
'LBL_VIEW_AUDIT_TRAIL'=>'查看操作日志',
'LBL_AUDIT_TRAIL_DESC'=>'查看用户的操作日志',
'LBL_NO_DATA'=>'没有数据',

'LBL_CURRENCY_CONFIGURATION'=>'- 货币信息',

'LBL_CURRENCY_CONFIG'=>'货币设置',

'LBL_CURRENCY_INFO'=>'货币信息',

'LBL_CURRENCY_TITLE'=>'汇率',

'LBL_CURRENCY_SETTINGS'=>'货币设定',


'LBL_USERNAME'=>'用户名',
'LBL_PASWRD'=>'密码',
'LBL_REQUIRES_AUTHENT'=>'需要验证？',
'LBL_FROM_EMAIL_FIELD'=>'发送邮件地址',

//Fields for Settings

'LBL_USER_MANAGEMENT'=>'用户管理',

'LBL_USERS'=>'用户',

'LBL_USERS_LIST'=>'用户列表',
'LBL_GROUP_LIST'=>'部门列表',

'LBL_CREATE_AND_MANAGE_USERS'=>'- 创建和管理用户 (例如，admin)',


'LBL_CREATE_AND_MANAGE_USER_ROLES'=>'- 创建和管理角色 (例如, Administrator, Standard User, etc.)',

'LBL_PROFILES'=>'权限',

'LBL_PROFILES_LIST'=>'权限列表',

'LBL_CREATE_AND_MANAGE_USER_PROFILES'=>'- 创建和管理用户权限(e.g., 总经理, 销售经理等.)',

'LBL_CREATE_AND_MANAGE_USER_GROUPS'=>'- 创建和管理部门',

'LBL_SHARING_ACCESS'=>'共享规则',

'LBL_FIELDS_ACCESS'=>'字段权限',

'LBL_DEFAULT_ORGANIZATION_FIELDS'=>'默认角色字段存取权限',

'LBL_SETTING_DEFAULT_ORGANIZATION_FIELDS'=>'设置角色的默认字段存取权限',

'LBL_SETTING_DEFAULT_SHARING_ACCESS'=>'- 设置角色的默认共享存取权限',

'LBL_FIELD_ACCESSIBILITY'=>'字段可访问性',

'LBL_SETTING_FIELD_ACCESSIBILITY'=>' - 为每个部门设置字段可访问性',
//<<<<<<<<for edit ordering blocks>>>>>>
'LBL_FIELD_ORDERING_DESC'=>' - 编辑字段顺序',

'LBL_FIELD_ORDERING'=>'编辑字段顺序',
//<<<<<<<<<<end>>>>>>>>>>>>>
'LBL_LEAD_FIELD_ACCESS'=>'潜在客户字段访问权限',

'LBL_ACCOUNT_FIELD_ACCESS'=>'客户字段访问权限',

'LBL_CONTACT_FIELD_ACCESS'=>'联系人字段访问权限',

'LBL_OPPORTUNITY_FIELD_ACCESS'=>'销售机会字段访问权限',

'LBL_HELPDESK_FIELD_ACCESS'=>'服务单字段访问权限',

'LBL_PRODUCT_FIELD_ACCESS'=>'产品字段访问权限',

'LBL_NOTE_FIELD_ACCESS'=>'备注字段访问权限',

'LBL_EMAIL_FIELD_ACCESS'=>'Email字段访问权限',

'LBL_TASK_FIELD_ACCESS'=>'任务字段访问权限',

'LBL_EVENT_FIELD_ACCESS'=>'事件字段访问权限',

'LBL_DELETE_DEMO_DATA'=>'删除测试数据',

'LBL_DELETE_DEMO_DATA_INFO'=>'- 删除在安装时所建立的测试数据',



'LBL_STUDIO'=>'系统定制',

'LBL_CUSTOM_FIELD_SETTINGS'=>'自定义字段设置',

'LBL_CREATE_AND_MANAGE_USER_DEFINED_FIELDS'=>'- 创建和管理用户定义的字段',

'LBL_SELECT_MODULE'=>'选择模块',

'LBL_SELECT_CF_TEXT'=>'<b>选择模块：</b>',



'LBL_PICKLIST_SETTINGS'=>'下拉框设置',

'LBL_EDIT_PICKLIST_VALUES'=>' - 编辑下拉框字段的值',

'LBL_EDIT'=>'编辑中',

'LBL_COMMUNICATION_TEMPLATES'=>'通讯模版',

'LBL_CREATE_EMAIL_TEMPLATES'=>' - 创建Email模版',

'LBL_UPLOAD_MSWORD_TEMPLATES'=>' - 上传MS Word模版供合并邮件使用',

'LBL_SCHEDULE_EMAIL_NOTIFICATION'=>' - Email通知列表',

'LBL_EXPAND_CLOSE_MENU'=>'展开/关闭选单',

'LBL_CONFIGURATION'=>'配置',

'LBL_CONFIGURE_MAIL_SERVER'=>' - 配置邮件服务器',

'LBL_BACKUP_SERVER_CONFIGURATION'=>'备份服务器配置',

'LBL_BACKUP_SERVER_INFO'=>'备份服务器信息',

'LBL_BACKUP_SERVER_SETTINGS'=>'备份服务器',

'LBL_CONFIGURE_BACKUP_SERVER'=>' - 配置备份服务器',

'LBL_SYSTEM_CONFIGURATION'=>' - 系统配置',

'LBL_PROXY_SERVER_CONFIGURATION'=>'代理服务器',

'LBL_PROXY_SERVER_INFO'=>'代理服务器信息',

'LBL_PROXY_SERVER_SETTINGS'=>'代理服务器设置',

'LBL_CONFIGURE_PROXY_SERVER'=>' - 配置代理服务器',

'LBL_PROXY_PORT'=>'端口',



//Field Types for custom fields

'LBL_URL'=>'网址',

'LBL_CHECK_BOX'=>'复选框',



//PickList Settings

'LBL_STANDARD_FIELDS'=>'标准字段',

'LBL_LEAD_SOURCE'=>'客户来源',

'LBL_SALUTATION'=>'称谓',

'LBL_LEAD_STATUS'=>'潜在客户状态',

'LBL_INDUSTRY'=>'行业',

'LBL_RATING'=>'评价',

'LBL_ACCOUNT_TYPE'=>'客户类型',

'LBL_BUSINESS_TYPE'=>'业务类型',

'LBL_CURRENCY_TYPE'=>'货币类型',

'LBL_SALES_STAGE'=>'销售阶段',

'LBL_PRIORITY'=>'优先级',

'LBL_STATUS'=>'状态',

'LBL_CATEGORY'=>'分类',

'LBL_MANUFACTURER'=>'供应商',

'LBL_PRODUCT_CATEGORY'=>'产品类别',

'LBL_RSS_CATEGORY'=>'Rss类别',

//Added for Web based Email client integration (post 4.0.1 release)

'LBL_ADD_MAIL_ACCOUNT'=>'新增邮件账号',
'LBL_NEW_MAIL_ACCOUNT_TITLE'=>'新增邮件账号 [Alt+M]',
'LBL_NEW_MAIL_ACCOUNT_KEY'=>'M',
'LBL_NEW_MAIL_ACCOUNT_LABEL'=>'新增邮件账号',
'LBL_GENERAL_INFO'=>'一般信息',
'LBL_DISPLAY_NAME'=>'显示名称',
'LBL_MAIL_PROTOCOL'=>'邮件协议',
'LBL_LIST_PASSWORD'=>'密码',
'LBL_MAIL_SERVER_NAME'=>'邮件服务器名称',
'LBL_MAIL_SERVER_SETTINGS'=>'邮件服务器',
'LBL_INCOME_SERVER_SETTINGS'=>'收件服务器',
'LBL_TEST_SETTINGS'=>'立即测试我的设置',
'LBL_TEST_BUTTON_TITLE'=>'测试我的设置！[Alt+T]',
'LBL_TEST_BUTTON_KEY'=>'T',
'LBL_TEST_BUTTON_LABEL'=>'测试我的设置！',
'LBL_DEFAULT'=>'默认',
'LBL_IMAP2'=>'IMAP2',
'LBL_IMAP4'=>'IMAP4',
'LBL_POP'=>'POP',
'LBL_IMAP'=>'IMAP',
'LBL_MAIL_DISCLAIM'=>'有 <font color="red">*</font> 符号表示必填，有 <font color="red">* *</font> 表示完全支持',
'LBL_SSL_OPTIONS'=>'SSL 选项',
'LBL_TLS'=>'TLS',
'LBL_NO_TLS'=>'No TLS',
'LBL_CERT_VAL'=>'验证证书',
'LBL_INT_MAILER'=>'使用内部邮件服务器？',
'LBL_INT_MAILER_USE'=>'是',
'LBL_INT_MAILER_NOUSE'=>'否',
'LBL_VAL_SSL_CERT'=>'验证 SSL 证书',
'LBL_DONOT_VAL_SSL_CERT'=>'不验证 SSL 证书',
'LBL_WEB_MAIL_CONFIG'=>'WebMail配置',
'LBL_CONFIGURE_WEB_MAIL'=>' - 配置网页邮件',
'LBL_LIST_MAIL_ACCOUNT'=>'邮件账号列表',
'LBL_USAGEUNIT'=>'使用单位',
'LBL_GLACCT'=>'会计科目',
'LBL_QUOTE_STAGE'=>'报价单阶段',
'LBL_CARRIER'=>'物流公司',
'LBL_TAXCLASS'=>'税别',
'LBL_MY_DETAILS'=>'我的详细信息',
'LBL_MY_MAIL_SERVER_DET'=>'我的接收邮件服务器信息',
'LBL_EMAIL_ID'=>'Email ID',
'LBL_NAME_EXAMPLE'=>'（例如： John Fenner）',
'LBL_EMAIL_EXAMPLE'=>'（例如： johnfenner@mailserver.com）',
'LBL_REFRESH_TIMEOUT'=>'刷新频率',
'LBL_1_MIN'=>'1 分钟',
'LBL_2_MIN'=>'2 分钟',
'LBL_3_MIN'=>'3 分钟',
'LBL_4_MIN'=>'4 分钟',
'LBL_5_MIN'=>'5 分钟',
'LBL_EMAILS_PER_PAGE'=>'每页显示邮件数量',

//Added for Organization Details (4.2 release)
'LBL_ORGANIZATION_NAME'=>'公司名称',
'LBL_ORGANIZATION_ADDRESS'=>'地址',
'LBL_ORGANIZATION_CITY'=>'城市',
'LBL_ORGANIZATION_STATE'=>'省份',
'LBL_ORGANIZATION_CODE'=>'邮政编码',
'LBL_ORGANIZATION_COUNTRY'=>'国家',
'LBL_ORGANIZATION_PHONE'=>'电话',
'LBL_ORGANIZATION_FAX'=>'传真',
'LBL_ORGANIZATION_WEBSITE'=>'网站',
'LBL_ORGANIZATION_DETAILS'=>'公司信息',
'LBL_SPECIFY_COMPANY_DETAILS'=>' - 指定公司信息',
'LBL_ORGANIZATION_LOGO'=>'Logo 名称',
'LBL_UPLOAD'=>'上传文件',
'LBL_FILENAME'=>'文件名称',
'LBL_SETTINGS'=>'控制面板',
'LBL_COMPANY_DETAILS'=>'公司信息',

'LBL_SEVERITY'=>'严重程度',
'LBL_FAQ_CATEGORY'=>'常见问答类别',
'LBL_VENDOR_FIELD_ACCESS'=>'供应商字段访问权限',
'LBL_PB_FIELD_ACCESS'=>'价格表字段访问权限',
'LBL_QUOTE_FIELD_ACCESS'=>'报价单字段访问权限',
'LBL_PO_FIELD_ACCESS'=>'采购订单字段访问权限',
'LBL_SO_FIELD_ACCESS'=>'合同订单字段访问权限',
'LBL_INVOICE_FIELD_ACCESS'=>'发票字段访问权限',
'INVENTORYNOTIFICATION'=>'库存提醒',
'LBL_INVENTORY_NOTIFICATIONS'=>'编辑库存Email通知',
'INVENTORYTERMSANDCONDITIONS'=>'条款和条件',//newly added for Inventory terms and conditions// by lingdang
'LBL_INVENTORY_TERMSANDCONDITIONS'=>' - 编辑条款和条件',//newly added //by lingdang
'LBL_TANDC_TEXT'=>'条款和条件文本',
'LBL_INVENTORY_TANDC'=>'库存条款',

'LBL_OTHER_SETTINGS'=>'其它设置',
'LBL_SCROLL'=>'[回到顶部]',

'LBL_INV_NOT_DESC'=>'下面是提醒通知的列表，用来在手动建立报价单、合同订单与发票时发送给产品负责人，包括需求和目前数量等信息．',

'InvoiceNotification'=>'在建立发票时提醒产品库存',
'InvoiceNotificationDescription'=>'当产品库存低于安全存量时，提醒通知会发送给库存负责人',
'Vendor'=>'供应商',
'PriceBook'=>'价格表',
'Quotes'=>'报价单',
'PurchaseOrder'=>'采购订单',
'SalesOrder'=>'合同订单',
'Invoice'=>'发票',

//For Custom Fields
'LBL_LEAD_MAP_CUSTOM_FIELD'=>'映射潜在客户自定义字段',
'leadCustomFieldDescription'=>'将您的组织潜在客户字段映射到公司、联系人或潜在客户字段，在转换潜在客户时会使用到这些对应信息。',

'LBL_MAPPING_INFO'=>'映射信息',
'LBL_ACCOUNT_FIELD'=>'客户字段',
'LBL_CONTACT_FIELD'=>'联系人字段',
'LBL_POTENTIAL_FIELD'=>'销售机会字段',
'CUSTOMFIELDMAPPING'=>'自定义字段映射',
'LBL_FIELD_MAPPING'=>'字段映射',
'LBL_LEAD_FIELD'=>'潜在客户自定义字段',
//After 4.2 GA
'LBL_TEXT_AREA'=>'文本区域',
//for Edit ordering the blocks
'NOTESCUSTOMFIELDS'=>'自定义备注字段',

//Added fields after 4.2 ptach 2
'LBL_ASSIGN_MODULE_OWNERS'=>'模块负责人',
'LBL_MODULE_OWNERS'=>'模块负责人',
'LBL_ASSIGN_MODULE_OWNERS_INFO'=>' - 为每个模块指定负责人',
'LBL_MODULE'=>'模块',
'LBL_OWNER'=>'模块负责人',
'LBL_MIGRATION'=>'升级向导',
'LBL_MIGRATION_INFO'=>' - 版本升级',

//Added for 5 GA - Description of Settings UI

'LBL_USER_DESCRIPTION'=>'管理访问系统的用户',
'LBL_ROLE_DESCRIPTION'=>'定义角色层级关系并为角色设定权限',
'LBL_PROFILE_DESCRIPTION'=>'定义每个角色存取数据的权限',//by lingdang
'LBL_GROUP_DESCRIPTION'=>'管理公司内部不同的部门',
'LBL_SHARING_ACCESS_DESCRIPTION'=>'管理模块共享规则和自定义共享规则',
'LBL_SHARING_FIELDS_DESCRIPTION'=>'定义每个模块的全局字段访问权限',
'LBL_MODULE_OWNERS_DESCRIPTION'=>'为每个模块指定客户服务负责人',
'LBL_ANNOUNCEMENT_DESCRIPTION'=>'管理显示在所有页面上方的滚动公告',
'LBL_CUSTOM_FIELDS_DESCRIPTION'=>'管理不同类型的自定义字段',
'LBL_PICKLIST_DESCRIPTION'=>'定制每个模块的下拉框选项',
'LBL_EMAIL_TEMPLATE_DESCRIPTION'=>'管理Email模块的模版',
'LBL_MAIL_MERGE_DESCRIPTION'=>'管理合并邮件使用的模版',
'LBL_NOTIF_SCHED_DESCRIPTION'=>'管理重要操作的警告信息',
'LBL_INV_NOTIF_DESCRIPTION'=>'修改库存相关提醒通知的设置',
'LBL_INV_TANDC_DESCRIPTION'=>'指定报价单、发票、订单的条款和条件',
'LBL_COMPANY_DESCRIPTION'=>'公司的详细信息与联系方式',
'LBL_MAIL_SERVER_DESCRIPTION'=>'配置邮件服务器信息',
'LBL_BACKUP_SERVER_DESCRIPTION'=>'配置数据库备份服务器',
'LBL_CURRENCY_DESCRIPTION'=>'管理货币与汇率',
'LBL_TAX_DESCRIPTION'=>'管理不同类型的税和税率',
'LBL_SYSTEM_DESCRIPTION'=>'显示系统设置',
'LBL_PROXY_DESCRIPTION'=>'配置读取RSS新闻的代理服务器',
'LBL_AUDIT_DESCRIPTION'=>'显示用户执行的数据操作',
'LBL_TAX_DESC'=>'管理不同类型的税和税率',
'LBL_COMPANY_DESC'=>'公司的详细信息与联系方式',
'LBL_SELECT_LOGO'=>'选择新Logo:',
'LBL_INVEN_TANDC_DESC'=>'指定库存模块（报价单、订单和发票）的条款和条件',
'LBL_MAIL_SERVER_DESC'=>'配置邮件服务器信息',
'LBL_BACKUP_SERVER_DESC'=>'配置备份服务器信息',
'LBL_MODULES_AND_OWNERS'=>'模块和模块负责人',
'LBL_GROUP_DESC'=>'管理基于角色、用户和部门的不同类型的组织',
'LBL_MAIL_MERGE_DESC'=>'管理各模块中使用的邮件合并模版',


//Added fields after 5.0 Alpha
'LBL_REQUIRE_SMTP_AUTHENTICATION'=>'需要SMTP认证?',
'LBL_ANNOUNCEMENT'=>'系统公告',
'LBL_SETTING_ANNOUNCEMENT'=>'公告',
'LBL_ANNOUNCE_TEXT'=>'公告信息',
'LBL_UPDATE_BUTTON'=>'更新',
'LBL_ANNOUNCEMENT_INFO'=>'在下面输入公告内容，然后点击【更新】按钮。',
'LBL_ANNOUNCEMENT_DESC'=>'显示在所有页面上方的滚动公告信息',
'LBL_EMAIL_CONTENTS'=>'Email内容',
'LBL_SUBJECT'=>'标题',
'LBL_MESSAGE'=>'内容',
'LBL_PICKLIST_EDITOR'=>'下拉框编辑',
'LBL_PICKLIST_AVAIL'=>'下拉框-',
'LBL_PICKLIST_AVAILINFO1'=>'下拉框-',
'LBL_PICKLIST_AVAILINFO2'=>'显示如下。点击编辑按钮修改列表内容。',
'LBL_EDIT_PICKLIST'=>'编辑下拉框列表',
'LBL_PICKLIST_SAVEINFO'=>'每行输入一个选项，然后点击“保存”按钮进行保存。',
'LBL_SELECT_CRM_MODULE'=>'选择 CRM 模块',
'LBL_TAX_SETTINGS'=>'税率设定',
'LBL_INVENTORY_TAX_CONFIG'=>'库存税率设定',
'LBL_CUSTOM_MAPP_INFO'=>'只有潜在客户的字段能和客户，联系人，销售机会的字段映射。',
'LBL_MAPPING_OTHER_MODULES'=>'和其它模块映射',
'LBL_CUSTOM_FILED_IN'=>'自定义字段在',
'LBL_ROLE_HIERARCHY_TREE'=>'组织结构-角色列表',
//'LBL_ROLE_HIERARCHY_TREE'=>'角色与层次关系',
'LBL_EDIT_FIELD_MAPPING'=>'编辑字段映射',
'LBL_LOGIN_HISTORY_DETAILS'=>'登录日志',
'LBL_LOGIN_HISTORY_DESCRIPTION'=>'显示用户登录历史',
'LBL_NON_EDITABLE_PICKLIST_ENTRIES'=>'没有可编辑的下拉框',

//Added for Tax settings
'LBL_PRODUCT_TAX_SETTINGS'=>'产品与服务税 ',
'LBL_SHIPPING_HANDLING_TAX_SETTINGS'=>'运费和物流附加费税 ',
'LBL_PROXY_SERVER_DESC'=>'配置读取RSS新闻的代理服务器',

'LBL_NEW_CURRENCTY'=>'新增货币',
'LBL_BASE_CURRENCY'=>'基本货币 - ',
'LBL_DELETE_CURRENCY'=>'删除货币',

//Added for singlepane view in modules 

'LBL_DEFAULT_DETAIL_VIEW'=>'页面布局方式',
//by LD tifa 20121210
//'LBL_DEFAULT_MODULE_VIEW'=>'默认模块视图',
'LBL_DEFAULT_MODULE_VIEW'=>'页面布局方式',
'LBL_DEFAULT_MODULE_VIEW_DESC'=>'设置相关模块显示样式',
'LBL_ENABLE_SINGLEPANE_VIEW'=>'相关模块(更多信息) 显示样式',

'LBL_CLEAR_DATA'=>'清除数据',
'LBL_ENABLE'=>'启用',
'LBL_FAQ_FIELD_ACCESS'=>'常见问答字段访问权限',
'LBL_ADD_TAX_BUTTON'=>'新增税额',
'LBL_NO_TAXES_AVAILABLE'=>'无税',
'LBL_PLEASE'=>'请',
'LBL_LENGTHALERT'=>'抱歉，您不能够映射不同字符长度的字段，请修正。',//5.3.0之前
'LBL_DECIMALALERT'=>'抱歉，您不能够映射不同位数的数字，请修正。',//5.3.0之前
'LBL_TYPEALERT_1'=>'抱歉，您不能映射',//5.3.0之前
'LBL_WITH'=>'于',//5.3.0之前
'LBL_TYPEALERT_2'=>'数据类型，请修正。',//5.3.0之前
//Added while moving role file from User to Setting Module
'LBL_ROLES'=>'角色',
'LBL_CREATE_NEW_ROLE'=>'新增角色',
'LBL_PROPERTIES'=>'角色',
'LBL_DEPARTMENT'=>'部门',//by LD  can 20121203 增加部门翻译
'LBL_NEW_ROLE'=>'新增角色',
'LBL_ROLE_NAME'=>'角色名称',
'LBL_REPORTS_TO'=>'上级角色',
'LBL_DESCRIPTION'=>'描述',
'LBL_PROFILE_M'=>'权限',
'LBL_PROFILES_AVLBL'=>'可用权限名称',
'LBL_ASSIGN_PROFILES'=>'指定的权限名称',
'LBL_MEMBER'=>'成员',
'LBL_DELETE_ROLE'=>'删除角色',
'LBL_ROLE_TO_BE_DELETED'=>'要删除的角色',
'LBL_TRANSFER_USER_ROLE'=>'为相关用户分配新角色',
'LBL_ASSOCIATED_PROFILES'=>'相关权限名称：',
'LBL_ASSOCIATED_USERS'=>'相关用户：',
//Added while moving email templates from Users to Settings
'LBL_EMAIL_TEMPLATES'=>'Email模版',
'LBL_EMAIL_TEMPLATE_DESC'=>'管理营销活动和群发邮件的Email模版',
'LBL_LIST_SELECT'=>'选择',
'LBL_EMAIL_TEMPLATE'=>'Email模版',
'LBL_TEMPLATE_TOOLS'=>'工具',
'LBL_NEW_TEMPLATE'=>'新增模版',
'LBL_FOLDER'=>'文件夹',
'LBL_NAME'=>'名称',
'LBL_PERSONAL'=>'个人',
'LBL_PUBLIC'=>'公开',
'Personal'=>'个人',
'Public'=>'公开',
'LBL_ACCOUNT_FIELDS'=>'客户字段',
'LBL_CONTACT_FIELDS'=>'联系人字段',
'LBL_LEAD_FIELDS'=>'潜在客户字段',
'LBL_USER_FIELDS'=>'用户字段',
'LNK_SAMPLE_EMAIL'=>'查看示例邮件',
//Added while moving Mail Merge templates from Users to Settings
'LBL_TEMPLATE_FILE'=>'模版文件',
'LBL_MODULENAMES'=>'模块',
'LBL_DOWNLOAD'=>'下载',
'LBL_ADD_TEMPLATE'=>'新增模版',
'LBL_WORD_TEMPLATES'=>'邮件合并模版',
//Added while moving Notification Schedulers from Users to Settings
'LBL_TASK_NOTIFICATION'=>'任务延迟提醒',
'LBL_BIG_DEAL'=>'重大交易提醒',
'LBL_PENDING_TICKETS'=>'等待中的服务单提醒',
'LBL_MANY_TICKETS'=>'当有太多的服务单时，发送提醒',
  'LBL_START_NOTIFICATION'=>'服务开始提醒',
'LBL_ACTIVITY_NOTIFICATION'=>'日程提醒',
 'LBL_SUPPORT_NOTICIATION'=>'服务结束提醒',//5.3.0之前
'LBL_SUPPORT_NOTICIATION_MONTH'=>'提前一个月提醒服务结束' ,//5.3.0之前

'LBL_TASK_NOTIFICATION_DESCRITPION'=>'当一个任务延迟超过 24 小时提醒',
  'LBL_BIG_DEAL_DESCRIPTION'=>'当高额订单成交时提醒',
'LBL_TICKETS_DESCRIPTION'=>'提醒注意等待处理的服务单',
  'LBL_MANY_TICKETS_DESCRIPTION'=>'当同一个人或部门接手太多服务单时发出提醒',
 'LBL_START_DESCRIPTION'=>'在服务支持开始时提醒',
'LBL_ACTIVITY_REMINDER_DESCRIPTION'=>'在日程活动开始前，按设定的时间发出提醒',
'LBL_SUPPORT_DESCRIPTION'=>'在支持或服务快结束时提醒',//5.3.0之前
'LBL_SUPPORT_DESCRIPTION_MONTH'=>'在支持或服务快结束时(提前一个月)提醒',//5.3.0之前
//Added while moving Inventory Notifications from Users to Settings
'QuoteNotificationDescription'=>'在报价单产生时，如果仓库中的产品库存低于报价单中提到的数量，这个提醒通知就会发出给相关人员',
'SalesOrderNotificationDescription'=>'在销售单产生时，如果仓库中的产品库存低于销售单中提到的数量，这个提醒通知就会发出给相关人员',
'Tools'=>'工具',
'QuoteNotification'=>'在报价单产生时发出产品库存提醒',
'SalesOrderNotification'=>'在合同订单产生时发出产品库存提醒',
'LBL_NOTE_DO_NOT_REMOVE_INFO'=>'注意：不要删除或替换大括号 ｛｝ 中的数值',

//Added while moving Profile file from User to Setting Module
'LBL_TOTAL'=>'总计：',
'LBL_NEW_PROFILE'=>'新增权限名称',
'LBL_LIST_NO'=>'#',
'LBL_NEW_PROFILE_NAME'=>'权限名称',
'LBL_LIST_TOOLS'=>'工具',
'LBL_PROFILE_MESG'=>'查看访问权限于',
'LBL_PROFILE_PRIVILEGES'=>'权限',
'LBL_DEFINE_PRIV_FOR'=>'定义权限于',
'LBL_USE_OPTION_TO_SET_PRIV'=>'使用下面选项设定权限',
'LBL_SUPER_USER_PRIV'=>'全局权限',
'LBL_SET_PRIV_FOR_EACH_MODULE'=>'设定每个模块的权限',
'LBL_FIELDS_AND_TOOLS_SETTINGS'=>'字段与工具设定',
'LBL_VIEW_ALL'=>'查看全部',
'LBL_EDIT_ALL'=>'编辑全部',
'LBL_ALLOW'=>'允许',
'LBL_MESG_VIEW'=>'查看所有模块和信息',
'LBL_MESG_EDIT'=>'编辑所有模块和信息',
'LBL_TAB_MESG_OPTION'=>'可显示的模块',
'LBL_CREATE_EDIT'=>'创建/编辑',
//divide create/edit button
'LBL_CREATE'=>'创建',
'LBL_EDIT'=>'编辑',
'LBL_VIEW'=>'查看',
'LBL_MANDATORY_MSG'=>'必填字段',
'LBL_DISABLE_FIELD_MSG'=>'这个字段在全局字段权限设定中被停用了',
'LBL_DELETE'=>'删除',

'LBL_STEP_2_2'=>'步骤2 of 2',
'LBL_FINISH_BUTTON'=>'完成',

//Added while moving Groups file from User to Setting Module
'LBL_NEW_GROUP'=>'新增部门',
'LBL_GROUPS'=>'部门',
'LBL_GROUP_NAME'=>'部门名称',
'LBL_ROLES_SUBORDINATES'=>'角色和下级角色',
'LBL_MEMBER_AVLBL'=>'可用成员',
'LBL_MEMBER_SELECTED'=>'选择的成员',
  'LBL_ENTITY'=>'类型',
'LBL_OF'=>'之',
'LBL_CREATE_NEW_GROUP'=>'新增部门',
'LBL_ADD_GROUP_BUTTON'=>'新增部门',
'LBL_GROUP_MESG1'=>'可以通过部门来定义复杂的权限机制。一个部门可以包含角色、用户、权限等。',
'LBL_GROUP_MESG2'=>'要新增时，选择左边的成员后点击 "》" 按钮',
'LBL_GROUP_MESG3'=>'要移除时，选择右边的成员后点击 "《" 按钮',

//Sharing Privileges
'LBL_GLOBAL_ACCESS_PRIVILEGES'=>'全局共享规则',
'LBL_RECALCULATE_BUTTON'=>'重新计算',
'LBL_CHANGE'=>'修改',
'LBL_PRIVILEGES'=>'规则',
'LBL_CUSTOM_ACCESS_PRIVILEGES'=>'自定义共享规则',
/**
更新操作
edit:cdw
date:20131118
reason:	0005646: 控制面板->共享规则->自定义共享规则中，“客户和联系人”后面的按钮名称不正确，应该显示为“增加 规则”，如图。
**/
//'LBL_ADD_PRIVILEGES_BUTTON'=>'新增 共享规则',
'LBL_ADD_PRIVILEGES_BUTTON'=>'增加 规则',
'LBL_RULE_NO'=>'规则编号',
'LBL_CAN_BE_ACCESSED'=>'可以存取者',
'LBL_CUSTOM_ACCESS_MESG'=>'没有自定义共享规则。',
'LNK_CLICK_HERE'=>'点击这里',
'LBL_CREATE_RULE_MESG'=>'建立新规则',
'LBL_RECALC_MSG'=>'您确定要重新计算共享规则？',
'LBL_YES'=>'是',
'LBL_NO'=>'否',
'LBL_IN_PERMISSION'=>'在规则',
'LBL_RELATED_MODULE_RIGHTS'=>'相关模块权限',
'LBL_USR_CAN_ACCESS'=>'用户可以',
'LBL_USR_OTHERS'=>'其它用户',
'LBL_USR_CANNOT_ACCESS'=>'用户无法访问其它账号',

'LBL_ORG_SHARING_PRIVILEGES'=>'角色享有之特别权限',
'LBL_EDIT_PERMISSIONS'=>'编辑规则',
'LBL_SAVE_PERMISSIONS'=>'储存规则',
'LBL_READ_ONLY'=>'公开：只读',
'LBL_EDIT_CREATE_ONLY'=>'公开： 读取, 编辑',
'LBL_READ_CREATE_EDIT_DEL'=>'公开： 读取, 编辑, 删除',
'LBL_PRIVATE'=>'私有',

'Public: Read Only'=>'公开：只读',
    
'Public: Read, Create/Edit'=>'公开：读取、编辑',
    
'Public: Read, Create/Edit, Delete'=>'公开：读取、编辑、删除',
    
'Private'=>'私有',
'Hide Details'=>'隐藏详细信息',
'Hide Details and Add Events'=>'隐藏详细信息并添加事件',
'Show Details'=>'显示详细信息',
'Show Details and Add Events'=>'显示详细信息并添加事件',
'ALL_BODY'=>'所有人',
'share_for'=>'共享给',
//Added for User Login History While moving from User to Settings
'LBL_LOGIN_HISTORY'=>'登入记录',
//Sharing Access module moved to Setting
'Read/Write'=>'读取/写入',
'Read Only '=>'只读',
'LBL_GROUP'=>'部门',
'LBL_ACCESS_RIGHTS_FOR_MODULES'=>'相关模块访问规则',
'LBL_ADD_RULE'=>'新增规则',
'LBL_EDIT_RULE'=>'保存规则',
'LBL_ADD_CUSTOM_RULE'=>'新增自定义共享规则',
'LBL_RULE_CONSTRUCTION'=>'共享规则说明',
'LBL_STEP'=>'步骤',
'LBL_SELECT_ENTITY'=>'从下面选择一个角色',
'LBL_CAN_BE_ACCESSED_BY'=>'可以存取者',
'LBL_PERMISSIONS'=>'权限',
'LBL_DOC_MSWORD'=>'档案必须是 doc/word 格式',
'LBL_NODOC'=>'文件夹中没有文件，请重试！',

//Added for error messages on Company Info.
'LOGO_ERROR'=>'Logo只能使用 jpg/jpeg/png格式',
'Error_Message'=>'错误信息',
'Invalid_file'=>'无效文件或',
'File_has_no_data'=>'文件没有数据',
'Sorry'=>'抱歉',
'uploaded_file_exceeds_maximum_limit'=>'上传文件的大小超过最大限制',
'try_file_smaller'=>'请尝试一个小于800KB的文件',
'Problems_in_upload'=>'上传出现问题',
'Please_try_again'=>'请重试!',
//5.0.3 fixes
'LBL_TESTMAILSTATUS'=>'测试邮件状态 : ',
'LBL_CHECK_ASSIGNEDTO_MAILID'=>'请检查指派的邮件ID',
'LBL_MAILSENDERROR'=>'电子邮件不能被发送到管理员用户。请检查管理员邮件帐号 /服务器设置',
'LBL_RECORD_NOEXIST'=>'记录不存在',
'LBL_ENTER_PROFILE'=>'输入权限名',
'LBL_ENABLE'=>'开启',
'LBL_DISABLE'=>'关闭',
'LBL_PROXY'=>'代理',
'LBL_FIELDS_TO_BE_SHOWN'=>'可显示的字段',
//Added for alerts
'SPECIFY_FILE_TO_MERGE'=>'请注明文件合并',
'FILESIZE_EXCEEDS_INFO_CONFIG_INC'=>'对不起，上传的文件超过了在config.inc.php 设置的最大文件大小限制。请尽量为较小的文件',
'FILESIZE_EXCEEDS_INFO_PHP_INI'=>'对不起，上传的文件超过了在php.ini设置的最大文件大小限制。请尽量为较小的文件',
'PROBLEMS_IN_FILEUPLOAD'=>'上传出现问题，请重试！',

//Added fields for Invoice Number labels
'LBL_CUSTOMIZE_INVOICE_NUMBER'=>'自定义发票编号',
'LBL_CUSTOMIZE_INVOICE_NUMBER_DESCRIPTION'=>'定制发票编号',
'LBL_CUSTOM_INVOICE_NUMBER_VIEW'=>'发票编号定制',
'LBL_CUSTOMINVOICE_STRING'=>'自定义发票字符串',
'LBL_CUSTOMINVOICE_NUMBER'=>'自定义发票编号',
'LBL_INVOICE_NUMBER_PREVIEW'=>'预览',
'LBL_INVOICE_NUMBER_BUTTON'=>'更新发票编号',
'LBL_PROXY_AUTHENTICATION_REQUIRED'=>'代理服务器要求身份认证',
'LBL_ENABLE_FTP'=>'你一定要开通PHP中的FTP支持功能，',

//Added for Role Labels
'LBL_ADD_ROLE'=>'添加下级角色',
'LBL_EDIT_ROLE'=>'编辑角色',
'LBL_MOVE_ROLE'=>'移动角色',
'LBL_COPY_ROLE'=>'复制角色',
'LBL_User_Role'=>'关联用户',
'LBL_Role_Copy'=>'复制',
'LBL_BACKUP_DESC'=>' CRM系统允许你在FTP服务器上作一个备份的数据库。每当一个管理员用户登录，客户关系管理将采取备份所有的数据。要确定你的FTP服务器有足够的磁盘空间。创建备份文件的格式为: "backup-date-time.sql".',

// Added/Updated for WebCider CRM 5.0.4
'LBL_SUPPORT_NOTICIATION'=>'服务结束前一周提醒',
'LBL_SUPPORT_NOTICIATION_MONTH'=>'服务结束前一个月提醒',
'LBL_SUPPORT_DESCRIPTION'=>'服务支持即将结束时，提前一个星期通知！',
'LBL_SUPPORT_DESCRIPTION_MONTH'=>'服务支持即将结束时，提前一个月通知！',
'LBL_SELECT_ROLE'=>'选择角色',
'LBL_TEMPLATE'=>'模板',
'LBL_SELECT_EMAIL_TEMPLATE_FOR'=>'选择Email模板',

'ERR_CUSTOM_FIELD_WITH_NAME'=>'自定义字段的名称 ',
'ERR_ALREADY_EXISTS'=>' 已存在.',
'ERR_SPECIFY_DIFFERENT_LABEL'=>'请指定一个不同的标签',
'LBL_TOOLS_TO_BE_SHOWN'=>'可显示的工具',
'LBL_PICKLIST_GLOBAL_CHANGE'=>'全局改变',
'LBL_PICKLIST_TRANSFER'=>'转移值 ',
'LBL_REPLACE_VALUE_WITH'=>'替换值 ',
'LBL_EDIT_CUSTOM_RULE'=>'编辑自定义权限规则',

/*for global add/delete in picklist*/
'DELETE_PICKLIST_VALUES'=>'删除下拉框选项',
'EDIT_PICKLIST_VALUE'=>'编辑下拉框选项',
'ADD_PICKLIST_VALUES'=>'添加下拉框选项',
'LBL_PICKLIST_ADDINFO'=>'键入新的条目，每行一个',
'LBL_SELECT_ROLES'=>'选择还需要加上项目的角色',
'LBL_EXISTING_PICKLIST_VALUES'=>'现有的下拉框选项',
'LBL_SELECT_PICKLIST'=>'选择下拉框选项',

// Added after 5.0.4 GA

'LBL_GENERAL_FIELDS'=>'普通字段',

'LBL_CANCEL_BUTTON'=>'取消',

//Added fields for Inventory Number labels
'LBL_CUSTOMIZE_INVENTORY_NUMBER'=>'自定义编号',
'LBL_CUSTOMIZE_INVENTORY_NUMBER_DESCRIPTION'=>'定制库存编号',
'LBL_CUSTOM_QUOTE_NUMBER_VIEW'=>'报价单编号定制',
'LBL_CUSTOMQUOTE_STRING'=>'自定义报价单字符串',
'LBL_CUSTOMQUOTE_NUMBER'=>'自定义报价单编号',
'LBL_QUOTE_NUMBER_PREVIEW'=>'预览',
'LBL_QUOTE_NUMBER_BUTTON'=>'更新报价单编号',
'LBL_CUSTOM_SO_NUMBER_VIEW'=>'合同订单编号定制',
'LBL_CUSTOMSO_STRING'=>'自定义合同订单字符串',
'LBL_CUSTOMSO_NUMBER'=>'自定义合同订单编号',
'LBL_SO_NUMBER_PREVIEW'=>'预览',
'LBL_SO_NUMBER_BUTTON'=>'更新合同订单编号',
'LBL_CUSTOM_PO_NUMBER_VIEW'=>'采购订单编号定制',
'LBL_CUSTOMPO_STRING'=>'自定义采购订单字符串',
'LBL_CUSTOMPO_NUMBER'=>'自定义采购订单编号',
'LBL_PO_NUMBER_PREVIEW'=>'预览',
'LBL_PO_NUMBER_BUTTON'=>'更新采购订单编号',

// Added after 5.0.4 GA

// Added for Multi-Currency Support
'LBL_TRANSFER_CURRENCY'=>'转换货币',
'LBL_CURRENT_CURRENCY'=>'当前货币',

//Added for new backup labels
'LBL_LOCAL'=>'本地',
'LBL_BACKUP'=>'备份',
'LBL_BACKUP_LOCATION'=>'备份路径',

'LBL_LAYOUT_EDITOR'=>'页面设置',
'LBL_LAYOUT_EDITOR_DESCRIPTION'=>'设计和修改各个模块的布局',
'LBL_Show'=>'显示',
'LBL_Hide'=>'隐藏',

// vtlib customization: Language Stings
'VTLIB_LBL_MODULE_MANAGER'=>'模块管理',
'VTLIB_LBL_MODULE_MANAGER_DESCRIPTION'=>'管理系统模块以及为模块定义新字段',
'VTLIB_LBL_MODULE_MANAGER_CUSTOMMOD'=>'定制模块',
'VTLIB_LBL_MODULE_MANAGER_STANDARDMOD'=>'标准模块',
'VTLIB_LBL_MODULE_MANAGER_NOMODULES'=>'没有发现定制模块! 创建一个块导入一个新模块 ...',

// vtmailscanner START
'LBL_MAIL_SCANNER'=>'邮件扫描',
'LBL_MAIL_SCANNER_DESCRIPTION'=>'配置邮箱扫描',
'LBL_SCAN_NOW'=>'现在扫描',
'LBL_RULE'=>'规则',
'LBL_SETUP'=>'安装',
'LBL_CONFIGURE'=>'设置',
'LBL_MAILBOX'=>'邮箱',
'LBL_INFORMATION'=>'信息',
'LBL_SCANNER'=>'扫描器',
'LBL_SERVER'=>'服务器',
'LBL_PROTOCOL'=>'协议',
'LBL_PASSWORD'=>'密码',
'LBL_TYPE'=>'类型',
'LBL_SSL'=>'SSL',
'LBL_METHOD'=>'方法',
'LBL_VAL_SSL_CERT'=>'验证 SSL 证书',
'LBL_DONOT_VAL_SSL_CERT'=>'不验证 SSL 证书',
'LBL_STATUS'=>'状态',
'LBL_ENABLE'=>'打开',
'LBL_DISABLE'=>'关闭',
'LBL_CONNECT'=>'链接',
'LBL_URL_CAPS'=>'URL',
'LBL_ENABLED'=>'允许',
'LBL_DISABLED'=>'禁止',
'LBL_RULES'=>'规则',
'LBL_FOR'=>'-',

'LBL_FROM'=>'发件人',
'LBL_TO'=>'收件人',

'LBL_ACTION'=>'激活',
'LBL_CREATE'=>'创建',
'LBL_TICKET'=>'票务',
'LBL_ADD'=>'新增',

'LBL_CONTACT'=>'联系',
'LBL_ACCOUNT'=>'帐户',

'LBL_FROM_CAPS'=>'FROM',
'LBL_TO_CAPS'=>'TO',
'LBL_TO_SMALL'=>'to',

'LBL_CONTAINS'=>'包含',
'LBL_EQUALS'=>'等于',

'LBL_BEGINS'=>'开始',

'LBL_REGEX'=>'正则表达式',
'LBL_ENDS'=>'Ends',
'LBL_BODY'=>'Body',

'LBL_NOT'=>'Not',

'LBL_ALL'=>'所有',
'LBL_ANY'=>'其他',
'LBL_CONDITION'=>'条件',
'LBL_ACTION'=>'活动',
'LBL_MOVE'=>'移动',
'LBL_UP'=>'向上',
'LBL_DOWN'=>'向下',
'LBL_PRIORITY'=>'优先级',
'LBL_UPDATE'=>'更新',
'LBL_SELECT'=>'选择',
'LBL_FOLDERS'=>'文件夹',
'LBL_UNSELECT'=>'取消选择',
'LBL_MATCH'=>'匹配',
'LBL_SCANNING'=>'扫描',
'LBL_LOOKFOR'=>'查找',
'LBL_UNREAD'=>'未读',
'LBL_READ'=>'已读',
'LBL_AFTER_SCAN'=>'经过扫描',
'LBL_MESSAGES_FROM_LASTSCAN'=>'扫描结果',
'LBL_MARK_MESSAGE_AS'=>'标记邮件为',

//Added for the workflow module
'LBL_LIST_WORKFLOWS'=>'自动化作业',
'LBL_LIST_WORKFLOWS_DESCRIPTION'=>'创建或编辑工作流',
'LBL_TASK_TITLE'=>'任务标题',
'LBL_PARENT_WORKFLOW'=>'上一级工作流',
'MSG_EXECUTE_TASK_DELAY'=>'延迟执行任务',
'LBL_AFTER'=>'之后',
'LBL_BEFORE'=>'之前',
'LBL_TASK_OPERATIONS'=>'操作任务',
'LBL_CREATE_TASK'=>'创建任务',
'LBL_CREATE_TASK_OF_TYPE'=>'新任务类型',
'LBL_SUMMARY'=>'概要',
'LBL_WHEN_TO_RUN_WORKFLOW'=>'何时运行该工作流',
'LBL_ONLY_ON_FIRST_SAVE'=>'当记录第一次保存时',
'LBL_UNTIL_FIRST_TIME_CONDITION_TRUE'=>'当条件第一次满足时',
'LBL_EVERYTIME_RECORD_SAVED'=>'每次保存记录的时候',
'LBL_ON_MODIFY'=>'每次编辑记录的时候',
'LBL_CONDITIONS'=>'条件',
'LBL_NEW_CONDITION_BUTTON_LABEL'=>'新条件',
'LBL_TASKS'=>'任务',
'LBL_NEW_TASK_BUTTON_LABEL'=>'新任务',
'LBL_TASK'=>'任务',
// END
//Added for vantage customization (Mandatory fields) -- Pavani
'LBL_MANDATORY_FIELDS'=>'必填项',
'LBL_MANDATORY_FIELDS_DESCRIPTION'=>'管理所有模块的必填项',
// Module Sequence Numbering
'LBL_CUSTOMIZE_MODENT_NUMBER'=>'系统编号定制',
'LBL_CUSTOMIZE_MODENT_NUMBER_DESCRIPTION'=>'定制每个模块的记录项编号',
// END

//added for softphone integration
'LBL_SOFTPHONE_SERVER_SETTINGS'=>'电话服务器设置',
'LBL_SOFTPHONE_SERVER_SETTINGS_DESCRIPTION'=>'您的IP电话配置',
'ASTERISK_SERVER_IP'=>'Asterisk 服务器IP ',
'ASTERISK_PORT'=>'Asterisk 服务器端口',
'ASTERISK_USERNAME'=>'Asterisk 帐号',
'ASTERISK_PASSWORD'=>'Asterisk 密码',
'ASTERISK_SERVER_IP_TITLE'=>'Asterisk 服务器的URL',
'ASTERISK_PORT_TITLE'=>'Call Manager API连接到 Asterisk 的端口 （默认 5038）',
'ASTERISK_USERNAME_TITLE'=>'Asterisk 用户名（通常是admin用户名）',
'ASTERISK_PASSWORD_TITLE'=>'用户密码',
'LBL_CANCEL_BUTTON'=>'取消',
'ASTERISK_VERSION'=>'Asterisk 版本',
'ASTERISK_VERSION_TITLE'=>'选择您的Asterisk版本，如果不知道则为1.4',
'ASTERISK_CONFIGURATION'=>'Asterisk 配置',
//softphone integration ends
'LBL_SELECT_FIELD_TO_MOVE'=>'选择要移动的字段',
'VTLIB_LBL_SELECT_PACKAGE_FILE'=>'选择一个打包文件',
'VTLIB_LBL_FILE_LOCATION'=>'文件位置：',
'VTLIB_LBL_PACKAGE_FILE_HELP'=>'要导入的系统模块必须为zip文件.',
'VTLIB_LBL_IMPORT_FAILURE'=>'导入失败',
'VTLIB_LBL_INVALID_FILE'=>'无效文件',
'VTLIB_LBL_INVALID_IMPORT_TRY_AGAIN'=>'文件包在服务器上，请重试.',
'VTLIB_LBL_UNABLE_TO_UPLOAD'=>'无法上传',
'VTLIB_LBL_UNABLE_TO_UPLOAD2'=>'服务器上的包！请重试。',
'VTLIB_LBL_VERIFY_IMPORT_DETAILS'=>'验证导入详情',
'VTLIB_LBL_MODULE_NAME'=>'模块名',
'VTLIB_LBL_MODULE_DIR'=>'模块目录',
'VTLIB_LBL_REQ_LINGDANG_VERSION'=>'lingdang版本',
'VTLIB_LBL_LICENSE'=>'许可证',
'VTLIB_LBL_LICENSE_ACCEPT_AGREEMENT'=>'我接受许可协议。',
'VTLIB_LBL_PROCEED_WITH_IMPORT'=>'你要继续导入吗？',
'VTLIB_LBL_IMPORTING_MODULE_START'=>'导入模块 ...',
'VTLIB_LBL_WARNING'=>'注意',
'VTLIB_LBL_NOT_WRITEABLE'=>'不可写',
'VTLIB_LBL_PACKAGE_VERSION'=>'版本',

'LBL_UPGRADE'=>'升级',
'VTLIB_LBL_UPDATE_FAILURE'=>'升级失败',
'VTLIB_LBL_MODULENAME_MISMATCH'=>'模块名称不匹配',
'VTLIB_LBL_TRY_AGAIN'=>'重试',
'VTLIB_LBL_VERIFY_UPDATE_DETAILS'=>'验证升级详情',
'VTLIB_LBL_PROCEED_WITH_UPDATE'=>'是否要继续进行升级?',
'VTLIB_LBL_UPDAING_MODULE_START'=>'更新模块...',
'VTLIB_LBL_EXISTS'=>'存在',
'VTLIB_LBL_NOT_PRESENT'=>'不存在',
'VTLIB_LBL_INST_VERSION'=>'安装版',
'VTLIB_LBL_MATCHES_PACKAGE_VERSION'=>'对应版本',
'VTLIB_LBL_CANNOT_UPGRADE'=>'不能升级!',
// END

//User group fixes
'LBL_USERNAME_EXIST'=>'用户账户已经存在！ ',
'LBL_GROUPNAME_EXIST'=>'部门名称已经存在！',
'LBL_ROLENAME_EXIST'=>'角色已存在',

//layout editor
'LBL_MOVE_FIELDS'=>'移动字段',
'NO_HIDDEN_FIELDS'=>'没有隐藏字段',
'LBL_RELATED_LIST'=>'相关列表',
'LBL_ADD_BLOCK'=>'新增区块',
'HIDDEN_FIELDS'=>'隐藏字段',
'DOWN'=>'向下',
'UP'=>'向上',
'RIGHT'=>'向右',
'LEFT'=>'向左',
'LBL_EDIT_PROPERTIES'=>'编辑属性',
'LBL_MANDATORY_FIELD'=>'必填字段',
'LBL_ACTIVE'=>'启用',
'LBL_QUICK_CREATE'=>'快速创建',
'LBL_MASS_EDIT'=>'批量编辑',
'LBL_BLOCK_NAME'=>'区块名称',
'AFTER'=>'在...之后',
'ADD_BLOCK'=>'新增区块',
'ARRANGE_RELATEDLIST'=>'排列字段显示顺序',
'CUSTOMFIELD_MAPPING'=>'自定义字段映射',
'LBL_MAPPED_FIELDS'=>'映射字段',
'LEADS_CUSTOM_FIELD_MAPPING_DESCRIPTION'=>'映射您的帐户，联系人和销售机会自定义字段',
'LEADS_CUSTOM_FIELD_MAPPING'=>'潜在客户自定义字段映射',
'LBL_CALENDER_CUSTOMFIELDS'=>'日程自定义字段',
'LBL_CALENDER_CUSTOMFIELDS_DESCRIPTION'=>'您可以创建日程的自定义字段',
'LBL_GO_BACK'=>'返回',
'LBL_Delete'=>'删除',

//Added fix for: 5418
'LBL_USE_PREFIX'=>'使用前缀',
'LBL_START_SEQ'=>'起始数字',
'LBL_MODULE_NUMBERING'=>'模块编号',
'LBL_FAILED'=>'失败',
'LBL_DONE'=>'执行完毕',
'LBL_IN_USE'=>'使用中',
'LBL_MODULE_NUMBERING_FIX_MISSING'=>'立刻更新遗漏的编号',

//Added for: 5473
'LBL_SHARING_ACCESS_HELPNOTE'=>'进行修改后，按重新计算按钮以应用更改.',

//for customer portal extension module
//'PORTAL_EXTENSION_DESCRIPTION'=>'允许您配置客户Portal插件',
//'LBL_CUSTOMER_PORTAL'=> '客户Portal',
'PORTAL_EXTENSION_DESCRIPTION'=>'允许您配置客户门户插件',
'LBL_CUSTOMER_PORTAL'=> '客户门户',

'LBL_ADD_CUSTOMFIELD'=>'新增自定义字段',
'AUTUALAMOUNT'=>'实际金额',
'ERR_INVALID_PROFILE_ID'=>'无效的权限ID，请指定一个有限的权限ID',

// Customization
'LBL_PUBLISHER' => '发布',
'LBL_PUBLISHED_ON' => '发布号',
'LBL_LICENSE'   => '许可',
'LBL_EXTENSION_FILE_DOWNLOAD_FAILED' => '无法下载扩展包!',
'LBL_DEFAULT'=>'默认情况下，发送邮件服务器SMTP帐户设置被配置为OD1 lingdang COM邮件服务器，为了避免您的收件人的ISP邮件服务器的垃圾邮件过滤器过滤外发邮件，我们建议您执行下列之一',
'LBL_OPTIONS1'=>'从您的邮件服务器发送电子邮件<br>
				- 输入SMTP帐户的详细信息（服务器名，用户名，密码），和发送邮件地址相同',
'LBL_OPTIONS2'=>"增加od1.lingdang.com 服务器作为您的域名的授权发件人.<br>
				- 如果您希望保留lingdang服务器作为邮件发送服务器,我们建议您配置您的域名的SPF记录并将lingdang服务器包含为您域名的有效发件人
				  为配置SPF记录获得额外指导，请电邮OD-lingdang.COM",
'LBL_ALREADY_EXISTS' => '已经存在',
'LBL_EXTENSION_INCOMPATIBLE' => '扩展不兼容',
'LBL_INSTALL' => '安装',
'LBL_DEFAULT_SETTINGS_BUTTON_TITLE' => '恢复默认',
'LBL_CONFIRM_DEFAULT_SETTINGS' => '你肯定要改变默认的服务器值的服务器的详细信息',
'EXISTING_DEFAULT_VALUES' => '服务器的详细信息已经设置为默认值',
'LBL_NOTE' => 'Note:',
'LBL_HIDE' => '隐藏信息',
'LBL_SHOW' => '显示信息',
// END
'LBL_USER_ADDITION_INFO'=>"要添加一个新用户，请点击  
			   <span style='font-style:italic;color:blue;'>设置图标 -> 按需求管理 -> 增加用户 </span>",

'LBL_READ_ONLY_ACCESS_MSG' => '只读权限',
'LBL_READ_WRITE_ACCESS_MSG' => '读写权限',
    
'LBL_DEFAULT_VALUE' => '默认',

'LBL_DESCRIPTION_Public: Read Only'=>'用户只能读取其他用户 ',
'LBL_DESCRIPTION_Public: Read, Create/Edit'=>'用户可以阅读、编辑其他用户 ',
'LBL_DESCRIPTION_Public: Read, Create/Edit, Delete'=>'用户可以读取、编辑、删除其他用户 ',

// For Dependency picklist
'LBL_PICKLIST_DEPENDENCY_SETUP' => '级联字段',
'LBL_PICKLIST_DEPENDENCY_DESCRIPTION' => '在每个模块设置选择列表值之间的依赖',

'Settings' => '控制面板',
'LBL_ERR_TAX_LABEL_ALREADY_EXISTS' => '此税已经可用',
'LBL_ERR_SOME_TAX_LABELS_ALREADY_EXISTS' => '一些税务标签已经在使用，因此不保存',

'LBL_EDIT_COMPANY_INFO' => "编辑公司的详细信息，请点击
			   <span style='font-style:italic;color:blue;'>设置图标 > 按需求管理 > 公司 </span>",

//FieldFormulas，5.3.0之前
'LBL_FIELDFORMULAS'=>'字段公式',
'LBL_FIELDFORMULAS_DESCRIPTION'=>'为自定义字段添加公式 ',    

'Configuration Editor'=>'配置编辑器',

//'ModTracker' => 'ModTracker',
'ModTracker' => '模块跟踪',
'LBL_MODTRACKER_DESCRIPTION' => '选择跟踪模块',

'LBL_MENUS_TO_SHOW'=>'选择主菜单上显示的模块',
'LBL_MENU_DESC'=>'自定义菜单顺序',
'LBL_MENU_EDITOR'=>'菜单编辑器',
'LBL_MENUS_TO_SHOW_DESCRIPTION' => '您可以使用箭头命令菜单中的项目，前10个项目出现在主菜单上，其余则显示下下拉菜单中',
'LBL_ALL_MODULES' => '所有模块',
'LBL_SELECTED_MODULES' => '选中的模块',

'LBL_CRM_SETTINGS' => '控制面板',
'Move Fields'=>'移动字段',

//add by LD tifa 20121205
'Scheduler'=>'计划任务',
'Update configuration file of the application'=>'更新应用程序的配置文件',
'Allows you to Configure Cron Task'=>'允许您配置计划任务',
'Allows you to manage Webforms'=>'允许您管理的网页表单',

'LBL_Move_Right'=>'右移',
'LBL_Move_Left'=>'左移',
'LBL_Move_Up'=>'上移',
'LBL_Move_Down'=>'下移',

'SettingsAjax'=>'设置ajax',
'AuditTrailList'=>'审计线索单',
'index'=>'该模块页面',
'DefaultFieldPermissions'=>'字段权限',
'EditView'=>'编辑',
'ListView'=>'查看列表',
'MailManagerAjax'=>'邮件管理ajax',
'DetailView'=>'查看详细信息',
'Save'=>'保存',
'TooltipAjax'=>'提示',
'AccountsAjax'=>'客户ajax',
'DashboardAjax'=>'统计图ajax',
'createemailtemplate'=>'创建邮件模板',
'listemailtemplates'=>'邮件模板列表',
//'listemailtemplates'=>'Email模板',
'HomeAjax'=>'主页',
'SavePriceBook'=>'保存',
'SaveVendor'=>'保存',
'PriceBookEditView'=>'编辑',
'QuickCreate'=>'快速创建',
'VendorEditView'=>'编辑',
'DeletePriceBook'=>'删除',
'Delete'=>'删除',
'DeleteVendor'=>'删除',
'VendorDetailView'=>'详细信息',
'Import'=>'导入',
'Export'=>'导出',
'Merge'=>'提醒',
'ModuleManager'=>'模块管理',
'CurrencyEditView'=>'货币编辑',
'CurrencyListView'=>'货币列表',
'CustomView'=>'视图',
'edittask'=>'编辑任务',
'ListCronJobs'=>'计划任务列表',
'editworkflow'=>'编辑工作流',
'workflowlist'=>'工作流列表',
'ListLoginHistory'=>'登录日志列表',
'MailerExport'=>'邮寄导出',
'com_lingdang_workflowAjax'=>'工作流ajax',
'CronTasksAjax'=>'日程任务ajax',
'Authenticate'=>'用户扩展选项',
'UsersAjax'=>'用户ajax',
'ActivityAjax'=>'日程ajax',
'CallRelatedList'=>'更多信息',
'HelpDeskAjax'=>'服务单ajax',
'ModCommentsAjax'=>'备注ajax',
'ExportRecords'=>'导出记录',
'updateRelations'=>'更新联系人',
'Popup'=>'弹出框',
'PotentialsAjax'=>'销售机会ajax',
'createrole'=>'创建角色',
'RoleDetailView'=>'角色信息',
'listroles'=>'角色列表',
'Logout'=>'注销',
'profilePrivileges'=>'权限',
'UpdateProfileChanges'=>'修改权限',
'ListProfiles'=>'权限列表',
'LayoutBlockList'=>'区块布局',
'ReportsAjax'=>'报表ajax',
'VendorsAjax'=>'供应商ajax',
'EditDefOrgFieldLevelAccess'=>'编辑字段权限',
'QuotesAjax'=>'报价单ajax',
'SaveAndRun'=>'保存执行',
'ServiceContractsAjax'=>'服务合同ajax',
'ProductsAjax'=>'产品ajax',
'UnifiedSearch'=>'查找',
'ModTrackerAjax'=>'模块跟踪ajax',
'OrgSharingDetailView'=>'共享规则详细信息',
'listnotificationschedulers'=>'通知列表',
'BackupServerConfig'=>'备份服务配置',
'ContactsAjax'=>'联系人ajax',
'CustomFieldList'=>'字段列表',
'listinventorynotifications'=>'库存提醒列表',
'SalesOrderAjax'=>'合同订单',
'RecalculateSharingRules'=>'计算共享规则',
'OrgSharingEditView'=>'编辑共享规则',
'CreatePDF'=>'生成pdf',
'BasicSettings'=>'基础设置',
'ProjectAjax'=>'项目ajax',
'getListOfRecords'=>'记录列表',
'massdelete'=>'批量删除',
'CampaignsAjax'=>'营销活动ajax',
'MassEditSave'=>'批量编辑',
'PickListAjax'=>'下拉框ajax',
'ServicesAjax'=>'服务',
'CustomModEntityNo'=>'系统编号',
'saveworkflow'=>'保存',
'InvoiceAjax'=>'发票ajax',
'ChangePassword'=>'修改密码',
'ConfigEditorAjax'=>'配置编辑器ajax',
'SaveSharingRule'=>'保存共享规则',
'EmailConfig'=>'邮件配置',
'ProxyServerConfig'=>'服务器配置',
'TaxConfig'=>'税配置',
'OrganizationConfig'=>'公司信息',
'Contact Name'=>'联系人姓名',
'Location'=>'地点',
'Visibility'=>'可见性',
'EditCompanyDetails'=>'编辑公司信息',
'FieldFormulasAjax'=>'字段公式',
'MenuEditor'=>'编辑菜单',
'detailviewemailtemplate'=>'邮件模板信息',
'DocumentsAjax'=>'文档ajax',
'saveemailtemplate'=>'保存邮件模板', 
'editemailtemplate'=>'编辑邮件模板', 
'DocumentsAjax'=>'文档ajax', 
'SaveCurrencyInfo'=>'保存货币信息',
'GroupDetailView'=>'部门信息',
'createnewgroup'=>'创建部门',
'PickListDependencySetup'=>'下拉框依赖关系',
'LBL_CONFIGURATION_DESCRIPTION'=>'配置描述',
'LBL_TEMPLATE'=>'模板',
'LBL_of'=>'的',
'LBL_SET_DATE_TIME'=>'打开日历..',
'Time'=>'时间',
'LBL_LIST_OF'=>'共',
'LBL_TEMPLATES'=>'首页组件模板',
'LBL_TEMPLATES_DESCRIPTION'=>'管理首页组件模板、设置模板关联角色',
'LBL_NEW_TEMPLATES'=>'新增模板',
'LBL_TEMPLATES_LIST'=>'模板列表',
'LBL_TEMPLATES_NAME'=>'组件模板名称',
'LBL_TEMPLATES_ROLE'=>'关联角色',
'LBL_TEMPLATES_MODIFIEDBY'=>'最近修改人',
'LBL_TEMPLATES_MODIFIEDTIME'=>'最近修改时间',
'LBL_DISPLAY_ASSMBLY'=>'选择显示的组件',
'LBL_MEMBER_ROLE'=>'可用角色',
'LBL_ROLE_SELECTED'=>'选择的角色',
'LBL_ALL_ASSMBLY'=>'所有模块',
'LBL_DISPLAY_ASSMBLY'=>'显示的模块',
'LBL_TEMPLATENAME_EXIST'=>'模板名称已经存在',
// Default home page widget's title
'Top Six Sales'=>'最近6个月销售情况',
'Company Year Sales'=>'年度销售情况',
'Stores'=>'库存资料',
'Product Name' => '产品名称',
'Description' => '描述',
'Product Image'=>'产品图片',
'Product No'=>'产品编号',
'Commission Rate' => '佣金率',
'Tax Class'=>'税别',
'Manufacturer'=>'制造商',
'Mfr PartNo'=>'生产厂家部件编号',
'Expense No' => '费用编号',
'expensedate' => '报销日期',
'numcount' => '票据张数',
'Serial No'=>'序列号',
'Support Start Date'=>'售后服务开始日期',
'Qty In Demand'=>'需求数量',
'Support Expiry Date'=>'售后服务终止日期',
'Qty/Unit'=>'数量/单位',
'Reorder Level'=>'记录者级别',
'Sales End Date'=>'终止销售日期',
'Sales Start Date'=>'开始销售日期',
'Vendor PartNo'=>'供应商部件编号',
'Mfr PartNo'=>'生产厂家部件编号',
'Qty In Stock'=>'库存数量',
'Usage Unit' => '计量单位',
'Created Time'=>'创建时间',
'Modified Time'=>'修改时间',
'Creator'=>'创建人',
'Company Month Sales'=>'签约额月度同比',
'Company Month Accounts'=>'回款额月度同比',
'Accounts Pays'=>'应收款汇总',
'Next Month Sales'=>'下属本月销售数据',
'Penson Month Sales'=>'个人本月销售数据',
'Penson Top Six Sales'=>'个人最近6个月销售情况',
'Upcoming Activities'=>'过去7天内日程',
'Pending Activities'=>'未来7天内日程',
'Not Finished Calendar'=>'过期未完成日程',
'Today Contract Customer'=>'今日待联系客户',
'Top Potentials'=>'最新销售机会',
'Top Quotes'=>'最新报价单',
'Top Sales Orders'=>'最新合同订单',
'Top Invoices'=>'最新发票',
'Top Purchase Orders'=>'最新采购订单',
'Sales Funnel'=>'销售漏斗',
'Key Metrics'=>'关键视图',
'NoteBook'=>'记事本',
'Top Trouble Tickets'=>'最新服务单',
'My Recent FAQs'=>'最新常见问答',

'Top Accounts'=>'最新销售机会',
'My New Leads'=>'最新潜在客户',
'My Group Allocation'=>'最新部门任务',
'Home Page Dashboard'=>'最新销售情况',
'Tag Cloud'=>'常用标签',
//工作报告提醒设置
'LBL_REMIND_SET'=>'工作报告提醒设置',
'LBL_REMIND_SET_DESCRIPTION'=>'设置日/周/月报提交期限',
'LBL_REMIND_DAILY'=>'日报提交期限:',
'LBL_REMIND_DAILY_DESCRIPTION'=>'提前1小时开始，到当天23:59为止，在工作台提醒',
'LBL_REMIND_WEEK'=>'周报提交期限:',
'LBL_REMIND_WEEK_DESCRIPTION'=>'提前1天开始，到本周最后一天，在工作台提醒',
'LBL_REMIND_MONTH'=>'月报提交期限:',
'LBL_REMIDN_MONTH_DESCRIPTION'=>'提前3天开始，在工作台提醒',
'LBL_SECURITYCODE_SET'=>'登录验证码',
'LBL_SECURITYCODE_SET_DESCRIPTION'=>'设置登录时是否启用验证码',
'LBL_SMS_SETTINGS'=>'通讯账户',
'LBL_SMS_DESCRIPTION'=>'配置短信、传真、语音账户',
'LBL_SMS_USERNAME'=>'用户名',
'LBL_SMS_PASSWORD'=>'密码',
'LBL_SMS_SERVER'=>'网络连接不可用，请检查你的网络环境！',
'LBL_SMS_DELACCOUNT'=>'账户已停用！',
'LBL_SMS_ACCOUNT'=>'请求的服务不可用，请联系供应商！',
'LBL_SMS_USERINFO'=>'用户名或密码有误，请重新输入！',
'LBL_ACCOUNT_SET'=>'公海客户设置',
'LBL_ACCOUNT_SET_DESCRIPTION'=>'设置公海客户管理参数',
'LBL_SYSTEM_SET'=>'系统参数',
'LBL_SYSTEM_SET_DESCRIPTION'=>'配置系统参数',
'LBL_RELATED_PARAMETERS'=>'关联产品字段',
'LBL_RELATED_RELATEDLIST'=>'更多信息字段',
'LBL_RELATED_PARAMETERS_DESCRIPTION'=>'定制合同订单等模块产品信息工具中显示的产品字段',
'LBL_RELATED_RELATEDLIST_DESCRIPTION'=>'定制各模块被关联时在更多信息中显示的字段',
//将客户公海改成公海客户
'LBL_ACCOUNT_SET'=>'公海客户设置',
'LBL_ACCOUNT_SET_DESCRIPTION'=>'设置公海客户管理参数',
//审批流程管理
'LBL_APPROVE'=>'审批流程管理',
'LBL_APPROVE_DESCRIPTION'=>'定制单据的审批流程',
'Comprehensivereport'=>'综合报表',
'Costprice'=>'成本价',
'LBL_WASEHOUSE'=>'仓库管理',
'LBL_WASEHOUSE_DESCRIPTION'=>'设置仓库和仓库管理人员',
'LBL_PAGE_SET'=>'页面设置',
'LBL_PAGE_SET_DESCRIPTION'=>'管理各模块的页面布局，为自定义字段定义公式',
'LBL_C_FORMUAL'=>'字段公式',
'LBL_TABLIST'=>'菜单定制',
'LBL_TABLIST_DESCRIPTION'=>'定制主菜单及其子模块的名称和显示次序',
'LBL_PRODUCTTOOLFIELD'=>'产品工具自定义字段',
'LBL_PRODUCTTOOLFIELD_DESCRIPTION'=>'管理订单、发票等模块中产品信息工具的自定义字段',

//数据备份
'LBL_BACKUP_SET'=>'数据备份',
//'LBL_BACKUP_SET_DESCRIPTION'=>'手动备份帐套或者设定自动备份周期',
'LBL_BACKUP_SET_DESCRIPTION'=>'手动备份帐套',
'LBL_BACKUP_HANDSET'=>'手动备份',
'LBL_BACKUP_AUTOSET'=>'自动备份',

'LBL_BACKUP_PATH'=>'备份文件路径',

'LBL_BACKUP_ISUSING'=>'是否启用',
'LBL_BACKUP_CYCLE'=>'自动备份周期',
'LBL_BACKUP_EVERY'=>'每',
'LBL_BACKUP_DAY'=>'天',
'LBL_BACKUP_HOUR'=>'时',
'LBL_BACKUP_MINUTE'=>'分',
'LBL_ProductTool_field'=>'产品工具自定义字段',
'LBL_ProductTool_Description'=>'管理订单、发票等模块中产品信息工具的自定义字段',
'actualamount'=>'已收金额',
'Description'=>'描述',
'LBL_Allroles'=>'所有角色',
'LBL_InvisibleProfileSet'=>'3.不可见角色设置',
'LBL_InvisibleProfile'=>'不可见角色',
    );
?>