<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

include_once('vtlib/lingdang/Utils.php');
global $current_user,$adb,$languageType;
global $theme;
$smarty = new lingdangCRM_Smarty;
//头部显示内容
$headerarr = ['functionsetting','backfillingmaprule','businesslog','businessdataanalysis','blacklist'];//'businessdataanalysis',
$nobusinessheaderarr = ['functionsetting','backfillingmaprule','blacklist'];//'businessdataanalysis',

crm_load_class_file('cls_BusinessInformation', 'modules/Users');
$reg = RegOp::getInstance();
$business_insterfacekey_deploy_value = cls_BusinessInformation::getBinsterfacedeployvalue();
$smarty->assign('business_insterfacekey_deploy_value',$business_insterfacekey_deploy_value);
$ret_arr = [];
//zkt 20240828 BUG20240625-28 工商查询功能设置，当前新账套没有工商接口授权的时候，不显示后面的工商日志查询、数据分析
//工商查询功能crm授权，1授权，0未授权
$buinessinterface=$reg->GetbusinessInterfaceStatus();
if($buinessinterface == 1){
    $usage_startdate = $reg->getbusiness_searchlike_startdate();
    $usage_enddata = $reg->getbusiness_searchlike_enddate();
    $todaydatetime = strtotime(date('Y-m-d', time()));//只判断日期
    if($todaydatetime<=strtotime($usage_startdate)||$todaydatetime>=strtotime($usage_enddata)){
        $headerarr = array_diff($headerarr, array('businessdataanalysis'));
    }
}
else{
    $headerarr = array_diff($headerarr, array('businesslog','businessdataanalysis'));
}


$selectpage = $headerarr[0];
if(isset($_REQUEST['selectpage'])&&in_array($_REQUEST['selectpage'],$headerarr)){
    $selectpage = $_REQUEST['selectpage'];
}
//工商设置
if($selectpage == 'functionsetting')
{

    $usage_starttime = $reg->getbusiness_searchlike_startdate();
    $usage_endtime = $reg->getbusiness_searchlike_enddate();
    $businesssearchcount = $reg->getBussinessSearchCount();//每年允许查询数量
    //天眼查工商接口KEY 0:设置 1:未设置
    $business_insterfacekey_arr = getSys_deploy(344);
    $business_insterfacekey_value = cls_BusinessInformation::getBinsterfaceinputvalue();
    if(!empty($business_insterfacekey_value)){
        // 计算需要替换成星号的长度
        $length = mb_strlen($business_insterfacekey_value)-4;
        // 创建一个等长度的星号字符串
        $replacement = str_repeat("*", $length);
        $business_insterfacekey_value  = substr_replace($business_insterfacekey_value, $replacement, 0, $length);
    }
    
    $businessinformation_arr = cls_BusinessInformation::getAllBusinessInformation();
    $fuzzyquerytosearchnum = cls_BusinessInformation::getBusinessfuzzyquerytosearchnum();


    $smarty->assign('business_insterfacekey_value',$business_insterfacekey_value);
    $smarty->assign('business_fuzzyquerytosearchnum',$fuzzyquerytosearchnum);
    $smarty->assign('fuzzyquerytosearchnum_arr',[2,3,4,5,6,7,8,9,10]);
    $smarty->assign('businessinformation_arr',$businessinformation_arr);
    $smarty->assign('usage_starttime',$usage_starttime);
    $smarty->assign('usage_endtime',$usage_endtime);
    $businesssearchcountlabel = $businesssearchcount.getFixedLabel('TIMESPERYEAR');
    $smarty->assign('businesssearchcountlabel',$businesssearchcountlabel);

}
//回填映射规则
else if($selectpage == 'backfillingmaprule')
{
    //选择模块
    // $selectmodulearr = ['Accounts','ServiceCharge','Vendors'];
    $selectmodulearr = cls_BusinessInformation::getBackfillModules();
    $selectmodule = $selectmodulearr[0];
    if(isset($_REQUEST['selectmodule'])&&in_array($_REQUEST['selectmodule'],$selectmodulearr)){
        $selectmodule = $_REQUEST['selectmodule'];
    }
    
    $businessinformationobj = cls_BusinessInformation::getInstance($selectmodule);
    $businessinformationobj->compareBackfillFields();
    $Backfillingmap_arr = $businessinformationobj->getBackFillFields();


    $smarty->assign('selectmodulearr',$selectmodulearr);
    $smarty->assign('selectmodule',$selectmodule);
    $smarty->assign('backfillingmap_arr',$Backfillingmap_arr);
}
//工商日志查询
else if($selectpage == 'businesslog')
{
    //获取查询的时间范围
    $startdate = date('Y-m') . '-01';
    $enddate = date('Y-m-t',time());
    if(isset($_REQUEST['startdate'])){
        $startdate = $_REQUEST['startdate'];
    }
    if(isset($_REQUEST['enddate'])){
        $enddate = $_REQUEST['enddate'];
    }
    $businessloglistarr = cls_BusinessInformation::getBusinesslogBydate($startdate,$enddate);
    $businessloglistheader_arr = [];
    $headerkeyarr = [];
    foreach($businessloglistarr['headtitle'] as $tmpindex=>$tmpheaderinfo){
        $headerkeyarr[] = $tmpheaderinfo['key'];
        $businessloglistheader_arr[] = $tmpheaderinfo['fieldlabel'];
    }
    //套餐到期日
    $usage_endtime = $reg->getbusiness_searchlike_enddate();
    $smarty->assign('headerkeyarr',$headerkeyarr);
    $smarty->assign('businessloglistheader_arr',$businessloglistheader_arr);
    $smarty->assign('businessloglistshow_arr',$businessloglistarr['list']);
    $smarty->assign('startdate',$startdate);
    $smarty->assign('enddate',$enddate);
}
//数据分析
else if($selectpage == 'businessdataanalysis')
{
    //获取查询的时间范围
    $startdate = date('Y-m') . '-01';
    $enddate = date('Y-m-t',time());
    if(isset($_REQUEST['startdate'])){
        $startdate = $_REQUEST['startdate'];
    }
    if(isset($_REQUEST['enddate'])){
        $enddate = $_REQUEST['enddate'];
    }
    if(isset($_REQUEST['selectedoperator'])){
        $selectedoperator = $_REQUEST['selectedoperator'];
    }
    $selectedoperationtype = '';
    if(isset($_REQUEST['selectedoperationtype'])){
        $selectedoperationtype = $_REQUEST['selectedoperationtype'];
    }
    $operatorarr = array();
    $operationtypearr = ['list'=>getFixedLabel('FUZZYSEARCH'),'accuratesearch'=>getFixedLabel('ACCURATESEARCH'),'backfill'=>getFixedLabel('BatchBackFilling')];

    $businessloglistarr = cls_BusinessInformation::getBusinesslogdataanalysis($startdate,$enddate);
    $headerkeyarr = [];
    foreach($businessloglistarr['headtitle'] as $tmpindex=>$tmpheaderinfo){
        $headerkeyarr[] = $tmpheaderinfo['key'];
        $businessloglistheader_arr[] = $tmpheaderinfo['fieldlabel'];
    }
    $businessloglistarr = $businessloglistarr['list'];
    //按日显示对应数据
    $businessbusinessdataanalysis_arr = array();
    $businesslogarr = [];
    $searchcounttotal = 0;
    $searchvalidcounttotal = 0;
    foreach($businessloglistarr as $businessloginfo){
        $storttime = strtotime($businessloginfo['searchtime']);
        $logdate = date("Y-m-d",$storttime);

        //操作人
        $userid = $businessloginfo['userid'];
        $user_name= '';
        if(!empty($userid)){
            $user_name = getUserFullName($userid);
        }
        if(!empty($userid)){
            $operatorarr[$userid] = $user_name;
        }
        //zkt 20240522 BUG20240521-48  后台设置->工商信息设置->数据分析界面，操作人显示空（客户账套需要查看下原因，通用账套，离职成员删除后会出现这个问题）。预期结果：操作人仍显示可查询记录
        if(!empty($selectedoperationtype)&&$businessloginfo['operationtype']!=$selectedoperationtype){
            continue;
        }
        if(!empty($selectedoperator)&&$userid!=$selectedoperator){
            continue;
        }
        //日期
        $searchdate = $logdate;
        //查询量
        $searchcount = 1;
        //有效查询量
        $searchvalidcount = 0;
        if($businessloginfo['searchvalidcount']){
            $searchvalidcount = 1;
        }
        $searchcounttotal += $searchcount;
        $searchvalidcounttotal += $searchvalidcount;
        if(isset($businesslogarr[$logdate])){
            $searchcount+=$businesslogarr[$logdate]['searchcount'];
            $searchvalidcount+=$businesslogarr[$logdate]['searchvalidcount'];
        }
        $businesslogarr[$logdate] = array(
            'searchcount'=>$searchcount,
            'searchvalidcount'=>$searchvalidcount,
            'logdate'=>$logdate
        );
    }
    $businesslogarr_new = [];
    foreach ($businesslogarr as $tmpdate=>$tmploginfo){
        $tmpinfo = [];
        foreach ($headerkeyarr as $tmpkey){
            $tmpinfo[$tmpkey] = $tmploginfo[$tmpkey];
        }
        $businesslogarr_new[] = $tmpinfo;
    }
    $xlinedata = [];
    $ylinedata0 = [];
    $ylinedata1 = [];
    $chartbusinesslogarr= array_reverse($businesslogarr);
    foreach($chartbusinesslogarr as $xdata=>$ydatainfo){
        $xlinedata[] = $xdata;
        $ylinedata0[] = $ydatainfo['searchvalidcount'];
        $ylinedata1[] = $ydatainfo['searchcount'];
    }
    $smarty->assign('searchcounttotal',$searchcounttotal);
    $smarty->assign('searchvalidcounttotal',$searchvalidcounttotal);
    $smarty->assign('operatorarr',$operatorarr);
    $smarty->assign('operationtypearr',$operationtypearr);
    $smarty->assign('selectedoperator',$selectedoperator);
    $smarty->assign('selectedoperationtype',$selectedoperationtype);
    $smarty->assign('headerkeyarr',$headerkeyarr);
    $smarty->assign('businessloglistheader_arr',$businessloglistheader_arr);
    $smarty->assign('businesslogarr',$businesslogarr_new);
    $smarty->assign('startdate',$startdate);
    $smarty->assign('enddate',$enddate);

    //折线图数据
    $ret_arr['optiontitle'] = getFixedLabel('BUSINESSINTERFACEUSAGECHART');
    $ret_arr['charlinedata'] = [getFixedLabel('BILLINGFREQUENCY'),getFixedLabel('ADJUSTMENTAMOUNT')];
    $ret_arr['xlinedata'] = $xlinedata;
    $ret_arr['ylinedata0'] = $ylinedata0;
    $ret_arr['ylinedata1'] = $ylinedata1;

}
//黑名单
else if($selectpage == 'blacklist')
{

    $starpage = 1;
    if(isset($_REQUEST['pagenum'])&&!empty($_REQUEST['pagenum'])){
        $starpage = $_REQUEST['pagenum'];
    }
    $searchwords = '';
    if(isset($_REQUEST['searchwords'])){
        $searchwords = $_REQUEST['searchwords'];
    }
    //每页条数
    $per_page_new = 500;
    $limit_start_rec = ($starpage-1) * $per_page_new;
    $blackwordlistkey_arr = [];
    $blackwordlistkey_arr = cls_BusinessInformation::getBlackKeylist($limit_start_rec,$per_page_new,$searchwords);
    $smarty->assign('blackwordlistkey_arr',$blackwordlistkey_arr);
    //获取总数量
    $query = "select count(*) from ld_business_wordslist where wordtype='blackkey'";
    if(!empty($searchwords)){
        $query .= "  and wordkey like '%$searchwords%' ";
    }
    $result = $adb->pquery($query,array());
    $rows = $adb->num_rows($result);
    $noofrows = 0;
    if($rows>0){
        $noofrows = $adb->query_result($result,0,0);
    }
    $smarty->assign('searchwords',$searchwords);
    $smarty->assign('LISTVIEWRECORDCOUNT',$noofrows);
    $smarty->assign('STARTPAGE',$starpage);
    $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$per_page_new));


}

$ret_arr['selectpage'] = $selectpage;
$ret_arr['headerarr'] = $headerarr;
$ret_arr['nobusinessheaderarr'] = $nobusinessheaderarr;
$ret_arr['business_insterfacekey_deploy_value'] = $business_insterfacekey_deploy_value;

$smarty->assign('selectpage',$selectpage);
$smarty->assign('headerarrjson',json_encode($headerarr));
$smarty->assign('nobusinessheaderarrjson',json_encode($nobusinessheaderarr));
if($_REQUEST['ajax'] == 'true')
{
    $ret_arr['content']=$smarty->fetch('Settings/BusinessSettings/BusinessInformationEntries.tpl');
}
else
{
    $ret_arr['content']=$smarty->fetch('Settings/BusinessSettings/BusinessInformation.tpl');
}
ConvertTojsonString(1,$ret_arr,'success');
?>