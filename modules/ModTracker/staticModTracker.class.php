<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-15
 */
 crm_load_function_file('getLineitemModuleInfo','include/Stock','CommonStock');
class staticModTracker{
	private static $module;//当前模块
	public  static $mode;//当前状态（新增、编辑、批量编辑、小编辑）
	private static $controller;//模块对应控制类结果集
	public  static $entitydata = array();//修改前的数据
	private $modulefield = array();//模块相关字段结果集
	private static $modtrackerId = array();
	private static $notrecordedfld = array(
					'creator'=>1,'createdtime'=>1,
					'modifiedby'=>1,'modifiedtime'=>1,
					'approvestatus'=>1,
					'promodifiedby'=>1,'promodifiedtime'=>1,
					'currency_symbol'=>1,'conversion_rate'=>1,
					'ServiceContractsmodifiedtime'=>1,
					'ServiceContractscreatedtime'=>1,
					'ServiceContractsmodifiedby'=>1,
					'ServiceContractscreator'=>1
				);
	public static $lastinsertid;
	protected $attachment_img_logs_arr = [];// 记录附件图片修改前后日志信息
	private $all_insertlogs_attachmentsid_arr = [];// 所有需要插入ld_attachments_history的附件id
	
	
    /**
     * 构造函数
     * @author Tujt 2015-06-15
     */
    function __construct() {
		
    }
	/**
	 * 初始化数据
	 * @author Tujt 2015-06-15
	 */
	public function init($controller,$module) {
		//1、字段日志初始化数据
		self::$controller[$module] = $controller;
	    self::$mode[$module] = 'create';
	    self::$module = $module;
       
	    if(self::$controller[$module]->id > 0){
	    	self::$mode[$module] = 'edit';//预留判断mass_edit 批量编辑、little_edit 小编辑
			$modarray = array('Calendar'=>'1','Events'=>'1');
			if (isset($modarray[$module]))
				$focus = new Activity();
			else
				$focus = new $module();
			$focus->retrieve_entity_info(self::$controller[$module]->id, $module);

			if ($module == 'Accounts')
				self::$controller[$module]->before_field_info = array();

            foreach(self::$controller[$module]->column_fields as $fieldname=>$value)
            {
                $fieldinfo=self::$controller[$module]->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname); 
                if($fieldinfo)   
                {
                    $fieldinfo->setColumn_Value($focus->column_fields[$fieldname]);
                    self::$controller[$module]->before_field_info[]=$fieldinfo;
                }        
            } 
			self::$controller[$module]->before_save_infos[]=$focus->column_fields;
			self::$entitydata[$module] = $focus->column_fields;//获取当前单据原来的数据
		}
        
		//2、字段公式
		self::saveFieldFormula();

		// 初始化图片附件日志
		$this->initAttachmentImgLogs();
	}
	/**
	 * 保存数据结束后记录字段日志
	 * @author Tujt 2015-06-15
	 */
	public function triggerEvent($module){
		//1、修改日志
		
		self::saveFieldUpdateLog($module,$this);
		
	}
	/**
	 * 模块的字段日志功能是否开启
	 * @author Tujt 2015-06-15
	 */
	public static  function getModTrackerTabs(){
		$cachekey = 'getmodtrackertabs';
		$trackertabs = Cache($cachekey);
		if(!$trackertabs){
			global $adb;
			$trackertabs = array();
			$query = 'SELECT tabid,visible FROM ld_modtracker_tabs ORDER BY tabid;';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			for ($i=0; $i < $rows; $i++) { 
				$tabid = $adb->query_result($result,$i,'tabid');
				$visible = $adb->query_result($result,$i,'visible');
				$trackertabs[$tabid] = $visible;
			}
			Cache($cachekey,$trackertabs);
		}
		return $trackertabs;
	}
	/**
	 * 保存字段修改日志
	 * @author Tujt 2015-06-15
	 */
	public static function saveFieldUpdateLog($module,$thisobj=null){
		global $adb,$current_user;
       
       
 		if('create' == self::$mode[$module]) return false;//创建单据时不记录字段日志
		$trackertabs = self::getModTrackerTabs();//获取模块字段日志是否开启数组
		$tabid = getTabid($module);
		if(!isset($trackertabs[$tabid]) || 0 == $trackertabs[$tabid]) 
			return false;//未开启字段日志
		$time = date('Y-m-d H:i:s',time());
		$status = 0;
		$crmid = self::$controller[$module]->id;
		//有可能在save_module中修改了数据，所以需要重新获取一下
       
		global  $reset_retrieve_entity_info;
		$reset_retrieve_entity_info='yes';
    
		self::$controller[$module]->retrieve_entity_info(self::$controller[$module]->id,$module);
        
        $reset_retrieve_entity_info='no';
		$entitydata = self::$entitydata[$module];
		$notShowModulecolumns['Users'] = array('time_zone','date_format','activity_view','lead_view',
			'language','theme','email2','start_hour','hour_format','scopeauthority',
			'reports_to_id','currency_id','email2','secondaryemail','phone_other','level','userlevel');
		if($module=="Users")
		{
            if(isPermitted("Users","AllowSetRoleDataProfile")=='no')
            {
                $notShowModulecolumns["Users"][]="profileid";
                $notShowModulecolumns["Users"][]="scopeauthority";
                $notShowModulecolumns['Users'][]='viewothers';
                $notShowModulecolumns['Users'][]='editothers';
                $notShowModulecolumns['Users'][]='delothers';
                $notShowModulecolumns['Users'][]='viewselfbills';
                $notShowModulecolumns['Users'][]='edit_other_mobile';
                $notShowModulecolumns['Users'][]='is_mobile_style';
                $notShowModulecolumns['Users'][]='select_servicedetail';
                $notShowModulecolumns['Users'][]='select_due_date';
                $notShowModulecolumns['Users'][]='accountallview';
                $notShowModulecolumns['Users'][]='trackgroupid';
                $notShowModulecolumns['Users'][]='edit_me_mobile';
            }
       	}
		
		foreach(self::$controller[$module]->column_fields as $key=>$value){
			//	editor:gyqX160812 Bug:0023807: 付款计划：编辑多选框字段的值由1,2,3为空，查看修改日志，显示格式不对
			$uitype = self::$controller[$module]->fieldobj->getFieldInfoBykeyValue('fieldname', $key, 'uitype');
			
			if(isset(self::$notrecordedfld[$key])) continue;

			if(empty($entitydata[$key]) && empty($value)) 
				continue;//修改前后都为空，不记录字段日志
            
            $displaytype=self::$controller[$module]->fieldobj->getFieldInfoBykeyValue('fieldname',$key,'displaytype');
            if($displaytype==2)//不能编辑的字段，不需要记录日志，如果记录日志请单独调用self::saveFieldLogOne
            {
                //27093: 入库单导入：以覆盖的方式导入系统中存在的单据，导入成功后再在单据明细界面编辑保存，查看修改日志，结果显示了多余的字段信息
                continue;
            }
			$fieldinfo= self::$controller[$module]->fieldobj->getFieldInfoobjBykey("fieldname",$key);
           //edit:can 20220124 049803: https://kehu001.com/weixin/kh46298/ [^])金动力：客户模块-客户名称-河南华穗食品有限公司-每编辑修改一次信息，动态就会显示分配服务收费人给李丹丹
            if(!$fieldinfo||$fieldinfo->getFieldName()=='')
                continue;
            $columnname=self::$controller[$module]->fieldobj->getFieldInfoBykeyValue("fieldname",$key,'columnname');
            if(array_key_exists($module,$notShowModulecolumns)&&in_array($columnname,$notShowModulecolumns[$module]))
            {
                continue;
            }
           
            if($uitype==33)
            {
                $value = str_replace('|##|',',',$value);
                $entitydata[$key] = str_replace('|##|',',',$entitydata[$key]);
            }
            //	editor:gyqX160812 Bug: 0023808: 付款计划：将“日期时间”、“日期”类型的字段的值清除后，查看修改日志，没有记录
           	/* if($uitype==5 || $uitype==86)
            {
                //17988: 客户>列表/明细：转公海操作后，编辑该客户，查看修改日志，结果：修改日志显示了领取日期的记录。
                 if(date('Y-m-d',$value)<'1600-01-01'||$value<'1600-01-01')
                 {
                    continue;
                 }
            }*/
            if ($module == 'Calendar' && in_array($key,['reminder_description','loop_description'])) {
                continue;
            }

			self::saveFieldLogOne($module,$key,$crmid,$entitydata[$key],$value);

		}
        //echo self::$controller[$module]->id;
        
		self::$modtrackerId[$module] = 0;//当前保存结束
        
	}
	/**
	 * 获取字段修改日志结果集
	 * @author Tujt 2015-06-16
	 */
	public function getFieldUpdateLog($input){
		global $adb,$list_max_entries_per_page_new_more;
        global $current_user;
		// editor:gyqX160803 Bug:0023859
        //$module = getSalesEntityType($input['record']);
		if(!empty($input['rmodule'])){
			$module = $input['rmodule'];
		}else{
			$module = getSalesEntityType($input['record']);
		}
        $tabid = getTabid($module);
        if($input['fieldtype']=='assigned_user_id'){
        include('user_privileges/user_language_'.$current_user->id.'.php');
			$focus = CRMEntity::getInstance($input['rmodule']);
            $columname=$focus->getSmownerColumName();
            $getassigned_user_header = "SELECT fieldname, ld_tranlabel.fieldlabel AS languageheader FROM ld_field 
            LEFT JOIN ld_tranlabel ON ld_tranlabel.tabid = ld_field.tabid AND ld_field.fieldid = Relateid
            where  columnname='$columname' AND trantable = 'ld_field' 
            AND ld_field.tabid=(SELECT tabid FROM ld_tab where 
             name='".$input['rmodule']."') AND languagetype = '$languageType';";

           //echo $getassigned_user_header;
           	$headerresult = $adb->pquery($getassigned_user_header,array());
            $relfieldname=$adb->query_result($headerresult,0,'fieldname'); 
            $languageheader=$adb->query_result($headerresult,0,'languageheader'); 
        }

		$query = 'SELECT DISTINCT ld_modtracker_basic.id,ld_modtracker_basic.module,
					ld_modtracker_basic.whodid,ld_modtracker_basic.changedon,
					ld_modtracker_basic.status,ld_modtracker_detail.fieldname,
					ld_modtracker_detail.prevalue,ld_modtracker_detail.postvalue 
				FROM ld_modtracker_basic 
					INNER JOIN ld_modtracker_detail 
						ON ld_modtracker_detail.`id` = ld_modtracker_basic.`id`
                    INNER JOIN ld_field 
                        ON ld_modtracker_detail.fieldname = ld_field.fieldname
				WHERE ld_modtracker_basic.`crmid` = '.$input['record'].' and ld_field.presence <> 1
                    and ld_field.tabid = '.$tabid;
        if($input['fieldtype']=='assigned_user_id'){
            $where .=" and ld_field.fieldname='$relfieldname' and ld_modtracker_basic.module='".$input['rmodule']."' ";
           
           
        }
        //20069: 客户>联系人：单据“小路”，明细界面-关联创建-销售负责人变更历史，弹出层翻页栏显示出现错误
        $query.=$where;

        $count_result = $adb->query( 'select ld_modtracker_basic.id   	FROM ld_modtracker_basic 
					   INNER JOIN ld_modtracker_detail 
						ON ld_modtracker_detail.`id` = ld_modtracker_basic.`id` 
                        INNER JOIN ld_field 
                        ON ld_modtracker_detail.fieldname = ld_field.fieldname
                        WHERE ld_modtracker_basic.`crmid` = '.$input['record']
                        .' and ld_field.presence <> 1 and ld_field.tabid = '.$tabid
                       . $where .' group by ld_modtracker_basic.id,ld_modtracker_detail.prevalue,postvalue' );
      
     	$noofrows=$adb->num_rows($count_result);

		$filter = array();
		$filter['record'] = $input['record'];
		//order by 排序
        //相同时间的排序按照id降序
		$order_by = 'ld_modtracker_basic.changedon desc ,ld_modtracker_basic.id   ';$sorder = ' ';
		if(isset($input['order_by']) && !empty($input['order_by'])){
			$order_by = $input['order_by'];
			if('pre' == $order_by) $order_by = 'prevalue';//prevalue中的eval会被过滤掉
		}
		if(isset($input['sorder']) && !empty($input['sorder'])){
			$sorder = $input['sorder'];
		}
		$filter['order_by'] = $order_by;
		$filter['sorder'] = $sorder;
		$query .= ' ORDER BY '.$order_by.' '.$sorder.' ';
		//获取当前页数
		if(isset($input['start']) && $input['start'] != '') {
			$start = $input['start'];
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
		$filter['start'] = $start;
		//计算limit
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$query .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';

		//读取数据
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
        if($input['fieldtype']=='assigned_user_id'){//负责人变更历史
      		$header = array(
						'prevalue'=>getFixedLabel('LBL_Earlier'),
						'postvalue'=>getFixedLabel('LBL_Present'),
						'whodid'=>getFixedLabel('OPERATOR'),
						'changedon'=>getFixedLabel('OPERATTIME')
						);
        }else{
      		$header = array('fieldname'=>getFixedLabel('LBL_Field'),
						'prevalue'=>getFixedLabel('LBL_Earlier'),
						'postvalue'=>getFixedLabel('LBL_Present'),
						'whodid'=>getFixedLabel('OPERATOR'),
						'changedon'=>getFixedLabel('OPERATTIME'));
        }

		$entity = array();$navigationOutput = Array();$url_qry = '';
		if($rows > 0){
			//$module = $adb->query_result($result,0,'module');
			$fieldobj = Field::getInstance($module,$db);
			$this->modulefield = $fieldobj->getModuleFields();
            $showfieldvalue=new ShowFieldValue($fieldobj,$module,SHOW_POPUP);
           	$showfieldvalue->setRecorId($input['record']);
            $showfieldvalue->result=$result;
			for ($i=0; $i < $rows; $i++) {
				$id = $adb->query_result($result,$i,'id');
				$fieldname = $adb->query_result($result,$i,'fieldname');
				$prevalue = $adb->query_result($result,$i,'prevalue');
				$postvalue = $adb->query_result($result,$i,'postvalue');
				$whodid = $adb->query_result($result,$i,'whodid');
				$changedon = $adb->query_result($result,$i,'changedon');
				$fieldlabel = $this->getFieldLabel($module,$fieldname);
             
				
			  
                if($fieldname=='deleted')
                {
                    $entity[$i]['id']['value'] = $id;
                    //18579: 销售退货单>明细：删除销售退货单后，在回收站还原。查看该销售退货单的修改日志，结果：修改日志显示为deleted。
                    $fieldlabel=getFixedLabel('DELETE');
                    if($prevalue==1)
                    {
                        $prevalue=getFixedLabel('DELETE');
                        $postvalue=getFixedLabel('REDUCTION');
                    }
                    else
                    {
                        $prevalue='';
                       $postvalue=getFixedLabel('DELETE');
                    }
                    
                }
                else
                {
                  
                       $field=$this->modulefield[$fieldname];
                       if(!$field)
                       {
                          continue;
                       }
                       $entity[$i]['id']['value'] = $id;
                        $showvalue= $showfieldvalue->getFieldValueByField($field,$prevalue,$prevalue);
                        $prevalue=$showvalue['value'];
                        $showvalue= $showfieldvalue->getFieldValueByField($field,$postvalue,$postvalue);
                        $postvalue=$showvalue['value'];
                }
                $entity[$i]['fieldname']['value'] = $fieldlabel;
				$entity[$i]['prevalue']['value'] = $prevalue;
				$entity[$i]['postvalue']['value'] = $postvalue;
				$entity[$i]['username']['value'] = getUserFullName($whodid);
				$entity[$i]['changedon']['value'] = $changedon;
				$entity[$i]['whodid']['value'] = $whodid;
			}
			 crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
			$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
			$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
			$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$module,'ModTrackerFldLog',$input['record']);
		}
        if($input['fieldtype']=='assigned_user_id'){//负责人变更历史
                $return_value = array('header'=>$header,'entries'=>$entity,'navigation'=>$navigationOutput,
        						'title'=>$languageheader.getFixedLabel('ChangeView'),'filter'=>$filter,'lbl_none'=>getFixedLabel('NONE'));
        }else{
                $return_value = array('header'=>$header,'entries'=>$entity,'navigation'=>$navigationOutput,
  						'title'=>getFixedLabel('View History'),'filter'=>$filter,'lbl_none'=>getFixedLabel('NONE'));  
        }

		return $return_value;
	}
	
	/**
	 * 获取字段对应的标签
	 * @author Tujt 2015-06-16
	 */
	public function getFieldLabel($module,$fieldname){
		if(!isset($this->modulefield[$fieldname])) return $fieldname;
		$fieldInstance = $this->modulefield[$fieldname];
		$fieldlabel = $fieldInstance->getFieldLabelKey();
		return $fieldlabel;
	}
	/**
	 * 记录某一个字段的修改日志
	 * @param String $module 模块名
	 * @param String $fieldname 字段名
	 * @param Integer $crmid 所编辑的ID
	 * @param Text $prevalue 修改前的值
	 * @param Text $postvalue 修改后的值
	 * @author Tujt 2015-06-16
	 */
	public static function saveFieldLogOne($module,$fieldname,$crmid,$prevalue,$postvalue,$operation_logid=''){
		global $adb,$current_user;
        $logId = self::$controller[$module]->logId;
		if(!empty(self::$controller[$module])){
			//日期字段
			if(self::$controller[$module]->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,"uitype")==5)
			{
				//26731: 销售机会：新增单据保存后，明细界面编辑单据，不修改信息直接保存，查看修改日志，结果显示了修改日志信息
				 if($prevalue==""||$prevalue=="0000-00-00"||$prevalue<"1600-01-01")
				 {
					if($postvalue==""||$postvalue=="0000-00-00"||$postvalue<"1600-01-01")
					{
						return false;
					}
				 }
			  
			}
			//日期时间字段
			if(self::$controller[$module]->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,"uitype")==86)
			{
				//26731: 销售机会：新增单据保存后，明细界面编辑单据，不修改信息直接保存，查看修改日志，结果显示了修改日志信息
				 if($prevalue==""||$prevalue=="0000-00-00 00:00:00"||$prevalue<"1600-01-01 00:00:00")
				 {
					if($postvalue==""||$postvalue=="0000-00-00 00:00:00"||$postvalue<"1600-01-01 00:00:00")
					{
						return false;
					}
				 }
			  
			}
		}
        
		if($prevalue == $postvalue) return false;

		//if(0 == self::$modtrackerId[$module]){
			$time = date('Y-m-d H:i:s',time());$status = 0;
			self::$modtrackerId[$module] = $adb->getUniqueID('ld_modtracker_basic');
			$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status,operation_logid) 
							values(?,?,?,?,?,?,?);';
                            
          
			$adb->pquery($query,array(self::$modtrackerId[$module],$crmid,$module,$current_user->id,$time,$status,$operation_logid));
		//}
		$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
       
		$adb->pquery($query,array(self::$modtrackerId[$module],$fieldname,$prevalue,$postvalue));
		if(!empty(self::$controller[$module])){
            self::$controller[$module]->modTrackerIds[] = self::$modtrackerId[$module];
        }
        if ($_REQUEST['is_qrcode_expand'] == 'yes') {
            $qrcodeid = $_REQUEST['qrcodeid'];
            $wechatuserid = $_REQUEST['wechatuserid'];
            //表单码表头修改日志
            $query = 'insert into ld_qrcode_operatelog(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
            $adb->pquery($query,array($qrcodeid,$wechatuserid,$time,'submit',self::$modtrackerId[$module],$crmid));
        }
		self::$lastinsertid = self::$modtrackerId[$module];
	}
	/**
	 * 字段公式功能
	 * @author Tujt 2015-07-02
	 */
	public function saveFieldFormula() {
		global $adb;
	    //因字段公式已经被暂时去掉，所以这儿暂时先用代码写死
      /*
		if('Potentials' == self::$module){//销售机会
			$query = 'SELECT expression_engine FROM ld_fieldformulas WHERE modulename = \'Potentials\' 
						AND expression_engine LIKE \'%amount*possibility/100%\' LIMIT 1;';
			$result = $adb->query($query);
			$rows = $adb->num_rows($result);
			$expression_engine = '';
			if(1 == $rows){
				$expression_engine = $adb->query_result($result,0,'expression_engine');
			}
			$fld = '';
			if(!empty($expression_engine)){
				$expression = explode(';',$expression_engine);
				foreach($expression as $code){
					if(stripos($code,'cf_') > -1){
						$codearr = explode('cf_',$code);
						$codearr[1] = (int)$codearr[1];
						$fld = 'cf_'.$codearr[1];break;
					}
				}
			}
            //22974: 快速创建销售机会：输入【预计合同金额】、【可能性(%) 】值保存后，结果【预算绝对值】字段没有自动计算
			if(!empty($fld) && array_key_exists($fld,self::$controller[self::$module]->column_fields)){
				$percent = 0;
                
				if(self::$controller[self::$module]->column_fields['amount'] > 0 && 
						self::$controller[self::$module]->column_fields['possibility'] > 0){
					$percent = self::$controller[self::$module]->column_fields['amount']*(self::$controller[self::$module]->column_fields['possibility']/100);
				}
               
				self::$controller[self::$module]->column_fields[$fld] = sprintf('%.2f',$percent);
			}
		}*/
        
      
	}
    
    function saveOperationLog($module,$crmid,$action,$actiontwo=''){
        global $adb,$current_user;
        if(!empty($action)){
            if ($actiontwo =='Update') $actiontwo='IMPORTUPDATE';
            elseif ($actiontwo =='UpdateAll') $actiontwo='IMPORTUPDATEALL';
            $query = 'insert into ld_operation_log(module,crmid,action,actiontwo,operator,operation_time) values (?,?,?,?,?,?)';
            $adb->pquery($query,array($module,$crmid,$action,$actiontwo,$current_user->id,date('Y-m-d H:i:s')));
        }
    }
	/**
     * 析构函数
     * @author Tujt 2015-06-15
     */
    function __destruct() {
        
    }
    /**
     * 初始化附件图片日志信息数组
     */
    public function initAttachmentImgLogs(){
		$this->setAttachmentImgLogs([]);
		$this->all_insertlogs_attachmentsid_arr = [];
	}
	public function setAttachmentImgLogs($attachment_img_logs_arr){
		$this->attachment_img_logs_arr = $attachment_img_logs_arr;
	}
	public function getAttachmentImgLogs(){
		return $this->attachment_img_logs_arr;
	}
    /**
     * 保存附件信息到成员变量
	 * type：prevalue（修改前）,postvalue（修改后）
	 * logtype：field（表头附件字段），detail（分录附件字段）
     */
	public function saveAttachmentImgLogs($attachmentinfo,$type,$logtype='field'){

		if(!empty($attachmentinfo)){
			$attachment_img_logs_arr = $this->getAttachmentImgLogs();

			$savelogs_fieldname_arr = [];// 需要保存修改日志的字段
			$not_savelogs_fieldname_arr = [];// 不需要保存修改日志的字段
			foreach ($attachmentinfo as $fieldname => $infos) {
				$newfilename_arr = [];
				$attachmentsid_arr = [];
				foreach ($infos[$type] as $index => $info) {
					$newfilename_arr[] = $info['newfile_name'];
					$attachmentsid_arr[] = $info['attachmentsid'];
				}
				$attachment_img_logs_arr[$logtype][$fieldname][$type]['attachmentinfo'] = $infos[$type];// 所有附件信息，用于插入ld_attachments_history表
				$attachment_img_logs_arr[$logtype][$fieldname][$type]['newfilename_arr'] = $newfilename_arr;// 存放的文件名，用于比较编辑前后是否有编辑过附件或图片
				$attachment_img_logs_arr[$logtype][$fieldname][$type]['attachmentsid_arr'] = $attachmentsid_arr;// 用于插入ld_attachments_history表时，提前统一判断防止重复插入
				// 筛选出仅编辑过的附件字段
				if($type == 'postvalue' && isset($attachment_img_logs_arr[$logtype][$fieldname]['prevalue'])){
					// // 没传对应prevalue需要初始化一下
					// if(!isset($attachment_img_logs_arr[$fieldname]['prevalue'])){
					// 	$attachment_img_logs_arr[$fieldname]['prevalue']['attachmentinfo'] = [];
					// 	$attachment_img_logs_arr[$fieldname]['prevalue']['newfilename_arr'] = [];
					// 	$attachment_img_logs_arr[$fieldname]['prevalue']['attachmentsid_arr'] = [];
					// }

					$prevalue_newfilename_arr = $attachment_img_logs_arr[$logtype][$fieldname]['prevalue']['newfilename_arr'];
					$postvalue_newfilename_arr = $newfilename_arr;

					// 修改前后都为空，不保存日志
					if(empty($prevalue_newfilename_arr) && empty($postvalue_newfilename_arr)){
						unset($attachment_img_logs_arr[$logtype][$fieldname]);
						continue;
					}
					if(is_array($prevalue_newfilename_arr) && is_array($postvalue_newfilename_arr)){

						// 单据头直接去掉不需要保存的，分录即便是其他字段有修改也要记录当前字段，所以分录先全部记录
						if($logtype == 'field'){
							// 前后文件数不同，一定保存日志
							if(count($prevalue_newfilename_arr) != count($postvalue_newfilename_arr)){
								$savelogs_fieldname_arr[] = $fieldname;
							}else{
								// 前后文件数相同时，比较数组元素是否一致，即便文件内容不变但只要重写上传了文件newfile_name就会变，就需要记录日志
								ksort($prevalue_newfilename_arr);
								ksort($postvalue_newfilename_arr);
								if(!empty(array_diff($prevalue_newfilename_arr,$postvalue_newfilename_arr)) || !empty(array_diff($postvalue_newfilename_arr,$prevalue_newfilename_arr))){
									$savelogs_fieldname_arr[] = $fieldname;
								}else{
									// 前后不变
									$not_savelogs_fieldname_arr[] = $fieldname;
								}
							}
							if(is_array($not_savelogs_fieldname_arr) && in_array($fieldname,$not_savelogs_fieldname_arr)){
								echo($fieldname);
								unset($attachment_img_logs_arr[$logtype][$fieldname]);
								continue;
							}
							// 当前字段有修改 则合并所有需要附件id
							if(is_array($savelogs_fieldname_arr) && in_array($fieldname,$savelogs_fieldname_arr)){
								$cur_fieldname_attachmentsid_arr = array_unique(array_merge($attachmentsid_arr, $attachment_img_logs_arr[$logtype][$fieldname]['prevalue']['attachmentsid_arr']));
								$this->all_insertlogs_attachmentsid_arr = array_unique(array_merge($this->all_insertlogs_attachmentsid_arr, $cur_fieldname_attachmentsid_arr));
							}

						}else if($logtype == 'detail'){
							$cur_fieldname_attachmentsid_arr = array_unique(array_merge($attachmentsid_arr, $attachment_img_logs_arr[$logtype][$fieldname]['prevalue']['attachmentsid_arr']));
							$this->all_insertlogs_attachmentsid_arr = array_unique(array_merge($this->all_insertlogs_attachmentsid_arr, $cur_fieldname_attachmentsid_arr));
							$attachment_img_logs_arr[$logtype][$fieldname][$type]['save_newlog'] = 'no';
							if(is_array($savelogs_fieldname_arr) && in_array($fieldname,$savelogs_fieldname_arr)){
								$attachment_img_logs_arr[$logtype][$fieldname][$type]['save_newlog'] = 'yes';
							}
						}
					}
				}
			}
			$this->setAttachmentImgLogs($attachment_img_logs_arr);
		}
	}
	/**
     * 将修改前后的附件图片存入ld_attachments_history
	 * logtype：field（表头附件字段），detail（分录附件字段）
     */
	public function insertAttachmentImgLogs($logtype='field'){
		global $adb,$current_user;
		if($logtype == 'detail'){
			$insert_tablename = 'ld_detailattachments_history';
		}else{
			$insert_tablename = 'ld_attachments_history';
		}
		$attachment_img_logs_arr = $this->getAttachmentImgLogs()[$logtype];
		$insertlogs_attachmentsid_arr = $this->all_insertlogs_attachmentsid_arr;// 为筛选过的所有需要插入的附件id
		if(!empty($insertlogs_attachmentsid_arr) && is_array($insertlogs_attachmentsid_arr)){
			$all_insertlogs_attachmentsid_str = implode(',',$insertlogs_attachmentsid_arr);
			$select_sql = "SELECT GROUP_CONCAT(attachmentsid) FROM $insert_tablename WHERE attachmentsid in ( $all_insertlogs_attachmentsid_str );";
			$select_result = $adb->pquery($select_sql,array());
			$num_rows = $adb->num_rows($select_result);
			$saved_attachmentsid_str = $adb->query_result($select_result,0,0);
			// 去掉已经保存过的
			if(!empty($saved_attachmentsid_str)){
				$saved_attachmentsid_arr = explode(',',$saved_attachmentsid_str);
				$insertlogs_attachmentsid_arr = array_diff($insertlogs_attachmentsid_arr,$saved_attachmentsid_arr);
			}
			foreach ($attachment_img_logs_arr as $fieldname => $logs_infos) {
				foreach ($logs_infos as $type => $infos) {
					foreach ($infos['attachmentinfo'] as $attid => $info) {
						if(in_array($attid,$insertlogs_attachmentsid_arr)){
							if($logtype == 'detail'){
								$insert_sql = "INSERT INTO $insert_tablename (`attachmentsid`,`crmid`, `name`, `newfile_name`, `type`, `path`, `size`, `imagefromtype`, 
									`storage_location`, `upload_from`, `cloud_path`, `lineitem_id`, `description`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
								$adb->pquery($insert_sql,array($info['attachmentsid'],$info['crmid'],$info['name'],$info['newfile_name'],$info['type'],$info['path'],$info['size'],$info['imagefromtype'],
									$info['storage_location'],$info['upload_from'],$info['cloud_path'],$info['lineitem_id'],$info['description']));
							}else{
								$insert_sql = "INSERT INTO $insert_tablename (`attachmentsid`,`crmid`, `name`, `newfile_name`, `type`, `path`, `size`, `imagefromtype`, 
									`storage_location`, `upload_from`, `cloud_path`, `description`, `watermark`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
								$adb->pquery($insert_sql,array($info['attachmentsid'],$info['crmid'],$info['name'],$info['newfile_name'],$info['type'],$info['path'],$info['size'],$info['imagefromtype'],
									$info['storage_location'],$info['upload_from'],$info['cloud_path'],$info['description'],$info['watermark']));
							}
						}
					}
				}
			}
		}
	}
	/**
     * 删除单据后，删除ld_attachments_history表中对应附件图片历史日志
     */
	public function deleteAttachmentImgLogs($recordid_arr){
		global $adb,$current_user;
		if(!empty($recordid_arr) && is_array($recordid_arr)){
			$recordid_str = implode(',',$recordid_arr);
			if(!empty($recordid_arr)){
				$delete_sql = "DELETE FROM ld_attachments_history WHERE crmid IN ( $recordid_str )";
				$adb->pquery($delete_sql,array());
				$delete_sql = "DELETE FROM ld_detailattachments_history WHERE crmid IN ( $recordid_str )";
				$adb->pquery($delete_sql,array());
			}
		}
	}
	/**
     * 单据头附件图片字段保存修改日志
     */
	public function saveAttachmentImgFieldLogs($module){
		$all_attachmentlogsinfo_arr = $this->getAttachmentImgLogs();
        if(!empty($all_attachmentlogsinfo_arr)){
			$this->insertAttachmentImgLogs();
			$all_field_attachmentlogsinfo_arr = $all_attachmentlogsinfo_arr['field'];
			$record = self::$controller[$module]->id;
            foreach ($all_field_attachmentlogsinfo_arr as $fieldname => $logs_arr) {
                if(!empty($logs_arr)){
                    if(!empty($logs_arr['prevalue']) && !empty($logs_arr['postvalue'])){
                        $attachment_prevalue_arr = $logs_arr['prevalue']['attachmentsid_arr']??[];
                        $attachment_postvalue_arr = $logs_arr['postvalue']['attachmentsid_arr']??[];
                        $attachment_prevalue_str = implode(',',$attachment_prevalue_arr);
                        $attachment_postvalue_str = implode(',',$attachment_postvalue_arr);
                        self::saveFieldLogOne($module,$fieldname,$record,$attachment_prevalue_str,$attachment_postvalue_str);
                    }
                }
            }
            // dump($all_attachmentlogsinfo_arr);
		}
	}
}
?>