<?php

/**
 * @author yyy
 * @copyright 2015
 */
 $filename = $_REQUEST['filename'];//附件名称
$filename = urldecode($filename);
 $file_path = globalStatic::$root_directory."modules/Attachment/attachments.txt";
 $filehandle = fopen($file_path,"r");
 $filestring= fgets($filehandle);
 $fileTypes=explode(',',$filestring);
 $fileParts = pathinfo($filename);
if (!in_array(strtolower($fileParts['extension']),$fileTypes)) {
    @ob_clean();
    @ob_flush();
    $jarr['type']=2;
    $jarr['warning'] =3;
    $jarr['prohibited'] = 3;
    $jarr['filename']=$filename;
    echo $str=json_encode($jarr);//将数组进行json编码 
    exit();
}

$sys = getSys_deploy(77);
$type = 0;//0 成功 1 失败
$warning = 0;//0 不提示 1 提示
$prohibited = 0;// 1 禁止上传
if($sys['deploy_value'] == 0){//不限制
    $type = 0;
}else if($sys['deploy_value'] == 1){//提示
    $query = 'select filename from ld_attachmentsforbills where deleted=0 and  filename =?';
	if(!empty($_REQUEST['arr_record'])){
		$query .= ' and attachmentsid != ' . $_REQUEST['arr_record'];
	}
    $result = $adb->pquery($query,array($filename));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $type = 1;$warning = 1;
    }
    else{
        $type = 0;   
    }
}else if($sys['deploy_value'] == 2){//禁止
    $query = 'select filename from ld_attachmentsforbills where deleted=0 and filename =?';
	if(!empty($_REQUEST['arr_record'])){
		$query .= ' and attachmentsid != ' . $_REQUEST['arr_record'];
	}
    $result = $adb->pquery($query,array($filename));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $type = 1; $prohibited = 1;
    }else{
        $type = 0;
    }
}
@ob_clean();
@ob_flush();
$jarr['type']=$type;
$jarr['warning'] = $warning;
$jarr['prohibited'] = $prohibited;
$jarr['filename']=$filename;
echo $str=json_encode($jarr);//将数组进行json编码 
exit();

?>