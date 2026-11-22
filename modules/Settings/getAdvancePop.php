<?php
$frommodule=$_REQUEST['frommodule'];
$triggercolumnname=$_REQUEST['triggercolumnname'];

if($_REQUEST['tmprange']=="memberrange"){
    $frommodule='Users';
}
$focus=CRMEntity::getInstance($frommodule);
$modulefields=$focus->fieldobj->getListSearchFields();
$blockinfos=$focus->fieldobj->getBlockInfos();
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
    // @edit:liushuai,2020-09-01,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮(该功能和布局规则里的其他条件走相同逻辑，但是布局规则只显示ld_field里的字段，过滤掉了是否公海等，所以需要差别处理)
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

$smarty=new lingdangCRM_Smarty();
$smarty->assign("HideGroup",'yes');
$smarty->assign("FIELDNAMES",$strhtml);
$_REQUEST['diony']='yes';
$advsearch=$_REQUEST['advancesearch'];//高级查询
$groupcondition=$_REQUEST['groupcondition'];//组合
$groupcondition_arr=json_decode($groupcondition,true);

if(!empty($advsearch))
{
    $arr_advsearch=(json_decode($advsearch,true));
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
//edit:can 2020-12-23 42553: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），收款单->页面设置：客户名称编辑属性【其他条件】中设置两个新条件之间的关系为“或”关系保存后，刷新再次查看【其他条件】设置时，两个新条件变为“且”关系了
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

$smarty->assign("CRITERIA_GROUPS",$groupsearch_arr);
//zkt 20221104 BUG0057767页面设置，自定义关联选择单据（单选）字段弹出层中，设置其他条件，选择“日期”字段，选择“区间”比较关系后，关键字只显示了一个日期插件
crm_load_class_file('CommonView',"modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$arr['content']=$smarty->fetch("Settings/LayoutBlockRuleAdvancePop.tpl");
$arr['oktext']=getFixedLabel('SAVE');
$arr['canceltext']=getFixedLabel('CANCEL');
$arr['title']=getFixedLabel('SettingOtherCondition');
$arr['fieldinfo']=array_values($modulefields);
ConvertTojsonString(1,$arr,'success');


?>