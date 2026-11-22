<?php
require_once(globalStatic::$root_directory . "modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");

class WorkBriefReportChuantou extends cls_getPenetrateModuleList{
    public function __construct(){
        parent::__construct();
    }
    //设置参数  boardid boardstuffid等
    public function setParams($params){
        $this->name=$params['chuantou_name'];
        $this->scopeType = 'smowner_search_senior';//数据范围类型
        $this->boardid = 'workBriefReport';
        $this->boardstuffid = 'WorkBriefReport';
        $this->selectuserid = $params['userid'];//选择的userid
        $this->search_date_custom_value = $params['search_date_custom_value'];//时间范围的值
        $date = explode('~',$this->search_date_custom_value);
        if(sizeof($date) > 1){
            $this->daterange = " between '$date[0] 00:00:00' and '$date[1] 23:59:59' " ;
        }else{
            $this->daterange = " like '%$date[0]%' " ;
        }
        $this->approve_value = 'all';//审批状态的值
        $this->searchtype = 'now';//穿透是本期还是上期  本期now 上期prev

        //字段排序功能
        $this->sortType = $params['sortType'] ?? 'DEFAULT';
        $this->sortColumnName = $params['sortColumnName'] ?? '';
    }
    public function getListView(){
        $this->getPageSearch();
        $this->getSalesKitInfo();//工作简报
        $this->setOrderByTable();
        $this->getDatarangeObj();//设置数据范围类
        if(!empty($this->basicsearchArr)){
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        }
        if(!empty($this->advancesearchArr)) {
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        }
        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);
        $this->getScopeModule();
        $this->commonReturn();
    }
    public function getSalesKitInfo(){
        global $languageType,$adb;
        $sql= "select 
        name,sequence,presence,is_default,label_zh,label_en,count_module,count_type,count_columnname,count_datarange,count_timerange,advft_criteria,advft_criteria_groups,content_value 
        from ld_workreport_briefreport_detail 
        where `delete`=0 and presence = 'yes' and `name`=?";
        $result=$adb->pquery($sql,array($this->name));
        $num_rows=$adb->num_rows($result);
        if ($num_rows>0) {
            $tmpinfo =  $adb->query_result_rowdata($result,0);
            $penetrateModule = $adb->query_result($result, 0, 'count_module');
            $info[$penetrateModule] = $tmpinfo;
            if ($languageType == 'en') {
                $label = $info[$penetrateModule]['label_en'];
            }else{
                $label = $info[$penetrateModule]['label_zh'];
            }
        }
        $this->popuptitle = getFixedLabel('BRIEFREPORTCUSTOMIZATION').'>'.$label;//穿透弹窗的标题
        $this->penetrateModuleArr = array_keys($info);
        $this->penetrateModule = empty($this->penetrateModule)?$this->penetrateModuleArr[0]:$this->penetrateModule;//穿透模块第一个 先考虑一个模块的穿透
        $this->stuffinfo = $tmpinfo;
    }
    public function getDatarangesqlArr($boardstuffid){
        $this->saleskit_params = [
            'stuffid'=>'workBriefReport',
            'compute_module'=>$this->stuffinfo['count_module'],//计算模块
            'scopeType'=>$this->scopeType,//查询范围类型
            'senioruserid'=>$this->selectuserid,//人员ID
            'datewhere'=>$this->daterange,//本期时间
            'before_datewhere'=>'',//上期时间
            'approve_value'=>$this->approve_value,//审批条件
            'advance_demand'=>$_REQUEST['advance_demand'],
            'advance_demand_groups'=>$_REQUEST['advance_demand_groups'],
            'viewrange'=>$this->stuffinfo['count_datarange'],//查看范围限制字段
            'daterange'=>$this->stuffinfo['count_timerange'],//日期字段限制字段
        ];
        $datarangesql_str = $this->DataRangeHomeboardObj->getDataRangeSqlSalesKit($this->saleskit_params);
        $datarangesqlArr = $this->DataRangeHomeboardObj->datarangesqlArr;
        $this->curdatarangsql_str = $this->searchtype=='last'?$datarangesql_str['prev']:$datarangesql_str['cur'];//不带innerjoin 的
        $this->curdatarangsql = $this->searchtype=='last'?$datarangesqlArr['prev']:$datarangesqlArr['cur'];//带inner join 的
    }
}

?>