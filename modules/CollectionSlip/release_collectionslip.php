<?php
global $current_user,$currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
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
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s失败！原因：该单据已经%s!
$documenterrorinfo = getFixedLabel('documenterrorinfo');//单据[%s]%s失败！原因：%s!
$batchnum = getFixedLabel('BATCHSUBMITLOG_INFO');//共选择 %d 条记录，成功 %d 条，失败 %d 条

//读取选中的工单信息
$success_idlist = array();
$ids_str = implode(',',$id_list);
$sql = 'select collectionslip_id,collectionslip_no,collectionslip_status from ld_collectionslip where collectionslip_id in ('.$ids_str.');';
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
for($i=0;$i<$num_rows;$i++){
    $collectionslip_id = $adb->query_result($result,$i,'collectionslip_id');
    $collectionslip_no = $adb->query_result($result,$i,'collectionslip_no');
    $collectionslip_status = $adb->query_result($result,$i,'collectionslip_status');

    $link = '<a referencemodule="'.$module.'" referencerecord="'.$collectionslip_id.'" onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636">'.$collectionslip_no.'</a>';
    //判断单据是否已分配
    if($collectionslip_status!='collected'){
        $receive_result[$collectionslip_id] = sprintf($documenterrorinfo,$link,getFixedLabel('RELEASE'),'单据未被领取或分配').'<br>';
    }else{
        $receive_result[$collectionslip_id] = sprintf($batchsuccesslog,$link,getFixedLabel('RELEASE')).'<br>';
        $success_idlist[] = $collectionslip_id;
    }
}
$receivelog_title = sprintf($batchnum,$num_rows,sizeof($success_idlist),$num_rows-sizeof($success_idlist));

$tablename = $focus->table_name;
$tableindex =  $focus->table_index;
$columnname = 'smownerid';
$fieldname = 'assigned_user_id';
foreach($success_idlist as $collectionslip_id){
    $time = date('Y-m-d H:i:s',time());
    //更新负责人,领取状态
    $sql = 'update '.$tablename.' set '.$columnname.'= ?,modifiedtime=?,modifiedby=?,collectionslip_status=?,collectionslip_time=? where '.$tableindex.'= ?';
    $adb->pquery($sql,array('',$time,$current_user->id,'uncollected',$time,$collectionslip_id));
}
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('BATCHRECEIVE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content'] = '<div class="pop_remind_content"><div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">' . $receivelog_title . "</div></div><div class='pop_prc_content'>" . implode(' ',$receive_result) . '</div></div>';
ConvertToJsonString(1,$arr,'success');

?>