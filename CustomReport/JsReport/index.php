<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
global $dbconfig,$root_directory;
global $global_minversin;
   // include('../../config.inc.php');
 require_once("../../Register/RegOp.php");
require_once("../../includefile.php");
require_once("../../Register/MySessionHandler.php");

// require_once("../../Register/CRMRedis.php");
if(file_exists("../../globalConfig/global_crm_server_url.php"))
    require_once("../../globalConfig/global_crm_server_url.php");
require_once("../../FrontMinVersion.php");

   // require_once('../../include/database/PearDatabase.php');
   // require_once('../../include/DatabaseUtil.php');

global $global_crmredisobj;
$global_crmredisobj=CRMRedis::getInstance();
if($global_crmredisobj!='error')
{
    //36059: （1.6）报表库>即时库存余额表：即时库存数量字段的值应该是蓝色可点击跳转的。（需要补丁）
    $handler = new MySessionHandler();

    //session_set_save_handler($handler,true);
    session_set_save_handler(
        array($handler, 'open'),
        array($handler, 'close'),
        array($handler, 'read'),
        array($handler, 'write'),
        array($handler, 'destroy'),
        array($handler, 'gc')
        );
        register_shutdown_function('session_write_close');
}
session_start();
global $userid;
file_put_contents("a.txt",$_SERVER['PHP_SELF'].'?'.$_SERVER["QUERY_STRING"]);
include($root_directory."modules/Customreport/JsReportIndex.php");

$VersionInfo=getVersionInfo();
 if(!isset($global_js_url)) 
 {
    $global_js_url="";
 }
$jsversion="1";
$crm_report_userid=0;
$printpermit='no';
$savereportpermit='no';
$permits['Print']='no';
$permits['SaveReportStore']='no';

 if(isset($_GET['crm_report_userid'])&&$_GET['crm_report_userid']>0&&$VersionInfo['account']!='saic')//saic:赛克
 {
    $crm_report_userid=$_GET['crm_report_userid'];//代表手机端访问
  
 }
 else{
    $crm_report_userid=$_SESSION['authenticated_user_id'];
   
    global $adb;
    global $current_user;
    $current_user=new Users();
    $current_user->retrieveCurrentUserInfoFromFile($crm_report_userid);
    if(!$adb)
    {
        $adb=PearDatabase::getInstance();
    
        
    }
    
  
    if(!is_admin($current_user))
    {
        $sql='select * from ld_profile2standardpermissions
        inner join ld_actionmapping on ld_profile2standardpermissions.operation=ld_actionmapping.actionid
         where ld_profile2standardpermissions.tabid=? and profileid=?';
        //zxm 20221205 报表库合并到报表分析之后 使用报表分析的权限
        $result=$adb->pquery($sql,array(getTabid('ReportAnalysis'),$current_user->profileid));
      
        if($adb->num_rows($result)>0)
        {
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                 $actionname=$adb->query_result($result,$i,'actionname');
                $permissions=$adb->query_result($result,$i,'permissions');
                if($permissions==0)
                {
                    $permit='yes';
                }
                else
                {
                    $permit='no';
                }
                $permits[$actionname]=$permit;
            }
            $printpermit=isset($permits['Print'])?$permits['Print']:'no';
           
            //$savereportpermit=$permits['SaveReportStore'];
            $savereportpermit=isset($permits['Export'])?$permits['Export']:'no';
        }
    }
    else
    {
        $printpermit='yes';
        $savereportpermit='yes';
    }
    //$printpermit=isPermitted('CustomReport','Print');
   // $savereportpermit=isPermitted('CustomReport','SaveReportStore');
 }
?>

<!DOCTYPE html>
<html>
<head>
    <script>
	var pagezoom='<?php echo $_GET["pagezoom"];?>';
    var crm_report_userid=<?php echo $crm_report_userid;?>;//
    var jsversion=<?php echo $global_minversin;?>;//$global_minversin:在FromMinVersion.php文件中
    </script>
    <meta http-equiv="Cache-Control:public,max-age=72000000" />
    
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<title><?php echo $_GET['report_name'];?></title>

	<!-- Office2013 style -->
	<link href="<?php echo $global_js_url;?>reportcss/stimulsoft.viewer.office2010.blue.css?v=<?php echo $global_minversin;?>" rel="stylesheet">

	<script src="<?php echo $global_js_url;?>reportjs1/stimulsoft.reports.src.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    <script src="<?php echo $global_js_url;?>reportjs1/StiCrossTabBuilder.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    
    <!--<script src="<?php echo $global_js_url;?>reportjs/stimulsoft.dashboards.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>-->
    <?php if(!isMobile() ) {?>
    	<script src="<?php echo $global_js_url;?>reportjs1/reportword.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>

      <script src="<?php echo $global_js_url;?>reportjs1/reportxls.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
             <script src="<?php echo $global_js_url;?>reportjs1/reportpdf.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
         <script src="<?php echo $global_js_url;?>reportjs1/reportcsv.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    <?php }?>

    <!--   <script src="<?php echo $global_js_url;?>reportjs/reporthtml.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    <script src="<?php echo $global_js_url;?>reportjs/reporth5.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    
    <script src="<?php echo $global_js_url;?>reportjs/svgdata.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
      -->
	<!-- Stimusloft Reports.JS -->
	<!-- Stimusloft Dashboards.JS -->
	<!--	<script src="scripts/stimulsoft.dashboards.js" type="text/javascript"></script>-->
	<!--  @edit:luyx @date:2021-10-19 @reason: 东贸铺位全景图默认显示比例50%   -->

    <script src="<?php echo $global_js_url;?>reportjs1/stimulsoft.viewer.src.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    <script src="reportjs1/cls_reportencryptyurl.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>
    <script src="reportjs1/crypto-js.min.js?v=<?php echo $global_minversin;?>" type="text/javascript"></script>


	
	<?php 
        $record=0;
        if(isset($_GET['record']))
        {
            $record=$_GET['record'];
            
        }
		$options = StiHelper::createOptions();
        if(isMobile())
		  $options->handler = "handler.php?default_report=".$defaultreport.'&crm_report_userid='.$crm_report_userid;
        else
            $options->handler = "handler.php?default_report=".$defaultreport;
        $options->handler.='&CRMCustomReport=yes';
        if(!empty($record))
        {
            $options->handler.='&record='.$record;
        }
		$options->timeout = 30;
		StiHelper::initialize($options);
	?>
    <style>
        body{
            margin:0px !important;
        }
        .stiJsViewerToolBarTable{
            background:#fff;
            border:none;
        }
    
    </style>
	<script type="text/javascript">
        var printpermit="<?php echo $printpermit;?>";
        var savereportpermit="<?php echo $savereportpermit;?>";
        if(typeof CallCenterJs!="undefined")
         {
                CallCenterJs.setPageText("<?php echo $_GET['report_name'];?>");
         }
		Stimulsoft.Base.StiLicense.loadVarFile("../../index.php?module=Customreport&action=jsReport");
		var reportprefix_url='';
		var options = new Stimulsoft.Viewer.StiViewerOptions();
        if(printpermit=='no')
        {
            options.toolbar.showPrintButton = false; 
        }
        if(savereportpermit=='no')
        {
            options.toolbar.showSaveButton=false;
        }
		options.appearance.fullScreenMode = true;
		options.toolbar.showSendEmailButton = false;
        options.toolbar.showOpenButton=false;
        //options.toolbar.showSaveButton=false;
        options.toolbar.showBookmarksButton=false;
        options.toolbar.showFindButton=false;
        options.toolbar.showResourcesButton=false;
        options.toolbar.showFullScreenButton=false;
        options.toolbar.multiPageWidthCount=false;
        options.toolbar.displayMode =false;
        
        // @edit:luyx @date:2020-09-01 @reason: 百分比和单页-多页按钮显示出来
        options.toolbar.showViewModeButton=true;
        options.toolbar.showZoomButton=true;//100%
      
        var pagezoom='<?php echo $_GET["pagezoom"];?>';

        
		var reportfilename='<?php echo $reportname;?>';
		var viewer = new Stimulsoft.Viewer.StiViewer(options, "StiViewer", false);
        //StiCollectionsHelper.getLocalizationItems：翻译
		Stimulsoft.Base.Localization.StiLocalization.cultureName='zh';
		// Process SQL data source
         
		viewer.onBeginProcessData = function (event, callback) {
		      jsHelper.process(arguments[0], arguments[1]);

		}
	
		// Manage export settings on the server side
		viewer.onBeginExportReport = function (args) {
		
		
		}
		
		
		// Send exported report to Email
		viewer.onEmailReport = function (event) {
			<?php StiHelper::createHandler(); ?>
		}
		
		// Load and show report
      
		var report = new Stimulsoft.Report.StiReport();//StiReport.prototype.loadFile 
          //StiDictionary:文件解析 //zxm BUG20240709-21 俄罗斯报表工具修改mrt模版之后，希望能够通过修改 FrontMinVersion.php 触发js更新
		report.loadFile("../../templatePrintFile/reports/"+reportfilename+"?v=<?php echo $global_minversin;?>");
      
		viewer.report = report;
		
		function onLoad() {
		  //StiNumberFormatService:数字格式化
          //StiReport.prototype.loadFromJsonInternal
          //StiFormatService.loadFromJsonObjectInternal:格式化
		  //整个报表界面的展示
          //showParametersPanel:展示查询列
          //InitializeParametersPanel:查询按钮，查询参数显示
          //InitializeParametersPanel,parametersPanel.addParameters展示Html
          //showReportPage:显示整个页面，该函数中reportPanel.addPages显示查询结果
			viewer.renderHtml("viewerContent");//StiViewer.prototype.renderHtml
            //InitializeToolBar:工具栏
            //StiDataSource.invokeConnecting();//后台参数赋值
            //StiSqlSource
            //StiSqlSource.prototype.retrieveDataAsync
           //StiSqlAdapterService.prototype.retrieveDataAsync:调用后台
          // StiSqlAdapterService.prototype.connectToDataAsync
           //InitializeViewerControls
           //StiVariablesHelper.getVariables:获取变量内容
           //CreateParameter:创建查询参数的html,添加下拉框CreateDropDownButton
		}
        function jsin_array(search,array){
            for(var i in array){
                if(array[i]==search){
                    return true;
                }
            }
            return false;
        } 
	</script>
	</head>
<body onload="onLoad();">
	<div id="viewerContent"></div>
</body>
</html>
<?php


/*移动端判断*/
function isMobile()
{ 
    // 如果有HTTP_X_WAP_PROFILE则一定是移动设备
    if (isset ($_SERVER['HTTP_X_WAP_PROFILE']))
    {
        return true;
    } 
    // 如果via信息含有wap则一定是移动设备,部分服务商会屏蔽该信息
    if (isset ($_SERVER['HTTP_VIA']))
    { 
        // 找不到为flase,否则为true
        return stristr($_SERVER['HTTP_VIA'], "wap") ? true : false;
    } 
    // 脑残法，判断手机发送的客户端标志,兼容性有待提高
    if (isset ($_SERVER['HTTP_USER_AGENT']))
    {
        $clientkeywords = array ('nokia',
            'sony',
            'ericsson',
            'mot',
            'samsung',
            'htc',
            'sgh',
            'lg',
            'sharp',
            'sie-',
            'philips',
            'panasonic',
            'alcatel',
            'lenovo',
            'iphone',
            'ipod',
            'blackberry',
            'meizu',
            'android',
            'netfront',
            'symbian',
            'ucweb',
            'windowsce',
            'palm',
            'operamini',
            'operamobi',
            'openwave',
            'nexusone',
            'cldc',
            'midp',
            'wap',
            'mobile'
            ); 
        // 从HTTP_USER_AGENT中查找手机浏览器的关键字
        if (preg_match("/(" . implode('|', $clientkeywords) . ")/i", strtolower($_SERVER['HTTP_USER_AGENT'])))
        {
            return true;
        } 
    } 
    // 协议法，因为有可能不准确，放到最后判断
    if (isset ($_SERVER['HTTP_ACCEPT']))
    { 
        // 如果只支持wml并且不支持html那一定是移动设备
        // 如果支持wml和html但是wml在html之前则是移动设备
        if ((strpos($_SERVER['HTTP_ACCEPT'], 'vnd.wap.wml') !== false) && (strpos($_SERVER['HTTP_ACCEPT'], 'text/html') === false || (strpos($_SERVER['HTTP_ACCEPT'], 'vnd.wap.wml') < strpos($_SERVER['HTTP_ACCEPT'], 'text/html'))))
        {
            return true;
        } 
    } 
    return false;
}
?>
