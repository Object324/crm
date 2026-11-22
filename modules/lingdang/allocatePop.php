<?php
/**
 * 分配弹出层
 * */
//$deploy_values=getSys_deploy(110);// 分配弹出层是否显示所有用户设置为否
//if('Allocate' == $_REQUEST['popup_type']){
//	if($deploy_values['deploy_value']==1)
//	{
//		//024943: 控制面板 系统参数设置 分配弹出层是否显示所有用户设置为否 当我数据范围是个人的时候 点击分配还弹出全部用户
//		$_REQUEST['popup_scopetype']='private';
//	}
//}
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$fld_module = isset($_REQUEST['popup_module'])?$_REQUEST['popup_module']:'yes';//模块
$focus=CRMEntity::getInstance($fld_module);
$fld_fieldname=$focus->getSmownerColumName();
$_REQUEST['fieldname']=$fld_fieldname;
include(globalStatic::$root_directory.'modules/Users/viewuserinfo.php');


?>