<?php
//生成表单码，带参数的小程序码
global $adb,$current_user;
global $current_user;
require_once(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once(globalStatic::$root_directory.'WeiXinApp/minipro/EventMiniModel.php');
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
$recordid = $_REQUEST['recordid'];
$fieldid = $_REQUEST['fieldid'];
$uitype = $_REQUEST['uitype'];
$modulename = $_REQUEST['module'];
$datetime_now = date('Y-m-d H:i:s');

$sql = "select qrcodetemplateid,template_content from ld_qrcode_template where fieldid = ?";
$result = $adb->pquery($sql,array($fieldid));
if($adb->num_rows($result)>0){
    $qrcodetemplateid = $adb->query_result($result,0,'qrcodetemplateid');
    $template_content_json = $adb->query_result($result,0,'template_content');
    $template_content = ldcrm_json_decode(html_entity_decode($template_content_json));
    $duration = $template_content['duration'];
    $endatetime = $template_content['endatetime'];
    $limit = $template_content['limit'];
}else{
    ConvertTojsonString(-1,array(),getFixedLabel('FORMCODEISEMPTY'));
}

$sql = "select qrcodebasicid,modifiedtime,token from ld_qrcode_creation where qrcodetemplateid=? and modulename=? and record=?";
$result = $adb->pquery($sql,array($qrcodetemplateid,$modulename,$recordid));
if($adb->num_rows($result)>0){
    $qrcodebasicid = $adb->query_result($result,0,'qrcodebasicid');
    $modifiedtime = $adb->query_result($result,0,'modifiedtime');
    $token = $adb->query_result($result,0,'token');
    if($_REQUEST['reset']=='yes'){
        $str = 'formcode'.$qrcodebasicid;
        $token = md5($str);
        $sql = "update ld_qrcode_creation set modifiedtime=?,modifiedby=?,token=? where qrcodebasicid=?";
        $adb->pquery($sql,array($datetime_now,$current_user->id,$token,$qrcodebasicid));
        $modifiedtime = $datetime_now;
    }
}else{
    $modifiedtime = $datetime_now;
    $sql = "insert into ld_qrcode_creation(qrcodetemplateid,modulename,record,modifiedtime,modifiedby) values(?,?,?,?,?)";
    $adb->pquery($sql,array($qrcodetemplateid,$modulename,$recordid,$modifiedtime,$current_user->id));
    $qrcodebasicid = $adb->getLastInsertID();
    
    $str = 'formcode'.$qrcodebasicid;
    $token = md5($str);
    $sql = "update ld_qrcode_creation set token=? where qrcodebasicid=?";
    $adb->pquery($sql,array($token,$qrcodebasicid));
    $modifiedtime = $datetime_now;
}

$filename = 'Formcode'.$fieldid.$recordid.'.jpg';
$imgsrc = 'storage/weixinqrcode/'.$filename;
if(!file_exists($imgsrc)||$_REQUEST['reset']=='yes'){
    $model = new EventMiniModel();
    $sql = "select switch,para_one,para_two,para_three,usertype from ld_wx_config where name=?";
    $result = $adb->pquery($sql,array('wechat_miniprogram_setting'));
    if($adb->num_rows($result)){
        $switch = $adb->query_result($result,0,'switch');
        $content_one = $adb->query_result($result,0,'para_one');
        $content_two = $adb->query_result($result,0,'para_two');
        $coid = $adb->query_result($result,0,'para_three');
        $const_type = $adb->query_result($result,0,'usertype');
        $img_url = '';
        if(!empty($coid)){
            if(empty($const_type))
                $const_type = 'formal';
            $root_dir =dirname (dirname(dirname(__FILE__)));
            $para_content = $model->get_appid_secret($const_type);
            $appid = $para_content['appid'];
            $secret = $para_content['secret'];
            
            if($coid > 0){
                $token_url = 'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid='.$appid.'&secret='.$secret;
                $content_result = CurlGet($token_url);
                $token_result = json_decode($content_result['content'],true);
                
                if(!empty($token_result['access_token'])){
                    $access_token = $token_result['access_token'];
                    //参考文档 https://developers.weixin.qq.com/minigame/dev/api-backend/getWXACodeUnlimit.html?search-key=getwxacodeunlimit
                    $qrcode_url = 'https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token='.$access_token;
                    $param['scene'] = 'coid='.$coid.'&qrcodeid='.$qrcodebasicid;
                    $param['page'] = 'pages/expand/expand';
                    $qrcode_result = CurlPost($qrcode_url,$param);
                    
                    if(!file_exists($uploadDir)){
                        mkdir($uploadDir,0777);
                    }
                    
                    $uploadDir = $root_dir.'/storage/weixinqrcode/';
                    if(file_exists($uploadDir.$filename)){
                        unlink($uploadDir.$filename);
                    }
                    file_put_contents($uploadDir.$filename,$qrcode_result['content']);
                    
                }
            }
        }else{
            if(isset($_REQUEST['print_qrcode'])&&$_REQUEST['print_qrcode']=='yes'){
                //打印模板调用
            }else{
                ConvertTojsonString(-1,array(),getFixedLabel('PRESETENTERPRISENUM'));
            }   
        }
    }
}


//获取字段名作为标题
$fieldobj =Field::getInstance($modulename, $adb);
$fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldid',$fieldid);
$fieldlabel = getFixedLabel('SOCIALPROMOTIONQRCODE');
if(!empty($fieldinfo)){
    $fieldlabel = $fieldinfo->getfieldLabel();
}

if(isset($_REQUEST['print_qrcode'])&&$_REQUEST['print_qrcode']=='yes'){
    //打印模板调用
}else{
    if($duration=='endate'){
        $endatetime = $endatetime;
        $timestr = getFixedLabel('VALIDUNTIL').':'.$endatetime;
    }else if($duration=='permanently'){
        $timestr = getFixedLabel('PERMANENTLYVALID');
    }else{
        $endatetime = strtotime($modifiedtime)+$duration*3600*24;
        $endatetime = date('Y-m-d H:i:s',$endatetime);
        $timestr = getFixedLabel('VALIDUNTIL').':'.$endatetime;
    }
    $refresh_str =getFixedLabel('REFRESH');
    $imgsrc .= '?a='.rand(1,1000);
    $_REQUEST['diony']='yes';
    $arr['duration'] = $duration;
    $arr['path'] = $imgsrc;
    $arr['timestr'] = $timestr;
    $arr['refreshstr'] = $refresh_str;
    $arr['templateid'] = $qrcodetemplateid;
    $arr['is_admin'] = is_admin($current_user)?1:0;
    $arr['title'] = $fieldlabel;
    
    ConvertTojsonString(1,$arr,"success");
}

?>