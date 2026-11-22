<?php
/*
edit:duan
date:2022-5-20
reason:保存自动化任务中，必填字段任务类型的保存
*/
global $adb,$weixin_user;
crm_load_class_file('cls_module_advance','modules/Settings');
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$focus = CRMEntity::getInstance($module);
$_REQUEST['mode'] = 'edit';
$_REQUEST['apiDeleteAttach'] ='no';
$_REQUEST['ajxaction'] = 'DETAILVIEW';
$cls_module_advance_obj = cls_module_advance::getInstance($module);
$pre_stagenamenow = $cls_module_advance_obj->getStagenameNow($record);

$focus->id = $_REQUEST['record'];
$focus->retrieve_entity_info($focus->id,$module);
$focus->mode = $_REQUEST['mode'];
$focus->is_check_business='no';//不经过工商查询判断
$attachfield_arr = array();

//保存前判断是否有布局规则的必填字段判断
if($_REQUEST['type'] != 'push'){ //做推进操作时会在推进里有判断，不用在保存再判断一次
    $cls_module_advance_obj->CommonEditFieldobj->requestcolumn = $_REQUEST;
    $error = $cls_module_advance_obj->JudgeRequiredFieldRule($record);
    if($error == 'yes'){
        ConvertTojsonString(-2, ['info'=>'fieldrule'], getFixedLabel('ADVANCEFIELDRULEREMIND'));
    }
}


//hzx BUG0062845 推进保存 字段属性“不允许重复”,“严格11位手机号码格式 ”不生效
foreach($focus->column_fields as $fieldname => $fieldvalue){
    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
    if(isset($_REQUEST[$fieldname])){
        if($fieldinfo->getfieldOnly() == 1){
            crm_load_class_file('staticlingdang.class','modules/lingdang');
            $ldcls = new staticlingdang();
            $rest = $ldcls->getFieldDuplicateInfo($module,$fieldname,$_REQUEST[$fieldname],$record);
            $rest_msg = explode('##',$rest);
            if($rest_msg[1] == 'error' && $rest_msg[2]){
                ConvertTojsonString(-1,'',$rest_msg[2]);
            }
        }
    }
}

foreach($focus->column_fields as $fieldname => $fieldvalue){
    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
    if(empty($fieldinfo)){
        continue;
    }
    if($fieldinfo->getBigType() == 'fileattachment' && isset($_REQUEST[$fieldname.'-file_num'])){
        $uitype = $fieldinfo->getUIType();
        $columnname = $fieldinfo->getColumnName();
        if($uitype==1109||$uitype==28){
            $attachfield_arr['filetoattachment'][] = $columnname;    
        }
        if($uitype==69){
            $attachfield_arr['imageattachment'][] = $columnname;    
        }
    }
    
    if(isset($_REQUEST[$fieldname])){
        $focus->column_fields[$fieldname] = $_REQUEST[$fieldname];
        if (!empty($weixin_user)&&$fieldinfo->getBigType()=='richtext') {
            $tablename = $fieldinfo->getTableName();
            $columnname = $fieldinfo->getColumnName();
            $table_index = $focus->table_index;
            $sql = "update $tablename set $columnname=? where $table_index = ?";
            $adb->pquery($sql,array($_REQUEST[$fieldname],$record));
            
            continue;
        }
    }
}
// 不走公共代码来保存附件
$focus->set_Is_needcommonsave_attachments('no');

$focus->save($module);
//附件字段单独保存
if(sizeof($attachfield_arr)>0){
    $focus->addFileToAttachmentSavenoJudge($focus->id,$module,$attachfield_arr);
}

// 销售线索，保存失败原因
if($module == 'Leads'){ 
    if(isset($_REQUEST['failurereason']) && !empty($_REQUEST['failurereason'])){
        $query = 'UPDATE ld_leads set failurereason=?,modifiedtime="'.date('Y-m-d H:i:s').'" where leadsid = ?';
        $adb->pquery($query,array($_REQUEST['failurereason'],$record));
    }
}

$next_stagenamenow = $cls_module_advance_obj->getStagenameNow($record);
if($next_stagenamenow != $pre_stagenamenow){
    //保存前后阶段不同，需要刷新界面
    $arr['push_success'] = 'yes';    
}else{
    $arr['push_success'] = 'no';
}

if($ismobile == 'yes'){
    $arr['push_success'] = 'yes';
}

ConvertTojsonString(1,$arr,'success');
?>