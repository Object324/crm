<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-17
 */
class Logic {//数据库操作核心逻辑层
	public $language = '';//当前语言状态
	public $modstatic;//模块静态类对象
	public $controller;//模块控制类对象
	public  $db;//数据库连接对象
    /**
     * 构造函数
     * @author Tujt 2015-06-17
     */
    public function __construct() {
    	$this->init();
    }
	/**
     * 初始化类参数
     * @author Tujt 2015-06-13
     */
    public function init(){
    	//1、初始化当前语言状态
    	if(empty($this->language)){
    		global $languageType;
    		if(empty($languageType)){
    			global $current_user;
               // if(file_exists(globalStatic::$root_directory.'./user_privileges/user_language_'.$current_user->id.'.php'))
    		//	require(globalStatic::$root_directory.'./user_privileges/user_language_'.$current_user->id.'.php');
                    $languageType=getLanguageType($current_user);
    		}
    		if(empty($languageType)) $languageType = 'zh';//默认中文
    		$this->language = $languageType;
    	}
		//2、初始化数据库
		if(empty($this->db)){
			global $adb;
            $this->db = $adb;
		}
    }
	/**
	 * 单例初始化模块static类对象
	 * @author Tujt 2015-05-28
	 */
	public function getModuleStatic($module){
		return $this->modstatic = $this->controller->getModuleStatic($module);
	}
	/**
	 * 获取当前模块关联创建结果集
	 * @param Integer $tabid
	 * @author Tujt 2015-06-17

	public function getQuickActionsInfo($tabid) {
	    $cachekey = 'cache_getQuickActionsInfo'.$tabid;
		$quickactionarr = Cache($cachekey);
		if(!$quickactionarr){
			$quickactionarr = array();
			 $arr_special = array('-1'=>'View History',//修改日志
                                '-10'=>'Change_assigned_user',//负责人变更
								'-2'=>'THELOWCONTACT',//创建下级联系人
								'-3'=>'THELOWLEVELCONTRACTS',//查看上下级联系人
								'-4'=>'LBL_SHOW_ACCOUNT_HIERARCHY',//查看上下级客户
								'-5'=>'PRINT',//打印工具
								'-6'=>'DOWNLOADFILE',//下载附件
								'-7'=>'CHECKATTACHMENTINTEGRITY',//检查附件完整性
								'-8'=>'SENTEMAILATTACHMENTS',//把附件作为电子邮件附件发送
								'-9'=>'Send_SMS',//发送短信
                                '-11'=>'VIEWADDJOBBILLHISTORY'
                                );
			$query = 'SELECT related_tabid FROM ld_quickactions WHERE tabid = ? 
						AND presence = 0 AND relation_id > 0 and related_tabid not in (select tabid from ld_tab where presence=1) ORDER BY sequence;';
			$result = $this->db->pquery($query,array($tabid));
			$nums = $this->db->num_rows($result);
			if($nums > 0){
				for($i=0;$i<$nums;$i++){
				    $related_tabid = $this->db->query_result($result,$i,'related_tabid');
					if(isset($arr_special[$related_tabid])){
						$modulename = $arr_special[$related_tabid];
					}else{
						$modulename = getTabname($related_tabid);
					}
					$quickactionarr[$related_tabid] = $modulename;
				}
				Cache($cachekey,$quickactionarr);
			}
		}

		return $quickactionarr;
	}
     * 	 */
	/**
	 * 获取模块下某字段的值
	 * @author Tujt 2015-06-29
	 */
	public function getTableFldInfo($module,$record,$field) {
		$entityarr = getEntitynameInfo(getTabid($module));
	    $query = 'select '.$field.' as fldval from '.$entityarr['tablename'].' where 
					'.$entityarr['entityidfield'].' = '.$record.' limit 1;';
		$result = $this->db->query($query);
		$rows = $this->db->num_rows($result);
		$fldval = '';
		if($rows > 0) $fldval = $this->db->query_result($result,0,'fldval');
		return $fldval;
	}
	/**
	 * 获取知识管理对应的附件ID
	 * @author Tujt 2015-06-29
	 */
	public function getDocumentAttachmentId($record) {
	    $query = 'select attachmentsid from ld_seattachmentsrel where crmid = ? ';
		$result = $this->db->pquery($query,array($record));
		$rows = $this->db->num_rows($result);
		$fileId = 0;
		if($rows > 0) $fileId = $this->db->query_result($result,0,'attachmentsid');
		return $fileId;
	}
	/**
	 * 析构函数
	 * @author Tujt 2015-06-17
	 */
	public function __destruct() {
	    
	}
}
?>