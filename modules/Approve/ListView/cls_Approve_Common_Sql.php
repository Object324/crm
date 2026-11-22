<?php
Class cls_Approve_Common_Sql{
	
	public function __construct(){
		
	}
	static function getApproveColumn_sql($module=''){
		global $approvestatus;

		if(empty($approvestatus)){ //待处理
			$sql  =' INNER JOIN ('.self::getapprovalof_sql().') as tmp_approve on tmp_approve.crmid = ';
		}else if($approvestatus == 1){//已处理
			$sql  =' INNER JOIN ('.self::getapproved_sql().') as tmp_approve on tmp_approve.crmid = ';
		}else if($approvestatus == 2){//待处理和已处理的全部数据
			$sql  =' INNER JOIN ('.self::getapprovalof_sql() . ' UNION ALL '.self::getapproved_sql().') as tmp_approve on tmp_approve.crmid = ';
		}else if($approvestatus == 3){//我提交的
		    $sql  =' INNER JOIN ('.self::getmysubmission_sql().') as tmp_approve on tmp_approve.crmid = ';
        }else if($approvestatus == 4){//被驳回的
            $sql  =' INNER JOIN ('.self::getrejected_sql($module).') as tmp_approve on tmp_approve.crmid = ';
		}
      
		return $sql;
	}
	
	//待处理
	static function getapprovalof_sql(){
		global $current_user;
       
        $sql = '
				SELECT
					ld_approvelog.crmid
				FROM
					ld_approvelog
				
				INNER JOIN (
					SELECT
						max(ld_approvelog.id) AS idd,
						setype
					FROM
						ld_approvelog
                                LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_approvelog.crmid 
                                 where ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
					
					GROUP BY
						ld_approvelog.crmid
				) AS t ON ld_approvelog.id = t.idd
				WHERE
					(approveresult = 1 or approveresult = 5 or approveresult=10 or approveresult=6)
				AND FIND_IN_SET('.$current_user->id.', nextstepapproveby)
				AND t.setype = \''.$_REQUEST['fromapprovemodule'].'\''.self::getapproved_30().'
				';
                
        //35839: 审批中心：待处理、我提交的列表界面，发起人和发起时间，应该取最近一次提交人和提交时间
        //35975: （1.6）审批中心>待处理>发起人：当某条单据审批一次后发起人变为了上一步审批人，而不是提交该单据的用户。（需要补丁）
	/*	$sql = 'select min_tmp.approveby_user AS approveby_user,
						temp.crmid,
						min_tmp. approveby_datetime,
						temp.approve_step from (
				SELECT
					ld_approvelog.crmid,
                    ld_approvelog.approved_by,
                    ld_approvelog.createdtime,
					ld_approvestep. NAME AS approve_step
				FROM
					ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.nextstepid
				INNER JOIN (
					SELECT
						max(ld_approvelog.id) AS idd,
						setype
					FROM
						ld_approvelog
                                LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_approvelog.crmid 
                                 where ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
					
					GROUP BY
						ld_approvelog.crmid
				) AS t ON ld_approvelog.id = t.idd
				WHERE
					(approveresult = 1 or approveresult = 5 or approveresult=10)
				AND FIND_IN_SET('.$current_user->id.', nextstepapproveby)
				AND t.setype = \''.$_REQUEST['fromapprovemodule'].'\''.self::getapproved_30().') as temp 
				LEFT JOIN (
					SELECT
						ld_approvelog.approved_by AS approveby_user,
						ld_approvelog.crmid,
						ld_approvelog.createdtime AS approveby_datetime
					FROM
						ld_approvelog
					INNER JOIN (
						SELECT
							max(ld_approvelog.id) AS idd,
							setype
						FROM
							 ld_approvelog
                                inner JOIN ld_crmentity on ld_crmentity.crmid = ld_approvelog.crmid 
                                 where ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
						and 
							ld_approvelog.id > 0
                            and ld_approvelog.stepid=-1
						GROUP BY
							ld_approvelog.crmid
					) AS t ON ld_approvelog.id = t.idd
					WHERE
					t.setype = \''.$_REQUEST['fromapprovemodule'].'\'
				)	 as min_tmp on min_tmp.crmid = temp.crmid';
                
                */
                
                
		return $sql;

	}

	//已处理
	//editor:gyq_122 date:20170208 reason:and crmid之前增加approve_by判断
	static function getapproved_sql(){
		global $current_user;
		$sql = 'select ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep. NAME AS approve_step from ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN(
					select max(id) as idd,crmid from ld_approvelog 
					where ld_approvelog.approved_by = '.$current_user->id.' and crmid in (select ld_approvelog.crmid from ld_approvelog
					where ld_approvelog.approved_by = '.$current_user->id.' and ld_approvelog.stepid > 0 GROUP BY crmid) GROUP BY crmid
				) as tmp on tmp.idd = ld_approvelog.id where ld_approvelog.stepid > 0' . self::getapproved_30();
		return $sql;
	}
    
    //我提交的
    static function getmysubmission_sql(){
        global $current_user;
        $sql = '
			
					SELECT
				ld_approvelog.createdtime AS approveby_datetime,
				ld_approvelog.crmid,ld_approvelog.approveresult AS approveby_result
				
			FROM
				ld_approvelog
			INNER JOIN (
				SELECT
					max(id) AS idd,
					createdtime,
					setype,
					ld_approvelog.crmid
				FROM
					ld_approvelog
				LEFT JOIN ld_crmentity ON ld_crmentity.crmid = ld_approvelog.crmid
				WHERE
					ld_approvelog.approved_by = '.$current_user->id.'
				AND ld_approvelog.stepid = - 1
				AND ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
				GROUP BY
					ld_approvelog.crmid
			)  AS t ON ld_approvelog.id = t.idd
		
				WHERE
					ld_approvelog.approved_by = '.$current_user->id ;
        //35832: （1.6登录）单据查看明细界面：提交审批再执行回撤操作后，审批中心>>我提交的 单据查看列表界面应该不显示该条单据（客户模块测试）
	/*	$sql = '
			SELECT
				ld_approvelog.createdtime AS approveby_datetime,
				ld_approvelog.crmid,
				temp_max.approveresult AS approveby_result,
				temp_max.`name` AS approve_step
			FROM
				ld_approvelog
			INNER JOIN (
				SELECT
					max(id) AS idd,
					createdtime,
					setype,
					ld_approvelog.crmid
				FROM
					ld_approvelog
				LEFT JOIN ld_crmentity ON ld_crmentity.crmid = ld_approvelog.crmid
				WHERE
					ld_approvelog.approved_by = '.$current_user->id.'
				AND ld_approvelog.stepid = - 1
				AND ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
				GROUP BY
					ld_approvelog.crmid
			) AS temp_min ON temp_min.idd = ld_approvelog.id
			INNER JOIN (
				SELECT
					ld_approvelog.approveresult,
					ld_approvestep.`name`,
					tem.max_idd,
					ld_approvelog.crmid
				FROM
					ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN (
					SELECT
						max(id) AS max_idd,
						setype
					FROM
						ld_approvelog
					LEFT JOIN ld_crmentity ON ld_crmentity.crmid = ld_approvelog.crmid
					WHERE
						ld_approvelog.approved_by = '.$current_user->id.'
					AND ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
					GROUP BY
						ld_approvelog.crmid
				) AS tem ON tem.max_idd = ld_approvelog.id and ld_approvelog.stepid<>-2
			) AS temp_max ON temp_max.crmid = temp_min.crmid
		';*/
	
        //echo $sql;
        return $sql;
    }

	//被驳回的
    static function getrejected_sql($module){
        global $current_user;
		$focus = CRMEntity::getInstance($module);
		$tablename = $focus->table_name;
		$tableindex = $focus->table_index;
		$smownercolumn = $focus->getSmownerColumName();
        $sql = "SELECT ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep.`name` AS approve_step from ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid				
				INNER JOIN(
					select max(id) as idd,crmid from ld_approvelog 
					where crmid in (select ld_approvelog.crmid from ld_approvelog
					INNER JOIN ".$tablename." ON ".$tablename.".".$tableindex." = ld_approvelog.crmid
					where ".$tablename.".".$smownercolumn." = ".$current_user->id."
						 and ".$tablename.".approvestatus = '已驳回'
						 and ld_approvelog.approveresult = 4 GROUP BY crmid) GROUP BY crmid
				) as tmp on tmp.idd = ld_approvelog.id where ld_approvelog.approveresult = 4" . self::getapproved_30();
        return $sql;
    }
	static function getapproved_30(){
		global $approvestatus;
		if($approvestatus == 2){
			$startdate=date("Y-m-d",strtotime("$start_date -30 days")).' 00:00:00';
			$enddate=Date('Y',time()).'-'.Date('m',time()).'-'.Date('t',time()).' 23:59:59';
			return ' and ld_approvelog.createdtime between \''. $startdate.'\' and \''.$enddate.'\' ';
		}else{
			return '';
		}
	}
}

?>