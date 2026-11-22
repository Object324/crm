<?php
/**
 * 审批中心：返回包含模块和处理数量的数组,按数量倒序排序
**/

class cls_Approve_countListView
{
    public $tabpagetype;//0:待处理 1:已处理 3我提交的 4被驳回的
    protected $approvemodule='';//editor:gyqCom0302 reason:移动端审批中心限制模块显示
    public function __construct($tabpagetype)
    {
        $this->tabpagetype = $tabpagetype;
    }
    //获取审批数量
    public function getapprovelist()
    {
        global $adb;
        $approveinfo = [];
        $result = '';

        if($this->tabpagetype==0 || empty($this->tabpagetype)){
            //待处理
            $result = $this->getPendingNumsResult();
        }
        else if($this->tabpagetype==1){
            //已处理
            $result = $this->getProcessedNumsResult();
        }
        else if($this->tabpagetype==3){
            //我提交的  回撤的也需要计数
            $result = $this->getisubmittedNumsResult();
        }
        else if($this->tabpagetype==4){
            //被驳回的
            $result = $this->getApproveRejectedNumsResult();
        }
        if(!empty($result)){
            $num_rows=$adb->num_rows($result);
            if($num_rows>0){
                for($i=0;$i<$num_rows;$i++)
                {
                    $module=$adb->query_result($result,$i,'setype');
                    if(!empty($module) && vtlib_isModuleActive($module)){
                        $approvecount=$adb->query_result($result,$i,'num');
                        $approveinfo[]=array('num'=>$approvecount,'module'=>$module);
                    }
                }
            }
        }
        return $approveinfo;
    }

    //获取待审批的数量列表
    public function getPendingNumsResult(){
        global $adb,$current_user;
        $sql = "select * from ld_systems_deploy  where setype is not null and deploy_value=0; ";
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        $sqlarr = [];
        $userid=$current_user->id;
        for($i=0;$i<$rows;$i++)
        {
            $setype=$adb->query_result($result,$i,'setype');
            if(empty($setype))
            {
                continue;
            }
            if(!vtlib_isModuleActive($setype))
            {
                continue;
            }
            $focus = CRMEntity::getInstance($setype);
            $tableindex=$focus->table_index;
            $tablename=$focus->table_name;
            //王耀文多伦收款单有200万数据，待审批页签很慢
            $sql="select count($tableindex) as num,'$setype' as 'setype' from $tablename where deleted=0 and
                approvestatus='审批中' and  FIND_IN_SET($userid,currentapprover) ";
            $sqlarr[]=$sql;
        }
        $sql=implode(" union all ",$sqlarr ) ;

        $sql="select * from ($sql) as tmp where num>0 ORDER BY num DESC "   ;

        $result=$adb->pquery($sql,array());
        return $result;
    }

    //获取待审批的单据列表 每个模块的数据在一起的  主要是首页的组件:审批中心组件使用
    //这个方法只是把之前首页组件待审批的代码拿过来 未做任何更改
    public function getPendingList(){
        global $adb,$current_user;
        //edit:can 20230327 63588  	http://60.247.158.183:85/crm ；四川中卉；费用报销单(单据编号：FYBX-2303-991)审批流程里面。从审批树显示该阶段只有项目
        //zxm 20231127 模块关闭 那待审批的单据就不应该出现
        //并发审批 没有审批，直接反审批
        $query="SELECT
    	crmid,
    	stepname,
    	GROUP_CONCAT(DISTINCT substring_index(substring_index(t.nextstepapproveby,',', b.seq+1 ),',',- 1) ORDER BY substring_index(substring_index(t.nextstepapproveby,',', b.seq+1 ),',',- 1)+0) AS nextstepapproveby,
    	approvetime,
    	setype,
    	urgent,
        expediting
    FROM (
    	SELECT
    			b.crmid,
    			
    			CASE
    				WHEN b.logconcurrentid>0 THEN 
    					(SELECT GROUP_CONCAT(nextstepapproveby ) FROM ld_approvelog INNER JOIN (select max(logconcurrentid) as maxconcurrentid,crmid
		from ld_approvelog where   isfinished='no'
group by crmid ) as tmpconcurrenct on tmpconcurrenct.maxconcurrentid=ld_approvelog.logconcurrentid and tmpconcurrenct.crmid= ld_approvelog.crmid
											WHERE ld_approvelog.crmid=b.crmid AND nextstepapproveby>0 AND isfinished='no')
    				ELSE b.nextstepapproveby
    			END AS nextstepapproveby,
				CASE
    				WHEN b.logconcurrentid>0 THEN 
    					(SELECT GROUP_CONCAT(name SEPARATOR ' / ') FROM ld_approvelog LEFT JOIN ld_approvestep on ld_approvestep.id = ld_approvelog.stepid WHERE crmid=b.crmid AND nextstepapproveby>0 AND isfinished='no')
    				ELSE d. NAME
    			END AS stepname,
    			CASE 
    				WHEN b.createdtime<='1600-01-01 00:00:00' THEN
    					(SELECT createdtime FROM ld_approvelog WHERE crmid=b.crmid AND isfinished='yes' AND logconcurrentid=0 ORDER BY seqtime LIMIT 1)
    				ELSE b.createdtime 
    			END AS approvetime,
    			c.setype,
    			b.approveresult,
    			b.urgent,
                b.expediting
    	FROM ld_approvelog b
    	INNER JOIN ld_crmentity c ON c.crmid=b.crmid
    	INNER JOIN ld_tab t ON t.name=c.setype
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
    			ORDER BY seqtime DESC,id DESC
    		) a
    		GROUP BY crmid
    	) a ON b.id=a.id AND b.crmid=a.crmid
    	LEFT JOIN ld_approvestep d ON d.id=b.nextstepid
    	LEFT JOIN ld_systems_deploy ON ld_systems_deploy.setype=c.setype
        WHERE ld_systems_deploy.setype <> '' AND ld_systems_deploy.deploy_value=0 and t.presence=0
    ) t
    LEFT JOIN sequence b ON b.seq<(length(t.nextstepapproveby)-length(REPLACE(t.nextstepapproveby,',',''))+1) 
    WHERE (approveresult IN (1,5,10,6,12,14,15,16,17,18) AND FIND_IN_SET(?,nextstepapproveby))       
    GROUP BY crmid
    ORDER BY (case when expediting='yes' then 0 when urgent='yes' then 1 else 2 end),
    approvetime LIMIT 10";

        $result = $adb->pquery($query, array($current_user->id));
        return $this->getApproveResultList($result);
    }

    //获取已处理的数量列表
    public function getProcessedNumsResult(){
        global $adb,$current_user;
        $sql = 'select setype,count(1) as num from ld_crmentity
                inner join ld_approvelog t1 on t1.crmid=ld_crmentity.crmid 
                inner join (select max(id) max_id,crmid from ld_approvelog where ld_approvelog.approved_by=? GROUP BY crmid) as tmp
                on t1.id=tmp.max_id and tmp.crmid=t1.crmid 
                where t1.approved_by=? and t1.stepid>0
                '.$this->approvemodule.'
                GROUP BY setype ORDER BY num desc';
        $result=$adb->pquery($sql,array($current_user->id,$current_user->id));
        return $result;
    }
    //获取已处理的单据列表 每个模块的数据在一起的  主要是首页的组件:审批中心组件使用
    public function getProcessedList(){
        global $adb,$current_user;
        //已处理 先获取前10条数据 再根据模块和单据ID 获取其他数据
        $numssql = "SELECT
	ld_crmentity.setype,
	ld_crmentity.crmid,
	d.`name` as stepname,
    t1.nextstepapproveby,
    t1.createdtime as approvetime,
    t1.urgent,
    t1.expediting
FROM
	ld_crmentity
INNER JOIN ld_approvelog t1 ON t1.crmid = ld_crmentity.crmid
INNER JOIN (
	SELECT
		max(id) max_id,
		crmid
	FROM
		ld_approvelog
	WHERE
		ld_approvelog.approved_by = ?
	GROUP BY
		crmid
) AS tmp ON t1.id = tmp.max_id AND tmp.crmid = t1.crmid
LEFT JOIN ld_approvestep d ON d.id=t1.nextstepid
WHERE
	t1.approved_by = ?
AND t1.stepid > 0
order by (case when expediting='yes' then 0 when urgent='yes' then 1 else 2 end) asc ,t1.seqtime desc limit 10 ;";
        $result = $adb->pquery($numssql, array($current_user->id,$current_user->id));

        return $this->getApproveResultList($result);
    }

    //获取我提交的数量列表
    public function getisubmittedNumsResult(){
        global $adb,$current_user;
        $sql = 'select setype,count(1) as num from ld_crmentity
                inner join ld_approvelog t1 on t1.crmid=ld_crmentity.crmid 
                inner join (select max(id) min_id,crmid from ld_approvelog
                 where ld_approvelog.approved_by = ? and ld_approvelog.stepid = -1 GROUP BY crmid) as tmp
                on t1.id=tmp.min_id and tmp.crmid=t1.crmid 
                inner join(select ld_approvelog.crmid,ld_approvelog.stepid,ld_approvelog.approved_by from (select max(id) as maxidd from ld_approvelog
                  where ld_approvelog.approved_by = ?  group by crmid ) as logmaxidd 
                    inner join ld_approvelog on ld_approvelog.id=logmaxidd.maxidd
                    ) as tmpmaxstepinfo
                    on tmpmaxstepinfo.crmid=t1.crmid
                where t1.approved_by=? 
                '.$this->approvemodule.'   GROUP BY setype ORDER BY num desc ';

        $result=$adb->pquery($sql,array($current_user->id,$current_user->id,$current_user->id));
        return $result;
    }
    //获取我提交的单据列表 每个模块的数据在一起的  主要是首页的组件:审批中心组件使用
    public function getisubmittedList(){
        global $adb,$current_user;
        $sql = 'select 
                setype,
                ld_crmentity.crmid,
                d.`name` as stepname,
                t1.nextstepapproveby,
                t1.createdtime as approvetime,
                t1.urgent,
                t1.expediting
                from ld_crmentity
                inner join ld_approvelog t1 on t1.crmid=ld_crmentity.crmid 
                inner join (select max(id) min_id,crmid from ld_approvelog
                 where ld_approvelog.approved_by = ? and ld_approvelog.stepid = -1 GROUP BY crmid) as tmp
                on t1.id=tmp.min_id and tmp.crmid=t1.crmid 
                inner join(select ld_approvelog.crmid,ld_approvelog.stepid,ld_approvelog.approved_by from (select max(id) as maxidd from ld_approvelog
                  where ld_approvelog.approved_by = ?  group by crmid ) as logmaxidd 
                    inner join ld_approvelog on ld_approvelog.id=logmaxidd.maxidd
                    ) as tmpmaxstepinfo
                    on tmpmaxstepinfo.crmid=t1.crmid
                LEFT JOIN ld_approvestep d ON d.id=t1.nextstepid
                left join (select seqtime,crmid from ld_approvelog where stepid=-1 group by crmid order by seqtime desc )summitsql on t1.crmid=summitsql.crmid
                where t1.approved_by=? 
                '.$this->approvemodule.'   order by  summitsql.seqtime desc limit 10 ';

        $result=$adb->pquery($sql,array($current_user->id,$current_user->id,$current_user->id));
        return $this->getApproveResultList($result);
    }
    //获取被驳回的数量列表
    public function getApproveRejectedNumsResult(){
        global $adb,$current_user;
        $select_sql = "SELECT * from ld_systems_deploy where setype is not null ";
        $select_result = $adb->pquery($select_sql,array());
        $rows = $adb->num_rows($select_result);
        $sqlarr=[];
        $userid = $current_user->id;
        for($i=0;$i<$rows;$i++)
        {
            $setype = $adb->query_result($select_result,$i,'setype');
            if(empty($setype))
            {
                continue;
            }
            if(!vtlib_isModuleActive($setype))
            {
                continue;
            }
            $focus = CRMEntity::getInstance($setype);
            $tablename = $focus->table_name;
            $tableindex = $focus->table_index;
            $smownercolumn = $focus->getSmownerColumName();
            $module_sql = "select count($tableindex) as num,'$setype' as 'setype' from $tablename where deleted=0 and
                approvestatus='已驳回' and $smownercolumn = $userid ";

            $sqlarr[] = $module_sql;
        }

        $sql = implode(" union all ",$sqlarr ) ;

        $sql = "select * from ($sql) as tmp where num>0 ORDER BY num DESC ";
        $result = $adb->pquery($sql,array());
        return $result;
    }
    //获取被驳回的单据列表 每个模块的数据在一起的  主要是首页的组件:审批中心组件使用
    public function getApproveRejectedList(){
        global $adb,$current_user;
        $select_sql = "SELECT * from ld_systems_deploy where setype is not null ";
        $select_result = $adb->pquery($select_sql,array());
        $rows = $adb->num_rows($select_result);
        $sqlarr=[];
        $userid = $current_user->id;
        for($i=0;$i<$rows;$i++)
        {
            $setype = $adb->query_result($select_result,$i,'setype');
            if(empty($setype)||!vtlib_isModuleActive($setype))
            {
                continue;
            }
            $focus = CRMEntity::getInstance($setype);
            $tablename = $focus->table_name;
            $tableindex = $focus->table_index;
            $smownercolumn = $focus->getSmownerColumName();
            $module_sql = "select $tableindex as crmid,'$setype' as 'setype',tmp.submittime as approvesubmittedtime from $tablename 
                 left join (select ld_approvelog.seqtime,ld_approvelog.crmid,summitsql.seqtime as submittime
                    from ld_approvelog
                    left join (select seqtime,crmid from ld_approvelog where stepid=-1 group by crmid order by seqtime desc  )summitsql on ld_approvelog.crmid=summitsql.crmid
                    inner join(
                        SELECT
                                max(id) maxid,
                                crmid
                            FROM
                                ld_approvelog
                            GROUP BY
                                crmid
                        ) tmp on tmp.maxid=ld_approvelog.id
                    )tmp on $tablename.$tableindex= tmp.crmid                                                    
                    where deleted=0 and
                approvestatus='已驳回' and $smownercolumn = $userid ";

            $sqlarr[] = $module_sql;
        }

        $sql = implode(" union all ",$sqlarr ) ;

        $sql = "select * from ($sql) as tmp  ORDER BY approvesubmittedtime DESC ";
        $result = $adb->pquery($sql,array());

        $num_rows = $adb->num_rows($result);
        $approval_lists = [];
        if($num_rows>0) {
            $userobj = new Users();
            for ($i = 0; $i < $num_rows; $i++) {
                $setype = $adb->query_result($result, $i, 'setype');
                $crmid = $adb->query_result($result, $i, 'crmid');

                //获取单据负责人名称
                $last_name=$this->getSmownerName($setype,$crmid,$userobj);
                $approval_lists[] = Array(
                    'crmid' => $crmid,
                    'setype' => $setype,
                    'ownerName' => $last_name, //负责人
                );
            }
        }

        return $approval_lists;
    }


    //根据模块和id获取单据负责人
    public function getSmownerName($module,$record,$userobj){
        global $adb;
        $focus = CRMEntity::getInstance($module);

        $query = "SELECT u.last_name,u.wx_userid FROM ld_users u INNER JOIN ".$focus->table_name.
            " s ON s.".$focus->getSmownerColumName(). "= u.id WHERE s.". $focus->table_index ."=".$record." LIMIT 1";

        $tmp_result=$adb->query($query);
        $last_name=$adb->query_result($tmp_result,0,'last_name'); //负责人;
        $wx_userid=$adb->query_result($tmp_result,0,'wx_userid');//

        $userobj->wx_userid=$wx_userid;
        $userobj->last_name=$last_name;
        $last_name=getUserlastName($userobj);
        return $last_name;
    }
    //获取下一步审批人名字  逗号隔开
    public function getNextstepbyname($nextstepapproveby,$approveObj){
        if(empty($nextstepapproveby)){
            return '';
        }
        if(substr($nextstepapproveby, 0, 1 )=='H'){
            $approveby = getUserIdRole($nextstepapproveby);
            $nextstepapproveby=implode(',',$approveby);
        }
        if($nextstepapproveby==-1)
        {
            $nextstepbyname="System";
        }
        else
        {
            $nextstepby=$nextstepapproveby;
            $nextstepbyname=rtrim($approveObj->getApproveByName($nextstepby),',');
        }
        return $nextstepbyname;
    }

    public function getApproveResultList($result){
        global $adb;
        $num_rows = $adb->num_rows($result);

        $approval_lists = [];
        if($num_rows>0){
            $userobj = new Users();
            $approve = new Approve();
            for($i=0;$i<$num_rows;$i++){
                $setype = $adb->query_result($result,$i,'setype');
                $crmid = $adb->query_result($result,$i,'crmid');

                //获取单据负责人名称
                $last_name=$this->getSmownerName($setype,$crmid,$userobj);
                //获取 下一步处理人 名字$nextstepbyname
                $nextstepapproveby = $adb->query_result($result,$i,'nextstepapproveby');
                $nextstepbyname = $this->getNextstepbyname($nextstepapproveby,$approve);

                $approval_lists[] = Array(
                    'crmid' => $crmid,
                    'stepname' => $adb->query_result($result,$i,'stepname'), //当前审批步骤
                    'nextstepbyname' => $nextstepbyname, //下一步处理人
                    'approvetime' => $adb->query_result($result,$i,'approvetime'),
                    'ownerName' => $last_name, //负责人
                    'setype' => $setype,//=module
                    'urgent' => $adb->query_result($result,$i,'urgent'),
                    'expediting' => $adb->query_result($result,$i,'expediting')
                );
            }
        }
        return $approval_lists;
    }
}

?>