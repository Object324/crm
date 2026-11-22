<?php
require_once globalStatic::$root_directory.'modules/Home/HomeParentUtils.php';

class HomeCustomSheetUtils extends HomeParentUtils{

    public $curviewid = 0;
    public $pagerows = 12;
    public $havetableheader = 'yes';
    //组件额外的条件
    public function addOtherCondition($DataRangeHomeboardObj){
        $stuffid = $this->stuffid;
        $temparr_advance = array();
        //未来七天日程组件
        if($stuffid=='11'){
            $dbStartDateTime = date('Y-m-d').' 00:00:00';
            $endDateTime=date('Y-m-d').' 23:59:59';
            $endDateTime=date('Y-m-d H:i:s',strtotime("$endDateTime +6 day"));
            $temparr_advance = $this->setStuffConditionCalendar11or10($temparr_advance,"$dbStartDateTime,$endDateTime");
            $DataRangeHomeboardObj->setCustomEchartHighSearchParam($temparr_advance);
        }else if($stuffid=='10'){
            //过去7天内日程
            $endDateTime=date('Y-m-d').' '.'23:59:59';
            $startDateTime=date('Y-m-d',strtotime("$endDateTime -6 day")).' '.'00:00:00';
            $temparr_advance = $this->setStuffConditionCalendar11or10($temparr_advance,"$startDateTime,$endDateTime");
            $DataRangeHomeboardObj->setCustomEchartHighSearchParam($temparr_advance);
        }else if($stuffid=='12'){
            //过期未完成日程
            $startDateTime=date('Y-m-d').' 00:00:00';
            $temparr_advance = $this->setStuffConditionCalendar12($temparr_advance,$startDateTime);
            $DataRangeHomeboardObj->setCustomEchartHighSearchParam($temparr_advance);
        }else{
            $functionname = 'setCondition'.$this->stuffid;
            if(method_exists($this,$functionname)) {
                $temparr_advance = $this->$functionname($temparr_advance);//穿透特殊条件
            }
            if(!empty($temparr_advance)){
                $DataRangeHomeboardObj->setCustomEchartHighSearchParam($temparr_advance);
            }
        }

    }
    public function setStuffConditionCalendar11or10($advft,$datebetween){
        if(!empty($datebetween)){
            global $adb;
            $advft_criteria = $advft['advft_criteria'];//条件json
            $advft_criteria_groups = $advft['advft_criteria_groups'];//条件分组json
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?json_decode('[null,{"groupcondition":""}]',true):json_decode($advft_criteria_groups,true);

            $lenOfAdv = count($advft_criteria);
            $nextGroupid = 1;
            if($lenOfAdv>=1){
                $nextGroupid = $advft_criteria[$lenOfAdv-1]['groupid']+1 ;
            }
            $lenOfAdvGroup = count($advft_criteria_groups);
            if($lenOfAdvGroup>=1){
                $advft_criteria_groups[$lenOfAdvGroup-1]['groupcondition'] = 'and';
            }
            //开始时间
            $advft_criteria[] = ['groupid'=>$nextGroupid,
                'columnname'=>'ld_activity:date_start:date_start:Calendar_fieldlabel:DT',
                'comparator'=>'bw',
                'value'=>$datebetween,
                'columncondition'=>'or'
            ];
            //结束时间
            $advft_criteria[] = ['groupid'=>$nextGroupid,
                'columnname'=>'ld_activity:due_date:due_date:Calendar_fieldlabel:DT',
                'comparator'=>'bw',
                'value'=>$datebetween,
                'columncondition'=>''
            ];
            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
            return $advft;
        }
        return $advft;
    }
    public function setStuffConditionCalendar12($advft,$datestart){
        if(!empty($datestart)){
            $advft_criteria = $advft['advft_criteria'];//条件json
            $advft_criteria_groups = $advft['advft_criteria_groups'];//条件分组json
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?json_decode('[null,{"groupcondition":""}]',true):json_decode($advft_criteria_groups,true);

            $lenOfAdv = count($advft_criteria);
            $nextGroupid = 1;
            if($lenOfAdv>=1){
                $nextGroupid = $advft_criteria[$lenOfAdv-1]['groupid']+1 ;
            }
            $lenOfAdvGroup = count($advft_criteria_groups);
            if($lenOfAdvGroup>=1){
                $advft_criteria_groups[$lenOfAdvGroup-1]['groupcondition'] = 'and';
            }
            //开始时间
            $advft_criteria[] = ['groupid'=>$nextGroupid,
                'columnname'=>'ld_activity:due_date:due_date:Calendar_fieldlabel:DT',
                'comparator'=>'l',
                'value'=>$datestart,
                'columncondition'=>'and'
            ];
            $advft_criteria[] = ['groupid'=>$nextGroupid,
                'columnname'=>'ld_activity:eventstatus:eventstatus:Calendar_fieldlabel:V',
                'comparator'=>'n',
                'value'=>getFixedLabel('Executed'),
                'columncondition'=>''
            ];

            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';

            return $advft;
        }
        return $advft;
    }
    //消息中心
    public function setCondition118($advft){
        global $current_user;
        $data_type = $this->params['data_type'];
        //保存最近选择的页签值
        setUsersettingByLabel('Reminds',$current_user->id,'new_reminds_modules',$data_type);

        if($data_type=='LBL_READEN'){
            //已读
            $this->curviewid = 114;
        }else{
            //未读
            $this->curviewid = 108;
            $reltab = $data_type;
            $advft_criteria = $advft['advft_criteria'];//条件json
            $advft_criteria_groups = $advft['advft_criteria_groups'];//条件分组json
            $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
            $advft_criteria_groups = empty($advft_criteria_groups)?json_decode('[null,{"groupcondition":""}]',true):json_decode($advft_criteria_groups,true);

            $lenOfAdv = count($advft_criteria);
            $nextGroupid = 1;
            if($lenOfAdv>=1){
                $nextGroupid = $advft_criteria[$lenOfAdv-1]['groupid']+1 ;
            }
            $lenOfAdvGroup = count($advft_criteria_groups);
            if($lenOfAdvGroup>=1){
                $advft_criteria_groups[$lenOfAdvGroup-1]['groupcondition'] = 'and';
            }

            $advft_criteria[] = ['groupid'=>$nextGroupid,
                'columnname'=>'ld_reminds:reltab:reltab:Reminds_fieldlabel:M',
                'comparator'=>'e',
                'value'=>getTranstab($reltab),
                'columncondition'=>'and'
            ];
//        $advft_criteria[] = ['groupid'=>$nextGroupid,
//            'columnname'=>'ld_reminds:status_rmd:status_rmd:Reminds_fieldlabel:V',
//            'comparator'=>'e',
//            'value'=>'未读',
//            'columncondition'=>'and'
//        ];
            $advft['advft_criteria'] = json_encode($advft_criteria);
            $advft['advft_criteria_groups'] = $advft_criteria_groups;
            $advft['searchtype'] = 'advance';
        }

        $_REQUEST['viewname'] = $this->curviewid;

        return $advft;

    }
    //获取组件数据
    public function getStuffData(){
        global $current_user,$adb;
        $stuffid = $this->stuffid;

        $boardstuffid = $this->boardstuffid;
        $this->getDataRangeSql();
        if($boardstuffid>0){
            $datarangemodule = $this->boarddatarangmoduleArr[$boardstuffid];
        }else{
            $datarangemodule = $this->DefaultdatarangmoduleArr['defaultstuff_'.$stuffid];
        }
        $page_list_query = $this->datarangesqlArr['datarangesql_'.$datarangemodule];

        $module = $datarangemodule;
        $focus = CRMEntity::getInstance($module);//模块的类
        crm_load_class_file('cls_CustomSheet_CustomView','modules/lingdang/cls_Report');
        global $customView,$viewid; //查询语句排序需要
        $customview = $customView= new cls_CustomSheet_CustomView($module);
        $customview->setColumnsList($this->getColumnList());//设置字段
        $viewid = $this->getViewid($customview);

        if($module=='Reminds'){
            crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
            $queryGenerator = new RemindsQueryGenerator($module, $current_user,$customView);

        }else{
            crm_load_class_file('QueryGenerator','include/QueryGenerator');
            $queryGenerator=new QueryGenerator($module, $current_user,$customview);
        }

        $queryGenerator->initForCustomViewById($viewid);
        $list_query = $queryGenerator->getQuery('',2);//获取SQL
        $controller = $this->getControllerObj($queryGenerator);
        $list_query .= $page_list_query;

        list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);
        $list_query .= $this->getLimitSql($module);//默认显示12条

        $list_result = $adb->pquery($list_query);
        $numrows = $adb->num_rows($list_result);
        $listview_header = [];
        if($this->havetableheader=='yes'){
            $listview_header = $controller->getListViewHeader($focus,$module,'',$sorder,$order_by);//表头 数组形式
        }
        $listview_entries = $controller->getListViewEntries($focus,$module,$list_result,array());//表体数据  数组形式
        $values=Array(
            'Header'=>$listview_header,
            'Entries'=>$listview_entries,
            'havenextpage'=>$numrows==$this->pagerows?'yes':'no',//这一页数据是12条  说明还有下一页
            'pagenum'=> $this->params['pagenum']
        );
        return $values;

    }

    public function getColumnList(){
        //看板编辑界面 修改了这个显示字段  需要根据界面设置的参数来 因为还未保存数据库  需要刷新预览
        if(isset($this->params['showfields'])&&!empty($this->params['showfields'])){
            return $this->params['showfields'];
        }
        $stuffinfo = self::$defaultstuffArr[$this->stuffid];
        $platesetting = $this->getPlateSetting($this->stuffid);
        $selectedfieldsJson = (isset($platesetting['showfields'])&&!empty($platesetting['showfields']))?$platesetting['showfields']:$stuffinfo['showfields'];
        $selectedfieldsArr = Zend_Json::decode(decode_html($selectedfieldsJson));
        return $selectedfieldsArr;
    }
    public function getControllerObj($queryGenerator){
        global $adb,$current_user;
        crm_load_class_file('CustomSheetListViewController','modules/lingdang/cls_Report');
        $controller = new CustomSheetListViewController($adb, $current_user, $queryGenerator);
        $controller->havelistcheckbox = 'no';//不要多选列
        $controller->haveExistsOperation = 'no';//不要操作列
        $controller->haveoperation = false;//不要操作列 最后一列不要合并
        return $controller;
    }
    public function getViewid($customview){
        $module = $customview->customviewmodule;
        static $module_viewid_popup;
        $statickey = 'module_viewid'.$module;
        if(!empty($module_viewid_popup) && isset($module_viewid_popup[$statickey]))
            return $module_viewid_popup[$statickey];
        if($module=='Calendar'){
            //日程管理的数据分类 entitytype是events
            $viewid = $customview->getViewIdByName('All', 'Events');//获取全部的视图ID
        }else if($module=='Reminds'){
            $viewid = $this->curviewid;
        }else{
            $viewid = $customview->getViewIdByName('All', $module);//获取全部的视图ID
        }
        $module_viewid_popup[$statickey] = $viewid;
        return $viewid;
    }
    public function getLimitSql($module){
        if($module=='Reminds'){
            $page = $this->params['pagenum'];
            if($page>1){
                $this->havetableheader = 'no';//不返回表头
            }
            $page = empty($page)?1:$page;
            $start = ($page-1)*$this->pagerows;
            return ' limit '.$start.','.$this->pagerows;//默认显示前12条
        }
        return ' limit '.$this->pagerows;//默认显示前12条
    }

}

