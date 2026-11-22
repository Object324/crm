<?php
require_once(globalStatic::$root_directory."include/simple_html_dom.php");
require_once(globalStatic::$root_directory."appCommon/appCommon.php");
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';

SqlSearchFilter($_REQUEST);

$stuffid = (String)$_REQUEST['stuffid'];
$stufftype = $_REQUEST['stufftype'];
$defaultArr = [
    '19' => 'FunnelChuantou',           //默认组件的销售漏斗
    '35' => 'SalesKitChuantou',         //默认组件的销售简报
    '65' => 'SalesKitChuantou',         //工程行业的收支报告  数据存储同销售简报
    '40' => 'HomeStuffChuantou40',      //40 特殊 近6个月目标完成情况 目标完成率
    '100' => 'DragonTigerChuantou',     //龙虎榜穿透
    '102' => 'DragonTigerChuantou',     //龙虎榜穿透
    '103' => 'DragonTigerChuantou',     //龙虎榜穿透
    '104' => 'DragonTigerChuantou',     //龙虎榜穿透
    '101' => 'HomeStuffChuantou40',     //目标完成率
    '45' => 'HomeStuffChuantou45',      //45 特殊
    '112' => 'SalesPhaseTransformationAnalysisChuantou',    //默认组件的销售阶段转化分析
    '113' => 'LeadsFunnelChuantou',     //线索漏斗
    '114' => 'TargetAnalysisChuantou',
    '115' => 'TD_PotentialsFunnelChuantou',     //天地 特殊开发 销售漏斗（含目标）
    '116' => 'LeadsFunnelChuantou',
];
if($stufftype === 'defaultstuff'){
    if(isset($defaultArr[$stuffid])){
        $className = $defaultArr[$stuffid];
    }
    //默认组件的销售简报，组件中含多个小组件
    else if(in_array( ((int)$stuffid) ,[2,6,7,33,34,8])){
        $className = 'HomeStuffDetailChuantou';
    }
}
else if($stufftype === 'customreport') {
    //自定义统计图
    $className = 'CustomEchartsChuantou';
}
else if($stufftype=='workBriefReport'){
    $className = 'WorkBriefReportChuantou';
}
if(empty($className)){
    $className = 'HomeStuffChuantou';
}
crm_load_class_file($className,"modules/lingdang/cls_Report");

$obj = new $className();
$obj->setParams($_REQUEST);

$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);


