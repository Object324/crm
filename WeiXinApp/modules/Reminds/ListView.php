<?php
// include globalStatic::$root_directory.'WeiXinApp/list/ListViewWX.php';

//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$current_user,$adb;

$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
$details = $mobj->get_listdetail(null,null);
if($details['pagecount'] > 0){
    foreach($details['list1'] as $i => &$content){
        $module = $_REQUEST['module'];
        $content['module'] = $module;
        //wym 240513 XUQIU1002193 销售线索、客户，即将回收和回收消息提醒内容单据查看详情界面，客户名称增加显示超链接，移动端不显示该超链接
        foreach($content['newfield'][3] as $i => $item){
            $content['newfield'][3][$i]['value']=strip_tags($item['value'],'<br>');
        }
    }
}
// 消息中心——未读消息条数
require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');
$remindscount = static_Reminds::getRemindsCount();
if($remindscount == 0)
    $remindscount = -1;
$details['remindscount'] = $remindscount;
ConvertTojsonString(1, $details, 'success');
?>
