<?php

//Eidtor:gyq_64 Reason:下拉框改进 系统设置 > 服务考核设置【特殊处理】  Date:2018/3/14 0014 上午 11:34
crm_load_class_file("cls_PickList",'modules/PickList');
class cls_PickList_ServeicePer extends cls_PickList
{
    //获取城市特殊字段值
    public function getPickListValues_City($rFieldName,$rFieldValue=''){
        global $adb;
        $relatetable = 'ld_field';
        if(!empty($rFieldValue)){
            $sqlQuery1 = "SELECT PV.listvalue,PV.id,ifnull(scores,0) scores_ FROM ld_picklist_values PV LEFT JOIN ld_picklist_set PS ON PV.listid=PS.listid
                    WHERE PS.listname=? AND PS.relatetable=?  AND PV.listvalue IN($rFieldValue) ORDER BY PV.sequence ASC ";
        }else{
            $sqlQuery1 = "SELECT PV.listvalue,PV.id,ifnull(scores,0) scores_ FROM ld_picklist_values PV LEFT JOIN ld_picklist_set PS ON PV.listid=PS.listid
                    WHERE PS.listname=? AND PS.relatetable=?  ORDER BY PV.sequence ASC ";
        }
        $result = $adb->pquery($sqlQuery1,array($rFieldName,$relatetable));
        $count = $adb->num_rows($result);
        $arrResult = array();
        for ($i = 0; $i < $count; $i++) {
            $arrResult[$i]['id'] = $adb->query_result($result, $i, 'id');
            $arrResult[$i]['name'] = $adb->query_result($result, $i, 'listvalue');
            $arrResult[$i]['scores'] = $adb->query_result($result, $i, 'scores_');//绩效基数
        }
        return $arrResult;
    }
    //获取下拉值
    public function getPickListValues($rFieldName,$rObjField,$rLang=array(),$rOutputType=''){
        global $adb;
        $relatetable = 'ld_field';
        $outputtype_serviceper = array('scores','weight');// 服务考核设置
        $sqlQuery1 = 'SELECT listid,parent_listname,parent_relatetable FROM ld_picklist_set WHERE listname=? AND relatetable=? LIMIT 1';
        $result1 = $adb->pquery($sqlQuery1,array($rFieldName,$relatetable));
        $parent_listname = $adb->query_result($result1, 0, 'parent_listname');
        if(!empty($parent_listname)){
            $parent_relatetable = $adb->query_result($result1, 0, 'parent_relatetable');
            $sqlQuery2 = 'SELECT PV.listvalue,PV.id,ifnull(scores,0) scores_,ifnull(weight,0) weight_ FROM ld_picklist_values PV LEFT JOIN ld_picklist_set PS ON PV.listid=PS.listid
                    WHERE PS.listname=? AND PS.relatetable=? ORDER BY PV.sequence ASC ';
            $result = $adb->pquery($sqlQuery2,array($parent_listname,$parent_relatetable));
        }else{
            $sqlQuery3 = 'SELECT listvalue,id,ifnull(scores,0) scores_,ifnull(weight,0) weight_ from ld_picklist_values  WHERE listid=? ORDER BY sequence ASC ';
            $result = $adb->pquery($sqlQuery3,array($adb->query_result($result1, 0, 'listid')));
        }
        $count = $adb->num_rows($result);
        $arrResult = array();
        if(in_array($rOutputType,$outputtype_serviceper)){
            for ($i = 0; $i < $count; $i++) {
                $arrResult[$i]['id'] = $adb->query_result($result, $i, 'id');
                $arrResult[$i]['name'] = $adb->query_result($result, $i, 'listvalue');
                $arrResult[$i]['scores'] = $adb->query_result($result, $i, $rOutputType.'_');//绩效基数
            }
        }
        return $arrResult;
    }
    //保存下拉编辑值
    public function savePickFieldEdit_Ser($rFieldName,$rFieldValue,$rId){
        global $adb;
        //初始化下拉选项顺序
        $sql = "update ld_picklist_values set $rFieldName=? where id=?";
        $adb->pquery($sql,array($rFieldValue,$rId));
    }
}