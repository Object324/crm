<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
require_once('../../includefile.php');
globalStatic::$root_directory=dirname(dirname(dirname(__FILE__))).'/';

require_once('../../Register/RegOp.php');
require_once('../../Register/softInfo.php');
require_once('../../config.inc.php');
require_once('../../lingdangversion.php');
require_once('../../Register/CRMRedis.php');
//require_once('../../include/language/zh_cn_version.lang.php');
require_once('../../include/utils/CacheInfo.php');
if(file_exists("../../dataCache/Login/zh_cn_version_new.lang.php")){
    require_once("../../dataCache/Login/zh_cn_version_new.lang.php");
}else{
    require_once("../../include/language/zh_cn_version.lang.php");
}
set_time_limit(0);
$dbport=$dbconfig['db_port'];
$dbports=explode(':',$dbconfig['db_port']);
if(sizeof($dbports)>1)
{
    $dbport=$dbports[1];
}
$mysqli=new mysqli($dbconfig['db_server'],$dbconfig['db_username'],$dbconfig['db_password'],$dbconfig['db_name'],$dbport);

if(mysqli_connect_errno())
{
      $filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
      $update=2;
      fwrite($filehandle,$update);
      fclose($filehandle);
      echo mb_convert_encoding('数据库连接失败，请检查服务器MySQL数据库是否启动或者联系供应商解决！','gbk','utf-8');
   exit();
}
$mysqli->set_charset("utf8");
$regop=RegOp::getInstance();
$havelangague=$regop->isEnorZh();
$testFile=$regop->isExistFile();
if($testFile==0)//不存在
{
    require_once("../../VersionType.php");
    global $VersionNo;
    $RegisterVersionNo=$VersionNo;
}
else
{
    $RegisterVersionNo=$regop->GetVersionNo();
}

$code=false;

$query = "select linkurl from ld_links where linktype = 'updateversion' and linklabel = 'updatewaresql'";
$result=$mysqli->query($query);
$rows=$result->fetch_array();
$linkurl =$rows['linkurl']; 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD html 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><?php echo $versions[$RegisterVersionNo]['LBL_BROWSER_TITLE']?></title>

 <link rel="stylesheet" type="text/css" href="../../themes/softed/popup.css">
 <link type="text/css" href="../../themes/softed/login.css" rel="stylesheet" />
<style>
*{
	margin:0; padding:0;
}
.kuang{ width:390px; height:210px; position:absolute; padding-left:15px; top:315px; margin-top:-140px; right:16%; background:url(../../dataCache/test/logo/login_bg.png) no-repeat; padding-top:25px;}
.label{ font-weight:bold; display:block; text-align:right; padding-right:5px; font-size:12px; color:#666; line-height:24px;}
.Yydiv {float:left;}
.Yydiv input {float:left; margin:5px 5px 0px 0px; *margin:0px; color:#666;}
.Yydiv label {float:left; font-size:12px; color:#333; padding-right:10px; line-height:24px;}
.login_txt{ border:1px solid #999; height:20px; line-height:20px; width:220px;}
.login_btn{ width:130px; height:27px; border:0; background: url(../../dataCache/test/logo/login_btn.jpg) no-repeat; color:#fff; font-weight:bold; font-size:14px; }
.lblreg{font-size:12px;text-decoration:underline;color:blue;}
.clear {clear: both;height: 0;overflow: hidden;width: 0;}
</style>
<?php

  $line=0;//当前正在执行的脚本行号
$sql='select  current_version from ld_version';
$result=$mysqli->query($sql);
$rows=$result->fetch_array();
$dbversion=trim($rows['current_version']);
if(file_exists('../../dataCache/sqlhandlers/update.txt'))
{
    $filehandle=fopen('../../dataCache/sqlhandlers/update.txt','r+');
    $update=fgets($filehandle);
    $str='1'.$dbconfig['db_server'].$dbconfig['db_name'].$root_directory;
    if($update==$str)
    {
        echo '<div id="hideDiv" style="height: 100%; width: 100%; position: fixed; left: 0px; top: 0px; background-color: rgb(128, 128, 128); z-index: 9998; opacity: 0.6;"></div>';
        
        echo '<div id="updateWareSqlDiv" class="D_pop_box LdPopWidth650px" style="position: fixed; z-index: 9999; top: 50%; left: 50%; display: block; margin-top: -79px; margin-left: -201px; max-height: 500px; width: 400px; background: rgb(253, 253, 253);">';
        echo '<div class="D_pop_tit">';
        echo '<strong class="D_ptita" id="deleteremindertitlename">温馨提示</strong><a href="javascript:;" class="D_ptitc" onclick="fninvshnew();"><img class="D_ptitcimg" src="../../themes/icon/pop_close.png" alt="关闭" title="关闭"></a>';   
        echo '</div>';
        echo '<div id="updateWareSqlDivcontent" class="pop_remind_content" style="max-height: 400px; border: none;">';
        echo '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">';
        echo '<div class="msgDlg_left">';
        echo '<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon">';
        echo '</div></div>';
        echo '<div class="msgDlg_right">';
        echo '<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">';
        echo '数据库正在升级中（请不要关闭当前浏览器），如果长时间没有响应，请尝试通过手动升级解决！';
        echo '</div></div></div></div>';
        echo '<div class="D_pbtn ww_dialog_foot">';
        echo '<input class="D_pbtnok" value="确认" type="button" onclick="fninvshnew();">';
        echo '</div></div>';
        
                
        echo '<script> 
            function fninvshnew(){
                location.reload();
            }
        </script>';
        exit(); 
    }
    fclose($filehandle);
}

$updatevesions=array(
    0=>'V2.01',
    1=>'V2.02',
    2=>'V2.1',
    3=>'V2.2',
    4=>'V3.0',
    5=>'V3.1',
    6=>'V5.2',
    7=>'V5.3',
    8=>'V5.3.1',
    9=>'V5.3.2',
    10=>'V5.3.3',
    11=>'V5.4',
    12=>'V5.4.1',
    13=>'V5.5',
    14=>'V5.5.1',
    15=>'V5.6.0',
    16=>'V5.6.1',
    17=>'V5.7.0',
    18=>'V5.8.0',
    19=>'V5.8.1',
    20=>'V5.9.0',
    21=>'V5.9.1',
    22=>'V5.9.2',
    23=>'V6.0.0',
    24=>'V6.1.0',
    25=>'V6.1.1',
    26=>'V6.1.2',
    27=>'V6.1.3',
    28=>'V6.1.4',
    29=>'V6.1.5',
    30=>'V6.1.6',
    31=>'V6.1.7',
    32=>'V6.1.8',
    33=>'V6.1.9',
    34=>'V6.2.0',
    35=>'V6.2.1',
    36=>'V6.2.2');
    array_push($updatevesions,"V6.3.0");
    array_push($updatevesions,"V6.3.1");
    array_push($updatevesions,"V6.3.2");
    array_push($updatevesions,"V6.3.3");
    array_push($updatevesions,"V6.3.4");
    array_push($updatevesions,"V6.3.5");
    array_push($updatevesions,"V6.3.6");
    array_push($updatevesions,"V6.3.7");
    array_push($updatevesions,"V6.4.0");
    array_push($updatevesions,"V6.4.1");
    array_push($updatevesions,"V6.4.2");
    array_push($updatevesions,"V6.4.3");
    array_push($updatevesions,"V6.4.4");
    array_push($updatevesions,"V6.4.5");
    array_push($updatevesions,"V6.5.0");
    array_push($updatevesions,"V6.5.1");
    array_push($updatevesions,"V6.5.2");
    array_push($updatevesions,"V6.5.3");
    array_push($updatevesions,"V6.5.4");
    array_push($updatevesions,"V6.5.5");
    array_push($updatevesions,"V6.6.0");
    array_push($updatevesions,"V6.6.1");
    array_push($updatevesions,"V6.6.2");
    array_push($updatevesions,"V6.6.3");
    array_push($updatevesions,"V6.6.4");   
    array_push($updatevesions,"V6.6.5");
    array_push($updatevesions,"V6.6.6");
    array_push($updatevesions,"V6.6.7");
    array_push($updatevesions,"V6.6.8"); 
    array_push($updatevesions,"V6.7.0"); 
    array_push($updatevesions,"V7.0.0"); 
    array_push($updatevesions,"V7.0.1"); 
    array_push($updatevesions,"V7.0.2"); 
    array_push($updatevesions,"V7.0.3");
    array_push($updatevesions,"V7.0.4");  
    array_push($updatevesions,"V7.0.5"); 
    array_push($updatevesions,"V7.0.6");
    array_push($updatevesions,"V7.0.7");  
    array_push($updatevesions,"V7.0.8");    
    array_push($updatevesions,"V7.0.9");
    array_push($updatevesions,"V7.0.91");
    array_push($updatevesions,"V7.0.92");   
    array_push($updatevesions,"V7.1.0");  
    array_push($updatevesions,"V7.1.1");  
    array_push($updatevesions,"V7.1.2"); 
    array_push($updatevesions,"V7.1.3");  
    array_push($updatevesions,"V7.1.4");
    array_push($updatevesions,"V7.1.5");
    array_push($updatevesions,"V7.1.6");
    array_push($updatevesions,"V7.1.7"); 
    array_push($updatevesions,"V7.1.8");
    array_push($updatevesions,"V7.1.9");
    array_push($updatevesions,"V7.2.0");
    array_push($updatevesions,"V7.2.1");
    array_push($updatevesions,"V7.2.2");
    array_push($updatevesions,"V7.2.3");
    array_push($updatevesions,"V7.2.4");
    array_push($updatevesions,"V7.2.5");
    array_push($updatevesions,"V7.2.6");
    array_push($updatevesions,"V7.2.7");
    array_push($updatevesions,"V7.2.8");
    array_push($updatevesions,"V7.2.9");
    array_push($updatevesions,"V7.3.0");
    array_push($updatevesions,"V7.3.1");
    array_push($updatevesions,"V7.3.2");
    array_push($updatevesions,"V7.3.3");
    array_push($updatevesions,"V7.3.4");
    array_push($updatevesions,"V7.3.5");
    array_push($updatevesions,"V7.3.6");
    array_push($updatevesions,"V7.3.9");
    array_push($updatevesions,"V7.4.0");
    array_push($updatevesions,"V7.4.1");
    array_push($updatevesions,"V7.4.2");
    array_push($updatevesions,"V7.4.3");
    array_push($updatevesions,"V7.4.6");
    array_push($updatevesions,"V7.4.7");
    array_push($updatevesions,"V7.4.8");
    array_push($updatevesions,"V7.4.9");
    array_push($updatevesions,"V7.5.0");
    array_push($updatevesions,"V7.5.1");
    array_push($updatevesions,"V7.5.3");
    array_push($updatevesions,"V7.5.4");  
    array_push($updatevesions,"V7.5.5");
    array_push($updatevesions,"V7.5.5.1");
    array_push($updatevesions,"V7.5.5.5");    	
    array_push($updatevesions,"V7.5.6");
    array_push($updatevesions,"V7.5.7");
    array_push($updatevesions,"V7.5.8");
    array_push($updatevesions,"V7.5.9");
    array_push($updatevesions,"V7.6.0");
    array_push($updatevesions,"V7.6.1");
    array_push($updatevesions,"V7.6.2");
    array_push($updatevesions,"V7.6.3");
    array_push($updatevesions,"V7.6.4");
    array_push($updatevesions,"V7.6.5");
    array_push($updatevesions,"V7.6.6");
    array_push($updatevesions,"V7.6.7");
    array_push($updatevesions,"V7.6.8");
    array_push($updatevesions,"V7.6.9");
    array_push($updatevesions,"V7.7.0");
    array_push($updatevesions,"V7.7.1");
    array_push($updatevesions,"V7.7.2");
    array_push($updatevesions,"V7.7.3");
    array_push($updatevesions,"V7.7.4");
    array_push($updatevesions,"V7.7.5");
    array_push($updatevesions,"V7.7.6");
    array_push($updatevesions,"V7.7.7");
    array_push($updatevesions,"V7.7.8");
    array_push($updatevesions,"V7.7.9");
    array_push($updatevesions,"V7.8.0");
    array_push($updatevesions,"V7.8.1");
    array_push($updatevesions,"V7.8.1.1");
    array_push($updatevesions,"V7.8.1.2");
    array_push($updatevesions,"V7.8.1.3");
    array_push($updatevesions,"V7.8.2");
    array_push($updatevesions,"V7.8.3");
    array_push($updatevesions,"V7.8.4");
    array_push($updatevesions,"V7.8.5");
    array_push($updatevesions,"V7.8.6");
    array_push($updatevesions,"V7.8.7");
    array_push($updatevesions,"V7.8.8");
    array_push($updatevesions,"V7.8.9");
    array_push($updatevesions,"V7.9.0");
    array_push($updatevesions,"V7.9.1");
    array_push($updatevesions,"V7.9.2");
    array_push($updatevesions,"V7.9.3");
    array_push($updatevesions,"V7.9.4");
    array_push($updatevesions,"V7.9.5"); 
    array_push($updatevesions,"V7.9.6");
    array_push($updatevesions,"V7.9.7");
    array_push($updatevesions,"V7.9.8");
    array_push($updatevesions,"V7.9.9");
    array_push($updatevesions,"V7.9.9.1");
    array_push($updatevesions,"V7.9.9.3");
    array_push($updatevesions,"V7.9.9.5");
    array_push($updatevesions,"V7.9.9.6");
    array_push($updatevesions,"V7.9.9.7");
    array_push($updatevesions,"V7.9.9.8");
    array_push($updatevesions,"V7.9.9.9");
    array_push($updatevesions,"V7.9.9.10");
    array_push($updatevesions,"V7.9.9.11");
    array_push($updatevesions,"V7.9.9.12");
    array_push($updatevesions,"V7.9.9.13");
    array_push($updatevesions,"V7.9.9.14");
    array_push($updatevesions,"V7.9.9.15");
    array_push($updatevesions,"V7.9.9.16");
    array_push($updatevesions,"V7.9.9.17");
    array_push($updatevesions,"V8.0.0");
    array_push($updatevesions,"V8.0.0.1");
    array_push($updatevesions,"V8.0.0.2");
    array_push($updatevesions,"V8.0.0.3");
    array_push($updatevesions,"V8.0.0.4");
    array_push($updatevesions,"V8.0.0.5");
    array_push($updatevesions,"V8.0.0.6");
    array_push($updatevesions,"V8.0.0.7");
    array_push($updatevesions,"V8.0.0.8");
    array_push($updatevesions,"V8.0.0.9");
    array_push($updatevesions,"V8.0.0.10");
    array_push($updatevesions,"V8.0.0.11");
    array_push($updatevesions,"V8.0.0.12");
    array_push($updatevesions,"V8.0.1");
    array_push($updatevesions,"V8.0.2");
    array_push($updatevesions,"V8.0.3");
    array_push($updatevesions,"V8.0.4");
    array_push($updatevesions,"V8.0.5");
    array_push($updatevesions,"V8.0.6");
    array_push($updatevesions,"V8.0.7");
    array_push($updatevesions,"V8.0.8");
    array_push($updatevesions,"V8.0.9");
    array_push($updatevesions,"V8.1.0");
    array_push($updatevesions,"V8.1.1");
    array_push($updatevesions,"V8.1.2");
    array_push($updatevesions,"V8.1.3");
    array_push($updatevesions,"V8.1.4");
    array_push($updatevesions,"V8.1.5");
    array_push($updatevesions,"V8.1.6");
    array_push($updatevesions,"V8.1.7");
    array_push($updatevesions,"V8.1.8");
    array_push($updatevesions,"V8.1.9");
    array_push($updatevesions,"V8.2.0");
    array_push($updatevesions,"V8.2.1");
    array_push($updatevesions,"V8.2.2");
    array_push($updatevesions,"V8.2.3");
    array_push($updatevesions,"V8.2.4");
    array_push($updatevesions,"V8.2.5");
    array_push($updatevesions,"V8.2.6");
    array_push($updatevesions,"V8.2.7");
    array_push($updatevesions,"V8.2.8");
    array_push($updatevesions,"V8.2.9");
    array_push($updatevesions,"V8.3.0");
    array_push($updatevesions,"V8.3.1");
    array_push($updatevesions,"V8.3.1.1");
    array_push($updatevesions,"V8.3.1.2");
    array_push($updatevesions,"V8.3.2");
    array_push($updatevesions,"V8.3.3");
    array_push($updatevesions,"V8.3.4");
    array_push($updatevesions,"V8.3.5");
    array_push($updatevesions,"V8.3.6");
    array_push($updatevesions,"V8.3.7");
    array_push($updatevesions,"V8.3.7.1");
    array_push($updatevesions,"V8.3.7.2");
    array_push($updatevesions,"V8.3.7.3");
    array_push($updatevesions,"V8.3.7.4");
    array_push($updatevesions,"V8.3.7.5");
    array_push($updatevesions,"V8.3.7.6");
    array_push($updatevesions,"V8.3.8");
    array_push($updatevesions,"V8.3.9");
    array_push($updatevesions,"V8.4.0");
    array_push($updatevesions,"V8.4.1");
    array_push($updatevesions,"V8.4.2.0");
    array_push($updatevesions,"V8.4.2.1");
    array_push($updatevesions,"V8.4.2.2");
    array_push($updatevesions,"V8.4.2.3");
    array_push($updatevesions,"V8.4.2.4");
    array_push($updatevesions,"V8.4.2.5");
    array_push($updatevesions,"V8.4.2.6");
    array_push($updatevesions,"V8.4.2.7");
    array_push($updatevesions,"V8.4.2.8");
    array_push($updatevesions,"V8.4.2.9");
    array_push($updatevesions,"V8.4.3.0");
    array_push($updatevesions,"V8.4.3.1");
    array_push($updatevesions,"V8.4.3.2");
    array_push($updatevesions,"V8.4.3.4");
    array_push($updatevesions,"V8.4.3.5");
    array_push($updatevesions,"V8.4.3.6");
    array_push($updatevesions,"V8.4.3.7");
    array_push($updatevesions,"V8.4.3.8");
    array_push($updatevesions,"V8.4.3.9");
    array_push($updatevesions,"V8.4.4.0");
	array_push($updatevesions,"V8.4.4.1");
	array_push($updatevesions,"V8.4.4.2");
    array_push($updatevesions,"V8.4.4.3");
    array_push($updatevesions,"V8.4.4.4");
    array_push($updatevesions,"V8.4.5.0");
    array_push($updatevesions,"V8.4.5.1");
    array_push($updatevesions,"V8.4.5.2");
    array_push($updatevesions,"V8.4.5.3");
    array_push($updatevesions,"V8.4.5.4");
    array_push($updatevesions,"V8.4.5.5");
    array_push($updatevesions,"V8.4.5.5.1");
    array_push($updatevesions,"V8.4.5.6");
    array_push($updatevesions,"V8.4.5.7");
    array_push($updatevesions,"V8.4.5.8");
    array_push($updatevesions,"V8.4.5.8.1");
    array_push($updatevesions,"V8.4.5.8.2");
    array_push($updatevesions,"V8.4.5.8.3");
	array_push($updatevesions,"V8.4.5.8.4");
	array_push($updatevesions,"V8.4.5.8.5");
	array_push($updatevesions,"V8.4.5.8.6");
	array_push($updatevesions,"V8.4.5.9");
	array_push($updatevesions,"V8.4.6.0");
	array_push($updatevesions,"V8.4.6.1");
	array_push($updatevesions,"V8.4.6.2");
	array_push($updatevesions,"V8.4.6.3");
	array_push($updatevesions,"V8.4.6.4");
	array_push($updatevesions,"V8.4.6.5");
	array_push($updatevesions,"V8.4.6.6");
	array_push($updatevesions,"V8.4.6.6.1");
	array_push($updatevesions,"V8.4.6.6.2");
	array_push($updatevesions,"V8.4.6.6.3");
	array_push($updatevesions,"V8.4.6.6.4");
	array_push($updatevesions,"V8.4.6.6.5");
	array_push($updatevesions,"V8.4.6.6.6");
	array_push($updatevesions,"V8.4.6.6.7");
	array_push($updatevesions,"V8.4.6.6.8");
	array_push($updatevesions,"V8.4.6.6.9");
	array_push($updatevesions,"V8.4.6.6.10");
	array_push($updatevesions,"V8.4.7.0");
	array_push($updatevesions,"V8.4.7.1");
	array_push($updatevesions,"V8.4.7.2");
	array_push($updatevesions,"V8.4.7.3");
	array_push($updatevesions,"V8.4.7.4");
	array_push($updatevesions,"V8.4.7.5");
	array_push($updatevesions,"V8.4.7.6");
	array_push($updatevesions,"V8.4.7.7");
	array_push($updatevesions,"V8.4.7.8");
	array_push($updatevesions,"V8.4.7.9");
	array_push($updatevesions,"V8.4.8.0","V8.4.8.1","V8.4.8.2","V8.4.8.3","V8.4.8.4","V8.4.8.5","V8.4.8.6","V8.4.8.7","V8.4.8.8","V8.4.8.9","V8.4.9.0","V8.4.9.1","V8.4.9.2","V8.4.9.3");
    array_push($updatevesions,"V8.4.9.4","V8.4.9.5","V8.4.9.6","V8.4.9.7","V8.4.9.8","V8.4.9.9","V8.5.0.0","V8.5.0.1","V8.5.0.2","V8.5.0.3","V8.5.0.4","V8.5.0.5","V8.5.0.6","V8.5.0.7");
	array_push($updatevesions,"V8.6.0.0","V8.6.0.1","V8.6.0.2","V8.6.0.3","V8.6.0.4","V8.6.0.5","V8.6.0.6","V8.6.0.7","V8.6.0.8","V8.6.0.9","V8.6.1.0");
	array_push($updatevesions,"V8.6.1.1","V8.6.1.2","V8.6.1.3","V8.6.1.4","V8.6.1.5","V8.6.1.6","V8.6.1.7","V8.6.1.8","V8.6.1.9");
	array_push($updatevesions,"V8.6.2.0","V8.6.2.1","V8.6.2.2","V8.6.2.3","V8.6.2.4","V8.6.2.5","V8.6.2.6","V8.6.2.7","V8.6.2.8","V8.6.2.9","V8.6.3.0","V8.6.3.1","V8.6.3.2");
	array_push($updatevesions,"V8.6.3.3","V8.6.3.3.1","V8.6.3.3.2","V8.6.3.3.3","V8.6.3.3.4","V8.6.3.3.5","V8.6.3.3.6","V8.6.3.3.7","V8.6.3.3.8","V8.6.3.3.9","V8.6.3.3.10");
	array_push($updatevesions,"V8.6.3.3.11","V8.6.3.3.12","V8.6.3.3.13","V8.6.3.3.14","V8.6.3.3.15","V8.6.3.3.16");
	array_push($updatevesions,"V8.6.3.4","V8.6.3.5","V8.6.3.6","V8.6.3.7","V8.6.3.8","V8.6.3.9","V8.6.4.0","V8.6.4.1","V8.6.4.2","V8.6.4.3","V8.6.4.4","V8.6.4.5","V8.6.4.6","V8.6.4.7","V8.6.4.8","V8.6.4.9");
	array_push($updatevesions,"V8.6.5.0","V8.6.5.1");

if(!in_array($dbversion,$updatevesions))
{
    ?>
    <script>
        window.location='../../index.php?update=2';
    </script>
    
<?php
   
}
$dbindex=array_search($dbversion,$updatevesions)+1;
$codeindex=array_search($lingdang_current_version,$updatevesions);

if(!in_array($lingdang_current_version,$updatevesions))
{
    echo '软件版本和升级脚本对应关系不一致，请检查程序文件是否缺失！';
    exit();
}

$divlength=0;
if($dbindex<=$codeindex)
{
    for($dbindex;$dbindex<=$codeindex;$dbindex++)
    {
         if(!file_exists($updatevesions[$dbindex].'.sql'))
             {
                echo '升级脚本文件“'.$updatevesions[$dbindex].'.sql”不存在，请检查程序文件是否缺失！';
                exit();
              
             }
            $content=file_get_contents($updatevesions[$dbindex].'.sql');
            $arr = explode("delimiter;", $content);
            $divlength+=sizeof($arr);  //总共需要执行脚本数目
    }
        
}
$filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
$sqlhandle=fopen('../../dataCache/sqlhandlers/sqlhandler.txt','w+');

$update=1;
 fwrite($filehandle,$update);
 fwrite($filehandle,$dbconfig['db_server']);
 fwrite($filehandle,$dbconfig['db_name']);
 fwrite($filehandle,$root_directory);
 fclose($filehandle);
if($divlength>310)
{
    $step=$divlength/310;

}
else
{
    $step=310/$divlength+1;
}

?>
</head>
<body>
<div class="header">
	<div class="logo"><img src="../../dataCache/test/logo/logo.png" width="110" height="40" /></div>
    <div class="rig_bar">
        <a href="<?php echo $versions[$RegisterVersionNo]['appweb']?> " target="_blank">官方网站</a>| 
        <span><?php echo '热线电话：'.$versions[$RegisterVersionNo]['apptel']?></span>
    </div>
</div>
<div class="container">
    <div class="content">
    	<div class="log_left">
        	<img src="../../dataCache/test/logo/login_img.png" width="511" height="379" class="log_left_img" />
        </div>
        <div class="log_rig">
            <div class="login span8 ml0">
                <div class="login-shadow"></div>
                <form class="form_log">
                <div class="login-info" style="padding-bottom:13px">
                    <h2>登录</h2>
                    <div class="valm_a">
                       <div class="valm_b">
                            <div class="valm_c">
                <?php if ($havelangague=='yes')
                {
                        echo '
                            <div style="margin-bottom:7px;">
                                <span class="val_m" style="padding-right:20px">语　言</span>
                                <input type="radio" class="val_m" name="languageType" value="zh" checked="true" onclick="changeLangage(this)"/>
                                <span class="val_m" style="padding-right:30px">中文</span>
                                <input type="radio" class="val_m" name="languageType" value="en" onclick="changeLangage(this)"/>
                                <span class="val_m" style="padding-top:2px">English</span>
                            </div>
                      	';
                    }
                ?>
                <div class="account">
                    <span></span>
                    <input type="text" maxlength="100" tabindex="1" name="user_name" value="" placeholder="用户名" onblur="checkForm(this,name,'zh');"/>
    			</div>
                <div class="errtip"></div>
    			<div class="password">
                    <span></span>
                    <input type="password" tabindex="2" id="password" name="user_password" value="" placeholder="密码" onblur="checkForm(this,name,'zh');"/>
                </div>
                <div class="errtip"></div>
                <?php if ($code==true)
                {
                     echo ' 
                    <div id="yzm_value" class="token">
                        <input type="text" tabindex="3" name="secutity_code" value="" placeholder="验证码" />
                    </div>
                    <div class="errtip" style="margin:0px;"></div>
                    ';
                }
                ?> 
                            </div>
                        </div>
                    </div>
                </div>
                <div class="login-action">
                    <input class="submit-update" type="button"  id="submitButton" value="登 录" />
                    <div class="other"><div class="fl"></div></div>
                </div>
              </form>
            </div>
        </div>
    </div>
 </div>
 <div class="footer">
    <p>
        <a href="###" >设为主页</a>|
        <a href="###" >加入收藏</a>|
        <a href="###" target="_blank">关于我们</a>|
        <a href="###" target="_blank">iPhone</a>
        <img src="../../dataCache/test/logo/android_img.jpg" class="val_m" />
        <a href="###">Android</a>
        <br />
        <?php echo '  版权所有&nbsp;' .$softInfo['BeginYear'].'~'.date('Y').'&nbsp;'.$softInfo['CopyRight'] ;?> 
    </p>
 </div>


	<div id="dvUpdate" class="D_pop_box LdPopWidth350px" style="margin-top:-50px;display: block;position: absolute; z-index: 9999; visibility: visible;">
        <div class="D_pop_tit">
            <strong class="D_ptita">升级数据库</strong>
            <a class="D_ptitc" href="javascript:fninvshnew('dvUpdate');">
            <img title="关闭" alt="关闭" src="../../themes/icon/pop_close.png" style="margin:5px 0px 0px 4px;padding:0px;outline:0;">
            </a>
        </div>
        <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
        <tbody>
            <tr>
                <td>
                    <div>
                        <div id="dv" style="float: left;">
                        </div>
                        <div style="float: right;">
                            <?php if($common_version['oem_crm'] == 'no'){ ?>
                                <a href="javascript:void(0);" style="float: right;cursor: pointer;display: inline-block;background-image: url(../../themes/softed/images/home-icons.png);background-repeat: no-repeat;vertical-align: middle;position: relative;width: 20px;height: 17px;background-position: -5px -251px;" onclick="window.open('<?php echo $linkurl; ?>')"></a>
                            <?php } ?>
                        </div>
                    </div>
                    <div style="float:left;background-color:#FFFFFF;width:310px;height:20px;padding:1px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;">
                        <div id="dvprogress" style="float:left;width:0;height:20px;background-color:#669966;overflow:hidden;">&nbsp;</div>
                    </div>
                    <div class="clear"></div>
                    <div style="margin-top:10px;" id="dvc">正在升级数据库，请不要关闭或刷新浏览器</div>
                </td>
            </tr>
        </tbody>
        </table>
     </div>   
      
         <script type="text/javascript">
              var pagewidth=Math.max(document.body.clientWidth ,document.body.scrollWidth );
              var pageheight=Math.max(document.body.clientHeight ,document.body.scrollHeight );
             
              var updatewidth=document.getElementById('dvUpdate').offsetWidth;
              var updateheight=document.getElementById('dvUpdate').offsetHeight;
              
              document.getElementById('dvUpdate').style.left=(pagewidth-updatewidth)/2+"px";
              document.getElementById('dvUpdate').style.top=(pageheight-updateheight)/2+"px";
              function fninvshnew(idname)
              {
                	var newbox=document.getElementById(idname);
                     newbox.style.display="none";
              }
          
         </script>
      
<?php
ignore_user_abort(true);
$dbindex=array_search($dbversion,$updatevesions)+1;
$codeindex=array_search($lingdang_current_version,$updatevesions);
updateWeiXinVersion($mysqli);//更新微信API端版本号缓存 editor:gyq_31 date:20170918
if($dbindex<=$codeindex)
{
     if(file_exists('../../storage/updatelog.txt'))
     {
        @unlink('../../storage/updatelog.txt');
     }
    $filelog=fopen('../../storage/updatelog.txt','w+');
    $dvwidth=1;
    for($dbindex;$dbindex<=$codeindex;$dbindex++)
    {
       try
       {
             if(!file_exists($updatevesions[$dbindex].'.sql'))
             {
                echo '文件'.$updatevesions[$dbindex].'.sql';
                break;
             }
            $content=file_get_contents($updatevesions[$dbindex].'.sql');
            $arr = explode("delimiter;", $content);  
            $i=0;
            
            for($i;$i<count($arr);$i++)
            {  
                $sql=trim($arr[$i]);
                $line++;
                if($divlength>310)
                {
                      if($line%$step==0 )
                     {
                        $dvwidth=$dvwidth+1;
                     }
                }
                else
                {
                    $dvwidth=$line*$step;
                    
                }
               
                echo '<script> 
                     document.getElementById("dv").innerHTML="'.$line.'/'.$divlength.'";
                     document.getElementById("dvprogress").style.width = "'.$dvwidth.'px"</script>';
                ob_flush(); 
                flush();  
                if(empty($sql))
                {
                    continue;
                }
               if(strstr($sql,'||'))//存储过程
               {
                  $queryarr=explode('||',$sql);
                  for($j=0;$j<sizeof($queryarr);$j++)
                  {
                     $sql1=trim($queryarr[$j]);
                      if(empty($sql1))
                      {
                        continue;
                      }
                     if(strstr($sql1,'delimiter'))
                     {
                        $sqlarr=explode('delimiter',$sql1);
                        $ret=$mysqli->multi_query($sqlarr[0]);
                     }
                     else
                     {
                        $ret=$mysqli->multi_query($sql1);
                     }
                     if( mysqli_error($mysqli))
                        {
                             $filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
                            $update=2;
                             fwrite($filehandle,$update);
                             fclose($filehandle);
                            ignore_user_abort(false); 
                             fwrite($filelog, '文件'.$updatevesions[$dbindex] .'错误脚本:');
                             fwrite($filelog,"\r\n");
                             fwrite($filelog,$sql1);
                             fwrite($filelog, mysqli_error($mysqli).'ddd');
                             fclose($filelog);
                             $mysqli->close();
                            echo '<script>document.getElementById("dvc").innerHTML="执行脚本出错，请尝试手动升级！&nbsp;<a href=\'../../sql/updateVersion/sqllog.php\'>查看详情</a>"</script>';
                            exit();
                        } 
                        else
                        {
                                while(@$mysqli->next_result())
                                { 
                                       $result=$mysqli->store_result();
                                        if($result)
                                        $result->close();
                                }
        
                        } 
                  }
               }
               else
               {
                  $ret= $mysqli->multi_query($sql);
                    fwrite($sqlhandle,$sql);
                    if(mysqli_error($mysqli))
                    {
                         $filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
                        $update=2;
                         fwrite($filehandle,$update);
                         fclose($filehandle);
                        ignore_user_abort(false);
                      
                        fwrite($filelog, '文件'.$updatevesions[$dbindex] .'错误脚本:');
                        fwrite($filelog,"\r\n");
                        fwrite($filelog,$sql);
                        fwrite($filelog,mysqli_error($mysqli));

                        fclose($filelog);
                        $mysqli->close();
                        echo '<script>document.getElementById("dvc").innerHTML="执行脚本出错，请尝试手动升级！&nbsp;<a href=\'../../sql/updateVersion/sqllog.php\'>查看详情</a>"</script>';
                        exit();
                        
                    }
                    else
                    {
                        if(@$mysqli->more_results())
                            {
                                while(@$mysqli->next_result())
                                {
                                      
                                       $result=$mysqli->store_result();
                                        if($result)
                                        $result->close();
                                }
                            }
                            else
                            {
                                 $result=$mysqli->store_result();
                                 if($reuslt)
                                 {
                                    while($result->fetch_row())
                                    {
                                        
                                    }
                                 }
                                
                            }
                           
                    } 
             
               }
               
            }  
       }
       catch(Exception $ex)
       {
            $filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
            $update=2;
             fwrite($filehandle,$update);
            
             fclose($filehandle);
            ignore_user_abort(false);
          echo '文件'.$updatevesions[$dbindex].'.sql 第'.$i.'行脚本错误';
       }
    }
}

$mysqli->close();
$filehandle=fopen('../../dataCache/sqlhandlers/update.txt','w+');
$update=2;
fwrite($filehandle,$update);
fclose($filehandle);
fclose($filelog);
fclose($sqlhandle);
ignore_user_abort(false);
require_once(globalStatic::$root_directory.'modules/Cache/index.php');
opcache_list_file(globalStatic::$root_directory);

clearCacheFiles();
clearMinifyFiles();
clearSmartyFiles();
clearDefaultFile();
unsetCacheDirectory('productfields');
unsetCacheDirectory('fields');
unsetCacheDirectory('profile');
if(file_exists("../../dataCache/execDays/autoremind.txt"))
{
	@unlink("../../dataCache/execDays/autoremind.txt");
}
?>
<script>
	window.location='../../index.php?update=2';
</script>
</body>
</html>