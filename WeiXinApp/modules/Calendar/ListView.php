<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$MobileLanguageType;//Calendar
//editor:gyq_109 reason:日程管理模块  2019/4/29 16:51
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
$details = $mobj->get_listdetail(null);
$relatemodule = $_REQUEST['related_module'];
//产品相关信息暂时隐藏新增按钮  gyqTE
if (isPermitted($currentModule, 'Create', '') == 'yes'&&$relatemodule!='Products') {
    if(strpos($mobj->relatedModuleActions,'add')!==false || empty($mobj->relatedModuleActions)){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'camcard'=>'',
    'create_html'=>$list_buttons);
    
//duan 移动端增加字符串翻译返回
if($_REQUEST['tab_page'] == 'me'){
    $label_arr=array(
        'VIEW',//查看
        'COMMENT1',//评论
        'DELAYED',//延时
        'EDIT',//编辑
        'YOUDONOTHAVETHECONTRACTPORDER',//您没有编辑权限
        'DELETE',//删除
        'NOSCHEDULE',//没有安排日程
        'TOADD',//去添加
        'MYSCHEDULE',//我的日程
        'OTHERSCHEDULE',//他人日程
        'nYear',//年
        'nMonth',//月
        'ShortMonday',//一
        'ShortTuesday',//二
        'ShortWednesday',//三
        'ShortThursday',//四
        'ShortFriday',//五
        'ShortSaturday',//六
        'ShortSunday',//日
        'SuccessDeleted',//删除成功！
        'SUREWANTDELETE',//确定要删除吗？
    );
    $fixedlabel_arr = TransFieldlabel($label_arr);
    $details['arrFixedLabel']=TransFieldlabel($label_arr);
    
    //文本控件的翻译
    $label_arr = array('CANCEL','PLEASEFILLINTHECONTENT','SUBMIT','FILLINCOMMENTS','COMMENT1','NOTFILLEDINTHECONTENT',
        'ENTERAPOSITIVEINTEGER','FAILLEDTOCOLSE','RELEASENEW','Reply','COMMENTAPP');
    $details['arrFixedLabel_remark']=TransFieldlabel($label_arr,'no');
    if(isset($details['arrFixedLabel_content'])){
        unset($details['arrFixedLabel_content']);
    }
}
ConvertTojsonString(1, $details, 'success');
?>
