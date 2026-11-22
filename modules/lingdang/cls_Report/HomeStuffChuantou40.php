<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/HomeStuffChuantou.php");
/**
 * 处理首页默认组件穿透的类
 */
class HomeStuffChuantou40 extends HomeStuffChuantou
{
    public function __construct(){
        parent::__construct();
    }
    public function setExtroCondition(){
        $stuffid = $this->stuffid;
        $XAxisName = $_REQUEST['XAxisName'];//月份
        $dataIndex = $_REQUEST['dataIndex'];//月份index

        $SeriesName = $_REQUEST['SeriesName'];//0目标值 1完成值 2完成率
        $SeriesIndex = $_REQUEST['SeriesIndex'];//0目标值 1完成值 2完成率

        require_once globalStatic::$root_directory.'modules/SalesGoal/SalesGoalNew.class.php';
        $SalesGoalNewObj = new SalesGoalNew();
        $SalesGoalNewObj->set_cur_module('SalesGoal');
        $SalesGoalNewObj->setUnitExist('yes');
        $SalesGoalNewObj->setSelectUserIds($_REQUEST['selectuserid']);
        $SalesGoalInfo = $SalesGoalNewObj->getSalesGolaInfoByid($_REQUEST['targetid']);//指标信息
        $this->popuptitle .= '->' . $SalesGoalInfo['label'];
        if($XAxisName)
            $this->popuptitle .= '->' . $XAxisName;
        if($SeriesName)
            $this->popuptitle .= '->' . $SeriesName;

        $_REQUEST['SmOwnerSearchScope'] = $this->scopeType;
        $_REQUEST['module_look'] = $_REQUEST['data_type'];
        $_REQUEST['targetname'] = $_REQUEST['data_type'];
        if($this->stuffid==40) {
            //这个是近6个月目标完成情况的穿透
            $this->deleteDaterange();//近六个月  不需要读取筛选条件中的时间条件
            $dateArr = [];
            for ($i = 0; $i < 6; $i++) {
                $dateArr[$i] = date("Y-m", strtotime("-" . (5 - $i) . " month"));
            }
            $yearmonth = $dateArr[$dataIndex];//年月
            $yearmontharr_origin = [$yearmonth];
            $yearmonth_arr = explode('-',$yearmonth);
            $_REQUEST['viewrangeone_year'] = $yearmonth_arr[0];
            $_REQUEST['viewrangeone_month'] = (int)$yearmonth_arr[1];
            $_REQUEST['viewrangetwo_year'] = $yearmonth_arr[0];
            $_REQUEST['viewrangetwo_month'] = (int)$yearmonth_arr[1];
        }
        else{
            $yearmontharr = getHomeDateArray($this->search_date_custom_value);
            $yearmontharr_origin =$yearmontharr;
            foreach($yearmontharr as $k=>&$v){
                $v = explode('-',$v);
            }
            //这个是目标完成率的完成值的穿透
            $_REQUEST['viewrangeone_year'] = $yearmontharr[0][0];
            $_REQUEST['viewrangeone_month'] = (int)$yearmontharr[0][1];
            if(count($yearmontharr)==1){
                $_REQUEST['viewrangetwo_year'] = $yearmontharr[0][0];
                $_REQUEST['viewrangetwo_month'] = (int)$yearmontharr[0][1];
            }else{
                $_REQUEST['viewrangetwo_year'] = $yearmontharr[1][0];
                $_REQUEST['viewrangetwo_month'] = (int)$yearmontharr[1][1];
            }


        }
        $detailinfo = $SalesGoalInfo['detailinfo']; //指标详情信息
        $moduleArr = _array_column($detailinfo,'entitytype');
        $this->penetrateModuleArr = array_unique($moduleArr);//穿透模块数组
        $this->penetrateModule = empty($this->penetrateModule)?$this->penetrateModuleArr[0]:$this->penetrateModule;//穿透模块第一个 先考虑一个模块的穿透

        $record_info = $SalesGoalNewObj->GetRecordInfo($SalesGoalInfo,$this->scopeType);

        if($SeriesIndex!=1&&$SeriesIndex!=2){
            return;
        }



        $searchType = $_REQUEST['searchType'];
        if($searchType=='Basic'&&!empty($_REQUEST['searchText'])){
            //销售漏斗的基本查找特殊处理  因为销售阶段这个值放在了高级查找数组中 基本查找数组会被覆盖掉 所以将基本查找也放到高级查找中去
            $this->advancesearchArr['advft_criteria'] = [];
            $this->advancesearchArr['advft_criteria_groups'] = [];
            $searchField = $_REQUEST['searchField'];
            $searchText = $_REQUEST['searchText'];
            $tmpadvft_criteria[] = ['groupid'=>1,
                'columnname'=>$searchField,
                'comparator'=>'c',
                'value'=>$searchText,
                'columncondition'=>''
            ];
            $this->advancesearchArr['advft_criteria'] = json_encode($tmpadvft_criteria);
            $this->advancesearchArr['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
            $this->advancesearchArr['searchtype'] = 'advance';
        }


        /*这个条件 目标类穿进去了  不需要再传
         * if(!empty($yearmonth)){
            $advft = $this->advancesearchArr;
            $advft_criteria = $advft['advft_criteria'];
            $advft_criteria_groups = $advft['advft_criteria_groups'];
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
            $lenOfAdv = count($advft_criteria);
            if($lenOfAdv>=1){
                $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            }
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$datefield,
                'comparator'=>'c',
                'value'=>$yearmonth,
                'columncondition'=>''
            ];


            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
        }*/
        //$this->advancesearchArr = $advft;//穿透特殊条件

        foreach ($detailinfo as $tmp_info) {
            //entitytype 是模块
            if($tmp_info['entitytype']==$this->penetrateModule){
                $SalesGoalNewObj->advancesearchArr = $this->advancesearchArr;//高级查找 基本查找组装的高级查找数组 直接传到SalesGoalNewObj生成page_list_query
                $SalesGoalNewObj->get_page_query_new($tmp_info, $yearmontharr_origin, $record_info);
                $this->curdatarangsql_str = $SalesGoalNewObj->getlist_page_query();
            }
        }

    }
    public function getDatarangesqlArr($boardstuffid){
        $tmpfocus = CRMEntity::getInstance($this->penetrateModule);
        //$this->DataRangeHomeboardObj->getDataRangeSqlHigh($this->penetrateModule,$this->penetrateModule,'no','','');
        //$this->curdatarangsql_str =$this->DataRangeHomeboardObj->get_query_obj($this->penetrateModule)->getQuery(1);

        //拼接特殊穿透条件//高级查找 基本查找组装的高级查找数组 直接传到SalesGoalNewObj生成page_list_query
        //$this->curdatarangsql_str = "select a.* from ($this->curdatarangsql_str)a inner join (".$this->conditionChuantouSql.")conditionChuantouSql on a.".$tmpfocus->table_index."=conditionChuantouSql.".$tmpfocus->table_index ;

        //拼接特殊穿透条件
        $this->curdatarangsql=  " inner join ($this->curdatarangsql_str)conditionChuantouSql on conditionChuantouSql.".$tmpfocus->table_index."=".$tmpfocus->table_name.".".$tmpfocus->table_index;

    }
    public function getListView()
    {
        $SeriesIndex = $_REQUEST['SeriesIndex'];//0目标值 1完成值 2完成率
        if($SeriesIndex!=1&&$SeriesIndex!=2){
            //目标值---直接引入ListViewNew.php
            $_REQUEST['ajax'] = 'yes';

            $this->getStuffinfo();
            $this->setExtroCondition();

            //edit: xll 2024/03/07 BUG20240305-45 “目标完成率”-目标值，弹出层中没有滚动条，左侧成员显示不完整
            //ListViewNew.php中的返回值数组，在此处添加 title、penetrateModule
            $tmparr['title'] = $this->popuptitle;
            $tmparr['penetrateModule'] = 'SalesGoal';
            include_once globalStatic::$root_directory.'modules/SalesGoal/ListViewNew.php';
            die;
        }else {

            //完成值 完成率 整体的思路是把销售目标的设置组成一个子查询  穿透条件是一个子查询 两个inner join
            $this->getPageSearch();
            $this->getStuffinfo();
            $this->setExtroCondition();
            $this->setOrderByTable();
            $this->getDatarangeObj();//设置数据范围类

            //高级查找基本查找组装的高级查找数组 直接传到SalesGoalNewObj生成page_list_query
            //if (!empty($this->basicsearchArr))
                //$this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr, $this->penetrateModule);//設置高級查找和基本查找的參數
            //if (!empty($this->advancesearchArr))
                //$this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr, $this->penetrateModule);//設置高級查找和基本查找的參數

            $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);
            $this->getScopeModule();

            $this->commonReturn();
        }
    }
}



