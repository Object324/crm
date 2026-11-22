<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * 更新操作
 * edit:diony
 * date:2013-11-14
 * reason:数据备份
 */ 

require_once('backupdefault.php');
require_once("config.php");
global $adb,$theme,$mod_strings,$app_strings;
$smarty=new lingdangCRM_Smarty;
$mode='look';
$os = BackUpLib::checkOs($root_directory);
$smarty->assign('OS',$os);

require( "vendor/autoload.php");

use Ifsnop\Mysqldump as IMysqldump;
//下载和删除备份文件
if(isset($_REQUEST['backupid']) && $_REQUEST['backupid']!='' && $_REQUEST['ajax']=='yes'){
    $backupid = $_REQUEST['backupid'];
    $dbQuery = "SELECT * FROM ld_backup_file where backupid = ?" ;

    $result = $adb->pquery($dbQuery, array($backupid)) or die("Couldn't get file list");
    
    if($adb->num_rows($result) == 1)
    {
        $backuptype = $adb->query_result($result,0,'backuptype');
        $fileType = $backuptype==1?'application/zip':'application/octet-stream';
    	$name = @$adb->query_result($result, 0, "filename");
        $name = html_entity_decode($name, ENT_QUOTES, $default_charset);

		$stri='storage/backup';
		
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {
            //获取系统类型，如果是非windows系统则不用修改编码格式
            $saved_filename=$name;
        }
        else
        {
            $saved_filename=iconv ( 'UTF-8', 'GBK', $name );
        }
        
		$stri.='/'.$saved_filename;
        
        //下载
        if(isset($_REQUEST['download']) && $_REQUEST['download']=='yes'){
            if(!file_exists($stri)){
                ConvertTojsonString(-1,'','error');
            }
			$name = iconv ( 'UTF-8', 'GBK', $name );
		//	crm_load_class_file('FileDownload','include/download'); 
//			$FileDownload = new FileDownload();
//			$FileDownload->download($stri, $name);
            $arr['name'] = $name;
            ConvertTojsonString(1,$arr,'success');

        }
        
        //删除
        if(isset($_REQUEST['deletefile']) && $_REQUEST['deletefile']=='yes'){
            $sql = "delete from ld_backup_file where backupid=".$backupid;
            $adb->pquery($sql,array());
            
            @unlink($stri);
        }
    }else{
        echo '###NOFILE###';exit;
    }
}

if(isset($_REQUEST['mode'])&&$_REQUEST['mode']!=''){
    $mode=$_REQUEST['mode'];
    if($mode=='backup')
    {
        define("dbserver", $dbconfig['db_hostname']);
		define("dbuser", $dbconfig['db_username']);
		define("dbpass", $dbconfig['db_password']);
		define("dbname", $dbconfig['db_name']);  

		$path_query = $adb->pquery("SELECT * FROM ld_backup WHERE id = 1");
        //$path = $adb->query_result($path_query,0,'backuppath');
		$currenttime=date("Ymd_His");
       /* if(strlen($path)>0)
        {
            $path = $path;
        }
        else
        {
            $path = $BACKUP_HAND_PATH;
        }*/
		 $path = $BACKUP_HAND_PATH;
		if(is_dir($path) && is_writable($path))
		{   
			//require_once 'modules/lingdangBackup/lingdangBackup.php';
			//require_once 'include/db_backup/DatabaseBackup.php';
            
            //插入ld_backup_file,ps:应该在备份文件结束后插入表,但插入代码放在备份文件后面会出错,未执行插入操作
            $sql = "insert into ld_backup_file(filename,backuptime,backuptype,operator)
                    values(?,?,?,?)";
            $backuptime = date('Y-m-d H:i:s',time());
            $filename = 'Backup-'.date('Ymd_His',time()).'.zip';
            
            $adb->pquery($sql,array($filename,$backuptime,1,$current_user->id));
            $backupid = $adb->getLastInsertID();
            
            //zkt 20210930 0048068: （81mis.com/kfbcrm）（本地也有问题、需要补丁）系统设置》其他设置》数据库备份，点击立即备份，界面一直转圈，后台有报错
			//$backup = new lingdangBackup($filename);
			//$backup->backup();
			//$fileName = $backup->getBackupFileName();
             @mkdir(globalStatic::$root_directory.   'storage/'.BackUpLib::LINUXBACK,0777);


            try {
                $options=['compress' =>IMysqldump\Mysqldump::GZIP]; // 压缩备份文件
                $dump = new IMysqldump\Mysqldump('mysql:host='.dbserver.';dbname='.dbname.';port='.$dbconfig['port'].';', dbuser, dbpass,$options);
                $dump->start(globalStatic::$root_directory.   'storage/'.BackUpLib::LINUXBACK.'/'.$filename);
            } catch (\Exception $e) {
                echo 'mysqldump-php error: ' . $e->getMessage();
            }
			$msg = 1;
			//$smarty->assign("ERROR_MSG", $fileName);
            //$smarty->assign("ERROR_MSG", getFixedLabel('BACKUPSUCCESS'));
		}
		else{
			$msg = 2;
			//$smarty->assign("ERROR_MSG", getFixedLabel('BACKUPFAILED'));	
		}
        $arr=array();
        
        if($msg!=''){
           $arr['content'].=' <span style="color:red"> ';
           
            if($msg=='1')
                $arr['content'].=getFixedLabel('BACKUPSUCCESS');
            else
                $arr['content'].=getFixedLabel('BACKUPFAILED');
               
            $arr['content'].='</span>';
            
            
        }
		if($backupid!='')
	                $arr['content'].=' &nbsp;&nbsp;<a href="javascript:;" onclick="downloadfile('.$backupid.')">'.getFixedLabel('CLICKDOWNLOADBACKUPFILE').'</a>';
                    
	      $_REQUEST['diony']='yes';
          ConvertTojsonString(1,$arr,'succcess');
                
		//header("Location:index.php?module=Settings&action=BackupSettings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']."&msg=".$msg."&backupid=".$backupid);
		//die;
    }elseif($mode=='save'){
//        @edit:liushuai,2020-08-14,reason:0041964: （本地部署）系统设置->其他设置->数据库备份：编辑界面点击【保存】点不动，点击【取消】按钮，界面跳转到首页
        $isusing_2 = $_REQUEST['isusing_2'];
        $sql = 'update ld_backup set isusing = ? where id = 2';//id:2 自动备份
        $adb->pquery($sql,array($isusing_2));
        $mode='look';
    }
}

//下载文件列表
if(isset($_REQUEST['filelist']) && $_REQUEST['filelist']=='yes'){
    global $list_max_entries_per_page_new_more;
    
    $sql = "select * from ld_backup_file order by backuptime desc ";
    $count_result = $adb->query('select 1 from ld_backup_file');
    
    $noofrows=$adb->num_rows($count_result);
    //获取当前页数
	if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
		$start = $_REQUEST['start'];
		if($start == 'last'){
			if($noofrows > 0){
				$start = ceil($noofrows/$list_max_entries_per_page_new_more);
			}
		}
		if(!is_numeric($start)) $start = 1;
		elseif($start < 1) $start = 1;
		$start = ceil($start);
	}else{
		$start = 1;
	}
	$limstart=($start-1)*$list_max_entries_per_page_new_more;
	$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
    
    
    $result = $adb->pquery($sql);
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $backupid = $adb->query_result($result,$i,'backupid');
            $filename = $adb->query_result($result,$i,'filename');
            $backuptime = $adb->query_result($result,$i,'backuptime');
            $backuptype = $adb->query_result($result,$i,'backuptype');
            $operator = $adb->query_result($result,$i,'operator');
            $download = getFixedLabel('DOWNLOAD');
            $operate = getFixedLabel('DELETE');
            //	0026535: 控制面板-数据备份：备份数据后，点击【下载备份文件】，弹出层中点击备份文件名称，界面提示该文件已经被删除
           // if(!file_exists('backup/'.$filename)) continue;
            $Downloadlist[$i]['filename'] = '<a title="'.$filename.'" href="javascript:downloadfile('.$backupid.')">'.$filename.'</a>';
            $Downloadlist[$i]['backuptime'] = substr($backuptime,0,10);
            $Downloadlist[$i]['backuptype'] = $backuptype=='1'?getFixedLabel('MANUAL'):getFixedLabel('AUTOMATIC');
            $Downloadlist[$i]['operator'] = getUserFullName($operator);
            $Downloadlist[$i]['operate'] = '<a class="Anu3_a" href="javascript:downloadfile('.$backupid.')">'.$download.'</a><a class="Anu3_a" href="javascript:deletefile('.$backupid.')">'.$operate.'</a>';
        }
    }
    
    $header = array(
                'filename'=>getFixedLabel('BACKUPFILENAME'),
                'backuptime'=>getFixedLabel('BACKUPTIME'),
                'backuptype'=>getFixedLabel('BACKUPTYPE'),
                'operator'=>getFixedLabel('OPERATOR'),
                'operate'=>getFixedLabel('OPERATING')
              );
              
    //分页按钮
    crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
	$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
	$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
	//chj 2021/2/22 44701: 系统设置->其他设置->数据库备份->下载备份文件，一直转圈
    $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array,'','','','');

    $return_value = array('header'=>$header,'entries'=>$Downloadlist,'navigation'=>$navigationOutput,
    				'title'=>getFixedLabel('DOWNLOADBACKUPFILE'),'lbl_none'=>getFixedLabel('NONE'));
    
    ConvertTojsonString(1,$return_value,'success');
    
}
//$_REQUEST['handbackup_path'] = $_REQUEST['backuppath_2'] = 'D:/Program Files/ldcrm/backup';
//判断是否是手动备份保存，如果是将数据更新到数据库中
/*
*edit chj
*date 2020/11/24
*reason 43387: （本地部署）客户问题（陈修宏），系统设置->其他设置->数据库备份：编辑界面，修改“自动备份周期”和“删除历史数据”保存后无效（需要补丁）
*/
if(isset($_REQUEST['savehand'])&&$_REQUEST['savehand']!=''){
    $savehand=$_REQUEST['savehand'];
    $handbackup_paths = $_REQUEST['handbackup_path'];
	//if($os == 'window'){
		//if(!file_exists($handbackup_paths{0}.$handbackup_paths{1})){//盘符不存在
			//echo '<script type="text/javascript">alert("'.getFixedLabel('BACKUPPATHNOTEXISTCONTAINSCHINESE').'");location.href="index.php?module=Settings&action=BackupSettings&mode=edit&focusfld=handbackup_path";</script>';exit();
		//}
	//}else if($os == 'linux'){
		//if($handbackup_paths{0} != '/'){
			//echo '<script type="text/javascript">alert("'.getFixedLabel('BACKUPPATHNOTEXISTCONTAINSCHINESE').'");history.go(-2);</script>';exit();
		//}
	//}
	if(!file_exists($handbackup_paths)){
		BackUpLib::createdir($handbackup_paths);
	}
    if(file_exists($handbackup_paths)&&!preg_match("/[\x7f-\xff]/", $str))
    {
        $handbackup_paths=str_replace('\\','\\\\',$handbackup_paths);    
        $query="update ld_backup set backuppath='".$handbackup_paths."' where id = 1 ";
       // $adb->pquery($query);
    }
    else
    {
        $smarty->assign('ERROR_MSG',getFixedLabel('BACKUPPATHNOTEXISTCONTAINSCHINESE'));
    }
	/**
	 * 自动备份设置保存
	 * @project PROT123 自动备份
	 * @author Tujt 2014-10-27
	 */
	//$_REQUEST['isusing_2'] == 'on'
	if(isset($_REQUEST['backuppath_2'])){//自动备份保存
		//清除路径中所有空格，因定时任务无法解析空格
		//$backuppath = ereg_replace('[[:space:]]','',$_REQUEST['backuppath_2']);
		$backuppath = $_REQUEST['backuppath_2'];
		//if($os == 'window'){
			//if(!file_exists($backuppath{0}.$backuppath{1})){//盘符不存在
				//echo '<script type="text/javascript">alert("'.getFixedLabel('BACKUPPATHNOTEXISTCONTAINSCHINESE').'");location.href="index.php?module=Settings&action=BackupSettings&mode=edit&focusfld=backuppath_2";</script>';exit();
			//}
		//}
		$eachbackopts = $_REQUEST['eachbackopts'];
		if($eachbackopts == 'week'){
			$eachbackopts .= ':'.$_REQUEST['weekopts'];
		}else if($eachbackopts == 'month'){
			$eachbackopts .= ':'.$_REQUEST['eachday'];
		}
		
		$automaticbackup = 'isusing = '.(('on' == $_REQUEST['isusing_2'])?1:0).',
							
							intervaldays = "'.$eachbackopts.'",
							intervalhours = "'.$_REQUEST['hours_2'].'",
							intervalminute = "'.$_REQUEST['minute_2'].'"';
		$update = 'update ld_backup set '.$automaticbackup.' where id = 2;';
		$adb->pquery($update,array());
		//创建批处理文件，实现定时任务
		$backupparam = array();
		$backupparam['admin'] = $root_directory;//系统配置根目录地址
		$backupparam['dbconfig'] = $dbconfig;//数据库备份信息
		$backupparam['every'] = $eachbackopts;//备份状态
		$backupparam['hours'] = $_REQUEST['hours_2'];//小时
		$backupparam['minute'] = $_REQUEST['minute_2'];//分钟
		$backupparam['backuppath'] = $backuppath;//数据库备份地址
		$backupparam['delbackup'] = $_REQUEST['delbackup_2'];//删除数据周期
		$backup_focus = new BackUpLib($backupparam);
		if('on' == $_REQUEST['isusing_2']){
			$backup_focus->backup();
		}else{
			$backup_focus->deleteAt();
		}
		$cachekey = 'cache_delete_backup_dumpsql';
		MemoryCache($cachekey,$_REQUEST['delbackup_2']);
		$mode='look';
		//header("Location:index.php?module=Settings&action=BackupSettings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
		//die;
	}
}


//查找手动备份
//如果备份路径为空，获取文件中备份路径；不为空，获取查找路径
$query="select * from ld_backup where id =1";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    //$handbackuppath=$adb->query_result($result,0,'backuppath');
	/*if(strlen($handbackuppath)>0)
    {
        $smarty->assign('HANDPATH',$handbackuppath);    
    }
    else
    {
        $smarty->assign("HANDPATH", $BACKUP_HAND_PATH);
    } */
	$smarty->assign("HANDPATH", $BACKUP_HAND_PATH);
}
if(!empty($_REQUEST['msg'])){
	$smarty->assign('MSG',$_REQUEST['msg']);
}
if(!empty($_REQUEST['backupid'])){
    $smarty->assign('BACKUPID',$_REQUEST['backupid']);
}
/**
 * 获取自动备份配置信息
 * @project PROT123 自动备份
 * @author Tujt 2014-10-27
 */
$query = 'select isusing,backuppath,intervaldays,intervalhours,intervalminute from ld_backup where id = 2 limit 1;';
$result = $adb->pquery($query,array());
$rows = $adb->num_rows($result);
if($rows == 1){
	$isusing_2 = $adb->query_result($result,0,'isusing');//是否启用
	$backuppath_2 = $adb->query_result($result,0,'backuppath');//备份路径
	$intervaldays_2 = $adb->query_result($result,0,'intervaldays');//备份周期
	$intervalhours_2 = $adb->query_result($result,0,'intervalhours');//定时任务执行的小时数
	$intervalminute_2 = $adb->query_result($result,0,'intervalminute');//定时任务执行的分钟数
	$smarty->assign('WHETHERTOENABLE_2',$isusing_2);
	//if(!$backuppath_2) $backuppath_2 = $BACKUP_HAND_PATH;
	$smarty->assign('BACKUPFILEPATH_2',$BACKUP_HAND_PATH);
	if($intervalhours_2 == '') $intervalhours_2 = date('H',time());
	$smarty->assign('INTERVALHOURS_2',$intervalhours_2);
	if(!$intervalminute_2 && $intervalminute_2 != 0) $intervalminute_2 = date('i',time());
	$smarty->assign('INTERVALMINUTE_2',$intervalminute_2);
	if(!empty($intervaldays_2)){
		if($intervaldays_2 == 'day'){//每天执行
			$smarty->assign('EACHBACKED','day');
		}else{
			$intervalarr = explode(':',$intervaldays_2);
			if($intervalarr[0] == 'week'){//每周执行一次
				$smarty->assign('EACHBACKED','week');
				$smarty->assign('WEEKOPTSED',$intervalarr[1]);//每周周几执行
			}else{//每月执行一次
				$smarty->assign('EACHBACKED','month');
				$smarty->assign('MONTHOPTSED',$intervalarr[1]);//每月几号执行
			}
		}
	}
}
$hoursopts = range(0,23);//小时，从1到23点
$minuteopts = range(0,59);//分钟，从0到59分
$smarty->assign('HOURSOPTS',$hoursopts);
$smarty->assign('MINUTEOPTS',$minuteopts);
$eachbackarr = array('day'=>getFixedLabel('Day'),
						'week'=>getFixedLabel('Week'),
							'month'=>getFixedLabel('nMonth'));
$smarty->assign('EACHBACKARR',$eachbackarr);
$weekopts = array('1'=>getFixedLabel('Monday'),'2'=>getFixedLabel('Tuesday'),
					'3'=>getFixedLabel('Wednesday'),'4'=>getFixedLabel('Thursday'),
					'5'=>getFixedLabel('Friday'),'6'=>getFixedLabel('Saturday'),
					'7'=>getFixedLabel('Sunday'));
$smarty->assign('WEEKOPTS',$weekopts);//星期
$eachdayopts = range(1,28);//每月执行天数
$smarty->assign('EACHDAYOPTS',$eachdayopts);
$delbackupopts = array(
			'beforedays_15'=>getFixedLabel('before15days'),//15天前
			'beforedays_30'=>getFixedLabel('before30days'),//30天前
			'beforedays_60'=>getFixedLabel('before60days'),//60天前
			'beforedays_90'=>getFixedLabel('before90days'),//90天前
			'beforedays_120'=>getFixedLabel('before120days'),//120天前
			'beforedays_180'=>getFixedLabel('before180days'),//180天前
			'beforedays_360'=>'360'.getFixedLabel('DAYSAGO'),//360天前
			'beforedays_720'=>'720'.getFixedLabel('DAYSAGO'),//720天前
		);

$cachekey = 'cache_delete_backup_dumpsql';
$delbackuped = MemoryCache($cachekey);
if(!$delbackuped){
	$delbackuped = 'beforedays_30';
}
$smarty->assign('DELBACKUPOPTS',$delbackupopts);
$smarty->assign('DELBACKUPED',$delbackuped);



$linuxback = rtrim($root_directory, '/').'/';
$linuxback = str_replace("\\","/",$linuxback);//替换反斜杠
$smarty->assign('ROOTDIR',$linuxback.'storage/'.BackUpLib::LINUXBACK);

$smarty->assign('FOCUSFLD',$_REQUEST['focusfld']);

$smarty->assign('THENME',$theme);
$smarty->assign('MODE',$mode);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('APP',$app_strings);
// require_once('SetmenuControl.php');
//edit:chj,date:2020-07-10,respon:系统设置->其他设置->数据库备份：点击【编辑】,缺少标题
$arr['title'] = getFixedLabel("EDIT");
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//数据库备份帮助
$labels = array('BackupSettings');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('BackupSettings.tpl');
ConvertTojsonString(1,$arr,"success");

/**
 * 实现数据库自动备份功能
 * 修改编码格式:统一编码：UTF-8
 * @project PROT123 自动备份
 * @author Tujt 2014-10-28
 */
class BackUpLib {
	const WINDOWBAT = 'backup.bat';//常量，批处理文件名
	const LINUXSH = 'backup.sh';//常量，shell文件名
	const FILEPATH = 'dataCache/cron';//window 批处理文件、linux shell脚本 存放地
	const LINUXBACK = 'backup';//linux系统下，备份路径为dataCache/linuxbackuo目录下
	private static $os = '';//操作系统
	private static $admin = '';//系统根目录
	private static $root = '';//mysql目录
	private static $port = '';//数据库端口号
	private static $host = '';//mysql地址
	private static $user = '';//用户名
	private static $pwd = '';//用户密码
	private static $db = '';//数据库名
	private static $every = '';//执行周期
	private static $time = '';//执行时间
	private static $backuppath = '';//数据库备份路径
	private static $delbackup = '';//删除备份数据周期
	private static $dbtype = '';//数据库类型
	private static $backupfile = 'dbbackup';//备份文件名
	private static $backupprogress = 'ldcrmbackup';
	/**
	 * 构造函数
	 * @author Tujt 2014-10-28
	 */
	public function __construct($backupparam) {
		self::$admin = $backupparam['admin'];
		self::$port = $backupparam['dbconfig']['db_port'];
		self::$host = $backupparam['dbconfig']['db_server'];
		self::$user = $backupparam['dbconfig']['db_username'];
		self::$pwd = $backupparam['dbconfig']['db_password'];
		self::$db = $backupparam['dbconfig']['db_name'];
		self::$every = $backupparam['every'];
		self::$time = sprintf('%02d',$backupparam['hours']).':'.sprintf('%02d',$backupparam['minute']);
		self::$backuppath = $backupparam['backuppath'];
		self::$delbackup = $backupparam['delbackup'];
		self::$dbtype = $backupparam['dbconfig']['db_type'];
		self::checkOs();//判断系统所布置的操作系统
		self::checkMysqlPath();//获得当前mysql数据库bin目录地址


		$cachekey = 'cache_delete_backup_backuppath';
		MemoryCache($cachekey,self::$backuppath);
	}
	/**
	 * 判断系统布置的操作系统
	 * @author Tujt 2014-10-28
	 */
	public static function checkOs($admin = '') {
		if(empty($admin)) $admin = self::$admin;
		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
			self::$os = 'linux';
		}else{
			self::$os = 'window';
		}

		return self::$os;
	}
	/**
	 * 获得当前系统mysql数据库地址
	 * @author Tujt 2014-10-28
	 */
	private static function checkMysqlPath() {
	    global $adb;
		if(self::$host != 'localhost'){//远程
			if(stripos(self::$admin,'wamp') > -1){//wamp
				$mysqlbin = explode('wamp',self::$admin);
				self::$root = $mysqlbin[0].'wamp\mysql\bin';
			}else if(stripos(self::$admin,'xampp') > -1){//xampp
				$mysqlbin = explode('xampp',self::$admin);
				self::$root = $mysqlbin[0].'xampp\mysql\bin';
			}
		}else{//备份本地数据库，直接查询当前数据库地址
			$result = $adb->query('SHOW VARIABLES LIKE "basedir"');
			$value = $result->fields['Value'];
            $value = rtrim($value, '/').'/';
			self::$root = $value.'bin';
		}
	}
	/**
	 * 执行备份语句
	 * @author Tujt 2014-10-28
	 */
	public static function backup() {
	    if(empty(self::$os)) return false;
		if(empty(self::$root)) return false;

		if(strtolower(self::$dbtype) == 'mysqli'){//mysql 自动备份
			switch(self::$os){
				case 'window':
					self::window_backup();
					break;
				case 'linux':
					self::lunux_backup();
					break;
			}
		}
	}
	/**
	 * window系统实现定时备份
	 * @author Tujt 2014-10-28
	 */
	static function window_backup() {
	    $path = self::$admin.self::FILEPATH;
		//1、创建文件夹
		self::createdir($path);
		self::createdir(self::$backuppath);
		//2、组装批处理语句(注意空格)
		$hostcron = '';
		if(self::$host != 'localhost')
			$hostcron = ' -h'.self::$host.'';//localhost为默认，可不填写
		$portcron = '';
        
		if(!empty(self::$port) && self::$port != ':3306'){
			$portstr = substr(self::$port,1,strlen(self::$port));
			$portcron = '-P'.$portstr.' ';
		}
		$pwdcron = '';
		if(!empty(self::$pwd))
			$pwdcron = '-p'.self::$pwd.' ';//密码为空则不添加-p
        self::$backuppath = rtrim(self::$backuppath, '/').'/';
		$cron = '@echo on
'.self::$admin[0] .':
cd '.self::$root.'
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set filename='.self::$backupfile.'_%year%%month%%day%.sql
mysqldump.exe --default-character-set=utf8'.$hostcron.' '.$portcron.'-u'.self::$user.' '.$pwdcron.' --set-gtid-purged=off --opt -R -E '.self::$db.' > "'.self::$backuppath.'%filename%"
mysql.exe '.$hostcron.' '.$portcron.' -u'.self::$user.' '.$pwdcron.' '.self::$db.' -e  "insert into ld_backup_file(filename,backuptime,backuptype,operator) values(\'%filename%\',now(),2,\'\');"
@echo off';
		if (!file_exists($path.'/'.self::WINDOWBAT)){//批处理文件不存在，创建
			touch($path.'/'.self::WINDOWBAT);
		}
		$fh = fopen($path.'/'.self::WINDOWBAT,'w');
		fputs($fh,$cron);
		fclose($fh);
		
		//执行at命令添加定时任务
		//editor:gyqX160801 Bug:0023816
		self::deleteAt();//如果定时任务存在，则删除
		if(self::$every == 'day'){
			$frequency = ' daily ';
			$schtasks = 'schtasks /create /tn "'.self::$backupprogress.'" /tr "'.$path.'/'.self::WINDOWBAT.'" /sc '.$frequency.' /st '.self::$time.'';
			//echo $schtasks; die;
            exec($schtasks);
		}else{
			$weekarr = array('MON','THU','WED','THU','FRI','SAT','SUN');
			$intervalarr = explode(':',self::$every);
			if($intervalarr[0] == 'week'){//每周执行一次
				//schtasks /create /tn "My App" /tr c:\apps\myapp.exe /sc weekly /d WED
				$frequency = ' weekly /d %s ';
				$at = 'schtasks /create /tn "'.self::$backupprogress.'" /tr "'.$path.'/'.self::WINDOWBAT.'" /sc '.$frequency.' /st '.self::$time.'';
				exec(sprintf($at,$weekarr[$intervalarr[1]-1]));
			}else{//每月执行一次
				$frequency = ' monthly /d %s ';
				$at = 'schtasks /create /tn "'.self::$backupprogress.'" /tr "'.$path.'/'.self::WINDOWBAT.'" /sc '.$frequency.' /st '.self::$time.'';
				exec(sprintf($at,$intervalarr[1]));
			}
		}

		//$at = 'at '.self::$time.' /every:%s "'.$path.'/'.self::WINDOWBAT.'"';
		/*if(self::$every == 'day'){//每天执行
			exec($at);
			//exec(sprintf($at,'m,t,w,th,f,s,su'),$rest);
		}else{
			$intervalarr = explode(':',self::$every);
			if($intervalarr[0] == 'week'){//每周执行一次
				$weekarr = array('m','t','w','th','f','s','su');
				exec(sprintf($at,$weekarr[$intervalarr[1]-1]),$rest);
			}else{//每月执行一次
				exec(sprintf($at,$intervalarr[1]),$rest);
			}
		}*/
		/*$rest = explode('ID =',$rest[0]);
		$at_cron_id = trim($rest[1]);//获取定时任务ID
		MemoryCache($cachekey,$at_cron_id);*/
		////删除定时任务
		//$r_a = explode('mysql',self::$root);
		//$phpbin = $r_a[0].'php\php.exe';
		
		//$cachekey = 'backupmysql_delete_file';
		//$at_delete_id = MemoryCache($cachekey);
		//if($at_delete_id > 0){
			//exec('at '.$at_delete_id.' /Delete',$rest1);
		//}
		//$t = strtotime(self::$time);
		//$t = $t - 5 * 50;
		//$time = date('H:i',$t);
		//if(self::$admin{strlen(self::$admin)-1} != '/')
			//self::$admin .= '/';
		//$at = 'at '.$time.' /every:m,t,w,th,f,s,su '.$phpbin.' "'.self::$admin.'DeleteAt.php"';
		//exec($at,$rest);
		//$at_delete_id = self::getWindAtID($rest);//获取定时任务ID
		//MemoryCache($cachekey,$at_delete_id);
		self::deleteBackup();//删除规定周期内的备份数据
	}
	/**
	 * 删除定时任务
	 * @author Tujt 2014-11-14
	 */
	public static function deleteAt() {
		if(self::$os == 'window'){
			self::$backupprogress =  trim(preg_replace('/[^\w]+/','',globalStatic::$root_directory)).'_'.self::$backupprogress;
			exec('schtasks /delete /tn "'.self::$backupprogress.'" /F');
			/*$at_cron_id = MemoryCache($cachekey);
			if($at_cron_id > 0){
				exec('schtasks '.$at_cron_id.' /Delete',$rest);
			}*/
			//return $cachekey;
		}
	}
	/**
	 * 传入at命令返回值，提取出当前at定时任务ID
	 * @param Array $rest at命令执行返回值
	 * @return Integer $at_id at命令ID
	 * @author Tujt 2014-11-10
	 */
	public static function getWindAtID($rest) {
		$at_id = 0;
	    foreach($rest as $r){
			if(empty($r)) continue;
			$rr = explode('ID =',$r);
			if(count($rr) > 1){
				$at_id = $rr[1];
				break;
			}
		}
		return $at_id;
	}
	/**
	 * 删除规定周期内的备份数据
	 * @author Tujt 2014-10-27
	 */
	public static function deleteBackup() {
	    if(empty(self::$delbackup)) return false;
		$delbackday = explode('beforedays_',self::$delbackup);
		$delbackday = $delbackday[1];
		$cachepath = self::$backuppath;
		chmod($cachepath, 0777);
		$folder = @opendir($cachepath);
		if ($folder == false) return;
		$count = 0;
		$isfile = array('.'=>'1','..'=>'1','index.html'=>'1','index.htm'=>'1');
		$backdate = '';$nowdate = date('Y-m-d',time());$countday = '';
		$fieldlen = strlen(self::$backupfile)+1;
		while(false !== ($file = readdir($folder))){
			if(isset($isfile[$file])) continue;//不可删除
			if(is_file($cachepath.$file)){
				$filearr = explode('.',$file);
				if(count($filearr) != 2 || $filearr[1] != 'sql') continue;//必须是sql类型
				$filearr = explode('_',$filearr[0]);
				if(count($filearr) != 2 || $filearr[0] != self::$backupfile) continue;//格式不标准
				$backdate = $filearr[1];
				$countday = self::count_days($backdate,$nowdate);
				if($countday > 0 && $countday > $delbackday){//相差天数大于设置天数，则删除
					chmod($cachepath.$file, 0777);
					if (@unlink($cachepath.$file)) ++$count;
				}
			}
		}
		closedir($folder);

	}
	/**
	 * 计算两个时间相差天数
	 * @author Tujt 2014-10-27
	 */
	public static function count_days($date1,$date2) {
		$d1 = strtotime($date1);
		$d2 = strtotime($date2);
		$days = round(($d2-$d1)/3600/24);
		return $days;
	}
	/*  -- Linux备份 --  */
	/**
	 * linux系统备份
	 * @author Tujt 2014-10-28
	 */
	private static function lunux_backup() {
		return false;//暂时不做linux的自动备份
		$path = self::$admin.self::FILEPATH;
	    //1、创建文件夹
		self::createdir($path);
		self::createdir(self::$backuppath);
		//2、组装shell文件
		$hostcron = '';
		if(self::$host != 'localhost')
			$hostcron = ' -h'.self::$host.'';//localhost为默认，可不填写
		$portcron = '';
		if(self::$port != ':3306'){
			$portstr = substr(self::$port,1,strlen(self::$port));
			$portcron = '-P'.$portstr.' ';
		}
		$pwdcron = '';
		if(!empty(self::$pwd))
			$pwdcron = '-p'.self::$pwd.' ';//密码为空则不添加-p
        self::$backuppath = rtrim(self::$backuppath,'/').'/';
		$cron = 'Now=$(date +"%Y%m%d")
mysqldump --opt'.$hostcron.' '.$portcron.'-u'.self::$user.' '.$pwdcron.' --set-gtid-purged=off --opt -R -E '.self::$db.' > '.self::$backuppath.'dbbackup_$Now.sql';
		//$cron = '#!/bin/sh
//# File: /home/mysql/backup.sh
//# Database info
//DB_NAME="'.self::$db.'"
//DB_USER="'.self::$user.'"
//# Others vars
//BIN_DIR="'.self::$root.'"
//BCK_DIR="'.self::$backuppath.'"
//BACKUP_FILE = "'.self::$backupfile.'_"$(date + %y%m%d)".sql"
//# TODO
//$BIN_DIR/mysqldump --opt'.$hostcron.' '.$portcron.'-u$DB_USER '.$pwdcron.'-R $DB_NAME > $BCK_DIR/$BACKUP_FILE';

		if (!file_exists($path.'/'.self::LINUXSH)){//shell文件不存在，创建
			touch($path.'/'.self::LINUXSH);
		}
		$fh = fopen($path.'/'.self::LINUXSH,'w');
		fputs($fh,$cron);
		fclose($fh);
		//执行crontab命令添加定时任务
		$sendtime = self::$time;
		$sendtime = explode(':',$sendtime);
		$command = ''.$sendtime[1].' '.$sendtime[0].' %s %s %s '.$path.'/'.self::LINUXSH.' ';
		$crontab = '';
		if(self::$every == 'day'){//每天执行
			$crontab = sprintf($command,'*','*','*');
		}else{
			$intervalarr = explode(':',self::$every);
			if($intervalarr[0] == 'week'){//每周执行一次
				$sendweek = $intervalarr[1];
				if($sendweek == 7) $sendweek = 0;
				$crontab = sprintf($command,'*','*',$sendweek);
			}else{
				$crontab = sprintf($command,$intervalarr[1],'*','*');
			}
		}
		if(!empty($crontab)){
			exec('crontab -e',$rest);
			exec($crontab,$rest);
			//如果原来的发布时间为空，只需要添加新命令
		   //$f = popen("crontab -e","w");
		   //fputs($f,"i");
		   //fputs($f,$crontab);
		   //fputs($f,"\n");
		   //fputs($f,chr(27));
		   //fputs($f,":wq\r");
		   //pclose($f);
		}

		////执行at命令添加定时任务
		//$cachekey = self::deleteAt();//如果定时任务存在，则删除
		//$at = 'at '.self::$time.' /every:%s "'.$path.'/'.self::WINDOWBAT.'"';
		//if(self::$every == 'day'){//每天执行
			//exec(sprintf($at,'m,t,w,th,f,s,su'),$rest);
		//}else{
			//$intervalarr = explode(':',self::$every);
			//if($intervalarr[0] == 'week'){//每周执行一次
				//$weekarr = array('m','t','w','th','f','s','su');
				//exec(sprintf($at,$weekarr[$intervalarr[1]-1]),$rest);
			//}else{//每月执行一次
				//exec(sprintf($at,$intervalarr[1]),$rest);
			//}
		//}
		//$rest = explode('ID =',$rest[1]);
		//$at_cron_id = trim($rest[1]);//获取定时任务ID
		//MemoryCache($cachekey,$at_cron_id);

		//self::deleteBackup();//删除规定周期内的备份数据
	}
    /**
	 * 如果文件夹不存在，则递归创建文件夹
	 * @param String $path 目录
	 * @author Tujt 2014-10-28
	 */
	public static function createdir($path){
		if (!file_exists($path)){
			self::createdir(dirname($path));//递归创建文件夹
			if(self::$os == 'window'){
				mkdir(iconv('utf-8', 'gbk', $path));
			}else{
				mkdir(path, 0777);
			}
		}
	}
}
?>