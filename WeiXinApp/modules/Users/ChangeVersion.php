<?php

global $adb;
if(!$adb)
{
    exit();
}
global $curl_url;
//include(globalStatic::$root_directory."Register/RegOp.php");

$reg=RegOp::getInstance();
$senddata['action']='cust_renew';
$senddata['expired_time']=$reg->getExpireDate();
$senddata['corpindex']=getkehu001CorpInfoByKey("corpindex");

$senddata['sessionrand']=md5(strtotime(date("Y-m-d H:i:s"))."ab123");

$senddata['accountquantity']=$reg->GetUserCount();
$senddata['versionno']=$_REQUEST['versionno'];

$curl_url="http://111.231.135.110/webapi/api/operation.php";
$datalist= sendCurlPost($curl_url,$senddata);
@unlink(globalStatic::$root_directory.'dataCache/kehu001info.txt');

RegOp::getInstance();//重新生成缓存
//edit:can 2022通用问题：001销售增强版无法切换版本试用且切换服务增强版点击服务合同模块显示模块未激活

 opcache_list_file(globalStatic::$root_directory);
ConvertTojsonString(1,array(),"success");




function opcache_list_file($date){
    if(!function_exists('opcache_invalidate'))
            return ;
        //1、首先先读取文件夹
        $temp=scandir($date);
        //遍历文件夹
        foreach($temp as $v){
            $a=$date.'/'.$v;
            if($v=='vendor'||$v=='tencentcloud'||$v=='templatePrintFile'||$v=='storage'||$v=='js'||$v=='app'
            ||$v=='My97DatePicker'||$v=='themes'||$v=='templates'||$v=='marketplateform'||$v=='PHPExcel'||$v=='recordData'
            ||$v=='autoload')
                continue;
           if(is_dir($a)){//如果是文件夹则执行
          
               if($v=='.' || $v=='..'){//判断是否为系统隐藏的文件.和..  如果是则跳过否则就继续往下走，防止无限循环再这里。
                   continue;
               }
              
             
               opcache_list_file($a);//因为是文件夹所以再次调用自己这个函数，把这个文件夹下的文件遍历出来
           }else{
             if(stripos($a,'.php')!==false)
                opcache_invalidate($a,true);
           }
          
        }
}

function sendCurlPost($uri,$data){
            $ch = curl_init ();
            curl_setopt ( $ch, CURLOPT_URL, $uri );
            curl_setopt ( $ch, CURLOPT_POST, 1 );
            curl_setopt ( $ch, CURLOPT_HEADER, 0 );
            curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
            curl_setopt ( $ch, CURLOPT_POSTFIELDS, http_build_query($data));
            $output = curl_exec ( $ch );
            curl_close ( $ch );
            return $output;
}

?>