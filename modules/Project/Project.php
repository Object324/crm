<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/


class Project extends CRMEntity {
    var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['Project']='Project';
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $table_name = 'ld_project';
    var $table_index= 'projectid';
    var $table_code='project_no';//表编号字段(审批中心)
    var $column_fields = Array();
    var $module_name='Project';
    /** Indicator if this is a custom module or standard module */
    /**
    @更新操作 by andy 
    @date: 20140218
    @项目更多信息中项目任务提交审批可以删除 变量$IsCustomModule=false 正常
    */
    var $IsCustomModule = false;

    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = Array('ld_projectcf', 'projectid');

    /**
     * Mandatory for Saving, Include tables related to this module.
     */
    var $tab_name = Array('ld_crmentity', 'ld_project', 'ld_projectcf');

    /**
     * Mandatory for Saving, Include tablename and tablekey columnname here.
     */
    var $tab_name_index = Array(
		'ld_crmentity' => 'crmid',
		'ld_project'   => 'projectid',
	    'ld_projectcf' => 'projectid');

    //reason:打印关联模块
    var $relatedtab=array('accounts'=>'','contacts'=>'','users'=>'','company'=>'','project'=>'');


	// Make the field link to detail view from list view (Fieldname)
	var $list_link_field = 'projectname';

	// For Popup listview and UI type support
	var $search_fields = Array(
	/* Format: Field Label => Array(tablename, columnname) */
	// tablename should not have prefix 'lingdang_'
	'Project Name'=> Array('project', 'projectname'),
	'Start Date'=> Array('project', 'startdate'),
	'Status'=>Array('project','projectstatus'),
	'Type'=>Array('project','projecttype'),
	);
	var $search_fields_name = Array(
	/* Format: Field Label => fieldname */
	'Project Name'=> 'projectname',
	'Start Date'=> 'startdate',
	'Status'=>'projectstatus',
	'Type'=>'projecttype',
	);

	// For Popup window record selection
	var $popup_fields = Array('projectname');

	// Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
	var $sortby_fields = Array();

	// For Alphabetical search
	var $def_basicsearch_col = 'projectname';

	// Column value to use on detail view record text display
	var $def_detailview_recname = 'projectname';

	// Required Information for enabling Import feature
	var $required_fields = Array('projectname'=>1);

	// Callback function list during Importing
	var $special_functions = Array('set_import_assigned_user');

	var $default_order_by = 'projectname';
	var $default_sort_order='ASC';
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('createdtime', 'modifiedtime');

	function __construct() {
	    global  $currentModule;
	   
 	   $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Project',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
       
	    $this->log = $log;
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Project');
        $this->list_link_field=$entityname['fieldname'];
       
	}
	//获取原单模块
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select entitytype,salesorderid from ld_project where projectid = ?";
        $result=$adb->pquery($sql,array($recordid)); 
		$salesorderid = $adb->query_result($result,0,'salesorderid');
		if(!empty($salesorderid)){
			$sourceModuleInfo['module'] = getSalesEntityType($salesorderid);
		}else{
			$sourceModuleInfo['module'] = '';
		}
        $sourceModuleInfo['sourceid']= $salesorderid;
        return $sourceModuleInfo;
    }
    //BUG0073586 liushuai 20231018 销售发票-相关信息栏下推创建项目立项-源单没有带出
    public function getSourceFieldInfo()
    {
        $fieldinfo= $this->fieldobj->getFieldInfoobjBykey("columnname",'salesorderid');//该模块源单字段不是source_list,需要重写方法
        return $fieldinfo;
    }
	function getInvoiceField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_invoicedetail where id = ? and entitytypeid>0 limit 1";
        $result = $adb->pquery($sql,array($recordid));
        if($adb->num_rows($result)>0)
            return $adb->query_result($result,0,0);
        else 
         return '';
         
    }
	function save_module($module) {
        global $adb,$projectstatus_old,$current_user;
		
		if(!empty($_REQUEST['salesorder_id_type'])){
			$selectsource = $_REQUEST['salesorder_id_type'];
			 $adb->pquery('update ld_project set entitytype = \''.$selectsource.'\' where projectid = ' . $this->id);
		}
        /*$setsystem = getSys_deploy(53);
        //读取系统设置缓存
        if(($setsystem['deploy_value']==1&&$projectstatus_old!=''&&$projectstatus_old!=$this->column_fields['projectstatus'])|| $this->mode==''){
            $this->updateProjectStatus($this->id);
        }*/
		$this->updateProjectStatus($this->id);
        //项目新增生成摘要
        if($this->mode !='edit'){
            InsertProjectabstract($this->id,$this->id,$module,'create');
        }
        
	}
    /**
     * 审批进行中执行操作函数
     * edit:andrew
     * date:201451017
     */
     public function approveding($record)
     {
        $this->updateProjectStatus($record);  
     }
     /**
     * 审批已拒绝执行操作函数
     * edit:andrew
     * date:201451017
     */
     public function failedApproved($record)
     {
        $this->updateProjectStatus($record);  
     }
     /**
     * 审批已批准执行操作函数
     * edit:andrew
     * date:201451017
     */
     public function successApprove($record)
     {
        $this->updateProjectStatus($record);
     }

     /**
     * 审批已驳回执行操作函数
     * edit:andrew
     * date:20141017
     */
    public function rejectApproved($record)
    {
        $this->updateProjectStatus($record);
    }     
        
    /**
     * 项目审批更新关联操作
     * edit:andrew
     * date:20141017
     */
    public function updateProjectStatus($record)
    {  
        global $adb,$projectstatus_old,$modulestatus_now,$current_user;
		$query = 'select projectstatus,salesorderid from ld_project where projectid = ?';
		$result = $adb->pquery($query,array($record));
		$projectstatus = $adb->query_result($result,0,0);
		$salesorderid = $adb->query_result($result,0,1);
		if(($projectstatus_old!=$projectstatus)||$this->mode==''){
			if(!empty($projectstatus) && !empty($salesorderid)){
				$query = 'select paymentplanid,ld_paymentplan.smownerid,ld_account.accountname,ld_paymentplan.amount,ld_paymentplan.projectid,ld_paymentplan.currency_id from ld_paymentplan 
				LEFT JOIN ld_account on ld_account.accountid = ld_paymentplan.accountid
				where (entitytypeid in (select invoiceid from ld_invoice where source_list=?) or entitytypeid=?) and projectstatus = ? and paymenttype = ? and plandate is NULL and ld_paymentplan.paymentstatus <> \'已收\'';
				$result = $adb->pquery($query,array($salesorderid,$salesorderid,$projectstatus,'项目状态'));
                //wym XUQIU1001598 收款计划增加单选“项目立项”字段，项目推进时需判断是否有收款计划关联该项目,如果收款计划收款阶段与项目推进阶段相等,则新建提醒
				if($adb->num_rows($result) >= 1){
					for($gc=0;$gc<$adb->num_rows($result);$gc++){
						$paymentplanid = $adb->query_result($result,$gc,'paymentplanid');
                        $amount =$adb->query_result($result,$gc,'amount');
                        // wym BUG0072188 合同订单关联收款计划，根据项目状态收款时，消息提醒中金额的小数位数太多了
                        $cur_len = getSys_deploy(351);
                        $amount=number_format($amount,$cur_len['deploy_value']);
                        // wym BUG0073439
                        $currency_id=$adb->query_result($result,$gc,'currency_id')??1;
                        $currencyobj=new Currency($adb,$currency_id);
                        $currencySymbol = decode_html($currencyobj->getCurrencySymbol());
						$datetime=date('Y-m-d H:i');
                        $focus_payment=CRMEntity::getInstance('PaymentPlan');
                        $fieldlabel_project=$focus_payment->fieldobj->getFieldInfoBykeyValue("fieldname",'projectid','fieldlabel');
                        $projectid = $adb->query_result($result,$gc,'projectid');
                        if($projectid==$record && !empty(getModuleHref('Project', $projectid))){
                            $RemindsContent=getFixedLabel('PAYMENTPLANEXPIRES').$adb->query_result($result,$gc,'accountname')."，".getFixedLabel('Paymentwhentheprojectstatus')."：".$projectstatus."，".$fieldlabel_project."：".getModuleHref('Project', $projectid).getFixedLabel('AMOUNTINFO').$currencySymbol.$amount;
                            $update="UPDATE ld_paymentplan SET plandate = curdate() where paymentplanid = ?";
                            $adb->pquery($update,array($paymentplanid));
                        }elseif(empty($projectid)){
                            $RemindsContent=getFixedLabel('PAYMENTPLANEXPIRES').$adb->query_result($result,$gc,'accountname')."，".getFixedLabel('Paymentwhentheprojectstatus')."：".$projectstatus."，".$fieldlabel_project."：".getModuleHref('Project', $record).getFixedLabel('AMOUNTINFO').$currencySymbol.$amount;
                            $update="UPDATE ld_paymentplan SET plandate = curdate(),projectid=? where paymentplanid = ?";
                            $adb->pquery($update,array($record,$paymentplanid));
                        }
                        if(!empty($RemindsContent)){
                            $sql='select id from ld_automaticreminds where defaultnum=40';
                            $autoresult=$adb->pquery($sql,array());
                            $reminds_ruleid=$adb->query_result($autoresult,0,0);
                            //wym BUG0073115 如果有未读的自动提醒先删除;删除后如果有已读的提醒则不再提醒,如果没有则发送提醒
                            $sql="delete from ld_reminds where reminds_ruleid=? and related_to=? and status_rmd='未读'" ;
                            $adb->pquery($sql,array($reminds_ruleid,$paymentplanid));
                            $sql="select 1 from ld_reminds where reminds_ruleid=? and related_to=? and status_rmd='已读'" ;
                            $yiduresult=$adb->pquery($sql,array($reminds_ruleid,$paymentplanid));
                            if(empty($adb->query_result($yiduresult,0,0))){
                                $remindsid = $this->AddReminds($RemindsContent,$datetime,$adb->query_result($result,$gc,'smownerid'),$paymentplanid);
                                $sql='update ld_reminds set reminds_ruleid=? where remindsid=?';
                                $adb->pquery($sql,array($reminds_ruleid,$remindsid));
                            }
                        }
					}
				}
			}
		}
    }  
         /**
     * 更新操作
     * 项目更新回款计划添加提醒
     * edit by andrew
     * date: 20141017
    **/
    function AddReminds($RemindsContent,$datetime,$recieverid,$record)
    {
        global $adb,$current_user;
        require_once(globalStatic::$root_directory.'modules/Reminds/Reminds.php');        
            $sql="delete from ld_reminds where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') != 'Approve'";
            $result = $adb->query($sql); 
            $sql="delete from ld_reminds_accepted where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') != 'Approve'";
            $result = $adb->query($sql); 
            
            $smownersql = "select * from ld_crmentity where crmid = ".$record;
            $smownerresult = $adb->query($smownersql);
            $setype = $adb->query_result($smownerresult,0,'setype');
            $focus_rel =new Reminds();                    
        	$focus_rel->column_fields['date_time'] = $datetime;	   
            $focus_rel->column_fields['related_to']=$record;
            $focus_rel->column_fields['reltab']=$setype;
          
            $focus_rel->column_fields['recieverid']=$recieverid;
            $focus_rel->column_fields['createdtime']=date('Y-m-d H:i');
            $focus_rel->column_fields['assigned_user_id']=$recieverid;
            $focus_rel->column_fields['status_rmd']='未读';
            $focus_rel->column_fields['content']=$RemindsContent;
            $focus_rel->mode="create";
            
            $focus_rel->save('Reminds');
            return $focus_rel->id;
    }
	/**
	 * Return query to use based on given modulename, fieldname
	 * Useful to handle specific case handling for Popup
	 */
	function getQueryByModuleField($module, $fieldname, $srcrecord) {
		// $srcrecord could be empty
	}




	
	/**
	 * Transform the value while exporting
	 */
	function transform_export_value($key, $value) {
		return parent::transform_export_value($key, $value);
	}

	/**
	 * Function which will give the basic query to find duplicates
	 */
	function getDuplicatesQuery($module,$table_cols,$field_values,$ui_type_arr,$select_cols='') {
		$select_clause = "SELECT ". $this->table_name .".".$this->table_index ." AS recordid, ld_users_last_import.deleted,".$table_cols;

		// Select Custom Field Table Columns if present
		if(isset($this->customFieldTable)) $query .= ", " . $this->customFieldTable[0] . ".* ";

		$from_clause = " FROM $this->table_name";

		$from_clause .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";

		// Consider custom table join as well.
		if(isset($this->customFieldTable)) {
			$from_clause .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index";
		}
		$from_clause .= " LEFT JOIN ld_users ON ld_users.id = ld_crmentity.smownerid";

		$where_clause = "	WHERE ld_crmentity.deleted = 0";
		$where_clause .= $this->getListViewSecurityParameter($module);

		if (isset($select_cols) && trim($select_cols) != '') {
			$sub_query = "SELECT $select_cols FROM  $this->table_name AS t " .
				" INNER JOIN ld_crmentity AS crm ON crm.crmid = t.".$this->table_index;
			// Consider custom table join as well.
			if(isset($this->customFieldTable)) {
				$sub_query .= " LEFT JOIN ".$this->customFieldTable[0]." tcf ON tcf.".$this->customFieldTable[1]." = t.$this->table_index";
			}
			$sub_query .= " WHERE crm.deleted=0 GROUP BY $select_cols HAVING COUNT(*)>1";
		} else {
			$sub_query = "SELECT $table_cols $from_clause $where_clause GROUP BY $table_cols HAVING COUNT(*)>1";
		}


		$query = $select_clause . $from_clause .
					" LEFT JOIN ld_users_last_import ON ld_users_last_import.bean_id=" . $this->table_name .".".$this->table_index .
					" INNER JOIN (" . $sub_query . ") AS temp ON ".get_on_clause($field_values,$ui_type_arr,$module) .
					$where_clause .
					" ORDER BY $table_cols,". $this->table_name .".".$this->table_index ." ASC";

		return $query;
	}


	static function registerLinks() {

	}

   

    /**
     * Here we override the parent's method
     * This is done because the related lists for this module use a custom query
     * that queries the child module's table (column of the uitype10 field)
     *
     * @see data/CRMEntity#delete_related_module($module, $crmid, $with_module, $with_crmid)
     */
    function delete_related_module($module, $crmid, $with_module, $with_crmid) {
         if (!in_array($with_module, array('ProjectMilestone', 'ProjectTask'))) {
             parent::delete_related_module($module, $crmid, $with_module, $with_crmid);
             return;
         }
        $destinationModule = vtlib_purify($_REQUEST['destination_module']);
        if (!is_array($with_crmid)) $with_crmid = Array($with_crmid);
        foreach($with_crmid as $relcrmid) {
            $child = CRMEntity::getInstance($destinationModule);
            $child->retrieve_entity_info($relcrmid, $destinationModule);
            $child->mode='edit';
            $child->column_fields['projectid']='';
            $child->save($destinationModule,$relcrmid);
        }
    }

	

    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
		/**
		 * 增加服务合同模块判断，修改or判断为isset判断
		 * @reason 0010339 服务单无法删除相关的项目
		 * @author Tujt 2014-07-23
		 */
		$delrelmod = array('Accounts'=>'1','SalesOrder'=>'1','PaymentPlan'=>'1','HelpDesk'=>'1');
        if(isset($delrelmod[$return_module])) {
			$this->trash('Project',$id);
		} 
	}
    
 //在项目模块中，编辑操作时，确保已用费用和已用工时字段值正确。
 function updateProjectHas($id){
    global $adb;
    if(!empty($id)){
        $query = 'select sum(timecost)as times,sum(totalcost) as total from ld_projectprogress where projectid = ? and deleted = 0';
        $result = $adb->pquery($query,array($id));
        $times = $adb->query_result($result,0,'times');
        $total = $adb->query_result($result,0,'total');
        $update_sql = 'update ld_project set hastime = ?,hascost = ? where projectid = ?';
        $adb->pquery($update_sql,array($times,$total,$id));
    }
 }
 //项目摘要
function get_projectabstract($id, $cur_tab_id, $rel_tab_id, $actions = false) {
    
    global $currentModule,$list_max_entries_per_page_new_more, $adb,$current_user;
    //列头
    $listview_header = array(
    '<div align="left">'. getFixedLabel('TIMES').'</div>',
        getFixedLabel('OPERATOR'),
        getFixedLabel('OPERATORTYPE'),
        getFixedLabel('DESCRIPTION'),
    );
    //获取内容
    $query = 'select module,smcreatorid,createdtime,description,recordid from ld_projectabstract  where projectid = ? order by createdtime desc';
    $result = $adb->pquery($query,array($id));
    $num_rows = $noofrows = $adb->num_rows($result);
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
     $filter['start'] = $start;
     //计算limit
     $limstart=($start-1)*$list_max_entries_per_page_new_more;
    $url_qry = '';

        for($i = 0; $i < $num_rows; $i++){
            $related_module = $adb->query_result($result,$i,'module');
            $description = $adb->query_result($result,$i,'description');
            $recordid = $adb->query_result($result,$i,'recordid');
            if($description =='delete'){
                $description = '删除';
            }else if($description=='close'){
                $description = '关闭';
            }
            else{
                $description = '新增';
            }
            $focus = CRMEntity::getInstance($related_module);
            $entityarray = getEntitynameInfo(getTabid($related_module));
            
            $query = 'select ' . $entityarray['fieldname'] . ' from ' . $entityarray['tablename'] . ' where ' . $entityarray['entityidfield'] .'=? limit 1';
            $res = $adb->pquery($query,array($recordid));
            
            $entityname = '<a  referencemodule="'.$related_module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">' . $adb->query_result($res,0,0) . '</a>';
            $desc = $description . getTranstab($related_module) .'[' . $entityname. ']';
            $listview_entries[$i] = array(
                'createdtime' =>'<div align="left">'. $adb->query_result($result,$i,'createdtime').'</div>',
                'smcreatorid' => getUserFullName($adb->query_result($result,$i,'smcreatorid')),
                'module' => getTranstab($related_module),   
                'description' => $desc,
                
            );
        }
        //操作按钮
        if ($singlepane_view == 'true')
            $returnset = "&return_module=$currentModule&return_action=DetailView&return_id=$id";
        else
            $returnset = "&return_module=$currentModule&return_action=CallRelatedList&return_id=$id";
            crm_load_function_file('GetRelatedList','include','RelatedListView');
        $return_value = GetRelatedList($currentModule, $related_module, $other, $query, $button, $returnset);
        if ($return_value == null)
            $return_value = Array();

        //kfbcrm 项目立项---相关信息‘项目动态’---右上角没有翻页控件和记录数据条数
    crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
    $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
    $navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
    $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$module,'ModTrackerFldLog',$record);
        $return_value = array('header'=>$listview_header,'entries'=>$listview_entries   ,'navigation'=>$navigationOutput,'fieldwidth'=>'');
        return $return_value;
 }
	   
}

Project::require_file();

?>