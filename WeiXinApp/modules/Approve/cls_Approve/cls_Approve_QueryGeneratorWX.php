<?php
crm_load_class_file('QueryGeneratorWX','WeiXinApp/QueryGenerator');

//gyq_22
class cls_Approve_QueryGeneratorWX  extends QueryGeneratorWX{
    public $queryobj;
	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		$this->queryobj = parent::getInstance($module, $user,$customerview,$productDetailsobj);
		crm_load_class_file('cls_Common_SqlWX','WeiXinApp/modules/Approve/cls_Approve');
		$this->approveSql = cls_Common_SqlWX::getApproveColumn_sql().$this->queryobj->moduleobj->table_name.'.'.$this->queryobj->moduleobj->table_index;
        //crm_load_class_file('cls_Common_Sql','modules/Approve/ListView');
		//$this->approveSql = cls_Common_Sql::getApproveColumn_sql().$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;                                
    }


	public function getQuery($puputype='',$type="1") {
		$sql=parent::getQuery('');
		$select_columns=$this->getSelectClauseColumnSQL();
		
		$fromclause=$this->getFromClause();
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$this->chart_where = $this->getWhereClause();
       
		if($type==1)
		{
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause .$this->approveSql.$this->chart_where;
			return $sql;
		}
		else if($type==2)
		{
			return ' SELECT '.$select_columns . $this->noPinyinFromClause .$this->approveSql;
		}
	}
    
    public function getListQuery(){
        global $approvestatus,$current_user;
        $sql=$this->queryobj->getQuery('');
      
		$statussql = '';
		$fromclause=$this->queryobj->getFromClause();
		$baseTable=$this->queryobj->moduleobj->table_name;
		$focus=$this->queryobj->moduleobj;
		$this->chart_where = $this->queryobj->getWhereClause();
          
		//editor:gyq_20190308 0036566: （http://222.132.62.18:85/crm [^]）企业微信>灵当CRM>审批中心>已审批>顶部的搜索框录入值进行搜索：搜索不到，落落计划是正常的。
		//chj 2021/1/13 44068: （企业微信移动端-kfbcrm）管理员账户登录；在审批列表界面，右上角筛选，查看范围“高级”选择成员后，筛选出的结果仍是自己负责审批的单据
		if($_REQUEST['SearchScope'] != 'SmOwner_Search_All'){
			$this->chart_owner = $this->queryobj->chart_owner;
		}
       
        $userid=$current_user->id;
        //我提交的页签涉及到查询审批状态
        if($approvestatus==3){
            $searchstatus = $_REQUEST['filter']['searchstatus'];
            $statussql = ','.$baseTable.'.approvestatus ';
            $statuswhere = empty($searchstatus)?'':' and '.$baseTable.'.approvestatus=\''.$searchstatus.'\'';
        }
        if($approvestatus==0)
        {
            //ls 2021-08-11  【ID1001881】航港：加急（优先）审批(移动端待审批 approveurgent)
           $sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index." as indexid,$baseTable.approvetime as  approveby_datetime,$baseTable.approveurgent,$baseTable.approveexpediting "
            .$statussql.$fromclause .$this->chart_where.$this->chart_owner.$statuswhere
         .  "  AND $baseTable.approvestatus = '审批中'
                    AND FIND_IN_SET(
                    	$userid,
                    	$baseTable.currentapprover
                    )";
           
        }
        else if($approvestatus==3)
        {
            //edit:can 20211110 048631: （http://haiminghui.3322.org:85/crm/ [^]）客户问题（海明晖）移动端待办-我提交的看不到我提交审批的单据
            	$approved_sql = ' INNER JOIN (
				SELECT
					ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep. NAME AS approve_step
				FROM
					ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN (
					SELECT
						min(id) AS idd,
						crmid
					FROM
						ld_approvelog
					WHERE
						ld_approvelog.approved_by = '.$userid.'
					AND crmid IN (
						SELECT
							ld_approvelog.crmid
						FROM
							ld_approvelog
						WHERE
							ld_approvelog.approved_by = '.$userid.'
						AND ld_approvelog.stepid =-1
						GROUP BY
							crmid
					)
					GROUP BY
						crmid
				) AS tmp ON tmp.idd = ld_approvelog.id
				WHERE
					ld_approvelog.stepid =-1
			) AS tmp_approve ON tmp_approve.crmid = '.$baseTable.'.'.$focus->table_index;
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index." as indexid,$baseTable.approvetime  as approveby_datetime,$baseTable.approveurgent,$baseTable.approveexpediting "
            .$statussql.$fromclause .$approved_sql.$this->chart_where.$this->chart_owner.$statuswhere;
        
        }
		else if($approvestatus == 4){//2024-4-7 xxy 移动端-被驳回的
			$smownercolumn = $focus->getSmownerColumName();//负责人字段
			$approved_sql = ' INNER JOIN (
				SELECT
					ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep. NAME AS approve_step
				FROM
					ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN (
					SELECT
						max(id) AS idd,
						crmid
					FROM
						ld_approvelog
					WHERE
					crmid IN (
						SELECT
							ld_approvelog.crmid
						FROM
							ld_approvelog
						INNER JOIN '.$baseTable.' ON '.$baseTable.'.'.$focus->table_index.' = ld_approvelog.crmid
						WHERE
							'.$baseTable.'.'.$smownercolumn.' = '.$userid.'
						AND '.$baseTable.'.approvestatus = "已驳回"
						AND ld_approvelog.approveresult = 4
						GROUP BY
							crmid
					)
					GROUP BY
						crmid
				) AS tmp ON tmp.idd = ld_approvelog.id
				WHERE
					ld_approvelog.approveresult = 4
			) AS tmp_approve ON tmp_approve.crmid = '.$baseTable.'.'.$focus->table_index;
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index." as indexid,$baseTable.approvetime  as approveby_datetime,$baseTable.approveurgent,$baseTable.approveexpediting "
            .$statussql.$fromclause .$approved_sql.$this->chart_where.$this->chart_owner.$statuswhere;
        
        }
        else{
			//chj 2021/7/21 46905: （微信小程序-kfbcrm）成员在待办-已审批页签，看到了不是自己操作过审批的单据 ，比如采购发票INV6 成员xia 密码123
			$approved_sql = ' INNER JOIN (
				SELECT
					ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep. NAME AS approve_step
				FROM
					ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN (
					SELECT
						max(id) AS idd,
						crmid
					FROM
						ld_approvelog
					WHERE
						ld_approvelog.approved_by = '.$userid.'
					AND crmid IN (
						SELECT
							ld_approvelog.crmid
						FROM
							ld_approvelog
						WHERE
							ld_approvelog.approved_by = '.$userid.'
						AND ld_approvelog.stepid > 0
						GROUP BY
							crmid
					)
					GROUP BY
						crmid
				) AS tmp ON tmp.idd = ld_approvelog.id
				WHERE
					ld_approvelog.stepid > 0
			) AS tmp_approve ON tmp_approve.crmid = '.$baseTable.'.'.$focus->table_index;
			$sql = ' SELECT distinct  '.$baseTable.'.'.$focus->table_index." as indexid,$baseTable.approvetime  as approveby_datetime,$baseTable.approveurgent,$baseTable.approveexpediting "
            .$statussql.$fromclause .$approved_sql.$this->chart_where.$this->chart_owner.$statuswhere;
        
        }
        return $sql;
    }

	public function getMeta($module) {
		parent::getMeta($module);
        global $adb;
        crm_load_class_file('Approve_Field','modules/Approve/ListView');
        $meta_fieldobj= new Approve_Field($module,$adb);                                
		return $meta_fieldobj;
	
	}
	
	public function getLeftOrderBy($tableList){
		return '';
	}
}

?>