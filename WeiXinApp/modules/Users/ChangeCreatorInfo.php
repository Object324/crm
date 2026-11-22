<?php
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include 'cls_ChangeCreatorInfoWX.php';
$obj=new cls_ChangeCreatorInfoWX($_REQUEST['setype']);

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
?>