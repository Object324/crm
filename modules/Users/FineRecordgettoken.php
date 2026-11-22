<?php
global $adb,$current_user,$root_directory;
$version_info = getVersionInfo();
//禹王————帆软报表，获取加密后token
if($version_info['account']=='yuwang')
{
    if(file_exists($root_directory.'/user_privileges/yuwangFineReportParam.php'))
    {
        require($root_directory.'/user_privileges/yuwangFineReportParam.php');
    }
    else
    {
        $myfile = fopen($root_directory.'/user_privileges/yuwangFineReportParam.php','w');
        $text = "<?php\n//\$key为加密设置key//\$iv为加密参数iv//\$tokenparam为URL中使用的参数\n\$key = '';\n\$iv='';\n\$tokenparam = '';\n?>";
        fwrite($myfile, $text);
        fclose($myfile);
        require($root_directory.'/user_privileges/yuwangFineReportParam.php');
    }
    if($key==''||$iv==''||$tokenparam=='')
    {
        ConvertTojsonString(-1,array(),"请联系管理员设置帆软报表相关参数");
    }
    
    
    $reportid = $_REQUEST['reportid'];
    $sql = "select report_file,report_url from ld_customreport_info where report_id = ?";
    $result = $adb->pquery($sql,array($reportid));
    $rows = $adb->num_rows($result);
    if($rows>0)
    {
        $fieldname = $adb->query_result($result,0,'report_file');
        $baseUrl = $adb->query_result($result,0,'report_url');
    }
    else
    {
        ConvertTojsonString(-1,array(),"打开报表失败");
    }
    $tokenarr = array(
                    'u'=>'yuwang',
                    'r'=>"formlet=/ywml/".$filename."/&op=h5",
                    'd'=>time()
                );
    
    //转为json字符串，JSON_UNESCAPED_SLASHES：不转义反斜杠，对应的数字 64
    $encryptcontent = json_encode($tokenarr,JSON_UNESCAPED_SLASHES);
    $token = Encrypt($encryptcontent,$key,$iv);
    
    $addurl = $tokenparam.'='.$token;
    if(strstr($baseUrl,'?')!= false)
	{
	   if(substr($baseUrl,strlen($baseUrl)-2,strlen($baseUrl)-1)!='?'){
	       $addurl ='&'.$addurl;
	   }
		
	}
	else
	{
		$addurl ='?'.$addurl;
	}
    ConvertTojsonString(1,array('token'=>$addurl,'url'=>$baseUrl.$addurl),"success");
}
else
{
    ConvertTojsonString(-1,array(),"error");
}


//加密token
function Encrypt($input,$key,$iv)
{
     $var = openssl_encrypt($input, 'AES-128-CBC', $key, OPENSSL_RAW_DATA, $iv);
     $var = base64_encode(base64_encode($var));
     return $var;
}

?>