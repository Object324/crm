<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Customreport/ReportFolder.php');
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$default_language;
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
//判断当前用户是否是管理员(on 是 off 否)
$smarty->assign('ISADMIN',$current_user->is_admin);
//获取所有文件夹
$folderAll = $focus->getFolderAll();
foreach($folderAll as $folder_id => $folder_info){
	$report_folderid[] = $folder_id;
	$report_folder[$folder_id]['folder_name'] = $folder_info['folder_name'];
    $report_folder[$folder_id]['systemdefault'] = $folder_info['systemdefault'];
}
//Ajax局部更新文件夹
if(!empty($_REQUEST['folder_id'])){
	foreach($report_folder as $folder_id => $folder_info){
		if($folder_id != $_REQUEST['folder_id']){
			unset($report_folder[$folder_id]);
		}

	}
}
//非管理员用户权限
if($current_user->is_admin == 'off'){
	require_once( 'modules/Users/Group.class.php');
	$group_focus = new Group();
	$depName = $group_focus->getUserGroup($current_user->id);
	$depId = array_keys($depName);
	if(count($depId) >= 1){
		$groups_where = ' and ld_groups.groupid in ('.implode(',',$depId).')';
	}
	$users_where = ' and ld_customreport2user.userid  = ' . $current_user->id;
}
//获取文件夹下的所有模块

$query = 'select allocatepname,systemdefault,presence,report_id,folder_id,report_name
        ,report_describe,allocatetype,report_type,sequence,report_template,report_url,databaselinktype from
     (
	select 
		"AllUser" AS allocatepname,systemdefault,presence,ld_customreport_info.report_id,folder_id
        ,report_name,report_describe,allocatetype,report_type,ld_customreport_info.sequence,report_template,report_url	
        ,databaselinktype
	from 
		ld_customreport_info where allocatetype=0  
	UNION
	select  
		GROUP_CONCAT(ld_users.last_name order by ld_users.id) AS allocatepname,
        ld_customreport_info.systemdefault,ld_customreport_info.presence,ld_customreport_info.report_id
        ,folder_id,report_name,report_describe,allocatetype,report_type,sequence,report_template,report_url
        ,ld_customreport_info.databaselinktype
	from 
		ld_customreport2user 
		inner JOIN ld_users on ld_users.id=ld_customreport2user.userid 
		inner JOIN ld_customreport_info on ld_customreport2user.report_id=ld_customreport_info.report_id  
	where 
		allocatetype=2 '.$users_where.' GROUP BY  ld_customreport2user.report_id';
if(!empty($groups_where) || $current_user->is_admin == 'on'){
$query .=' UNION
	select  
		GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid) AS allocatepname,
        ld_customreport_info.systemdefault,ld_customreport_info.presence,ld_customreport_info.report_id,folder_id
        ,report_name,report_describe,allocatetype,report_type,ld_customreport_info.sequence,report_template,report_url
         ,ld_customreport_info.databaselinktype
	from 
		ld_customreport2user 
		inner JOIN ld_groups on ld_groups.groupid=ld_customreport2user.userid 
		inner JOIN ld_customreport_info on ld_customreport_info.report_id=ld_customreport2user.report_id  
	where 
		allocatetype=1 '.$groups_where.' GROUP BY  ld_customreport2user.report_id';
}
$query .=') AS allreportdata';
if(!empty($_REQUEST['folder_id'])){
	$query .= ' where allreportdata.folder_id = ' . $_REQUEST['folder_id'];
}
$query .= ' ORDER BY sequence asc';

$result = $adb->pquery($query,array());
if($adb->num_rows($result) >= 1){
	for($i = 0; $i<$adb->num_rows($result); $i++){
		$folder_id = $adb->query_result($result,$i,'folder_id');
		if(in_array($folder_id,$report_folderid)){
			$allocatepname = $adb->query_result($result,$i,'allocatepname');//用户权限0 所有人 1 部门 2用户 
			if($allocatepname == 'AllUser'){
				$allocatepname = getFixedLabel('ALLTHEUSERS');
			}
            $report_presence = $adb->query_result($result,$i,'presence');
            $report_systemdefault= $adb->query_result($result,$i,'systemdefault');
			$report_id = $adb->query_result($result,$i,'report_id');
			$report_type = $adb->query_result($result,$i,'report_type');//报表类型
			$report_name = $adb->query_result($result,$i,'report_name');//报表名称
			$report_template = $adb->query_result($result,$i,'report_template');
			$report_url = $adb->query_result($result,$i,'report_url');
			$report_name = $adb->query_result($result,$i,'report_name');
            $databaselinktype=$adb->query_result($result,$i,'databaselinktype');//数据库连接方式
          
            $tmpsystemdefault=0;
            if($databaselinktype=='crmlink')
            {
                $tmpsystemdefault=1;
            }
            
			if($report_type == 'template_flex'){
			 //stimulsoft_client_key=ViewerFx&
				$report_name = "<a target=\"_blank\" title=".$report_name." href=CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=".$report_template."&default_report=$tmpsystemdefault>" . $report_name . "</a>";
			}
            else if($report_type=='template_js')
            {
                $report_name = "<a target=\"_blank\" title=".$report_name." href=CustomReport/JsReport/index.php?crm_report_key=".$report_template."&default_report=$tmpsystemdefault&report_name=".urlencode($report_name).">" . $report_name . "</a>";
            }
            //zkt 【禹王：自定义报表增加对“帆软”开发的报表的访问解析支持】
            else if($report_type == 'finereport')
            {
                $report_name = "<a href='javascript:void(0);' id='href_link_".$report_id."' onclick='report_href_fanruan(".$report_id.")' title=".$report_name." tag='".$report_url."'>" . $report_name . "</a>";
            }
            else{
				$report_name = "<a href='javascript:void(0);' id='href_link_".$report_id."' onclick='report_href_link(".$report_id.")' title=".$report_name." tag='".$report_url."&default_report=$tmpsystemdefault'>" . $report_name . "</a>";
			}
            if($report_presence == 0){
    			$report_folder[$folder_id]['report_info'][] = array(
                    'systemdefault' => $report_systemdefault,
    				'report_id' => $report_id,
    				'report_name' => $report_name,
    				'report_describe' => '<span title="'.$adb->query_result($result,$i,'report_describe').'">'.$adb->query_result($result,$i,'report_describe').'</span>',
    				'allocatetype' => $adb->query_result($result,$i,'allocatetype'),
    				'report_type' => $report_type,
    				'allocatepname'=>'<span title="'.$allocatepname.'">' . $allocatepname . '</span>',
    			);
            }
		}
	}
}
$smarty->assign('REPORT_FOLDER',$report_folder); //所有启用并且显示的报表
$smarty->assign('languageType',$languageType);
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
	$smarty->display("modules/Customreport/CustomreportContents.tpl");
else
	$smarty->display("modules/Customreport/CustomreportListView.tpl");

?>