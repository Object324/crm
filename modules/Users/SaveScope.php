<?php
/**
 * edit:andrew
 * date:2015-6-19
 * reason:保存授权范围
 * 流程说明
 * 1。删除全选选择部门或用户的模块（单独设置除外）
 * 2。插入新的选择（单独设置除外）
 * 3。删除并插入所有模块的设置
 * 4。单独选择的范围数据删除和插入
 **/

global $current_user,$adb;
if($_REQUEST['uid']){
    $uid = $_REQUEST['uid'];
}
$viewothers_module=json_decode($_REQUEST['viewothers'],true);
$viewcreateme_module=json_decode($_REQUEST['viewcreateme'],true);


$editothers_module=json_decode($_REQUEST['editothers'],true);
$editcreateme_module=json_decode($_REQUEST['editcreateme'],true);

$delothers_module=json_decode($_REQUEST['delothers'],true);
$viewselfbills_module=json_decode($_REQUEST['viewselfbills'],true);

$moduleRecord = $_REQUEST['moduleRecord'];//选择的用户或部门id--各模块
$modueltype = $_REQUEST['modueltype'];//部门还是用户的数组
$moduleRecord = json_decode($moduleRecord,TRUE);
$modueltype = json_decode($modueltype,TRUE);
if($_REQUEST['ODuplicateID']!=''){//复制
    $ODuplicateID = $_REQUEST['ODuplicateID'];
    $SQL = 'select scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills,viewcreateme,editcreateme FROM ld_setscoperhigher WHERE userid=?';
    $query = $adb->pquery($SQL,array($ODuplicateID));
    $num_rows = $adb->num_rows($query);
    $insetSQL = 'INSERT INTO ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills,viewcreateme,editcreateme) VALUES ';
    for($i = 0; $i<$num_rows; $i++)
    {
        $scopeauthority=$adb->query_result($query,$i,'scopeauthority');
        $modulename=$adb->query_result($query,$i,'modulename');
        $viewothers=$adb->query_result($query,$i,'viewothers');
        $editothers=$adb->query_result($query,$i,'editothers');
        $delothers=$adb->query_result($query,$i,'delothers');
        $viewselfbills=$adb->query_result($query,$i,'viewselfbills');
        $viewcreateme=$adb->query_result($query,$i,'viewcreateme');
        $editcreateme=$adb->query_result($query,$i,'editcreateme');
        $insetSQL.="($uid,$scopeauthority,'$modulename','$viewothers','$editothers','$delothers','$viewselfbills',$viewcreateme,$editcreateme),";
    }
        $insetSQL = substr($insetSQL,0,-1); 
        $adb->pquery($insetSQL,array());


    $SQL = 'select userid,viewid,scopeauthority,modulename FROM ld_scoperhigher WHERE userid=?';
    $query = $adb->pquery($SQL,array($ODuplicateID));
    $num_rows = $adb->num_rows($query);
    $insetSQL = 'INSERT INTO ld_scoperhigher(userid,viewid,scopeauthority,modulename) VALUES ';
    for($i = 0; $i<$num_rows; $i++)
    {
        $viewid=$adb->query_result($query,$i,'viewid');
        $scopeauthority=$adb->query_result($query,$i,'scopeauthority');
        $modulename=$adb->query_result($query,$i,'modulename');
        $insetSQL.="($uid,$viewid,$scopeauthority,'$modulename'),";
    }
    $insetSQL = substr($insetSQL,0,-1); 
    $adb->pquery($insetSQL,array()); 
}

if(!empty($modueltype)){
   
    //各模块授权范围类型
    foreach($modueltype as $key=>$arr){
		$str = explode(',',$arr);
		$modulelist[$str[0]]=$str[1];
    }
	//插入用户模块授权范围类型
    if($uid=='all')
    {
        $deployarray=getSys_deploy(67);
        $btach_num =  $deployarray['deploy_value'];
        $_REQUEST['mass_batch_num_all']=$btach_num;
       $uids= getSelectedRecords($_REQUEST,"Users","all","");
      
    }
    else
    {
        $uid=trim($uid,";");
        $uids=explode(';',$uid);
    }

    foreach($uids as $uid)
    {
                $adb->pquery('DELETE FROM ld_setscoperhigher WHERE userid= ?',array($uid));
            	$insetSQL = 'INSERT INTO ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills,viewcreateme,editcreateme) VALUES ';
                foreach($modulelist as $key=>$arr){
                    $viewothers=$viewothers_module[$key];
                    $editothers=$editothers_module[$key];
                    $delothers=$delothers_module[$key];
                    $viewselfbills=$viewselfbills_module[$key];
                    $viewcreateme=$viewcreateme_module[$key];
                    $editcreateme=$editcreateme_module[$key];
                    
                    $insetSQL.="($uid,$arr,'$key','$viewothers','$editothers','$delothers','$viewselfbills',$viewcreateme,$editcreateme),";
                }
                $insetSQL = substr($insetSQL,0,-1);
                $adb->pquery($insetSQL,array());
            
            	if(!empty($moduleRecord)){
            		//插入用户模块授权范围值
            		$adb->pquery('DELETE FROM ld_scoperhigher WHERE userid= ?',array($uid));
            		$insetSQL = 'INSERT INTO ld_scoperhigher(userid,viewid,scopeauthority,modulename) VALUES ';
                    //edit:can 20210726 47122: 修改用户数据范围：设置为全部、个人、按部门，切换几次之后，ld_scoperhigher 表中出现很多重复数据
                    $selectUser=[];
            		foreach($moduleRecord as $module=>$arr){
            			$str = explode(',',$arr);
            			foreach($str as $key => $selectuserid){
            				if($key >= 1){
            					$selectUser[$str[0]][] = $selectuserid;
            				}
            			}
            		}
                    $tmp_insetSQL = '';
            		foreach($selectUser as $module => $userids){
            			foreach($userids as $userid){
            				if(!empty($userid)){
            					$scopeauthority = $modulelist[$module];
                                $tmp_insetSQL.="($uid,$userid,$scopeauthority,'$module'),";
            				}
            			}
            		}
                    if (!empty($tmp_insetSQL)) { //原逻辑的values 后面没有数据,sql报错
                        $insetSQL = substr($insetSQL.$tmp_insetSQL,0,-1);

                        $adb->pquery($insetSQL,array());
                    }

            }
			//全部
			if(isset($_REQUEST['all_scope'])){
				if($_REQUEST['all_scope'] == 0 || $_REQUEST['all_scope'] == 1){
					$insetSQL = 'INSERT INTO ld_scoperhigher(userid,viewid,scopeauthority,modulename) VALUES (?,?,?,?)';
					$adb->pquery($insetSQL,array($uid,0,$_REQUEST['all_scope'],'All'));
				}else{
					if(!empty($_REQUEST['all_scopeid'])){
						$scopeids = explode(',',$_REQUEST['all_scopeid']);
						foreach($scopeids as $id){
							$insetSQL = 'INSERT INTO ld_scoperhigher(userid,viewid,scopeauthority,modulename) VALUES (?,?,?,?)';
							$adb->pquery($insetSQL,array($uid,$id,$_REQUEST['all_scope'],'All'));
						}
					}
				}
			}
			//zkt 20230403 BUG0063944 成员管理，修改数据范围后，需要更新“更新时间”和“最新更新人” 
            $updateSQL = 'update ld_users set modifiedtime=NOW(),modifiedby=? where id = ?;';
			$adb->pquery($updateSQL,array($current_user->id,$uid));
	          
	}
	if($_REQUEST['mode']!='create'){
	   if($_REQUEST['SaveScopeajaxsave'] == 'yes'){
		  ConvertTojsonString(1,array(),'success');
       }
       else{
            exit();
       }
	} 
}
if($_REQUEST['SaveScopeajaxsave'] == 'yes'){
    ConvertTojsonString(1,array(),'success');
}
   //公海未分配客户不控制数据权限（可查询所有公海未分配客户）)0：不控制，1：控制
    /*$status=getAccount_Set('status');
    $dataprofile=getAccount_Set('dataprofile');
    if($status==1||$dataprofile==0)
    {
        //公海未分配客户的数据权限
        $SQL='delete from ld_setscoperhigher where modulename=?';
        $adb->pquery($SQL,array(NOALLOCATEACCOUNTS));
         $SQL='delete from ld_scoperhigher where modulename=?';
        $adb->pquery($SQL,array(NOALLOCATEACCOUNTS));
        $SQL="insert into ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills,viewcreateme,editcreateme)
        select userid,scopeauthority,'".NOALLOCATEACCOUNTS."',viewothers,editothers,delothers,viewselfbills,viewcreateme,editcreateme from ld_setscoperhigher  where modulename='Accounts'
        and  not EXISTS (select userid from ld_setscoperhigher where modulename='".NOALLOCATEACCOUNTS."');
        ";
        $adb->pquery($SQL,array());
        
        $SQL="insert into ld_scoperhigher(userid,viewid,scopeauthority,modulename)
            select userid,viewid,scopeauthority,'".NOALLOCATEACCOUNTS."' from ld_scoperhigher where  modulename='Accounts'
            and  not EXISTS (select userid from ld_scoperhigher where modulename='".NOALLOCATEACCOUNTS."');";
         $adb->pquery($SQL,array());
           
    }*/

?>