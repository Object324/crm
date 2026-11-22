<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/SalesKitChuantou.php");

/**
 * 处理龙虎榜穿透的类
 */
class DragonTigerChuantou extends SalesKitChuantou
{
    public function __construct(){
        parent::__construct();
    }
    public function getGroupbyColumn(){
        //获取分组字段信息--start
        $groupby = $this->stuffinfo['groupby'];
        $penetrateModule = $this->penetrateModule;
        $penetrateFocus = CRMEntity::getInstance($penetrateModule);
        $fieldobj =  $penetrateFocus->fieldobj;
        $moduleAllPreseneceFields_main = $fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
        $moduleAllPreseneceFields_detail = [];
        $detailfieldobj = '';
        if($penetrateFocus->detailfieldobj){
            $detailfieldobj = $penetrateFocus->detailfieldobj;
            $moduleAllPreseneceFields_detail= $detailfieldobj->getModuleAllPreseneceFields();
        }
        $moduleAllPreseneceFields = array_merge($moduleAllPreseneceFields_main,$moduleAllPreseneceFields_detail);
        //分组字段--统计维度
        if(!empty($groupby)){
            $groupby_arr = explode(':',$groupby);
            //判断该字段是否存在 是否删除
            if(isset($moduleAllPreseneceFields[$groupby_arr[2]])) {
                //groupby字段存的值已经是需要的格式  直接return
                return $groupby;
            }
        }
        $groupbycolumnname = $penetrateFocus->getSmownerColumName();
        $groupbytablename = $penetrateFocus->table_name;
        $groupby_fieldinfo = $fieldobj->getFieldInfoobjBykey('columnname',$groupbycolumnname);
        $typeofdata = $groupby_fieldinfo->getTypeOfData();
        $typeofdata_arr = explode('~',$typeofdata);
        $fieldname = $groupby_fieldinfo->getFieldName();
        $groupby_combine = $groupbytablename.":".$groupbycolumnname.":".$fieldname.":".$penetrateModule."_fieldlabel:".$typeofdata_arr[0];
        //获取分组字段信息--这里是默认值--end
        return $groupby_combine;
    }
    public function setExtroCondition(){
        $searchType = $_REQUEST['searchType'];
        if($searchType=='Basic'&&!empty($_REQUEST['searchText'])){
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
        }

        $groupby_value = $_REQUEST['groupby_value'];
        $groupby_column = $this->getGroupbyColumn();
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
            'columnname'=>$groupby_column,
            'comparator'=>'findinset',
            'value'=>$groupby_value,
            'columncondition'=>''
        ];
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';
        $this->advancesearchArr = $advft;
    }

    public function getDatarangesqlArr($boardstuffid){
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
            'daterange'=>$this->stuffinfo['daterange']//日期字段限制字段
        ];
        $this->saleskit_params['searchtype'] = 'now';
        //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
        $datarangesql_str = $this->DataRangeHomeboardObj->getDataRangeSqlSalesKit($this->saleskit_params);
        $datarangesqlArr = $this->DataRangeHomeboardObj->datarangesqlArr;
        $this->curdatarangsql_str = $datarangesql_str['cur'];//不带innerjoin 的
        $this->curdatarangsql = $datarangesqlArr['cur'] ;//带inner join 的


    }

}



