<?php
//editor:gyq_147 reason:扬锻销售报表  2019/9/29 11:27
crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
class report_saleskit_yangduan extends cls_ReportDetailInfoWX
{
    public function __construct($record)
    {}
    public function listview_where($r_module){
        $search_type = $_REQUEST['reporttype']?$_REQUEST['reporttype']:'thismonth';
        $shiyebu = $_REQUEST['shiyebu']?$_REQUEST['shiyebu']:'全部';
        $daqu = $_REQUEST['daqu']?$_REQUEST['daqu']:'全部';
        $time_list = cls_StaticCommonFun::rangeTime2DateArr($search_type);
        //editor:gyq_20191021 reason:between范围！  2019/10/21 14:17
        //0038304: 扬锻的手机报表按时间段查询数据跟PC不一致 ， 上周和上月都有问题
        $date_start = $time_list[0].' 00:00:00';
        $date_end = $time_list[1].' 23:59:59';
        $focus = CRMEntity::getInstance($r_module);
        $table_name  = $focus->table_name;
        $detail_table_name  = $focus->Detail_table;
        //大区筛选条件
        if($daqu=='全部'){
            $sql_join = '';
            $where_daqu = ' where ';
        }elseif($daqu=='其他'){
            $sql_join = ' left join ld_users2group tus on '.$table_name.'.smownerid=tus.userid
              left join ld_groups tgr on tgr.groupid=tus.groupid ';
            $where_daqu  = ' where tgr.groupname not IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) and ';
        }else{
            $sql_join = ' left join ld_users2group tus on '.$table_name.'.smownerid=tus.userid
                  left join ld_groups tgr on tgr.groupid=tus.groupid ';
            $where_daqu  = ' where tgr.groupname=\''.$daqu.'\' and ';
        }
        //事业部筛选条件
        if($shiyebu=='全部')
            $where_shiyebu = ' ';
        else
            $where_shiyebu = ' c.cf_2307=\''.$shiyebu.'\' and ';
        //根据模块不同组装条件
        $where = '';
        //ls 2022-01-11 扬锻以前开发的手机端扬锻销售简报，按条件查询数据后，显示数据，点击数据，查会把所有数据显示出来（查询条件失效）
        if($r_module=='Accounts'||$r_module=='ContactRecords'||$r_module=='Potentials'){
            $where .= $sql_join.$where_daqu.$table_name.'.createdtime between \''.$date_start.'\' and \''.$date_end.'\' and '.$table_name.'.deleted = 0';
        }elseif($r_module=='SalesOrder' || $r_module=='ServiceContracts' || $r_module=='PurchaseOrder'){
            $sql_join .= ' left join '.$focus->Detail_table.' b on '.$table_name.'.'.$focus->table_index.'=b.id
                left join ld_productcf c ON c.productid=b.productid ';
            $where .= $sql_join.$where_daqu.$where_shiyebu.$table_name.'.createdtime between \''.$date_start.'\' and \''.$date_end.'\' and '.$table_name.'.deleted = 0';
            //editor:gyq_20200107 reason:去除不合理的group by语句
            //$where .= ' group by '.$table_name.'.'.$focus->table_index;
        }
        return $where;
    }
    //扬锻销售简报
    public function saleskit_yangduan(){
        global $adb;
        $search_type = $_REQUEST['reporttype']?$_REQUEST['reporttype']:'thismonth';
        $shiyebu = $_REQUEST['shiyebu']?$_REQUEST['shiyebu']:'全部';
        $daqu = $_REQUEST['daqu']?$_REQUEST['daqu']:'全部';
        //$date = getHomeDateScope($search_date);
        //时间筛选
        $time_list = cls_StaticCommonFun::rangeTime2DateArr($search_type);
        //editor:gyq_20191021 reason:between范围！  2019/10/21 14:17
        //0038304: 扬锻的手机报表按时间段查询数据跟PC不一致 ， 上周和上月都有问题
        $date_start = $time_list[0].' 00:00:00';
        $date_end = $time_list[1].' 23:59:59';
        //大区筛选
        $sql_join = '';
        if($daqu=='全部'){
            $sql_join .= ' where ';
        }elseif($daqu=='其他'){
            $sql_join .= ' left join ld_users2group tus on tac.smownerid=tus.userid
              left join ld_groups tgr on tgr.groupid=tus.groupid
            where tgr.groupname not IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) and ';
        }else{
            $sql_join = ' left join ld_users2group tus on tac.smownerid=tus.userid
                  left join ld_groups tgr on tgr.groupid=tus.groupid
                where tgr.groupname=\''.$daqu.'\' and ';
        }
        $list_i = 0;
        $report_list[$list_i]['name'] = '客户';
        $report_list[$list_i]['imgname'] = 'report_01.png';
        //新增客户
        if(vtlib_isModuleActive('Accounts')){
            $query = 'select count(1) as cnt from ld_account tac ';
            $query .= $sql_join;
            $query .= ' tac.deleted = 0 and tac.createdtime between \''.$date_start.'\' and \''.$date_end.'\'';
            $result = $adb->pquery($query,array());
            $record_num = 0;
            if($adb->num_rows($result)>0)
                $record_num =$adb->query_result($result,0,0);
            $report_list[$list_i]['list'][] = array(
                'content'=>$record_num.'<span style="font-size:13px;color:#999">个</span>',
                'describe'=>'新增'.getTransTab('Accounts').'数',
                'module'=>'Accounts',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        //新增跟进记录
        if(vtlib_isModuleActive('ContactRecords')){
            $query = 'select count(1) as cnt from ld_contactrecords tac';
            $query .= $sql_join;
            $query .= ' tac.deleted = 0 and tac.contactdate between \''.$date_start.'\' and \''.$date_end.'\'';
            $result = $adb->pquery($query,array());
            $record_num = 0;
            if($adb->num_rows($result)>0)
                $record_num = $adb->query_result($result,0,0);
            $report_list[$list_i]['list'][] = array(
                'content'=>$record_num.'<span style="font-size:13px;color:#999">个</span>',
                'describe'=>'新增'.getTransTab('ContactRecords').'数',
                'module'=>'ContactRecords',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        $list_i++;
        $report_list[$list_i]['name'] = '商机';
        $report_list[$list_i]['imgname'] = 'report_02.png';
        //新建销售机会
        if(vtlib_isModuleActive('Potentials')){
            $query = 'select count(1) as cnt,sum(
                       IF (
                           tac.currency_id > 1,
                           IFNULL(tac.amount, 0) / ifnull(
                               tac.conversion_rate,
                               1
                           ),
                           IFNULL(tac.amount, 0)
                       )
                   ) as to_amount from ld_potential tac';
            $query .= $sql_join;
            $query .= ' tac.deleted = 0 and tac.createdtime between \''.$date_start.'\' and \''.$date_end.'\'';
            $result = $adb->pquery($query,array());
            $record_num = 0;$to_amount = 0;
            if($adb->num_rows($result)>0){
                $record_num = $adb->query_result($result,0,'cnt');
                $to_amount = $adb->query_result($result,0,'to_amount');
            }
            $report_list[$list_i]['list'][] = array(
                'content'=>$record_num.'<span style="font-size:13px;color:#999">个</span>',
                'describe'=>'新增'.getTransTab('Potentials').'数',
                'module'=>'Potentials',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.setNumberFormat($to_amount),
                'describe'=>'新增'.getTransTab('Potentials').'金额',
                'module'=>'Potentials',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        $list_i++;
        //合同订单
        $report_list[$list_i]['name'] = '订单';
        $report_list[$list_i]['imgname'] = 'report_03.png';
        if(vtlib_isModuleActive('SalesOrder')){
            $dingdan_list = $this->dingdan_yangduan($date_start,$date_end,$daqu,$shiyebu);
            //空值判断 begin
            $all_total = $dingdan_list['all_total'];
            $benqi_total = $dingdan_list['benqi_total'];
            if(empty($benqi_total))
                $benqi_total = 0;
            $benqi_total = setNumberFormat($benqi_total);
            if(empty($all_total))
                $all_total = 0;
            $all_total = setNumberFormat($all_total);
            if($daqu == '其他'){
                $wancheng = $all_total.'/100%';
            }elseif(empty($dingdan_list['done_rate']))
                $wancheng = $all_total;
            else
                $wancheng = $all_total.'/'.$dingdan_list['done_rate'];
            //空值判断 end
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.$benqi_total,
                'describe'=>'新增订单金额',
                'module'=>'SalesOrder',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.$wancheng,
                'describe'=>'完成情况',
                'module'=>'SalesOrder',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        //收款单
        $list_i++;
        $report_list[$list_i]['name'] = '回笼';
        $report_list[$list_i]['imgname'] = 'report_02.png';
        if(vtlib_isModuleActive('ServiceContracts')){
            $dingdan_list = $this->huilong_yangduan($date_start,$date_end,$daqu,$shiyebu);
            //空值判断 begin
            if(empty($dingdan_list['benqi_total']))
                $dingdan_list['benqi_total'] = 0;
            if(empty($dingdan_list['all_total']))
                $dingdan_list['all_total'] = 0;
            if($daqu == '其他'){
                $wancheng = setNumberFormat($dingdan_list['all_total']).'/100%';
            }elseif(empty($dingdan_list['done_rate']))
                $wancheng = setNumberFormat($dingdan_list['all_total']);
            else
                $wancheng = setNumberFormat($dingdan_list['all_total']).'/'.$dingdan_list['done_rate'];
            //空值判断 end
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.setNumberFormat($dingdan_list['benqi_total']),
                'describe'=>'新增回笼金额',
                'module'=>'ServiceContracts',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.$wancheng,
                'describe'=>'完成情况',
                'module'=>'ServiceContracts',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        //销售确认单
        $list_i++;
        $report_list[$list_i]['name'] = '确认';
        $report_list[$list_i]['imgname'] = 'report_02.png';
        if(vtlib_isModuleActive('PurchaseOrder')){
            $dingdan_list = $this->queren_yangduan($date_start,$date_end,$daqu,$shiyebu);
            //空值判断 begin
            $all_total = $dingdan_list['all_total'];
            $benqi_total = $dingdan_list['benqi_total'];
            if(empty($benqi_total))
                $benqi_total = 0;
            $benqi_total = setNumberFormat($benqi_total);
            if(empty($all_total))
                $all_total = 0;
            $all_total = setNumberFormat($all_total);
            if($daqu == '其他'){
                $wancheng = $all_total.'/100%';
            }elseif(empty($dingdan_list['done_rate']))
                $wancheng = $all_total;
            else
                $wancheng = $all_total.'/'.$dingdan_list['done_rate'];
            //空值判断 end
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.$benqi_total,
                'describe'=>'新增确认金额',
                'module'=>'PurchaseOrder',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
            $report_list[$list_i]['list'][] = array(
                'content'=>'¥'.$wancheng,
                'describe'=>'完成情况',
                'module'=>'PurchaseOrder',
                'second_para'=>'-1','second_action'=>'saleskit_yangduan'
            );
        }
        $jsonArray['list'] = $report_list;
        $jsonArray['list2'][] = $this->set_filter_time_range();
        $jsonArray['list2'][] = $this->saleskit_yangduan_daqu();
        $jsonArray['list2'][] = $this->saleskit_yangduan_shiyebu();
        return $jsonArray;
    }
    protected function saleskit_yangduan_daqu(){
        global $adb;
        $sql = 'SELECT \'全部\' listvalue,0 AS sequence
            UNION
            SELECT
              CASE
              WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN groupname
              ELSE \'其他\'
              END AS listvalue,
              CASE
              WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
              ELSE 1000
              END AS sequence
            FROM (
                   SELECT
                     a.id,
                     a.last_name,
                     CASE
                     WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                       (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                     ELSE
                       d.groupname
                     END AS groupname
                   FROM ld_users a
                     LEFT JOIN ld_profile b ON a.profileid=b.profileid
                     LEFT JOIN ld_users2group c ON c.userid=a.id
                     LEFT JOIN ld_groups d ON d.groupid=c.groupid
                   WHERE a.deleted=0
                   GROUP BY a.id
                 ) a
            GROUP BY listvalue
            ORDER BY sequence';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $shiyebu = array(
            'fieldlabel'=>'大区',
            'fieldname'=>'daqu'
        );
        if($num > 0){
            for($i=0;$i<$num;$i++){
                $content = $adb->query_result($result,$i,'listvalue');
                if($content=='全部')
                    $option[$i]['select'] = 'yes';
                else
                    $option[$i]['select'] = 'no';
                $option[$i]['text'] = $content;
                $option[$i]['value'] = $content;
            }
        }
        $shiyebu['option'] = $option;
        return $shiyebu;
    }
    protected function saleskit_yangduan_shiyebu()
    {
        global $adb;
        $sql = 'SELECT \'全部\' AS listvalue
            UNION (
              SELECT
                listvalue
              FROM ld_picklist_set a
                LEFT JOIN ld_picklist_values b ON a.listid=b.listid
              WHERE a.listname=\'cf_2307\'
              ORDER BY sequence)';
        $result  = $adb->pquery($sql,array());
        $shiyebu = array(
            'fieldlabel'=>'事业部',
            'fieldname'=>'shiyebu'
        );
        $num = $adb->num_rows($result);
        if($num > 0){
            for($i=0;$i<$num;$i++){
                $content = $adb->query_result($result,$i,'listvalue');
                if($content=='全部')
                    $option[$i]['select'] = 'yes';
                else
                    $option[$i]['select'] = 'no';
                $option[$i]['text'] = $content;
                $option[$i]['value'] = $content;
            }
        }
        $shiyebu['option'] = $option;
        return $shiyebu;
    }
    //设置销售简报筛选时间
    public function set_filter_time_range(){
        $list = array(
            'fieldlabel'=>'日期',
            'fieldname'=>'reporttype'
        );
        if($num > 0){
            for($i=0;$i<$num;$i++){
                $content = $adb->query_result($result,$i,'listvalue');
                $option[$i]['select'] = 'no';
                $option[$i]['text'] = $content;
                $option[$i]['value'] = $content;
            }
        }
        //本周、上周、本月、上月、本季度、上季度、本年、上年
        $time_range = array(
            array('select'=>'no','value'=>'thisweek','text'=>'本周'),
            array('select'=>'no','value'=>'lastweek','text'=>'上周'),
            array('select'=>'yes','value'=>'thismonth','text'=>'本月'),
            array('select'=>'no','value'=>'lastmonth','text'=>'上月'),
            array('select'=>'no','value'=>'thisquarter','text'=>'本季度'),
            array('select'=>'no','value'=>'lastquarter','text'=>'上季度'),
            array('select'=>'no','value'=>'thisyear','text'=>'本年度'),
            array('select'=>'no','value'=>'lastyear','text'=>'上年度'),
        );
        $list['option'] = $time_range;
        return $list;
    }
    //订单：       1、新增订单金额， 2、完成情况
    protected function dingdan_yangduan($r_start_date,$r_end_date,$r_daqu,$r_shiyebu){
        global $adb;
		/*
        $sql = 'SELECT
  benqi_total,
  all_total,all_mubiao_total,
  CONCAT(ROUND(all_total*100/all_mubiao_total,0),\'%\') AS done_rate
FROM (

       SELECT
         (
           SELECT
             ROUND(SUM(bf.sf13023)*0.0001,2) AS total
           FROM ld_salesorder a
             LEFT JOIN ld_salesordercf af ON af.salesorderid=a.salesorderid
             LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
             LEFT JOIN ld_salesorderdetailscf bf ON b.lineitem_id=bf.lineitem_id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
           WHERE a.deleted=0
                 AND a.approvestatus<>\'已拒绝\'
                 AND bf.sf7637 BETWEEN \''.$r_start_date.'\' AND \''.$r_end_date.'\'
                 AND af.cf_2331=\'机床销售\'
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)

         ) AS benqi_total,
         (
           SELECT
             ROUND(SUM(bf.sf13023)*0.0001,2) AS total
           FROM ld_salesorder a
             LEFT JOIN ld_salesordercf af ON af.salesorderid=a.salesorderid
             LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
             LEFT JOIN ld_salesorderdetailscf bf ON b.lineitem_id=bf.lineitem_id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
           WHERE a.deleted=0
                 AND a.approvestatus<>\'已拒绝\'
                 AND YEAR(bf.sf7637) = YEAR(\''.$r_start_date.'\') AND bf.sf7637<=CURDATE()
                 AND af.cf_2331=\'机床销售\'
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)
         ) AS all_total,
         IFNULL((
                  SELECT
                    ROUND(SUM(d.sf62)*0.0001,2) AS mubiao
                  FROM ld_minusjobbill a
                    LEFT JOIN ld_minusjobbillscf c ON c.minusjobbillid=a.minusjobbillid
                    LEFT JOIN ld_minusjobbilldetail b ON a.minusjobbillid=b.id
                    LEFT JOIN ld_minusjobbilldetailscf d ON d.lineitem_id=b.lineitem_id
                    INNER JOIN (
                                 SELECT
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN groupname
                                   ELSE \'其他\'
                                   END AS listvalue,
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
                                   ELSE 1000
                                   END AS sequence
                                 FROM (
                                        SELECT
                                          a.id,
                                          a.last_name,
                                          CASE
                                          WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                                            (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                                          ELSE
                                            d.groupname
                                          END AS groupname
                                        FROM ld_users a
                                          LEFT JOIN ld_profile b ON a.profileid=b.profileid
                                          LEFT JOIN ld_users2group c ON c.userid=a.id
                                          LEFT JOIN ld_groups d ON d.groupid=c.groupid
                                        WHERE a.deleted=0
                                        GROUP BY a.id
                                      ) a
                                 GROUP BY listvalue
                               ) e ON e.listvalue=d.sf67
                  WHERE a.deleted=0
                        AND a.approvestatus<>\'已拒绝\'
                        AND c.cf_2386=YEAR(\''.$r_start_date.'\')
                        AND (
                          CASE
                          WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                          ELSE FIND_IN_SET(d.sf67,\''.$r_daqu.'\')
                          END)
                ),0) AS all_mubiao_total

     ) t';
	 */
	 	//$sql="CALL yangduan_getordertotal('2022-08-01','2022-08-31','全部','全部','1')";
		$sql = 'CALL yangduan_getordertotal("'.$r_start_date.'","'.$r_end_date.'","'.$r_daqu.'","'.$r_shiyebu.'",1)';
		
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $list = array();
        $list['benqi_total'] = $adb->query_result($result,0,'benqi_total');
        $list['all_total'] = $adb->query_result($result,0,'all_total');
        $list['all_mubiao_total'] = $adb->query_result($result,0,'all_mubiao_total');
        $list['done_rate'] = $adb->query_result($result,0,'done_rate');
        return $list;
    }
    //回笼：       1、新增回笼金额， 2、完成情况
    public function huilong_yangduan($r_start_date,$r_end_date,$r_daqu,$r_shiyebu){
        global $adb;
        $sql = 'SELECT
  benqi_total,
  all_total,all_mubiao_total,
  CONCAT(ROUND(all_total*100/all_mubiao_total,0),\'%\') AS done_rate
FROM (

       SELECT
         (
           SELECT
             ROUND(SUM(b.tax_amount/IFNULL(a.conversion_rate,1))*0.0001,2)
           FROM ld_servicecontracts a
             LEFT JOIN ld_servicecontractscf af ON af.servicecontractsid=a.servicecontractsid
             LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
             INNER JOIN (
                          SELECT
                            a.groupname AS listvalue,
                            CASE
                            WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
                            ELSE 1000
                            END AS sequence
                          FROM (
                                 SELECT
                                   a.id,
                                   a.last_name,
                                   CASE
                                   WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                                     (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                                   ELSE
                                     d.groupname
                                   END AS groupname
                                 FROM ld_users a
                                   LEFT JOIN ld_profile b ON a.profileid=b.profileid
                                   LEFT JOIN ld_users2group c ON c.userid=a.id
                                   LEFT JOIN ld_groups d ON d.groupid=c.groupid
                                 WHERE a.deleted=0
                                 GROUP BY a.id
                               ) a
                          GROUP BY listvalue
                        ) e ON e.listvalue=u.groupname
           WHERE a.deleted=0
                 AND a.due_date BETWEEN \''.$r_start_date.'\' AND \''.$r_end_date.'\'
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)
         ) AS benqi_total,
         (
           SELECT
             SUM(b.tax_amount/IFNULL(a.conversion_rate,1))*0.0001 AS total
           FROM ld_servicecontracts a
             LEFT JOIN ld_servicecontractscf af ON af.servicecontractsid=a.servicecontractsid
             LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
             INNER JOIN (
                          SELECT
                            a.groupname AS listvalue,
                            CASE
                            WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
                            ELSE 1000
                            END AS sequence
                          FROM (
                                 SELECT
                                   a.id,
                                   a.last_name,
                                   CASE
                                   WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                                     (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                                   ELSE
                                     d.groupname
                                   END AS groupname
                                 FROM ld_users a
                                   LEFT JOIN ld_profile b ON a.profileid=b.profileid
                                   LEFT JOIN ld_users2group c ON c.userid=a.id
                                   LEFT JOIN ld_groups d ON d.groupid=c.groupid
                                 WHERE a.deleted=0
                                 GROUP BY a.id
                               ) a
                          GROUP BY listvalue
                        ) e ON e.listvalue=u.groupname
           WHERE a.deleted=0
                 AND YEAR(a.due_date) = YEAR(\''.$r_start_date.'\') AND a.due_date<=CURDATE()
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)
         ) AS all_total,
         IFNULL((
                  SELECT
                    ROUND(SUM(d.sf63)*0.0001,2) AS mubiao
                  FROM ld_minusjobbill a
                    LEFT JOIN ld_minusjobbillscf c ON c.minusjobbillid=a.minusjobbillid
                    LEFT JOIN ld_minusjobbilldetail b ON a.minusjobbillid=b.id
                    LEFT JOIN ld_minusjobbilldetailscf d ON d.lineitem_id=b.lineitem_id
                    INNER JOIN (
                                 SELECT
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN groupname
                                   ELSE \'其他\'
                                   END AS listvalue,
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
                                   ELSE 1000
                                   END AS sequence
                                 FROM (
                                        SELECT
                                          a.id,
                                          a.last_name,
                                          CASE
                                          WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                                            (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                                          ELSE
                                            d.groupname
                                          END AS groupname
                                        FROM ld_users a
                                          LEFT JOIN ld_profile b ON a.profileid=b.profileid
                                          LEFT JOIN ld_users2group c ON c.userid=a.id
                                          LEFT JOIN ld_groups d ON d.groupid=c.groupid
                                        WHERE a.deleted=0
                                        GROUP BY a.id
                                      ) a
                                 GROUP BY listvalue
                               ) e ON e.listvalue=d.sf67
                  WHERE a.deleted=0
                        AND a.approvestatus<>\'已拒绝\'
                        AND c.cf_2386=YEAR(\''.$r_start_date.'\')
                        AND (
                          CASE
                          WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                          ELSE FIND_IN_SET(d.sf67,\''.$r_daqu.'\')
                          END)
                ),0) AS all_mubiao_total

     ) t';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $list = array();
        $list['benqi_total'] = $adb->query_result($result,0,'benqi_total');
        $list['all_total'] = $adb->query_result($result,0,'all_total');
        $list['all_mubiao_total'] = $adb->query_result($result,0,'all_mubiao_total');
        $list['done_rate'] = $adb->query_result($result,0,'done_rate');
        return $list;
    }
    //销售确认：   1、新增确认金额， 2、完成情况*/
    public function queren_yangduan($r_start_date,$r_end_date,$r_daqu,$r_shiyebu){
        global $adb;
        $sql = 'SELECT
  benqi_queren_total,all_queren_total,all_mubiao_total,
  CONCAT(ROUND(all_queren_total*100/all_mubiao_total,0),\'%\') AS done_rate
FROM (

       SELECT
         (
           SELECT
             ROUND(SUM(bf.sf13159)*0.0001,2)
           FROM ld_purchaseorder a
             LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
             LEFT JOIN ld_purchaseorderdetailscf bf ON bf.lineitem_id=b.lineitem_id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
           WHERE a.deleted=0
                 AND a.approvestatus<>\'已拒绝\'
                 AND bf.sf3723 BETWEEN \''.$r_start_date.'\' AND \''.$r_end_date.'\'
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)
         ) AS benqi_queren_total,
         (
           SELECT
             ROUND(SUM(bf.sf13159)*0.0001,2)
           FROM ld_purchaseorder a
             LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
             LEFT JOIN ld_purchaseorderdetailscf bf ON bf.lineitem_id=b.lineitem_id
             LEFT JOIN ld_productcf c ON c.productid=b.productid
             INNER JOIN (
                          SELECT
                            a.id,
                            a.last_name,
                            CASE
                            WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                              (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                            ELSE
                              d.groupname
                            END AS groupname
                          FROM ld_users a
                            LEFT JOIN ld_profile b ON a.profileid=b.profileid
                            LEFT JOIN ld_users2group c ON c.userid=a.id
                            LEFT JOIN ld_groups d ON d.groupid=c.groupid
                          WHERE a.deleted=0
                          GROUP BY a.id
                        ) u ON u.id=a.smownerid
           WHERE a.deleted=0
                 AND a.approvestatus<>\'已拒绝\'
                 AND YEAR(bf.sf3723) = YEAR(\''.$r_start_date.'\') AND bf.sf3723<=CURDATE()
                 AND (
                   CASE
                   WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                   ELSE FIND_IN_SET((CASE WHEN u.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN u.groupname ELSE \'其他\' END),\''.$r_daqu.'\')
                   END)
                 AND (
                   CASE
                   WHEN \''.$r_shiyebu.'\'=\'全部\' THEN 1=1
                   ELSE c.cf_2307=\''.$r_shiyebu.'\'
                   END)
         ) AS all_queren_total,
         IFNULL((
                  SELECT
                    ROUND(SUM(d.sf64)*0.0001,2) AS mubiao
                  FROM ld_minusjobbill a
                    LEFT JOIN ld_minusjobbillscf c ON c.minusjobbillid=a.minusjobbillid
                    LEFT JOIN ld_minusjobbilldetail b ON a.minusjobbillid=b.id
                    LEFT JOIN ld_minusjobbilldetailscf d ON d.lineitem_id=b.lineitem_id
                    INNER JOIN (
                                 SELECT
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN groupname
                                   ELSE \'其他\'
                                   END AS listvalue,
                                   CASE
                                   WHEN a.groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) THEN (SELECT sequence FROM ld_picklist_values WHERE listid=135 AND listvalue=a.groupname LIMIT 1)
                                   ELSE 1000
                                   END AS sequence
                                 FROM (
                                        SELECT
                                          a.id,
                                          a.last_name,
                                          CASE
                                          WHEN (SELECT COUNT(1) FROM ld_users2group WHERE userid=a.id)>1 AND EXISTS (SELECT 1 FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135)) THEN
                                            (SELECT groupname FROM ld_groups WHERE FIND_IN_SET(groupid,(SELECT GROUP_CONCAT(groupid) FROM ld_users2group WHERE userid=a.id)) AND groupname IN (SELECT listvalue FROM ld_picklist_values WHERE listid=135) LIMIT 1)
                                          ELSE
                                            d.groupname
                                          END AS groupname
                                        FROM ld_users a
                                          LEFT JOIN ld_profile b ON a.profileid=b.profileid
                                          LEFT JOIN ld_users2group c ON c.userid=a.id
                                          LEFT JOIN ld_groups d ON d.groupid=c.groupid
                                        WHERE a.deleted=0
                                        GROUP BY a.id
                                      ) a
                                 GROUP BY listvalue
                               ) e ON e.listvalue=d.sf67
                  WHERE a.deleted=0
                        AND a.approvestatus<>\'已拒绝\'
                        AND c.cf_2386=YEAR(\''.$r_start_date.'\')
                        AND (
                          CASE
                          WHEN \''.$r_daqu.'\'=\'全部\' THEN 1=1
                          ELSE FIND_IN_SET(d.sf67,\''.$r_daqu.'\')
                          END)
                ),0) AS all_mubiao_total

     ) t';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $list = array();
        $list['benqi_total'] = $adb->query_result($result,0,'benqi_queren_total');
        $list['all_total'] = $adb->query_result($result,0,'all_queren_total');
        $list['all_mubiao_total'] = $adb->query_result($result,0,'all_mubiao_total');
        $list['done_rate'] = $adb->query_result($result,0,'done_rate');
        return $list;
    }
  
}