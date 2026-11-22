<?php
//gyq_117 reason:企业微信增加个人资料及修改密码  2019/6/3 16:10 
global $adb,$currentModule;
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
