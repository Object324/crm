<?php
/**
 * edit:andrew
 * date:2015-6-2
 * reason:设置查询字段
 **/
global $adb,$current_user;
$setmodule = $_REQUEST['setmodule'];

if($_REQUEST['settype']=='save'){
    $SQL = 'UPDATE ld_field SET searchfieldtype=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name=?) AND fieldid IN ('.$_REQUEST['checklist'].')';
    //edit:can 20210820 47528: http://10.2.0.11:85/crm/ [^]（施依洛、没有开通外网）跟进记录中选择销售计划，设置显示的字段，点击保存没有生效
    if($setmodule=='Calendar')
    {
        $adb->pquery($SQL,array('events'));
    }
    else
        $adb->pquery($SQL,array($setmodule));
    $SQL = 'UPDATE ld_field SET searchfieldtype=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name=?) AND fieldid NOT IN ('.$_REQUEST['checklist'].')';

      if($setmodule=='Calendar')
    {
        $adb->pquery($SQL,array('events'));
    }
    else
        $adb->pquery($SQL,array($setmodule));
    unsetCacheDirectory('fields');
    exit();
}



$focus=CRMEntity::getInstance($setmodule);
$tabarray = $focus->tab_name;

foreach($tabarray as $key=>$arr){
    $tabarray[$key]=strtolower($arr);
}
	$entityfieldname = getEntityFieldNames($module);
  
	$entityname = $entityfieldname['fieldname'];
$smarty = new lingdangCRM_Smarty;
$frommodule = $_REQUEST['frommodule'];
$smarty->assign("FROMMODULE",$frommodule);
$smarty->assign("TYPE",$_REQUEST['type']);
if($setmodule == 'Users'){
    $setFieldList = setUsersSearchFieldList($setmodule,$languageType,$tabarray);
}else{
    $setFieldList = setSearchFieldList($setmodule,$languageType,$tabarray);
}
$smarty->assign("MODULE",$setmodule);
$smarty->assign("SETFIELDLIST",$setFieldList);
$smarty->assign("Hreffieldname",$focus->list_link_field);

if($_REQUEST['fieldname'])
{
    $smarty->assign("FIELDNAME",$_REQUEST['fieldname']);
}
else
{
    $smarty->assign("FIELDNAME",'');
}
$str=$smarty->fetch("setSearchField.tpl");
$_REQUEST['diony']='diony';
$retarr['title']=getFixedLabel("SETFIELD");
$retarr['oktext']=getFixedLabel("SAVE");
$retarr['canceltext']=getFixedLabel("CANCEL");
$retarr['content']=$str;

ConvertTojsonString(1,$retarr,"success");


function setSearchFieldList($setmodule,$languageType,$tabarray){
    global $adb,$current_user;
    
    $languageType= getLanguageType($current_user);
    $fieldobj=Field::getInstance($setmodule,$adb);
    $modulefields=$fieldobj->getModuleFields();
    
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
        //30428: 联系人选择弹出层，“照片”字段显示出来，结果有照片的显示undefined，应该控制列不允许显示照片列
		//chj 2020/11/18 43337: （61mis.com/kfbcrm）销售管理-合同订单-新建/编辑；以合同订单为例，选择客户时，设置查找字段中有“标签”可选择，但选择后进行查找不显示结果；请将“标签”在设置查找字段去掉。
         if($fieldinfo->getUIType()==69||$fieldinfo->getUIType()==301||$fieldinfo->getSaveDataBase()=='no')
                continue;
        $tablename =$fieldinfo->getTableName();
        if(in_array(strtolower($tablename),$tabarray)){
           
            $fieldid=$fieldinfo->getFieldid();
            $fieldlist[$fieldid]['fieldlabel']=$fieldinfo->getFieldLabelKey();
            $fieldlist[$fieldid]['columnname']=$fieldinfo->getColumnName();
            $fieldlist[$fieldid]['searchfieldtype']=$fieldinfo->getSearchFieldType();
            $fieldlist[$fieldid]['tablename']=$tablename;
        }
    }
    /*echo "<pre>";
    print_r($fieldlist);
    echo "<pre>";*/
    return $fieldlist;
    
}

function setUsersSearchFieldList($setmodule,$languageType,$tabarray){
    global $adb,$current_user;
    
    $languageType= getLanguageType($current_user);
    $fieldobj=Field::getInstance($setmodule,$adb);
    $modulefields=$fieldobj->getListSearchFields();
    
    $modulenoshowfields['Users'] = array('activity_view', 'lead_view', 'hour_format', 'end_hour'
        , 'start_hour', 'title', 'reports_to_id', 'phone_other'
        , 'secondaryemail', 'signature', 'address_street', 'address_city', 'address_state', 'address_postalcode'
        , 'address_country', 'accesskey', 'time_zone', 'currency_id', 'currency_grouping_pattern', 'currency_decimal_separator'
        , 'currency_grouping_separator', 'currency_symbol_placement', 'internal_mailer', 'theme', 'language'
        , 'reminder_interval', 'asterisk_extension', 'use_asterisk', 'attachmentsid', 'date_format', 'email2'
        , 'confirm_password', 'user_password', 'viewothers', 'editothers', 'imagename'
        , 'delothers', 'viewselfbills', 'edit_other_mobile', 'edit_me_mobile', 'is_mobile_style'
        , 'select_servicedetail', 'select_due_date', 'trackpostion', 'login_sms', 'telephone_view'
        , 'push_work_reminds', 'push_news_reminds', 'push_wx_reminds', 'scopeauthority', 'accountallview');
    
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
         if($fieldinfo->getUIType()==69||$fieldinfo->getUIType()==301||$fieldinfo->getSaveDataBase()=='no')
                continue;
         if(in_array($fieldname,$modulenoshowfields[$setmodule])){
            continue;
         }
        $tablename =$fieldinfo->getTableName();
        if(in_array(strtolower($tablename),$tabarray)){
           
            $fieldid=$fieldinfo->getFieldid();
            $fieldlist[$fieldid]['fieldlabel']=$fieldinfo->getFieldLabelKey();
            $fieldlist[$fieldid]['columnname']=$fieldinfo->getColumnName();
            $fieldlist[$fieldid]['searchfieldtype']=$fieldinfo->getSearchFieldType();
            $fieldlist[$fieldid]['tablename']=$tablename;
        }
    }
    
    
    return $fieldlist;
    
}


?>