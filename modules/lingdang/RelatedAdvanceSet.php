<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty();
$frommodule = $_REQUEST['module'];
$relation_id = $_REQUEST['relationid'];

if($_REQUEST['mode']=='save'){
    if($relation_id!='' && $_REQUEST['advanceset']!='' ) {
        $advanceset = $_REQUEST['advanceset'];
        $sql_update = 'update ld_relatedlists SET related_advanceset =? where relation_id=?';
        $result_update = $adb->pquery($sql_update,array($advanceset,$relation_id));
    }
    if(getTabid($frommodule)==16)
    {
        $tabid = 9;
    } else{
        $tabid = getTabid($frommodule);
    }
    $key = 'cache_getrelatedlistinfobyid_relationid_'.$tabid;
    unsetCache($key);//清除缓存
    unsetCache('cache_getrelatedlistinfobytabid');//清除缓存
    ConvertTojsonString(1,'','success');
}
crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
$relationInfo = getRelatedListInfoById($relation_id);
$focus=CRMEntity::getInstance($frommodule);
$module_label = getTranstab($frommodule);
$list_link_field=$focus->list_link_field;
$list_link_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $list_link_field);
$list_link_field_label=$list_link_fieldinfo->getFieldLabelKey();
$relatedmodule = $_REQUEST['relatedmodule'];
$related_focus=CRMEntity::getInstance($relatedmodule);
$related_module_label = getTranstab($relatedmodule);//wym 240517 BUG20240516-60 相关信息查询设置：选择字段的模块名称错了，应该是被关联的模块（ls：改"选择字段"的模块名，别改“关键字”啊）
$arr['keywords']=$module_label.'-'.$list_link_field_label;

$modulefields_arr=$related_focus->fieldobj->getModuleFields();

$tmp_related_fields = [];
foreach($modulefields_arr as $fieldname=>$fieldinfo)
{
    $tmp_fieldinfo = [];
    if($fieldinfo->getSaveDataBase()!='yes') //不存数据库的字段跳过
        continue;
    $bigtype=$fieldinfo->getBigType();
    $uitype=$fieldinfo->getUIType();
    $columnname=$fieldinfo->getColumnName();
    if($relationInfo['type']=='budget_datacategory_sql' && $columnname=='smownerid'){ //费用预算单-相关信息栏-费用报销单
        $tmp_fieldinfo['fieldlabel'] = $fieldinfo->getFieldLabelKey();
        $tmp_fieldinfo['bigtype'] = $bigtype;
        $budget_person_fieldinfo  = $focus->fieldobj->getFieldInfoobjBykey("columnname", 'budget_person');
        if($budget_person_fieldinfo){
            $budget_person_label=$budget_person_fieldinfo->getFieldLabelKey();
            $tmp_fieldinfo['special_keywords'] =$related_module_label.'_'.$budget_person_label;
        }else{
            $tmp_fieldinfo['special_keywords'] =$related_module_label.'_预算人员';
        }
        $tmp_related_fields['expense.smownerid'] = $tmp_fieldinfo;
        continue;
    }
    if($bigtype == 'reference' || $bigtype == 'multireference'){//单选/多选字段
        if(cls_module_uitype::getUitypeModule($uitype)!=$frommodule) //选择单据模块referencemodule不等于当前模块字段跳过
            continue;
    }elseif($bigtype=='selectsource'){ // selectsource：选择源单
        $sourceinfos=getSourceModule($relatedmodule);
        $sourcemodule=[];
        foreach ($sourceinfos as $sourceinfo){
            array_push($sourcemodule,$sourceinfo['entitytype']);
        }
        if(!in_array($frommodule,$sourcemodule)){ //选择原单的sourcemodule不包括当前模块时,跳过
            continue;
        }
    }elseif($uitype==112 || $uitype==173){
        //wym uitype 112：相关对象 uitype 173：最终客户
    }else{
        continue;
    }

    $tablename = $fieldinfo->getTableName();

    if($tablename == $related_focus->table_name || $tablename == $related_focus->customFieldTable[0]) {
        $tmp_fieldinfo['fieldlabel'] = $related_module_label.'_'.$fieldinfo->getFieldLabelKey();
        $tmp_fieldinfo['bigtype'] = $bigtype;
        if($bigtype=='selectsource' && $relationInfo['related_coltable'] == 'tmpsourcedetail.id'){
            $table_field = 'tmpsourcedetail.id';
            if($relationInfo['type']=='cashbillsourcebill_datacategory_sql' || $relationInfo['type']=='sendcashbillsourcebill_datacategory_sql'){
                $table_field = 'tmp_related_cashbill.entitytypeid';
            }
        }else{
            $table_field = explode( 'ld_',$tablename)[1].'.'.$columnname;
        }
        $tmp_related_fields[$table_field] = $tmp_fieldinfo;
    }
}

if($related_focus->detailfieldobj){//分录字段
    if(get_file_address($relatedmodule,$relatedmodule.'DetailFieldsHtml'))
    {
        $detailfieldlabel_prefix = getTranstab($relatedmodule).getFixedLabel('DETAIL'). '_';

    }
    else if(get_file_address($relatedmodule,"ProductDetails")){
        $detailfieldlabel_prefix = getTranstab('Products').getFixedLabel('DETAIL'). '_';
    }
    $detailfields = $related_focus->detailfieldobj->getModuleProductToolField();
    foreach($detailfields as $fieldname=>$detailfieldinfo)
    {
        $columnname = $detailfieldinfo->getColumnName();
        $bigtype=$detailfieldinfo->getBigType();
        $tablename=$detailfieldinfo->getTableName();
        $savedatabase=$detailfieldinfo->getSaveDataBase();
        //edit: xll 2024/08/13 BUG20240708-18 产品管理--相关信息页签，销售订单（没有设置相关条件，依旧显示了关联的订单）
        if($frommodule==='Products') {
            if(getEntitynameInfo(getTabid('Products'))['fieldname'] === $columnname) {
                $tmp_fieldinfo = [
                    'fieldlabel' => $detailfieldlabel_prefix.$detailfieldinfo->getFieldLabel(),
                    'bigtype' => $bigtype,
                ];
                $table_field = explode( 'ld_',$related_focus->Detail_table)[1].'.productid';
                $tmp_related_fields[$table_field] = $tmp_fieldinfo;
            }
        }
        $referencemdoule='';
        if($savedatabase!='yes') {
            continue;
        }
        $tablename=$detailfieldinfo->getTableName();
        if($tablename != $related_focus->Detail_table && $tablename != $related_focus->Detail_table_scf) {
            continue;
        }
        $referencemdoule='';
        if($bigtype=='reference') { //选择单据单选字段
            $referencemdoule = $detailfieldinfo->getReferenceModule();
        }
        $parentbigtype=$detailfieldinfo->getParentBigType();
        if($detailfieldinfo->isRelatedModuleField()&&!empty($parentbigtype)&&($parentbigtype == 'reference'||$parentbigtype == 'selectsource')){ //引用选择单据单选字段
            $sql='select fromvalue_info,frommodule from ld_related_detailfield where effect_columnname=? and fromvalue_type="column"';
            $result = $adb->pquery($sql,array($columnname));
            if($adb->num_rows($result)>0){
                $columnname_tmp = $adb->query_result($result,0,'fromvalue_info');
                $columnname_module = $adb->query_result($result,0,'frommodule');
                $columnname_focus=CRMEntity::getInstance($columnname_module);
                if($columnname_focus->fieldobj){
                    $columnname_uitype=$columnname_focus->fieldobj->getFieldInfoBykeyValue("columnname",$columnname_tmp,'uitype');
                    if($columnname_uitype){
                        $referencemdoule=cls_module_uitype::getUitypeModule($columnname_uitype);//引用选择源单字段的对应模块
                    }
                }
            }
        }
        else if($bigtype=='selectsource')
        {

            $sourceinfos=getSourceModule($relatedmodule);
            $sourcemodule=[];

            foreach ($sourceinfos as $sourceinfo){
                if($sourceinfo['entitytype']==$frommodule)
                {
                    $referencemdoule=$frommodule;
                    break;
                }
            }

        }
        if($referencemdoule && $referencemdoule==$frommodule){
            $tmp_fieldinfo = [];

            $tmp_fieldinfo['fieldlabel'] = $detailfieldlabel_prefix.$detailfieldinfo->getFieldLabel();
            $tmp_fieldinfo['bigtype'] = $bigtype;
            $table_field = explode( 'ld_',$tablename)[1].'.'.$columnname;
            $tmp_related_fields[$table_field] = $tmp_fieldinfo;
        }else if($bigtype=='selectsource'){ // selectsource：选择源单
            $sourceinfos=getSourceModule($relatedmodule);
            $sourcemodule=[];
            foreach ($sourceinfos as $sourceinfo){
                array_push($sourcemodule,$sourceinfo['entitytype']);
            }
            if(in_array($frommodule,$sourcemodule)){
                $tmp_fieldinfo = [];
                $tmp_fieldinfo['fieldlabel'] = $detailfieldlabel_prefix.$detailfieldinfo->getFieldLabel();
                $tmp_fieldinfo['bigtype'] = $bigtype;
                $table_field = explode( 'ld_',$tablename)[1].'.'.$columnname;
                $tmp_related_fields[$table_field] = $tmp_fieldinfo;
            }
        }
    }
}

$arr['related_fields']=$tmp_related_fields;
$arr['content']=$smarty->fetch("ShowAdvanceSet.tpl");
$arr['title']=getFixedLabel('Relatedquerycondition');
$arr['oktext']=getFixedLabel('SAVE');
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');

?>