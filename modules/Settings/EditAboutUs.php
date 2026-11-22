<?php
/**
 * zxm
 * 2020-0922
 * 灵当云 名片小程序 关于我们的编辑 与查看
 */
global $mod_strings;
global $app_strings;
global $app_list_strings;

$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
//主表信息 查询【公司简介标题brief_title】【主图链接image_main】【视频链接video_link】【视频封面video_cover】
$sql="select * from ld_organizationdetails";
$result = $adb->pquery($sql, array());

$organization_id = $adb->query_result($result,0,'organization_id');
$brief_title = $adb->query_result($result,0,'brief_title');
$image_main = $adb->query_result($result,0,'image_main');
$video_cover = $adb->query_result($result,0,'video_cover');
$video_link = $adb->query_result($result,0,'video_link');
$smarty->assign("organization_id",$organization_id);
$smarty->assign("brief_title",$brief_title);
$smarty->assign("image_main",$image_main);
$smarty->assign("video_cover",$video_cover);
$smarty->assign("video_link",$video_link);
// 从表信息 多条简介 多图链接
$brief_sql = "select * from ld_organizationdetails_brief where organizationdetails_id=".$organization_id;
$brief_result = $adb->pquery($brief_sql, array());
$num_rows = $adb->num_rows($brief_result);
$brief_res = [];
$brief_image = [];
if($num_rows > 0){
    for($i = 0; $i<$num_rows; $i++){
        $temp_type = $adb->query_result($result,$i,'type');
        $temp_brief = $adb->query_result($result,$i,'brief');
        $temp_image_link = $adb->query_result($result,$i,'image_link');
        $temp = [];
        if($temp_type == "text"){
            $temp['brief'] = $temp_brief;
            $brief_res[] = $temp;
        }
        if($temp_type == "image"){
            $temp['image_link'] = $temp_image_link;
            $brief_image[] = $temp;
        }
    }
}

$smarty->assign("brief_res", $brief_res);
$smarty->assign('brief_count',count($brief_res));
$smarty->assign("brief_image", $brief_image);

$smarty->assign("THEME", $theme);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('Setup').getFixedLabel('ABOUTUS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str = $smarty->fetch("Settings/EditAboutUs.tpl");
$arr['content'] = $str;
ConvertTojsonString(1,$arr,"success");

