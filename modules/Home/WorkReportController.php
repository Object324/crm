<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-02-02
 */
class WorkReportController {
    public $model;
	/**
	 * 构造函数
	 * @author Tujt 2015-02-02
	 */
	public function __construct() {
	    require globalStatic::$root_directory.'modules/Home/WorkReportModel.php';
		$this->model = new WorkReportModel();
	}

	/**
	 * 获取用户所有数据
	 * @author Tujt 2015-02-02
	 */
	public function getUsers() {
		$users_combo = $this->model->getUserInfo();
		$groupuser = $this->model->getGroupUserInfo();
	    return array('Colleague'=>$users_combo,'Department'=>$groupuser);
	}

	/**
	 * 保存日志,微博，任务
	 * @author Tujt 2015-02-04
     * edit:can 2015-03-18
	 */
	public function saveSendLog() {
		$this->model->save();//保存日志
		return true;
	}
    /**
     * @author Tujt 2015-02-09
     */
    public function savereader() {
        $this->model->savereader();
        return '';
    }

    /**
     * edit:can
     * reason:点赞保存
     * */
    public function savepraise()
    {
       $count= $this->model->savePraise();//保存日志
       return  $count;
    }
    
    /**
     * edit:can
     * reason:列表获取
     * */
    public function getList()
    {
        $list=$this->model->getList();
        return $list;
    }    
    /**
     * edit:can
     * reason:创建点评弹出层
     * */
    public function createreaderPop()
    {
         $list=$this->model->createreaderPop();
        return $list;
    }
    public function getPreviousReport()
    {
        $workreportid = $_REQUEST['workreportid'];
        $list=$this->model->getPreviousReport($workreportid);
        return $list;
    }
    public function getChangeLog()
    {
        $workreportid = $_REQUEST['workreportid'];
        $list=$this->model->getChangeLog($workreportid);
        return $list;
    }
    public function getApproveStatus(){
        $workreportid= $_REQUEST['workreportid'];
        $prevapproved=$_REQUEST['prevapproved'];
        if($prevapproved == 0){
            $approvedmsg = $this->model->getApproveStatus($workreportid,$prevapproved);
            return $approvedmsg;
        } else{
            return "";
        }
    }
    /**
     * edit:diony
     * reason:创建转发弹出框
     * */
    public function createforwardPop()
    {
        $list=$this->model->createforwardPop();
        return $list;
    }

    
     /**
     * edit:can
     * reason:获取报告的相关用户列表
     * */
    public function getReportUserList()
    {
        $list=$this->model->getReportUserList();
        return $list;
    }
    
    /**
     * edit:diony
     * reason:获取即将新增加的相关用户列表
     * */
    public function getNewReportUserList()
    {
        $list=$this->model->getNewReportUserList();
        return $list;
    }

	/**
	 * 获得回复列表
	 * @author Tujt 2015-02-06
	 */
	public function getReplyList() {
	    $replylist = $this->model->getReplyList();
        return $replylist;
	}
    /**
	 * 获得点赞列表
	 * @author diony 2016-04-19
	 */
	public function getPraiseList() {
	    $praiselist = $this->model->getPraiseList();
        return $praiselist;
	}

	/**
	 * 获取关键回复
	 * @author Tujt 2015-02-09
	 */
	public function getKeyReply() {
	    $workreportid = $_REQUEST['workreportid'];
		$keyreport = $this->model->getKeyReply($workreportid);
		return $keyreport;
	}
	/**
	 * 删除工作报告
	 * @author Tujt 2015-02-10
	 */
	public function DeleteReport() {
		return $this->model->DeleteReport();
	}
    /**
	 * 检查取消是否需要显示
	 * @author diony 2015-03-27
	 */
	public function checkMore() {
	    $workreportid = $_REQUEST['workreportid'];
	    return $this->model->checkMore($workreportid);
	}
	/**
	 * 获取当前用户最近一次发送微博、日志、任务的抄送范围
	 * @author chj 2016-10-19
	 */
	public function getLatelyScope() {
	    $cur_panel = $_REQUEST['cur_panel'];
	    $cur_panel_tag = $_REQUEST['cur_panel_tag'];
	    return $this->model->getLatelyScope($cur_panel,$cur_panel_tag);
	}

    /**以下函数已无使用 start
	 * 上传附件
	 * @author Tujt 2015-02-10
	 */
	public function Upload($module,$fields) {
	    global $adb,$current_users;
		//1、组装附件上传路径
		$targetFolder = $this->getUploadFilePath();
		//2、获取文件信息
		$tempFile = $_FILES['file']['tmp_name'];
		$fileTypes = array('bmp','csv','chm','chw','dat','dll','doc','docx','dot','dps','dpt','et','ett',
							'gif','html','iso','ini','js','jpg','jpeg','rar','php','pdf','png','ptf',
							'ppt','pptx','pot','pps','rtf','sql','txt','wps','wpt','xls','xlsx','xml',
							'xlt','zip','eml','msg','ico','x-icon');
		//替换空格
		$file_name = $_FILES['file']['name'];
		$file_name = str_replace(" ","_",$file_name);
		$fieldname = $this->getUploadFileName($file_name);
		$fileParts = pathinfo($fieldname);
		if (f_in_array(strtolower($fileParts['extension']),$fileTypes)) {    	
			if(move_uploaded_file($tempFile,$targetFolder.$fieldname)){ 
				$field['name'] = $file_name;
				$field['path'] = $targetFolder;
                $field['size'] = $_FILES['file']['size'];
				return $field;
			}else{
				return -1;//上传失败
			}
		}else{
			return -2;//扩展名无效
		}
	}
	/**
	 * 初始化上传附件的名称
	 * @author Tujt 2015-02-10
	 */
	public function getUploadFileName($file_name) {
		//拷贝的uploadify/uploadify.php的代码
		$arr = array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
		$encode = mb_detect_encoding($file_name, $arr); 
		if($encode == 'UTF-8'){
			$targetFile = iconv('UTF-8','gb2312',$file_name);
		}else{
			$targetFile = $file_name;
		}
		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
			$targetFile = $file_name;//获取系统类型，如果是非windows系统则不用修改编码格式
		}
		if(empty($targetFile)) $targetFile = $file_name;
		return $targetFile;
	}
	/**
	 * 获取上传路径
	 * @author Tujt 2015-02-10
	 */
	public function getUploadFilePath() {
	    $time = time();
		$fyear = date('Y',$time);
        $fmonth = date('F',$time);
        $fday = date('j',$time);//获取当前月份第几天
        $fweek = 'week'.ceil($fday/7);//获取当前日期所属月份的第几周
		if(!file_exists('storage/'.$fyear)){
             mkdir(globalStatic::$root_directory.'storage/'.$fyear,0777);
        }
        if(!file_exists(globalStatic::$root_directory.'storage/'.$fyear.'/'.$fmonth)){
             mkdir(globalStatic::$root_directory.'storage/'.$fyear.'/'.$fmonth,0777);
        }
        // ljj 2024-11-21 XUQIU20241113-07 week目录改成day目录
        if(!file_exists(globalStatic::$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday)){
             mkdir(globalStatic::$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday,0777);
        }
        $targetFolder = 'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		return $targetFolder;
	}
	/**
	 * 上传图片
	 * @author Tujt 2015-02-10
	 */
	public function uploadImage($module,$fields) {
	    global $adb,$current_users;
		//第一步，上传附件
		$field = $this->Upload($module,$fields);
		if(-1 == $field){//上传失败
			return -1;
		}else if(-2 == $field){
			return -2;
		}
		if(empty($field)) return -1;
		//存入数据库中
		//$record = $adb->getUniqueID('ld_workachments');
		$query = 'insert into ld_workachments(name,type,path) 
					values("'.$field['name'].'","image","'.$field['path'].'");';
		$adb->pquery($query,array());
		$field['record'] = $adb->getLastInsertID();
		return $field;
	}
    	/**
	 * 上传图片
	 * @author andrew 2015-05-26
	 */
	public function uploadAchment($module,$fields) {
	    global $adb,$current_users;
		//第一步，上传附件
		$field = $this->Upload($module,$fields);
		if(-1 == $field){//上传失败
			return -1;
		}else if(-2 == $field){
			return -2;
		}
		if(empty($field)) return -1;
		//存入数据库中
		//$record = $adb->getUniqueID('ld_workachments');
		$query = 'insert into ld_workachments(name,type,path,size) 
					values("'.$field['name'].'","att","'.$field['path'].'","'.$field['size'].'");';
		$adb->pquery($query,array());
		$field['record'] = $adb->getLastInsertID();
		return $field;
	}

    //以上函数已无使用    end
    /**
     * edit:can
     * reason:获取工作提醒相关数量
     * */
    public function getWorkReminds()
    {
        return $this->model->getWorkReminds();
    }

	/**
	 * 获取工作协同发日志设置的字段
	 * @project 工作协同模板
	 * @author Tujt 2015-05-06
	 */
	public function getWorkFieldInfo($entitytype,$type=0) {
	    $workfield = $this->model->getWorkFieldEntity($entitytype);
		if($type > 0 && isset($workfield[$type])){
			return $workfield[$type];
		}
		return $workfield;
	}
    public function editReport() {
        $result = $this->model->editReport($_REQUEST);
        return $result;
    }

    public function getWorkPrevFld($entitytype,$type,$prevreport) {
        $workfield = $this->model->getWorkPrevFld($entitytype,$type,$prevreport);
        return $workfield;
    }
    /**
     * edit:diony
     * reason:获取文档列表
     * */
    public function getDocumentList()
    {
        $list=$this->model->getDocumentList();
        return $list;
    }

	//获取工作汇报日志的销售简报
	public function getSendLog_SalesKit(){
		$sendlog_date = $_REQUEST['sendlog_date'];
		$list=$this->model->getSendLog_SalesKit($sendlog_date);
		return $list;
	}
	public function getSendLog_SalesKit_date(){
		$workreportid = $_REQUEST['workreportid'];
		$userid = $_REQUEST['userid'];
		$list=$this->model->getSendLog_SalesKit_date($workreportid,$userid);
		return $list;
	}
    public function getRelatedModuleField(){
        $reporttype=$_REQUEST['reporttype'];
        $value=$this->model->getRelatedModuleField($reporttype);
        return $value;
    }
	
}
?>