<?php
/**
* @edit:dong
* @data:2020/07/28
* @reason:表单推广 相关信息 外部提交数据详情
* @description: 特殊
*/
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $adb,$current_user;
$current_module =$_REQUEST['module'];
$record = intval($_REQUEST['record']);
$userid = $current_user->id;
$baseModule ='SocialPromotion';
$share_record = intval($_REQUEST['share_record']);
//引入表单推广模块的类 获取当前单据的明细
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
$mobj = new cls_ListViewWX($baseModule);
$mobj->focus->id =$share_record;
$mobj->focus->retrieve_entity_info($share_record, $baseModule);
//映射模块
$mappingModule = $mobj->focus->column_fields['mappingmodule'];
//加载表单推广 外部表单类
crm_load_class_file($current_module,'modules/'.$baseModule);
$Form = new SocialPromotionForm($mobj->focus->column_fields);
$smownerid = $Form->getSmownerid($recordid);  //当前活动的所有者
$smcreatorid = $mobj->focus->column_fields['smcreatorid']; //创建者
//获取分享者
crm_load_class_file('cls_share','include/Functions/Share');
$objShare = new cls_share();
$shareUsers  = $objShare->getSelectedUser($share_record);
// 创建人 负责人和 共享人 合并去重
$shareUsers = array_filter(array_unique(array_merge(array($smcreatorid),array($smownerid),explode(',',$shareUsers['userid']))));
//判断是否拥有访问权限
if(!in_array($userid,$shareUsers)){
    ConvertTojsonString(-5, null, getFixedLabel('YOUDONOTHAVEACCESSRIGHTS'));
}
$result = $Form->getFromSingle($record);
$list =array();
$maininfo=array();
$list['blocklabel'] = getFixedLabel('FORMINFORMATION');
$list['display_status'] = '1';
if($result){
    $row = $adb->fetch_row($result);
    foreach ($Form->customFields as $field){
        $tmpArr =array();
        $tmpArr['fieldlabel'] = $field['fieldlabel'];
        $tmpArr['fieldname'] = $field['columnname'];
        $tmpArr['isadmin'] = '1';
        $tmpArr['phone'] = 'no';
        $tmpArr['text'] =$row[$field['columnname']];
        $tmpArr['type'] =1;
        $tmpArr['typeofdata'] =$field['typeofdata'];
        $tmpArr['value_name'] = $row[$field['columnname']];
        $list['fieldinfo'][] =$tmpArr;
    }

    $maininfo[] =array(
        'fieldlabel'=> '所属用户：',
        'fieldname'=>'userid',
        'phone'=> 'no',
        'value'=>getUserFullName($row['userid'])
    );

}


$retunArr['list'][] = $list;

$retunArr['maininfo']['title'] = getTranstab('Accounts').':'.$row['accountname'];
$retunArr['maininfo']['list'] = $maininfo;
$retunArr['advancestage'] = array('data_error'=>'no','is_enable'=>'no');
$retunArr['module_title']= getTranstab($baseModule).'-'.getFixedLabel('FIELDSMAPPING').getTranstab($mappingModule).'-'.getFixedLabel('details1');
$retunArr['page_title']=getTranstab($baseModule).'-'.getFixedLabel('FIELDSMAPPING').getTranstab($mappingModule).'-'.getFixedLabel('details1');

$retunArr['list2'] = array();
ConvertTojsonString(1, $retunArr, 'success');
?>

