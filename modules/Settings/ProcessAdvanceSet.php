<?php
crm_load_class_file("CommonView","modules/CustomView");
$smarty=new lingdangCRM_Smarty();
//审批步骤查询
$_REQUEST['diony']='yes';
if(isset($_REQUEST['modulename'])){
    $module = $_REQUEST['modulename'];
    $tabid = getTabid($module);
}else{
    $tabid=$_REQUEST['tabid'];
    $module=getTabname($tabid);
}

$nodename=$_REQUEST['nodename'];
$focus=CRMEntity::getInstance($module);
$modulefields=$focus->fieldobj->getListSearchFields();
$blockinfos=$focus->fieldobj->getBlockInfos();
$nodeid=$_REQUEST['nodeid'];
$childids=$_REQUEST['childids'];
$childid_arr=explode(",",$childids);
$stepid=$_REQUEST['stepid'];
$advsearch_arr=json_decode($_REQUEST['advancesearch'],true);//高级查询
$groupcondition=$_REQUEST['groupcondition'];//组合
$groupcondition_arr=json_decode($groupcondition,true);
$advgroup_arr=[];


$groupindex=0;

foreach($groupcondition_arr as $groupid=>$groupinfo)
{

    if(is_array($groupinfo)){

        foreach($advsearch_arr  as $searchindex=>$searchinfo)
        {
            if(is_array($searchinfo)&&$searchinfo['groupid']==$groupid)

            {
                $searchinfo['search_comparator']=$searchinfo['comparator'];
                $advgroup_arr[$groupid]['columns'][]=$searchinfo;
            }
        }

        $advgroup_arr[$groupid]['condition']=$groupinfo['groupcondition'];
    }

}

$smarty->assign("CRITERIA_GROUPS",$advgroup_arr);

$conditionpriority='';

$priorityhtml='';

foreach($childid_arr as  $tmpindex=>$tmpchildid)
{
    if($tmpchildid==$nodeid)
    {
        $priorityhtml.="<option value='".$tmpindex."' selected>".getFixedLabel('Priority').($tmpindex+1).'</option>';

    }
    else{
        $priorityhtml.="<option value='".$tmpindex."'>".getFixedLabel('Priority').($tmpindex+1).'</option>';
    }
}
//获取成员管理不显示字段
$modulenoshowfields = array();
if($frommodule == 'Users'){
    $modulenoshowfields = $focus->getSearchNoshowfields();
}
$table_name_index=$focus->tab_name_index;
$advancefields=array();
foreach($modulefields as $fieldname=>$fieldinfo)
{
    //成员管理不显示字段，不显示
    if(in_array($fieldname,$modulenoshowfields)){
        continue;
    }
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
    $display=$fieldinfo->getDisplaytype();
    $uitype = $fieldinfo->getUIType();

    if (!empty($triggercolumnname)) {
        if($display==2||$display==3)
        {
            continue;
        }
    }
    //标签应该不显示在布局规则：其它条件
    if($uitype == 301){
        continue;
    }
    if($columnname==$triggercolumnname)
    {
        //触发字段不显示在高级查询中
        continue;
    }
    if(array_key_exists($tablename,$table_name_index))
    {
        $blockfields[$fieldinfo->getBlockId()][]=$fieldinfo;
    }
}
$prevblockid=0;
foreach($blockinfos as $blockid=>$blockinfo)
{

    $tmpfields=$blockfields[$blockid];
    if(sizeof($tmpfields)<=0)
    {
        continue;
    }
    $strhtml.="<optgroup label='".$blockinfo['blocklabel']."' class='select' style='border:none'>";
    foreach($tmpfields as $index=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $fieldname=$fieldinfo->getFieldName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        $typeofdata=$fieldinfo->getTypeOfData();
        $typeofdatas=explode('~',$typeofdata);
        $cols="$tablename:$columnname:$fieldname:$frommodule"."_fieldlabel:".$typeofdatas[0];

        $strhtml.="<option value='$cols'>$fieldlabel</option>";
    }
    $strhtml.="</optgroup>";
}
if(get_file_address($module,$module.'DetailFieldsHtml'))
{
    $detailfields=  $focus->detailfieldobj->getModuleAllPreseneceFields();
    $strhtml.="<optgroup label='".getTranstab($module).getFixedLabel('DETAIL'). "' class='select' style='border:none'>";

}
else if(get_file_address($module,"ProductDetails")){
    $detailfields=  $focus->detailfieldobj->getModuleAllPreseneceFields();
    $strhtml.="<optgroup label='".getTranstab('Products').getFixedLabel('DETAIL')."' class='select' style='border:none'>";
}
if(isset($detailfields))
{

    //edit:can 20230302 61460 （医疗器械行业方案）产品通用问题。审批流程-设置条件分支，选不到分录字段
    foreach($detailfields as $tmpcolumn=>$fieldinfo )
    {
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $fieldname=$fieldinfo->getFieldName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        $typeofdata=$fieldinfo->getTypeOfData();
        $typeofdatas=explode('~',$typeofdata);
        $cols="$tablename:$columnname:$fieldname:$frommodule"."_fieldlabel:".$typeofdatas[0];
        //duan 20230808 高级查询取表头的合计,不用分录的合计
        if($columnname == 'total'){
            continue;
        }
        $strhtml.="<option value='$cols'>$fieldlabel</option>";
    }
    $strhtml.="</optgroup>";
}
$smarty->assign("FIELDNAMES",$strhtml);
$smarty->assign("priorityhtml",$priorityhtml);
$smarty->assign("nodename",$nodename);
$arr['module']=$module;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$smarty->fetch("Settings/ProcessAdvanceSet.tpl");

ConvertTojsonString(1,$arr,'success');

?>