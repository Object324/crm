<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");
/**
 * 处理首页默认组件穿透的类
 */
class HomeStuffChuantou extends cls_getPenetrateModuleList
{
    public function __construct(){
        parent::__construct();
    }
    public function setExtroCondition(){
        $stuffid = $this->stuffid;
        //未来七天日程组件
        if($stuffid=='11'){
            $dbStartDateTime = date('Y-m-d').' 00:00:00';
            $endDateTime=date('Y-m-d').' 23:59:59';
            $endDateTime=date('Y-m-d H:i:s',strtotime("$endDateTime +6 day"));
            $temparr_advance = $this->setStuffConditionCalendar11or10($this->advancesearchArr,"$dbStartDateTime,$endDateTime");
            $this->advancesearchArr = $temparr_advance;
        }else
        //过去7天内日程
        if($stuffid=='10'){
            $endDateTime=date('Y-m-d').' '.'23:59:59';
            $startDateTime=date('Y-m-d',strtotime("$endDateTime -6 day")).' '.'00:00:00';
            $temparr_advance = $this->setStuffConditionCalendar11or10($this->advancesearchArr,"$startDateTime,$endDateTime");
            $this->advancesearchArr = $temparr_advance;
        }else
        //过期未完成日程
        if($stuffid=='12'){
            $startDateTime=date('Y-m-d').' 00:00:00';
            $temparr_advance = $this->setStuffConditionCalendar12($this->advancesearchArr,$startDateTime);
            $this->advancesearchArr = $temparr_advance;
        }else{
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
                //zkt 20240618 BUG20240617-35  首页，最新费用报销单，筛选：备注 房租
                $this->advancesearchArr['searchtype'] = 'advance';
            }


            $functionname = 'setCondition'.$this->stuffid;
            if(method_exists($this,$functionname)) {
                $this->advancesearchArr = $this->$functionname($this->advancesearchArr);//穿透特殊条件
            }
        }

    }

    //最近6个月销售情况
    public function setCondition1($advft){
        $this->deleteDaterange();//近六个月  不需要读取筛选条件中的时间条件
        $dateArr = [];
        for($i=0;$i<6;$i++){
            $dateArr[$i] =date("Y-m",strtotime(date("Y-m")." -".(5-$i)." month"));
        }

        $XAxisName = $_REQUEST['XAxisName'];//月份
        $dataIndex = $_REQUEST['dataIndex'];//数据列  近6个月假设是5.6.7.8.9.10月 dataIndex=2的话 那就是7月
        $clickdatemonth = $dateArr[$dataIndex];//点击的柱子的年月
        $SeriesName = $_REQUEST['SeriesName'];// 0金额  1数量
        $SeriesIndex = $_REQUEST['SeriesIndex']; // 0金额  1数量
        if($XAxisName)
            $this->popuptitle .= '->' . $XAxisName;
        if($SeriesName)
            $this->popuptitle .= '->' . $SeriesName;

        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        //获取设置好的条件
        $filterArr = $DataRangeHomeboardObj->boardfilterArr[$this->boardstuffid];

        if(isset($filterArr['timecomponent_'.$this->penetrateModule])&&!empty($filterArr['timecomponent_'.$this->penetrateModule]['filters'])){
            //新看板
            $tmpfilters = $filterArr['timecomponent_'.$this->penetrateModule]['filters'];
        }else{
            //老看板
            $tmpfocus = CRMEntity::getInstance($this->penetrateModule);
            $tmpfilters = $DataRangeHomeboardObj->getTimeDefaultFieldColumns($tmpfocus,'defaultstuff',$this->stuffid);
        }
        $advft_criteria = $advft['advft_criteria'];
        $advft_criteria_groups = $advft['advft_criteria_groups'];
        $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
        $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
        $lenOfAdv = count($advft_criteria);
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
        }
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>$tmpfilters,
            'comparator'=>'c',
            'value'=>$clickdatemonth,
            'columncondition'=>''
        ];
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';
        return $advft;
    }
    //个人最近6个月销售情况
    public function setCondition9($advft){
        //数据范围不跟首页的筛选条一致  只查询当前用户的
        global $current_user;
        $this->selectuserid = $current_user->id;
        $this->scopeType = 'SmOwner_Search_Me';
        return $this->setCondition1($advft);
    }
    //签约额月度同比
    public function setCondition4($advft){
        $this->deleteDaterange();//近六个月  不需要读取筛选条件中的时间条件
        $dateArr = [];
        for($i=0;$i<12;$i++){
            $dateArr[$i] = str_pad($i+1,2,"0",STR_PAD_LEFT);
        }
        $XAxisName = $_REQUEST['XAxisName'];//月份
        $dataIndex = $_REQUEST['dataIndex'];//数据列  近6个月假设是5.6.7.8.9.10月 dataIndex=2的话 那就是7月

        $SeriesName = $_REQUEST['SeriesName'];// 0去年  1今年
        $SeriesIndex = $_REQUEST['SeriesIndex']; // 0去年  1今年
        $yearnum = $SeriesIndex==0?date('Y')-1:date('Y');
        $clickdatemonth = $yearnum.'-'.$dateArr[$dataIndex];//点击的柱子的年份和月份
        if($XAxisName)
            $this->popuptitle .= '->' . $XAxisName;
        if($SeriesName)
            $this->popuptitle .= '->' . $SeriesName;

        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        //获取设置好的条件
        $filterArr = $DataRangeHomeboardObj->boardfilterArr[$this->boardstuffid];

        if(isset($filterArr['timecomponent_'.$this->penetrateModule])&&!empty($filterArr['timecomponent_'.$this->penetrateModule]['filters'])){
            $tmpfilters = $filterArr['timecomponent_'.$this->penetrateModule]['filters'];
        }else{
            //老看板
            $tmpfocus = CRMEntity::getInstance($this->penetrateModule);
            $tmpfilters = $DataRangeHomeboardObj->getTimeDefaultFieldColumns($tmpfocus,'defaultstuff',$this->stuffid);
        }
        $advft_criteria = $advft['advft_criteria'];
        $advft_criteria_groups = $advft['advft_criteria_groups'];
        $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
        $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
        $lenOfAdv = count($advft_criteria);
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
        }
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>$tmpfilters,
            'comparator'=>'c',
            'value'=>$clickdatemonth,
            'columncondition'=>''
        ];
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';

        return $advft;
    }
    //收款额月度同比
    public function setCondition5($advft){
        return $this->setCondition4($advft);
    }
    //开票额月度同比
    public function setCondition41($advft){
        return $this->setCondition4($advft);
    }
    //出库额月度同比
    public function setCondition42($advft){
        return $this->setCondition4($advft);
    }
    //商机统计图_按销售负责人和销售阶段统计 44
    public function setCondition44($advft){
        $XAxisName = $_REQUEST['XAxisName'];//44负责人名称 //45所属行业  实际上是关联客户的所属行业  需要构建个子查询
        $SeriesName = $_REQUEST['SeriesName'];// 销售阶段名称
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
        if($this->stuffid==44){
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V',
                'comparator'=>'e',
                'value'=>$XAxisName,
                'columncondition'=>'and'
            ];
        }
        if($SeriesName!='全部商机'){
            //点击折线图的点 全部商机 无数据
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_fieldlabel:V',
                'comparator'=>'e',
                'value'=>$SeriesName,
                'columncondition'=>''
            ];
        }

        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';

        return $advft;
    }
    //商机统计图_按所属行业和销售阶段统计--子类重写
    public function setCondition45($advft){

    }
    public function setCondition57($advft){
        $XAxisName = $_REQUEST['XAxisName'];//负责人名称
        $SeriesName = $_REQUEST['SeriesName'];// 销售阶段名称
        $SeriesIndex = $_REQUEST['SeriesIndex'];// 0跟进记录数量 1 拜访签到数量
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
        $focus = CRMEntity::getInstance($this->penetrateModule);
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>$focus->table_name.':smownerid:assigned_user_id:'.$this->penetrateModule.'_fieldlabel:V',
            'comparator'=>'e',
            'value'=>$XAxisName,
            'columncondition'=>''
        ];
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';
        return $advft;
    }
    public function setCondition105($advft){
        if($_REQUEST['SeriesIndex']==0){
            //费用
            $this->penetrateModule = 'Expense';
        }
        if($_REQUEST['SeriesIndex']==1){
            //佣金
            $this->penetrateModule = 'Commission';
        }
        $this->penetrateModuleArr = [$this->penetrateModule];
        return $this->setCondition57($advft);
    }
    public function setCondition60($advft){
        $product_no = $_REQUEST['product_no'];
        if($product_no)
            $this->popuptitle .= '->' . $product_no;

        $advft_criteria = $advft['advft_criteria'];
        $advft_criteria_groups = $advft['advft_criteria_groups'];
        $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
        $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
        $lenOfAdv = count($advft_criteria);
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
        }
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>'ld_products:product_no:product_no:products_fieldlabel:V',
            'comparator'=>'e',
            'value'=>$product_no,
            'columncondition'=>''
        ];
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';

        return $advft;
    }
    public function setCondition106($advft){
        $XAxisName = $_REQUEST['XAxisName'];//客户类型
        $SeriesName = $_REQUEST['SeriesName'];// 销售阶段名称
        //$SeriesIndex = $_REQUEST['SeriesIndex'];// 0跟进记录数量 1 拜访签到数量
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
        $columnname = 'ld_account:leadsource:leadsource:Accounts_fieldlabel:V';
        if($this->stuffid == 107){
            $columnname = 'ld_account:account_type:accounttype:Accounts_fieldlabel:V';
        }
        if($this->stuffid == 119){
            $columnname = 'ld_account:industry:industry:Accounts_fieldlabel:V';
        }
        if ($XAxisName=='无'){
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$columnname,
                'comparator'=>'isnull',
                'value'=>'',
                'columncondition'=>''
            ];
        }else{
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$columnname,
                'comparator'=>'e',
                'value'=>$XAxisName,
                'columncondition'=>''
            ];
        }
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';

        return $advft;
    }
    public function setCondition107($advft){
        return $this->setCondition106($advft);
    }
    public function setCondition119($advft){
        return $this->setCondition106($advft);
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
    

}



