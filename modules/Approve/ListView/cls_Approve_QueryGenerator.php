<?php
crm_load_class_file('QueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_QueryGenerator  extends QueryGenerator{

	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		parent::__construct($module, $user,$customerview,$productDetailsobj);
		crm_load_class_file('cls_Approve_Common_Sql','modules/Approve/ListView');
		$this->approveSql = cls_Approve_Common_Sql::getApproveColumn_sql($module).$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;
    }

    public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($puputype='',$type="1") {
		//$sql=parent::getQuery('');
        global $current_user;
		$select_columns=$this->getSelectClauseColumnSQL();

        $select_columns.=','.$this->moduleobj->table_name.'.approveurgent ';//ls 2021-08-11  【ID1001881】航港：加急（优先）审批(联系人等模块审批中心)
        $select_columns.=','.$this->moduleobj->table_name.'.approveexpediting ';//zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数 
        
        unset($this->selecttables['tmp_approve']);
     
		$this->chart_where = $this->getWhereClause();
		$fromclause=$this->getFromClause();
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		 
		if($type==1)
		{
            if($_REQUEST['approvestatus']==0)
            {
                $this->chart_where.=" and  $baseTable.approvestatus='".constant('D_A_S_APPROVALOF')."' and FIND_IN_SET($current_user->id,$baseTable.currentapprover) ";
                $sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause ;
            }
            else
                $sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause .$this->approveSql;
            if(array_key_exists('tmp_approve',(array)$this->approvewhereFieldTables))
            {
                $sql.=' left join '.$this->approvewhereFieldTables['tmp_approve'];
            }
            $sql.=$this->chart_where;
            //gyqCom reason:移动端没有SearchScope参数 date:20170301
            if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
                $sql .= $this->getSmOwnerSearchSql;
            }
            
            return $sql;
		}
		else if($type==2)
		{
            if ($_REQUEST['approvestatus'] == 0) {
                $sql = ' SELECT ' . $select_columns . $this->noPinyinFromClause;
            } else
                $sql = ' SELECT ' . $select_columns . $this->noPinyinFromClause . $this->approveSql;
            if(array_key_exists('tmp_approve',(array)$this->approvewhereFieldTables))
            {
                $sql.=' left join '.$this->approvewhereFieldTables['tmp_approve'];
            }
           
            return $sql;
            
		}
	}
    
     public function setFieldSql($conditionInfo){
        if($conditionInfo['name']=='approveby_user')
        {
            $fieldSql="  approveby_user_user.last_name like '%".$conditionInfo['value']."%'";
            $this->approvewhereFieldTables['tmp_approve']= "  ld_users   as approveby_user_user on approveby_user_user.id=tmp_approve.approveby_user ";
            return $fieldSql;
        }
        else if($conditionInfo['name']=='approveby_datetime')
        {
            $fieldSql="  tmp_approve.approveby_datetime  like '%".$conditionInfo['value']."%'";
            return $fieldSql;
        }
        else
        {
            return parent::setFieldSql($conditionInfo);
        
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