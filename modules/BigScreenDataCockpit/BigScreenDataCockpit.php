<?php

class BigScreenDataCockpit
{

    public function initDataArr(){
        crm_load_class_file('EchartSetting','modules/CustomEcharts');
        $this->CockpitData = [];
        $this->SalesAreaData = [
            'area_all' => [
                'pickId' => 'all',
                'label' => '全部',
                'color' => '#AE0D0D',
                'accountArr' => [],
                'salesNum' => 0,
                'provinceArr' => [],
            ],
        ];          //区域数据
        $this->SalesProvinceData = [];      //地图数据，各省份信息
        $this->SalesMapData = [];           //地图数据，用于echarts颜色渲染和获取SalesProvinceData中的索引
        $this->SalesAreaDetailData = [];    //区域详情，按项目类型计算项目签约金额占比，饼图
        $this->SalesProvinceDetailData = [];//省份详情，表格
        $areaField = 'cf_7459';
        $provinceField = 'bill_state';
        $businessTypeField = 'cf_7634';
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $pickListObj = new cls_PickList();
        global $global_picklist_colors;

        crm_load_class_file('lingdang_DependencyPicklist', 'modules/PickList');
        $areaProvinceArr = lingdang_DependencyPicklist::getPickListDependency('Accounts', $areaField, $provinceField)['valuemapping'];

        //区域
        $areaArr = $pickListObj->getPickListValues($areaField,'',array(),'id');
        $this->areaColor = $global_picklist_colors;
        //省份
        $provinceArr = $pickListObj->getPickListValues($provinceField,'',array(),'id');
        //项目类型
        $businessTypeArr = $pickListObj->getPickListValues($businessTypeField,'',array(),'id');
        $businessColor = $global_picklist_colors;
        $this->businessColor = [];
        $allKey = 'area_all';
        foreach ($businessTypeArr as $valueId2 => $pickValue2){
            $businessKey = 'business_'.$valueId2;
            if(!isset($this->SalesAreaDetailData[$allKey]))
                $this->SalesAreaDetailData[$allKey] = [];
            $this->SalesAreaDetailData[$allKey][$businessKey] = [
                'name' => $pickValue2,
                'value' => 0,
            ];
            $this->businessColor[$businessKey] = [
                'label' => $pickValue2,
                'color' => $businessColor[$valueId2],
            ];
        }
        foreach ($provinceArr as $valueId1 => $pickValue1){
            $provinceKey = 'province_'.$valueId1;
            array_push($this->SalesAreaData[$allKey]['provinceArr'],$provinceKey);
            $itemStyle = [  ];
            $this->SalesProvinceData[$allKey][$provinceKey] = [
                'pickId' => $valueId1,
                'label' => $pickValue1,
                'areaKey' => $allKey,
                'accountArr' => [],
                'salesNum' => 0,
            ];
            $this->SalesProvinceDetailData[$allKey][$provinceKey] = [];
            $this->SalesMapData[$allKey][$provinceKey] = [
                'name' => $this->prvinceNameChange($pickValue1),
                'value' => 0,
                'itemStyle' => $itemStyle,
                'provinceKey' => $provinceKey,
                'areaKey' => $allKey,
            ];
        }
        foreach ($areaArr as $valueId => $pickValue){
            $areaProvince = [];
            foreach ($areaProvinceArr as $index => $areaProvinceInfo){
                if($areaProvinceInfo['sourcevalue'] === $pickValue){
                    $areaProvince = $areaProvinceInfo['targetvalues'];
                    unset($areaProvinceArr[$index]);
                    break;
                }
            }
            $areaKey = 'area_'.$valueId;
            $areaColor = $this->areaColor[$valueId];
            $this->SalesAreaData[$areaKey] = [
                'pickId' => $valueId,
                'label' => $pickValue,
                'color' => $areaColor,
                'accountArr' => [], //
                'salesNum' => 0,
                'provinceArr' => [],
            ];
            foreach ($provinceArr as $valueId1 => $pickValue1){
                if(in_array($pickValue1,$areaProvince)){
                    $provinceKey = 'province_'.$valueId1;
                    array_push($this->SalesAreaData[$areaKey]['provinceArr'],$provinceKey);
                    if($pickValue === '其他') {
                        $itemStyle = [];
                    }
                    else {
                        $itemStyle = [ 'areaColor' => $areaColor, ];
                        // 全部区域上色
                        $this->SalesMapData[$allKey][$provinceKey]['itemStyle'] = $itemStyle;
                    }
                    $this->SalesProvinceData[$areaKey][$provinceKey] = [
                        'pickId' => $valueId1,
                        'label' => $pickValue1,
                        'areaKey' => $areaKey,
                        'accountArr' => [],
                        'salesNum' => 0,
                    ];
                    $this->SalesProvinceDetailData[$areaKey][$provinceKey] = [];
                    $this->SalesMapData[$areaKey][$provinceKey] = [
                        'name' => $this->prvinceNameChange($pickValue1),
                        'value' => 0,
                        'itemStyle' => $itemStyle,
                        'provinceKey' => $provinceKey,
                        'areaKey' => $areaKey,
                    ];
                    //edit: xll 2024/04/03 国能龙源，首页驾驶舱，一个省份属于多个区域的问题，显示颜色按照区域颜色显示
                    //unset($provinceArr[$valueId1]);
                }
            }
            foreach ($businessTypeArr as $valueId2 => $pickValue2){
                $businessKey = 'business_'.$valueId2;
                if(!isset($this->SalesAreaDetailData[$areaKey]))
                    $this->SalesAreaDetailData[$areaKey] = [];
                $this->SalesAreaDetailData[$areaKey][$businessKey] = [
                    'name' => $pickValue2,
                    'value' => 0,
                ];
            }
        }


    }

    public function getCockpitData() {
        $this->initDataArr();
        $this->getAllData();
        $themeName = getUsersettingByLabel('BigScreenDataCockpit','','DataCockpitTheme');
        $themeName = empty($themeName) ? 'dark' : $themeName;
        $CockpitData = [
            'salesArea' => $this->getSalesAreaData(),
            'salesMap' => $this->getSalesMapData(),
            'salesProvince' => $this->getSalesProvinceData(),
            'salesAreaDetail' => $this->getSalesAreaDetailData(),
            'salesProvinceDetail' => $this->getSalesProvinceDetailData(),
            'businessColorArr' => $this->getBusinessColorArr(),
            'themeName' => $themeName,
        ];

        ConvertTojsonString(1,$CockpitData,'success');
    }

    public function getAllData() {
        global $adb;
        $sql = "SELECT
                    ld_accountscf.cf_7459 AS area,
                    fieldscf_7459.id AS areaid,
                    ld_account.bill_state AS province,
                    fieldsbill_state.id AS provinceid,
                    ld_account.accountid,
                    ld_account.accountname,
                    ld_accountscf.cf_7636 AS salesnum,
                    ld_customform04scf.cf_7634 AS businesstype,
                    fieldscf_7634.id AS businesstypeid,
                    ifnull(sum(ld_customform04scf.cf_7557),0) AS businesstypeamount
                FROM
                    ld_account
                LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                LEFT JOIN (
                    SELECT
                        ld_picklist_set.listid,
                        ld_picklist_values.listvalue,
                        ld_picklist_values.id
                    FROM
                        ld_picklist_set
                    LEFT JOIN ld_picklist_values ON ld_picklist_set.listid = ld_picklist_values.listid
                    WHERE
                        listname = 'cf_7459'
                ) fieldscf_7459 ON fieldscf_7459.listvalue = ld_accountscf.cf_7459
                LEFT JOIN (
                    SELECT
                        ld_picklist_set.listid,
                        ld_picklist_values.listvalue,
                        ld_picklist_values.id
                    FROM
                        ld_picklist_set
                    LEFT JOIN ld_picklist_values ON ld_picklist_set.listid = ld_picklist_values.listid
                    WHERE
                        listname = 'bill_state'
                ) fieldsbill_state ON fieldsbill_state.listvalue = ld_account.bill_state
                LEFT JOIN ld_customform04 ON ld_customform04.accountid = ld_account.accountid
                LEFT JOIN ld_customform04scf ON ld_customform04scf.customform04id = ld_customform04.customform04id
                LEFT JOIN (
                    SELECT
                        ld_picklist_set.listid,
                        ld_picklist_values.listvalue,
                        ld_picklist_values.id
                    FROM
                        ld_picklist_set
                    LEFT JOIN ld_picklist_values ON ld_picklist_set.listid = ld_picklist_values.listid
                    WHERE
                        listname = 'cf_7634'
                ) fieldscf_7634 ON fieldscf_7634.listvalue = ld_customform04scf.cf_7634
                GROUP BY area,bill_state,accountid,businesstype;";
        $result = $adb->pquery($sql);
        $row = $adb->num_rows($result);
        if($row > 0){
            for ($i = 0; $i < $row; $i ++){
                $rowInfo = $adb->fetch_array($result);
                $accountId = $rowInfo['accountid'];
                $accountName = $rowInfo['accountname'];
                $salesnum = $rowInfo['salesnum'];
                $businesstypeamount = $rowInfo['businesstypeamount'];

                if(!in_array($accountId,$this->SalesAreaData['area_all']['accountArr'])) {
                    array_push($this->SalesAreaData['area_all']['accountArr'],$accountId);
                    $this->SalesAreaData['area_all']['salesNum'] += $salesnum;
                }

                if(!empty($rowInfo['areaid'])) {
                    $areaKey = 'area_' . $rowInfo['areaid'];
                    if(!in_array($accountId,$this->SalesAreaData[$areaKey]['accountArr'])) {
                        //仅计数用
                        array_push($this->SalesAreaData[$areaKey]['accountArr'],$accountId);
                        $this->SalesAreaData[$areaKey]['salesNum'] += $salesnum;
                    }

                    if(!empty($rowInfo['businesstypeid'])) {
                        $businessKey = 'business_' . $rowInfo['businesstypeid'];
                        $this->SalesAreaDetailData[$areaKey][$businessKey]['value'] += $businesstypeamount;
                        $this->SalesAreaDetailData['area_all'][$businessKey]['value'] += $businesstypeamount;
                    }

                    if(!empty($rowInfo['provinceid'])){
                        $provinceKey = 'province_'.$rowInfo['provinceid'];
                        if(!in_array($accountId,$this->SalesProvinceData[$areaKey][$provinceKey]['accountArr'])) {
                            $this->SalesMapData[$areaKey][$provinceKey]['value'] += $salesnum;
                            $this->SalesMapData['area_all'][$provinceKey]['value'] += $salesnum;
                            array_push($this->SalesProvinceData[$areaKey][$provinceKey]['accountArr'],$accountId);
                            array_push($this->SalesProvinceData['area_all'][$provinceKey]['accountArr'],$accountId);
                            $this->SalesProvinceData[$areaKey][$provinceKey]['salesNum'] += $salesnum;
                            $this->SalesProvinceData['area_all'][$provinceKey]['salesNum'] += $salesnum;
                        }

                        if(!isset($this->SalesProvinceDetailData[$areaKey][$provinceKey][$accountId])) {
                            $this->SalesProvinceDetailData[$areaKey][$provinceKey][$accountId] = [
                                'accountName' => $accountName,
                                'salesNum' => 0,
                                'businessType' => [],
                                'amount' => 0,
                            ];
                            $this->SalesProvinceDetailData[$areaKey][$provinceKey][$accountId]['salesNum'] += $salesnum;
                            $this->SalesProvinceDetailData['area_all'][$provinceKey][$accountId] = [
                                'accountName' => $accountName,
                                'salesNum' => 0,
                                'businessType' => [],
                                'amount' => 0,
                            ];
                            $this->SalesProvinceDetailData['area_all'][$provinceKey][$accountId]['salesNum'] += $salesnum;
                        }
                        $this->SalesProvinceDetailData[$areaKey][$provinceKey][$accountId]['amount'] += $businesstypeamount;
                        $this->SalesProvinceDetailData['area_all'][$provinceKey][$accountId]['amount'] += $businesstypeamount;
                        array_push($this->SalesProvinceDetailData[$areaKey][$provinceKey][$accountId]['businessType'],$this->businessColor[$businessKey]['color']);
                        array_push($this->SalesProvinceDetailData['area_all'][$provinceKey][$accountId]['businessType'],$this->businessColor[$businessKey]['color']);
                    }
                }
            }
        }
    }

    public function getSalesAreaData() {

        return $this->SalesAreaData;
    }

    public function getSalesMapData() {

        return $this->SalesMapData;
    }

    public function getSalesProvinceData() {

        return $this->SalesProvinceData;
    }

    public function getSalesAreaDetailData() {

        return $this->SalesAreaDetailData;
    }

    public function getSalesProvinceDetailData() {
        return $this->SalesProvinceDetailData;
    }

    public function getBusinessColorArr(){
        return $this->businessColor;
    }

    public function prvinceNameChange($bill_state) {
        return EchartSetting::prvinceNameChange($bill_state);
    }

    public function setDataCockpitTheme(){
        setUsersettingByLabel('BigScreenDataCockpit','','DataCockpitTheme',$_REQUEST['themeName']);
    }

}

?>