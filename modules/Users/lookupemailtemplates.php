<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/


$smarty = new lingdangCRM_Smarty;
global $theme,$current_user;
$theme_path="themes/".$theme."/";
//zkt 20221128 管理员应该可以看到所有模板，非管理员应看到自己创建的以及公开的模板
//BUG0059166邮件模板中看不到私有模板，但是群发邮件时，却可以选择到私有模板
if(is_admin($current_user))//edit:can 20210422 45445: （https://61mis.com/kfbcrm [^]）邮件模板中设置了私有的模板，但是在邮件管理中发送邮件时选择邮件模板，可以选择到私有的模板，例如系统中名称为‘1’的模板是可以被其他人选择到的
    $sql = "select templateid,foldername,templatename,description,body from ld_emailtemplates order by templateid desc";
else
    $sql = "select templateid,foldername,templatename,description,body from ld_emailtemplates where smcreatorid=".$current_user->id." or foldername = 'Public' order by templateid desc";


$result = $adb->pquery($sql, array());
$temprow = $adb->num_rows($result);
$cnt=1;
require_once('include/utils/UserInfoUtil.php');
$is_admin=is_admin($current_user);
//	0019721: IE8>客户>明细界面>关联创建-发送邮件弹出页中的【选择邮件模板】按钮没反应
$html='<div style="max-height:550px;overflow:auto;width:100%;">';
$html .='<table id="emailTemplatesTable" class="D_pop_bod listEntries" cellspacing="1" cellpadding="1" border="0">
    ';
if($temprow > 0){
	for($i=0;$i<$temprow;$i++){
		$templateid = $adb->query_result($result, $i, "templateid");
		$foldername = $adb->query_result($result, $i, "foldername");
		$templatename = $adb->query_result($result, $i, "templatename");
		$description = htmlspecialchars_decode($adb->query_result($result, $i, "body"));
		 $json_array[]=array();
		 
		if($is_admin == false){
			if($folderName != 'Personal')
			{
			  $json_array[]=array('templateprintid'=>$templateprintid);
				$html .= "<tr><td width='30%' align='left'>";
				$html .= "<a href='javascript:submittemplate(".$templateid.");' title='".$templatename."'>".$templatename."</a></td>";
				$html .= "<td width='70%' align='left'><span title='".$description."'>".$description."</span></td></tr>";
			}
		}
		else{
			$html .= "<tr><td width='30%' align='left'>";
			$html .= "<a href='javascript:submittemplate(".$templateid.");' title='".$templatename."'>".$templatename."</a></td>";
			$html .= "<td width='70%' align='left'><span title=''>".$description."</span></td></tr>";
		}
	}
	$html .= "<tr><td colspan='2'>&nbsp;</td></tr>";
}else{
	$html .= '<tr align="center">';
	$html .= '<td colspan="2" bgcolor="#efefef">';
	$html .= '<div class="popupnoResultBG">';
	$html .= '<div class="noResultContent">';
	$html .= '<div class="divNoRecord">'.getFixedLabel("NOTFOUNDANYRECORD").'</div>';
	$html .= '</div>';
	$html .= '</td></tr>';
}
$html .= '</table>';
$html .= '</div>';
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('EMAILTEMPLATES');
$str=$html;
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>