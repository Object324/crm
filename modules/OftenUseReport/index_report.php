<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_135 reason:常用报表公共文件  2019/8/6 15:30 ID1000568
global $current_user;
// $_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='OftenUseReport';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='index_report';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]=$_REQUEST['report_name'];
//
if($_REQUEST['ajax']=='true'&&!empty($_REQUEST['report_file']))
    include globalStatic::$root_directory.'modules/OftenUseReport/module/'.$_REQUEST['report_name'].'/'.$_REQUEST['report_file'].'.php';
else
{
    global $adb,$current_language,$theme,$currentModule,$current_user,$languageType;
 //   require_once(globalStatic::$root_directory.'include/QueryGenerator/QueryGenerator.php');
    //andrew  20140521    打印时languagetype为空
    include(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
    require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
    require_once(globalStatic::$root_directory.'modules/OftenUseReport/report_function.php');
    require_once(globalStatic::$root_directory.'modules/OftenUseReport/ReportModel.php');
    Crm_load_class_file("CommonView","modules/CustomView");
    crm_load_class_file('cls_encryptToken','Register');
    crm_load_class_file('cls_decryptToken','Register');
    $theme_path="themes/".$theme."/";
    $image_path=$theme_path."images/";
    //````````显示列设置和保存
    if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='SaveColumnSet')
    {
        UpdateColumnSet();exit;
    }else if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='editColumnName')
    {
        UpdateColumnLabel();exit;
    }
    //editor:gyq_155 reason:钉钉考勤同步  2019/10/29 13:40 ID1000624
    $sql = "select usertype from ld_wx_config where name=?";
    $result = $adb->pquery($sql,array('checkin_monthly'));
    $interfaceType = 'weixin';
    if($adb->num_rows($result)){
        $interfaceType = $adb->query_result($result,0,'usertype');
    }
    $versioninfo = getVersionTradeInfo();
    if($interfaceType=='dingtalk'&&($_REQUEST['report_name']=='checkin_abnormal'||$_REQUEST['report_name']=='checkin_monthly')){
        $filename = 'indexDing.php';
        if($versioninfo['account']=='yunwangjinfu'){
            $filename = 'indexDing_yunjin.php';
        }
        include globalStatic::$root_directory.'modules/OftenUseReport/module/'.$_REQUEST['report_name'].'/'.$filename;
    }else{
       
     //  echo globalStatic::$root_directory.'modules/OftenUseReport/module/'.$_REQUEST['report_name'].'/index.php';
      // exit();
        include globalStatic::$root_directory.'modules/OftenUseReport/module/'.$_REQUEST['report_name'].'/index.php';
    }
}
