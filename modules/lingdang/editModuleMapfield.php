<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $current_user;

$frommodule = $_REQUEST['frommodule'];
$module = $_REQUEST['module'];
$mode = $_REQUEST['mode'];
crm_load_class_file("cls_ModuleMap","modules/Users");
if($mode == 'edit')
{
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,0,0);
    $productListViewAll = $cls_modulemapobj->getmodulemapFieldAll();
    $modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
    
    $rightlist = array();
    foreach($modulemapfieldinfo as $index=>$info)
    {
        $moduleInfo = explode(':',$info['columns']);
        $moduleName = explode('_',$moduleInfo[3]);
        $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];
        $fieldlabel = $info['fieldlabel'];
        $rightlist[$columns] = getTranstab($moduleName[0]) . '_' . $fieldlabel;
    }
    
    if(!empty($rightlist))
    {
        $productListViewAll = array_diff($productListViewAll,$rightlist);
    	/**
    	 * 服务收费时，有可能客户字段的标签名跟服务收费的标签名不一致，所以需要用键值进行查重（键值是一致的）
    	 */
    	if('ServiceCharge' == $module){
    		$productListViewAll = array_diff_key($productListViewAll,$rightlist);
    	}
    }
    
    $smarty = new lingdangCRM_Smarty;
    
    
    $smarty->assign("PRODUCTLISTVIEWALL",$productListViewAll);//获取所有模块界面字段

    $smarty->assign("HAVEPRODUCTLISTVIEWALL",$rightlist);//获取已选择列头
    setGLobalURLSmarty($smarty);
    $strContent= $smarty->fetch("ModuleMapfield.tpl");
    
    
    $arr['content'] = $strContent;
    $arr['title'] = getFixedLabel('SETMAPDISPLAYFIELD');
    $arr['oktext'] = getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    ConvertTojsonString(1,$arr,'success');
}
else if($mode == 'save'){
    $fromrecordid = $_REQUEST['fromrecordid'];
    $relatedid = $_REQUEST['relatedid'];
    
    $mapfields = trim($_REQUEST['mapfields'],',');
    $mapfieldarr = explode(',',$mapfields);
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecordid,$relatedid);
    $cls_modulemapobj->savemodulemapField($mapfieldarr);
    $cls_modulemapobj->ResetmodulemapField();
    //获取字段信息
    $modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
    //获取对应的数据信息
    $moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
    $arr['modulemapfieldinfo']=$modulemapfieldinfo;
    $arr['moduledatainfo']=$moduledatainfo;
    
    ConvertTojsonString(1,$arr,'success');
    
}
?>