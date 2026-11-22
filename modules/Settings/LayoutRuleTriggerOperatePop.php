<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//新增布局规则-》触发字段操作
global $adb;
$frommodule=$_REQUEST['frommodule'];
$triggeroperate=$_REQUEST['triggeroperate'];
$arr_triggeroperate=json_decode($triggeroperate,true) ;
$type=$_REQUEST['type'];
$selectcols = [];
foreach($arr_triggeroperate as $index=>$infos)
{
    $selectcols[]=$infos['columnname'];
    $type=$infos['type'];
    
}
$focus=CRMEntity::getInstance($frommodule);
$tab_name_index=$focus->tab_name_index;

$modulefields=$focus->fieldobj->getModuleFields();
//获取成员管理不显示字段
$modulenoshowfields = array();
if($frommodule == 'Users'){
    $modulenoshowfields = $focus->getSearchNoshowfields();
}

foreach($modulefields as $fieldname=>$fieldinfo)
{
    //成员管理不显示字段，不显示
    if(in_array($fieldname,$modulenoshowfields)){
        continue;
    }
    $columnname=$fieldinfo->getColumnName();
    $tablename=$fieldinfo->getTableName();
	$uitype = $fieldinfo->getUIType();
    
    if(($frommodule=='Accounts'||$frommodule=='ServiceCharge') && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')){
        //客户模块的联系人字段特殊处理
    }else if(!array_key_exists($tablename,$tab_name_index)&&$tablename!='ld_attachments')
    {
        continue;
    }
   //标签应该不显示在布局规则：触发操作
	if($uitype == 301){
		continue;
	}
    if($type=='required')
    {
       $typeofdata=$fieldinfo->getTypeOfData();
       $typeofdata=strtolower($typeofdata);
        //必填字段设置

        if(($fieldinfo->getSaveDataBase()=='no'||$fieldinfo->getDisplaytype()==2||$fieldinfo->getDisplaytype()==3))
        {
            //getDisplaytype:2表示查看界面的字段
            //duan 20240322 除了拜访签到模块，其他模块的布局规则可以选择签到字段
            if($fieldinfo->getBigType() == 'signin' && $frommodule !='Singin' ){
            }else{
                continue;
            }
        }
        if(strpos($typeofdata,'~m')!==false)
        {
            //38125: （51mis.com/kfbcrm）页面设置->布局规则：触发操作-设置必填字段下拉选项中应该不显示【字段布局中的必填字段】（需要补丁）
            //continue;
        }
    }
    $allowhide=$fieldinfo->getAllowHide();
    $typeofdata=$fieldinfo->getTypeOfData();
    $typeofdatas=explode("~",$typeofdata);
    //chj 2021/5/27 46109: （61mis.com/kfbcrm）系统设置-页面设置-客户-布局规则；设置布局规则显示字段时，必填字段不应该显示在可选择列表中
    if($type=='display')
    {
        //必填字段不能设置是否显示
        //continue;
    }
    $blockid=$fieldinfo->getBlockId();
    $blockfields[$blockid][]=$fieldinfo;
    
    
}

$blockinfos=$focus->fieldobj->getBlockInfos();
$strhtml='<optgroup label="'.getFixedLabel("PLEASESELECTFIELD").'">'.getFixedLabel("PLEASESELECTFIELD")."</optgroup>";

foreach($blockinfos as $blockid=>$blockinfo)
{
    $tmpfields=$blockfields[$blockid];
    if(!is_array($tmpfields) || sizeof($tmpfields)<=0)
    {
        continue;
    }
    $strhtml.='<optgroup label="'.$blockinfo['blocklabel'].'">';


    foreach($tmpfields as $index=>$fieldinfo)
    {
        $columnname=$fieldinfo->getColumnName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        if(in_array($columnname,$selectcols)) {
            $strhtml.="<option value='".$columnname."' selected>".$fieldlabel.'</option>';
        } else
            $strhtml.="<option value='".$columnname."'>".$fieldlabel.'</option>';
    }
      
    $strhtml.="</optgroup>";
    
}

$smarty=new lingdangCRM_Smarty();
$smarty->assign("OPTIONHTML",$strhtml);
$content=$smarty->fetch("Settings/LayoutRuleTriggerOperatePop.tpl");

$_REQUEST['diony']='yes';
$arr['content']=$content;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
if($_REQUEST['type']=='required')
{
    //设置必填字段
    $arr['title']=getFixedLabel('Triggeredoperation').'-'.getFixedLabel('Setmandatoryfield');
}
else
    $arr['title']=getFixedLabel('Triggeredoperation').'-'.getFixedLabel('Displayfields');
    
ConvertTojsonString(1,$arr,'success');

?>