<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

/**
 * edit:kevin
 * date:2013-06-25
 * reason:短信模板明细界面
 */ 
    global $adb,$app_strings,$theme;
    if(isset($_REQUEST['templateid'])&&$_REQUEST['templateid']!=""){
        $templateid=$_REQUEST['templateid'];
    }
    if(isset($_REQUEST['blockidsetting'])&&$_REQUEST['blockidsetting']!=""){
        $blockidsetting=$_REQUEST['blockidsetting'];
    }
    if(isset($_REQUEST['fieldidsetting'])&&$_REQUEST['fieldidsetting']!=""){
        $fieldidsetting=$_REQUEST['fieldidsetting'];
    }
    $query="select * from ld_smstemplates where templateid=?";
    $result=$adb->pquery($query,array($templateid));
    $num_rows=$adb->num_rows($result);
    $platform = '';
    if($num_rows){
        $templatename=$adb->query_result($result,0,'templatename');
        $body=$adb->query_result($result,0,'body');
		$template_type=$adb->query_result($result,0,'template_type');
		$platform=$adb->query_result($result,0,'platform');
    }
    $smarty=new lingdangCRM_Smarty;
    $smarty->assign('TEMPLATENAME',$templatename);
    $smarty->assign('BODY',$body);
    if ($platform == 'aliyun') {
        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();
        $smarty->assign('TEMPLATE_TYPE',$cls_Send_MassSms->get_template_type($template_type));
    }else{
        if($template_type == 'ordinary'){
            $smarty->assign('TEMPLATE_TYPE',getFixedLabel('plainsms'));
        }else{
            $smarty->assign('TEMPLATE_TYPE',getFixedLabel('SMS_Marketing'));
        }
    }

    $smarty->assign('TEMPLATEID',$templateid);
    $smarty->assign('BLOCKIDSETTING',$blockidsetting);
    $smarty->assign('FIELDIDSETTING',$fieldidsetting);
    
    $smarty->assign('APP',$app_strings);
    $smarty->assign('THEME',$theme);
    $smarty->display('DetailViewSmsTemplate.tpl');
	$_REQUEST['diony']='diony';
	$arr['title'] = getFixedLabel('VIEW');
	$arr['oktext']=getFixedLabel("CONFIRME");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("DetailViewSmsTemplate.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
?>