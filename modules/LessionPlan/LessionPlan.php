<?php
include_once('config.php');

require_once('user_privileges/default_module_view.php');

class LessionPlan extends CRMEntity
{
    var $log;
    var $db;
    var $table_name='ld_lessionplan';
    var $table_index='lessionplanid';
    var $table_code='lessionplanid';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_lessionplan','ld_lessionplanscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_lessionplan'=>'lessionplanid','ld_lessionplanscf'=>'lessionplanid');
   	var $customFieldTable = Array('ld_lessionplanscf', 'lessionplanid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();
    var $sortby_fields=Array('lessionplanid');
    //管理模块
    var $relatedtab=array();
            
    var $list_link_field= '';
   	var $search_fields_name = Array();
    var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'commission_no');
	var $default_order_by = 'lessionplanid';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="lessionplanid";
    function __construct()
    {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj = Field::getInstance('LessionPlan',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('LessionPlan');
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','LessionPlan'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
            "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
            );   
            $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
        }
    }*/
    function save($module_name, $fileid = '')
    {
    	global $current_user;
    
        $module = new $module_name();
    	//Event triggering code
    //	require_once("include/events/include.inc");
    	global $adb;
        $i=1;
        $lessionplaninfo=json_decode($_REQUEST['lessionplaninfo'],true);
        
        //while(true)
        //{ 
          foreach($lessionplaninfo as $tmpindex=>$info)  
          {
                if(isset($_REQUEST['recordid']) && $_REQUEST['recordid'] > 0)
                {
    				$updateLession = 'update ld_lessionplan set projectid = ?,servicecontractsid = ?,projectmilestoneid = ?,projecttaskid = ?,lessiondate=?,
    				lessiontype = ?,starttime=?,endtime=?,remark=?,modifiedby=? where lessionplanid = ?';
    				$lessiontype = $info['starttime'] . '-' . $info['endtime'];
    				$adb->pquery($updateLession,array($info['projectid'],$info['servicecontractsid'],$info['projectmilestoneid'],$info['projecttaskid'],$info['lessiondate'],$lessiontype,
                    $info['starttime'],$info['endtime'],$info['remark'],$current_user->id,$_REQUEST['recordid']));
                }
                else
                {
                    $current_id = $adb->getUniqueID("ld_crmentity");
                    $sql = " insert into ld_crmentity(crmid,setype) values (?,?)";
                    $adb->pquery($sql,array($current_id,$module_name));
                    $crmid = $current_id;
                    $insertLession = "insert into ld_lessionplan(lessionplanid,projectid,servicecontractsid,projectmilestoneid,projecttaskid,lessiondate,lessiontype,starttime,endtime,remark,smcreatorid,modifiedby,createdtime,modifiedtime,smownerid) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                    $lessiontype = $info['starttime'] . '-' . $info['endtime'.$i];
                  
                    $adb->pquery($insertLession,array($crmid,$info['projectid'],$info['servicecontractsid'],$info['projectmilestoneid'],$info['projecttaskid'],$info['lessiondate'],$lessiontype,
                    $info['starttime'],$info['endtime'],$info['remark'],$current_user->id,$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),$current_user->id));   
                }
          }
            
          return ['code'=>"ok",[],'success'];
    }
   	function save_module($module)
	{
    }
    /*
    function getListQuery()
    {
         $query = "SELECT DISTINCT ld_lessionplan.*,ld_lessionplan.lessionplanid as crmid
			FROM ld_lessionplan 
			left JOIN ld_lessionplanscf
			        ON ld_lessionplan.lessionplanid = ld_lessionplanscf.lessionplanid
		
			LEFT JOIN ld_users
				ON ld_users.id = ld_lessionplan.smownerid ";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_lessionplan.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_lessionplan.lessionplanid";
			$query .= " WHERE ld_lessionplan.deleted = 0 " . $where;    
      return $query;
    }*/
}

?>