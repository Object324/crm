<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/6/24
 * Description: 获取新建页面的自定义字段的html
 */
global  $theme, $currentModule, $current_user,$languageType;
$usedFields = vtlib_purify($_REQUEST['usedFields']);
$mappingModule = vtlib_purify($_REQUEST['mappingModule']);
$usedFields = explode(';',$usedFields);

$focus = CRMEntity::getInstance($mappingModule);
$tab_name_index=$focus->tab_name_index;
$fieldObj=$focus->fieldobj;
$moduleFields=$fieldObj->getModuleFields();
$noUseFields = array();
//载入配置文件
require_once ('SocialPromotionConfig.php');

foreach ($moduleFields as $columnname => $field){
    if(!in_array($columnname,$usedFields) && in_array($field->uitype,$needUiType) && $field->displaytype ==1 && $field->presence != 1 && $field->allowedit != 'no'){
        $noUseFields[] = $field;
    }
}


foreach($noUseFields as $fieldname=>$fieldinfo)
{
    $columnname=$fieldinfo->getColumnName();
    $tablename=$fieldinfo->getTableName();
    if(!array_key_exists($tablename,$tab_name_index)&&$tablename!='ld_attachments')
    {
        continue;
    }

    if($type=='required')
    {
        $typeofdata=$fieldinfo->getTypeOfData();
        $typeofdata=strtolower($typeofdata);
        //必填字段设置
        if($fieldinfo->getSaveDataBase()=='no'||$fieldinfo->getDisplaytype()==2||$fieldinfo->getDisplaytype()==3)
        {
            //getDisplaytype:2表示查看界面的字段

            continue;
        }
        if(strpos($typeofdata,'~m')!==false)
        {
            //38125: （51mis.com/kfbcrm）页面设置->布局规则：触发操作-设置必填字段下拉选项中应该不显示【字段布局中的必填字段】（需要补丁）
            continue;
        }
    }
    $allowhide=$fieldinfo->getAllowHide();
    $typeofdata=$fieldinfo->getTypeOfData();
    $bigtype=$fieldinfo->getBigType();
    if($bigtype=='fileattachment')
        continue;
    $typeofdatas=explode("~",$typeofdata);
    
    if($type=='display'&&($allowhide=='no'||stripos($typeofdatas[1],'m')>0))
    {
        //必填字段不能设置是否显示
        continue;
    }
    $blockid=$fieldinfo->getBlockId();
    $blockfields[$blockid][]=$fieldinfo;


}

$blockinfos=$focus->fieldobj->getBlockInfos();
$strhtml='<optgroup label="'.getFixedLabel("PLEASESELECTFIELD").'">'.getFixedLabel("PLEASESELECTFIELD")."</optgroup>";

foreach($blockinfos as $blockid=>$blockinfo)
{
    $tmpfields=$blockfields[$blockid];
    if(sizeof($tmpfields)<=0)
    {
        continue;
    }
    $strhtml.='<optgroup label="'.$blockinfo['blocklabel'].'">';
    foreach($tmpfields as $index=>$fieldinfo)
    {
        $columnname=$fieldinfo->getColumnName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        if(in_array($columnname,$selectcols))
        {
            $strhtml.="<option value='".$columnname."' selected>".$fieldlabel.'</option>';
        }
        else
            $strhtml.="<option value='".$columnname."'>".$fieldlabel.'</option>';
    }
    $strhtml.="</optgroup>";
}

$smarty=new lingdangCRM_Smarty();
$smarty->assign("OPTIONHTML",$strhtml);
$content=$smarty->fetch("modules/SocialPromotion/SocialCustomField.tpl");

$_REQUEST['diony']='yes';
$arr['content']=$content;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");

//设置必填字段
$arr['title']=getFixedLabel('ADDITION').'-'.getFixedLabel('Add_custom_fields');


ConvertTojsonString(1,$arr,'success');

