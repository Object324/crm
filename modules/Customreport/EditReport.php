<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * 新增自定义报表	2016-03-01

 * Description:  Chj To be written.

 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.

 * All Rights Reserved.

 * Contributor(s): ______________________________________..

 ********************************************************************************/
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$default_language;
$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony']='diony';
if(!empty($_REQUEST['report_id'])){
	$query = 'SELECT
				folder_id,
				report_name,
				ld_customreport_info.analysisfolder_id,
				report_describe,
                report_template,
				report_type,report_url,ld_customreport_info.systemdefault,
				ld_customreport_folder.folder_name,databaselinktype,report_file
			FROM
				ld_customreport_info
			LEFT JOIN ld_customreport_folder ON ld_customreport_folder.id = ld_customreport_info.folder_id
			WHERE
				ld_customreport_info.report_id = ? limit 1';
	$result = $adb->pquery($query,array($_REQUEST['report_id']));
	$before_folder_id = $adb->query_result($result,0,'folder_id');
	$databaselinktype = $adb->query_result($result,0,'databaselinktype');
	$report_type = $adb->query_result($result,0,'report_type');
	$report_url = $adb->query_result($result,0,'report_url');
	$report_name = $adb->query_result($result,0,'report_name');
	$report_template = $adb->query_result($result,0,'report_template');
    $report_file = $adb->query_result($result,0,'report_file');
    $analysisfolder_id = $adb->query_result($result,0,'analysisfolder_id');//zxm 20221110 报表文件文件夹id
	//查询链接模块   //增加帆软报表的entitytype值
	$selectSql = "select * from ld_linkmodulecustom where  linkcvid =? and entitytype in (?,?) and linkmodule=?";
	$selectRes = $adb->pquery($selectSql,array($_REQUEST['report_id'],'custom','customfine','Customreport'));
	$selectNums =  $adb->num_rows($selectRes);
	if($selectNums>0){
		$smarty->assign('setlinkmodule',"yes");
	}else{
		$smarty->assign('setlinkmodule',"no");
	}
	if(!empty($_REQUEST['report_save']) && $_REQUEST['report_save'] == 'yes'){
		if(!empty($_REQUEST['report_name']) && (!empty($_REQUEST['select_folder'])||!empty($_REQUEST['analysisfolder_id']))){
			$select_folder = $_REQUEST['select_folder'];
			if($before_folder_id != $select_folder){
				$query = 'select max(sequence) as sequence from ld_customreport_info where folder_id = ?';
				$result = $adb->pquery($query,array($select_folder));
				$max_sequence = $adb->query_result($result,0,0);
				$query = 'update ld_customreport_info set folder_id = ?,sequence = ? where report_id = ?';
				$adb->pquery($query,array($select_folder,$max_sequence,$_REQUEST['report_id']));
			}
			$query = 'update ld_customreport_info set analysisfolder_id = ? where report_id = ?';
			$adb->pquery($query,array($_REQUEST['analysisfolder_id'],$_REQUEST['report_id']));
			$query = 'update ld_customreport_info set report_name = ?,report_describe=?,report_url=?,report_file=?,databaselinktype=? where report_id = ?';
		
            $adb->pquery($query,array($_REQUEST['report_name'],$_REQUEST['report_describe'],$_REQUEST['edit_report_url'],$_REQUEST['reportfile'],$_REQUEST['databaselinktype'],$_REQUEST['report_id']));

			//ｚｘｍ　2021-0830设置链接模块
			//$corpurl = $_SERVER['HTTP_ORIGIN']. rtrim($_SERVER['PHP_SELF'],'index.php');
			$tmpsystemdefault=0;
			if($databaselinktype=='crmlink')
			{
				$tmpsystemdefault=1;
			}
			if($report_type == 'template_flex'){
				$link_url = "CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=".$report_template."&default_report=".$tmpsystemdefault;
			}
			else if($report_type=='template_js')
			{
				$link_url = "CustomReport/JsReport/index.php?crm_report_key=".$report_template."&default_report=".$tmpsystemdefault."&report_name=".urlencode($report_name);
			}
			else{
				$link_url = $_REQUEST['edit_report_url'];
			}
			$linkmodulecheck = (isset($_REQUEST['setlinkmodule'])&&!empty($_REQUEST['setlinkmodule'])&&$_REQUEST['setlinkmodule']=="on")?"yes":"no";
			createLinkModule($report_name,$_REQUEST['report_id'],$link_url,$linkmodulecheck,$report_type);
		}
		require_once globalStatic::$root_directory.'/modules/ReportAnalysis/ReportAnalysisActions.php';
		$ReportAnalysisActionsObj = new ReportAnalysisActions();
		$list = $ReportAnalysisActionsObj->getReportInfo('Customreport',$_REQUEST['report_id']);
		$reportinfo = isset($list[0])?$list[0]:[];
		ConvertTojsonString(1,array('reportinfo'=>$reportinfo),"success");
	}else{
		$focus = CRMEntity::getInstance('Customreport');
		$folderAll = $focus->getFolderAll();
		//获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
		require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
		$ReportAnalysisActionsObj = new ReportAnalysisActions();
		$folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);

		$smarty->assign('REPORT_ID',$_REQUEST['report_id']);
		$smarty->assign('REPORT_NAME',$adb->query_result($result,0,'report_name'));
		$smarty->assign('REPORT_DESCRIBE',$adb->query_result($result,0,'report_describe'));
		$smarty->assign('REPORT_TYPE',$adb->query_result($result,0,'report_type'));
		$smarty->assign('REPORT_URL',$adb->query_result($result,0,'report_url'));
        $smarty->assign('REPORT_FILE',$adb->query_result($result,0,'report_file'));
		$smarty->assign('FOLDER_ID',$before_folder_id);
		$smarty->assign('FOLDER_ALL',$folderAll);
		$smarty->assign('analysisfolder_id',$analysisfolder_id);
		$smarty->assign('frommodule',$_REQUEST['frommodule']);
		$smarty->assign('folderOptions',$folderOptions);//zxm 20221109  报表分析模块新建报表库报表

        $smarty->assign("report_template",$adb->query_result($result,0,'report_template'));
        $smarty->assign("systemdefault",$adb->query_result($result,0,'systemdefault'));
        $smarty->assign("databaselinktype",$adb->query_result($result,0,'databaselinktype'));
	}
}



$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSIONACCOUNT',$version_info['account']);
$smarty->assign('MODULE',$currentModule);
//zxm 20240523 分屏报表需求
//$smarty->display("modules/Customreport/editCustomreport.tpl");
$content = $smarty->fetch("modules/Customreport/editCustomreport.tpl");
$res['title'] = getFixedLabel('EDITREPORT');
$res['content'] = $content;
$res['oktext'] = getFixedLabel('SAVE');
$res['cancel'] = getFixedLabel('CLOSE');
ConvertTojsonString(1,$res,"success");

//ｚｘｍ　2021-0830 创建或者编辑链接模块
function createLinkModule($report_name,$report_id,$report_url,$linkmodulecheck,$report_type){
	$url = $report_url;
	global $adb;
	$sql ='select * from ld_linkmodulecustom where  linkcvid =? and entitytype=? and linkmodule=?';
    if($report_type == 'finereport')
    {
        $result = $adb->pquery($sql,array($report_id,'customfine','Customreport'));
    }
    else
    {
        $result = $adb->pquery($sql,array($report_id,'custom','Customreport'));
    }
	$nums = $adb->num_rows($result);
	if($linkmodulecheck=='yes'){
		if($nums>0){  //设置里面自己添加的自定义模块
            $Id = $adb->query_result($result,0,'id');
			$sql='update ld_linkmodulecustom set zh_label=? ,en_label=? ,`scope`=? , url=? where id = ?';
			$adb->pquery($sql,array($report_name,$report_name,'all',$url,$Id));
		}else{
			$sql='insert into ld_linkmodulecustom(zh_label,en_label,url,`scope`,entitytype,linkmodule,linkcvid)value(?,?,?,?,?,?,?) ';
            if($report_type == 'finereport'){
                $adb->pquery($sql,array($report_name,$report_name,$url,'all','customfine','Customreport',$report_id));
            }
            else{
                $adb->pquery($sql,array($report_name,$report_name,$url,'all','custom','Customreport',$report_id));
            }
			
			$id = $adb->getLastInsertID();
			$adb->pquery("update ld_linkmodulecustom set name=? where id=?",array("CRMLinkModuleCustom".$id,$id));
		}
	}else{
		//删除菜单设置
		if($nums>0){
			$linkmoduleId = $adb->query_result($result,0,'id');
			//ld_parenttabrel
			$sql ='delete from ld_linkmodulecustom where id=?';
			$adb->pquery($sql,array($linkmoduleId));
			$sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
			$adb->pquery($sql2,array($linkmoduleId));
			//移动端菜单
			$sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
			$adb->pquery($sqlMobile,array($linkmoduleId));
			clearAllCaCheFiles();
		}
	}

}
?>
