<?php
Class cls_Common_SqlWX{

    static function getApproveColumn_sql(){
		global $approvestatus,$goapprovelogsql;
		$search = $_REQUEST['filter']['searchcontent'];
        $searchmodule = $_REQUEST['filter']['searchmodule'];
        if(empty($approvestatus)){ //待处理
			$rawsql  = self::getapprovalof_sql();
		}else if($approvestatus == 1){//已处理
			$rawsql  = self::getapproved_sql();
        /*}else if($approvestatus == 4){//已驳回
            $rawsql  = self::getrejected_sql();*/
		}else if($approvestatus == 3){//我提交的
		    $rawsql  =self::getmysubmission_sql();  
            return ' INNER JOIN ('.$rawsql.') as tmp_approve on tmp_approve.crmid = ';
		}
        if($goapprovelogsql){
            return $rawsql;
        }else{
            return ' INNER JOIN ('.$rawsql.') as tmp_approve on tmp_approve.crmid = ';
        }
        
		return '';
	}
	
	//待处理
	static function getapprovalof_sql(){
		global $current_user;

        if(!empty($_REQUEST['implodesetype'])&&empty($_REQUEST['fromapprovemodule'])){
            $setype1 = ' where ld_crmentity.setype in (\''.$_REQUEST['implodesetype'].'\') ';
            $setype2 = ' AND t.setype in (\''.$_REQUEST['implodesetype'].'\') ';
        }else{
            $setype1 = ' where ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\' ';
            $setype2 = ' AND t.setype = \''.$_REQUEST['fromapprovemodule'].'\' ';
        }
        
        $query="SELECT
    	crmid,
    	stepname,
    	GROUP_CONCAT(DISTINCT substring_index(substring_index(t.nextstepapproveby,',', b.seq+1 ),',',- 1) ORDER BY substring_index(substring_index(t.nextstepapproveby,',', b.seq+1 ),',',- 1)+0) AS nextstepapproveby,
    	approvetime as approveby_datetime,
    	setype
    FROM (
    	SELECT
    			b.crmid,
    			d.name AS stepname,
    			CASE
    				WHEN b.logconcurrentid>0 THEN 
    					(SELECT GROUP_CONCAT(nextstepapproveby ) FROM ld_approvelog WHERE crmid=b.crmid AND isfinished='no')
    				ELSE b.nextstepapproveby
    			END AS nextstepapproveby,
    			CASE 
    				WHEN b.createdtime<='1600-01-01 00:00:00' THEN
    					(SELECT createdtime FROM ld_approvelog WHERE crmid=b.crmid AND isfinished='yes' AND logconcurrentid=0 ORDER BY seqtime LIMIT 1)
    				ELSE b.createdtime 
    			END AS approvetime,
    			c.setype,
    			b.approveresult
    	FROM ld_approvelog b
    	INNER JOIN ld_crmentity c ON c.crmid=b.crmid
    	INNER JOIN  (
    		SELECT
    			crmid,
    			id,
    			logconcurrentid
    		FROM (
    			SELECT 
    				crmid,
    				id,
    				logconcurrentid
    			FROM ld_approvelog 
    			WHERE crmid>0 
    			HAVING 1
    			ORDER BY seqtime DESC,id desc
    		) a
    		GROUP BY crmid
    	) a ON b.id=a.id AND b.crmid=a.crmid
    	LEFT JOIN ld_approvestep d ON d.id=b.nextstepid
    ) t
    LEFT JOIN sequence b ON b.seq<(length(t.nextstepapproveby)-length(REPLACE(t.nextstepapproveby,',',''))+1) 
    WHERE (approveresult IN (1,5,10,6,12) AND FIND_IN_SET($current_user->id,nextstepapproveby))   
    $setype2    
    GROUP BY crmid
    ORDER BY approveby_datetime ";
    return $query;
	/*	$sql = 'SELECT
					ld_approvelog.crmid,
                    ld_approvelog.createdtime approveby_datetime
				FROM
					ld_approvelog
				INNER JOIN (
					SELECT
						max(sss.id) AS idd,
						setype
					FROM
						(select ld_approvelog.crmid,ld_approvelog.id,ld_crmentity.setype from ld_approvelog
LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_approvelog.crmid  '.$setype1.') as sss
					WHERE
						sss.id > 0 
					GROUP BY
						sss.crmid
				) AS t ON ld_approvelog.id = t.idd
				WHERE
					(approveresult = 1 or approveresult = 5 or approveresult = 10)
				AND FIND_IN_SET('.$current_user->id.', nextstepapproveby)'.$setype2;*/
                
                
                                
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
				) as tmp on tmp.idd = ld_approvelog.id where ld_approvelog.stepid > 0';
		return $sql;
	}

    //已驳回
    /*static function getrejected_sql(){
        global $current_user;
        $sql = 'select ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime,
					ld_approvestep. NAME AS approve_step from ld_approvelog
				LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.stepid
				INNER JOIN(
					select max(id) as idd,crmid from ld_approvelog 
					where ld_approvelog.approved_by = '.$current_user->id.' and crmid in (select ld_approvelog.crmid from ld_approvelog
					where ld_approvelog.approved_by = '.$current_user->id.' and ld_approvelog.approveresult = 4 GROUP BY crmid) GROUP BY crmid
				) as tmp on tmp.idd = ld_approvelog.id where ld_approvelog.approveresult = 4';
        return $sql;
    }*/
    
    //我提交的
    static function getmysubmission_sql(){
        global $current_user;
        $sql = 'SELECT
					ld_approvelog.approved_by AS approveby_user,
					ld_approvelog.crmid,
					ld_approvelog.createdtime AS approveby_datetime
				FROM
					ld_approvelog
				INNER JOIN (
					SELECT
						max(sss.id) AS idd,
						setype
					FROM
						(
							SELECT
								ld_approvelog.crmid,
								ld_approvelog.id,
								ld_crmentity.setype
							FROM
								ld_approvelog
							LEFT JOIN ld_crmentity ON ld_crmentity.crmid = ld_approvelog.crmid
							WHERE
								ld_crmentity.setype = \''.$_REQUEST['fromapprovemodule'].'\'
                            AND ld_approvelog.stepid=-1
						) AS sss
					WHERE
						sss.id > 0
					GROUP BY
						sss.crmid
				) AS t ON ld_approvelog.id = t.idd
				WHERE
					t.setype = \''.$_REQUEST['fromapprovemodule'].'\' and approved_by='.$current_user->id;
        return $sql;
    }
}

?>