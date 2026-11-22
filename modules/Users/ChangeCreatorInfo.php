<?php
global $adb,$current_user,$languageType;
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if($_REQUEST['changetype']=='averageDistribution'){
    crm_load_class_file('cls_AverageDistribution','modules/Users');    
    $obj=new cls_AverageDistribution($_REQUEST['setype']);
}
elseif ($_REQUEST['changetype']=='autoDistribution'){//圣拉维自动分配
    crm_load_class_file('cls_AutoDistribution','modules/Users');
    $obj=new cls_AutoDistribution($_REQUEST['setype']);
}
else{
    crm_load_class_file('cls_ChangeCreatorInfo','modules/Users');
    $obj=new cls_ChangeCreatorInfo($_REQUEST['setype']);
}

// 是否同步分配相关信息
if(isset($_REQUEST['enablerelatedinfo']) && !empty($_REQUEST['enablerelatedinfo'])){
    $obj->relatedinfoset_arr['sharerelatedinfo'] = $_REQUEST['enablerelatedinfo'];
    if(isset($_REQUEST['shareoldsmowner']) && !empty($_REQUEST['shareoldsmowner'])){
        $obj->relatedinfoset_arr['shareoldsmowner'] = $_REQUEST['shareoldsmowner'];
    }
    if(isset($_REQUEST['relmodule_scope']) && !empty($_REQUEST['relmodule_scope'])){
        $obj->relatedinfoset_arr['relmodule_scope'] = $_REQUEST['relmodule_scope'];
        $obj->relatedinfoset_arr['relmodule_selectedtabid_str'] = $_REQUEST['selectedtabid_str'];
    }
    if(isset($_REQUEST['reldata_scope']) && !empty($_REQUEST['reldata_scope'])){
        $obj->relatedinfoset_arr['reldata_scope'] = $_REQUEST['reldata_scope'];
    }
    if($_REQUEST['changetype']=='averageDistribution'){
        $obj->relatedinfoset_arr['type'] = 'seniorAverageAllocate';
    }else{
        $obj->relatedinfoset_arr['type'] = 'seniorAllocate';
    }
}

$obj->setChangeOperation();
exit();
?>