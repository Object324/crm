<?php


class ServiceKanBan
{
    private $adb;
    private $showcolLists;

    public function __construct($showcolLists)
    {
        global $adb;
        $this->adb = $adb;
        $this->showcolLists = $showcolLists;
    }

    /**
     * @param string $extroWhere
     * @param $timefieldname
     * @return string
     * @throws Exception
     */
    public function ListViewForServiceKanBan($extroWhere='',$timefieldname='ld_troubletickets.createdtime'){
        $whereArr = [];

        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        $currMonth = date('Y-m');
        if(!empty($start_date)){
            $whereArr[] = ' ld_troubletickets.createdtime >= "'.$start_date.' 00:00:00"';
        }
        if(!empty($end_date)){
            $whereArr[] = ' ld_troubletickets.createdtime <= "'.$end_date.' 23:59:59"';
        }
        // 服务方法
        $serviceype = $_REQUEST['basicotherfindsservicetype'];
        if(!empty($serviceype)){
            $whereArr[] = ' ld_troubletickets.servicetype="'.$serviceype.'"';
        }

        // 审批状态 多选
        //未提交
        //审批中
        //已批准
        //已拒绝
        //已驳回
        $approvestatus = $_REQUEST['approve_header_select_value'];
        $approvestatus = empty($approvestatus)?'':trim($approvestatus,',');
        if(!empty($approvestatus)){
            $approvestatus = explode(',',$approvestatus);
            if(sizeof($approvestatus)<=4){
                $approvestatus = implode('","',$approvestatus);
                $approvestatus = '"'.$approvestatus.'"';
                $whereArr[] = ' ld_troubletickets.approvestatus in ('.$approvestatus.',"")';
            }
        }
        // 其他条件 --只有客户名称了basicotherfind
        $otherfindcolumn = $_REQUEST['otherfindcolumn'];
        $basicotherfind = $_REQUEST['basicotherfind'];
        if(!empty($basicotherfind)){
            $whereArr[] = ' b.accountname like "%'.$basicotherfind.'%"';
        }
        $whereStr = ' where ld_troubletickets.deleted=0 ';
        if(!empty($whereArr)){
            $whereStr .= ' and '.implode(' and ',$whereArr);
        }
        //是否来自首页  来自首页 则只显示10条数据
        $limitSql = '';
        if(isset($_REQUEST['fromhome'])&&$_REQUEST['fromhome']=='yes'){
            $limitSql = 'limit 0,10';
            $whereStr = $extroWhere;//首页传过来的条件
        }else{
            $whereStr .= $extroWhere;
        }

        $advft['advft_criteria'] = json_encode($_REQUEST['advft_criteria']);
        $advft['advft_criteria_groups'] = $_REQUEST['advft_criteria_groups'];
        $advft['searchtype'] = 'advance';

        //zxm 2022-06-27  服务看板 增加高级查询
        crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
        $queryGenerator = new cls_QueryGenerator('', null,'');
        $queryGenerator->addUserSearchConditions($advft);
        $advsearch = $queryGenerator->getWhereClause();

        $where_out = '';
        if(!empty($advsearch)){
            $where_out = ' where '.$advsearch;
        }

        //查询sql
        $report_sql = "
        select * from(SELECT
	ifnull(b.accountname,'')as accountname,
	ld_troubletickets.accountid,ld_troubletickets.ticketid,ld_troubletickets.ticket_no,
	b.lastservicedate,
	ld_troubletickets.createdtime as createdTime,
	ld_troubletickets.`status` AS ticketstatus,
	ld_troubletickets.smownerid,
	u.last_name,u.wx_userid,
	ld_troubletickets.distributetime,
	ld_troubletickets.approvesubmittedtime,
	(
		CASE
		WHEN ifnull(ld_troubletickets.distributetime, '') = '' THEN
			0
		WHEN ifnull(ld_troubletickets.createdtime, '') = '' THEN
			0
		ELSE
			TIMESTAMPDIFF(
				MINUTE,
				ld_troubletickets.createdtime,
				ld_troubletickets.distributetime
			)
		END
	) AS waitingtime,
	(
		CASE
		WHEN ifnull(ld_troubletickets.approvesubmittedtime, '') = '' THEN
			0
		WHEN ifnull(ld_troubletickets.distributetime, '') = '' THEN
			0
		ELSE
			TIMESTAMPDIFF(
				MINUTE,
				ld_troubletickets.distributetime,
				ld_troubletickets.approvesubmittedtime
			)
		END
	) AS servicetime
FROM
	ld_troubletickets 
LEFT JOIN ld_account b ON ld_troubletickets.accountid = b.accountid
LEFT JOIN ld_users u ON u.id = ld_troubletickets.smownerid
$whereStr  order by $timefieldname desc)a $where_out $limitSql
        ";

        $result = $this->adb->pquery($report_sql);
        $html = '';
        $nums = $this->adb->num_rows($result);
        $list = [];

        if($nums>=1){
            for ($i = 0; $i < $nums; $i++) {
                $wx_userid = $this->adb->query_result($result,$i,'wx_userid');
                $accountid = $this->adb->query_result($result,$i,'accountid');
                $ticketid = $this->adb->query_result($result,$i,'ticketid');
                foreach($this->showcolLists  as $fieldName=>$v){
                    $fieldName = explode(':',$fieldName)[0];
                    $start_len = strpos($fieldName,'_')+1;
                    $fieldName = substr($fieldName,$start_len);
                    if($fieldName == 'smownerid'){
                        require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
                        if(isKehu001ServerPc()=='yes'){
                            $last_name='<ww-open-data type="userName" name="wxopendata" openid="'.$wx_userid.'"></ww-open-data>';
                        }else{
                            $last_name = $this->adb->query_result($result,$i,'last_name');
                        }
                        $list[$i][$fieldName] = $last_name;
                    }else{
                        $list[$i][$fieldName] = $this->adb->query_result($result,$i,$fieldName);
                    }
                }
                $list[$i]['accountid'] = $accountid;
                $list[$i]['ticketid'] = $ticketid;
            }

            foreach( $list as $k=>$v){
                $style = '';
                $class = 'lvtColDataBj';
                if($k%2==0){
                    $class = 'lvtColData';
                }

                $accountid = $v['accountid'];
                $ticketid = $v['ticketid'];
                $a_account = '<a lasturl="" module="Accounts" record="'.$accountid.'" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record='.$accountid.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$v['accountname'].'">'.$v['accountname'].'</a>';
                $a_ticket = '<a lasturl="" module="HelpDesk" record="'.$ticketid.'" href="index.php?pageto_module=HelpDesk&pageto_action=index&pageto_record='.$ticketid.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$v['ticket_no'].'">'.$v['ticket_no'].'</a>';
                if($k%2==0){
                    $html .= '<tr id="report_'.$k.'" '.$style.' class="'.$class.'" onmouseout="listOnMouseOut(ld(this),\'on\');" onmouseover="listOnMouseOver(ld(this));">';
                }else{
                    $html .= '<tr id="report_'.$k.'" '.$style.' class="'.$class.'"  onmouseout="listOnMouseOut(ld(this),\'On\');" onmouseover="listOnMouseOver(ld(this));">';
                }

                foreach( $v as $kk=>$vv) {
                    if ($kk != "accountid" && $kk!="ticketid") {
                        if($kk == "accountname"){
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_account . '</a></td>';
                        }else if($kk == "ticket_no"){
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_ticket . '</a></td>';
                        }else{
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html .= "<tr>";
            $colspan = count($this->showcolLists);
            $html .= "<td colspan='".$colspan."' style='text-align:center;' valign='top'>".getFixedLabel('NODATAFOUND')."</td>";
//            foreach($this->showcolLists  as $fieldName=>$v){
//                $html .= "<td style='text-align:left' valign='top'>-</td>";
//            }
            $html .= "</tr>";
        }
        return $html;
    }
}