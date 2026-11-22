<?php
crm_load_class_file('PenetrateToChildChart','modules/lingdang/cls_Report');
class TargetAnalysisChuantou extends PenetrateToChildChart
{
    public $colorArr = [
                'Target' => [ 'color' => '#d6d6d6' , 'opacity' => 0.7],
                'Done' => [ 'color' => '#91cc75' , 'opacity' => 0.7],
            ];
    public $system_deploy_351;
    public $ChildType;
    public $SalesGoalNewObj;
    public $userArr;
    public $recordInfo;
    public $ResDataArr;
    public $optionArr;
    public function __construct(){
        parent::__construct();
    }
    public function getChildChartData(){
        if(!isset($_REQUEST['selectuid']))
            $_REQUEST['selectuid'] = $_REQUEST['selectuserid'];
        $HomeDateArr = getHomeDateArray($this->search_date_custom_value);
        $DateArr = [];
        $DateArr['start'] = $HomeDateArr[0];
        $DateArr['end'] = isset($HomeDateArr[1]) ? $HomeDateArr[1] : $HomeDateArr[0];
        $StuffDetaiInfo = [ 'homestuffdetailid'=>$_REQUEST['homestuffdetailid'] ];
        $targetid = $_REQUEST['targetid'];
        $system_351 = getSys_deploy(351);
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];
        }
        $this->system_deploy_351 = $system_deploy_351;

        crm_load_class_file('TargetAnalysis','modules/Home/HomeBoardNew');
        $TargetAnalysisObj = TargetAnalysis::getInstance($_REQUEST['boardid']);
        $TargetAnalysisObj->setHomeDateArr($DateArr);
        $SetValue = $TargetAnalysisObj->getStuffDetailSetValue($StuffDetaiInfo);
        $TargetDoneData = $TargetAnalysisObj->getTargetDoneDataArr($SetValue,$this->scopeType);
        $SalesGoalInfo = $TargetDoneData['SalesGoalInfo'];
        $SalesGoalLabel = $SalesGoalInfo['label'];
        $targetModule = $SalesGoalInfo['modulename'];
        //$DataType = $_REQUEST['SeriesIndex'];   //目标值 Target 完成值 Done
        //$typeArr = $TargetAnalysisObj->typeArr;
        if($targetModule === 'Users')
            $this->ChildType = ($_REQUEST['ChildChartType'] && !empty($_REQUEST['ChildChartType']) ) ? $_REQUEST['ChildChartType'] : 'Group';//'User';//'Group';
        else {
            $this->ChildType = $targetModule;
        }
        $funName = 'get'.$this->ChildType.'Data';
        //$resData = [];
        $TargetDoneData['Target'] = $TargetDoneData['Target'][$targetModule];
        unset($TargetDoneData['SalesGoalInfo']);

        crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
        $this->SalesGoalNewObj = new SalesGoalNew();
        $this->SalesGoalNewObj->set_cur_module('SalesGoal');
        $this->SalesGoalNewObj->setUnitExist('yes');
        $this->SalesGoalNewObj->setSelectUserIds($_REQUEST['selectuid']);
        $this->userArr = $this->SalesGoalNewObj->getUserInfo($this->scopeType);//获取用户数
        $this->recordInfo = $this->SalesGoalNewObj->GetRecordInfo($SalesGoalInfo,$this->scopeType);
        $this->ResDataArr = [
            'idArr' => [],
            'nameArr' => [],
            'TopData' => [],
            'BottomData' => [],
            'Rate' => [],
            'colorArr' => $this->colorArr,
        ];

        $this->ChildChartData = $this->$funName($TargetDoneData);
        if(getVersionTradeInfo()['account'] === 'tiandi') {
            //冒泡排序
            $arr = &$this->ChildChartData;
            $num = count($arr['Rate']);
            for ($i = $num - 1; $i > 0; $i--) {
                for ($j = 0; $j < $i; $j++) {
                    if ($arr['Rate'][$j] === -1 || ($arr['Rate'][$j + 1] !== -1 && $arr['Rate'][$j] > $arr['Rate'][$j + 1])) {
                        // 交换位置，五个数组全部交换位置
                        foreach (['idArr', 'nameArr', 'TopData', 'BottomData', 'Rate'] as $index) {
                            $temp = $arr[$index][$j];
                            $arr[$index][$j] = $arr[$index][$j + 1];
                            $arr[$index][$j + 1] = $temp;
                        }
                    }
                }
            }
        }

        //标题名： 指标名 -> 仪表盘名 -> 统计图
        $this->popuptitle = $SalesGoalLabel . '->' . $_REQUEST['gaugeName'] . '->' . getFixedLabel('statisticalGraphics');

        $this->scopemodule = 'Home';
    }

    public function getGroupData($TargetDoneData){
        $groupData = $this->ResDataArr;
        $usersGroup = $this->SalesGoalNewObj->getUserGroup($this->userArr,$_REQUEST['targetid']);
        $userDataArr = [];
        foreach ($usersGroup as $groupId => $userList){
            $groupValue = [
                'Target' => 0,
                'Done' => 0,
                'id' => $groupId,
            ];
            $groupname = '';
            foreach ($userList as $index => $userInfo){
                $userid = $userInfo['userid'];
                foreach ($TargetDoneData as $type => $dataArr) {
                    if(!isset($userDataArr[$type][$userid])){
                        $userDataArr[$type][$userid] = 0;
                        if(isset($dataArr[$userid])){
                            foreach($dataArr[$userid] as $tmpMonth => $tmpValue){
                                $userDataArr[$type][$userid] += $tmpValue;
                            }
                        }
                    }
                    $groupValue[$type] += $userDataArr[$type][$userid];
                }
                if($groupname === '')
                    $groupname = $userInfo['groupname'];
            }
            if(getVersionInfo()['account'] === 'tiandi') {
                //edit: xll 2023/01/30 BUG20240115-51 公司名称做简化
                if(strpos($groupname,'营销公司') === false )
                    continue;
                else
                    $groupname = str_replace('营销公司','',$groupname);
            }
            $groupValue['name'] = $groupname;
            $this->TargetDoneDataPush($groupData,$groupValue);
        }
        $this->optionArr = [
            [ 'value' => 'Group', 'label' => getFixedLabel('BYDEPARTMENTS')],
            [ 'value' => 'User', 'label' => getFixedLabel('BYUSER')],
        ];
        return $groupData;
    }

    public function getUserData($TargetDoneData){
        $userData = $this->ResDataArr;
        foreach ($this->userArr as $userid => $userName){
            $userValue = [
                'Target' => 0,
                'Done' => 0,
                'id' => $userid,
                'name' => $userName,
            ];
            foreach ($TargetDoneData as $type => $dataArr) {
                if(isset($dataArr[$userid])){
                    foreach($dataArr[$userid] as $tmpMonth => $tmpValue){
                        $userValue[$type] += $tmpValue;
                    }
                }
            }
            $this->TargetDoneDataPush($userData,$userValue);
        }
        $this->optionArr = [
            [ 'value' => 'Group', 'label' => getFixedLabel('BYDEPARTMENTS')],
            [ 'value' => 'User', 'label' => getFixedLabel('BYUSER')],
        ];
        return $userData;
    }

    public function getAccountsData($TargetDoneData) {
        $data = $this->ResDataArr;
        foreach ($this->recordInfo as $record => $recordName){
            $userValue = [
                'Target' => 0,
                'Done' => 0,
                'id' => $record,
                'name' => $recordName,
            ];
            foreach ($TargetDoneData as $type => $dataArr) {
                if(isset($dataArr[$record])){
                    foreach($dataArr[$record] as $tmpMonth => $tmpValue){
                        $userValue[$type] += $tmpValue;
                    }
                }
            }
            $this->TargetDoneDataPush($data,$userValue);
        }
        $this->optionArr = [
            [ 'value' => 'Accounts', 'label' => getFixedLabel('ByAccount')],
        ];
        return $data;
    }

    public function TargetDoneDataPush(&$ResDataArr,$FromDataArr){
        $TargetValue = $FromDataArr['Target'];
        $DoneValue = $FromDataArr['Done'];
//        if($TargetValue < $DoneValue){
//            $TopName = 'Done';
//            $TopValue = $DoneValue - $TargetValue;
//            $TopColor = $this->colorArr['Done'];
//            $BottomName = 'Target';
//            $BottomValue = $TargetValue;
//            $BottomColor = $this->colorArr['Target'];
//        }
//        else {
//            $TopName = 'Target';
//            $TopValue = $TargetValue - $DoneValue;
//            $TopColor = $this->colorArr['Target'];
//            $BottomName = 'Done';
//            $BottomValue = $DoneValue;
//            $BottomColor = $this->colorArr['Done'];
//        }
        $TopName = 'Done';
        $TopValue = $DoneValue;
        $TopColor = $this->colorArr['Done'];
        $BottomName = 'Target';
        $BottomValue = $TargetValue;
        $BottomColor = $this->colorArr['Target'];
        //edit: xll 2023/01/30 BUG20240115-51 不保留小数位数，单位万
        //$TopValue = $TopValue/10000;        //单位万
        $TopValue = (float)(setNumberFormatEmptySeperator($TopValue,0));
        //$BottomValue = $BottomValue/10000;  //单位万
        $BottomValue = (float)(setNumberFormatEmptySeperator($BottomValue,0));
        array_push($ResDataArr['idArr'],$FromDataArr['id']);
        array_push($ResDataArr['nameArr'],$FromDataArr['name']);
        array_push($ResDataArr['TopData'],[ 'name' => $TopName, 'value' => $TopValue , 'itemStyle' => $TopColor]);
        array_push($ResDataArr['BottomData'],[ 'name' => $BottomName, 'value' => $BottomValue , 'itemStyle' => $BottomColor]);
        $rate = $TopValue === 0.0 ? 0 : ($BottomValue === 0.0 ? -1 : $TopValue / $BottomValue);
        array_push($ResDataArr['Rate'],$rate);
    }

    public function getSearchBtnHtml(){

        $SearchBtnHtml = '<div style="margin: 12px 0 0 15px;">';
        $SearchBtnHtml .= '<select id="SelChildChartType" class="SelChildChartType" style="height: 30px;width: 80px;padding: 0 8px;">';
        foreach ($this->optionArr as &$optionInfo){
            $SearchBtnHtml .= '<option value="'.$optionInfo['value'].'">'.$optionInfo['label'].'</option>';
            if($optionInfo['value'] === $this->ChildType){
                $optionInfo['selected'] = 'yes';
            }
            else{
                $optionInfo['selected'] = 'no';
            }
        }
        $SearchBtnHtml .= '</select>';
        $SearchBtnHtml .= '</div>';
        $this->SearchBtnHtml = $SearchBtnHtml;
    }
}