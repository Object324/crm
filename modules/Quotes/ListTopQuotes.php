<?php
/**
 * @param $calCnt
 * @param $scope
 * @param $senioruserid
 * @param $stuffid
 * @param $boardid
 * @param $boardstuffid
 * @return array|int|mixed|string|string[]|void|null
 * @throws Exception
 * 最新报价单
 */
function getTopQuotes($calCnt,$scope,$senioruserid=0,$stuffid,$boardid,$boardstuffid,$search_date)
{
	global $adb,$default_charset;
    $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];    
    }
    $date_serach = getHomeDateScope($search_date);
    /**新的条件解析 兼容了旧的看板start */
    $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
    $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid,$date_serach,$_REQUEST['approve_value']);
    $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;
    $timefieldname = $DataRangeHomeboardObj->filterArr['timecomponent_Quotes']['filtersfield'];
    /**新的条件解析 兼容了旧的看板end */

    crm_load_class_file("Quotes","modules/Quotes");
    $focus = new Quotes();

    $query='SELECT distinct ld_quotes.quoteid,'. $focus->list_link_field.' , ld_quotes.accountid,ld_quotes.total,
     ld_quotes.currency_symbol FROM ld_quotes 
     LEFT JOIN ld_tabshare ON (ld_tabshare.crmid = ld_quotes.quoteid)
     '.$datarangesqlArr['datarangesql_Quotes'].' WHERE IFNULL(quotestage,"") <>\''.constant('D_A_S_REJECTED').'\' AND ld_quotes.quoteid > 0';
    $query .=" order by $timefieldname desc";
	$query .= " LIMIT 10";
    $contacts_field_obj=Field::getInstance('Quotes',$adb);
	$fieldlabels=$contacts_field_obj->getFieldLables();
    
    $header[]='<span title="'.$fieldlabels['quote_no'].'">' .$fieldlabels['quote_no'] . '</span>';
    $header[]='<span title="'.$fieldlabels['hdnGrandTotal'].'">' .$fieldlabels['hdnGrandTotal'] . '</span>';
    $header[]='<span title="'.$fieldlabels['account_id'].'">' .$fieldlabels['account_id'] . '</span>';

	if($calCnt == 'calculateCnt') {
		$list_result_rows = $adb->query(mkCountQuery($query));
		return $adb->query_result($list_result_rows, 0, 'count');
	}
	$list_result = $adb->query($query);
	$noofrows = $adb->num_rows($list_result);
    for($i=0;$i<$adb->num_rows($list_result);$i++)
    {
        $quoteid = $adb->query_result($list_result,$i,'quoteid');
        $accountid = $adb->query_result($list_result,$i,'accountid');
        //chj 2021/3/9 44873: （https://61mis.com/kfbcrm [^]）（大平恒）首页报表（最新报价单 ；最新合同订单；最新销售发票 ）这几个报表的客户名称如果过长的话，会显示在报表的边框外面，麻烦将这个多余的部分做一个隐藏（最新销售机会后台返回做了截取）
        $accountname = getModuleHref('Accounts',$adb->query_result($list_result,$i,'accountid'));
        $accountname = (mb_strlen($accountname,'utf-8') > 18) ? (mb_substr($accountname,0,18,$default_charset).'...') : $accountname;
        $no='<a href="javascript:;" referencemodule="Quotes" referencerecord="'.$quoteid.'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$adb->query_result($list_result,$i,'quote_no').'">'.$adb->query_result($list_result,$i,'quote_no').'</a>';
        $total='<span title="'.$adb->query_result($list_result,$i,'currency_symbol').setNumberFormat($adb->query_result($list_result,$i,'total'),$system_deploy_351).'">' .$adb->query_result($list_result,$i,'currency_symbol').setNumberFormat($adb->query_result($list_result,$i,'total'),$system_deploy_351) . '</span>';
        $accountname='<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$accountid.'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.getModuleHref('Accounts',$adb->query_result($list_result,$i,'accountid')).'">'.$accountname.'</a>';
        $entries[]=array($no,$total,$accountname);
    }
	$values=Array('ParentTab'=>'Sales','ModuleName'=>'Quotes','Title'=>$title,'Header'=>$header,'Entries'=>$entries,'search_qry'=>$search_qry);
	if ( ($noofrows == 0 ) || ($noofrows>0) )
		return $values;
}
?>