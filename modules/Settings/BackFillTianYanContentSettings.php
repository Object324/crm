<?php

global $current_user,$adb,$smarty;

$mode = $_REQUEST['mode'];
$frommodule = $_REQUEST['frommodule'];
$tabid = getTabid($frommodule);
if(isset($mode)&&$mode=='edittianyanchaname')
{
    $tianyanchaname = $_REQUEST['tianyanchaname'];
    $focus=CRMEntity::getInstance($frommodule);
    $modulefields=$focus->fieldobj->getModuleFields();
    //下拉框内容
    $select_arr = array();
    //"--无--"
    $selcet_arr[] = array('columnname'=>'null','value'=>$frommodule.':null:','fieldlabel'=>'--'.getFixedLabel('NONE').'--');
    $i=1;
    $table_name_index=$focus->tab_name_index;
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
        $uitype = $fieldinfo->getUIType();
        $bigtype = $fieldinfo->getBigType();
        //标签应该不显示
        if($uitype == 301){
            continue;
        }
        if($bigtype == 'selectoneuser'||$bigtype == 'selectmultiuser'||$bigtype == 'selectsource'||$bigtype == 'reference'
            ||$bigtype == 'fileattachment'||$bigtype == 'boolean'||$bigtype == 'multipicklist'||$bigtype == 'users'||$bigtype == 'richtext')
            continue;
        //下拉框内容显示首要联系人对应内容
        if(array_key_exists($tablename,$table_name_index)||$tablename=='ld_contactdetails')
        {
            $blockfields[$fieldinfo->getBlockId()][]=$fieldinfo;
            $displaytype=$fieldinfo->getDisplaytype();
            if($displaytype==2||$displaytype==3)continue;
            $columnname=$fieldinfo->getColumnName();
            $fieldname=$fieldinfo->getFieldName();
            $fieldlabel=$fieldinfo->getFieldLabel();


            $colvalue = $frommodule.':'.$columnname.':'.$bigtype;
            $selcet_arr[] = array('columnname'=>$columnname,'value'=>$colvalue,'fieldlabel'=>$fieldlabel);
            $i++;
        }
    }
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
    $Backfillingmap_arr = $businessinformationobj->getBackFillFields();
    $backfillfields_arr = [];
    foreach ($Backfillingmap_arr as $tmpindex=>$backfillingarr)
    {
        if($backfillingarr['tianyanchaname'] == $tianyanchaname){
            $backfillfields_arr[] = $backfillingarr;
            break;
        }
    }
    $smarty->assign('BACKFILLFIELD',$backfillfields_arr);
    $smarty->assign('SELECTOPTION',$selcet_arr);
    $content=$smarty->fetch('Settings/BackFillTianYanChaSettings.tpl');
    $arr['backfillfields'] = $backfillfields_arr;
    $arr['fieldcount'] = count($backfillfields_arr);
    $arr['content']= $content;
    $arr['title']=getFixedLabel('Setbackfillfield');
    $arr['oktext']= getFixedLabel('CONFIRMED');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    ConvertTojsonString(1,$arr,'success');

}
else if(isset($mode)&&$mode=='savetianyanchaname')
{
    $tianyanchaname = $_REQUEST['tianyanchaname'];

    if(isset($_REQUEST['selectoptions'])&&!empty($_REQUEST['selectoptions'])){
        $selectoptions = ldcrm_json_decode(trim($_REQUEST['selectoptions']));
    }
    else{
        ConvertTojsonString(-1,array(),'success');
    }
    $savetabid = getTabid($frommodule);
    $optionarr = explode(':',$selectoptions[0]);
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
    $businessinformationobj->updataBackFillField($savetabid,$tianyanchaname,$optionarr[2],$optionarr[3]);

    ConvertTojsonString(1,array(),'success');
}
else if(isset($mode)&&$mode=='edit')
{
    
    $focus=CRMEntity::getInstance($frommodule);
    $modulefields=$focus->fieldobj->getModuleFields();
    $blockinfos=$focus->fieldobj->getBlockInfos();
    //下拉框内容
    $select_arr = array();
    //"--无--"
    $selcet_arr[] = array('columnname'=>'null','value'=>$frommodule.':null:','fieldlabel'=>'--'.getFixedLabel('NONE').'--');
    $i=1;
    $table_name_index=$focus->tab_name_index;
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
    	$uitype = $fieldinfo->getUIType();
    	//标签应该不显示
    	if($uitype == 301){
    		continue;
    	}
        //下拉框内容显示首要联系人对应内容
        if(array_key_exists($tablename,$table_name_index)||$tablename=='ld_contactdetails')
        {
            $blockfields[$fieldinfo->getBlockId()][]=$fieldinfo;
            $displaytype=$fieldinfo->getDisplaytype();
            if($displaytype==2||$displaytype==3)continue;
           $columnname=$fieldinfo->getColumnName();
           $fieldname=$fieldinfo->getFieldName();
           $fieldlabel=$fieldinfo->getFieldLabel();
           $bigtype = $fieldinfo->getBigType();
           
           
           $colvalue = $frommodule.':'.$columnname.':'.$bigtype;
           $selcet_arr[] = array('columnname'=>$columnname,'value'=>$colvalue,'fieldlabel'=>$fieldlabel);
           $i++;
        }
    }

    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
    $businessinformationobj->compareBackfillFields();
    $backfillfields_arr = $businessinformationobj->getBackFillfields();
    $smarty->assign('BACKFILLFIELD',$backfillfields_arr);
    $smarty->assign('SELECTOPTION',$selcet_arr);
    $content=$smarty->fetch('Settings/BackFillTianYanChaSettings.tpl');
    
    $arr['backfillfields'] = $backfillfields_arr;
    $arr['fieldcount'] = count($backfillfields_arr);
    $arr['content']= $content;
    $arr['title']=getFixedLabel('Setbackfillfield');
    $arr['oktext']= getFixedLabel('CONFIRMED');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    ConvertTojsonString(1,$arr,'success');
}
else if(isset($mode)&&$mode == 'save')
{
    if(isset($_REQUEST['selectoptions'])&&!empty($_REQUEST['selectoptions'])){
        $selectoptions = ldcrm_json_decode(trim($_REQUEST['selectoptions']));
    }
    else{
        ConvertTojsonString(-1,array(),'success');
    }

    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
    foreach($selectoptions as $key => $option)
    {
        $optionarr = explode(':',$option);
        $tianyanchaname = $optionarr[0];
        $module = $optionarr[1];
        $trancolumnname = $optionarr[2];
        $trancoltype = $optionarr[3];
        $savetabid = getTabid($frommodule);
        $businessinformationobj->updataBackFillField($savetabid,$tianyanchaname,$trancolumnname,$trancoltype);
    }
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
    $backfillfields_arr = $businessinformationobj->getBackFillfields();
    $arr['backfillarr'] = $backfillfields_arr;
    ConvertTojsonString(1,$arr,'success');
}
?>