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

require_once 'modules/PickList/PickListUtils.php';


global $adb, $current_user, $default_charset;

$global_languageType = getLanguageType($current_user);
$moduleName = $_REQUEST['fld_module'];
$focus=CRMEntity::getInstance($moduleName);
//BUG20240513-01 ls 240513 	收、付款单 新建界面 单据分录下拉框字段 新增下拉款值不成功
$selectsourcetype = $_REQUEST['selectsourcetype'];
if (!empty($selectsourcetype)) {
    $focus->Resetdetailfieldobj($selectsourcetype);
}

$tableName = $_REQUEST['fieldname'];
$tableName = $adb->sql_escape_string($tableName);
$tableid = $tableName.'id';
if($tableName == 'sales_stage') $tableid = 'sales_stage_id';
$selectvalue = $_REQUEST['selectvalue'];

$mode = trim($_REQUEST['mode']);
if(empty($mode)){
	echo "action mode is empty";
	exit;
}
if(get_file_address($moduleName,$moduleName."DetailFieldsHtml")){
	crm_load_class_file('TabDetails','include/TabDetailFields');
	$productDetails=new TabDetails($moduleName);
	$productFields = $productDetails->getModuleFields();
	$fieldinfo = $productFields[$tableName];
	if(!empty($fieldinfo)){
		if($fieldinfo->getFieldType() == 'Select'){
			$uitype = 15;
		}else{
			$uitype = $fieldinfo->getUIType();
		}
		$table_name = $fieldinfo->getTableName();
		$columnname = $fieldinfo->getColumnName();
	}
}else if(get_file_address($moduleName,'ProductDetails')){
	crm_load_class_file('ProductDetails','include/ProductDetails');
	$productDetails=ProductDetails::getInstance($moduleName);
	$productFields = $productDetails->getModuleFields();
	$fieldinfo = $productFields[$tableName];
	if(!empty($fieldinfo)){
		if($fieldinfo->getUIType() == 60){
			$uitype = 15;
		}else{
			$uitype = $fieldinfo->getUIType();
		}
		$table_name = $fieldinfo->getTableName();
		$columnname = $fieldinfo->getColumnName();
	}
}
if(empty($fieldinfo)){
	$field = Field::getInstance($moduleName,$adb);
	$fieldinfo = $field->getFieldInfoobjBykey('fieldname',$tableName);
	if(!empty($fieldinfo)){
		$uitype = $fieldinfo->getUIType();
		$table_name = $fieldinfo->getTableName();
		$columnname = $fieldinfo->getColumnName();
	}
}
//市场活动相关信息 - 客户 状态下拉框特殊
if($tableName == 'campaignaccountrelstatus'){
	$table_name = $columnname = 'campaignaccountrelstatus';
	$uitype = 15;
}
/**
 * 删除当前模块下拉框缓存缓存
 * @author Tujt 2015-03-04
 */
$tabid = getTabid($moduleName);
$cachekey = 'getPicklistValesForNORole'.$tabid;
unsetCache($cachekey);
unsetCacheDirectory('fields');
unsetCacheDirectory('picklist');
global $picklistmodule,$adb;
$smarty=new lingdangCRM_Smarty;
$picklistmodule = $moduleName;

if($mode == 'save'){
    require_once 'modules/PickList/DependentPickListUtils.php';
    $_REQUEST['diony']='diony';
    //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/8 0008 下午 2:56
    $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
    //APPROVEFINISHEDALLOWEDIT

    //edit:can 20241204 费用报销单  修改费用类别的默认值 不生效，
    $sql='select  fieldid from ld_field where fieldname=?  and tabid=? ';
    $result=$adb->pquery($sql,array($_REQUEST['fieldname'],getTabid($moduleName)));
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$_REQUEST['fieldname']);
    if($adb->num_rows($result)>0 || $tableName == 'campaignaccountrelstatus')
    {
        $selectvalue = $objPickList->savePickFieldEdit($_REQUEST['comboxjson'],$tableName,$table_name,$columnname,$moduleName,$_REQUEST['selectvalue'],'ld_field');
        
        if($_REQUEST['sourcevalue']!=""&&$_REQUEST['sourcefield']!="")
        {
            
            //保存级联字段
           $dep=json_decode(vtlib_purify($_REQUEST['targetvalue']),true);
           
            lingdang_DependencyPicklist::savePickListDependencies($moduleName,$_REQUEST['sourcefield'],$_REQUEST['fieldname'],$_REQUEST['sourcevalue'],$dep);
            @unlink(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$moduleName.'_pickdepencylist.php');
        }
    }else{
        if(get_file_address($moduleName,$moduleName.'DetailFieldsHtml'))
        {
            $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$_REQUEST['fieldname']);
            $selectvalue = $objPickList->savePickFieldEdit($_REQUEST['comboxjson'],$tableName,$table_name,$columnname,$moduleName,$_REQUEST['selectvalue'],'ld_tabdetailfield');
        }
        else if(get_file_address($moduleName,'ProductDetails'))
        {
            $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$_REQUEST['fieldname']);
            
            $selectvalue = $objPickList->savePickFieldEdit($_REQUEST['comboxjson'],$tableName,$table_name,$columnname,$moduleName,$_REQUEST['selectvalue'],'ld_producttoolfield');
        }
    }
   
        
    //旧代码002
    
       
   // unlink(globalStatic::$root_directory."dataCache/picklist/datacache_".$moduleName."_pickdepencylist.php");
  
   //单据分录自定义字段
   if($_REQUEST['savefrom']=='settings')//控制面板（级联字段)
       //wym 240103 BUG0078134 级联字段定制-编辑字段，添加“+”符号，保存后，没有显示这个符号。
		$jsonarr['list']=json_decode(urldecode($_REQUEST['comboxjson']),true);
  
   else if($_REQUEST['selectvalue'] == 'undefined'){
    
    
            //控制面板保存下拉框
        $tmpjsonarr = json_decode($_REQUEST['comboxjson'],true);
        $jsonarr=array();
        foreach($tmpjsonarr as $tmpindex=>$values)
        {
            $jsonarr[$tmpindex]=array('oldval'=>urldecode($values['oldval'])
                                ,'value'=>urldecode($values['value']),'type'=>$values['type']);
        }
   }
   else
   {
     $jsonarr=getComboxCoverArr($tableName,$selectvalue,$uitype,$fieldinfo);
     //dump($jsonarr);//普通下拉框     
   }
   $changedcombox_arr=json_decode($_REQUEST['comboxjson'],true);
  
    //针对账户字段下拉框，在表ld_bankaccountset_picklist中更新银行账户记录的排序
    if($uitype==251||$uitype==252){
        $fieldname=$_REQUEST['fieldname'];
    	$sequence=0;
        //遍历下拉框中账户的信息
    	foreach($changedcombox_arr as $values){
            $sequence+=1;//获取账户在下拉框的位置
            $tmp_value['sequence']=$sequence;
            $tmp_value['bankaccountsetid']=$values['type'];
            $tmp_value['oldval']=urldecode($values['oldval']);
            $tmp_value['value']=urldecode($values['value']);
            $tmp_value['pick_color']=urldecode($values['pick_color']);
            $jsonarr['changedcombox'][]=$tmp_value;
            $sql='update ld_bankaccountset_picklist set sequence=? where bankaccountsetid=? and tabid=? and fieldname=?';
            $adb->pquery($sql,array($tmp_value['sequence'],$tmp_value['bankaccountsetid'],$tabid,$fieldname));
       }
    }else{//其他下拉框
       $jsonarr['changedcombox']=array();
       foreach($changedcombox_arr as $values){
            $tmp_value['type']=$values['type'];
            $tmp_value['oldval']=urldecode($values['oldval']);
            $tmp_value['value']=urldecode($values['value']);
            $tmp_value['pick_color']=urldecode($values['pick_color']);
            $jsonarr['changedcombox'][]=$tmp_value;
       }
    }
    unsetCacheDirectory('productfields');//BUG0071846 xxy 2023-8-30 费用报销单新建-分录费用类别的默认值设置不生效
    unsetCacheDirectory('tabdetailfields');//BUG0071846 xxy 2023-8-30 费用报销单新建-分录费用类别的默认值设置不生效  
    ConvertTojsonString(1,$jsonarr,"success");

}elseif($mode == 'delete'){
    //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 下午 6:01
    $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
    $sql='select  fieldid from ld_field where fieldname=? ';
    $result=$adb->pquery($sql,array($_REQUEST['fieldname']));
    if($adb->num_rows($result)>0 || $_REQUEST['fieldname'] == 'campaignaccountrelstatus')
    {
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$_REQUEST['fieldname']);
        $selectvalue = $objPickList->replacePickField($tableName,$_REQUEST['values'],$_REQUEST['replaceVal'],$moduleName,$table_name,$columnname,$_REQUEST['selectvalue'],'ld_field');
    }
    else
    {
        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$_REQUEST['fieldname']);
         if(get_file_address($moduleName,$moduleName.'DetailFieldsHtml'))
        {
            $selectvalue = $objPickList->replacePickField($tableName,$_REQUEST['values'],$_REQUEST['replaceVal'],$moduleName,$table_name,$columnname,$_REQUEST['selectvalue'],'ld_tabdetailfield');
        }
        else if(get_file_address($moduleName,'ProductDetails'))
        {
            $selectvalue = $objPickList->replacePickField($tableName,$_REQUEST['values'],$_REQUEST['replaceVal'],$moduleName,$table_name,$columnname,$_REQUEST['selectvalue'],'ld_producttoolfield');
        }
    }
   
    
        
    //旧代码001
    $jsonarr=getComboxCoverArr($tableName,$selectvalue,$uitype,$fieldinfo);
   // unlink(globalStatic::$root_directory."dataCache/picklist/datacache_".$moduleName."_pickdepencylist.php");
   
    ConvertTojsonString(1,$jsonarr,"success");
}
elseif($mode == 'gethtml'){
    //页签
    $checkedcolor=array('color'=>'','type'=>'preset');
    $selectcolor=strtoupper($_REQUEST['selectedcolor']);
    $tab=array('preset'=>getFixedLabel('PRESETCOLOR'),'custom'=>getFixedLabel('custom'));
    //浅色系和亮色系
    $sql='select color,type from ld_picklist_presetcolor order by sequence';
    $result=$adb->pquery($sql,array());
    $num_row=$adb->num_rows($result);
    if ($num_row>0){
        for ($i=0;$i<$num_row;$i++){
            $color=$adb->query_result($result,$i,'color');
            $type=$adb->query_result($result,$i,'type');
            if ($color == $selectcolor){
                $checkedcolor=array('color'=>$color,'type'=>$type);
            }
            if ($type == 'preset') {
                $presetcolor[] = array('color'=>$color);
            }
        }
    }
    $smarty->assign('checkedcolor',$checkedcolor);
//    dump($selectcolor);
    $smarty->assign('colortab',$tab);
    $smarty->assign('presetcolor',$presetcolor);
    $arr['title']=getFixedLabel('SELECTCOLOR');
    $arr['content']=$smarty->fetch('modules/PickList/PickListPresetColor.tpl');
    ConvertTojsonString(1,$arr,'success');
}


function getComboxCoverArr($tableName,$default,$uitype,$fieldinfo){
    global $adb;
    
    // if($uitype=='33') $default='';
    crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
    //dump(array($tableName, $default, $adb,$fieldinfo));
    $optionvalue=getEditViewPagePickList($tableName, $default, $adb,$fieldinfo);
    //dump($optionvalue);//普通下拉框
 
    $optiontext = '';
    $selecttext = '';
    $i = 1;
    if($uitype==15 || $uitype==34){
        $arr['comboxtype'] = 'onepick';
        $arr['optiontext'] = $optiontext;
        $arr['selecttext'] = $optionvalue;
    }elseif($uitype==33){
        
        foreach($optionvalue as $val){
            if($val[2]=='selected'){
                $optiontext .= "<option value='$val[0]' selected='true'>$val[0]</option>";
            }else{
                $optiontext .= "<option value='$val[0]' >$val[0]</option>";
            }
            $selecttext .= "<li class='active-result' style='' name='dv_chzn_$i"."_$tableName' onclick=\"cmb_liclick('$val[0]','$tableName')\" onmouseover=\"cmb_limouseover(event,'$tableName')\">$val[0]</li>";
            $i++;
        }
        $arr['comboxtype'] = 'multipick';
        $arr['optiontext'] = $optiontext;
        $arr['selecttext'] = $optionvalue;// 2024-6-24 xxy 字段类型为多选框时，设置默认值不成功
    }
    $_REQUEST['diony']='diony';
    return $arr;
}

?>