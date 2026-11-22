<?php
global $adb;
/***
 * zxm
 * 2020-0923
 * 公司简介添加和编辑
 */
// 保存产品介绍标题 用一个参数判断是保存产品介绍标题还是保存公司介绍信息
if($_REQUEST['is_brief'] == 'no'){
    $organization_id = from_html($_REQUEST['organization_id']);
    $product_title = from_html($_REQUEST['product_title']);
    $update_sql = "update ld_organizationdetails set product_title='".$product_title."' where organization_id=".$organization_id;

    $update_res = $adb->pquery($update_sql,[]);
    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,['a'=>$update_sql],"success");
    exit ;
}

// 入主表ld_organitiondetails的信息
$brief_title = from_html($_REQUEST['brief_title']);
$image_main = from_html($_REQUEST['image_main']);
$video_cover = from_html($_REQUEST['video_cover']);
$video_link = from_html($_REQUEST['video_link']);
$organization_id = from_html($_REQUEST['organization_id']);

// 修改主表信息
$update_value = [
     'brief_title="'.$brief_title.'"',
     'image_main="'.$image_main.'"',
     'video_cover="'.$video_cover.'"',
     'video_link="'.$video_link.'"'
];
$update_value = implode(',',$update_value);
$update_sql = "update ld_organizationdetails set $update_value where organization_id=".$organization_id;
$update_res = $adb->pquery($update_sql,[]);

//修改从表信息
// 先做删除
$adb->pquery("delete from ld_organizationdetails_brief where organizationdetails_id=".$organization_id,[]);
$brief = from_html($_REQUEST['brief']);
$image_link = from_html($_REQUEST['image_link']);
$insert_field = "(organizationdetails_id,brief,image_link,type)";
$insert_values = [];
if(count($brief) > 0) {
    foreach ($brief as $b) {
        $temp = [
            $organization_id,
            "'" . $b . "'",
            "''",
            "'" . 'text' . "'"
        ];
        $temp = "(" . implode(',', $temp) . ")";
        $insert_values[] = $temp;
    }
}
if(count($image_link) > 0) {
    foreach ($image_link as $i) {
        $temp = [
            $organization_id,
            "''",
            "'" . $i . "'",
            "'" . 'image' . "'"
        ];
        $temp = "(" . implode(',', $temp) . ")";
        $insert_values[] = $temp;
    }
}
if(!empty($insert_values)) {
    $insert_values = implode(',', $insert_values);
    $insert_sql = "insert ld_organizationdetails_brief $insert_field values $insert_values";
    $update_res = $adb->pquery($insert_sql, []);
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,null,"success");