<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Potentials/ListViewTop.php,v 1.18 2005/04/20 20:24:30 ray Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
/**
 * 首页：销售漏斗
 * @param $reporttype:手机端传入的时间范围参数
 * @return
 * @author Chj
 */

function getPotentials($scope,$senioruserid=0,$reporttype='',$stuffid,$boardid,$boardstuffid){
    global $adb,$default_charset,$current_user;
    require(globalStatic::$root_directory."user_privileges/user_privileges_".$current_user->id.".php");
    //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 10:45
	crm_load_class_file("cls_PickList", 'modules/PickList');
	$objpinklist = new cls_PickList();
	$arrsales_stage = $objpinklist->getPickListValues('sales_stage','',array(),'id');
    $salesstage = array();
    $open_potential_list=array();
	foreach($arrsales_stage as $id=>$value){
		$salesstage[trim($value)]=array('sales_stage_id'=>$id,'sales_stage'=>$value);
		$open_potential_list[trim($value)]=array(
			'POTENTIALCOUNT'=>0,
			'SALESSTAGE'=>$value,
			'SALESSTAGEID'=>$id,
			'AMOUNT'=>0
		);
	}
    $date_serach = getHomeDateScope($reporttype);
    /**新的条件解析 兼容了旧的看板start */
    $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
    $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid,$date_serach,$_REQUEST['approve_value']);
    $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;
    /**新的条件解析 兼容了旧的看板end */
    $query = "select 
ifnull(a.potentialcount,0)as potentialcount,
ld_sales_stage.listvalue as sales_stage,
ifnull(a.amount,0)as amount,
ld_sales_stage.sales_stage_id
from 
( 
	SELECT
		count(1) AS potentialcount,
		sales_stage,
		sum(amount) AS amount
	FROM
		ld_potential ".$datarangesqlArr['datarangesql_Potentials']."
	GROUP BY
		ld_potential.sales_stage
)a 
RIGHT JOIN (
	SELECT
		id sales_stage_id,
		listvalue
	FROM
		ld_picklist_values
	LEFT JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
	WHERE
		listname = 'sales_stage'
	AND relatetable = 'ld_field'
) AS ld_sales_stage ON ld_sales_stage.listvalue = a.sales_stage
ORDER BY
	a.sales_stage";//zxm 20230906 SQL优化  原来的方式雅士空调数据量太多会直接卡住

	/*$tradeInfo = getVersionTradeInfo();
	$accountinfo = $tradeInfo['account'];
	if(!empty($date_serach)){
	    // zxm 2022-6-7 星云时代 1.成功结案，失败结案保持原有逻辑
        //2.初期沟通，需求分析，方案报价。商务谈判，项目暂停不受首页时间条件审批条件控制其他逻辑不变
		$query .=" and (case when '$accountinfo'='xingyunshidai' and find_in_set(ld_potential.sales_stage,'初期沟通,需求分析,方案报价,商务谈判,项目暂停') then 1=1 else ld_potential.createdtime $date_serach end )";
	}*/
    // zxm 2022-6-7 星云时代 1.成功结案，失败结案保持原有逻辑
    //2.初期沟通，需求分析，方案报价。商务谈判，项目暂停不受首页时间条件审批条件控制其他逻辑不变
    /*$query .="  and ld_potential.deleted=0 and (case when '$accountinfo'='xingyunshidai' and find_in_set(ld_potential.sales_stage,'初期沟通,需求分析,方案报价,商务谈判,项目暂停') then 1=1 else $potential_approvestatus end ) group by ld_potential.sales_stage order by ld_potential.sales_stage";*/
    //$query .= " group by ld_potential.sales_stage order by ld_potential.sales_stage";
    $result=$adb->query($query);
    $num_rows=$adb->num_rows($result);   
    $j=0;
    $i=0;
   
    while($i<$num_rows)
    {
        if(array_key_exists(trim($adb->query_result($result,$i,'sales_stage')),$salesstage))
        {
            $open_potential_list[trim($adb->query_result($result,$i,'sales_stage'))]['POTENTIALCOUNT']=$adb->query_result($result,$i,'potentialcount');
            $open_potential_list[trim($adb->query_result($result,$i,'sales_stage'))]['SALESSTAGEID']=$adb->query_result($result,$i,'sales_stage_id');
			$open_potential_list[trim($adb->query_result($result,$i,'sales_stage'))]['AMOUNT']=$adb->query_result($result,$i,'amount');
        }
        $i++;
    }
    //wyt_220706_XUQIU1000477_销售机会漏斗表 旁边显示各阶段的百分占比
    $totalcount=0;
    foreach($open_potential_list as $list){
        $value=array();
        $value[]=$list['POTENTIALCOUNT'];
        $value[]=$list['SALESSTAGE'];
        $value[]=$list['SALESSTAGEID'];
        $value[]=$scopes;
		$value[]=$list['AMOUNT'];
        $totalcount +=$list['POTENTIALCOUNT'];
        $value[]=$totalcount;
        $entries[]=$value;
    }
    $values=Array('ModuleName'=>'Potentials','Entries'=>$entries,'totalcount'=>$totalcount);
    return $values;
}
