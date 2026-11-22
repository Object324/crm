<?php

/**
 * 修改统一编码utf-8
 */
/**
*@author:andy
*@data:20141031
*@reason:首页组件获取本周、本月统计 
*@version:V5.8
*/

if(isset($_REQUEST['reporttype']) && $_REQUEST['reporttype'] != '' 
    && isset($_REQUEST['scopeType']) && $_REQUEST['scopeType'] !='')
{
    $selectuid=$_REQUEST['selectuid'];
    $reportarr=getmonthweekrepotdetails($_REQUEST['reporttype'],$_REQUEST['scopeType'],$selectuid);//获取周、月统计数据数组
    $smarty=new lingdangCRM_Smarty;
    $smarty->assign("REPORTTYPE",$_REQUEST['reporttype']);
    
    //客户数开始******************
    $smarty->assign("NOWACCNUM",$reportarr['nowaccnum']);
    $smarty->assign("LASTACCNUM",$reportarr['lastaccnum']);
    //客户数环比
    if($reportarr['lastaccnum'] != 0)
    {
        $Chainaccnum=($reportarr['nowaccnum']-$reportarr['lastaccnum'])/$reportarr['lastaccnum'];
        //$Chainaccnum=setNumberFormat(($reportarr['nowaccnum']-$reportarr['lastaccnum'])/$reportarr['lastaccnum']*100,2).'%';
    }else{
        $Chainaccnum=0;
    }
    $smarty->assign("CHAINACCNUM",$Chainaccnum);
    //客户数end******************
    
    //新增联系记录开始*************
    $smarty->assign("NOWCONTRECORDSNUM",$reportarr['nowcontactrecordsnum']);
    $smarty->assign("LASTCONTRECORDSNUM",$reportarr['lastcontactrecordsnum']);
    //新增联系记录数环比
    if($reportarr['lastcontactrecordsnum'] != 0)
    {
        $Chaincontactrecordsnum=($reportarr['nowcontactrecordsnum']-$reportarr['lastcontactrecordsnum'])/$reportarr['lastcontactrecordsnum'];
        //$Chaincontactrecordsnum=setNumberFormat(($reportarr['nowcontactrecordsnum']-$reportarr['lastcontactrecordsnum'])/$reportarr['lastcontactrecordsnum']*100,2).'%';
    }else{
        $Chaincontactrecordsnum=0;
    }
    $smarty->assign("CHAINCONTACTRECORDSNUM",$Chaincontactrecordsnum);
    //新增联系记录end*************
    
    //签约数量开始********************
    $smarty->assign("SIGNINGNOWNUM",$reportarr['signingnownum']);
    $smarty->assign("SIGNINLASTNUM",$reportarr['signinglastnum']);
    //签约数量环比
    if($reportarr['signinglastnum'] != 0)
    {
        $Chainsigningnum=($reportarr['signingnownum']-$reportarr['signinglastnum'])/$reportarr['signinglastnum'];
        //$Chainsigningnum=setNumberFormat(($reportarr['signingnownum']-$reportarr['signinglastnum'])/$reportarr['signinglastnum']*100,2).'%';
    }else{
        $Chainsigningnum=0;
    }
    $smarty->assign("CHAINSIGNINGNUM",$Chainsigningnum);
    //签约数量end********************
    
    //签约额开始*************************
    $smarty->assign("TOTALNOW",setNumberFormat($reportarr['totalnow'],2));
    $smarty->assign("TOTALLAST",setNumberFormat($reportarr['totallast'],2));
    //签约金额环比
    if($reportarr['totallast'] != 0)
    {
        $Chaintotalnum=($reportarr['totalnow']-$reportarr['totallast'])/$reportarr['totallast'];
        //$Chaintotalnum=setNumberFormat(($reportarr['totalnow']-$reportarr['totallast'])/$reportarr['totallast']*100,2).'%';
    }else{
        $Chaintotalnum=0;
    }
    $smarty->assign("CHAINTOTALNUM",$Chaintotalnum);
    //签约额end*************************
    
    //收款额开始************
    $smarty->assign("CASHBILLNOW",getDecimalTwoVal($reportarr['cashbillnow']));
    $smarty->assign("CASHBILLLAST",setNumberFormat($reportarr['cashbilllast'],2));
    //收款额环比
    if($reportarr['cashbilllast'] != 0)
    {
        $Chaincashbillnum=($reportarr['cashbillnow']-$reportarr['cashbilllast'])/$reportarr['cashbilllast'];
        //$Chaincashbillnum=setNumberFormat(($reportarr['cashbillnow']-$reportarr['cashbilllast'])/$reportarr['cashbilllast']*100,2).'%';
    }else{
        $Chaincashbillnum=0;
    }
    $smarty->assign("CHAINCASHBILLNUM",$Chaincashbillnum);
    //收款额end************
    global $current_user;
    $count=0;
    $width = 100;
    if(vtlib_isModuleActive('OftenUseReport'))
        $smarty->assign("OFTENHREF",'yes');//判断权限，模块是否开启OftenUseReport   
    if(vtlib_isModuleActive('Accounts')){
        $smarty->assign("OFTENACCHREF",'yes');//判断权限，模块是否开启Accounts
        $count++;
    }if(vtlib_isModuleActive('ContactRecords')){         
        $smarty->assign("OFTENCONHREF",'yes');//判断权限，模块是否开启ContactRecords
        $count++;
    }if(vtlib_isModuleActive('SalesOrder')){
        $smarty->assign("OFTENSALHREF",'yes');//判断权限，模块是否开启SalesOrder        
        $count=$count+2;    
    }if(vtlib_isModuleActive('CashBill')){
        $smarty->assign("OFTENCASHREF",'yes');//判断权限，模块是否开启CashBill
        $count++;
    }
    if($count > 0){ 
        $width= floor(100/$count);
    }
    $smarty->assign('WIDTH',$width);
        echo '###gotpl###';
    $deployarray=getSys_deploy(78);
    $smarty->assign('WM_STAT',$deployarray['deploy_value']);
    $smarty->display("Home/Monthweekreport.tpl");
}

/**
*@author:andy
*@data:20141031
*@reason:this function to get the month or week Statistics return an array
*@version:v5.8
*/
function getmonthweekrepotdetails($reporttype,$scopeType,$senioruserid=0)
{
    global $adb,$current_user;
    require("user_privileges/user_privileges_".$current_user->id.".php");
    
    if($reporttype == 'week')
    {
        $date = date("Y-m-d");  //当前日期
        $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
        $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6 
        $d = $w ? $w - $first : 6;  //如果是周日 -6天 
        $nowStart  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days")); //本周开始时间
        $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //本周结束时间
        $lastStart = date('Y-m-d 00:00:00',strtotime("$nowStart - 7 days"));  //上周开始时间
        $lastEnd   = date('Y-m-d 23:59:59',strtotime("$nowStart - 1 days"));  //上周结束时间
    }else if($reporttype == 'lastweek')
    {   $date = date("Y-m-d");  //当前日期
        $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
        $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6 
        $d = $w ? $w - $first : 6;  //如果是周日 -6天     
        $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days")); 
        $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
        $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
        $lastStart = date('Y-m-d 00:00:00',strtotime("$nowStart - 7 days"));  //上上周开始时间
        $lastEnd   = date('Y-m-d 23:59:59',strtotime("$nowStart - 1 days"));  //上上周结束时间
    }else if($reporttype == 'month'){       
        $nowStart  =date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m"),1,date("Y"))); //本月开始时间
        $nowEnd    =date("Y-m-d H:i:s",mktime(23,59,59,date("m"),date("t"),date("Y")));//本月结束时间
        $lastStart =date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m")-1,1,date("Y")));//上月开始时间
        $lastEnd   =date("Y-m-d H:i:s",mktime(23,59,59,date("m") ,0,date("Y")));//上月结束时间
    }else{       
        $nowStart  =date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m")-1,1,date("Y"))); //上月开始时间
        $nowEnd    =date("Y-m-d H:i:s",mktime(23,59,59,date("m") ,0,date("Y")));//上月结束时间
        $lastStart =date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m")-2,1,date("Y")));//上上月开始时间
        $lastEnd   =date("Y-m-d H:i:s",mktime(23,59,59,date("m")-1 ,0,date("Y")));//上上月结束时间
    }
    //echo $nowStart.'='.$nowEnd.'=='.$lastStart.'==='.$lastEnd;
    $reportarr=array();
    
    //新增客户数start*************************************
    //上周、月客户数
    $useridlistacc=getuseridlist($scopeType,'Accounts',$senioruserid);//客户查询范围,获取查询用户id字串
    $sql_accnumlast="SELECT count(accountid) as accnum from ld_account where deleted=0 and createdtime BETWEEN '$lastStart' and '$lastEnd' ".$useridlistacc." AND accountid >0 ORDER BY accountid";
    //echo $sql_accnumlast.'<br>';
    $res_accnumlast=$adb->pquery($sql_accnumlast,array());
    $lastaccnum=$adb->query_result($res_accnumlast,0,'accnum');
    
    //本周、月客户数
    $sql_accnumnow="SELECT count(accountid) as accnum from ld_account where deleted=0 AND createdtime BETWEEN '$nowStart' and '$nowEnd' ".$useridlistacc." AND accountid >0 ORDER BY accountid";
    //echo $sql_accnumnow.'<br>';
    $res_accnumnow=$adb->pquery($sql_accnumnow,array());
    $nowaccnum=$adb->query_result($res_accnumnow,0,'accnum');
    
    $reportarr['lastaccnum']=$lastaccnum;
    $reportarr['nowaccnum'] =$nowaccnum;
    //新增客户end*************************************
    
    //新增联系记录数开始*************
    //上周、上月新增联系记录
    $useridlistcon=getuseridlist($scopeType,'ContactRecords',$senioruserid);//联系记录查询范围，获取查询用户id字串
    $sql_contactsrecordslast="SELECT count(contactrecordID) as contactredordsnum from ld_contactrecords where deleted=0 and createdtime BETWEEN '$lastStart' and '$lastEnd'  ".$useridlistcon." and contactrecordID>0  order by contactrecordID";
    //echo $sql_contactsrecordslast.'<br>';
    $res_contactsrecordslast=$adb->pquery($sql_contactsrecordslast,array());
    $lastcontactredordsnum=$adb->query_result($res_contactsrecordslast,0,'contactredordsnum');
    
    //本周、本月新增联系记录实数
    $sql_contactsrecordsnow="SELECT count(contactrecordID) as contactredordsnum from ld_contactrecords where deleted=0 and createdtime BETWEEN '$nowStart' and '$nowEnd'  ".$useridlistcon." and contactrecordID>0  order by contactrecordID";
    //echo $sql_contactsrecordsnow.'<br>';
    $res_contactsrecordsnow=$adb->pquery($sql_contactsrecordsnow,array());
    $nowcontactredordsnum=$adb->query_result($res_contactsrecordsnow,0,'contactredordsnum');
    
    $reportarr['lastcontactrecordsnum']=$lastcontactredordsnum;
    $reportarr['nowcontactrecordsnum'] =$nowcontactredordsnum;
    //新增联系记录end*************
    
    $useridlistsales=getuseridlist($scopeType,'SalesOrder',$senioruserid);//合同订单查询范围
    $useridlistserves=getuseridlist($scopeType,'ServiceContracts',$senioruserid);//服务合同查询范围
    //签约数量开始********************
    //销售订单last
    $sql_signinglast_salesorder="SELECT count(salesorderid) as signinglast_salesordernum from ld_salesorder where deleted=0 and signed_data BETWEEN '$lastStart' and '$lastEnd' and sostatus<>'已作废' ".$useridlistsales." and salesorderid >0 order by salesorderid";
    //echo $sql_signinglast_salesorder.'<br>';
    $res_signinglast_salesorder=$adb->pquery($sql_signinglast_salesorder,array());
    $signinglast_salesordernum=$adb->query_result($res_signinglast_salesorder,0,'signinglast_salesordernum');
    
    //服务合同last
    $sql_signinglast_servicecontracts="SELECT count(servicecontractsid) as signinglast_servicecontractsnum from ld_servicecontracts where deleted=0 and due_date BETWEEN '$lastStart' and '$lastEnd'  and contract_status<>'已作废' ".$useridlistserves." and servicecontractsid>0 order by servicecontractsid";
    //echo $sql_signinglast_servicecontracts.'<br>';
    $res_signinglast_servicecontracts=$adb->pquery($sql_signinglast_servicecontracts,array());
    $signinglast_servicecontractsnum=$adb->query_result($res_signinglast_servicecontracts,0,'signinglast_servicecontractsnum');
    $signinglastnum=$signinglast_salesordernum+$signinglast_servicecontractsnum;//上周、月签约数
    
    //销售订单now
    $sql_signingnow_salesorder="SELECT count(salesorderid) as signingnow_salesordernum from ld_salesorder where deleted=0 and signed_data BETWEEN '$nowStart' and '$nowEnd'  and sostatus<>'已作废' ".$useridlistsales." and salesorderid >0 order by salesorderid";
    //echo $sql_signingnow_salesorder.'<br>';
    $res_signingnow_salesorder=$adb->pquery($sql_signingnow_salesorder,array());
    $signingnow_salesordernum=$adb->query_result($res_signingnow_salesorder,0,'signingnow_salesordernum');
    
    //服务合同now
    $sql_signingnow_servicecontracts="SELECT count(servicecontractsid) as signingnow_servicecontractsnum from ld_servicecontracts where deleted=0 and due_date BETWEEN '$nowStart' and '$nowEnd'  and contract_status<>'已作废' ".$useridlistserves." and servicecontractsid>0 order by servicecontractsid";
    //echo $sql_signingnow_servicecontracts.'<br>';
    $res_signingnow_servicecontracts=$adb->pquery($sql_signingnow_servicecontracts,array());
    $signingnow_servicecontractsnum=$adb->query_result($res_signingnow_servicecontracts,0,'signingnow_servicecontractsnum');
    $signingnownum=$signingnow_salesordernum+$signingnow_servicecontractsnum;//本周、月签约数
    
    $reportarr['signingnownum'] =$signingnownum;
    $reportarr['signinglastnum'] =$signinglastnum;
    //签约数量end*********************
    
    //签约金额开始************************
    //合同订单金额last
    $sql_totallast_salesorder="SELECT sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as totallast_salesorder from ld_salesorder  where deleted=0 and signed_data BETWEEN '$lastStart' and '$lastEnd'  and sostatus<>'已作废' ".$useridlistsales;
    $res_totallast_salesorder=$adb->pquery($sql_totallast_salesorder,array());
    $totallast_salesorder=$adb->query_result($res_totallast_salesorder,0,'totallast_salesorder');
    //echo $sql_totallast_servicecontracts.'<br>';
    //服务合同金额last
    $sql_totallast_servicecontracts="SELECT sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as totallast_servicecontracts from ld_servicecontracts where deleted=0 and due_date BETWEEN '$lastStart' and '$lastEnd' and contract_status<>'已作废' ".$useridlistserves;
    //echo $sql_totallast_servicecontracts.'<br>';
    $res_totallast_servicecontracts=$adb->pquery($sql_totallast_servicecontracts,array());
    $totallast_servicecontracts=$adb->query_result($res_totallast_servicecontracts,0,'totallast_servicecontracts');
    $totallast=$totallast_salesorder+$totallast_servicecontracts;//上周、月签约额
    
    //合同订单金额now
    $sql_totalnow_salesorder="SELECT sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as totalnow_salesorder from ld_salesorder  where signed_data BETWEEN '$nowStart' and '$nowEnd' and deleted=0 and sostatus<>'已作废' ".$useridlistsales;
    //echo $sql_totalnow_salesorder.'<br>';
    $res_totalnow_salesorder=$adb->pquery($sql_totalnow_salesorder,array());
    $totalnow_salesorder=$adb->query_result($res_totalnow_salesorder,0,'totalnow_salesorder');
    
    //服务合同金额now
    $sql_totalnow_servicecontracts="SELECT sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as totalnow_servicecontracts from ld_servicecontracts where due_date BETWEEN '$nowStart' and '$nowEnd' and  deleted=0 and contract_status<>'已作废' ".$useridlistserves;
    //echo $sql_totalnow_servicecontracts.'<br>';
    $res_totalnow_servicecontracts=$adb->pquery($sql_totalnow_servicecontracts,array());
    $totalnow_servicecontracts=$adb->query_result($res_totalnow_servicecontracts,0,'totalnow_servicecontracts');
    $totalnow=$totalnow_salesorder+$totalnow_servicecontracts;//本周、月签约额
    
    $reportarr['totalnow'] =$totalnow;
    $reportarr['totallast'] =$totallast;
    //签约金额开始************************
    
    //收款金额开始***************
    $useridlistscashbill=getuseridlist($scopeType,'CashBill',$senioruserid);//收款单查询范围
	//已收金额计算时是否统计未审核的收款单
	$focus = CRMEntity::getInstance('CashBill');
	$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
    //上周、月收款金额
    $sql_cashbilllast="SELECT sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as cashbilllasttotal from ld_cashbill where cashbilldate BETWEEN '$lastStart' and '$lastEnd' and  deleted=0 $checkoutstatuswhere ".$useridlistscashbill;
    //echo $sql_cashbilllast.'<br>';
    $res_cashbilllast=$adb->pquery($sql_cashbilllast,array());
    $cashbilllast =$adb->query_result($res_cashbilllast,0,'cashbilllasttotal');
    
    //本周、月收款金额
    $sql_cashbillnow="SELECT ifnull(sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))),0) as cashbillnowtotal from ld_cashbill where cashbilldate BETWEEN '$nowStart' and '$nowEnd' and  deleted=0 $checkoutstatuswhere ".$useridlistscashbill;
    //echo $sql_cashbillnow.'<br>';
    $res_cashbillnow=$adb->pquery($sql_cashbillnow,array());
    $cashbillnow =$adb->query_result($res_cashbillnow,0,'cashbillnowtotal');
    
    $reportarr['cashbillnow'] =$cashbillnow;
    $reportarr['cashbilllast'] =$cashbilllast;
    //收款金额end***************
    
    return $reportarr;
}

/**
*@author:andy
*@data:20141031
*@reason:获取当前查询范围的用户ID字串 返回字串，用户ID字串，无用户自返回0(默认不存在用户)
*@version:v 5.8
*/
function getuseridlist($scopeType,$modulename,$senioruserid=0)
{
    global $current_user,$adb;
    require("user_privileges/user_privileges_".$current_user->id.".php");
    $scopeobj = ScopOfAuthority::getInstance($adb,'Home');
	$SearchUserId = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
	if(!empty($SearchUserId)){
		return ' and '.$SearchUserId;
	}else{
		return '';
	}
}
?>