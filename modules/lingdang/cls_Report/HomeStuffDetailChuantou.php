<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/SalesKitChuantou.php");

/**
 * 处理销售简报穿透的类
 */
class HomeStuffDetailChuantou extends SalesKitChuantou
{
    public $datarangesqlParent;
    public $datarangesqlInnerJoinParent;
    public $curdatarangsql_strParent;
    public $curdatarangsqlParent;
    public $conditionChuantouSql;

    public function __construct(){
        parent::__construct();
    }
     public function getDatarangeObj(){
        $this->DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);

        if($this->stuffid==8||$this->stuffid==6||$this->stuffid==34||$this->stuffid==33
        ||$this->stuffid==2||$this->stuffid==7)//8：个人本月销售数据,34:交易,33:销售排行榜，6：应收应付，2：年度销售,7:小组本月销售
        {

             $this->DataRangeHomeboardObj->setPenetrateModuleListobj($this);

        }
        //zxm 20231116 合同年度销售业绩情况的新签约客户  不按客户考虑数据范围
        if($this->stuffid==2&&in_array($this->stuffinfo['stufflabel'],array('signNewAccount_Sales','signNewAccount_Service')))
            $this->DataRangeHomeboardObj->setScopeModule("asssss");
        
    }
    public function getTotalGroupBy()
    {
        $focus=CRMEntity::getInstance($this->stuffinfo['compute_module']);

        return " a.".$focus->table_index." ";
    }
     public function getDataRangeSqlSmownerid ($scopemodule,$tmpmodulename,$smownerfieldname,$scopeType,$senioruserid,$tmpfocus){
        
        return '';
        
     }
    //2 年合同年度销售业绩情况 合同订单收款金额
    public function getDetailCondition_AMOUNTTO_Sales($type){
        $sql = "SELECT DISTINCT
            				CashBillID
            			FROM (
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_salesorder
            				INNER JOIN ld_paymentplan ON ld_salesorder.salesorderid = ld_paymentplan.entitytypeid
            				INNER JOIN ld_cashbill2paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_salesorder.deleted = 0
            				UNION ALL
            				SELECT
            					ld_cashbill2paymentplan.CashBillID
            				FROM ld_salesorder
            				INNER JOIN ld_cashbill2paymentplan ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid
            				WHERE ld_salesorder.deleted = 0
            			) AS t";
        return $sql;
    }
    public function getDetailCondition_signNewAccount_Sales($type){
        $starttime = date("Y")."-01-01 00:00:00";
        $endtime = date("Y")."-12-31 23:59:59";
        $homeboard_filterArr = $this->DataRangeHomeboardObj->filterArr;
        $salesorder_date=$homeboard_filterArr['timecomponent_SalesOrder']['filtersfield'];//获取时间限制字段是哪个
        $salesorder_approvestatus=$homeboard_filterArr['approvestatuscomponent_SalesOrder']['filterssql']; //审批条件单独 的 sql
        $salesorder_highsearch=$homeboard_filterArr['highsearch_SalesOrder']['filterssql'];//高级查找条件单独 的 sql
        $field = 'DISTINCT ld_account.accountid';
        if($type=='count'){
            $field = 'COUNT(DISTINCT ld_account.accountid)';
        }
        $sql="SELECT
            			".$field."
            		FROM ld_salesorder
            		LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid
            		".$this->DataRangeHomeboardObj->datarangesqlArr['datarangesql_SalesOrder']."  $salesorder_highsearch
            		WHERE ld_account.deleted = 0 
            			AND ld_salesorder.accountid NOT IN (
            				SELECT 
            					DISTINCT accountid
            				FROM ld_salesorder
            				WHERE deleted = 0  $salesorder_approvestatus  
            					AND $salesorder_date < '$starttime'
            				)";
        return $sql;
    }
    //2 年合同年度销售业绩情况 服务合同收款金额
    public function getDetailCondition_AMOUNTTO_Service($type){
        $sql = 'SELECT DISTINCT
                        CashBillID
                    FROM (
                        SELECT
                            ld_cashbill2paymentplan.CashBillID
                        FROM ld_servicecontracts
                        INNER JOIN ld_paymentplan ON ld_servicecontracts.servicecontractsid = ld_paymentplan.entitytypeid
                        INNER JOIN ld_cashbill2paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
                        WHERE ld_servicecontracts.deleted = 0
                        UNION ALL
                        SELECT
                            ld_cashbill2paymentplan.CashBillID
                        FROM ld_servicecontracts
                        INNER JOIN ld_cashbill2paymentplan ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
                        WHERE ld_servicecontracts.deleted = 0
                    ) AS t';
        return $sql;
    }
    public function getDetailCondition_signNewAccount_Service($type){
        $starttime = date("Y")."-01-01 00:00:00";
        $endtime = date("Y")."-12-31 23:59:59";
        $homeboard_filterArr = $this->DataRangeHomeboardObj->filterArr;
        $contract_date=$homeboard_filterArr['timecomponent_ServiceContracts']['filtersfield'];//获取时间限制字段是哪个
        $servicecontracts_approvestatus=$homeboard_filterArr['approvestatuscomponent_ServiceContracts']['filterssql']; //审批条件单独 的 sql
        $servicecontracts_highsearch=$homeboard_filterArr['highsearch_ServiceContracts']['filterssql'];//高级查找条件单独 的 sql
        $field = 'DISTINCT ld_account.accountid';
        if($type=='count'){
            $field = 'COUNT(DISTINCT ld_account.accountid)';
        }
        $sql="SELECT
            			".$field."
            		FROM ld_servicecontracts
            		LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
            		".$this->DataRangeHomeboardObj->datarangesqlArr['datarangesql_ServiceContracts']."  $servicecontracts_highsearch
            		WHERE ld_account.deleted = 0
            			AND ld_servicecontracts.accountid NOT IN (
            				SELECT 
            					DISTINCT accountid
            				FROM ld_servicecontracts
            				WHERE deleted = 0
            					 $servicecontracts_approvestatus
            					AND $contract_date < '$starttime'
            				)";
        return $sql;
    }
    public function setExtroCondition(){
        if($this->stuffid==2){
            //合同年度销售业绩情况 不控制时间范围 默认是本年  这个条件卸载ld_homestuffdetail表中了
            $this->deleteDaterange();
        }
    }
    public function getSalesKitInfo(){
        global $languageType;
        $stufflabel=  $_REQUEST['stufflabel'];
        $stuffid=$this->stuffid;
        $boardid = $_REQUEST['boardid'];
        $penetrateModule=$this->penetrateModule;
        $whereArr = [];
        $whereArr[] = $stuffid;
        $whereArr[] = $stufflabel;

        global $adb;
        $sql = "select a.id,
        a.stufflabel,
        a.stufflabel_zh,
        a.stufflabel_en,
        a.viewrange,
        a.daterange,
        a.advance_demand,
        a.advance_demand_groups,a.compute_columns,
        a.compute_module from ld_homestuffdetail a  where  a.stuffid=? and stufflabel=?";

        $res = $adb->pquery($sql,$whereArr);
        $numrows = $adb->num_rows($res);
        $info = [];

        if($numrows>0){
            for($i=0;$i<$numrows;$i++){
                $compute_module = $adb->query_result($res,$i,'compute_module');
                if(!vtlib_isModuleActive($compute_module)){
                    continue;
                }
                if(empty($penetrateModule)){
                    $penetrateModule = $compute_module;
                }
                $info[$compute_module] = $adb->query_result_rowdata($res,$i);
                $advance_demand = $adb->query_result($res,$i,'advance_demand');
                //edit: xll 2023/08/17 BUG0071167 销售简报“线索升级到客户”、“线索升级到客户和销售机会”数据丢失
                $stufflabel_arr = ['LeadUgradeToPotentials','LeadUgradeToCustomerCount'];
                if(!empty($advance_demand) && in_array($stufflabel,$stufflabel_arr)) {
                    crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
                    $advance_demand = SalesKitEditSetting::getKis_no_FixedLabel($stufflabel,$advance_demand);
                    $info[$compute_module]['advance_demand'] = $advance_demand;
                }
            }
        }
        //穿透弹窗的标题
        if($info[$penetrateModule]['stufflabel_zh']=='')
        {
            $info[$penetrateModule]['stufflabel_zh']=getFixedLabel($stufflabel);

        }
        if($info[$penetrateModule]['stufflabel_en']=='')
        {
            $info[$penetrateModule]['stufflabel_eh']=getFixedLabel($stufflabel);
        }
        if ($languageType == 'en') {
            $label = $info[$penetrateModule]['stufflabel_en'];
        }else{
            $label = $info[$penetrateModule]['stufflabel_zh'];
        }

        $this->stuffinfo = $info[$penetrateModule];//组件信息
        $this->popuptitle = $label;//穿透弹窗的标题

        $this->penetrateModuleArr = array_keys($info);
        $this->penetrateModule = empty($this->penetrateModule)?$this->penetrateModuleArr[0]:$this->penetrateModule;//穿透模块第一个 先考虑一个模块的穿透

        return $info;
    }


    public function getDatarangesqlArr($boardstuffid){
        //parent::getDatarangesqlArr($boardstuffid);

        $stuffDetailDateRangeArr = $this->DataRangeHomeboardObj->getHomeDateScope($this->search_date_custom_value,'no'); //获取时间范围  返回的是一个数组
        $this->saleskit_params = [
            'stuffid'=>$this->stuffid,
            'compute_module'=>$this->stuffinfo['compute_module'],//计算模块
            'compute_columns'=>$this->stuffinfo['compute_columns'],//计算模块
            'scopeType'=>$this->scopeType,//查询范围类型
            'senioruserid'=>$this->selectuserid,//人员ID
            'date_adv'=>$stuffDetailDateRangeArr['date_adv'],//时间范围关键字
            'date_advbefore'=>$stuffDetailDateRangeArr['date_advbefore'],//时间范围关键字
            'datewhere'=>$stuffDetailDateRangeArr['datewhere'],//本期时间
            'before_datewhere'=>$stuffDetailDateRangeArr['before_datewhere'],//上期时间
            'approve_value'=>$this->approve_value,//审批条件
            'advance_demand'=>$this->stuffinfo['advance_demand'],
            'advance_demand_groups'=>$this->stuffinfo['advance_demand_groups'],
            'viewrange'=>$this->stuffinfo['viewrange'],//查看范围限制字段
            'daterange'=>$this->stuffinfo['daterange'],//日期字段限制字段
            'searchtype'=>$this->searchtype,//日期字段限制字段
        ];
        //33 zxm 20240605 销售排行榜	穿透的时候 传负责人id到后台，如果还去和本身的数据范围（假设点击的超级管理员这个人，模块数据范围是自己）做交集 查不出来数据 所以从这里把负责人条件组成sql传进去
        if($this->stuffid==33&&$boardstuffid>0){
            $this->saleskit_params['viewrange'] = '';
            $this->saleskit_params['daterange'] = '';
            $tmpmodule = $this->saleskit_params['compute_module'];
            $tmpfocus = CRMEntity::getInstance($tmpmodule);
            $SmownerColumName = $tmpfocus->getSmownerColumName();
            $FieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', $SmownerColumName);
            $tablename = $FieldInfo->getTableName();
            $this->saleskit_params['scopesql'] = $tablename.'.'.$SmownerColumName.'='.$this->selectuserid;
        }
        $this->saleskit_params['searchtype'] = 'now';

        //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
        $datarangesql_str = $this->DataRangeHomeboardObj->getDataRangeSqlSalesKit($this->saleskit_params);

        $datarangesqlArr = $this->DataRangeHomeboardObj->datarangesqlArr;
        $this->curdatarangsql_str = $datarangesql_str['cur'];//不带innerjoin 的

        $this->curdatarangsql_str = "select a.* from (" . $datarangesql_str['cur'] . ")a " ;//不带innerjoin 的

        $this->curdatarangsql = $datarangesqlArr['cur'] ;//带inner join 的


        $stufflabel = $this->stuffinfo['stufflabel'];
        /**  这里是按组件和看板设置的条件 --start*/
        $daterange = getHomeDateScope($this->search_date_custom_value);//34 交易的穿透没时间条件  需要传这个参数
        $this->DataRangeHomeboardObj->setPenetrateModule($this->saleskit_params['compute_module']);

        $this->datarangesqlParent = $this->DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$boardstuffid,$this->scopeType,$this->selectuserid,$daterange,$this->approve_value);




        $this->datarangesqlInnerJoinParent = $this->DataRangeHomeboardObj->datarangesqlArr;//这个数组中的条件sql子查询是带inner join 和on 的
        $this->curdatarangsql_strParent = $this->datarangesqlParent[$this->penetrateModule]; //不带innerjoin 的
        $this->curdatarangsqlParent=$this->datarangesqlInnerJoinParent['datarangesql_'.$this->penetrateModule];//带inner join 的
        /**  这里是按组件和看板设置的条件--end */

        //这是特殊条件
        $funname = "getDetailCondition_".$stufflabel;
        $this->conditionChuantouSql = '';
        if(method_exists($this,$funname)) {
            $this->conditionChuantouSql = $this->$funname('');
        }

        $tmpfocus = CRMEntity::getInstance($this->penetrateModule);

        if(!empty($this->curdatarangsql_strParent)) {
            $this->curdatarangsql_str .= " inner join (" . $this->curdatarangsql_strParent . ")conditionChuantouSql on a." . $tmpfocus->table_index . "=conditionChuantouSql." . $tmpfocus->table_index;//不带innerjoin 的

            $this->curdatarangsql = $datarangesqlArr['cur'] . " inner join ($this->curdatarangsql_strParent)conditionChuantouSql on conditionChuantouSql." . $tmpfocus->table_index . "=" . $tmpfocus->table_name . "." . $tmpfocus->table_index;//带inner join 的
        }

        if(!empty($this->conditionChuantouSql)){
            $this->curdatarangsql_str .= " inner join "."(".$this->conditionChuantouSql.")conditionChuantouSql2 on a.".$tmpfocus->table_index."=conditionChuantouSql2.".$tmpfocus->table_index ;
            $this->curdatarangsql .=" inner join ($this->conditionChuantouSql)conditionChuantouSql2 on conditionChuantouSql2.".$tmpfocus->table_index."=".$tmpfocus->table_name.".".$tmpfocus->table_index;
        }

    }
}



