<?php


class ProjectTask extends CRMEntity {
    var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['ProjectTask']='ProjectTask';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $table_name = 'ld_projecttask';
    var $table_index= 'projecttaskid';
    var $column_fields = Array();
    var $table_code='projecttask_no';//表编号字段(审批中心)
    /** Indicator if this is a custom module or standard module */
    var $IsCustomModule = true;
    var $module_name='ProjectTask';

    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = Array('ld_projecttaskcf', 'projecttaskid');

    /**
     * Mandatory for Saving, Include tables related to this module.
     */
    var $tab_name = Array('ld_crmentity', 'ld_projecttask', 'ld_projecttaskcf');

    /**
     * Mandatory for Saving, Include tablename and tablekey columnname here.
     */
    var $tab_name_index = Array(
        'ld_crmentity' => 'crmid',
        'ld_projecttask'   => 'projecttaskid',
        'ld_projecttaskcf' => 'projecttaskid');

    /**
     * Mandatory for Listing (Related listview)
     */
     /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('project'=>'','users'=>'','company'=>'','projecttask'=>'','accounts'=>'','contacts'=>'');

    // Make the field link to detail view from list view (Fieldname)
    var $list_link_field = 'projecttaskname';

  
    // For Popup window record selection
    var $popup_fields = Array('projecttaskname');

    // Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
    var $sortby_fields = Array();

    // For Alphabetical search
    var $def_basicsearch_col = 'projecttaskname';

    // Column value to use on detail view record text display
    var $def_detailview_recname = 'projecttaskname';

    // Required Information for enabling Import feature
    var $required_fields = Array('projecttaskname'=>1);

    // Callback function list during Importing
    var $special_functions = Array('set_import_assigned_user');

    var $default_order_by = 'projecttaskname';
    var $default_sort_order='ASC';
    // Used when enabling/disabling the mandatory fields for the module.
    // Refers to ld_field.fieldname values.
    var $mandatory_fields = Array('createdtime', 'modifiedtime');

    function __construct() {
        global  $currentModule;
       
        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('ProjectTask',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->log = $log;
           /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('ProjectTask');
        $this->list_link_field=$entityname['fieldname'];
    }
  
    
   function save_module($module) {
    global $adb,$projectstatus_old,$current_user;
               //项目任务新增生成摘要
               
        if($this->mode !='edit' && !empty($this->column_fields['projectid'])){
            InsertProjectabstract($this->column_fields['projectid'],$this->id,$module,'create');
        }
         if($_REQUEST['file']=='DetailViewAjax'&&$_REQUEST['ajxaction']=='DETAILVIEW')
       {
            //查看界面的小编辑
            $sql='select projectid from  '.$this->table_name.' where '.$this->table_index.'=?';
            $result=$adb->pquery($sql,array($this->id));
            $projectid=$adb->query_result($result,0,0);
            if($projectid>0)
            {
                $this->column_fields['projectid']=$projectid;
            }
            
        
       }
       
        if(array_key_exists("projectid",$this->column_fields))
        {
            $projectids=array($this->column_fields["projectid"]);
            $this->updateRelated_Project($projectids);
       }
            
    
    }
    /**
     *  //修改项目任务相关的项目的字段（例如项目的任务数)
     * $projectids：项目ID数组集合
     * */
    function updateRelated_Project($projectids)
    {
        global $adb;
        if(is_array($projectids)&&sizeof($projectids)>0)
        {
            
            $projectids=implode(",",$projectids);

            //ZKT 使用inner join时空白的不能处理
            //修改项目任务相关的项目已完成任务数
            $sql="update ld_project LEFT JOIN
                 (SELECT  count(projectid) as totalcount,projectid from ld_projecttask 
                     where ld_projecttask.deleted=0 and  ld_projecttask.projectid in($projectids)  GROUP BY projectid)
                as tmp_one  on tmp_one.projectid=ld_project.projectid left join (
                 select count(projectid) as  finishcount  ,projectid from ld_projecttask where ld_projecttask.deleted=0 and  projectid in($projectids) and ifnull(projecttaskstatus,'')='已完成' GROUP BY projectid) as tmp_two
                   on tmp_two.projectid=ld_project.projectid  set  completetask=concat( ifnull( tmp_two.finishcount,0),'/',ifnull(tmp_one.totalcount,0)) where ld_project.projectid in($projectids)";
            $adb->pquery($sql,array());
     
        }
        
    }
     //在项目计划模块中，编辑操作时，确保已用费用和已用工时字段值正确。
     function updateProjecTaskHas($id){
        global $adb;
        if(!empty($id)){
            $query = 'select sum(ifnull(timecost,0))as times,sum(ifnull(totalcost,0)) as total from ld_projectprogress where projecttaskid = ? and deleted = 0';
        
            $result = $adb->pquery($query,array($id));
            if($adb->num_rows($result)>0)
            {
                $times = $adb->query_result($result,0,'times');
                $total = $adb->query_result($result,0,'total');
                $update_sql = 'update ld_projecttask set hastime = ?,hascost = ? where projecttaskid = ?';
                $adb->pquery($update_sql,array($times,$total,$id));
            }
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
            }else if($description == 'create'){
                $description = '新增';
            }else{
                $description = '关闭';
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

   
    function getListViewSecurityParameter($module) {
        global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
        return $ScopOfAuthority->getModuleListViewQuery();
    }
    function get_lessionplan($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;
        $related_module = 'LessionPlan';
		$other =CRMEntity::getInstance();
		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;
		$button = '';
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
					onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
    				<span>'.getFixedLabel('SELECT').'</span>
    				</a>';
			}
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
                $button .= '<a title="'.getFixedLabel('CREATE').'"
                href="index.php?module='.$related_module.'&action=EditView&return_module='.$related_module.'&return_action=DetailView&Create=yes&projectid='.$id.'&account_id='.$_REQUEST['account_id'].'&contact_id='.$_REQUEST['contact_id'].'&potential_id='.$_REQUEST['potential_id'].'&salesorder_id='.$_REQUEST['salesorder_id'].'" target="_blank"/>
                <span>'.getFixedLabel('CREATE').'</span>
                </a>';
			}
		}
		$query = "select ld_lessionplan.* from ld_lessionplan
inner join ld_projecttask on ld_lessionplan.projectid = ld_projecttask.projecttaskid 
inner join ld_crmentity on ld_crmentity.crmid = ld_lessionplan.lessionplanid 
where ld_lessionplan.deleted =0 and ld_projecttask.projecttaskid = ".$id;
        //echo 'query1:'.$query.'<br>';
		crm_load_function_file('GetRelatedList','include','RelatedListView');
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
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
        
        
		$select_clause = "SELECT ". $this->table_name .".".$this->table_index . " AS recordid,$this->list_link_field as entityname, ld_users_last_import.deleted,".$table_cols;

		// Select Custom Field Table Columns if present
		if(isset($this->customFieldTable)) $query .= ", " . $this->customFieldTable[0] . ".* ";

		$from_clause = " FROM $this->table_name";

		//$from_clause .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";

		// Consider custom table join as well.
		if(isset($this->customFieldTable)) {
			$from_clause .= " left JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
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
    /**
     * 批量删除，编辑，修改项
     * 
     * */
    private function massOperation($Allupdate_ids)
    {
       $adb=PearDatabase::getInstance();
        $sql="select projectid from ld_projecttask where deleted=0 and  projecttaskid in($Allupdate_ids)  group by projectid";
            $result=$adb->pquery($sql,array());
            for($ki=0;$ki<$adb->num_rows($result);$ki++)
            {
                $projectid=$adb->query_result($result,$ki,0);
                if(!empty($projectid))
                    $projectids[]=$projectid;
            }
          
            if(sizeof($projectids)>0)
                $this->updateRelated_Project($projectids);
    }
    function   massDelete_after($module,$ids)
    { 
        global $adb;
        parent::massDelete_after($module,$ids);
        if(array_key_exists("projectid",$this->column_fields))
        {
            
            $Allupdate_ids=implode(',',$ids);
            $this->massOperation($Allupdate_ids);
            
        }
    }
    function massChangeOrder_after($module,$ids)
    {
        parent::massChangeOrder_after($module,$ids);
        global  $adb;
        //$_REQUEST['moduleMassDelete']:批量删除
        //$_REQUEST['massChangerOrder']:修改状态
       if(array_key_exists("projectid",$this->column_fields))
        {
            
            $Allupdate_ids=implode(',',$ids);
            $this->massOperation($Allupdate_ids);
        }
    }
     /**
     * 批量修改保存(保存以后)
     * ids:单据id的集合(数组)
     * */
    function  massEdit_save_after($module,$ids)
    {
      parent::massEdit_save_after($module,$ids);
        global  $adb;
        //$_REQUEST['moduleMassDelete']:批量删除
        //$_REQUEST['massChangerOrder']:修改状态
       if(array_key_exists("projectid",$this->column_fields)&&array_key_exists("projecttaskstatus_mass_edit_check",$_REQUEST))
        {
            
            $Allupdate_ids=implode(',',$ids);
            $this->massOperation($Allupdate_ids);
        }
        
    }   
    function trash($module, $id)
    {   
        
       global $adb;
        $versioninfo = getVersionInfo();
        $trade = $versioninfo['trade'];
        $SQL = "SELECT totalcost,projectid FROM ld_projecttask WHERE projecttaskid=$id;";
        $result=$adb->pquery($SQL,array());
        $projectid = 0;
        if($adb->num_rows($result)>0){
            $totalcost = $adb->query_result($result, 0, 'totalcost');
            $projectid = $adb->query_result($result, 0, 'projectid');
            if($trade=='qiaiju'){
                $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost-$totalcost WHERE projectid=$projectid;";
                $adb->pquery($SQL,array());
            }

        }
        parent::trash($module,$id);
        //zkt 20231220 删除后应更新项目的任务状态 BUG0077304 设备安装立项功能为原项目管理功能调整，设备安装调试单为原项目计划功能调整
        if(!empty($projectid)){
            $this->updateRelated_Project(array($projectid));
        }
       
       
    }
    
}
ProjectTask::require_file();
?>