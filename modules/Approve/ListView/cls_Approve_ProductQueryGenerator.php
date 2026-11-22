<?php
crm_load_class_file('ProductQueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_ProductQueryGenerator  extends ProductQueryGenerator{
    public $approveSql;

	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
	    global $adb;
      
		parent::__construct($module, $user,$customerview,$productDetailsobj);
       
		crm_load_class_file('cls_Approve_Common_Sql','modules/Approve/ListView');
		$this->approveSql = cls_Approve_Common_Sql::getApproveColumn_sql($module).$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;

        //@edit:liushuai @date:2020-07-13 @reason: 1000895：审批中心查询优化：（审批中心基本查找对象里没有Approve_Field.php定义的字段对象，需要重载方法$this->fieldobj->getModuleAllPreseneceFields()）
        crm_load_class_file('Approve_Field','modules/Approve/ListView');
        $this->fieldobj= new Approve_Field($module,$adb);
          
    }
    public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($popup='',$type='1'){

         global $current_user;
		$sql=parent::getQuery('');
		$select_columns=$this->getSelectColumn(getTabid($this->module));
        $select_columns.=','.$this->moduleobj->table_name.'.approveurgent ';//ls 2021-08-11  【ID1001881】航港：加急（优先）审批(合同订单等模块审批中心和序时簿列表)
        $select_columns.=','.$this->moduleobj->table_name.'.approveexpediting ';//zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数 
		
		$fromclause=$this->getFromClause();
        
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
     
       
		$where=$this->getWhereClause();
        
		if($type==1)
		{
		   if($_REQUEST['approvestatus']==0)
           {
            $where.=" and  $baseTable.approvestatus='".constant('D_A_S_APPROVALOF')."' and FIND_IN_SET($current_user->id,$baseTable.currentapprover) ";
            $sql =' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause;
           }
           else
			$sql =' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause .$this->approveSql;
           
            if(array_key_exists('tmp_approve',$this->whereMainTable))
            {
                $sql.=' left join '.$this->whereMainTable['tmp_approve'];
            }
            $sql.= $where;
            //gyqCom reason:移动端没有SearchScope参数 date:20170301
			if(isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
				$sql .= $this->chart_owner;
			}

            return $sql;
		}
		else if($type==2)
		{
		   if($_REQUEST['approvestatus']==0)
           {
            //$where.=" and  approvestatus='审批中' and FIND_IN_SET(40,currentapprover) ";
            $sql= ' SELECT '.$select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '. $this->noPinyinFromClause;
           }
           else
			 $sql= ' SELECT '.$select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '. $this->noPinyinFromClause .$this->approveSql;
            
            if(array_key_exists('tmp_approve',$this->whereMainTable))
            {
                
                $sql.=' left join '.$this->whereMainTable['tmp_approve'];
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
    //29241: 系统右下方的审批通知提醒，设为已读后，点击【审批中心】，进入单据列表界面显示没有找到任何记录。
     public  function isStockQuery($module)
     {
        return '';
     }
}

?>