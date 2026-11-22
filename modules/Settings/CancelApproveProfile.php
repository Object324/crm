<?php
/*
 * edit:duan
 * date:2024/12/18
 * reason:反审批权的编辑和保存
 * */

//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_related_scope','include/utils');
global $adb,$current_user;
$mode = $_REQUEST['mode'];
$scopetlabel = 'CancelApproveProfile';
$tabid=$_REQUEST['tabid'];
$module= getTabname($tabid);
$return_arr = [];
$scopetype_arr = [
    'all'=>0,
    'group'=>1,
    'user'=>2,
    'role'=>3,
];

if($mode == 'edit'){
    $scopetype = '';
    $scopeid_str = '';
    $all_scopeid_arr = cls_related_scope::get_related_scope_withtype($module,$scopetlabel,$tabid);
    if(is_array($all_scopeid_arr) && sizeof($all_scopeid_arr)>0){
        foreach ($all_scopeid_arr as $tmp_scopetype=> $tmp_scopeid_str){
            $scopetype = $tmp_scopetype;
            $scopeid_str = $tmp_scopeid_str;
        }
    }
    $show_scopetype = '-10';
    if(!empty($scopetype) && array_key_exists($scopetype,$scopetype_arr)){
        $show_scopetype = $scopetype_arr[$scopetype];
    }
    $return_arr['scopetype'] = $show_scopetype;
    $return_arr['scopeid'] = $scopeid_str;
    $return_arr['title'] = getTranstab($module).'-'.getFixedLabel('ANTIAPPROVALAUTHORITY');
    $return_arr['bottom_label'] = getFixedLabel('CANCELAPPROVEPROFILECOMMENT');
}else{
    $show_scopetype = $_REQUEST['scopetype'];
    if(in_array($show_scopetype,$scopetype_arr)){
        $scopetype = array_search($show_scopetype,$scopetype_arr);
    }else{
        $scopetype = '';
    }
    if(!empty($scopetype)){
        if($scopetype == 'all'){
            $scopeid_arr = [0];
        }else{
            $scopeid = $_REQUEST['scopeid'];
            $scopeid_arr = explode(',',$scopeid);
        }
        //删除所有的历史数据并重新插入数据
        cls_related_scope::save_related_scope_withtype($module,$scopetlabel,$tabid,$scopeid_arr,$scopetype);
    }else{
        cls_related_scope::delete_related_scope_withtype($module,$scopetlabel,$tabid);
    }
}

ConvertTojsonString(1,$return_arr,"success");

?>