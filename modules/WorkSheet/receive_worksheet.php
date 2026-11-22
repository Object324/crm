<?php
/*
edit:duan
date:2021-11-16
reason:工单模块领取功能
*/

//判断当前用户能否领取单据
global $current_user,$currentModule,$adb;

$focus = CRMEntity::getInstance($currentModule);
$limit_amount = 1000;
$module = $currentModule;

if($_REQUEST['selectid'] == 'all'){ //全部
    $id_list = getSelectedRecords($_REQUEST,$module,$_REQUEST['selectid'],$_REQUEST['excludedRecords']); 
}else{
    $select_ids = $_REQUEST['selectid'];
    $select_id = trim($select_ids,",");
    $id_list = explode(",",$select_id); 
}

$receive_result = array();
foreach($id_list as $id){
    $receive_result[$id] = getFixedLabel('RECEIVE').getFixedLabel('SUCCESS');
}
//判断用户负责的工单数量是否会到达上限
$sql = 'select * from ld_worksheet where smownerid =? and worksheet_status <> ? and deleted = 0';
$result = $adb->pquery($sql,array($current_user->id,'closed'));
$cur_amount = $adb->num_rows($result);

//读取选中的工单信息
$success_idlist = array();
$ids_str = implode(',',$id_list);
$sql = 'select smownerid,worksheetid,worksheet_no,worksheet_status from ld_worksheet where worksheetid in ('.$ids_str.');';
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);


$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s失败！原因：该单据已经%s!
$documenterrorinfo = getFixedLabel('documenterrorinfo');//单据[%s]%s失败！原因：%s!
$batchnum = getFixedLabel('BATCHSUBMITLOG_INFO');//共选择 %d 条记录，成功 %d 条，失败 %d 条

for($i=0;$i<$num_rows;$i++){
    $smownerid = $adb->query_result($result,$i,'smownerid');
    $worksheetid = $adb->query_result($result,$i,'worksheetid');
    $worksheet_no = $adb->query_result($result,$i,'worksheet_no');
    
    
    $link = '<a referencemodule="'.$module.'" referencerecord="'.$worksheetid.'" onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636">'.$worksheet_no.'</a>';
    //判断单据是否已有服务人员
    if($smownerid>0){
        $receive_result[$worksheetid] = sprintf($batcherrorlog,$link,getFixedLabel('RECEIVE'),getFixedLabel('RECEIVEDORALLOCATED')).'<br>';
    }else if($cur_amount >= $limit_amount){
        $receive_result[$worksheetid] = sprintf($documenterrorinfo,$link,getFixedLabel('RECEIVE'),getFixedLabel('RECEIVEDORALLOCATED')).'<br>';
    }else{
        $receive_result[$worksheetid] = sprintf($batchsuccesslog,$link,getFixedLabel('RECEIVE')).'<br>';
        $success_idlist[] = $worksheetid;
    }
    $cur_amount += 1;
}
$receivelog_title = sprintf($batchnum,$num_rows,sizeof($success_idlist),$num_rows-sizeof($success_idlist));

$tablename = $focus->table_name;
$tableindex =  $focus->table_index;
$columnname = 'smownerid';
$fieldname = 'assigned_user_id';
foreach($success_idlist as $worksheetid){
    $time = date('Y-m-d H:i:s',time());
    //更新工单服务人员
    $sql = 'update '.$tablename.' set '.$columnname.'= ?,modifiedtime=?,modifiedby=?,worksheet_status=?,receivedtime=? where '.$tableindex.'= ?';
    $adb->pquery($sql,array($current_user->id,$time,$current_user->id,'inprocess',$time,$worksheetid));
    
    //添加日志
    $status = 0;
    $id = $adb->getUniqueID('ld_modtracker_basic');
    $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
    					values(?,?,?,?,?,?);';
    $adb->pquery($query,array($id,$worksheetid,$module,$current_user->id,$time,$status));
    $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
    $adb->pquery($query,array($id,$fieldname,'',$current_user->id));
    
    //添加工单动态信息
    $description = 'receive';
    $modifiedmodule = 'Users';
    $modifiedby = $current_user->id;
    $focus->saveWorkTrends($worksheetid,$modifiedmodule,$modifiedby,$description);
}
$_REQUEST['diony']='yes';
if($_REQUEST['fromtype']=='list'){ //wym 240425 BUG20240425-18 显示的是“批量领取”，但实际上是单选领取，不能批量领取
    $arr['title'] = getFixedLabel('RECEIVE');
}else{
    $arr['title'] = getFixedLabel('BATCHRECEIVE');
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content'] = '<div class="pop_remind_content"><div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">' . $receivelog_title . "</div></div><div class='pop_prc_content'>" . implode(' ',$receive_result) . '</div></div>';
ConvertToJsonString(1,$arr,'success');

?>