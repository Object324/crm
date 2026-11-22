<?php
global $adb,$current_user;
$error = 0;
$success = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$batchsuccesslog = getFixedLabel('RELEASESUCCESS');
//获取模块链接字段
$entityarray = getEntitynameInfo(getTabid('Leads'));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$focus=CRMEntity::getInstance($currentModule);
$smcolumnname=$focus->getSmownerColumName();
$field_obj=$focus->fieldobj->getFieldInfoobjBykey('columnname',$smcolumnname);
$assigned=$field_obj->getFieldName();
$pool_id = $_REQUEST['pool_id'];	//公海池id
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicAccounts = new cls_PublicLeads($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
$public_account_pool = $public_account['public_account_pool'][$pool_id];
if($_REQUEST['idstring'] && !empty($public_account_pool))
{
    //$storearray=explode(";",$_REQUEST['idstring']);
   // $storearray=array_filter($storearray);
    $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
    $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
    $storearray=array_filter($storearray);
    $opdate=date("Y-m-d H:i:s");
    $module='Leads';
    foreach($storearray as $key => $id)
    {
        if($btach_num <= $key)break;
        if(empty($id) || $id <=0)continue;
        //chj 2021/3/18 批量释放错误，没有任何提示：问题原因：客户模块的超链接字段改成了自定义字段
        $query = "select $tabfieldname as subject from ld_leads LEFT JOIN ld_leadscf on 
            ld_leads.leadsid = ld_leadscf.leadsid where ld_leads.leadsid = ?";
            
        $result = $adb->pquery($query,array($id));
        $subject = $adb->query_result($result,0,'subject');
        //公海已分配客户释放后，更改客户负责人为（为空表示不更改） 
        if($public_account_pool['userid_after_release'] > 0){
            $recordid=$id;
            $userid=$public_account_pool['userid_after_release'];
            $focus->retrieve_entity_info($recordid,"Leads");
            $old_assign_userid=$focus->column_fields[$assigned];
            $sql="update ld_leads set allocatedate=null,protectdate=null,protectstartdate=null,publicaccount=1,smownerid=".$userid." where leadsid=? ";
            $adb->pquery($sql,array($id));
            //bug:23911 edit:cyb date:2016-08-15 reason:修改日志和销售负责人变更历史是否没有记录销售负责人变更历史
            if($old_assign_userid != $userid){
                $focus->getModuleStatic('ModTracker');//字段修改日志/变更销售负责人
                $focus->modstatic->saveFieldLogOne($module,$assigned,$recordid,
                $old_assign_userid,$userid);
            }
        }
        else{
            $sql="update ld_leads set allocatedate=null,protectdate=null,protectstartdate=null,publicaccount=1 where leadsid=? ";
            $adb->pquery($sql,array($id));
        }
        $operation="TORELEASETHECUSTOMERTOTHEHIGNSEAS";

        // GYQ1230
        $operation .= '$####$'.$_REQUEST['releaseAccountReasons'];

        $sql="insert into ld_logpublicleads(username,Operation,Opdate,leadsid,userid,pool_id)values(?,?,?,?,?,?)";
        $adb->pquery($sql,array($current_user->last_name,$operation,$opdate,$id,$current_user->id,$pool_id));
        //系统操作日志
        $logid = $adb->getLastInsertID();
        crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveLogs('Leads','Release',$id,'',$logid);
        //单据[%s]释放成功！
        $edit_err .= sprintf($batchsuccesslog,'<a href="javascript:;" module="Leads" record="'.$id.'"  onclick="ListLinkClick(ld(this),event)" >'.$subject.'</a>').'<br>';

        $success++;
    }
}
$storearray = array_filter($storearray);
if($error == 0){
	$error = count($storearray) - $success;
}
$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');

$submitlog = sprintf($submitlog,count($storearray),$success,$error);

$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

$viewid = vtlib_purify($_REQUEST['viewname']);
if(isset($_SESSION['lvs']['Accounts']['viewname'])){
	$viewid = $_SESSION['lvs']['Accounts']['viewname'];
	$start = $_SESSION['lvs']['Accounts'][$viewid]['start'];
}
if(!$start) $start = 1;
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$entity['title']['value'] = getFixedLabel('BATCHRELEASE');//标题



$json = new Zend_Json();
$jsonentity = $json->encode($entity);

echo $jsonentity;die;


/*$viewid = vtlib_purify($_REQUEST['viewname']);
$SearchScope=$_REQUEST['SearchScope'];
if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
    	$rstart = "&start=".vtlib_purify($_REQUEST['start']);
    }
$accounttype=$_REQUEST['pagepublicaccounttype'];

header("Location: index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid");*/
    

?>