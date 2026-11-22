<?php
/**
 * Edit: xll
 * Date: 2023/08/25
 * Reason: PC龙虎榜组件的类，含设置、展示龙虎榜的相关方法
 */
crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
class TargetAnalysis extends SalesKitEditSetting
{
    public static $DragonTigerListObjArr;
    public $HomeDateArr;    //首页时间数组，[ 'start' => '' , 'end' => '']
    public $typeArr = ['Target','Done'];
    public $scopeModuleList = [];
    public $SelStuffDetailList = [];
    public $TargetID;

    public function __construct($boardid)
    {
        parent::__construct($boardid);
        $this->setStuffId(114);
        $this->TargetID = $_REQUEST['targetid'];
    }

    public static function getInstance($boardid) {
        if(isset(self::$DragonTigerListObjArr[$boardid])){
            return self::$DragonTigerListObjArr[$boardid];
        }
        self::$DragonTigerListObjArr[$boardid]=new TargetAnalysis($boardid);
        return self::$DragonTigerListObjArr[$boardid];
    }

    //获取所有龙虎榜的SQL和对应参数，含看板是否已选信息
    public function getAllStuffDetailSQL(){
        $sql = "SELECT
                    ld_homestuffdetail.id AS homestuffdetailid, ld_homestuffdetail.stufflabel, ld_homestuffdetail.stufflabel_zh, ld_homestuffdetail.stufflabel_en,
                    ld_homestuffdetail.is_default, ld_homestuffsaleskit2board.sequence,
                    (
                        CASE
                        WHEN IFNULL(ld_homestuffsaleskit2board.homestuffdetailid,'') = '' THEN 'no'
                        ELSE 'yes'
                        END
                    ) AS selected
                FROM
                    ld_homestuffdetail
                LEFT JOIN ld_homestuffsaleskit2board ON ld_homestuffsaleskit2board.homestuffdetailid = ld_homestuffdetail.id
                AND ld_homestuffsaleskit2board.boardid = ? AND ld_homestuffsaleskit2board.relatedid = ? 
                WHERE
                    ld_homestuffdetail.stuffid = ?
                ORDER BY -ld_homestuffsaleskit2board.sequence desc";
        $this->AllSQLParams = array($this->boardid,$this->TargetID,$this->stuffid);
        return $sql;
    }

    public function getAllStuffDetailList(){
        parent::getAllSalesKitList($this->stuffid);
        $StuffDetailList = $this->saleskitlist;
        return $StuffDetailList;
    }

    public function setHomeDateArr($DateArr){
        if(isset($DateArr['search_date'])){
            $HomeDateArr = getHomeDateArray($DateArr['search_date']);
            $this->HomeDateArr =  [
                'start' => $HomeDateArr[0],
                'end' => isset($HomeDateArr[1]) ? $HomeDateArr[1] : $HomeDateArr[0],
            ];
        }
        else
            $this->HomeDateArr = $DateArr;
    }

    public function getStuffLabelList()
    {
        parent::getStuffLabelList();
        $this->StuffLabelList['default']['label'] = getFixedLabel('DefaultTargetAnalysis');
        $this->StuffLabelList['custom']['label'] = getFixedLabel('CustomTargetAnalysis');
    }

    public function getStuffDetailList($result,$type){
        $adb = $this->adb;
        $languageType = $this->language;
        $labelKey = $languageType === 'en' ? 'stufflabel_en' : 'stufflabel_zh';
        $StuffDetailList = [];
        $num_rows = $adb->num_rows($result);//dump($result);
        if($num_rows > 0) {
            $colList = ['homestuffdetailid','stufflabel','stufflabel_zh','stufflabel_en','is_default','selected','sequence'];
            for ($i = 0; $i < $num_rows; $i++) {
                $stufflabel = $adb->query_result($result, $i, 'stufflabel');
                foreach ($colList as $colName){
                    $colValue = $adb->query_result($result, $i, $colName);
                    $StuffDetailList[$stufflabel][$colName] = $colValue;
                }
                $StuffDetailList[$stufflabel]['label'] = $StuffDetailList[$stufflabel][$labelKey];
                $this->getStuffDetailSetValue($StuffDetailList[$stufflabel]);
                $this->PushToStuffLabelList($StuffDetailList[$stufflabel]['is_default'],$StuffDetailList[$stufflabel]);
                if($StuffDetailList[$stufflabel]['selected'] === 'yes'){
                    array_push($this->SelStuffDetailList,$stufflabel);
                }
            }
        }
        return $StuffDetailList;
    }

    public function getStuffDetailSetValue(&$StuffDetaiInfo){
        $SetValue = parent::getStuffDetailSetValue($StuffDetaiInfo);
        $this->getTimeInfo($SetValue);
        $StuffDetaiInfo['SetValue'] = $SetValue;
        return $SetValue;
    }

    public function getTimeInfo(&$SetValue){
        foreach ($this->typeArr as $type){
            $option = [
                'Date' => $SetValue[$type.'Date'],
                'DateFrom' => $SetValue[$type.'DateFrom'],
            ];
            $SetValue[$type.'TimeInfo'] = $this->getStuffDetailTime($option);
        }
    }

    public function getStuffDetailTime($option){
        $getCurTimeFun = 'getCurTime'.$this->TimeFromFun[$option['DateFrom']];
        $curTime = strtotime($this->$getCurTimeFun());
        $startFun = 'getTime'.$this->TimeStartFun[$option['Date']];
        $TimeInfo['start'] = $this->$startFun($curTime);
        $endFun = 'getTime'.$this->TimeEndFun[$option['Date']];
        $TimeInfo['end'] = $this->$endFun($curTime);
        return $TimeInfo;
    }

    public $TimeFromFun = [
        'HomeEnd' => 'HomeEnd',
        'HomeStart' => 'HomeStart',
        'CurTime' => 'CurTime',
    ];

    public function getCurTimeHomeEnd(){
        return $this->HomeDateArr['end'];
    }

    public function getCurTimeHomeStart(){
        return $this->HomeDateArr['start'];
    }

    public function getCurTimeCurTime(){
        return date('Y-n');
    }

    public $TimeStartFun = [
        'Year' => 'YearStart',
        'YearProgress' => 'YearStart',
        'Quarter' => 'QuarterStart',
        'Month' => 'Month',
    ];

    public $TimeEndFun = [
        'Year' => 'YearEnd',
        'YearProgress' => 'Month',
        'Quarter' => 'QuarterEnd',
        'Month' => 'Month',
    ];

    public function getTimeYearStart($curTime){
        return date('Y',$curTime) . '-1';
    }

    public function getTimeYearEnd($curTime){
        return date('Y',$curTime) . '-12';
    }

    public function getTimeMonth($curTime){
        return date('Y-n',$curTime);
    }

    public function getTimeQuarterStart($curTime){
        $quarter = ceil(date('n',$curTime) / 3);
        return date('Y',$curTime) . '-' . ($quarter * 3 - 2);
    }

    public function getTimeQuarterEnd($curTime){
        $quarter = ceil(date('n',$curTime) / 3);
        return date('Y',$curTime) . '-' . ($quarter * 3);
    }

    public function getTargetDoneDataArr($SetValue,$scopeType){
        $DataArr = [];
        require_once(globalStatic::$root_directory.'modules/SalesOrder/ListTopSalesOrder.php');
        foreach ($this->typeArr as $type){
            $TimeInfo = $SetValue[$type.'TimeInfo'];
            $Time = [$TimeInfo['start'],$TimeInfo['end']];
            //dump([$SetValue,$type,$Time[0],$Time[1],$scopeType,$Time]);
            $TargetDoneArr = getSalesGoalListInfo('',$Time[0],$Time[1],$scopeType,$Time);
            $DataArr[$type] = $TargetDoneArr[$type];
        }
        $DataArr['SalesGoalInfo'] = $TargetDoneArr['SalesGoalInfo'];
        return $DataArr;
    }

    public function getNavBarList($smarty)
    {
        if(!$smarty)
            $smarty = new lingdangCRM_Smarty();
        crm_load_class_file('HomeBoardNew_114','modules/Home/HomeBoardNew');
        $HomeBoardNewObj = new HomeBoardNew_114();
        $salesGoalList = $HomeBoardNewObj->getSalesGoalList();
        $HomeBoardNewObj->getPageTabHtml($smarty,$salesGoalList);
        $NavBarList = $HomeBoardNewObj->PageTabList;
        $SelNavBarInfo = $NavBarList[$HomeBoardNewObj->PageTabListSelKey];
        $this->TargetID = $SelNavBarInfo['id'];
        $this->getScopeModuleList($salesGoalList[$SelNavBarInfo['fromKey']]);
        return $NavBarList;
    }

    public function getScopeModuleList($salesGoalInfo){
        //zxm 20240415 BUG20240415-40 移动端工作台定制，“查看范围”下拉选项的模块名称一致时，是不是应该去重？
        $this->scopeModuleList['Home'] = [ 'module' => 'Home' , 'label' => getTranstab('Home')];
        foreach ($salesGoalInfo['detailinfo'] as $index => $info){
            if(!isset($this->scopeModuleList[$info['entitytype']])){
                $this->scopeModuleList[$info['entitytype']] = [ 'module' => $info['entitytype'] , 'label' => getTranstab($info['entitytype'])];
            }
        }
        $this->scopeModuleList = array_values($this->scopeModuleList);
    }

    public function fun_EditTargetAnalysis(){
        $smarty = new lingdangCRM_Smarty();
        $this->setHomeDateArr($_REQUEST);
        $NavBarList = $this->getNavBarList($smarty);
        $TargetAnalysisList = $this->getAllStuffDetailList();
        $layout = parent::getSaleskitLayout(3);
        $boardtype = $layout['boardtype'];
        $smarty->assign('OperationTip','1. ' . getFixedLabel('TargetAnalysisTip') . '</br>2. ' . getFixedLabel('TargetAnalysisTip2'));
        $smarty->assign('StuffLabelList',$this->StuffLabelList);
        $smarty->assign('boardtype',$boardtype);
        $content = $smarty->fetch('Home/EditTargetAnalysis.tpl');
        $resArr = [
            'title' => getFixedLabel('EditTargetAnalysis'),
            'content' => $content,
            'NavBarList' => $NavBarList,
            'selTargetId' => $this->TargetID,
            'scopeModuleList' => $this->scopeModuleList,
            'stuffDetailList' => $TargetAnalysisList,
            'SelStuffDetailList' => $this->SelStuffDetailList,
        ];
        ConvertTojsonString(1,$resArr,"success");
    }

    public function fun_getStuffDetailData(){
        global $languageType;
        crm_load_class_file('HomeUtils','modules/Home');
        $scopeType = $_REQUEST['scopeType'];

        $HomeUtilsObj = new HomeUtils($_REQUEST['boardid']);
        $params = array(
            'scopeType'=>$scopeType,
            'senioruserid'=>$_REQUEST['selectuserid'],
            'search_date'=>$_REQUEST['search_date'],
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid($_REQUEST['stuffid'],'');

        $StuffDetailInfo = json_decode($_REQUEST['StuffDetailInfo'],true);

        $labelKey = ($languageType === 'en') ? 'stufflabel_en' : 'stufflabel_zh';
        $this->setHomeDateArr($_REQUEST);
        //记住页签
        $SetValue = $StuffDetailInfo['SetValue'];
        $this->getTimeInfo($SetValue);
        $DataArr = $this->getTargetDoneDataArr($SetValue,$scopeType);
        $ResArr = $HomeUtilsObj->getTargetDoneRes($DataArr);
        $ResArr['title'] = $StuffDetailInfo[$labelKey];
        $ResArr['homestuffdetailid'] = $StuffDetailInfo['homestuffdetailid'];

        ConvertTojsonString(1,$ResArr,"success");
    }

    public function fun_getGaugeListData(){
        //记住页签
        $targetid = $_REQUEST['targetid'];
        setUsersettingByLabel('SalesGoal','','TargetAnalysis_SalesGoal',$targetid);
        $smarty = new lingdangCRM_Smarty();
        $this->setHomeDateArr($_REQUEST);
        $NavBarList = $this->getNavBarList($smarty);
        $TargetAnalysisList = $this->getAllStuffDetailList();
        $resArr = [
            'selTargetId' => $this->TargetID,
            'scopeModuleList' => $this->scopeModuleList,
            'SelStuffDetailList' => $this->SelStuffDetailList,
        ];
        ConvertTojsonString(1,$resArr,"success");
    }

    public function fun_saveTargetGaugeList(){
        global $adb;
        $this->adb = $adb;
        $this->stuffDetailList = json_decode($_REQUEST['stuffDetailList'],true);
        $targetGaugeListArr = json_decode($_REQUEST['targetGaugeListArr'],true);
        //dump($this->stuffDetailList);
        $this->setValueColArr = ['TargetScope','TargetDate','TargetDateFrom','DoneScope','DoneDate','DoneDateFrom'];
        foreach ($this->stuffDetailList as $stuffLabel => &$stuffDetailInfo){
            //首次新增的
            if(strpos($stuffLabel, 'NEW') !== false){
                $stuffDetailInfo['homestuffdetailid'] = $this->saveNewStuffDetail($stuffDetailInfo);
            }
            //已有的
            else{
                $this->saveOldStuffDetail($stuffDetailInfo);
            }
        }

        //保存至看板
        $delete_sql = 'delete from ld_homestuffsaleskit2board where boardid=? and relatedid=? and homestuffdetailid in (
                            select id from ld_homestuffdetail where stuffid = ? )';
        $boardid = $this->boardid;
        foreach ($targetGaugeListArr as $targetid => $GaugeListInfo){
            $adb->pquery($delete_sql,[$boardid,$targetid,$this->stuffid]);
            $gaugeList = $GaugeListInfo['SelStuffDetailList'];
            if(count($gaugeList) > 0){
                $insert_sql = 'insert into ld_homestuffsaleskit2board(boardid,homestuffdetailid,sequence,relatedtablename,relatedid) values ';
                $insert_params = [];
                foreach ($gaugeList as $index => $stuffLabel){
                    $insert_sql .= '(?,?,?,?,?),';
                    $homestuffdetailid = $this->stuffDetailList[$stuffLabel]['homestuffdetailid'];
                    array_push($insert_params,$boardid,$homestuffdetailid,$index,'ld_salestarget_basic',$targetid);
                }
                $insert_sql = substr($insert_sql,0,-1);
                $adb->pquery($insert_sql,$insert_params);
            }
        }

        $boardstuffid = 0;
        //保存其他设置，行高，行数
        crm_load_class_file('Homeboard','modules/Home');
        $homeboardObj = Homeboard::getInstance($this->boardid,'Home');
        $homeboardObj->saveStuffOtherSet($boardstuffid,["stuffid" => $this->stuffid],[
            "rowNum" => $_REQUEST['rowNum'],
            "rowHeight" => $_REQUEST['rowHeight'],
        ]);
        ConvertTojsonString(1,'',"success");
    }

    public function getNewStuffDetailSQL(){
        $this->NewStuffDetailSQL = 'insert into ld_homestuffdetail(stuffid,stufflabel,stufflabel_zh,stufflabel_en,is_default) values (?,?,?,?,?)';
    }
    public function getNewSetValueSQL(){
        $this->NewSetValueSQL = 'insert into ld_homestuffdetail_setting(homestuffdetailid,type,setvalue) values (?,?,?),(?,?,?),(?,?,?),(?,?,?),(?,?,?),(?,?,?)';
    }
    public function saveNewStuffDetail($stuffDetailInfo){
        $stufflabel = str_replace("NEW","custom_targetanalysis",$stuffDetailInfo['stufflabel']);
        //dump($stufflabel);
        if(!$this->NewStuffDetailSQL)
            $this->getNewStuffDetailSQL();
        $params = [ $this->stuffid,$stufflabel,$stuffDetailInfo['stufflabel_zh'],$stuffDetailInfo['stufflabel_en'],$stuffDetailInfo['is_default'] ];
        $this->adb->pquery($this->NewStuffDetailSQL,$params);
        $homestuffdetailid = $this->adb->getLastInsertID();

        $setValue = $stuffDetailInfo['SetValue'];
        if(!$this->NewSetValueSQL)
            $this->getNewSetValueSQL();
        $setValueParams = [];
        foreach ($this->setValueColArr as $type){
            array_push($setValueParams,$homestuffdetailid,$type,$setValue[$type]);
        }
        $this->adb->pquery($this->NewSetValueSQL,$setValueParams);
        return $homestuffdetailid;
    }

    public function getOldStuffDetailSQL(){
        $this->OldStuffDetailSQL = 'update ld_homestuffdetail set stufflabel_zh=?,stufflabel_en=? where id=?';
    }
    public function getOldSetValueSQL(){
        $this->OldSetValueSQL = 'update ld_homestuffdetail_setting set setvalue=? where homestuffdetailid=? and type=? ';
    }
    public function saveOldStuffDetail($stuffDetailInfo){
        $homestuffdetailid = $stuffDetailInfo['homestuffdetailid'];
        if(!$this->OldStuffDetailSQL)
            $this->getOldStuffDetailSQL();
        $params = [ $stuffDetailInfo['stufflabel_zh'],$stuffDetailInfo['stufflabel_en'],$homestuffdetailid ];
        $this->adb->pquery($this->OldStuffDetailSQL,$params);

        $setValue = $stuffDetailInfo['SetValue'];
        if(!$this->OldSetValueSQL)
            $this->getOldSetValueSQL();
        foreach ($this->setValueColArr as $type){
            $this->adb->pquery($this->OldSetValueSQL,[ $setValue[$type], $homestuffdetailid, $type ]);
        }
        return $homestuffdetailid;
    }


    public function fun_DeleteCustom(){
        $DeleteStuffLabelInfo = json_decode($_REQUEST['DeleteStuffLabelInfo'],true);
        $delete_sql = 'delete from ld_homestuffdetail where `id` = ?';
        $adb = $this->adb;
        $adb->pquery($delete_sql,array($DeleteStuffLabelInfo['homestuffdetailid']));
        ConvertTojsonString(1, '', "success");
    }

}