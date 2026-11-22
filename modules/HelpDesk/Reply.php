<?php

global $app_strings, $mod_strings, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;
$smarty = new lingdangCRM_Smarty();
$time = date('Y-m-d H:i:s');
$module = getEntitySetype($_REQUEST['record']);
$record = $_REQUEST['record'];

//点击评论后方的回复按钮时触发，给js返回【回复】弹出层的属性
if($_REQUEST['mode']=='reply_ready'){
    $id = $_REQUEST['reply_id'];
    $query = 'select content from ld_wx_communicate where record=? and module=? and id=? order by create_time desc';
    $result = $adb->pquery($query,array($record,$module,$id));
    $reply_content = $adb->query_result($result,0,'content');
    $arr['reply_content'] = $reply_content;
    
    
    
    //绘制【回复】弹出层的基本组成部分——标题，文本框，确认按钮，取消按钮
    $html = '<div style="padding:10px;">';
    $html .= '<textarea id="textarea"  name="textarea" value="" style="resize:none;padding: 8px;margin-top: 6px;"></textarea>';
    $html .= '</div>';
    $arr['content_html'] = $html;
    $arr['title'] = getFixedLabel('Reply');
    $arr['oktext'] = getFixedLabel('Reply');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    $_REQUEST['diony'] = 'yes'; 
    //给js返回【回复】弹出层
    
    ConvertTojsonString(1,$arr,'success');
}

//点击【回复】弹出层的【回复】按钮时触发，将新的留言记录插入到数据库中
if($_REQUEST['mode']=='reply_finish'){
    $reply_content=$_REQUEST['reply_content'];
    $role_type=$_REQUEST['role_type'];
    $pid=$_REQUEST['pid'];
    $arr['r_module'] =$module;
    $arr['r_record'] =$record;
    $arr['r_urlstring'] ='&start=1';
    $query = "INSERT INTO ld_wx_communicate (module,record,create_time,content,pid,openid,role_type,crmuserid) VALUES (?,?,?,?,?,?,?,?)"; 
    $result = $adb->pquery($query,array($module,$record,$time,$reply_content,$pid,'',$role_type,$current_user->id));
    ConvertTojsonString(1,$arr,'success');
}

ConvertTojsonString(1,$arr,'success');
?>