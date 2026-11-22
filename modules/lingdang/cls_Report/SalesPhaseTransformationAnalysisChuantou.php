<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");
/**
 * 处理 销售阶段转化分析 穿透的类
 */
class SalesPhaseTransformationAnalysisChuantou extends cls_getPenetrateModuleList
{
    public $yingdanlabel ;
    public $conditionChuantouSql;
    public function __construct(){
        parent::__construct();
        $this->yingdanlabel=getFixedLabel('Win');
    }
    public function getDatarangeObj()
    {
        parent::getDatarangeObj();
        $this->DataRangeHomeboardObj->setPenetrateModuleListobj($this);

    }
    public function getTotalGroupBy()
    {
         return " a.potentialid ";
    }
    public function setExtroCondition ( ) {
        if( $this->stuffinfo['stuffid']==112&&$this->stuffinfo['stufftype']=='defaultstuff'){
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
            $boardselect_stage_value = $_REQUEST['boardselect_stage_value'];//上级字段的值
            $temparr_advance = $this->setAdvanceCondition($this->advancesearchArr,$boardselect_stage_value);
            $this->advancesearchArr = $temparr_advance;

            $XAxisName = $_REQUEST['XAxisName'];//销售阶段关键词
            $SeriesName = $_REQUEST['SeriesName'];//销售阶段关键词
            $SeriesIndex = $_REQUEST['SeriesIndex'];//销售阶段关键词

            $this->conditionChuantouSql = $this->setCondition112($XAxisName,$SeriesIndex);//穿透特殊条件  //系列  //0 经过该阶段的商机数  1当前阶段的商机数  2失败商机数 3 成功商机数
        }
        if($_REQUEST['XAxisName'])
            $this->popuptitle .= '->' . $XAxisName;
        if($_REQUEST['SeriesName'])
            $this->popuptitle .= '->' . $SeriesName;
    }
    //级联字段上级字段的条件
    public function setAdvanceCondition($advft,$boardselect_stage_value){
        if(!empty($boardselect_stage_value)){
            $advft_criteria = $advft['advft_criteria'];
            $advft_criteria_groups = $advft['advft_criteria_groups'];
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;

            crm_load_class_file('ModuleUtils','modules/lingdang');
            $ModuleUtilsObj = new ModuleUtils();
            $sourcefield = $ModuleUtilsObj->getPrevAdvanceFieldname('Potentials','sales_stage');
            $tmpfocus = CRMEntity::getInstance('Potentials');
            $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
            $tmpfields = $moduleAllPreseneceFields[$sourcefield];

            $lenOfAdv = count($advft_criteria);
            if($lenOfAdv>=1){
                $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            }
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$tmpfields->getTableName().':'.$tmpfields->getColumnName().':'.$tmpfields->getFieldName().':Potentials_fieldlabel:V',
                'comparator'=>'e',
                'value'=>$boardselect_stage_value,
                'columncondition'=>''
            ];
            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
            return $advft;
        }
        return $advft;
    }
    //获取设置的值
    public function getHomeboardPlateSetting(){
        global $adb;
        $selectsql = "select * from ld_homeboard_plate_setting where boardid=? and stuffid=?";
        $selectres = $adb->pquery($selectsql,array($this->boardid,$this->stuffid));
        $selectnums = $adb->num_rows($selectres);
        $setlist = [];
        $setlist['successlistvalue'] = '成功结案';//多个则以########分隔
        $setlist['faillistvalue'] = '失败结案';
        $setlist['totalcolumn'] = 'totalxrate';

        if($selectnums>0){
            for($i=0;$i<$selectnums;$i++){
                $tmptype = $adb->query_result($selectres,$i,'type');
                $tmpsetvalue = $adb->query_result($selectres,$i,'setvalue');
                if ($tmptype == 'successlistvalue'||$tmptype == 'faillistvalue') {
                    $tmpsetvalue = explode('########', $tmpsetvalue);
                    $tmpsetvalue = implode(",", $tmpsetvalue);
                }
                $setlist[$tmptype] = $tmpsetvalue;
            }
        }
        return $setlist;
    }
    public function setCondition112($XAxisName,$SeriesIndex){
        global $adb;
        $homeboardPlateSetting = $this->getHomeboardPlateSetting();
        //销售阶段
        $sales_stage = $XAxisName;
        //系列  //0 经过该阶段的商机数  1当前阶段的商机数  2失败商机数 3 成功商机数
        require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
        $picklistvalues = getAllPickListValues('sales_stage');
        $picklistvalues = array_values($picklistvalues);
        $firststage = $picklistvalues[0];//第一个阶段的值
        $failstage = $homeboardPlateSetting['faillistvalue'];//失败阶段的值
        $failstage_arr = explode(',',$failstage);
        $successtage = $homeboardPlateSetting['successlistvalue'];//成功阶段的值
        $successtage_arr = explode(',',$successtage);
        $curstage = $sales_stage;//当前点击阶段的值
        if($curstage==$this->yingdanlabel){
            $curstage = $successtage;
        }
        $allsql = "
                    select ld_potential.potentialid from ld_potential where deleted=0";//获取全部数量ID

        $curstage_prev = [];
        foreach($picklistvalues as $value){
            $curstage_prev[] = $value;
            if($value==$curstage){
                break;
            }
        }
        $curstage_prev_str = implode(",",$curstage_prev);
        $sql = '';

        if(!empty($XAxisName)){
            //0 经过该阶段的商机数
            if($SeriesIndex==0){
                //if($XAxisName==$this->yingdanlabel){
                    //$sql = "select ld_potential.potentialid from ld_potential where deleted=0 and ifnull(sales_stage,'')=''";//获取全部数量ID
                //}else {
                    //0 经过该阶段的商机数 =第一减去(第二+第三)
                    //第一 获取全部数量ID
                    //第二 获取当前阶段以及前面阶段的数量ID
                    //第三 获取当前阶段推到失败的ID 以及前面阶段推进到失败的数量ID 
                    $curprevsql = "select ld_potential.potentialid from ld_potential where deleted=0 and find_in_set(sales_stage,'$curstage_prev_str')";//获取当前阶段以及前面阶段的数量ID

                    $failsql = "select potentialid from (
                select  
                ld_potential.potentialid,
                (case when find_in_set(logsql.stage,'$successtage')then '".$this->yingdanlabel."' when ifnull(logsql.stage,'')='' then '$firststage' else logsql.stage end ) as sales_stage
                from ld_potential 
                left  join (
                    select 
                    ld_potstagehistory.potentialid,ld_potstagehistory.stage
                    from  ld_potstagehistory 
                    inner join(
                        select 
                        max(historyid) as maxhistoryid
                        from  ld_potstagehistory
                        group by potentialid,sales_stage
                    )maxhistory on maxhistory.maxhistoryid=ld_potstagehistory.historyid
                    where FIND_IN_SET(ld_potstagehistory.sales_stage,'$failstage') 
                    group by ld_potstagehistory.potentialid
                    order by ld_potstagehistory.historyid desc 
                )logsql on logsql.potentialid=ld_potential.potentialid
                inner join (
                    select DISTINCT potentialid
                    from ld_potential where deleted=0 
                )datarangsql on datarangsql.potentialid=ld_potential.potentialid
                where FIND_IN_SET( ld_potential.sales_stage,'$failstage') 
                )a where  find_in_set(sales_stage,'$curstage_prev_str')
                ";
                    $sql = "select a.* from ($allsql)a 
left join (
$curprevsql
union all
$failsql
)b on a.potentialid=b.potentialid where b.potentialid is null ";
                //}

            }
            //当前阶段的销售机会
            if($SeriesIndex==1){
                $sql = "select ld_potential.potentialid from ld_potential where deleted=0 and find_in_set(sales_stage,'$curstage')";//获取当前阶段以及前面阶段的数量ID
            }
            //2 当前阶段推到失败阶段的销售机会
            if($SeriesIndex==2){
                $sql = "select potentialid from (
                select  
                ld_potential.potentialid,
                (case when find_in_set(logsql.stage,'$successtage')then '".$this->yingdanlabel."' when ifnull(logsql.stage,'')='' then '$firststage' else logsql.stage end ) as sales_stage
                from ld_potential 
                left  join (
                    select 
                    ld_potstagehistory.potentialid,ld_potstagehistory.stage
                    from  ld_potstagehistory 
                    inner join(
                        select 
                        max(historyid) as maxhistoryid
                        from  ld_potstagehistory
                        group by potentialid,sales_stage
                    )maxhistory on maxhistory.maxhistoryid=ld_potstagehistory.historyid
                    where FIND_IN_SET(ld_potstagehistory.sales_stage,'$failstage') 
                    group by ld_potstagehistory.potentialid
                    order by ld_potstagehistory.historyid desc 
                )logsql on logsql.potentialid=ld_potential.potentialid
                inner join (
                    select DISTINCT potentialid
                    from ld_potential where deleted=0 
                )datarangsql on datarangsql.potentialid=ld_potential.potentialid
                where FIND_IN_SET( ld_potential.sales_stage,'$failstage') 
                )a where sales_stage='$sales_stage'
                ";
            }
            //成功的销售机会
            if($SeriesIndex==3){
                $sql = "select ld_potential.potentialid from ld_potential where deleted=0 and FIND_IN_SET(sales_stage,'$successtage')";
            }
        }
        return $sql;
    }
    public function getDatarangesqlArr($boardstuffid){
        $XAxisName = $_REQUEST['XAxisName'];//销售阶段关键词
        $SeriesName = $_REQUEST['SeriesName'];//销售阶段关键词
        $SeriesIndex = $_REQUEST['SeriesIndex'];//销售阶段关键词

        /*if($SeriesIndex==0&&$XAxisName==$this->yingdanlabel){
            //穿过赢单的单据 一般是sales_stage为空的
            //拼接特殊穿透条件
            $this->curdatarangsql=$this->conditionChuantouSql;//不带inner join 的
            //拼接特殊穿透条件
            $this->curdatarangsql=  " inner join ($this->conditionChuantouSql)conditionChuantouSql on conditionChuantouSql.potentialid=ld_potential.potentialid"; ;
        }else{*/
            //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
            $daterange = $this->daterange;
            $this->datarangesql = $this->DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$boardstuffid,$this->scopeType,$this->selectuserid,$daterange,$this->approve_value);
            $this->datarangesqlInnerJoin = $this->DataRangeHomeboardObj->datarangesqlArr;//这个数组中的条件sql子查询是带inner join 和on 的
            $this->curdatarangsql_str = $this->datarangesql[$this->penetrateModule]; //不带innerjoin 的
            //拼接特殊穿透条件
            $this->curdatarangsql_str = "select a.* from ($this->curdatarangsql_str)a inner join (".$this->conditionChuantouSql.")conditionChuantouSql on a.potentialid=conditionChuantouSql.potentialid" ;
            $this->curdatarangsql=$this->datarangesqlInnerJoin['datarangesql_'.$this->penetrateModule];//带inner join 的
            //拼接特殊穿透条件
            $this->curdatarangsql=  $this->curdatarangsql." inner join ($this->conditionChuantouSql)conditionChuantouSql on conditionChuantouSql.potentialid=ld_potential.potentialid";
//        }

    }



    public function getListView()
    {

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

        $this->commonReturn();
    }
}



