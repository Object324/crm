<?php
/****************************************************
**edit:kevin
**date:2013-08-28
**reason:强制返回提交审批
****************************************************/
global $adb,$current_user,$default_charset;
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
require_once('modules/Approve/ApproveRemind.php');
$appremindObj = new ApproveRemind();
$fld_module=getTabname($blockid);
$focus=CRMEntity::getInstance($fld_module);
$smowneridcolumnname=$focus->getSmownerColumName();
$approvestatus=-1;

$tabname =$focus->table_name ;
$moduleid = $focus->table_index;
if(empty($tabname)) $tabname = 'ld_'.strtolower($fld_module);
if(empty($moduleid)) $moduleid = strtolower($fld_module).'id';
include('modules/Approve/Remind.php');
$query="select DISTINCT T1.$moduleid,T1.$smowneridcolumnname as smowner from ld_approvelog 
	INNER JOIN(
		select max(id) as max_id from ld_approvelog  where approved_by>0 GROUP BY crmid
	) as T2 on T2.max_id  = ld_approvelog.id
	left join (select $moduleid,$smowneridcolumnname from $tabname where approvestatus='".constant('D_A_S_APPROVALOF')."') as T1 on ld_approvelog.crmid=T1.$moduleid 
	
    where approveid=$record and T1.$moduleid <>''";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
 /*$sql="delete from ld_approvelog where crmid not in(select $moduleid  from  $tabname)
 and approveid=$record ";
 $adb->query($sql);
 */
if($num_rows){
	//删除之前的审批提醒
    $query="insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,approveresult,createdtime,seqtime)value";
    for($i=0;$i<$num_rows;$i++){
        $id=$adb->getUniqueID("ld_approvelog");
        $crmid=$adb->query_result($result,$i,0);
        $smownerid=$adb->query_result($result,$i,'smowner');
		$appremindObj->updateRemindStatus($crmid);
        $sql="update $tabname set approvestatus='".constant('D_A_S_DISMISSED')."',approveby=$current_user->id,currentapprover='' where $moduleid=$crmid";
       
        $adb->query($sql);       
        $query .="($id,$crmid,null,$record,$approvestatus,$current_user->id,4,'".date('Y-m-d H:i:s')."',current_timestamp(6)),";
        
        $focusreminds = new Reminds();
    	$date_time = date('Y-m-d H:i:s', time());
    	$focusreminds->column_fields['related_to'] = $crmid;
    	$focusreminds->column_fields['reltab'] = $fld_module;
    	$focusreminds->column_fields['is_del_send'] = 0;
    	$focusreminds->column_fields['is_del_rec'] = 0;
    	$focusreminds->column_fields['status_rmd'] = '未读';
    	$focusreminds->column_fields['date_time'] = $date_time;
        
        //zkt 20220719  BUG0054005企业微信移动端，强制驳回提交审批提醒，提醒内容中“强制返回提交审批”也应该显示为强制驳回提交审批 
        $focusreminds->column_fields['content'] = "你负责的".getTranstab($fld_module)."已经被".$current_user->last_name."强制驳回提交审批";
        
        $focusreminds->column_fields['recieverid'] = $smownerid;
        $focusreminds->column_fields['remindstype'] = 'ForceAntiApprove';
        $focusreminds->mode='create';
        $focusreminds->save('Reminds');
    }
      
    $query=mb_substr($query,0,strlen($query)-1,$default_charset);
   
    $adb->query($query);
    
    //$query="update $tabname set approvestatus=$approvestatus,approveby=".$current_user->id." where $moduleid=".$record;
    echo "###SUCCESS###";
    exit();
}else{
	echo "###SUCCESS###";
    exit();
}
?>