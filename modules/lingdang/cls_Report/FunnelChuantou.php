<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");

/**
 * 处理销售漏斗穿透的类
 */
class FunnelChuantou extends cls_getPenetrateModuleList
{
    public function __construct(){
        parent::__construct();
    }
    //获取页面传过来的基本查找和高级查找的参数 --继承父类getPageSearch

    public function setExtroCondition(){
        //如果是默认组件销售漏斗19
        if( $this->stuffinfo['stuffid']==19&&$this->stuffinfo['stufftype']=='defaultstuff'){
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
            }

            $sales_stage = $_REQUEST['keyvalue'];//销售阶段关键词--PC端是picklistvalue的id,
            $stagename = $_REQUEST['stagename'];//销售阶段关键词--移动端是下拉框值,
            $temparr_advance = $this->setSalesfunnelCondition19($this->advancesearchArr,$sales_stage,$stagename);
            $this->advancesearchArr = $temparr_advance;
        }

    }
   
    //首页预制组件--销售漏斗的特殊处理
    public function setSalesfunnelCondition19($advft,$sales_stageid,$stagename){
        global $adb;
        //PC端
        if(!empty($sales_stageid)){
            $advft_criteria = $advft['advft_criteria'];
            $advft_criteria_groups = $advft['advft_criteria_groups'];
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;

            $picklistvaluesql = "select listvalue from ld_picklist_values where id=?";
            $picklistvalueres = $adb->pquery($picklistvaluesql,array($sales_stageid));
            $sales_stage = $adb->query_result($picklistvalueres,0,0);

            $lenOfAdv = count($advft_criteria);
            if($lenOfAdv>=1){
                $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            }

            $advft_criteria[] = ['groupid'=>1,
            'columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_fieldlabel:V',
            'comparator'=>'c',
            'value'=>$sales_stage,
            'columncondition'=>''
            ];
            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
            return $advft;
        }
        //移动端--//zxm 20240704 点全部阶段的时候穿透数据为空了  BUG20240702-54	ios微信小程序：RM销售漏斗，微信移动端--销售漏斗，预计合同金额点进去没有显示数据（ios系统）
        if(!empty($stagename)&&$stagename!='all'){

            $advft_criteria = $advft['advft_criteria'];
            $advft_criteria_groups = $advft['advft_criteria_groups'];
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;

            $lenOfAdv = count($advft_criteria);
            if($lenOfAdv>=1){
                $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            }

            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_fieldlabel:V',
                'comparator'=>'c',
                'value'=>$stagename,
                'columncondition'=>''
            ];
            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
            return $advft;
        }
        return $advft;
    }


    //获取穿透弹窗内容
   /* public function getListView(){
        $this->getPageSearch();
        $this->getStuffinfo();
        $this->getDatarangeObj();
        $this->setExtroCondition();

        if(!empty($this->basicsearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數


        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

        //数据范围依赖模块
        $scopeisrelated = $this->DataRangeHomeboardObj->filterArr['usercomponent_'.$this->penetrateModule]['isrelated'];
        $this->scopemodule = $scopeisrelated=='yes'?$this->DataRangeHomeboardObj->filterArr['usercomponent_' . $this->penetrateModule]['filtermodule']:$this->DataRangeHomeboardObj->frommodule;//未关联则默认数据范围模块为首页
        $this->commonReturn();

    }*/
    

}



