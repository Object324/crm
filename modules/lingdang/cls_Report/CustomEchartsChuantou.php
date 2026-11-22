<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");
/**
 * 处理自定义统计图穿透的类，首页模块
 */
class CustomEchartsChuantou extends cls_getPenetrateModuleList
{
    public $ChartSetInfo;
    public function __construct(){
        parent::__construct();
    }
    public function setParams($params)
    {
        parent::setParams($params);
        $ChartSetInfo = json_decode($_REQUEST['ChartSetInfo'],true);
        crm_load_class_file('DataRangeHomeboard','modules/Home/');
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);

        //获取统计模块信息 zxm 20231208 根据点击的是哪个系列来获取
        $YAxis = $ChartSetInfo['AxisFields']['YAxis'];

        $SeriesIndex = $_REQUEST['SeriesIndex'];
        //漏斗图需要删除尾部的数字
        /*if(in_array($ChartSetInfo['chart_type'],['funnel','triangle','bowls'])){
            $_REQUEST['XAxisName'] = explode('(',$_REQUEST['XAxisName'])[0];
        }*/
        if($ChartSetInfo['chart_type']=='nesting_pie'||count($YAxis)==1){
            //嵌套饼图就一个统计字段
            $cur_computeinfo = $YAxis[0];
        }else{
            $cur_computeinfo = $YAxis[$SeriesIndex];
        }
        $this->params['cur_computeinfo'] = $cur_computeinfo;
        $compare_select = $cur_computeinfo['compare_select'];//同环比选项 //同环比选项  没有同比环比的是cur
        $this->params['compare_select'] = $compare_select;
        $params = [
            'ChartSetInfo' => $ChartSetInfo,
            'penetrateModule' => $cur_computeinfo['FieldModule'],//穿透模块,
            'DataRangeHomeboardObj' => $DataRangeHomeboardObj,
            'curdatarangsql' => '',
            'curdatarangsql_str' => '',
            'popuptitle' => $ChartSetInfo['report_name'],
        ];

        $this->ChartSetInfo = $params['ChartSetInfo'];
        $this->penetrateModule = $cur_computeinfo['FieldModule'];
        $this->penetrateModuleArr = [];
        $this->penetrateModuleArr[] = $this->penetrateModule;
        $this->scopemodule = $params['penetrateModule'];
        $this->DataRangeHomeboardObj = $params['DataRangeHomeboardObj'];
        //$this->report_popuptitle = $params['popuptitle'];
    }
    public function setExtroCondition ( ) {
        crm_load_class_file('CustomEchartsChuantou_Report','modules/lingdang/cls_Report/');
        $ChuantouObj = new CustomEchartsChuantou_Report();
        $ChuantouObj->setParams($this->params);
        $ChuantouObj->DataRangeHomeboardObj = $this->DataRangeHomeboardObj;
        $ChuantouObj->getPageSearch();
        $ChuantouObj->setExtroCondition();

        $this->curdatarangsql_report = $ChuantouObj->curdatarangsql;    //带INNER JION
        $this->curdatarangsql_str_report = $ChuantouObj->curdatarangsql_str;    //不带INNER JION

        if($this->ChartSetInfo['chart_type'] == 'simple_sunburst'){
            if($_REQUEST['treePathInfo']){
                $treePathInfo = $this->treePathInfo = json_decode($_REQUEST['treePathInfo'],true);
                for ($i = 1 ; $i < count($treePathInfo) ; $i ++) {
                    $this->popuptitle .= '->' . $treePathInfo[$i]['name'];
                }
            }
        } else {
            if($_REQUEST['XAxisName'])
                $this->popuptitle .= '->' . $_REQUEST['XAxisName'];
            if($_REQUEST['SeriesName'])
                $this->popuptitle .= '->' . $_REQUEST['SeriesName'];
        }
    }

    //获取穿透弹窗内容
   public function getListView(){
       $this->getPageSearch();
       $this->getStuffinfo();
       $this->setOrderByTable();
       $this->setExtroCondition();
       $this->getDatarangeObj();//设置数据范围类

       $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

       $this->getScopeModule();

       $this->curdatarangsql = $this->curdatarangsql_report;
       $this->curdatarangsql_str =  $this->curdatarangsql_str_report ;
       $this->commonReturn();

    }
    //移动端穿透的条件SQL
    public function getChuantouSql(){
        $this->getPageSearch();
        $this->getStuffinfo();
        $this->setExtroCondition();
        $this->getDatarangeObj();//设置数据范围类
        //只有高级查找 移动端
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

        $this->getScopeModule();
        $this->curdatarangsql = $this->curdatarangsql_report;
        $this->curdatarangsql_str =  $this->curdatarangsql_str_report ;
        return $this->curdatarangsql;
    }
    

}



