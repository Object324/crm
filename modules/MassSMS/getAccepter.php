<?php
/*******************************************
*{*修改编码格式:统一编码：UTF-8*}
**edit:kevin
**date:2013-06-18
**reason:群发短信获取接收人手机
*******************************************/
global $adb,$currentModule;
$viewid=vtlib_purify($_REQUEST['viewname']);

$queryGenerator = new QueryGenerator('Accounts', $current_user);
$queryGenerator->initForCustomViewById($viewid);
$list_query = $queryGenerator->getQuery();//分组查询条件


//联系人手机号码
$conquery="select T1.mobile,T1.lastname,T2.accountid from 
           (select mobile,accountid,lastname from ld_contactdetails left join ld_crmentity on ld_contactdetails.contactid=ld_crmentity.crmid where ld_crmentity.deleted=0 and
            ld_contactdetails.mobile<>''
           ) as T1 left join (".$list_query.") as T2 on T1.accountid=T2.accountid where T1.mobile<>'' and T2.accountid<>''";
     
$conresult=$adb->query($conquery);
for($i=0;$i<$adb->num_rows($conresult);$i++){ 
    $tostr .=$adb->query_result($conresult,$i,'lastname').'<'.$adb->query_result($conresult,$i,'mobile').'>'."\r\n";
}
echo '&#&#&#'.$tostr.'&#&#&#$';
?>