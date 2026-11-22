<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-14
 */
include './modules/Settings/AutoTaskQueryLogic.class.php';
include './modules/Settings/AutoTaskProductLogic.class.php';
include './modules/Settings/AutoTaskModel.class.php';
require_once('./include/utils/CacheInfo.php');
require_once('./include/TemplatePrint/TemplatePrint.php');
//控制层，初始化自动任务所需要的query
class AutoTaskController {
	private $autoquery;//分类处理对象
	private $module;//模块名
	private $tabid;//模块ID
	private $entityname;//模块entityname表对象
	private $autoid;//自动任务ID
	private $autotask;//数据层类对象
	private $meta;//模块对应初始化数据对象
	private $module_idx;//模块分类判断标识（是否有产品模块）
	private $moduleinit;//确保模块未重复加载
	public function __construct(){
		$this->autotask = new AutoTaskModel();//初始化数据层类对象
	}
	/**
	 * 加载事件，加载aotuquery逻辑层处理类，以及数据层处理类
	 * @author Tujt 2015-01-15
	 */
	public function init($module,$autoid) {
		global $adb,$current_user;
		if(empty($this->moduleinit) || !isset($this->moduleinit[$module]))
			$this->setModule($module);//防止模块重复加载
	    
			$this->meta[$this->module] = self::autotaskMeta($this->module);
		//分类判断，初始化不同的逻辑类处理对象
		if(1 == $this->module_idx){//有产品模块
			$this->autoquery = new AutoTaskProductLogic($this->autotask,
										$current_user,$this->meta,$this->module);
		}else{//普通模块
			$this->autoquery = new AutoTaskQueryLogic($this->autotask,
										$current_user,$this->meta,$this->module);
		}
	}
	/**
	 * 初始化模块（方便切换模块）
	 * @author Tujt 2015-01-15
	 */
	public function setModule($module) {
	    $this->module = $module;
		$this->tabid = getTabid($this->module);//获取tabid
		$this->entityname = getEntitynameInfo($this->tabid);//获取entityname对象
		if(get_file_address($this->module,'ProductDetails')){//首先判断当前模块是否为由产品模块
			$this->module_idx = 1;
		}else{
			$this->module_idx = 0;
		}
	}
	/**
	 * 提供一个修改autoid的方法，方便批量操作时不需要重复初始化本类
	 * @author Tujt 2015-01-15
	 */
	public function setAutoId($autoid) {
	    $this->autotask->setAutoId($autoid);
	}
	/**
	 * 获取Query信息
	 * @project PROT145 自动任务
	 * @author Tujt 2015-01-14
	 */
	public function getQuery() {
	    return $this->autoquery->getQuery();
	}
	/**
	 * 执行自动任务
	 * @author Tujt 2015-01-15
	 */
	public function SendAutoTask($module,$autoid) {
		global $adb;
		$this->autoid = $autoid;
		$this->setAutoId($autoid);
		self::updateExecution($this->autoid,1);//修改执行中状态，该自动任务禁删、禁改，直到执行结束
		$queryfilter = $this->autotask->getAutoTackQuery();
		if(!empty($queryfilter)){//SQL脚本执行
			self::ExecAutoTaskQuery($queryfilter);
			self::updateExecution($this->autoid);//修改为未执行状态
			return true;//不走下面的逻辑
		}
		$this->init($module,$autoid);
		$entityname = $this->entityname;//模块的entityname对象
		$tabname = $entityname['tablename'];
		$tabindex = $entityname['entityidfield'];
		if(empty($tabname)) $tabname = 'ld_'.strtolower($fld_module);
		if(empty($tabindex)) $tabname = strtolower($fld_module).'id';
		$query = $this->getQuery();//获取当前模块对应查询条件sql语句
       
		//获取当前条件的影响行数，确定是否大数据处理模式
		$countquery = 'SELECT count('.$tabname.'.'.$tabindex.') as count '.$query;
		$countresult = $adb->pquery($countquery,array());
       
		$count = $adb->query_result($countresult,0,'count');//获取影响行数
		$autotackfilter = $this->autotask->getAutoTackFilterInfo();//获取定制任务结果集
		$time = date('Y-m-d H:i:s',time());//修改时间，所有影响单据的修改时间，做重复执行判断
		$query = 'SELECT '.$tabname.'.'.$tabindex.' as crmid '.$query.' ';
		$query .= 'and '.$tabname.'.modifiedtime != "'.$time.'" ';//执行过的单据不再执行第二次
		$obj['time'] = $time;$obj['tabname'] = $tabname;$obj['tabindex'] = $tabindex;
		if($count < 500){//少于500条，普通执行
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
		}else if($count < 3000){//大于500，小于300，分奇偶数修改
			$query .= ' and '.$tabname.'.'.$tabindex.'%2 = 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
			$query .= ' and '.$tabname.'.'.$tabindex.'%2 != 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
		}else{//大于3000条，大数据处理，分五次获取数据，防止一次获取、修改数据过多，造成堵塞
			$query .= ' and '.$tabname.'.'.$tabindex.'%5 = 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
			$query .= ' and '.$tabname.'.'.$tabindex.'%4 = 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
			$query .= ' and '.$tabname.'.'.$tabindex.'%3 = 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
			$query .= ' and '.$tabname.'.'.$tabindex.'%2 = 0 ';
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
			$query .= ' and '.$tabname.'.'.$tabindex.'%2 != 0 ';//非奇即偶，没有例外
			self::setAutoTaskUpdate($this->module,$query,$autotackfilter,$obj);
		}
		self::updateExecution($this->autoid);//修改为未执行状态
	}
	/**
	 * 执行修改操作
	 * @author Tujt 2015-01-15
	 */
	public static function setAutoTaskUpdate($module,$query,$autotackfilter,$obj) {
		global $adb;
		if(!empty($autotackfilter)){
			$focus = CRMentity::getInstance($module);//单例初始化模块对象结果集
			$updatearr = array();
			foreach($autotackfilter as $autotask){//循环自动任务对应的定职任务到结果集中
				$updatearr[strtolower($autotask['tablename'])] .= $autotask['columnname'].'="'.$autotask['value'].'",';
			}
			$updatearr[strtolower($focus->table_name)] .= 'modifiedtime="'.$obj['time'].'",';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			$tablearray = array('ld_contactdetails'=>'1','ld_contactscf'=>'1');
			if($rows > 0){
				$tablename = strtolower($obj['tabname']);
				if('Accounts' == $module){//客户模块特别判断
					for($i=0;$i<$rows;++ $i){//循环单据，获取单据ID
						$crmid = $adb->query_result($result,$i,'crmid');
						$focus->id = $crmid;
						foreach($updatearr as $update_tab=>$updatesql){
							if(!isset($tablearray[$update_tab])){//普通情况下
								$update = 'update '.$update_tab.' set '.trim($updatesql,',').' where '.$obj['tabindex'].' = '.$crmid.' ';
							}else{//客户的首要联系人
								if('ld_contactdetails' == $update_tab){//联系人表，直接修改
									$update = 'update ld_contactdetails set '.trim($updatesql,',').' where accountid = '.$crmid.' and reference = 1; ';
								}else{//联系人自定义表，关联联系人表修改
									$update = 'update ld_contactscf inner join ld_contactdetails on ld_contactdetails.contactid = ld_contactscf.contactid set '.trim($updatesql,',').' where ld_contactdetails.accountid = '.$crmid.' and ld_contactdetails.reference = 1; ';
								}
							}
							if(method_exists($focus,'_before_autotask_save')){//自动执行 前置方法
								$focus->_before_autotask_save($module,$crmid,$autotackfilter);
							}
							$adb->pquery($update,array());//修改
							if(method_exists($focus,'_after_autotask_save')){//自动执行 后置方法
								$focus->_after_autotask_save($module,$crmid,$autotackfilter);
							}
						}
					}
				}else{//其他模块
					for($i=0;$i<$rows;++ $i){//循环单据，获取单据ID
						$crmid = $adb->query_result($result,$i,'crmid');
						$focus->id = $crmid;
						foreach($updatearr as $update_tab=>$updatesql){
							$update = 'update '.$update_tab.' set '.trim($updatesql,',').' where '.$obj['tabindex'].' = '.$crmid.' ';
							if(method_exists($focus,'_before_autotask_save')){//自动执行 前置方法
								$focus->_before_autotask_save($module,$crmid,$autotackfilter);
							}
							$adb->pquery($update,array());//修改
							if(method_exists($focus,'_after_autotask_save')){//自动执行 后置方法
								$focus->_after_autotask_save($module,$crmid,$autotackfilter);
							}
						}
					}
				}
			}
		}
	}
	/**
	 * 执行自动任务SQL
	 * @author Tujt 2015-01-16
	 */
	public static function ExecAutoTaskQuery($query) {
	    global $adb;
		//$query = strtolower($query);
		if(stripos($query,'DELIMITER') > -1){
			$query = str_replace("DELIMITER", "delimiter", $query);
		}
		//存储过程执行
		if(stripos($query,'||') > -1){
			$queryarr = explode('||',$query);
			foreach($queryarr as $q){
				self::setQuery($q);
			}
		}else if(stripos($query,'$$') > -1){
			$queryarr = explode('$$',$query);
			foreach($queryarr as $q){
				self::setQuery($q);
			}
		}else{
			self::setQuery($query);
		}
	}

	/**
	 * @author Tujt 2015-02-04
	 */
	public static function setQuery($query) {
		global $adb;
		$query = trim($query);
		if(stripos($query,'DELIMITER') > -1){
			$query = str_replace("DELIMITER", "delimiter", $query);
		}
		if(stripos($query,'delimiter;') > -1){
			$queryarr = explode('delimiter;',$query);
			foreach($queryarr as $q){
				$q = trim($q);
				if(!empty($q))
					self::setQuery($q);
			}
		}else if(stripos($query,'delimiter') > -1){
			$queryarr = explode('delimiter',$query);
			foreach($queryarr as $q){
				$q = trim($q);
			   if(stripos($q,'BEGIN')!=false)
                {
                    self::setQuery($q);
                    continue;
                }
                $sqls=explode(';',$q);
			    foreach($sqls as $sql)
    			{
    			 	if(!empty($sql))
    					self::setQuery($sql);
    			}
			}
		}else if(!empty($query)){
			$adb->pquery($query);
		}
	}
	/**
	 * 自动执行自动任务
	 * @author Tujt 2015-01-16
	 */
	public function AllSendAutoTask() {
	    global $adb;
		$autotaskinfo = $this->autotask->getAutoTaskInfo();
		if(isset($autotaskinfo['query']) && !empty($autotaskinfo['query'])){
			foreach($autotaskinfo['query'] as $autotaskid=>$module){//有sql执行格式
				$this->SendAutoTask($module,$autotaskid);//执行
			}
		}
		//把SQL和非SQL分开执行，防止一次执行过多
		if(isset($autotaskinfo['filter']) && !empty($autotaskinfo['filter'])){
			foreach($autotaskinfo['filter'] as $autotaskid=>$module){
				$this->SendAutoTask($module,$autotaskid);
			}
		}
	}
	/**
	 * 修改自动任务执行状态
	 * @author Tujt 2015-01-15
	 */
	public static function updateExecution($autoid,$execution = 0) {
	    global $adb;
		$update = 'update ld_autotask set execution = '.$execution.' where autotaskid = ? ';
		$adb->pquery($update,array($autoid));
	}
	/**
	 * 获取$meta对象
	 * @project PROT145 自动任务
	 * @author Tujt 2015-01-14
	 */
	public static function autotaskMeta($module) {
	    global $current_user,$adb;
        
		$fieldobj=Field::getInstance($module,$adb);
		return $fieldobj;
	}
}
?>