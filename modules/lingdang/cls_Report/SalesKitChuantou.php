<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");

/**
 * 处理销售简报穿透的类
 */
class SalesKitChuantou extends cls_getPenetrateModuleList
{
    public $searchtype ;
    public $popuptitle ;
    public  $penetrateModuleArr ;
    public $chuantouSearchArr ;
    public $saleskit_params ;
    public $curdatarangsql_str ;
    public $datarangesqlArr ;
    public $curdatarangsql ;
    public function __construct(){
        parent::__construct();
    }
    //设置参数  boardid boardstuffid等
    public function setParams($params){
        $this->params = $params;

        $this->boardid = $params['boardid'];
        $this->boardstuffid = $params['boardstuffid'];
        $this->stuffid = $params['stuffid'];

        $this->scopeType = $params['scopeType'];//数据范围类型
        $this->selectuserid = $params['selectuserid'];//选择的userid
        $this->search_date_custom_value = $params['search_date_custom_value'];//时间范围的值
        //$this->daterange = getHomeDateScope($this->search_date_custom_value);
        $this->approve_value = $params['approve_value'];//审批状态的值
        $this->searchtype = $params['searchtype'];//穿透是本期还是上期  本期now 上期prev
        $this->penetrateModule = $params['penetrateModule'];//穿透模块

        //字段排序功能
        $this->sortType = $params['sortType'] ?? 'DEFAULT';

        $this->sortColumnName = $params['sortColumnName'] ?? '';

    }
    public function setExtroCondition(){

    }
    public function getSalesKitInfo(){
        global $languageType;
        $stufflabel=  $this->params['stufflabel'];
        $stuffid=$this->stuffid;

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
        a.advance_demand_groups,
        a.compute_module,
        a.compute_columns,
        a.groupby
        from ld_homestuffdetail a 
        where a.stuffid=? and stufflabel=?";

        $res = $adb->pquery($sql,$whereArr);
        $numrows = $adb->num_rows($res);
        $info = [];

        if($numrows>0){
            if(empty($penetrateModule)){
                $penetrateModule = $adb->query_result($res,0,'compute_module');
            }
            for($i=0;$i<$numrows;$i++){
                $compute_module = $adb->query_result($res,$i,'compute_module');

                if(!vtlib_isModuleActive($compute_module)){
                    continue;
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

        $this->stuffinfo = $info[$penetrateModule];//组件信息
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
        $label = strip_tags($label);////zxm @date:2024/11/13 @reason: 天地的简报 中英文名称有html 导出
        if($stuffid==35){
            $this->popuptitle = getFixedLabel('saleskit').'>'.$label.'>'.($this->searchtype=='now'?getFixedLabel('THISPERIOD'):getFixedLabel('PREVIOUSDATA'));//穿透弹窗的标题
        }else{
            $this->popuptitle = $label;
        }

        $this->penetrateModuleArr = array_keys($info);
        $this->penetrateModule = empty($this->penetrateModule)?$this->penetrateModuleArr[0]:$this->penetrateModule;//穿透模块第一个 先考虑一个模块的穿透

        return $info;
    }
    public function getDatarangesqlArr($boardstuffid){
        crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
        $salesKitSetObj = SalesKitEditSetting::getInstance($this->boardid);
        $salesKitSetObj->setStuffId($this->stuffid);
        $salesKitSetObj->setBoardStuffId($this->boardstuffid);
        $EqualDuration = $salesKitSetObj->getSaleskitLayout($this->boardstuffid)['EqualDuration'];

        $stuffDetailDateRangeArr = $this->DataRangeHomeboardObj->getHomeDateScope($this->search_date_custom_value,$EqualDuration); //获取时间范围  返回的是一个数组
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

        //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
        $datarangesql_str = $this->DataRangeHomeboardObj->getDataRangeSqlSalesKit($this->saleskit_params);
        $datarangesqlArr = $this->DataRangeHomeboardObj->datarangesqlArr;

        $this->curdatarangsql_str = $this->searchtype=='last'?$datarangesql_str['prev']:$datarangesql_str['cur'];//不带innerjoin 的
        $this->curdatarangsql = $this->searchtype=='last'?$datarangesqlArr['prev']:$datarangesqlArr['cur'];//带inner join 的

    }
     public function getScopeModule()
    {
        //数据范围依赖模块
        $this->scopemodule = $this->penetrateModule;
    }
    public function getStuffInfo()
    {
        
    }
    //移动端穿透的条件SQL
    public function getChuantouSql(){
        $this->getSalesKitInfo();//销售简报
        $this->getStuffinfo();
        //移动端的穿透 因为chuantousql是inner join 到pagelistquery上,移动端的pagelistquery只有salesorderid,innerjoin 只有的链接字段只能是salesorderid
        $this->stuffinfo['compute_columns'] = '';
        $this->setExtroCondition();
        $this->getDatarangeObj();//设置数据范围类
        //只有高级查找 移动端
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);
        $this->getScopeModule();
        return $this->curdatarangsql;
    }
    /*销售简报的穿透
    public function getListView(){
        $this->getPageSearch();
        $this->getSalesKitInfo( );
        $this->getDatarangeObj();

        if(!empty($this->basicsearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->getDatarangesqlArr($this->boardstuffid);

        //数据范围依赖模块
        $this->scopemodule = $this->penetrateModule;
        $this->commonReturn();
    }*/

    /*public function getHomeDateScope() {
        crm_load_class_file('HomeStuffDetailUtils','modules/Home');
        return HomeStuffDetailUtils::getHomeDateScope($this->search_date_custom_value,[
            'boardid' => $this->boardid,
            'stuffid' => $this->stuffid,
            'boardstuffid' => $this->boardstuffid,
        ]);
    }*/
    
}



