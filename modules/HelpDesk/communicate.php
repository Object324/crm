<?php
//editor:gyq_123 reason:服务小程序增加沟通信息  2019/6/18 14:28 ID1000512
global $app_strings, $mod_strings, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;
$record = $_REQUEST['record'];
$module = $_REQUEST['frommodule'];
$smarty = new lingdangCRM_Smarty();
$all_cvid = getCvIdOfAll($module);


//需要传给js的是评论表中的所有评论记录，id,create_time,content,pid
$query = 'select id,create_time,content,openid,pid,role_type,record from ld_wx_communicate where record=? and module=? order by create_time desc';
$result = $adb->pquery($query,array($record,$module));



$noofrows = $adb->num_rows($result);//获取总条目数
$list_max_entries_per_page_new = 5;//每页显示5个
$start = 1;

//设置页面展示的格式
if(!empty($_REQUEST['start'])){//把获取url传回来的页面数
    $start = $_REQUEST['start'];
    
}
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$limit_sql = " limit $limit_start_rec,$list_max_entries_per_page_new";
$query .= $limit_sql;
$list_result = $adb->pquery($query,array($record,$module));

$num_rows = $adb->num_rows($list_result);

for($i = 0; $i<$num_rows; $i++){
    if($start<=1){
        $listviewentity[$i]['list_row'] =$i+1;
    }else{
        $listviewentity[$i]['list_row'] =$i+1+($start-1)*5;
    }
    
    $listviewentity[$i]['id'] = $adb->query_result($list_result,$i,'id');
    $listviewentity[$i]['create_time'] = $adb->query_result($list_result,$i,'create_time');
    $listviewentity[$i]['record'] = $adb->query_result($list_result,$i,'record');
    $listviewentity[$i]['content'] = $adb->query_result($list_result,$i,'content');
    $listviewentity[$i]['openid'] = $adb->query_result($list_result,$i,'openid');
    $listviewentity[$i]['pid'] = $adb->query_result($list_result,$i,'pid');
    $listviewentity[$i]['role_type'] = $adb->query_result($list_result,$i,'role_type');
    $pid=$listviewentity[$i]['pid'];
    $listviewentity[$i]['reply_content']='';
    if(!empty($pid))
    {
        $query_reply_content = 'select content from ld_wx_communicate where record=? and module=? and id=?';
   
        $reply_content_result= $adb->pquery($query_reply_content,array($record,$module,$listviewentity[$i]['pid']));
       if($adb->num_rows($reply_content_result)>0)
            $listviewentity[$i]['reply_content'] = $adb->query_result($reply_content_result,0,'content');
    }
    
    
}





crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,5,$noofrows);//获取分页具体参数数组
//获取分页
crm_load_function_file('getTableHeaderSimpleNavigation2','include/utils','ListViewUtils');
$navigation_array['record'] = $record;
$navigation_array['module'] = $module;
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, 'get_communicate_detail', $module, 'index', $all_cvid);
crm_load_function_file('getRecordRangeMessage','include/utils','ListViewUtils');
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
//显示列表


//设置页面展示的内容
if(!empty($listviewentity)){
    //设置列头的标题显示
    $titile1 = getFixedLabel('DATE');
    $titile2 = getFixedLabel('Content');
  
    //遍历每一条评论记录    
    foreach($listviewentity as $key=>$listview){
        $table .='<tr bgcolor="white">';
        $id = $listview['id'];
        $openid = $listview['openid'];
        $pid = $listview['pid'];
        $role_type=$listview['role_type'];
        $record=$listview['record'];
        $reply_content=$listview['reply_content'];
        //dump($reply_content);
        //遍历每一条评论记录中的字段（显示编号，记录id，创建时间，内容，pid等）
        foreach($listview as $key2=>$val){
            //当且仅当字段=content时，表示该条留言来自移动端用户，留言内容后方应增加【回复】按钮
            if($key2=='content'&&$role_type=="serviceaccount"){
                $table .='<td title="'.$val.'" record="'.$record.'"  id="'.$id.'"  openid="'.$openid.'" pid="'.$pid.'"  module="'.$module.'"  reply_content="'.$reply_content.'"  >' . $val.'<a href="javascript:;" title="'.$val.'"  id="'.$id.'" pid="'.$pid.
                '"  module="'.$module.'" onclick="reply_message(this)" style="margin-left: 300px;">回复</a>';
                $table .='</td>';
            }else if($key2=='content'&&$role_type=="crmuser"){
                $table .='<td title="'.$val.'" record="'.$record.'"  id="'.$id.'" openid="'.$openid.'"  pid="'.$pid.'"  module="'.$module.'"  reply_content="'.$reply_content.'" >' . $val.' 【回复】：'.$reply_content;
                $table .='</td>';
            }else if($key2=='create_time'  ){
                $table .='<td title="'.$val.'">' . $val .'</td>';
            }else if($key2=='list_row'  ){
                $table .='<td title="'.$val.'">' . $val .'</td>';
            }
        }
        $table .='</tr>';
    }
}else{
    //共三列
    $colspan = 3;
    $table .='<tr align="left"><td style="padding-left: 5px;background-color:#fff;font-size: 13px;"colspan="'.$colspan.'">' . getFixedLabel('NOTFOUNDANYRECORD') . '</td></tr>';
}

$arr[]=Array();
$_REQUEST['diony']='yes';
$arr['tablecontent']=$table;
$arr['start']=$start;

    

$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign('COUNT',count($listviewentity));
$smarty->assign('START',$start);
$arr['content']=$smarty->fetch('modules/lingdang/communicate.tpl');
ConvertTojsonString(1,$arr,'success');

?>