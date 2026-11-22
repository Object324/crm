<?php
crm_load_class_file('TabDetailQueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_TabDetailQueryGenerator  extends TabDetailQueryGenerator{

	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		parent::__construct($module, $user,$customerview,$productDetailsobj);
		crm_load_class_file('cls_Approve_Common_Sql','modules/Approve/ListView');
		$this->approveSql = cls_Approve_Common_Sql::getApproveColumn_sql($module).$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;  
    }
    public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($popup='',$type='1'){
        global $current_user;
		$sql=parent::getQuery('');
		$select_columns=$this->getSelectColumn(getTabid($this->module));
        $select_columns.=','.$this->moduleobj->table_name.'.approveurgent ';//ls 2021-08-11  【ID1001881】航港：加急（优先）审批（加班单等）
        $select_columns.=','.$this->moduleobj->table_name.'.approveexpediting ';//zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数 
        
        $fromclause=$this->getFromClause();
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$where_clause=$this->getWhereClause();
		if($type==1)
		{
            if($_REQUEST['approvestatus']==0)
           {
            //带审批
            $where_clause.=" and  $baseTable.approvestatus='".constant('D_A_S_APPROVALOF')."' and FIND_IN_SET($current_user->id,$baseTable.currentapprover) ";
            $sql =' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause;
           }
           else
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause .$this->approveSql;
	       	if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }
            $sql.=$where_clause;
			if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
				$sql .= $this->chart_owner;
			}
			return $sql;
		}
		else if($type==2)
		{
		  if($_REQUEST['approvestatus']==0)
           {
            $sql= ' SELECT '.$select_columns . $this->noPinyinFromClause ;
           }
           else
			$sql= ' SELECT '.$select_columns . $this->noPinyinFromClause .$this->approveSql;
            if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }
            return $sql;
		}
	}
     public function setFieldSql($conditionInfo){
	    //ls 20220916 BUG0056395  批量审批时，如果加了查询条件，审批步骤为：提交审批，全选多页数据批量审批时保存无反应
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