<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $versions;
require_once(globalStatic::$root_directory."Register/RegOp.php");
global $current_user;
global $adb;

if(isset($_REQUEST['loginui']) && $_REQUEST['loginui'] == 'new'){
    setUsersettingByLabel('Settings',1,'historyloginui','new','');
}else{
    $historylogin = getUsersettingByLabel('Settings',1,'historyloginui');
    if($historylogin == 'old'){
        ConvertTojsonString(2,array(),"success");
    }
}

$smarty=new lingdangCRM_Smarty();

$query = "select content from ld_loginsettingsinfo where `name` = 'swiperratio';";
$result = $adb->pquery($query,array());
$swiperratio = $adb->query_result($result,0,'content');
$smarty->assign("SWIPERRATIO",$swiperratio);

$loginswiperarr = [];
$sql = "select * from ld_loginsettingsinfo where `name` = 'loginswiper' and isedit = 'yes' and swipertype = ? ORDER BY sequence ASC;";
$result = $adb->pquery($sql,array($swiperratio));

$num = $adb->num_rows($result);
if($num > 0){
    for($i = 0 ;$i < $num; $i++){
        $content = $adb->query_result($result,$i,'content');
        if(strpos($content,'dataCache/') === false && strpos($content,'https:') === false && strpos($content,'storage/') === false){
            $content = 'dataCache/test/swiper/'.$content;
        }
        $loginswiperarr[] = array('id'=>$adb->query_result($result,$i,'id'),'content'=>$content,'isshow'=>$adb->query_result($result,$i,'isshow'),'url'=>$adb->query_result($result,$i,'url'));
    }
}
$smarty->assign("LOGINSWIPERARR",$loginswiperarr);
$arr = [];
$arr['content']= $smarty->fetch('LoginSettings/LoginSettingsSwiper.tpl');
ConvertTojsonString(1,$arr,"success");
?>