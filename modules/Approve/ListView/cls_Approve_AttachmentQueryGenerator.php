<?php
crm_load_class_file('AttachmentQueryGenerator','include/QueryGenerator');
class cls_Approve_AttachmentQueryGenerator extends AttachmentQueryGenerator
{
    	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		parent::__construct($module, $user,$customerview,$productDetailsobj);
		crm_load_class_file('cls_Approve_Common_Sql','modules/Approve/ListView');
		$this->approveSql = cls_Approve_Common_Sql::getApproveColumn_sql($module).$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;  
    }

	public function getQuery($popup='',$type='1'){

		$sql=parent::getQuery('');
		$select_columns=$this->getSelectColumn(getTabid($this->module));
        $select_columns.=','.$this->moduleobj->table_name.'.approveurgent ';//ls 2021-08-11  【ID1001881】航港：加急（优先）审批
        $select_columns.=','.$this->moduleobj->table_name.'.approveexpediting ';//zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数 
        

        $fromclause=$this->getFromClause();
      
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$where=$this->getWhereClause();
		if($type==1)
		{
			$sql =  ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause .$this->approveSql;
            if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }
            $sql.=$where;
            //gyqCom reason:移动端没有SearchScope参数 date:20170301
			if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
				$sql .= $this->chart_owner;
			}

            return $sql;
		}
		else if($type==2)
		{
			$sql= ' SELECT '.$select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '. $this->noPinyinFromClause .$this->approveSql;
            if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }
            return $sql;
		}
	}
     public function setFieldSql($conditionInfo){
         include_once(globalStatic::$root_directory.'modules/Approve/ListView/ApproveCommon.php');
        $fieldSql=ApproveCommonFieldSql($conditionInfo);
        if(empty($fieldSql))
         {
            return   parent::setFieldSql($conditionInfo);
            
         }
         else
         {
            if($conditionInfo['name']=='approveby_user')
            {
                $this->whereFieldTables['tmp_approve']= "  ld_users   as approveby_user_user on approveby_user_user.id=tmp_approve.approveby_user ";
            }
            return $fieldSql;
            
         }
    }
	public function getMeta($module) {
		parent::getMeta($module);
        global $adb;
		static $approvemetas;
        if(is_array($approvemetas))
        {
            return $approvemetas[$module];
        }
        crm_load_class_file('Approve_Field','modules/Approve/ListView');
        $meta_fieldobj= new Approve_Field($module,$adb);
		$approvemetas[$module]=$meta_fieldobj;
		return $meta_fieldobj;
	
	}
	public function getLeftOrderBy($tableList){
		return '';
	}
}
?>