<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/HomeStuffChuantou.php");
/**
 * 处理 销售阶段转化分析 穿透的类
 */
class TD_PotentialsFunnelChuantou extends HomeStuffChuantou
{
    public function __construct(){
        parent::__construct();
    }
    public function setCondition115($advft){
        $XAxisName = $_REQUEST['XAxisName'];//销售阶段
        $SeriesName = $_REQUEST['SeriesName'];// form35还是potentials
        $SeriesIndex = $_REQUEST['SeriesIndex'];// 0是form35 1 potentials
        if($XAxisName)
            $this->popuptitle .= '->' . $XAxisName;
        if($SeriesName)
            $this->popuptitle .= '->' . $SeriesName;

        $advft_criteria = $advft['advft_criteria'];
        $advft_criteria_groups = $advft['advft_criteria_groups'];
        $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
        $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
        $lenOfAdv = count($advft_criteria);
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
        }
        if($this->penetrateModule=='CustomForm35'){
            //[{"groupid":"1","columnname":"ld_customform35detailscf:sf815:sf815:CustomForm35_商机阶段:V","comparator":"c","value":"合同签订","columncondition":""}]
            $columnname = 'ld_customform35detailscf:sf815:sf815:CustomForm35_fieldlabel:V';
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$columnname,
                'comparator'=>'e',
                'value'=>$XAxisName,
                'columncondition'=>'and'
            ];
            //advft_criteria: [{"groupid":"1","columnname":"ld_customform35scf:cf_8391:cf_8391:CustomForm35_指标类型:V","comparator":"e","value":"项目类","columncondition":""}]
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_customform35scf:cf_8391:cf_8391:CustomForm35_fieldlabel:V',
                'comparator'=>'e',
                'value'=>'项目类',
                'columncondition'=>'and'
            ];
            //[{"groupid":"1","columnname":"ld_customform35scf:cf_8392:cf_8392:CustomForm35_年度:V","comparator":"e","value":"2023","columncondition":""}]
            require_once globalStatic::$root_directory.'modules/Home/CustomMade/TiandiUtils.php';
            $TiandiUtilsObj = new TiandiUtils($this->boardid);
            $dateInfo = $TiandiUtilsObj->getDateInfo($this->search_date_custom_value);
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_customform35scf:cf_8392:cf_8392:CustomForm35_fieldlabel:V',
                'comparator'=>'e',
                'value'=>$dateInfo['yearnum'],
                'columncondition'=>''
            ];
        }
        if($this->penetrateModule=='Potentials'){
            $columnname = 'ld_potential:sales_stage:sales_stage:Potentials_fieldlabel:V';
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$columnname,
                'comparator'=>'e',
                'value'=>$XAxisName,
                'columncondition'=>''
            ];
        }
        //dump($advft_criteria);
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';

        return $advft;
    }
    public function getDatarangesqlArr($boardstuffid){
        $XAxisName = $_REQUEST['XAxisName'];//销售阶段关键词
        $SeriesName = $_REQUEST['SeriesName'];//销售阶段关键词
        $SeriesIndex = $_REQUEST['SeriesIndex'];//销售阶段关键词
        $daterange = '';
        if($XAxisName=='合同签订'&&$this->penetrateModule=='Potentials'){
            require_once globalStatic::$root_directory.'modules/Home/CustomMade/TiandiUtils.php';
            $TiandiUtilsObj = new TiandiUtils($this->boardid);
            $dateInfo = $TiandiUtilsObj->getDateInfo($this->search_date_custom_value);
            $daterange = " between '".$dateInfo['yearstartdate']."' and '".$dateInfo['enddate']."' ";
        }


        $this->datarangesql = $this->DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$boardstuffid,$this->scopeType,$this->selectuserid,$daterange,$this->approve_value);

        $this->datarangesqlInnerJoin = $this->DataRangeHomeboardObj->datarangesqlArr;//这个数组中的条件sql子查询是带inner join 和on 的
        $this->curdatarangsql_str = $this->datarangesql[$this->penetrateModule]; //不带innerjoin 的
        $this->curdatarangsql=$this->datarangesqlInnerJoin['datarangesql_'.$this->penetrateModule];//带inner join 的
    }
    //移动端穿透的条件SQL
    public function getChuantouSql(){
        $this->getPageSearch();

        $this->getStuffinfo();
        $this->setExtroCondition();
        $this->getDatarangeObj();//设置数据范围类

        if(!empty($this->basicsearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

        $this->getScopeModule();
        return $this->curdatarangsql;
    }
}



