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



class ProjectMilestone extends CRMEntity {
	var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['ProjectMilestone']='ProjectMilestone';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $table_name = 'ld_projectmilestone';
	var $table_index= 'projectmilestoneid';
    var $table_code='projectmilestone_no';//表编号字段(审批中心)
	var $column_fields = Array();
    var $module_name='ProjectMilestone';
	/** Indicator if this is a custom module or standard module */
	var $IsCustomModule = true;

	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_projectmilestonecf', 'projectmilestoneid');

	/**
	 * Mandatory for Saving, Include tables related to this module.
	 */
	var $tab_name = Array('ld_crmentity', 'ld_projectmilestone', 'ld_projectmilestonecf');

	/**
	 * Mandatory for Saving, Include tablename and tablekey columnname here.
	 */
	var $tab_name_index = Array(
		'ld_crmentity' => 'crmid',
		'ld_projectmilestone'   => 'projectmilestoneid',
	    'ld_projectmilestonecf' => 'projectmilestoneid');

/*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('projectmilestone'=>'','users'=>'','company'=>'','project'=>'');


	// Make the field link to detail view from list view (Fieldname)
	var $list_link_field = 'projectmilestonename';

	// For Popup listview and UI type support
	var $search_fields = Array(
		/* Format: Field Label => Array(tablename, columnname) */
		// tablename should not have prefix 'lingdang_'
		'Project Milestone Name'=> Array('projectmilestone', 'projectmilestonename'),
		'Milestone Date' => Array ('projectmilestone', 'projectmilestonedate'),
		'Type' =>Array ('projectmilestone', 'projectmilestonetype'),
	);
	var $search_fields_name = Array(
		/* Format: Field Label => fieldname */
		'Project Milestone Namee'=> 'projectmilestonename',
		'Milestone Date' => 'projectmilestonedate',
		'Type' => 'projectmilestonetype',
	);

	// For Popup window record selection
	var $popup_fields = Array('projectmilestonename');

	// Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
	var $sortby_fields = Array();

	// For Alphabetical search
	var $def_basicsearch_col = 'projectmilestonename';

	// Column value to use on detail view record text display
	var $def_detailview_recname = 'projectmilestonename';

	// Required Information for enabling Import feature
	var $required_fields = Array('projectmilestonename'=>1);

	// Callback function list during Importing
	var $special_functions = Array('set_import_assigned_user');

	var $default_order_by = 'projectmilestonedate';
	var $default_sort_order='ASC';
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('createdtime', 'modifiedtime');

	function __construct() {
		global  $currentModule;
		
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('ProjectMilestone',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
		$this->log = $log;
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('ProjectMilestone');
        $this->list_link_field=$entityname['fieldname'];
	}
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','ProjectMilestone'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
	function save_module($module) {
	   global $adb,$projectstatus_old,$current_user;
               //项目里程碑新增生成摘要
        if($this->mode !='edit' && !empty($this->column_fields['projectid'])){
            InsertProjectabstract($this->column_fields['projectid'],$this->id,$module,'create');
        }
        
	}
     //项目摘要
 function get_projectabstract($id, $cur_tab_id, $rel_tab_id, $actions = false) {
    
		global $currentModule, $adb,$current_user;
		//列头
        $listview_header = array(
            getFixedLabel('TIMES'),
            getFixedLabel('OPERATOR'),
            getFixedLabel('OPERATORTYPE'),
            getFixedLabel('DESCRIPTION'),
        );
        //获取内容
        $query = 'select module,smcreatorid,createdtime,description,recordid from ld_projectabstract where recordid = ? order by createdtime desc';
        $result = $adb->pquery($query,array($id));
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i < $num_rows; $i++){
            $related_module = $adb->query_result($result,$i,'module');
            $description = $adb->query_result($result,$i,'description');
            $recordid = $adb->query_result($result,$i,'recordid');
            if($description =='edit'){
                $description = '删除';
            }else{
                $description = '新增';
            }
            $focus = CRMEntity::getInstance($related_module);
            $entityarray = getEntitynameInfo(getTabid($related_module));
            
            $query = 'select ' . $entityarray['fieldname'] . ' from ' . $entityarray['tablename'] . ' where ' . $entityarray['entityidfield'] .'=? limit 1';
            $res = $adb->pquery($query,array($recordid));
            $entityname = '<a referencemodule="'.$related_module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">' . $adb->query_result($res,0,0) . '</a>';
            $desc = $description . getTranstab($related_module) .'[' . $entityname. ']';
            $listview_entries[$i] = array(
                'createdtime' => $adb->query_result($result,$i,'createdtime'),
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
        $return_value = array('header'=>$listview_header,'entries'=>$listview_entries   ,'navigation'=>$navigationOutput,'fieldwidth'=>'');
		return $return_value;
 }

	/**
	 * Return query to use based on given modulename, fieldname
	 * Useful to handle specific case handling for Popup
	 */
	function getQueryByModuleField($module, $fieldname, $srcrecord) {
		// $srcrecord could be empty
	}

	/**
	 * Get list view query (send more WHERE clause condition if required)
	 
	function getListQuery($module, $where='') {
		 $query = 'SELECT 
							ld_projectmilestone.projectmilestoneid as crmid,LD_projectmilestone.* '.$fromclause.' 
						FROM
							ld_projectmilestone 
						LEFT JOIN ld_users 
							ON ld_projectmilestone.smownerid = ld_users.id 
						left join ld_projectmilestonecf 
							on ld_projectmilestonecf.projectmilestoneid = ld_projectmilestone.projectmilestoneid';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_projectmilestone.projectmilestoneid";
		   $query .= "  WHERE ld_projectmilestone.deleted = 0 " . $where;
		return $query;
	}*/

	/**
	 * Apply security restriction (sharing privilege) query part for List view.
	 */
	function getListViewSecurityParameter($module) {
		global $current_user,$adb;
    	$is_admin=is_admin($current_user);

		$sec_query = '';
		$tabid = getTabid($module);
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
		if($is_admin==false && $ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE) {

				$sec_query .= " AND (ld_crmentity.smownerid in($current_user->id) OR ld_crmentity.smownerid IN
					(
						SELECT ld_user2role.userid FROM ld_user2role
						INNER JOIN ld_users ON ld_users.id=ld_user2role.userid
						INNER JOIN ld_role ON ld_role.roleid=ld_user2role.roleid
						WHERE ld_role.parentrole LIKE '".$current_user_parent_role_seq."::%'
					)
					OR ld_crmentity.smownerid IN
					(
						SELECT shareduserid FROM ld_tmp_read_user_sharing_per
						WHERE userid=".$current_user->id." AND tabid=".$tabid."
					)
					OR
						(";

					// Build the query based on the group association of current user.
					if(sizeof($current_user_groups) > 0) {
						$sec_query .= " ld_groups.groupid IN (". implode(",", $current_user_groups) .") OR ";
					}
					$sec_query .= " ld_groups.groupid IN
						(
							SELECT ld_tmp_read_group_sharing_per.sharedgroupid
							FROM ld_tmp_read_group_sharing_per
							WHERE userid=".$current_user->id." and tabid=".$tabid."
						)";
				$sec_query .= ")
				)";
		}
		return $sec_query;
	}

	
	/**
	 * Transform the value while exporting
	 */
	function transform_export_value($key, $value) {
		return parent::transform_export_value($key, $value);
	}
    function get_lessionplan($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user;
		$this_module = $currentModule;
        $related_module = 'LessionPlan';
	
		$other = CRMEntity::getInstance($related_module);
       
		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;
		$button = '';
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= '<a class="Anu1_a" title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
				onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
				<span>'.getFixedLabel('SELECT').'</span>
				</a>';
			}
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
                $button .= '<a class="Anu1_a" title="'.getFixedLabel('CREATE').'"
                href="index.php?module='.$related_module.'&action=EditView&return_module='.$related_module.'&return_action=DetailView&Create=yes&projectid='.$id.'&account_id='.$_REQUEST['account_id'].'&contact_id='.$_REQUEST['contact_id'].'&potential_id='.$_REQUEST['potential_id'].'&salesorder_id='.$_REQUEST['salesorder_id'].'" target="_blank"/>
                <img src="themes/softed/button/icon_add.png" /><span>'.getFixedLabel('CREATE').'</span>
                </a>';
			}
		}
		$query = "select ld_lessionplan.* from ld_lessionplan
inner join ld_projectmilestone on ld_lessionplan.projectid = ld_projectmilestone.projectmilestoneid 
inner join ld_crmentity on ld_crmentity.crmid = ld_lessionplan.lessionplanid 
where ld_lessionplan.deleted =0 and ld_projectmilestone.projectmilestoneid = ".$id;
        //echo 'query1:'.$query.'<br>';
		crm_load_function_file('GetRelatedList','include','RelatedListView');
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}
	/**
	 * Function which will give the basic query to find duplicates
	 */
	function getDuplicatesQuery($module,$table_cols,$field_values,$ui_type_arr,$select_cols='') {
		$select_clause = "SELECT ". $this->table_name .".".$this->table_index ." AS recordid, ld_users_last_import.deleted,".$table_cols;

		// Select Custom Field Table Columns if present
		if(isset($this->customFieldTable)) $query .= ", " . $this->customFieldTable[0] . ".* ";

		$from_clause = " FROM $this->table_name";
		//$from_clause .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";

		// Consider custom table join as well.
		if(isset($this->customFieldTable)) {
			$from_clause .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index";
		}
		$from_clause .= " LEFT JOIN ld_users ON ld_users.id = $this->table_name.smownerid
						LEFT JOIN ld_groups ON ld_groups.groupid = $this->table_name.smownerid";

		$where_clause = "	WHERE $this->table_name.deleted = 0";
		$where_clause .= $this->getListViewSecurityParameter($module);

		if (isset($select_cols) && trim($select_cols) != '') {
			$sub_query = "SELECT $select_cols FROM  $this->table_name AS t ";
			// Consider custom table join as well.
			if(isset($this->customFieldTable)) {
				$sub_query .= " LEFT JOIN ".$this->customFieldTable[0]." tcf ON tcf.".$this->customFieldTable[1]." = t.$this->table_index";
			}
			$sub_query .= " WHERE $this->table_name.deleted=0 GROUP BY $select_cols HAVING COUNT(*)>1";
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

	
}

ProjectMilestone::require_file();
?>