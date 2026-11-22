<?php
/**
* @edit:dong
* @data:2020/07/28
* @reason:表单推广 相关信息 外部提交数据列表
* @description:特殊控制
*/
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$mobile_pagerecordcount,$adb;
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];
$recordid = intval($_REQUEST['recordid']);
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
$mobj = new cls_ListViewWX($relatemodule);
$mobj->focus->id =$recordid;
$mobj->focus->retrieve_entity_info($recordid, $relatemodule);
//映射模块
$mappingModule = $mobj->focus->column_fields['mappingmodule'];
//加载表单推广 外部表单类
crm_load_class_file('SocialPromotionForm','modules/SocialPromotion');
$Form = new SocialPromotionForm($mobj->focus->column_fields);
$smownerid = $Form->getSmownerid($recordid);  //当前活动的所有者
if($current_user->id == $mobj->focus->column_fields['smcreatorid'] || $current_user->id == $smownerid){
    $Form->getFormList('',$recordid);
}else{
    $Form->getFormList($current_user->id,$recordid);
}
$noofrows = $Form->formCountNum; //当前用户能看到的总条目
if($mobile_pagerecordcount >  $noofrows && $noofrows > 0){
    $mobile_pagerecordcount = $noofrows;
}
$totalpagecount = ceil($noofrows / $mobile_pagerecordcount); //当前用户的素有数据的总页数
if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
    $totalpagecount += 1;
}
if (!isset($_REQUEST['page'])) {
    $_REQUEST['page'] = 1;
} else {
    $_REQUEST['page']++;
}
$haveprevpage = 'yes';
$havenextpage = 'yes';
$startpagenum = $_REQUEST['page'] - 1;
if ($_REQUEST['page'] >= $totalpagecount)//是否有下一页
{
    $havenextpage = 'no';
    $startpagenum = $totalpagecount - 1;
}
if ($_REQUEST['page'] <= 1)//是否有上一页
{
    $haveprevpage = 'no';
    $startpagenum = 0;
}
$_REQUEST['start'] = $startpagenum + 1;
$startpagerecord = $startpagenum * $mobile_pagerecordcount; // limit开始的条目

//获取当前用户的外部表单数据
if($current_user->id == $mobj->focus->column_fields['smcreatorid'] || $current_user->id == $smownerid){
    $listresult =$Form->getFormList('',$recordid,$startpagerecord,$mobile_pagerecordcount);
}else{
    $listresult =$Form->getFormList($current_user->id,$recordid,$startpagerecord,$mobile_pagerecordcount);
}

$num_rows = $adb->num_rows($listresult);
$list1 =array();
if($num_rows>0){
    for ($i=0;$i<$num_rows;$i++){
        $tmpArr=array(); //初始化 变量
        $tmpArr['curid'] = $adb->query_result($listresult,$i,'id');  //外部单据id
        $tmpArr['hiddenqty'] = 0;
        $tmpArr['isphone'] = "no";
        $tmpArr['phone'] = '';
        $tmpArr['phonetext'] = '';
        $tmpArr['field'][] = gettranslabelfields($relatemodule,'createdtime').$adb->query_result($listresult,$i,'createdtime'); //单据提交时间
        $tmpArr['field'][] = '创建状态：'.$adb->query_result($listresult,$i,'statusmsg'); //单据状态
        $tmpArr['hiddentitle'] = $adb->query_result($listresult,$i,'accountname'); //客户名称
        $tmpArr['title'] = getTranstab('Accounts').':'.$adb->query_result($listresult,$i,'accountname');

        $list1[]=$tmpArr;
    }
}

$result['list1'] =  $list1;
$result['totalrows'] = $noofrows;
$result['pagecount'] = $totalpagecount;

$result['page_title'] =getTranstab('SocialPromotion').'-映射'.getTranstab($mappingModule);
$result['modulename'] ='映射'.getTranstab($mappingModule);
$result['haveprevpage'] =$haveprevpage;
$result['havenextpage'] =$havenextpage;
$result['firstview'] = 'no';
$result['curpagenum']= $_REQUEST['page'];


ConvertTojsonString(1, $result, 'success');
