<?php

global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once globalStatic::$root_directory.'appCommon/appCommon.php';

if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    // 保存信息的键值对
    $feishuStaticField = array('AppId','AppSecret','CrmUrl');
    $para_content = array();
    // 如果存在空参数则置remind为true
    $remind = false;
    // 暂存参数为空的字段数组
    $remind_arr = array();
    // 返回给前端的提示字符串
    $remind_str = '';
    foreach ($feishuStaticField as $key=>$value){
        // 提取请求参数
        if(empty($_REQUEST[$value])){
            $para_content = array();
        }else{
            $para_content[$value] = trim($_REQUEST[$value]);
        }
        // 参数为空时进行标记
        if (!isset($_REQUEST[$value])||$_REQUEST[$value]==''){
            if($value=='CrmUrl'){
                array_push($remind_arr,getFixedLabel('WECHATAPPLETSETTINGSTITLE02'));
            }else{
                array_push($remind_arr,$value);
            }
            // 如果参数不全，需要提示
            $remind = true;
        }
    }
    // 对传递的参数为空的字段进行拼接
    $remind_str = $remind_str.$remind_arr[0];
    for($i=1;$i<count($remind_arr);$i++){
        if($i == count($remind_arr)-1){
            // 最后一个使用AND进行连接
            $remind_str = $remind_str . getFixedLabel('AND').$remind_arr[$i];
        }else{
            $remind_str = $remind_str .', '.$remind_arr[$i];
        }
    }
    $remind_str = $remind_str.getFixedLabel('APPCANNOTBEEMPTY');
    $_REQUEST['diony']='diony';
    // 如果存在空参数则返回提示
    if(!$remind){
        // 保存飞书接口参数
        $query = 'select 1 from ld_wx_config where name = ?';
        $result = $adb->pquery($query,array('FeishuInterfaceSettings'));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            // 如果存在飞书接口设置参数
            $sql = "update ld_wx_config set para_content=? where name=?";
            $adb->pquery($sql,array(json_encode($para_content),'FeishuInterfaceSettings'));
        }else{
            // 如果不存在飞书接口参数设置
            $sql = "insert into ld_wx_config(name,para_content) values (?,?)";
            $adb->pquery($sql,array('FeishuInterfaceSettings',json_encode($para_content)));
        }
        // 将结果返回给前端
        ConvertTojsonString(1,array(),'success');
    }else{
        // 将结果返回给前端
        ConvertTojsonString(-1,array(),$remind_str);
    }
    exit();
}

if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='delete'){
    $sql = "update ld_wx_config set para_content=? where name=?";
    $adb->pquery($sql,array('','FeishuInterfaceSettings'));
    ConvertTojsonString(1,array(),'success');
}

$smarty = new lingdangCRM_Smarty;
$sql = "select para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('FeishuInterfaceSettings'));
if($adb->num_rows($result) > 0){
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('FeishuInterfaceSettings');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/feishu_interface_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>