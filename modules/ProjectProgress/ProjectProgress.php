<?php


class ProjectProgress extends CRMEntity {
    var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['ProjectProgress']='ProjectProgress';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $table_name = 'ld_projectprogress';
    var $table_index= 'projectprogressid';
    var $column_fields = Array();
    var $table_code='projectprogress_no';//表编号字段(审批中心)
    /** Indicator if this is a custom module or standard module */
    var $IsCustomModule = true;
    var $module_name='ProjectProgress';

    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = Array('ld_projectprogresscf', 'projectprogressid');

    /**
     * Mandatory for Saving, Include tables related to this module.
     */
    var $tab_name = Array('ld_crmentity', 'ld_projectprogress', 'ld_projectprogresscf');

    /**
     * Mandatory for Saving, Include tablename and tablekey columnname here.
     */
    var $tab_name_index = Array(
        'ld_crmentity' => 'crmid',
        'ld_projectprogress'   => 'projectprogressid',
        'ld_projectprogresscf' => 'projectprogressid');

    /**
     * Mandatory for Listing (Related listview)
     */
     /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('project'=>'','users'=>'','projectprogress'=>'');

    // Make the field link to detail view from list view (Fieldname)
    var $list_link_field = 'projectprogress_no';

  
    // For Popup window record selection
    var $popup_fields = Array('projectprogress_no');

    // Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
    var $sortby_fields = Array();

    // For Alphabetical search
    var $def_basicsearch_col = 'projectprogress_no';

    // Column value to use on detail view record text display
    var $def_detailview_recname = 'projectprogress_no';

    // Required Information for enabling Import feature
    var $required_fields = Array('projectprogress_no'=>1);

    // Callback function list during Importing
    var $special_functions = Array('set_import_assigned_user');

    var $default_order_by = 'projectprogress_no';
    var $default_sort_order='ASC';
    // Used when enabling/disabling the mandatory fields for the module.
    // Refers to ld_field.fieldname values.
    var $mandatory_fields = Array('createdtime', 'modifiedtime');

    function __construct() {
        global  $currentModule;
       
        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('ProjectProgress',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->log = $log;
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('ProjectProgress');
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','ProjectProgress'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    
    function save_module($module) {
        //反写项目的工时和费用
		$this->UpdateProjectInfo($this);
		//反写项目任务的工时和费用
		$this->UpdateProjectTaskInfo($this);
    }
     //项目进度新增、编辑 反写 项目计划工时和费用
    function UpdateProjectTaskInfo($focus){
            $projecttask_focus=CRMEntity::getInstance("ProjectTask");
            if(array_key_exists('projecttaskid',$this->column_fields))
            {
                if($this->column_fields['projecttaskid']>0)
                {
                    $projecttask_focus->updateProjecTaskHas($this->column_fields['projecttaskid']);
                }
                else
                {
                    $adb=PearDatabase::getInstance();
                    $sql='select projecttaskid from ld_projectprogress where projectprogressid=?';
                    $result=$adb->pquery($sql,array($focus->id));
                    $projecttaskid=$adb->query_result($result,0,'projecttaskid');
                    if(!empty($projecttaskid))
                    {
                        $projecttask_focus->updateProjecTaskHas($projecttaskid);
                    }
                }
            }
        
    }
    //项目进度新增、编辑 反写 项目工时和费用
    function UpdateProjectInfo($focus){
        global $current_user,$adb;
          
            
       // if(!empty($focus->column_fields['timecost']) || !empty($focus->column_fields['totalcost'])){
            //新增保存
           
            if($focus->mode != 'edit'){
                //判断项目是否为空
                if(!empty($focus->column_fields['projectid'])){
                    $query = 'update ld_project set hastime = ifnull(hastime,0)+?,hascost = ifnull(hascost,0)+? where projectid = ?';
                    $adb->pquery($query,array($focus->column_fields['timecost'],$focus->column_fields['totalcost'],$focus->column_fields['projectid']));
                   // dump(array($focus->column_fields['timecost'],$focus->column_fields['totalcost'],$focus->column_fields['projectid']));
                }            
            }else if(!empty($focus->column_fields['projectid'])){//编辑
				$query = 'select sum(ifnull(timecost,0))as times,sum(ifnull(totalcost,0)) as total,projectid from ld_projectprogress
                where  projectid=? and deleted=0 GROUP BY projectid';
				$result = $adb->pquery($query,array($focus->column_fields['projectid']));
              
                
				$num_rows = $adb->num_rows($result);
				if($num_rows > 0){
					for($i = 0; $i < $num_rows; $i++){
						$times = $adb->query_result($result,$i,'times');
						$total = $adb->query_result($result,$i,'total');
						$projectid = $adb->query_result($result,$i,'projectid');
						if(!empty($projectid)){
							$update_sql = 'update ld_project set hastime = ?,hascost = ? where projectid = ?';
							$adb->pquery($update_sql,array($times,$total,$projectid));
						}
					}
				}
                else{
                    
                    
                    $update_sql = 'update ld_project set hastime = ?,hascost = ? where projectid = ?';
							$adb->pquery($update_sql,array(0,0,$focus->column_fields['projectid']));
                }
            }
          
        //}
    }
    /**
     * Apply security restriction (sharing privilege) query part for List view.
     */
    function getListViewSecurityParameter($module) {
        global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
        return $ScopOfAuthority->getModuleListViewQuery();
    }
   
        
    function trash($module, $id)
    {    
       global $adb;       
        parent::trash($module,$id);
        $oldmode=$this->mode;
        $this->mode='edit';
        if((array_key_exists('projectid',$this->column_fields)&&empty($this->column_fields['projectid']))||
          array_key_exists('projecttaskid',$this->column_fields)&&empty($this->column_fields['projecttaskid'])  )
        {
            $sql='select projectid,projecttaskid,timecost from ld_projectprogress where projectprogressid=? ';
            $result=$adb->pquery($sql,array($id));
            $this->column_fields['projectid']=$adb->query_result($result,0,'projectid');
            $this->column_fields['projecttaskid']=$adb->query_result($result,0,'projecttaskid');
            $this->column_fields['timecost']=$adb->query_result($result,0,'timecost');
            
        }
       
         $this->UpdateProjectInfo($this);
            //反写项目任务的工时和费用
		$this->UpdateProjectTaskInfo($this);
         $this->mode=$oldmode;
         $this->column_fields['projectid']=0;
         $this->column_fields['projecttaskid']=0;
         $this->column_fields['timecost']=0;
        
    }
    /*
    function getListQuery()
    {
         $query = "SELECT DISTINCT ld_projectprogress.*,ld_projectprogress.projectprogressid as crmid
			FROM ld_projectprogress 
			left JOIN ld_projectprogresscf
			        ON ld_projectprogress.projectprogressid = ld_projectprogresscf.projectprogressid
		
			LEFT JOIN ld_users
				ON ld_users.id = ld_projectprogress.smownerid ";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_projectprogress.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_projectprogress.projectprogressid";
			$query .= " WHERE ld_projectprogress.deleted = 0 " . $where;    
      return $query;
    }*/
}
ProjectProgress::require_file();
?>