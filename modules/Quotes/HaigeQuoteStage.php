<?php
/*海格2.报价单（新建和复制）保存的特殊判断，
报价单类型是“特价报价单”保存的时候需要判断状态必须依次有：准备投标、投标中、最终优化清单（根据特价申请单编号）
*/
//@edit:luyx @date:2021-09-09 @reason: 投标中 更改为 中标后

$quotestage=$_REQUEST['quotestage'];// 报价单状态
$record=$_REQUEST['record'];
$potentialid=$_REQUEST['potentialid'];
$_REQUEST['diony']='yes';
global $adb;
if(!$adb)
{
    exit('error');
}
$tmps=array("0"=>'准备投标',"1"=>'中标后',"2"=>'最终优化清单');
$requestquotestage_index=array_search($quotestage,$tmps);
 if($requestquotestage_index!=2)
{
        ConvertTojsonString("1",array(),'success');
}
$dbquotestage_index=-1;
if($record>0)
{
    $sql='select quote_version,potentialid from ld_quotes where quoteid=?';
    $result=$adb->pquery($sql,array($record));
    $quote_version=$adb->query_result($result,0,'quote_version');
    $potentialid=$adb->query_result($result,0,'potentialid');
    $sql='select quotestage from ld_quotes  where deleted=0 and potentialid=?
    and cast(quote_version as SIGNED INTEGER) <?  and (quotestage=? or quotestage=?) 
     limit 1';
    $result=$adb->pquery($sql,array($potentialid,$quote_version,$tmps[0],$tmps[1]));
    
     if($adb->num_rows($result)>0)
    {
        ConvertTojsonString("1",array(),'success');
    }
    else {
        ConvertTojsonString("-1",array(),'准备投标、中标后必须有一个才能创建最终优化清单');
    }

}
else
{
    $sql='select quotestage from ld_quotes  where deleted=0 and potentialid=? 
     and (quotestage=? or quotestage=?)';
    $result=$adb->pquery($sql,array($potentialid,$tmps[0],$tmps[1]));
    
    if($adb->num_rows($result)>0)
    {
        ConvertTojsonString("1",array(),'success');
    }
    else {
        ConvertTojsonString("-1",array(),'准备投标、中标后必须有一个才能创建最终优化清单');
    }

   
   
}



?>