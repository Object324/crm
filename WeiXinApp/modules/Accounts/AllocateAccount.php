<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//D:\wamp\www\ldcrm\mobileapi\6.5.0\htmlmodules\Accounts\cls_AllocateAccount.php
global $current_user;
    //include 'cls_AllocateAccountWX.php';
    unset($_REQUEST['userid']);
    $allocate = cls_Instance::get_commonAction_Instance('Accounts','AllocateAccount',1);
    if(isset($_REQUEST['allocate_userid'])){
        $userid = $_REQUEST['allocate_userid'];
    }else{
        $userid = $current_user->id;
    }

    // 是否同步分配相关信息
    if(isset($_REQUEST['enablerelatedinfo']) && !empty($_REQUEST['enablerelatedinfo'])){
        $allocate->relatedinfoset_arr['sharerelatedinfo'] = $_REQUEST['enablerelatedinfo'];
        if(isset($_REQUEST['shareoldsmowner']) && !empty($_REQUEST['shareoldsmowner'])){
            $allocate->relatedinfoset_arr['shareoldsmowner'] = $_REQUEST['shareoldsmowner'];
        }
        if(isset($_REQUEST['relmodule_scope']) && !empty($_REQUEST['relmodule_scope'])){
            $allocate->relatedinfoset_arr['relmodule_scope'] = $_REQUEST['relmodule_scope'];
            $allocate->relatedinfoset_arr['relmodule_selectedtabid_str'] = $_REQUEST['selectedtabid_str'];
        }
        if(isset($_REQUEST['reldata_scope']) && !empty($_REQUEST['reldata_scope'])){
            $allocate->relatedinfoset_arr['reldata_scope'] = $_REQUEST['reldata_scope'];
        }
        if(isset($_REQUEST['selectlen']) && !empty($_REQUEST['selectlen'])){
            $allocate->relatedinfoset_arr['type'] = 'seniorAverageHigndistribution';
        }else{
            $allocate->relatedinfoset_arr['type'] = 'seniorHigndistribution';
        }
    }

    $allocate->set_userid($userid)->init_count()->switch_entrance();
    
    ConvertTojsonString(1,array(),'success');
?>