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
if(!empty($_REQUEST['report_save']) && $_REQUEST['report_save'] == 'yes'){
	if(empty($_REQUEST['report_id'])){
		$frommodule = $_REQUEST['frommodule'];
		$analysisfolder_id = vtlib_purify($_REQUEST['analysisfolder_id']);
		//zxm 20221109  报表分析模块新建报表库报表
		if(!empty($frommodule)&&$frommodule=='ReportAnalysis'){
			$query = 'select ifnull(max(sequence),0) as sequence,max(report_id) as max_report_id from ld_customreport_info where analysisfolder_id = ?';
			$res = $adb->pquery($query,array($_REQUEST['analysisfolder_id']));
		}else{
			//之前的逻辑
			$query = 'select ifnull(max(sequence),0) as sequence,max(report_id) as max_report_id from ld_customreport_info where folder_id = ?';
			$res = $adb->pquery($query,array($_REQUEST['folder_id']));
		}

		$sequence = $adb->query_result($res,0,'sequence');
		$max_report_id = $adb->query_result($res,0,'max_report_id');
		$report_name = vtlib_purify($_REQUEST['report_name']);
		$report_describe = vtlib_purify($_REQUEST['report_describe']);
		$report_type = vtlib_purify($_REQUEST['report_type']);
		$radioUser = vtlib_purify($_REQUEST['radioUser']);
		$folder_id = vtlib_purify($_REQUEST['folder_id']);
        $databaselinktype=vtlib_purify($_REQUEST['databaselinktype']);
		if($report_type=='template'){
			$file_name = $_FILES['report_file']['name'];
			$file_size = $_FILES['report_file']['size'];
			if(empty($file_name)){
				$_REQUEST['diony']='diony';
				ConvertTojsonString(-1,array(),getFixedLabel('LBL_PLEASE_SELECT') . getFixedLabel('TEMPLATEREPORT') . '  (' . getFixedLabel('STYLE') . ':  .mrt' . ')');
			}
			//限制上传格式
			$file_type = strstr($file_name, '.'); 
			if($file_type != '.mrt'){
				$_REQUEST['diony']='diony';
				ConvertTojsonString(-1,array(),getFixedLabel('TEMPLATEREPORT') . getFixedLabel('FILE') . getFixedLabel('STYLE') . getFixedLabel('error'));
			}
			//零字节
			if(empty($file_size)){
				$_REQUEST['diony']='diony';
				ConvertTojsonString(-1,array(),getFixedLabel('THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT'));
			}

			//判断在对应文件夹下有没有已使用过该模板 20231213 weiyannan XUQIU1002182
			$query = "SELECT * FROM ld_customreport_info WHERE analysisfolder_id =" . $analysisfolder_id . " AND report_template = '" . $file_name . "'";
			$result = $adb->pquery($query);
			$path = "templatePrintFile/reports/".$file_name;
			if ($adb->num_rows($result) == 0 && !file_exists($path)) {
				//没查询到结果说明该模板没用过,直接使用源文件名称
				$new_file_name = $file_name;
			} else {
				//查询到结果说明该模板已使用过
				$choice = $_REQUEST['choice'];
				if($choice=='CONTINUE'){
					$new_file_name = 'CustomReport_' . $analysisfolder_id . '_' . $max_report_id . $file_type;
				}elseif ($choice=='SAVE'){
					$new_file_name = $file_name;
				}else{
					ConvertTojsonString(-2, array(), '');
					//重名名附件名称('CustomReport'+文件夹id+报表明细表的最大id)
					$max_report_id = $max_report_id + 1;
					if (!empty($frommodule) && $frommodule == 'ReportAnalysis') {
						//zxm 20221109  报表分析模块新建报表库报表
						$new_file_name = 'CustomReport_' . $analysisfolder_id . '_' . $max_report_id . $file_type;
					} else {
						$new_file_name = 'CustomReport_' . $folder_id . '_' . $max_report_id . $file_type;
					}
				}
			}

			//上传路径
			$path = "templatePrintFile/reports/";
			if(!file_exists($path)){
				mkdir ("templatePrintFile/reports");
			}
			$upload_file = @move_uploaded_file($_FILES['report_file']['tmp_name'], mb_convert_encoding($path . $new_file_name,'gb2312','UTF-8'));
			if(!$upload_file){
				echo getFixedLabel('FILEUPLOADPROBLEMS');
				exit();
			}
            $mrt_content=file_get_contents(globalStatic::$root_directory.$path.$new_file_name);
            $tmparr= json_decode($mrt_content,true);
          
            if(is_array($tmparr))
            {
                $template_report_type='template_js';
            }
            else
            {
                $template_report_type='template_flex';
            }
			$query = 'insert into ld_customreport_info(report_name,folder_id,report_describe,report_type,report_template,sequence,allocatetype,databaselinktype,analysisfolder_id,smcreatorid,createdtime) values (?,?,?,?,?,?,?,?,?,?,?);';
			$adb->pquery($query,array($report_name,$folder_id,$report_describe,$template_report_type,$new_file_name,$sequence+1,$radioUser,$databaselinktype,$analysisfolder_id,$current_user->id,date('Y-m-d H:i:s')));
		}
        else if($report_type == 'finereport')
        {
            $report_file = $_REQUEST['reportfile'];
            $report_url = $_REQUEST['reportserveraddress'];
            $query = 'insert into ld_customreport_info(report_name,folder_id,report_describe,report_type,report_url,report_file,sequence,allocatetype,analysisfolder_id,smcreatorid,createdtime) values (?,?,?,?,?,?,?,?,?,?,?);';
			$adb->pquery($query,array($report_name,$folder_id,$report_describe,$report_type,$report_url,$report_file,$sequence+1,$radioUser,$analysisfolder_id,$current_user->id,date('Y-m-d H:i:s')));
        }
        else{
			$report_url = $_REQUEST['report_url'];
			$preg='|^http://|';  //正则，匹配以http://开头的字符串
			if(preg_match($preg,$report_url)) {
				$report_url = str_replace("http://","",$report_url);
			}
			$query = 'insert into ld_customreport_info(report_name,folder_id,report_describe,report_type,report_url,sequence,allocatetype,analysisfolder_id,smcreatorid,createdtime) values (?,?,?,?,?,?,?,?,?,?);';
			$adb->pquery($query,array($report_name,$folder_id,$report_describe,$report_type,$report_url,$sequence+1,$radioUser,$analysisfolder_id,$current_user->id,date('Y-m-d H:i:s')));
		}
		$report_id=$adb->getLastInsertID();
		//分配用户
		if(!empty($_REQUEST['create_selectuser'])){
			$selectuser = $_REQUEST['create_selectuser'];	
			$users = explode(',',$selectuser);
			for($i = 0;$i<count($users); $i++){
				$query = 'insert into ld_customreport2user(report_id,userid) value (?,?)';
				$adb->pquery($query,array($report_id,$users[$i]));
			}
		}
		$_REQUEST['diony']='diony';
		//ｚｘｍ　2021-0830设置链接模块
		$tmpsystemdefault=0;
		if($databaselinktype=='crmlink')
		{
			$tmpsystemdefault=1;
		}
		//corpurl
		//$corpurl = $_SERVER['HTTP_ORIGIN']. rtrim($_SERVER['PHP_SELF'],'index.php');
		if($template_report_type == 'template_flex'){

			$link_url = "CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=".$new_file_name."&default_report=".$tmpsystemdefault;
		} else if($template_report_type=='template_js')
		{
			$link_url = "CustomReport/JsReport/index.php?crm_report_key=".$new_file_name."&default_report=".$tmpsystemdefault."&report_name=".urlencode($report_name);
		} else{
			$link_url = $report_url;
		}
		$linkmodulecheck = (isset($_REQUEST['setlinkmodule'])&&!empty($_REQUEST['setlinkmodule'])&&$_REQUEST['setlinkmodule']=="on")?"yes":"no";
		createLinkModule($report_name,$report_id,$link_url,$linkmodulecheck,$report_type);
		//zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
		unsetCache('pinyinAlllabel_zh');
		unsetCache('pinyinAlllabel_en');
		ConvertTojsonString(1,array(),"success");
	}
}
//获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
$ReportAnalysisActionsObj = new ReportAnalysisActions();
$folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($_REQUEST['analysisfolder_id']);

$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSIONACCOUNT',$version_info['account']);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('FOLDER_ID',$_REQUEST['folder_id']);
$smarty->assign('frommodule',$_REQUEST['frommodule']);
$smarty->assign('folderOptions',$folderOptions);//zxm 20221109  报表分析模块新建报表库报表
$content = $smarty->fetch("modules/Customreport/createCustomreport.tpl");
$res['title'] = getFixedLabel('CREATE').getFixedLabel('TEMPLATE').getFixedLabel('Table');
$res['content'] = $content;
$res['oktext'] = getFixedLabel('SAVE');
$res['cancel'] = getFixedLabel('CLOSE');
ConvertTojsonString(1,$res,"success");

//ｚｘｍ　2021-0830创建链接模块
function createLinkModule($report_name,$report_id,$report_url,$linkmodulecheck,$reprot_type)
{
	$url = $report_url;
	global $adb;
	if ($linkmodulecheck == 'yes') {
	   if($reprot_type == 'finereport')
       {
            $sql = 'insert into ld_linkmodulecustom(zh_label,en_label,url,`scope`,entitytype,linkmodule,linkcvid)value(?,?,?,?,?,?,?) ';
    		$adb->pquery($sql, array($report_name, $report_name, $url, 'all', 'customfine', 'Customreport', $report_id));
    		$id = $adb->getLastInsertID();
    		$adb->pquery("update ld_linkmodulecustom set name=? where id=?", array("CRMLinkModuleCustom" . $id, $id));
       }
       else
       {
            $sql = 'insert into ld_linkmodulecustom(zh_label,en_label,url,`scope`,entitytype,linkmodule,linkcvid)value(?,?,?,?,?,?,?) ';
    		$adb->pquery($sql, array($report_name, $report_name, $url, 'all', 'custom', 'Customreport', $report_id));
    		$id = $adb->getLastInsertID();
    		$adb->pquery("update ld_linkmodulecustom set name=? where id=?", array("CRMLinkModuleCustom" . $id, $id));
       }
	}
}
?>
