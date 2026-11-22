<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $MobileLanguageType;
global $currentModule;

$orgin_page = $_REQUEST['page'];

crm_load_class_file('cls_ListViewSpecialWX','WeiXinApp/list');;
$mobj = new cls_ListViewSpecialWX("");
$data= $mobj->get_listdetail();
if(!isset($_REQUEST['related_id'])){
    //避免因为重复调用导致页码错误
    $_REQUEST['page'] = $orgin_page;
    $mobj_common = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
    $details = $mobj_common->get_listdetail(null);
    $trans_key_arr = array('pagecount','totalrows','havenextpage','haveprevpage','curpagenum');
    foreach($trans_key_arr as $tmp_key){
        $data[$tmp_key] = $details[$tmp_key];
    }
}

if (isPermitted($currentModule, 'Create', '') == 'yes') {
    if(empty($mobj_common->relatedModuleActions) || strpos($mobj_common->relatedModuleActions,'add')!==false){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}

$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
   // 'moduletitle' => getTranstab('CustomForm66'),
    'camcard'=>$camcard,
    'create_html'=>$list_buttons);

//签退模块是否开启
if(vtlib_isModuleActive('Signout') && isPermitted('Signout','DetailView','') == 'yes'){
    $NavbarLabel = array('all'=>'ALL','notsignedout'=>'NotSignedOut','havesignedout'=>'SignedOut');
    foreach ($NavbarLabel as $value => $label) {
        $selected = 'no';
        if (!empty($_REQUEST['listview_type']) && $value == $_REQUEST['listview_type']) {
            $selected = 'yes';
        }else if(empty($_REQUEST['listview_type']) && $value == 'all'){//默认“全部”页签
            $selected = 'yes';
        }
        $NavbarItem = [
            'label' => getFixedLabel($label),
            'value' => $value,
            'selected' => $selected,
        ];
        $data['sign_Navbar'][] = $NavbarItem;
    }
}

//duan 20221013 移动端获取字符串翻译
$label_arr=array(
    'DELETE',//删除
    'TOTALOF',//共
    'NOSIGNINHISTORY',//没有签到历史
    'NOMORESIGNINHISTORY',//没有更多签到历史
    'RECORDNUMS',//条记录
    'SUREWANTDELETE',//确定要删除吗？
    'SuccessDeleted',//删除成功！
    'zhang',//张
    'RECORDSINTOTAL',//共%d条记录
    'SIGNOUT2',//签退
    'SUPSIGN',//补签
    'NotSignedOut',//未签退
    'SignedOut',//已签退
    'SIGNIN',//签到
    'SIGNINANDOUTTIP',
);
$fixedlabel_arr = TransFieldlabel($label_arr);
$fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);//共%d条记录
$details['arrFixedLabel'] = $fixedlabel_arr;
$data['arrFixedLabel'] = $fixedlabel_arr;
$data['list_sign'] = $details['list1'];

ConvertTojsonString(1,$data,'success');
//ConvertTojsonString(1,$details,'success');
?>