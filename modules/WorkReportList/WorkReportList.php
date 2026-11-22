<?php



class WorkReportList extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['WorkReportList']='WorkReportList';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='WorkReportList';
	var $table_name = "ld_workreport";
	var $table_index= 'workreportid';
	var $tab_name = Array('ld_crmentity','ld_workreport','ld_workreportcf','ld_workreply','ld_workreport2user');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_workreport'=>'workreportid','ld_workreportcf'=>'workreportid','ld_workreply'=>'workreportid','ld_workreport2user'=>'workreportid');//连表查询时的关联关系
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_workreportcf', 'workreportid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('createdtime');

	var $list_link_field= 'workreport_no';
    //和主表关联的模块
    var $relatedtab=array('accounts'=>'','contacts'=>'','products'=>'');


    var $table_code='workreport_no';
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("smcreatorid"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('workreport_no');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'workreport_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'workreport_no';

    var $workreport_logtype;
	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('WorkReportList',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('WorkReportList');
        $this->list_link_field=$entityname['fieldname'];

//        $this->workreport_logtype = array('0'=>getFixedLabel('ALL'),
//            '1'=>getFixedLabel('JOURNAL'),//daily
//            '2'=>getFixedLabel('WEEKPLAN'),//weekly
//            '3'=>getFixedLabel('MONTHPLAN'));//monthly
        $this->workreport_logtype = array('0'=>getFixedLabel('ALL'));//默认页签
        //页签动态显示启用的日月周报
        $sql = "SELECT `type` FROM ld_workreport_showset WHERE belongtype = 'blog' AND presence = 'yes' AND type IN('dayreport','weekreport','monthreport');";
        $result=$this->db->pquery($sql,array());
        if($this->db->num_rows($result)>0)
        {
            for($i=0;$i<$this->db->num_rows($result);$i++)
            {
                $type=$this->db->query_result($result,$i,'type');
                if ($type == 'dayreport') {
                    //zkt 20240326 BUG20240326-06  把日志关掉后，工作汇报（列表）中，周计划月计划页签显示的内容对应错误（华：通用问题，81kfbcrm也有相同的问题）
                    $this->workreport_logtype["1"]=getFixedLabel('JOURNAL');//数组的键与数据库存储的值要对应
                    //$this->workreport_logtype = array_merge($this->workreport_logtype,array("1"=>getFixedLabel('JOURNAL')));//数组的键与数据库存储的值要对应
                }elseif ($type == 'weekreport'){
                    $this->workreport_logtype["2"]=getFixedLabel('WEEKPLAN');
                    //$this->workreport_logtype = array_merge($this->workreport_logtype,array('2'=>getFixedLabel('WEEKPLAN')));
                }else{
                    $this->workreport_logtype["3"]=getFixedLabel('MONTHPLAN');
                    //$this->workreport_logtype = array_merge($this->workreport_logtype,array('3'=>getFixedLabel('MONTHPLAN')));
                }
            }
        }

	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}

    public function getSmownerColumName()
    {

        return 'smcreatorid';
    }

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

    function getDetailQuery()
    {
        $select = "SELECT 
    ld_workreport.workreportid,
	ld_workreport.workreport_no,
	ld_workreport.smcreatorid,
	ld_workreport.createdtime,
	ld_workreport.reuser,
	ld_workreport.commentscore,
	ld_workreport.commenttime,
	ld_workreport.ccuser,
	ld_workreport.type,
	ld_workreply.text,
	ld_workreport.sendlog_workdate,
	ld_workreport.relatedto_account,
	ld_workreport.relatedto_contact,
	ld_workreport.relatedto_product,
	
	usercreator.id AS userid,
	usercreator.last_name AS usercreator,
	usercreator.wx_userid AS usercreator_wx_userid,
        ";
        $select .= $this->getSQLColumn();
        $leftioin = " 
        LEFT JOIN ld_workreply ON ld_workreply.workreportid = ld_workreport.workreportid
AND ld_workreply.type = 1
LEFT JOIN ld_users AS usercreator ON ld_workreport.smcreatorid = usercreator.id
LEFT JOIN ld_workreportcf ON ld_workreportcf.workreportid = ld_workreport.workreportid ";
        $where = " where ld_workreport.workreportid = ".$this->id;

        $sql = $select . " from ld_workreport ".$leftioin.$where;

        return $sql;
    }

    //获取要当前类型下要查询的特殊字段
    function getSQLColumn()
    {

        $Allfields=$this->getAllFields();
        foreach ($Allfields as $fieldid=>$fieldinfo) {
            if ($fieldinfo['type'] == $this->column_fields['type']) {
                $columns[]=$fieldinfo['tablename'].'.'.$fieldinfo['columnname'];
            }
        }
        return implode(', ',$columns);
    }

    //获取要当前类型下详情页要显示的特殊字段
    function getShowSpecialColumn()
    {
        $Allfields=$this->getAllFields();
        foreach ($Allfields as $fieldid=>$fieldinfo) {
            if ($fieldinfo['type'] == $this->column_fields['type']) {
                $showcolumns[]=array("columnname"=>$fieldinfo['columnname'],"fieldlabel"=>$fieldinfo['fieldlabel']);
            }
        }
        return $showcolumns;
    }

    //获取模块分类下所有字段
    function getAllFields()
    {
        global $languageType,$adb;
        $sql = "SELECT
	ld_field.*, ld_tranlabel.fieldlabel AS tranlabel
FROM
	ld_field
INNER JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_field.fieldid

WHERE
	ld_tranlabel.trantable ='ld_field'
AND ld_tranlabel.tabid =?
AND ld_field.tabid =?
AND ld_field.presence in(0,2)


AND ld_field.columnname not like 'saleskit%'
AND ld_field.columnname not like 'signaddress%'
order by  ld_field.sequence asc,ld_field.fieldid asc,ld_tranlabel.languagetype desc";
        $params=array(getTabid($this->module_name),getTabid($this->module_name));
        $result=$adb->pquery($sql,$params);
        $num_rows=$adb->num_rows($result);

        for($i=0;$i<$num_rows;$i++)
        {

            $fieldid=$adb->query_result($result,$i,'fieldid');
            $columnname=$adb->query_result($result,$i,'columnname');
            $tablename=$adb->query_result($result,$i,'tablename');
            $type=$adb->query_result($result,$i,'categorytype');
            $tranlabel=$adb->query_result($result,$i,'tranlabel');
            $en_tranlabel=$adb->query_result($result,$i+1,'tranlabel');

            $fieldInfos[$fieldid]=array('fieldid'=>$fieldid,'columnname'=>$columnname,'tablename'=>$tablename,'type'=>$type, 'fieldlabel'=>$tranlabel,'en_tranlabel'=>$en_tranlabel);
            $i++;
        }
        return $fieldInfos;

    }

    function getUserImage($userid='')
    {
        global $adb;
        $sql = "SELECT
	ld_users.last_name,
	ld_users.wx_userid,
	ld_attachments.attachmentsid,
	ld_attachments.path,
	ld_attachments.newfile_name AS userimagename,
	ld_attachments.cloud_path,
	ld_attachments.storage_location
FROM
 ld_users
LEFT JOIN ld_salesmanattachmentsrel ON ld_users.id = ld_salesmanattachmentsrel.smid
LEFT JOIN ld_attachments ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid
WHERE
	ld_users.id = ?";
        $result=$adb->pquery($sql,array($userid));

        $last_name=$adb->query_result($result,0,'last_name');
        $wx_userid=$adb->query_result($result,0,'wx_userid');
        $attachmentsid=$adb->query_result($result,0,'attachmentsid');
        $path=$adb->query_result($result,0,'path');
        $userimagename=$adb->query_result($result,0,'userimagename');
        $storage_location=$adb->query_result($result,0,'storage_location');
        if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,0,'cloud_path');
        }
        else{
            if(!empty($attachmentsid)&&!empty($path)){
                $userfilepath=$path.$userimagename;
            }
            else{
                // ljj 20231201 XUQIU1000927 更换默认头像
                $userfilepath=getDefaultAvatar($userid);
            }
            $userfilepath_True = globalStatic::$root_directory.$userfilepath;
            //加载图片时图片错误时，显示默认图片
            if(!file_exists($userfilepath_True)||!@getimagesize($userfilepath_True)){
                $userfilepath='themes/images/defaultuser.png';
            }
        }
        $userinfo['userid']=$userid;
        $userinfo['last_name']=$last_name;
        $userinfo['wx_userid']=$wx_userid;
        $userinfo['userimage']=$userfilepath;
        return $userinfo;

    }

}
WorkReportList::require_file();
?>