<?php
require_once("include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//判断代码版本和数据库的版本是否一致
$languageType=$_REQUEST['languagetype'];
if(!in_array($languageType,array('zh','en')))
{
    return ;
}
require_once("config.inc.php");
require_once($root_directory.'include/utils/globalStatic.php');

globalStatic::$root_directory=$root_directory;
require_once($root_directory.'include/database/PearDatabase.php');
include($root_directory.'include/DatabaseUtil.php');
require_once("lingdangversion.php");
$adb=PearDatabase::getInstance();
$sql='select * from ld_version';
$result=$adb->pquery($sql,array());

$current_version=$adb->query_result($result,0,'current_version');
$code=1;
$error='';

if($lingdang_current_version!=$current_version)
{
    $code='-1';
    if($lingdang_current_version<$current_version)
    {
        if($languageType=='zh')
            $error="当前升级程序版本为：$lingdang_current_version"."，数据库版本为：$current_version"."，crm升级失败，请升级crm的代码文件！";
        else
            $error="The current upgrade program version is $lingdang_current_version and the database version is $current_version，database upgrade failed, please click [OK] to continue upgrading!" ;

    }
    else
    if($languageType=='zh')
        $error="当前升级程序版本为：$lingdang_current_version"."，数据库版本为：$current_version"."，数据库升级失败，请点击【确定】按钮继续升级";
    else
         $error="The current upgrade program version is $lingdang_current_version and the database version is $current_version，database upgrade failed, please click [OK] to continue upgrading!" ;
           
}
@unlink($root_directory.'dataCache/sqlhandlers/update.txt');
@unlink($root_directory.'dataCache/sqlhandlers/update1.txt');

$str=json_encode(array('code'=>$code,'result'=>array('error'=>$error)));
    //if(!$PlatformMC)
@ob_clean();
@ob_start();
@header('Content-type: text/html;charset=utf-8');
echo $str;
exit();
?>