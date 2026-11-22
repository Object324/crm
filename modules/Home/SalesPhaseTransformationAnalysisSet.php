<?php

global $adb,$current_user,$languageType;
if(!is_admin($current_user)){
    exit('error');
}
$smarty=new lingdangCRM_Smarty();
$stuffid = $_REQUEST['stuffid'];
$boardid = $_REQUEST['boardid'];

//设置页面
if($_REQUEST['mode']=='Set'){
    //获取下拉框值
    require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
    $picklistvalues = getAllPickListValues('sales_stage');

    $selectsql = "select * from ld_homeboard_plate_setting where boardid=? and stuffid=?";
    $selectres = $adb->pquery($selectsql,array($boardid,$stuffid));
    $selectnums = $adb->num_rows($selectres);
    $setlist = [];
    $setlist['successlistvalue'] = '成功结案';//多个则以########分隔
    $setlist['faillistvalue'] = '失败结案';
    $setlist['totalcolumn'] = 'totalxrate';
    $setlist['ratecalculationmethod'] = 'byopportunitycount';//转换率计算方法

    if($selectnums>0){
        for($i=0;$i<$selectnums;$i++){
            $tmptype = $adb->query_result($selectres,$i,'type');
            $tmpsetvalue = $adb->query_result($selectres,$i,'setvalue');
            $setlist[$tmptype] = $tmpsetvalue;
        }
    }
    $tmpfocus = CRMEntity::getInstance('Potentials');
    $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,array(
        'picklistvalues'=>array_values($picklistvalues),
        'setlist'=>$setlist,
        'ByOpportunityCount'=>getFixedLabel('ByOpportunityCount'),
        'ByOpportunityAmount'=>getFixedLabel('ByOpportunityAmount'),
        'totalcolumnname'=>isset($moduleAllPreseneceFields['hdnGrandTotal'])?$moduleAllPreseneceFields['hdnGrandTotal']->fieldLableKey:'合计',//预计合同金额字段名称
        'possibilitycolumnname'=>isset($moduleAllPreseneceFields['possibility'])?$moduleAllPreseneceFields['possibility']->fieldLableKey:'可能性',//可能性字段名称 possibility
        'title'=>getFixedLabel('SalesPhaseTransformationAnalysis').'>'.getFixedLabel('SET')
    ),"success");
}
//保存设置信息
if($_REQUEST['mode']=='Save'){
    $_REQUEST['diony']='diony';
    $setlist = $_REQUEST['setlist'];
    $boardstuffid = $_REQUEST['boardstuffid'];
    if(!empty($setlist)){
        foreach($setlist as $tmptype=>$tmpsetvalue){
            $tmpselectsql = "select 1 from ld_homeboard_plate_setting where boardid=? and stuffid=? and boardstuffid=? and type=?";
            $tmpselectres = $adb->pquery($tmpselectsql,array($boardid,$stuffid,$boardstuffid,$tmptype));
            $tmpselectnums = $adb->num_rows($tmpselectres);

            if($tmpselectnums>0){
                $updatesql = "update ld_homeboard_plate_setting set setvalue=? where boardid=? and stuffid=? and boardstuffid=? and type=?";
                $adb->pquery($updatesql,array($tmpsetvalue,$boardid,$stuffid,$boardstuffid,$tmptype));
            }else if($boardstuffid>0){
                $insertsql = "insert into ld_homeboard_plate_setting (setvalue,boardid,stuffid,boardstuffid,type) values (?,?,?,?,?)";
                $adb->pquery($insertsql,array($tmpsetvalue,$boardid,$stuffid,$boardstuffid,$tmptype));
            }
        }
    }
    ConvertTojsonString(1,array(),"success");
}

?>