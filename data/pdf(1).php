<?php
//预览PDF的文件
//$url = "https://81mis.com/kfbcrm/a.pdf";
$url = $_REQUEST['url'];
$root_dir= dirname(dirname(__FILE__)).'/';
require_once($root_dir."include/Tokencls.php");
$token=$_REQUEST['token'];
if(Tokencls::CheckTimeToken($token)=='no')
{
    echo json_encode(array(-1,[],'token错误'));
    die();

}
if($_REQUEST['storage_location']=='cos')
{
    $file =file_get_contents($url);
}
else{

    $tmp_arr=explode(".",$url);
    if(strtolower($tmp_arr[sizeof($tmp_arr)-1]!='pdf'))
    {
        require_once 'include/utils/utils.php';
        ConvertTojsonString(-1,[],'文件类型错误');

    }
    if(stripos($url,'/datacache/')===false)
    {
        if(stripos($url,'/storage/')===false){
            $filepath = $url;//cos文件
            $file =file_get_contents($filepath);
        }else{
            $url_arr=explode('/storage/',$url);
            $filepath="storage/".$url_arr[1];
            $file =file_get_contents($root_dir.$filepath);
        }
    }
    else
    {

        $url_arr=explode('/dataCache/',$url);
        $filepath="dataCache/".$url_arr[1];
        $file =file_get_contents($root_dir.$filepath);
    }
}
 //$file=_pdffile_get_contents($url);
 //$file =file_get_contents($root_dir.$filepath);// //_file_get_contents($url);
echo $file;
function _pdffile_get_contents($s) {
  $ch = curl_init($s);
  curl_setopt($ch, CURLOPT_HEADER, 0);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_FRESH_CONNECT, true);
  curl_setopt($ch, CURLOPT_TIMEOUT, 0);
  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); // 对认证证书来源的检查
  curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE); // 从证书中检查SSL加密算法是否存在
  $buffer = curl_exec($ch);
  //echo 'Curl error: ' . curl_error($ch);
  curl_close($ch);
  if ($buffer === false || empty($buffer)) {
    $ret = "";
  } else {
    $ret = $buffer;
  }
  return $ret;
}

 