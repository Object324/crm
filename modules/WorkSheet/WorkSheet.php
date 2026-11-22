<?php


class WorkSheet extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['WorkSheet']='WorkSheet';
            if(empty(globalStatic::$arr_module_require['Accounts']))
            {
                globalStatic::$arr_module_require['Accounts']='Accounts';
                include(globalStatic::$root_directory.'modules/Accounts/Accounts.php');
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            }

    }
      var $Detail_table="ld_worksheetdetail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_worksheetdetailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
   
	var $log;
	var $db;
    var $module_name='WorkSheet';
	var $table_name = "ld_worksheet";
	var $table_index= 'worksheetid';
    var $table_code='worksheet_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
	var $tab_name = Array('ld_crmentity','ld_worksheet','ld_worksheetscf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_worksheet'=>'worksheetid','ld_worksheetscf'=>'worksheetid');//'ld_invoice_recurring_info'=>'WorkSheetid'
	/*
    edit:can
    date:20131024
    reason:閹垫挸宓冮崗瀹犱粓濡€虫健
    */
    //edit:can 57107  	自动提醒设置，提醒内容设置了变量信息，接收到消息后变量信息显示为空值。（客户手机，客户地址，最新分配日期等字段收到提醒显示为空值） 
    var $relatedtab=array('worksheet'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','WorkSheet'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_worksheetscf', 'worksheetid');
	var $entity_table = "ld_crmentity";


	var $object_name = "WorkSheet";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'worksheet_no';

	var $search_fields = Array(
				'Order No'=>Array('WorkSheet'=>'worksheet_no'),
				'Subject'=>Array('WorkSheet'=>'subject'),
				'Account Name'=>Array('account'=>'accountid')
				);

	var $search_fields_name = Array(
					'Order No'=>'worksheet_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','WorkSheetid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    //   
    var $worksheet_status = array();
    var $status_columnname = 'worksheet_status';
    var $SpecialDetailTable = 'ld_worksheetspecialdetail';
    var $solution_columnname = array('description','solution','filename');
    
    static $mass_before_focus=array();
   
	/** Constructor Function for WorkSheet class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of WorkSheet class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('WorkSheet',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:超链接字段动态化
         * */
        $entityname=getEntitynameByModulename('WorkSheet');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='WorkSheet';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
        
        $this->worksheet_status = array('all'=>getFixedLabel('ALL'),
                                        'tobeallocated'=>getFixedLabel('TOBEALLOCATED'),
                                        'urged'=>getFixedLabel('BEURGED'),
                                        'inprocess'=>getFixedLabel('INPROCESS'),
                                        'closed'=>getFixedLabel('CLOSEDBILL'));
        //zkt 20240620 BUG20240619-62  工单：界面方案界面显示的字段，可通过数据库配置
        $solution_columnname = getUsersettingByLabel($this->module_name, 1, 'WorkSheet_solution_columnname');
        if(!empty($solution_columnname)){
            $solution_columnname_arr = json_decode(html_entity_decode($solution_columnname));
            if(is_array($solution_columnname_arr)){
                $this->solution_columnname=$solution_columnname_arr;
            }
        }

	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
        if(file_exists(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php'))
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
        	// Update the currency id and the conversion rate for the sales order
		//缂傛牞绶弮璺哄灲閺傤厼绔电粔宥嗘Ц閸氾附鏁奸崣?this->currency_status  true:閺€鐟板綁閿涘畺alse:濞屸剝鏁奸崣?
        //25906: pc缁?閸氬牆鎮撶拋銏犲礋 鐠併垹宕熺紓鏍у娇 SO11-15626 閺傛澘缂撻崥鍫濇倱鐠併垹宕?鐢胶顫掗柅澶嬪濞喲冨帗 閵嗗倸鍙ч懕鏂垮灡瀵ゅ搫褰傜粊?閸欐垹銈ㄩ柌鎴︻杺253.80濞喲冨帗閸掓澘鎮庨崥宀冾吂閸楁洖鍑″鈧粊銊╁櫨妫版繈鍋呮潏鍦箙閿涘本濡?53.80濞喲冨帗瑜版挻鍨氭禍鐑樼毌鐢焦婀侀幑銏㈢暬閹存劖顑傞崗鍐х啊
		if($this->currency_status === true)
		{
			$update_query = "update ld_worksheet set currency_id=?, conversion_rate=?,currency_symbol=? where worksheetid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'WorkSheetAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{ 
			//保存明细
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'WorkSheet');
            
            $this->save_specialdetail();   
            
          
		}
        
        //工单管理保存时默认不设置服务人员
        if($this->mode == 'create'){
            // 新建工单之后保存日志
            $this->saveWorkTrends($this->id,'Users',$current_user->id,'create');
            //新建工单更新为待分配状态
            $sql = 'update '.$this->table_name.' set worksheet_status=? where '.$this->table_index.'= ?';
            $this->db->pquery($sql,array('tobeallocated',$this->id));
            
            $sql = 'update '.$this->table_name.' set smownerid = "" where '.$this->table_index.'= '.$this->id;
            $this->db->pquery($sql,array());
        }
         
        
    }

	

   
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('WorkSheet',$id);
    }
    
    public function save_specialdetail(){
        global $adb;
        //编辑时删除原有特殊分录
        if($this->id>0 && $this->mode =='edit'){
            $sql = 'delete from ld_worksheetspecialdetail where worksheetid=?';
            $adb->pquery($sql,array($this->id));
        }
        $rowcnt = $_REQUEST['worksheet_rowcnt']+1;
        $specialvalues = array();
        $specialvalues['worksheetid'] = $this->id;
        for($i=1;$i<$rowcnt;$i++){
            $specialvalues['productid'] = $_REQUEST['worksheet_hdnProductId'.$i];
            if(isset($_REQUEST['worksheet_lineitem_id'.$i])){
                $parent_lineitem_id = $_REQUEST['worksheet_lineitem_id'.$i];
            }else if(isset($_REQUEST['worksheet_detailid'.$i])){
                $parent_lineitem_id = $_REQUEST['worksheet_detailid'.$i];
            }
            $specialvalues['parent_lineitem_id'] = $parent_lineitem_id;
            if(isset($_REQUEST['worksheet_repaired'.$i])){
                $specialvalues['repaired'] = $_REQUEST['worksheet_repaired'.$i];
            }else{
                $specialvalues['repaired'] = 'yes';
            }
            $specialvalues['entitytype'] = $_REQUEST['worksheet_entitytype'.$i];
            $specialvalues['entitytypeid'] = $_REQUEST['worksheet_entitytypeid'.$i];
            
            $specialvaluesKeys = array_keys($specialvalues);	//返回所有键名
			$specialvaluesValues = array_values($specialvalues); //返回所有键值
            
            $query='insert into '. $this->SpecialDetailTable.' ('.implode(',', $specialvaluesKeys).') values ('.generateQuestionMarks($specialvaluesValues).')';
            $adb->pquery($query,array($specialvaluesValues));
        }
    }
    
    //工单动态信息
    public function saveWorkTrends($record,$modifiedmodule,$modifiedby,$description){
        if(empty($record) && $this->id>0){
            $record = $this->id;   
        }
        if(empty($record) && $record <= 0){
            return false;
        }
        
        $sql = 'insert into ld_worksheetlog(worksheetid,modulename,modifiedby,modifiedtime,description)
                values(?,?,?,?,?);';

        $this->db->pquery($sql,array($record,$modifiedmodule,$modifiedby,date('Y-m-d H:i:s'),$description));
    }
    //获取操作用户的名称
    public function getName($frommodule,$record){
        global $adb;
        $frommodule_focus = CRMEntity::getInstance($frommodule);
        $tablename = $frommodule_focus->table_name;
        $tableindex = $frommodule_focus->table_index;
        if($frommodule=='Accounts'){
            $columnname = 'accountname';
        }else if($frommodule == 'Contacts'){
            $columnname = 'lastname';
        }else{
            return getUserFullName($record);
        }
                    
        $sql = 'select '.$columnname.' from '.$tablename.' where '.$tableindex.'= ?';
        $result = $adb->pquery($sql,array($record));

        $name = $adb->query_result($result,0,$columnname);
        return $name;
    }
    //获取角色字段权限
    public function getProfileFields($profileid){
        $profileobj = Profile::getInstance();
        $profilefields = $profileobj->getProfileInfos($profileid);
        $profilefields = $profilefields['field'];
        if($_REQUEST['get_solution']!=""&&$_REQUEST['get_solution']=='yes'){
            //点击解决方案按钮时，解决方案字段必须要有权限
            $adb = $this->db;
            $worksheet_tabid = getTabid($this->moduleName);
            $sql = "SELECT fieldid from ld_field where tabid = ? and fieldname = ?";
            $result = $adb->pquery($sql,[$worksheet_tabid,'solution']);
            if($adb->num_rows($result)>0){
                $solution_fieldid = $adb->query_result($result,0,'fieldid');
                if(isset($profilefields[$solution_fieldid])){
                    unset($profilefields[$solution_fieldid]);
                }
            }
        }
        return $profilefields;
    }
}
WorkSheet::require_file();
?>