<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
set_time_limit(0) ;
global $currentModule;
global $adb;
global $current_user;
require_once('modules/ModTracker/ModTracker.php');
require_once('modules/Reminds/Reminds.php');

$focus = CRMEntity::getInstance($currentModule);
$module_tablename = $focus->table_name;//当前模块的主表名
$module_tableindex = $focus->table_index;//当前模块的主表的ID
if(!isset($_REQUEST['massedit_recordids'])){
	//
}
$mass_allocate_totalrows=$_REQUEST['mass_allocate_totalrows'];

$idlist = vtlib_purify($_REQUEST['massedit_recordids']);

/***
更新操作
edit：cdw
date：20131210
reason;0005594: 个人权限用户在客户序时簿中，选中负责人为其他用户的单据，然后点击“修改负责人”按钮，将负责人修改为自己，结果程序报错。如附注
**/
$idlist = trim($idlist,';');
$id_before = explode(";",$idlist);
if(empty($mass_allocate_totalrows))
{
    $mass_allocate_totalrows=count($id_before);
}
$new_id_before = join(',',$id_before);


$viewid = vtlib_purify($_REQUEST['viewname']);
$return_module = vtlib_purify($_REQUEST['massedit_module']);
if(empty($return_module)){
	$return_module = (!empty($_REQUEST['return_module']))?$_REQUEST['return_module']:$_REQUEST['module'];
} 
$return_action = 'index';

if(isset($_REQUEST['return_action']) && !empty($_REQUEST['return_action']))
	$return_action = $_REQUEST['return_action'];

global $rstart;
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
	$rstart = "&start=".vtlib_purify($_REQUEST['start']);
}

//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$correct = 0;	//正确记录数
$error = 0;	//错误记录数
$edit_err = '';
$idArr = explode(';',rtrim($idlist,';'));
$entityarray = getEntitynameInfo(getTabid($currentModule));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
if(sizeof($idArr)>$btach_num)
    $batch_arr_ids=array_slice($idArr,0,$btach_num);
else
    $batch_arr_ids=$idArr;
  
 $tmp_tableName='allocate_tmp_'.$current_user->id;
 $sql=' drop table if exists  '.$tmp_tableName;
 $adb->pquery($sql, array());  

 $query = "create  table IF NOT EXISTS $tmp_tableName(id int(11) primary key) " ;
 $adb->pquery($query,array());
 $sql="insert into $tmp_tableName (id) values ("
         .implode ( "),(", $batch_arr_ids ) . ")";
        
 $adb->pquery($sql,array());    
   
$query = 'select '.$tabindex.' as id,'.$tabfieldname.' as subject,smownerid from '.$tabname.
" inner join $tmp_tableName on $tmp_tableName.id=$tabname.$tabindex ";

        //  ' where '.$tabindex.' in ('.implode(',',$batch_arr_ids).')';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
	$id = $adb->query_result($result,$i,'id');
	$subject[$id] = $adb->query_result($result,$i,'subject');
    $assOldOwnerID[] = $adb->query_result($result,$i,'smownerid');
    $old_smonwerids[$id]= $adb->query_result($result,$i,'smownerid');
}

if(isset($_REQUEST['assigned_user_id']) && $_REQUEST['assigned_user_id'] > 0){
	$userid = $_REQUEST['assigned_user_id'];
	$acctid = '';
	$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
	$batchtype = getFixedLabel('ALLOCATE');
    if('yes' != isPermitted($currentModule,'Allocate')) {
			$edit_err .= sprintf($batchlog,'<a href="javascript:;" module="'.$currentModule.'" record="'.$accountid.'"  onclick="ListLinkClick(ld(this),event)" >'.$subject[$accountid].'</a>',$batchtype,$batchtype).'<br>';
			$error++;
		}
        else
        {
               $columname='smownerid';
               $sql="SELECT fieldname FROM ld_field WHERE columnname = '$columname' AND ld_field.tabid =(select tabid from ld_tab where name='$module')";
               $assigned = $adb->query_result($adb->pquery($sql,array()),0,'fieldname');
            foreach($id_before as $key=>$accountid){
        		if($accountid == '') continue;
        		if($btach_num <= $key)break;
        		
        		    $oldsmownerid=$old_smonwerids[$accountid];
        			//$update = 'update '.$focus->table_name.' set smownerid = ? where '.$focus->table_index.' = ?; ';
        			//$adb->pquery($update,array($userid,$accountid));
        			//$adb->pquery('delete from ld_tabshare where crmid = ?',array($accountid));
                    if($oldsmownerid!=$userid){
        				$focus->getModuleStatic('ModTracker');//字段修改日志
                        
        				$focus->modstatic->saveFieldLogOne($currentModule,$assigned,$accountid,$oldsmownerid,$userid);
                        $focus->id=$accountid;
                        $focus->AddReminds();//edit:can 12084: 刘总建议：管理员给非管理员用户分配客户后，非管理员用户登录后没有弹出分配客户的温馨提醒
                    }
        			$edit_err .= sprintf($batchsuccesslog,'<a href="javascript:;" module="'.$currentModule.'" record="'.$accountid.'"  onclick="ListLinkClick(ld(this),event)" >'.$subject[$accountid].'</a>',$batchtype).'<br>';
        			$acctid .= $accountid.',';
        			$correct++;
        		}
        }
 	$update = 'update '.$focus->table_name." inner join $tmp_tableName on $tmp_tableName.id=".$focus->table_name.'.'.$focus->table_index ."  set smownerid = ? ";
   $adb->pquery($update,array($userid));
   $sqlDEL=" DELETE ld_tabshare FROM ld_tabshare,$tmp_tableName
           WHERE ld_tabshare.crmid=$tmp_tableName.id";
    $adb->pquery($sqlDEL,array());
    if($error == 0){
		$error = $mass_allocate_totalrows - $correct;
	}
     
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,$mass_allocate_totalrows,$correct,$error);
    //获取短信签名
    $SMSarray = GetSMSAutograph();
    $autograph = $SMSarray['autograph'];
                        
    /*
    andrew
    如果系统参数设置为是，客户分配时，也将客户的相关信息一同分配
    20141217
    */
    $deployarray=getSys_deploy(61);//获取系统参数设定
	if('Accounts' == $currentModule && !empty($acctid) && $deployarray['deploy_value'] == 'all'){
        $acctid = trim($acctid,',');
        $selectMouleSQL = "SELECT DISTINCT name FROM ld_tab WHERE
                            tabid IN (SELECT related_tabid FROM ld_relatedlists 
                            WHERE tabid=(SELECT tabid FROM ld_tab where name='Accounts') AND 
                            related_tabid NOT IN (SELECT tabid FROM ld_tab 
                            where name in ('Accounts','CommunicationLog','Emails'))
                            AND related_tabid<>0);";
        $selectMouleresult =$adb->pquery($selectMouleSQL,array());//获取客户相关信息模块名
            for($i=0;$adb->num_rows($selectMouleresult)>$i;$i++)
            {
                $modulename=$adb->query_result($selectMouleresult,$i,'name');
                $entityname=getEntitynameByModulename($modulename);
                $tablename=$entityname['tablename'];//获取相关信息主表名
                if($tablename!=''&&$modulename!=''){
                    //echo $modulename;
				//获取LD_field负责人的fieldname
                    $field_obj=Field::getInstance($modulename,$adb);
                    $columname=$focus->getSmownerColumName();
				    $fieldname = $field_obj->getFieldInfoBykeyValue('columnname',$columname,'fieldname');
                    $relatedEntityname = getEntitynameByModulename($modulename);
    				$related_tablename = $relatedEntityname['tablename'];
				    $related_tableindex = $relatedEntityname['entityidfield'];
					if(!empty($relatedEntityname['entityidfield'])){
						if($modulename == 'Products'){
							$query = 'select productid from ld_seproductsrel where crmid = ?';
						}else if($modulename == 'Documents'){
							$query = 'select notesid from ld_senotesrel where crmid = ?';
						}else if($modulename == 'Campaigns'){
						  $query = 'select campaignid from ld_campaignaccountrel where accountid = ?';
						}
                        else if($modulename=='Attachment')
                        {
                            $query = 'select attachmentsid from ld_attachmentsforbills where related_to = ?';
                        }
                        else{
							$query = 'select ' . $related_tableindex . ' from ' . $related_tablename . ' where ' . $module_tableindex . ' = ? ';	
						}
                    }
                    $related_result = $adb->pquery($query,array($acctid));
                    $related_num_rows = $adb->num_rows($related_result);
                     //echo $related_result->sql.';<br>';
 					if($related_num_rows > 0){
						for($j = 0; $j<$related_num_rows; $j++){
							$rec_id = $adb->query_result($related_result,$j,0);
							//获取单据变更前的负责人ID
							 $getSmownerId = 'select smownerid from '.$related_tablename.' where '.$related_tableindex.' = '.$rec_id.' limit 1';
							// echo $getSmownerId.'<br>';
                             $SmownerResult = $adb->pquery($getSmownerId,array());
                            
                                $old_smownerid = $adb->query_result($SmownerResult,0,0);
                                //echo $modulename.'|'.$fieldname.'|'.$rec_id.'|'.$old_smownerid.'|'.$userid."<br>";
							  
							 if($old_smownerid != $userid){
							    // echo $modulename.'|'.$fieldname.'|'.$rec_id.'|'.$old_smownerid.'|'.$userid."<br>";
								$focus->modstatic->saveFieldLogOne($modulename,$fieldname,$rec_id,$old_smownerid,$userid);
							 }
						}
					}
                    
                    //$update = 'update '.$tablename.' set smownerid = '.$userid.'  where accountid in ('.$acctid.') and deleted = 0 ';
                    //$adb->pquery($update,array());
                    $update = 'update '.$tablename." inner join $tmp_tableName on $tmp_tableName.id=$tablename.accountid  set smownerid = ".$userid.'  where deleted = 0 ';
                    if($modulename=='Documents')
                    $update = 'update '.$tablename." INNER JOIN ld_senotesrel ON ld_senotesrel.notesid = ld_notes.notesid
                     inner join $tmp_tableName on $tmp_tableName.id=ld_senotesrel.crmid  set smownerid = ".$userid.'  where deleted = 0 ';
                    if($modulename=='Campaigns'){
                        $update = 'update '.$tablename." INNER JOIN ld_campaignaccountrel ON ld_campaignaccountrel.campaignid = ld_campaign.campaignid
                     inner join $tmp_tableName on $tmp_tableName.id=ld_campaignaccountrel.accountid  set smownerid = ".$userid.'  where deleted = 0 ';
                  
                    }
                    else if($modulename=='Products'){
                        $update = 'update '.$tablename." INNER JOIN ld_seproductsrel ON ld_seproductsrel.productid = ld_products.productid
                     inner join $tmp_tableName on $tmp_tableName.id=ld_seproductsrel.crmid  set smownerid = ".$userid.'  where deleted = 0 ';
                  
                    }
                    else if($modulename=='Attachment')
                    {
                             $update = 'update '.$tablename.
                            " inner join $tmp_tableName on $tmp_tableName.id=ld_attachmentsforbills.related_to  set smownerid = ".$userid.'  where deleted = 0 ';
                            
                    }

                    $adb->pquery($update,array());
                }
                //unset($field_obj);
            }
			//更改相关信息模块单据的负责人ID
			//UpdateRelatedListModuleSmownerid($currentModule,$acctid,$userid);
    }
}
$query = "create  table IF NOT EXISTS $tmp_tableName(id int(11) primary key) " ;
    $adb->pquery($query,array());
//$parenttab = getParentTab();
$parenttab = '';
$SearchScope=$_REQUEST['SearchScope'];
if(isset($_SESSION['lvs'][$currentModule]['viewname'])){
	$viewid = $_SESSION['lvs'][$currentModule]['viewname'];
	$start = $_SESSION['lvs'][$currentModule][$viewid]['start'];
}
if(!$start) $start = 1;
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
/**
 * 更新操作
 *edit:can
 * date:20131228
 * reason:发送短信
 * other:6535: 客户序时簿界面，选择多个客户信息，点击“修改负责人”，弹出层点击保存，出错，如图：
 * */
 $massHref="index.php?module=$return_module&action=$return_action&parenttab=$parenttab$rstart&SearchScope=$SearchScope&query_session=1";

if($return_action == 'DetailView'){
	$massHref .= '&record='.$_REQUEST['massedit_recordids'];
}
$_REQUEST['id']=$new_id_before;
$_REQUEST['sendSms']=implode(',',$assOldOwnerID);

//0018046: 客户明细界面：增加【分配时间】字段，分配修改负责人后记录分配时间
if($new_id_before!='')
{
    $update_query = "update ld_account set distributiondate=? where accountid in ($new_id_before)";
    $update_params = array(date("Y-m-d H:i:s"));
    $adb->pquery($update_query, $update_params);
}
include("modules/Accounts/Accountalertmsg.php");

$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
?>