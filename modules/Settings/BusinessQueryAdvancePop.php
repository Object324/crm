<?php
$frommodule=$_REQUEST['frommodule'];
$tabid = getTabid($frommodule);
//获取设置的条件
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
$businessinformation_arr = cls_BusinessInformation::getAllBusinessInformation();
$advsearch=$businessinformation_arr[$tabid]['nosave_exception_column'];//高级查询
$groupcondition=$businessinformation_arr[$tabid]['nosave_exception_group'];//组合
if(empty($advsearch)){
    $advsearch = '[]';
    $groupcondition = '[]';
}
$focus=CRMEntity::getInstance($frommodule);
$modulefields=$focus->fieldobj->getListSearchFields();
$blockinfos=$focus->fieldobj->getBlockInfos();

$table_name_index=$focus->tab_name_index;
$advancefields=array();
foreach($modulefields as $fieldname=>$fieldinfo)
{
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
    $display=$fieldinfo->getDisplaytype();
	$uitype = $fieldinfo->getUIType();

	//标签应该不显示在布局规则：其它条件
	if($uitype == 301){
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
    if(!is_array($tmpfields) || sizeof($tmpfields)<=0)
    {
        continue;
    }
    $strhtml.="<optgroup label='".$blockinfo['blocklabel']."' class='select' style='border:none'>";
    foreach($tmpfields as $index=>$fieldinfo)
    {
        $displaytype=$fieldinfo->getDisplaytype();
        if($displaytype==2)continue;
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
$smarty=new lingdangCRM_Smarty();
$smarty->assign("HideGroup",'yes');

$_REQUEST['diony']='yes';
$groupcondition_arr=json_decode($groupcondition,true);

if(!empty($advsearch))
{
    $arr_advsearch=json_decode($advsearch,true);
    foreach($arr_advsearch as $index=>$searchinfo)
    {
        if(!is_array($searchinfo))
        {
            continue;
        }
        $groupid=$searchinfo['groupid'];
        $condition=$searchinfo['columncondition'];
        $comparator=$searchinfo['comparator'];
        $value=$searchinfo['value'];
        $columnname=$searchinfo['columnname'];
        $searchinfo['search_comparator']=$searchinfo['comparator'];
        
       $groupsearch[$groupid]['columns'][]=$searchinfo;
       
    }
   // $arr['criteria_groups']=$groupsearch;	
}
else
{
   // $arr['criteria_groups']="";
    
}
$groupsearch_arr=[];
$groupindex=0;
foreach($groupsearch as $tmpgroupid=>$groupsearchinfo)
{
    if(array_key_exists($tmpgroupid,$groupcondition_arr))
        $groupsearchinfo['condition']=$groupcondition_arr[$tmpgroupid]['groupcondition'];
    else
        $groupsearchinfo['condition']='';
        
    
    $groupsearch_arr[$tmpgroupid]=$groupsearchinfo;
    
    $groupindex++;
}


$arr['content']=$smarty->fetch("newAdvanceFilter.tpl");
$arr['oktext']=getFixedLabel('SAVE');
$arr['canceltext']=getFixedLabel('CANCEL');
$arr['title']=getFixedLabel('INCONDITIONALLOWSAVE');
$arr['criteria_groups_arr']=$groupsearch_arr;
$arr['source']='customview';
$arr['columns_block']=$strhtml;

crm_load_class_file('CommonView',"modules/CustomView");
$comparatorArr = CommonView::getComparatorLabel();
$comparatorArr['belong'] = getFixedLabel('BELONG');
$comparatorArr['notbelong'] = getFixedLabel('NOTBELONG');
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$comparatorArr['new_belong'] = getFixedLabel('BELONG');
$comparatorArr['new_notbelong'] = getFixedLabel('NOTBELONG');
$advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
$arr['advfilterhtml'] = $advfilterhtml;
$arr['fLabels'] = $comparatorArr;
$arr['fieldsinfo'] = array_values($modulefields);
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($frommodule);
$arr['advanceFields'] = $controller->getAdvanceFields();

ConvertTojsonString(1,$arr,'success');


?>