<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//ls 2022-03-10 【1002521】页面设置，增加【字段列表】标签
require_once('include/CustomFieldUtil.php');
require_once 'modules/PickList/PickListUtils.php';
global $adb,$current_user;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty;

$fld_module=vtlib_purify($_REQUEST['frommodule']);
$searchtext=vtlib_purify($_REQUEST['searchtext']);
if($fld_module=='Calendar') {
    $fld_module='Events';
}

$smarty->assign("MODULE",$fld_module);
$fieldz = getCFFieldList($fld_module,$searchtext);
//dump($fieldz);
$smarty->assign("CFENTRIES",$fieldz);//字段信息

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    $arr['content']=$smarty->fetch('Settings/LayoutBlockList_CFOperationLog.tpl');
}else{
    $arr['content']=$smarty->fetch('Settings/LayoutBlockList_CFOperationSearch.tpl');
}
ConvertTojsonString(1,$arr,'success');


function getCFFieldList($module,$searchtext='') {
    global $handleWriteSign_interface,$adb,$current_user;

    if($module=='Events')
    {
        $tabid =16;
    }
    else
    {
        $tabid = getTabid($module);
    }
    global $adb, $smarty,$current_user,$languageType;

    require('user_privileges/user_language_'.$current_user->id.'.php');
    if($languageType=='zh')
    {
        $fieldlabeltype='fieldlabel_zh';
    }else{
        $fieldlabeltype = 'fieldlabel_en';
    }

    //字段搜索
    if (!empty($searchtext)) {
        $otherConditions .=" AND ($fieldlabeltype like '%".$searchtext."%' ) ";
    }

  
    $sql = "select fieldid,uitype,bigtype,relatedmodulefield,createdtime,create_operator ,deletedtime,delete_operator ,$fieldlabeltype from ld_cfoperationlog
            where tabid = ? ".$otherConditions." order by modifiedtime desc";
    $result_field = $adb->pquery($sql,array($tabid));
    $row_field= $adb->fetch_array($result_field);
    if($row_field!='') {
        $cf_element=Array();
        $cf_hidden_element=Array();
        $count=0;
        $hiddencount=0;

        do {
            $fieldid = $row_field['fieldid'];
            $fieldname = $row_field[$fieldlabeltype];
            $createdtime = $row_field['createdtime'];
            $create_operatorID = $row_field['create_operator'];
            $deletedtime = $row_field['deletedtime'];
            $delete_operatorID = $row_field['delete_operator'];
            $uitype = $row_field['uitype'];
            $bigtype = $row_field['bigtype'];
            $relatedmodulefield = $row_field['relatedmodulefield'];
            if($relatedmodulefield == 'yes'){
                $bigtype = 'relatedmodulefield';
            }

            $fld_type_name = getCustomFieldTypeByBigtype($uitype,$bigtype,'ld_fieldid');
            $create_operator = getUserFullName($create_operatorID);
            $delete_operator = getUserFullName($delete_operatorID);

            $cf_element[$count]['fieldid']=$fieldid;
            $cf_element[$count]['no']=$count;
            $cf_element[$count]['fieldlabel'] = $fieldname;
            $cf_element[$count]['type']=$fld_type_name;
            $cf_element[$count]['uitype']=$uitype;
            $cf_element[$count]['bigtype']=$bigtype;

            $cf_element[$count]['createdtime']=$createdtime;
            $cf_element[$count]['create_operator']=$create_operator;
            $cf_element[$count]['deletedtime']=$deletedtime;
            $cf_element[$count]['delete_operator']=$delete_operator;
            $count++;
        } while($row_field = $adb->fetch_array($result_field));

        return $cf_element;
    }

}


?>