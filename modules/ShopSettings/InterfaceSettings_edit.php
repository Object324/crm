<?php
$_REQUEST['diony']='diony';
global $adb,$current_user,$root_directory;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');

$sql = "select * from ld_shop_settings where `name`= ?";
$result = $adb->pquery($sql,array('InterfaceSettings'));
$para_content_list = array();
if($adb->num_rows($result) > 0){
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'input_content'));
    if(!is_array($para_content_list))
        $para_content_list=[];
}
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $InterfaceStaticField = array('appid','appsecret','appname','custelno','sharedescription','displayinvoice');
    $para_content = array();
    foreach ($InterfaceStaticField as $key=>$value){
        //任意一个参数没有配置，不保存
        if(!isset($_REQUEST[$value])){
            $para_content = array();
            break;
        }else{
            if($value=='displayinvoice'){
                if($_REQUEST[$value]=='true')
                    $_REQUEST[$value]='yes';
                else
                    $_REQUEST[$value]='no';
            }
            $para_content[$value] = trim($_REQUEST[$value]);
        }
    }
    if (is_array($_FILES['sharepicture'])) {
        $image_path = 'storage/ShopSettings/';
        $uploadDir = $root_directory.$image_path;
		if(!file_exists($uploadDir)){
			mkdir($uploadDir,0777);
		}
        if ($_FILES['sharepicture']['error'] != UPLOAD_ERR_OK) {
            ConvertTojsonString(-1,array(),getFixedLabel('FILEUPLOADPROBLEMS'));//上传的文件有问题
        } 
        else 
        {
            $original_name = $_FILES['sharepicture']["name"];
            $file_name = FileFileterString($original_name);//文件特殊字符串过滤，安全性检测
            
            $fileParts = pathinfo($file_name);
            $date = date('ymdHis',time());
            $new_file_name = 'ShopSettings_sharepicture_'.$date.'.'.$fileParts['extension'];
            $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
    		$encode=mb_detect_encoding($new_file_name, $arr); 
    		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
    		{
    		//获取系统类型，如果是非windows系统则不用修改编码格式
    
    		}
    		else if($encode=='UTF-8')
    		{
    			$new_file_name=iconv('UTF-8','gb2312',$new_file_name);
    		}
            if(!move_uploaded_file($_FILES['sharepicture']["tmp_name"],$uploadDir.$new_file_name)){ //移动操作可以重新命名及修改后缀
                ConvertTojsonString(-1,array(),$original_name.getFixedLabel('FILEUPLOADPROBLEMS'));//上传失败，请重试！
            }
            if(isset($para_content_list['sharepicture'])&&$para_content_list['sharepicture']!='' &&$new_file_name!=$para_content_list['sharepicture']){
                @unlink($uploadDir.$para_content_list['sharepicture']);
            }
            $para_content['sharepicture'] = $new_file_name;
        }
    }
    else{
        $para_content['sharepicture'] = $para_content_list['sharepicture'];
    }
    if(isset($_REQUEST['havesharepicture'])&&$_REQUEST['havesharepicture']=='no'){
        if(isset($para_content_list['sharepicture'])&&$para_content_list['sharepicture']!=''){
            @unlink($root_directory.'storage/ShopSettings/'.$para_content_list['sharepicture']);
        }
        $para_content['sharepicture'] = '';
    }
    if(!empty($para_content)){
        $sql = "update ld_shop_settings set input_content=? where `name`=?";
        $adb->pquery($sql,array(json_encode($para_content),'InterfaceSettings'));
        $query = "select 1 from ld_field where fieldname = 'productstatus' and tablename = 'ld_shop_productproperty' and presence = 1";
        $result = $adb->pquery($query,array());
        if($adb->num_rows($result)>0){
            $sql = "update ld_field set presence=2 where fieldname = 'productstatus' and tablename = 'ld_shop_productproperty' and uitype = 15";
            $adb->pquery($sql,array());
        }
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),'小程序设置'.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='update'){
    //目前仅针对 是否显示发票 的更新
    $InterfaceStaticField = array('appid','appsecret','appname','custelno','sharedescription','displayinvoice');
    foreach ($InterfaceStaticField as $value){
        //传了哪些参数，更新哪些参数
        if(isset($_REQUEST[$value])){
            if($value=='displayinvoice'){
                if($_REQUEST[$value]=='true')
                    $_REQUEST[$value]='yes';
                else
                    $_REQUEST[$value]='no';
            }
            $para_content_list[$value] = trim($_REQUEST[$value]);
        }
    }
    if(!empty($para_content_list)){
        $sql = "update ld_shop_settings set input_content=? where `name`=?";
        $adb->pquery($sql,array(json_encode($para_content_list),'InterfaceSettings'));
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),'小程序设置'.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
$smarty = new lingdangCRM_Smarty;
foreach ($para_content_list as $paraName=>$paraValue){
    $smarty->assign(strtoupper($paraName),$paraValue);
}
$smarty->assign('LANGUAGETYPE',$languageType);
$arr['title'] = '小程序设置';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("modules/ShopSettings/InterfaceSettings_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>