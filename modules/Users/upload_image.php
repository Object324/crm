<?php
if(isset($_FILES["myfile"]))
{
	crm_load_class_file('User_Special','modules/Users');
    crm_load_class_file('cls_MyCRMcrypt',"Register");
    $cls_MyCRMcrypt = new cls_MyCRMcrypt();
	
	$file_details['name'] = $_FILES["myfile"]["name"];
    $fileParts = pathinfo($file_details['name']);
    global $global_forbiddenext;

    if (in_array(strtolower($fileParts['extension']),$global_forbiddenext))
    {
        die('为了安全考虑，禁止上传该文件');
    }
    $focus = new Users();
	$focus->retrieve_entity_info($_REQUEST['record'],'Users');
    
	$file_details['type'] = $_FILES["myfile"]["type"];
	$file_details['size'] = $_FILES["myfile"]["size"];
	$file_details['tmp_name'] = $_FILES["myfile"]["tmp_name"];



	$file_path_name =  User_Special::uploadAndSaveFile($_REQUEST['record'],$_REQUEST['module'],$file_details,$focus);
    
    //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
    $isEncrypt = $_REQUEST['imagename-isEncrypt_1'];	//是否加密
    $imgpath =  $_REQUEST['imagename-file_path_1'];
    $imgpath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($imgpath) : $imgpath;
	$ret['file'] = $imgpath.$file_path_name;
	$ret['filename'] = $_REQUEST['filename'];

    //@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片
	$_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1,$ret,'success');
//	echo json_encode($ret);
}
?>