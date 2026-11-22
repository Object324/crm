<?php
crm_load_class_file('AccountsQueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_AccountsQueryGenerator  extends AccountsQueryGenerator{

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
        $select_columns.=','.$this->moduleobj->table_name.'.approveurgent ';//ls 2021-08-11  【ID1001881】航港：加急（优先）审批（客户审批中心）
		$select_columns.=','.$this->moduleobj->table_name.'.approveexpediting ';//zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数 
        
		$fromclause=$this->getFromClause();
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$where=$this->getWhereClause();
		$this->chart_where = $this->getWhereClause();
		if($type==1)
		{
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause ;//.$this->approveSql;
            /*if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }*/
            
            if($_REQUEST['approvestatus']==1)
            {
                $sql.=$this->approveSql;
                $sql.=$where;
            }
            else if($_REQUEST['approvestatus']==3)
            {
                //edit:can 20210402 045149: （61mis.com/kfbcrm）审批中心-我提交的-客户；当前登录成员“已批准”和“已驳回”的客户审批单据没有显示在审批中心，只有“审批中”的客户单据显示
                  $sql.=$where;
                 $sql.=' and  FIND_IN_SET('.$current_user->id.' ,ld_account.approvesubmitter)';
            }
            else
            {
                $sql.=$where;
                 $sql.=' and  FIND_IN_SET('.$current_user->id.' ,ld_account.currentapprover)';
            
            }
			
			//gyqCom reason:移动端没有SearchScope参数 date:20170301
			if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
				$sql .= $this->getSmOwnerSearchSql;
			}
          
			return $sql;
		}
		else if($type==2)
		{
			$sql= ' SELECT ' . $select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '. $this->noPinyinFromClause ;
            /*if(array_key_exists('tmp_approve',$this->whereFieldTables))
            {
                $sql.=' left join '.$this->whereFieldTables['tmp_approve'];
            }*/
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
    
     public function getCustomViewFieldObj($tablename,$fieldname)
    {
        if($tablename=='tmp_approve')
        {

            $fieldinfo=new fieldInfo();
            $fieldinfo->setTableName($tablename);
            $fieldinfo->setFieldName($fieldname);
            $fieldinfo->setcolumnName($fieldname);
            if($fieldname=='approveby_user')
            {
                $fieldinfo->setuitType(53);
            }
            else
            {
                $fieldinfo->setuitType(70);
            }
            return $fieldinfo;
        }
        else
        {
            return parent::getCustomViewFieldObj($tablename,$fieldname);
        }
    }
	public function getLeftOrderBy($tableList){
		return '';
	}

    //@edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（审批中心客户模块列头）
    public function getMeta($module) {
	    //由于客户模块定义了联系人模块的字段，所以列头获取需要重写基类QueryGenerator的getMeta方法
	    if($module=='Contacts')
	        return parent::getMeta($module);
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
}

?>