<?php
/*+**********************************************************************************
 *{*�޸ı����ʽ:ͳһ���룺UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

global $mod_strings,$app_strings,$theme,$currentModule,$current_user;



//��ʾ�Զ����ֶ�����
if(!empty($_REQUEST['tabid'])){
	/* gyq_10 */
	require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
	$autoLoadInstance = new INSTANCE();
	$ProductToolFields = $autoLoadInstance->autoLoad($_REQUEST['tabid'],'Fields');

    $type = $_REQUEST['type'];
	$module=getTabModuleName($_REQUEST['tabid']);
	if(!empty($_REQUEST['type'])){
        if(isset($_REQUEST['selectsourcetype'])&&!empty($_REQUEST['selectsourcetype'])){
            $ProductToolFields->Setselectsourcetype($_REQUEST['selectsourcetype']);
        }
		$fieldlist = $ProductToolFields->getFieldList($_REQUEST['type']);
	}


	$smarty->assign('MODULE',$module);
	$smarty->assign('APP',$app_strings);
	$smarty->assign('THEME', $theme);
	$smarty->assign('TABID',$_REQUEST['tabid']);
	$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
	$smarty->assign('FIELDLIST',$fieldlist);
	$smarty->assign('TYPE',$_REQUEST['type']);
    $_REQUEST['diony']='yes';

    if ($type == 'Sort'){
        $arr['title'] = getFixedLabel('LBL_CHANGEORDER');
        $arr['oktext'] = getFixedLabel('SAVE');
        $arr['canceltext'] = getFixedLabel('CANCEL');
    }else{
        $arr['title'] = getFixedLabel('HIDDENFIELDS');
        $arr['oktext'] = getFixedLabel('CANCELHIDDEN');
        $arr['canceltext'] = '';
    }
    
	$arr['content']=$smarty->fetch('SortFieldView.tpl');
    ConvertTojsonString(1,$arr,'success');
    
}
exit();
?>