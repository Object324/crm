<?php

global $default_timezone;
global $global_forbiddenext;
$global_forbiddenext=array('exe','bat','sh','php','aspx','js','com','php5','php4','php3','php2','asp','htaccess');
define("DEFAULTBATCHTEXT",'##1a$$1##MUBATCH');
//数据分类查询空值
define("DATACATEGORYSEACHEMPTYVALUE",'##$$searchemptyvalue##$$#');
//系统界面类型
define("PAGELIST","VAR_PAGELIST");//列表
define("PAGEPOPUPLISTWINDOW","VAR_PAGEPOPUPLISTWINDOW");//弹出窗口列表
define("PAGEPOPUPLISTLAYER","VAR_PAGEPOPUPLISTLAYER");//弹出层列表查询
define("PAGELISTQUICKFIND","VAR_PAGELISTQUICKFIND");//快速查找
define("PAGEEXPORTLIST","VAR_PAGEEXPORTLIST");//导出列表
define("PAGECSVEXPORTLIST","VAR_PAGECSVEXPORTLIST");//导出csv列表
define("PAGEEDITWINDOW","VAR_PAGEEDITWINDOW");//编辑
define("PAGECREATEWINDOW","VAR_PAGECREATEWINDOW");//创建
define("PAGEDETAILVIEWWINDOW","VAR_PAGEDETAILVIEWWINDOW");//查看

define("PAGEQUICKCREATELAYER",'VAR_PAGEQUICKCREATELAYER');//快速创建
define("NOALLOCATEACCOUNTS",'UnAssignedAccounts');//公海未分配的数据范围的模块名称
define("Field_FILEATTACHMENT",'fileattachment');

//渠道码名称
define("WEIXINCODE","微信");//微信
define("CHANNELCODE","渠道码");//渠道码
//小程序商城设置（商品状态）
define('PUTON_SHELF', '上架');
define('PULLOFF_SHELF', '下架');
define("WxSelfBuildURL",'http://81mis.com');
//不能进行统计的模块
define("UNABLE2STATISTICSMODULE","'ReportLog','Users','Reminds','Tooltip','ModTracker','lingdangBackup','FieldFormulas',
     'Events','Dashboard','Ambassador','WechatSession','Home','Documents','Emails','Faq',
     'MailManager','FieldFormulas','ModComments','RecycleBin','EmailListtmp','MassSMS',
     'MassEmails','SmsPhrases','Reminds','CommunicationLog','Comprehensivereport','Cache','OftenUseReport',
     'Attachment','BankAccountSet','PublicAnnouncement','CustomEcharts','ChinaMap','SocialPromotion','Articles',
     'ChannelCode','CooperativeWork','BankCash','Customreport','SalesGoal','Questionnaire','CustomTables','ReportAnalysis','Shopping','ShopSettings',
     'VisualAnalysis','BIReportScreen','ldsoukebao','ldsoukebaomap','TrackLocationMap'");

@date_default_timezone_set($default_timezone);
require_once('config.inc.php');
//require_once('CRMRedis.php');
require_once("SessionInfo.php");
require_once($root_directory.'include/utils/globalStatic.php');

globalStatic::$root_directory=$root_directory;
require_once($root_directory.'include/database/PearDatabase.php');
include($root_directory.'include/DatabaseUtil.php');

include($root_directory.'include/fields/fieldInfo.php');
include($root_directory.'include/fields/Field.Class.php');
require_once($root_directory.'modules/Users/Profile.class.php');
include($root_directory.'include/fields/ShowfieldValue.php');
include($root_directory.'data/CRMEntity.php');
require_once($root_directory.'Register/CRMRedis.php');
include($root_directory.'include/utils/utils.php');
require_once($root_directory.'include/cls_AESencryptionbykey.php');

require_once($root_directory.'/modules/Users/Users.php');
require_once($root_directory.'include/fields/cls_module_uitype.php');

include(globalStatic::$root_directory.'appCommon/appCommon.php');
if(file_exists($root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
    require_once($root_directory."dataCache/Login/zh_cn_version_new.lang.php");
}else{
    require_once($root_directory."include/language/zh_cn_version.lang.php");

}
/*if(!class_exists("DataCode"))
{
        class DataCode{
        static $ok=1;
        static $error=-1;
        static $errorcontinue=-2;
        static $errorhtml=-3;
    }
}*/

if(!array_key_exists(75,$versions))
{

    $versions[75]=array("lblversion"=>"灵当CRM旗舰版".$common_version['lblversion'],
        "LBL_BROWSER_TITLE"=>"灵当CRM旗舰版 - 客户关系管理专家",
        "EN_LBL_BROWSER_TITLE"=>"灵当CRM旗舰版 - 客户关系管理专家",
        "Version"=>"75",
    );
    $tmp_str='<?php'.PHP_EOL;
    $tmp_str.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
    $tmp_str.='$versions=array('.PHP_EOL;
    foreach($versions as $tmp_versionno=>$content)
    {
        $tmp_str.=$tmp_versionno.'=>array(';
        foreach($content as $key=>$info)
        {
            $tmp_str.="'".$key."'=>'".$info."',".PHP_EOL;
        }
        $tmp_str.="),".PHP_EOL;
    }
    $tmp_str.=")".PHP_EOL;
    $tmp_str.="?>";

    if(file_exists($root_directory.'dataCache/Login/zh_cn_version_new.lang.php')){
        file_put_contents($root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$tmp_str);
    }else{
        file_put_contents($root_directory.'include/language/zh_cn_version.lang.php',$tmp_str);
    }



}

if(!array_key_exists(76,$versions))
{

    $versions[76]=array("lblversion"=>"销售360旗舰版".$common_version['lblversion'],
        "LBL_BROWSER_TITLE"=>"销售360旗舰版 - 客户关系管理专家",
        "EN_LBL_BROWSER_TITLE"=>"销售360旗舰版 - 客户关系管理专家",
        "Version"=>"76",
    );
    $tmp_str='<?php'.PHP_EOL;
    $tmp_str.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
    $tmp_str.='$versions=array('.PHP_EOL;
    foreach($versions as $tmp_versionno=>$content)
    {
        $tmp_str.=$tmp_versionno.'=>array(';
        foreach($content as $key=>$info)
        {
            $tmp_str.="'".$key."'=>'".$info."',".PHP_EOL;
        }
        $tmp_str.="),".PHP_EOL;
    }
    $tmp_str.=")".PHP_EOL;
    $tmp_str.="?>";

    if(file_exists($root_directory.'dataCache/Login/zh_cn_version_new.lang.php')){
        file_put_contents($root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$tmp_str);
    }else{
        file_put_contents($root_directory.'include/language/zh_cn_version.lang.php',$tmp_str);
    }



}

/*
if(!array_key_exists(60,$versions))
{

   $versions[60]=array("lblversion"=>"销售360金融版".$common_version['lblversion'],
        "LBL_BROWSER_TITLE"=>"销售360金融版 - 客户关系管理专家",
        "EN_LBL_BROWSER_TITLE"=>"销售360金融版 - 客户关系管理专家",
        "Version"=>"60",
        );
        $tmp_str='<?php'.PHP_EOL;
        $tmp_str.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
        $tmp_str.='$versions=array('.PHP_EOL;
        foreach($versions as $tmp_versionno=>$content)
        {
            $tmp_str.=$tmp_versionno.'=>array(';
            foreach($content as $key=>$info)
            {
                $tmp_str.="'".$key."'=>'".$info."',".PHP_EOL;
            }
            $tmp_str.="),".PHP_EOL;
        }
        $tmp_str.=")".PHP_EOL;
        $tmp_str.="?>";

        if(file_exists($root_directory.'dataCache/Login/zh_cn_version_new.lang.php')){
            file_put_contents($root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$tmp_str);
        }else{
            file_put_contents($root_directory.'include/language/zh_cn_version.lang.php',$tmp_str);
        }



}
if(!array_key_exists(70,$versions))
{

   $versions[70]=array("lblversion"=>"灵当进销存".$common_version['lblversion'],
        "LBL_BROWSER_TITLE"=>"灵当进销存 - 库存管理专家",
        "EN_LBL_BROWSER_TITLE"=>"灵当进销存 -  库存管理专家",
        "Version"=>"70",
        );
    $versions[71]=array("lblversion"=>"销售360进销存".$common_version['lblversion'],
        "LBL_BROWSER_TITLE"=>"销售360进销存 - 库存管理专家",
        "EN_LBL_BROWSER_TITLE"=>"销售360进销存 -  库存管理专家",
        "Version"=>"71",
        );
        $tmp_str='<?php'.PHP_EOL;
        $tmp_str.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
        $tmp_str.='$versions=array('.PHP_EOL;
        foreach($versions as $tmp_versionno=>$content)
        {
            $tmp_str.=$tmp_versionno.'=>array(';
            foreach($content as $key=>$info)
            {
                $tmp_str.="'".$key."'=>'".$info."',".PHP_EOL;
            }
            $tmp_str.="),".PHP_EOL;
        }
        $tmp_str.=")".PHP_EOL;
        $tmp_str.="?>";

        if(file_exists($root_directory.'dataCache/Login/zh_cn_version_new.lang.php')){
            file_put_contents($root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$tmp_str);
        }else{
            file_put_contents($root_directory.'include/language/zh_cn_version.lang.php',$tmp_str);
        }

}*/
include($root_directory.'include/utils/CacheInfo.php');
include($root_directory.'include/utils/CommonUtils.php');
include($root_directory.'modules/Approve/Approve.php');
include($root_directory.'modules/CustomView/CustomView.php');
include($root_directory.'include/Currency/Currency.class.php');
include($root_directory.'include/ScopOfAuthority/ScopOfAuthority.php');
if(file_exists($root_directory.'include/Zend/json.php'))
    include($root_directory.'include/Zend/json.php');
else
    include($root_directory.'include/Zend/Json.php');
if(file_exists('user_privileges/oem_config.php'))
{
    require_once('user_privileges/oem_config.php');
    $LOGIN_SECURITY_CODE=oem_config::$LOGIN_SECURITY_CODE;
}
else if(file_exists('lingdang.php'))
{
     require_once('lingdang.php');
    $LOGIN_SECURITY_CODE=oem_config::$LOGIN_SECURITY_CODE;
}

//预先准备缓存文件夹
function createCachefolder(){
    @mkdir(globalStatic::$root_directory.'dataCache/tabdatas',0777);
    chmod(globalStatic::$root_directory.'dataCache/tabdatas', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/Login',0777);
    chmod(globalStatic::$root_directory.'dataCache/Login', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/execDays',0777);
    chmod(globalStatic::$root_directory.'dataCache/execDays', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/sqlhandlers',0777);
    chmod(globalStatic::$root_directory.'dataCache/sqlhandlers', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/test',0777);
	chmod(globalStatic::$root_directory.'dataCache/test', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/test/logo',0777);
	chmod(globalStatic::$root_directory.'dataCache/test/logo', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/test/vtlib',0777);
	chmod(globalStatic::$root_directory.'dataCache/test/vtlib', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/test/vtlib/HTML',0777);
	chmod(globalStatic::$root_directory.'dataCache/test/vtlib/HTML', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/pdf',0777);
	chmod(globalStatic::$root_directory.'dataCache/pdf', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/pdf/tmp',0777);
	chmod(globalStatic::$root_directory.'dataCache/pdf/tmp', 0777);

    @mkdir(globalStatic::$root_directory.'dataCache/apilog/',0777);
    chmod(globalStatic::$root_directory.'dataCache/apilog/', 0777);

     $dir = opendir(globalStatic::$root_directory.'dataCache/mpdf/tmp');
     $ml = 0;
    $cs=0;
    while ($dir&&($file = readdir($dir)) !== false)
    {

        if(is_dir($file))
            continue;

        $cs = $ml++;
        if(intval($cs) ==2){
            break;
        }
      }
      closedir($dir);

      if(empty($cs)){

        @rmdir(globalStatic::$root_directory.'dataCache/mpdf/tmp');
        @rmdir(globalStatic::$root_directory.'dataCache/mpdf');
      }

    @mkdir(globalStatic::$root_directory.'dataCache/mpdf',0777);
	chmod(globalStatic::$root_directory.'dataCache/mpdf', 0777);
    @mkdir(globalStatic::$root_directory.'dataCache/mpdf/tmp',0777);
	chmod(globalStatic::$root_directory.'dataCache/mpdf/tmp', 0777);
    //转移LoginSettingsInfo.php到dataCache/Login目录下
    if(file_exists(globalStatic::$root_directory.'LoginSettingsInfo.php')&&!file_exists(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php')){
        //转移文件时修改网页封面的路径
        $content =file_get_contents(globalStatic::$root_directory.'LoginSettingsInfo.php');
        if(!strpos($content,'dataCache/test/logo') && strpos($content,'test/logo')>=0){
            $content = str_replace('test/logo','dataCache/test/logo',$content);
        }
        file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',$content);
    }
    //转移test路径下的文件,用于登录界面显示
    $old2new_foldername = array(globalStatic::$root_directory.'test/logo/'=>globalStatic::$root_directory.'dataCache/test/logo/',
                                globalStatic::$root_directory.'test/vtlib/'=>globalStatic::$root_directory.'dataCache/test/vtlib/',
                                globalStatic::$root_directory.'test/vtlib/HTML/'=>globalStatic::$root_directory.'dataCache/test/vtlib/HTML/'
                                );
    //客户可以修改的图片,可能会出现客户图片名称与现有的重复的情况,以旧图片为准
    $special_filename_arr = array('logo.png','logo_mini_1.png');
    foreach($old2new_foldername as $pre_folder=>$post_folder){
        $folder = @opendir($pre_folder);
    	if ($folder == false) continue;
    	while(false !== ($file = readdir($folder))){
            if(is_dir($pre_folder.$file))continue;
    		if(file_exists($pre_folder.$file)&&(!file_exists($post_folder.$file)||in_array($file,$special_filename_arr))){
                file_put_contents($post_folder.$file,file_get_contents($pre_folder.$file));
            }
    	}
        closedir($folder);
    }
}

function SqlSearchFilter(&$req)
{
     foreach($req as $k=>$v)
     {
                if(is_array($v))
                {
                        $req[$k] = SqlSearchFilter($req[$k]);
                }
                else
                {
                        if(!isset($req[$k])) continue;
                        $req[$k]= trim($req[$k]); //$s为需要过滤的参数
                        //31495: 创建跟进记录时，内容中有“<”符号，后面的内容填了后保存后全没了
                        $req[$k]= strip_tags($req[$k],""); //清除HTML如等代码
                       // $req[$k]= str_replace("\n", "", str_replace(" ", "", $req[$k]));//去掉空格和换行
                        $req[$k]= str_replace("\t","",$req[$k]); //去掉制表符号

                        $req[$k]= str_replace("../","",$req[$k]); //去掉"../"
                         $req[$k]=addslashes($req[$k]);
                        $req[$k]= trim($req[$k]);
                }
     }
     return $req;
}


/**
 * 普通文本过滤（保存）
 * */
function TextRemoveXSS($val)
{
    $val = $val ?? '';
    $str=preg_replace("/<(script.*?)>(.*?)<(\/script.*?)>/si","",$val); //过滤script标签
    $str=preg_replace("/<(\/?script.*?)>/si","",$str); //过滤script标签
    $str=preg_replace("/javascript/si","Javascript",$str); //过滤script标签
    $str=preg_replace("/vbscript/si","Vbscript",$str); //过滤script标签
    $str=preg_replace("/on([a-z]+)\s*=/si","On\\1=",$str); //过滤script标签
    $str = preg_replace( "@<iframe(.*?)</iframe>@is", "", $str );
 //   $str = preg_replace( "@<style(.*?)</style>@is", "", $str );
    $str = preg_replace( "@document.write@is", "", $str );
    $str = preg_replace( "/eval[ ]*/si", "", $str);
    $str =preg_replace("/<(\/?img.*?)>/si","",$str);
    $str =preg_replace("/<(\/?image.*?)>/si","",$str);
    return $str;
}
function getFileTypeByfilename($filename)
{
    $fileInfo = pathinfo($filename);
    switch(strtolower($fileInfo['extension']))
    {
        case 'pdf':
            return 'application/pdf';
        case "png":
            return "image/png";
        case "jpg":
        case "jpeg":
            return 'image/jpeg';
        case 'xlsx':

            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        case 'xls':
            return "application/vnd.ms-excel";

        case 'doc':
        case 'docx':
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

    }
}
//后端 获取图片cdn地址 //zxm @date:2024/11/5 @reason: XUQIU20241029-07 模块图标没有替换，使用CND链接
function getGlobalImageUrl(){

    global $lingdang_cdn_version;
    if(file_exists(globalStatic::$root_directory."globalConfig/global_crm_server_url.php"))
    {
        global $global_image_url;//zxm @date:2024/11/5 @reason: 系统图片（非用户上传图片访问cdn地址）
        require_once(globalStatic::$root_directory."globalConfig/global_crm_server_url.php");
        if(empty($global_image_url)||!isset($global_image_url))
        {
            return '';
        }else{
            if(substr($global_image_url,"-1")!="/")
            {
                $global_image_url.="/";
            }
            if(strtolower(substr($global_image_url,"0",7))!="http://"&&strtolower(substr($global_image_url,"0",8))!="https://")
            {
                $global_image_url="http://".$global_image_url;
            }
            $tmpglobal_image_url=$global_image_url.$lingdang_cdn_version.'/';
            return $tmpglobal_image_url;
        }
    }else{
        return '';
    }
}

?>