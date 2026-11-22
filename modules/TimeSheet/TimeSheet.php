<?php


class TimeSheet extends CRMEntity {
    var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['TimeSheet']='TimeSheet';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $table_name = 'ld_timesheet';
    var $table_index= 'timesheet_id';
   	var $customFieldTable = Array('ld_timesheetcf', 'timesheet_id');//�Զ����ֶ����洢�ı�
	var $entity_table = "ld_crmentity";
	var $Detail_table="ld_timesheetdetail";//��ϸ������
	var $Detail_table_id="timesheetdetail_id";//��ϸ��id
	var $Detail_table_scf = "ld_timesheetdetailscf";//��ϸscf��
     var $Detail_table_index="timesheet_id";//��ϸ�������������ֶ�
    var $column_fields = Array();
    var $table_code='timesheet_no';//�����ֶ�(��������)
    /** Indicator if this is a custom module or standard module */
    var $IsCustomModule = true;
    var $module_name='TimeSheet';

    /**
     * Mandatory table for supporting custom fields.
     */
  

    /**
     * Mandatory for Saving, Include tables related to this module.
     */
    var $tab_name = Array('ld_crmentity', 'ld_timesheet', 'ld_timesheetcf');

    /**
     * Mandatory for Saving, Include tablename and tablekey columnname here.
     */
    var $tab_name_index = Array(
        'ld_crmentity' => 'crmid',
        'ld_timesheet'   => 'timesheet_id',
        'ld_timesheetcf' => 'timesheet_id');

    /**
     * Mandatory for Listing (Related listview)
     */
     /*
    edit:can
    date:20131024
    reason:��ӡ����ģ��
    */
    var $relatedtab=array('project'=>'','users'=>'','timesheet'=>'');

    // Make the field link to detail view from list view (Fieldname)
    var $list_link_field = 'timesheet_no';

  
    // For Popup window record selection
    var $popup_fields = Array('timesheet_no');

    // Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
    var $sortby_fields = Array();

    // For Alphabetical search
    var $def_basicsearch_col = 'timesheet_no';

    // Column value to use on detail view record text display
    var $def_detailview_recname = 'timesheet_no';

    // Required Information for enabling Import feature
    var $required_fields = Array('timesheet_no'=>1);

    // Callback function list during Importing
    var $special_functions = Array('set_import_assigned_user');

    var $default_order_by = 'timesheet_no';
    var $default_sort_order='ASC';
    // Used when enabling/disabling the mandatory fields for the module.
    // Refers to ld_field.fieldname values.
    var $mandatory_fields = Array('createdtime', 'modifiedtime');

    function __construct() {
        global  $currentModule;
       
        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('TimeSheet',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->log = $log;
        /**
         * edit:can
         * reason:��̬������ʱ��������
         * */
        $entityname=getEntitynameByModulename('TimeSheet');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
     /*
    date��20130916
    reason:������Ϣ�ֶ�
    edit by chj
    
    function getRelated($Type)
    {
         global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','TimeSheet'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    } */
    function save_module($module) {
        global $weixin_user;
        $i=1;
        $tabid = getTabid($module);
        
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
        //记录保存前的分录信息
        $before_db_value_arr = $obj->save_before_detailinfo();
        //��ȡ������ϸ�ֶ�
        require_once(globalStatic::$root_directory.'include/TabDetailFields/TabDetailFields.php');
        $TabDetailFields = new TabDetailFields($tabid);
        $tabDetailFields = $TabDetailFields->getTabDetailFields();
        $expensedetailids=array();
        if($_REQUEST['action'] != 'TimeSheetAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW' && $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails'){
            //ls 20220818 BUG0055316 工时，编辑保存，分录会自动增加(参考费用报销单Expense.php)
            $tab_name_index = $this->tab_name_index;
            $query = 'delete from ld_timesheetdetailscf where timesheetdetail_id in( select timesheetdetail_id from ld_timesheetdetail where timesheet_id = ?) ';
            $this->db->pquery($query,array($this->id));
            $query = 'delete from ld_timesheetdetail where timesheet_id = ?';
            $this->db->pquery($query,array($this->id));

			$row_cnt = $_REQUEST['rowcnt'];
			$tab_name_index = $this->tab_name_index;
			do{
				$insertTable = array();
				// 1��ʾɾ����  2��ʾ����
				if($_REQUEST['hidden_rowid_'.$i] == 1 || $_REQUEST['hidden_rowid_'.$i] == 2 || empty($_REQUEST['workdate'.$i])){
					/*if(!empty($_REQUEST[$this->Detail_table_id.$i])){
						$deleteRowId[] = $_REQUEST[$this->Detail_table_id.$i];
					}*/
					$i++;
					continue;
				}
				foreach($tabDetailFields as $columnname => $field){
					$columnname = $field->getColumnName();
					$tablename = $field->getTableName();
					$savedatabase = $field->getSaveDataBase();
					if($savedatabase == 'no'){
						continue;
					}
					if($field->getNewLine() == 1)
				        $value= $_REQUEST[$columnname];
					else
						$value = $_REQUEST[$columnname . $i];
     	              if($field->getFieldType() == 'CheckBox'){
						if($value === 'on'||$value==1){
							$value = 1;
						}else{
							$value = 0;
						}
					}
					if($field->getFieldType() == 'SelectComBox'){
						//$value = implode(' |##| ',$value);
						$value = str_replace('########'," |##| ",$value);
					}
					//Դ��
					if($field->getFieldType() == 'SelectSource'){
						if($columnname == 'entitytypeid'){
							$insertTable[$tablename][$columnname] = $value;
							$entitype = $_REQUEST['select_' . $columnname . $i];
                            //editor:gyq_20190830 reason:0037902:
                            // 企业微信：新增的佣金单，关联服务合同，保存后 ld_commission2payment 表 entitytype 没有赋值  2019/8/30 15:28
                            if($weixin_user->environment_weixin){
                                $entitype = $_REQUEST['entitytype'. $i];
                            }
							$insertTable[$tablename]['entitytype'] = $entitype;
							if(!empty($entitype) && !empty($value)){
								$insertTable[$tablename]['entitytype_value'] = getModuleHref($entitype,$value);
							}
						}
					}
                    $insertTable[$tablename][$columnname] = $value;
				}
				foreach($insertTable as $tablename => $columvalues){
					$column = array_keys($columvalues);
					$updatefld = array();
					if($tablename != strtolower($this->table_name)){
						foreach($column as $col){
							$updatefld[] = $col . '=?';
						}
						//��ϸ
						if($tablename == $this->Detail_table){
					
							/*if(!empty($_REQUEST[$this->Detail_table_id.$i])){
								$query = 'update '.$tablename.' set '.implode(',',$updatefld).' where ' . $this->Detail_table_id . '=? and '.$this->table_index.'=?';
								$id = $_REQUEST[$this->Detail_table_id.$i];//��ϸ��id
								array_push($columvalues, $_REQUEST[$this->Detail_table_id.$i]);
								array_push($columvalues, $this->id);
								$this->db->pquery($query,$columvalues);
							}else{*/
								$query = 'insert into '.$tablename.'('.$this->table_index.','.implode(',',$column). ',sequence) values('.$this->id.','.generateQuestionMarks($columvalues).',?);';
                                $columvalues['sequence']=$i;
								$this->db->pquery($query,$columvalues);
								$id=$this->db->getLastInsertID();
                                
//							}
                            
                             //记录新旧Detail_table_id用于保存修改日志
                             if($_REQUEST[$this->Detail_table_id.$i]>0){
                                $detail_id = $_REQUEST[$this->Detail_table_id.$i];
                                $new_detailid_arr[$detail_id] = $id;
                             }else{
                                $new_detailid_arr[$id] = $id;
                                $detail_id = $id;
                             }
                             if(is_array($insertTable[$this->Detail_table_scf])&&sizeof($insertTable[$this->Detail_table_scf])>0){
                                $request_value_arr[$detail_id] = array_merge($columvalues,$insertTable[$this->Detail_table_scf]);
                            }else{
                                $request_value_arr[$detail_id] = $columvalues;
                            }
                            //记录行数与lineitem_id的关系
                            $new_lineitemid[$i] = array('new_lineitemid'=>$id,'old_lineitemid'=>$_REQUEST[$this->focus->Detail_table_id.$i]);
						}//��ϸscf
						else if($tablename == $this->Detail_table_scf){
							/*$query = 'select 1 from ' . $this->Detail_table_scf . ' where ' . $this->Detail_table_id .' = ?';
							$result = $this->db->pquery($query,array($id));
							if($this->db->num_rows($result) >= 1){
								$query = 'update '.$tablename.' set '.implode(',',$updatefld).' where ' . $this->Detail_table_id . '=?';
								array_push($columvalues, $_REQUEST[$this->Detail_table_id.$i]);
								$this->db->pquery($query,$columvalues);
							}else{*/
								$query = 'insert into '.$tablename.'('.$this->Detail_table_id.','.implode(',',$column). ') values('.$id.','.generateQuestionMarks($columvalues).')';
								$this->db->pquery($query,$columvalues);
//							}
						}
					}
				}
				$i++;
			}while($i<=$row_cnt);
            $obj->insertIntoImage($new_lineitemid);
		}
        
        //保存分录修改日志
        $obj->save_moduleddetail_log($before_db_value_arr,$new_detailid_arr,$request_value_arr);
		//����
		foreach($insertTable as $tablename => $columvalues){
			$column = array_keys($columvalues);
			$updatefld = array();
			if($tablename == strtolower($this->table_name)){
				foreach($column as $col){
					$updatefld[] = $col . '=?';
				}
				$query = 'update '.$tablename.' set '.implode(',',$updatefld).' where ' . $this->table_index . '=?';
				array_push($columvalues,$this->id);
				$this->db->pquery($query,$columvalues);
			}
		}
		/*if(count($deleteRowId) >= 1){
			foreach($deleteRowId as $id){
				$query = 'delete from ' . $this->Detail_table . ' where ' . $this->Detail_table_id .' = ?';
				$this->db->pquery($query,array($id));
				$query = 'delete from ' . $this->Detail_table_scf . ' where ' . $this->Detail_table_id .' = ?';
				$this->db->pquery($query,array($id));
			}
		}*/
      }  
    
    /**
     * Apply security restriction (sharing privilege) query part for List view.
     */
    function getListViewSecurityParameter($module) {
        global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
        return $ScopOfAuthority->getModuleListViewQuery();
    }
    function getDirectType($fieldlabel){
		global $adb;
		if(!empty($fieldlabel)){
			$query = "select labelbol from ld_desk where fieldlabel = '".$fieldlabel."' and labelbol like '%timesheet_%' limit 1";
			$result = $adb->pquery($query,array());
			$labelbol = $adb->query_result($result,0,0);
			if($labelbol == 'timesheet_direct'){
				return 'Direct';
			}else{
				return 'Indirect';
			}
		}
		return '';
	}
        
    function trash($module, $id)
    {    
       global $adb;       
        parent::trash($module,$id);
    }
    /*
    function getListQuery()
    {
         $query = "SELECT DISTINCT ld_timesheet.*,ld_timesheet.timesheet_id as crmid
			FROM ld_timesheet 
			left JOIN ld_timesheetcf
			        ON ld_timesheet.timesheet_id = ld_timesheetcf.timesheet_id		
			LEFT JOIN ld_users
				ON ld_users.id = ld_timesheet.smownerid ";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_timesheet.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_timesheet.timesheet_id";
			$query .= " WHERE ld_timesheet.deleted = 0 " . $where;    
      return $query;
    }*/
    
}
TimeSheet::require_file();
?>