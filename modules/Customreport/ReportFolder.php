<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * 定制报表的操作按钮事件保存方法	2016-03-01

 * Description:  Chj To be written.

 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.

 * All Rights Reserved.

 * Contributor(s): ______________________________________..

 ********************************************************************************/

if(!empty($_REQUEST['type'])){
	$result = '';
	$type = vtlib_purify($_REQUEST['type']);
	if(!empty($_REQUEST['folder_name'])){
		$folder_name = vtlib_purify($_REQUEST['folder_name']);
	}
	if(!empty($_REQUEST['folderid_str'])){
		$folderid_str = vtlib_purify($_REQUEST['folderid_str']);
	}
	if(!empty($_REQUEST['reportid_str'])){
		$reportid_str = vtlib_purify($_REQUEST['reportid_str']);
	}
	if(!empty($_REQUEST['folder_id'])){
		$folder_id = vtlib_purify($_REQUEST['folder_id']);
	}
	if(!empty($_REQUEST['report_id'])){
		$report_id = vtlib_purify($_REQUEST['report_id']);
	}
	if(!empty($_REQUEST['selectUser'])){
		$selectUser = vtlib_purify($_REQUEST['selectUser']);
	}
	if($_REQUEST['allocatetype'] != ''){
		$allocatetype = $_REQUEST['allocatetype'];
	}
	if($_REQUEST['folderid_showFolder'] != ''){
		$folderid_showFolder = $_REQUEST['folderid_showFolder']; //显示报表中选中的报表id
	}
	switch($type){
		case 'addFolder':
		   $result = addFolder($folder_name);
		   break;
		case 'sortFolder':
		   sortFolder($folderid_str);
		   break;
		case 'sortReport':
		   sortReport($reportid_str);
		   break;
		case 'renameFolder':
		   $result = renameFolder($folder_id,$folder_name);
		   break;
		case 'deleteFolder':
		   $result = deleteFolder($folder_id);
		   break;
		case 'deleteReport':
		   $result = deleteReport($report_id);
		   break;
		case 'editReport':
		   editReport($report_id,$allocatetype,$selectUser);
		   break;
        case 'hideFolder'://隐藏文件夹
           $result = hideFolder($folder_id);
           break;
        case 'showFolder'://显示文件夹
           $result = showFolder($folderid_showFolder);
           break;
        case 'hideReport'://隐藏报表
           $result = hideReport($report_id);
           break;
        case 'showReport'://显示报表
           $result = showReport($reportid_str);
           break;
	}
	echo $result;
	die;
}
//添加文件夹
function addFolder($folder_name = '') {
	global $adb;
	if(!empty($folder_name)){
		$query = 'select 1 from ld_customreport_folder where folder_name = ?';
		$result = $adb->pquery($query,array($folder_name));
		if($adb->num_rows($result) >= 1){
			return 'error';
		}else{
			$sequence = 0;
			$query = 'select max(sequence) as sequence from ld_customreport_folder';	
			$result = $adb->pquery($query,array());
			if($adb->num_rows($result) >= 1){
				$sequence = $adb->query_result($result,$i,'sequence');
			}
			$query = 'insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible) value (?,?,?,?)';
			$adb->pquery($query,array($folder_name,$sequence+1,0,0));
		}
	}
	return '';
}
//文件夹排序
function sortFolder($folderid_str){
	global $adb;
	if(!empty($folderid_str)){
		$folderids = explode(';',$folderid_str);
		for($i = 0; $i<count($folderids); $i++){
			if(!empty($folderids[$i])){
				$adb->pquery('update ld_customreport_folder set sequence = ? where id = ? limit 1',array($i+1,$folderids[$i]));
			}
		}
	}
}
//报表排序
function sortReport($reportid_str){
	global $adb;
	if(!empty($reportid_str)){
		$reportids = explode(';',$reportid_str);
		for($i = 0; $i<count($reportids); $i++){
			if(!empty($reportids[$i])){
				$adb->pquery('update ld_customreport_info set sequence = ? where report_id = ? limit 1',array($i+1,$reportids[$i]));
			}
		}
	}
}
//重命名报表
function renameFolder($folder_id,$folder_name){
	global $adb;
	if(!empty($folder_id) && !empty($folder_name)){
		$query = 'select 1 from ld_customreport_folder where folder_name = ? and id != ?';
		$result = $adb->pquery($query,array($folder_name,$folder_id));
		if($adb->num_rows($result) >= 1){
			return 'error';
		}else{
			$query = 'update ld_customreport_folder set folder_name = ? where id = ?';
			$adb->pquery($query,array($folder_name,$folder_id));
		}
	}
	return '';
}
//删除文件夹
function deleteFolder($folder_id){
	global $adb;
	if(!empty($folder_id)){
		$query = 'select systemdefault as systemdefault from ld_customreport_folder where id = ? limit 1';
		$result = $adb->pquery($query,array($folder_id));
        $result_nums=$adb->num_rows($result);
		if($result_nums > 0){
		  for($i=0;$i<$result_nums;$i++){
		      $systemdefault = $adb->query_result($result,0,'systemdefault');
		  }
	       if($systemdefault == 1){ //系统默认的文件夹不允许被删除
                echo "alert('系统预置的报表文件夹不允许删除！')";
                exit();
	       }else{
                $query = 'delete from ld_customreport_folder where id = ? and systemdefault<> 1';
                $adb->pquery($query,array($folder_id));
	       }
		}else{
			return 'error';
		}
	}
}

//隐藏文件夹
function hideFolder($folder_id){
	global $adb;
	if(!empty($folder_id)){
		$query = 'update ld_customreport_folder set visible=1 where id=?';
		$result = $adb->pquery($query,array($folder_id));
	}
}

//隐藏报表
function hideReport($report_id){
	global $adb;
	if(!empty($report_id)){
		$query = 'update ld_customreport_info set presence=5 where report_id=?';
		$result = $adb->pquery($query,array($report_id));
	}
}

//显示报表
function showReport($reportid_str){
	global $adb;
	if(!empty($reportid_str)){
		$query = 'update ld_customreport_info set presence=0 where report_id in('.$reportid_str.')';
		$result = $adb->pquery($query,array());
	}
}

//显示文件夹
function showFolder($folderid_showFolder){
	global $adb;
	if(!empty($folderid_showFolder)){
        $query = 'update ld_customreport_folder set visible=0 where id in('.$folderid_showFolder.')';
        $result = $adb->pquery($query,array());
	}
}


//删除报表
function deleteReport($report_id){
	global $adb;
	if(!empty($report_id)){
		$query = 'select report_type,folder_id from ld_customreport_info where report_id = ? limit 1';
		$result = $adb->pquery($query,array($report_id));
		if($adb->num_rows($result) >= 1){
			$report_type = $adb->query_result($result,0,'report_type');
			$folder_id = $adb->query_result($result,0,'folder_id');
			//如果是报表模板，删除对应目录下报表模板
			if($report_type == 'template'){
				$path = 'templatePrintFile/report/CustomReport_' . $folder_id . '_' . $report_id . '.mrt';
				unlink($path);
			}
			$query = 'delete from ld_customreport_info where report_id = ?';
			$adb->pquery($query,array($report_id));
			//zxm  2021-0830 删除链接模块
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
			if($nums>0){
				$linkmoduleId = $adb->query_result($result,0,'id');
				//ld_parenttabrel
				$sql ='delete from ld_linkmodulecustom where id = ?';
				$adb->pquery($sql,array($linkmoduleId));
				$sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
				$adb->pquery($sql2,array($linkmoduleId));
				clearAllCaCheFiles();
			}
		}else{
			return 'error';
		}
	}
}
//报表分配
function editReport($report_id,$allocatetype,$selectUser){
	global $adb;
	if(!empty($report_id) && !empty($selectUser)){
		//更新报表的分配类型
		$adb->pquery('update ld_customreport_info set allocatetype = ? where report_id = ?',array($allocatetype,$report_id));
		//删除原先的报表分配用户
		$adb->pquery('delete from ld_customreport2user where report_id = ?',array($report_id));
		//插入
		$users=  explode(',', $selectUser);
		for($i = 0; $i<count($users); $i++){
			$adb->pquery('insert into ld_customreport2user(report_id,userid) value (?,?)',array($report_id,$users[$i]));	
		}
	}
}
?>
