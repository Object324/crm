<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");
/**
 * 处理 线索漏斗 穿透的类
 */
class LeadsFunnelChuantou extends cls_getPenetrateModuleList {

    private $HomeUtilsObj;
    public function __construct(){
        parent::__construct();
    }

    public function setParams($params){
        parent::setParams($params);
        //线索漏斗的穿透模块
        $this->penetrateModule = $params['XAxisName'];
    }
    public function getDatarangeObj(){
       parent::getDatarangeObj();

     $this->DataRangeHomeboardObj->setPenetrateModuleListobj($this);


    }
    public function getTotalGroupBy()
    {

        return "";
    }
    public function getStuffinfo(){
        parent::getStuffinfo();
        //线索漏斗的穿透模块
        $penetrateModule = $_REQUEST['XAxisName'];
        $this->penetrateModule = $penetrateModule;
        $this->penetrateModuleArr = [];
        $this->popuptitle .= ' -> ' . getTranstab($penetrateModule);
    }

    public function getDatarangesqlArr($boardstuffid){

    }

    public function setExtroCondition(){
        //edit: xll 2024/02/01 BUG20240112-04 线索漏斗-穿透界面，高级查找和基本查找无效
        $this->getDatarangeObj();
        if(!empty($this->basicsearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $fieldname = 'leadsource';
        $countType = 'count';
        crm_load_class_file('Homeboard','modules/Home');
        $PlateSetting = Homeboard::getPlateSetting($this->boardid,$this->stuffid);
        if(isset($PlateSetting['classifyField']) && isset($PlateSetting['classifyField'])){
            $fieldname = explode(':',$PlateSetting['classifyField'])[2];
            $countType = $PlateSetting['countType'];
        }
        $module_arr = explode(',',$this->stuffinfo['datarangmodule']);
        $module_path = [
            'start' => $module_arr[0],
            'path' => $module_arr,
        ];
        crm_load_class_file('HomeChartUtils','modules/Home');
        $HomeUtilsObj = new HomeChartUtils($this->boardid);
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuserid,
            'search_date'=>$this->search_date_custom_value,
            'data_type'=>'',
            'approve_value'=>$this->approve_value,
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid($this->stuffid,$this->boardstuffid);
        $HomeUtilsObj->setGetSQLType('Chuantou');
        $HomeUtilsObj->getDataRangeSql();
        $this->HomeUtilsObj = $HomeUtilsObj;
        $where_arr = $this->getLeadsFunnelSQL($module_path,$fieldname);

        $this->curdatarangsql = $where_arr['where_sql'];
        $this->curdatarangsql_str = $where_arr['where'];
        //dump([$where_arr,$HomeUtilsObj]);
    }

    public function getLeadsFunnelSQL($module_path,$fieldname){
        $HomeUtilsObj = $this->HomeUtilsObj;
        $start_module = $module_path['start'];
        $start_focus = CRMEntity::getInstance($start_module);
        $start_table = $start_focus->table_name;
        $start_field =  $start_table . '.' . $fieldname;
        $path = $module_path['path'];

        $penetrateModule = $this->penetrateModule;
        $head_focus = CRMEntity::getInstance($penetrateModule);
        $head_table = $HomeUtilsObj->new_table_name[$penetrateModule];
        $table_index = $head_focus->table_index;
        $head_field = $head_table . '.' . $table_index;
        $sql_head = 'SELECT DISTINCT ' . $head_field . ' ';

        $sql_body = ' FROM ' . $start_table . ' ' . $HomeUtilsObj->datarangesqlArr['datarangesql_'
        .$start_module];

        $sql_tail = '  ';
        //表格穿透需要考虑类型
        if($_REQUEST['PenetrateType'] === 'Table' && !empty($_REQUEST['SeriesName'])){
            $sql_tail .= ' WHERE '.$start_field.' = \''.$_REQUEST['SeriesName'].'\'';
        }
        if($this->penetrateModule !== $path[0]){
            for ($i = 1; $i < count($path); $i ++) {
                $tmp_module = $path[$i];
                $before_module = $path[$i - 1];
                $tmp_sql_arr = $HomeUtilsObj->getLeadsFunnelSQLModule($tmp_module,$before_module);
                $sql_body .= $tmp_sql_arr['body'] . ' ';
                if($tmp_module === $this->penetrateModule)
                    break;
            }
        }
        else {
            $sql_head = 'SELECT DISTINCT ' . $start_table . '.' . $table_index . ' ';
        }
        $where = $sql_head.$sql_body.$sql_tail;
        $tmptablename = 'chuantou_sql_'.strtolower($penetrateModule);
        $where_sql = ' inner join (' .$where. ') '.$tmptablename.
            ' on '.$tmptablename.'.'.$table_index.' = '.$head_focus->table_name.'.'.$table_index.' ';

        return ['where'=>$where,'where_sql'=>$where_sql];
    }
}