<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $adb;

$smarty=new lingdangCRM_Smarty();

$content = '';
$url = '';
$isshow = 'yes';
$swiperid = $_REQUEST['swiperid'];
if($swiperid > 0){
    $sql = 'select content,url,isshow from ld_loginsettingsinfo where id = ?;';
    $result = $adb->pquery($sql,array($_REQUEST['swiperid']));
    if($adb->num_rows($result) > 0){
        $content = $adb->query_result($result,0,'content');
        if(strpos($content,'dataCache/') === false && strpos($content,'https:') === false && strpos($content,'storage/') === false){
            $content = 'dataCache/test/swiper/'.$content;
        }
        $url = $adb->query_result($result,0,'url');
        $isshow = $adb->query_result($result,0,'isshow');
    }
}else{

}
$smarty->assign("swiperid",$swiperid);
$smarty->assign("CONTENT",$content);
$smarty->assign("URL",$url);
$smarty->assign("ISSHOW",$isshow);

$query = "select content from ld_loginsettingsinfo where `name` = 'swiperratio';";
$result = $adb->pquery($query,array());
$swiperratio = $adb->query_result($result,0,'content');
$smarty->assign("SWIPERRATIO",$swiperratio);

$arr = [];

$arr['title'] = getFixedLabel('Carousel');
$arr['oktext'] = getFixedLabel("SAVE");
$arr['canceltext'] = getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('LoginSettings/LoginSettingsSwiperEdit.tpl');
ConvertTojsonString(1,$arr,"success");
?>