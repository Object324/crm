<?php
define('DIVIDEND_STATUS_NO','未派');
define('DIVIDEND_STATUS','已派');
class DividendOrder extends CRMEntity {
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['DividendOrder']='DividendOrder';
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $module_name='DividendOrder';
	var $table_name = "ld_dividendorder";
	var $table_index= 'dividendorderid';
    var $table_code='';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_dividendorder','ld_dividendordercf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_dividendorder'=>'dividendorderid','ld_dividendordercf'=>'dividendorderid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_dividendordercf', 'dividendorderid');
	var $entity_table = "ld_crmentity";

	var $billadr_table = "";
   //打印管理模块
    var $relatedtab=array('dividendorder'=>'','users'=>'','company'=>'','salesorder'=>'','accounts'=>'');
    
	var $object_name = "DividendOrder";

	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('bankcard_no','crmid','smownerid');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

  
	var $list_link_field= 'bankcard_no';

	
	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'dividendorderid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_quotegrouprelation','quoteid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
         global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','DividendOrder'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('DividendOrder');
		$this->db = PearDatabase::getInstance();
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('DividendOrder',$this);
        $this->list_link_field=$entityname['fieldname'];
		 $this->fieldobj=Field::getInstance('DividendOrder',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        
	}
    /*
    function getListQuery($module, $where = '') {
      
        $customview=CustomView::getInstance($module);
        $moduleobj=$this;
    	
    	$table_name = $moduleobj->table_name;
    
        $viewid=$customview->getViewId($module);
        $columnlist=$customview->getColumnsListByCvid($viewid);
       
        $fromclause="";
    
        foreach($columnlist as $colmn)
        {
             $arrcolumn=explode(":",$colmn);
    	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
    				$arrcolumn[0] = $table_name;
    			 }
            $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
        }
    
			$query = "SELECT distinct ld_dividendorder.dividendorderid as crmid,ld_users.last_name".$fromclause .
			" FROM ld_dividendorder
			INNER JOIN ld_dividendordercf
				ON ld_dividendordercf.dividendorderid = ld_dividendorder.dividendorderid
		";
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_dividendorder.dividendorderid";
			$query .= "  WHERE ld_dividendorder.deleted = 0 " . $where;
            return $query;
    }*/
    
	function transform_export_value($key, $value) {
		return parent::transform_export_value($key, $value);
	}
	function save_module()
	{
		global $adb;
	
    }
	/**
	 * 获取派息 短信设置信息
	 * @param
	 * @return
	 * @author Chj
	 */
	function getDividendSms() {
		global $adb;
		$query = 'select is_dividend,is_anti_dividend,mobile_fieldname from ld_dividendorder_sms ';
		$result = $adb->pquery($query,array());
		if($adb->num_rows($result) >= 1){
			$dividend_sms['is_dividend'] = $adb->query_result($result,0,'is_dividend');
			$dividend_sms['is_anti_dividend'] = $adb->query_result($result,0,'is_anti_dividend');
			$dividend_sms['mobile_fieldname'] = explode(',', $adb->query_result($result,0,'mobile_fieldname'));
		}
		return $dividend_sms;
	}
    
    /**
     * 获取派息单明细
     * */
    function get_dividendorderDetail($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
         global  $adb;
        $sql="select ratetype,float_income from ld_dividendordersetting";
        $result=$adb->pquery($sql,array());
        
        if($adb->num_rows($result)>0)
        {
            $rate_type_class_name='cls_'.ucwords($adb->query_result($result,0,'ratetype'));
            $float_income_type=$adb->query_result($result,0,'float_income');
        }
        else
        {
            $rate_type_class_name='cls_Rate_havetotal';
            $float_income_type="";
        }
        require("modules/DividendOrder/DividendParent.php");
       return DividendParent::getDetailByDividendorderId($id,$float_income_type);

    }
	
}
DividendOrder::require_file();
?>
