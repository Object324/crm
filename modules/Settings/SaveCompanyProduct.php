<?php
global $adb;
/***
 * zxm
 * 2020-0923
 * 公司产品简介的保存
 */
$_REQUEST['diony']='diony';
$id = from_html($_REQUEST['id']);
$title = from_html($_REQUEST['title']);
$brief = from_html($_REQUEST['brief']);
$order = from_html($_REQUEST['order']);
$brief = implode('|',$brief);
$image_link= from_html($_REQUEST['image_link']);
$organization_id = from_html($_REQUEST['organization_id']);
$sort_string = $_REQUEST['sort_string'];
if (!empty($sort_string)){
    $order_arr = explode(',', $sort_string);
    $sql = "UPDATE ld_organizationdetails_product SET `order` = CASE ";
    foreach ($order_arr as $index => $id) {
        $order = $index + 1;
        $sql .= "WHEN id = $id THEN $order ";
    }
    $ids = implode(',', $order_arr);
    $sql .= "ELSE `order` END WHERE id IN ($ids);";
    $result = $adb->pquery($sql,array());
    ConvertTojsonString(1,null,"success");
}
if($id > 0){
    //编辑
    $update_value = [
        'organizationdetails_id="'.$organization_id.'"',
        'title="'.$title.'"',
        'brief="'.$brief.'"',
        '`order`="'.$order.'"',
        'image_link="'.$image_link.'"',
    ];
    $update_value = implode(',',$update_value);
    $update_sql = "update ld_organizationdetails_product set $update_value where id=".$id;
    $insert_res = $adb->pquery($update_sql,[]);
}else{
    //新增
    $insert_value = [
        "'".$organization_id."'",
        "'".$title."'",
        "'".$brief."'",
        "'".$image_link."'",
        "'".$order."'"
    ];
    $insert_value = implode(',',$insert_value);
    $insert_sql = "insert into ld_organizationdetails_product (organizationdetails_id,title,brief,image_link,`order`) values ($insert_value)";
    $insert_res = $adb->pquery($insert_sql,[]);
}


ConvertTojsonString(1,null,"success");