<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$record = $_REQUEST['record'];
//判断该产品是否已经有关联的单据
$SQL='select ld_tab.name from ld_producttoolfield
       inner join ld_tab on ld_tab.tabid=ld_producttoolfield.tabid 
       where ld_tab.presence in(0,2) group by ld_tab.name ';
$productdetail_result=$adb->pquery($SQL,array());
for($i=0;$i<$adb->num_rows($productdetail_result);$i++)
{
    //判断该产品是否已经有关联的单据
    $tabname=$adb->query_result($productdetail_result,$i,'name');

    $productforsource = $focus->getProductForSource($record,$tabname);

    if($productforsource['num_rows']>0)
    {
        $entityarray = getEntitynameInfo(getTabid('Products'));
        $tabfieldname = $entityarray['fieldname'];//模块链接字段
        $query = "select $tabfieldname as subject from ld_products where productid = ?";
        $result = $adb->pquery($query,array($record));
        $subject = $adb->query_result($result,0,0);
        $srt = sprintf(getFixedLabel('FAILEDFORORDERISAPPROVINGFORINVEN'),$subject,getFixedLabel('DELETETISHI'));
        ConvertTojsonString('-1',null,$srt);
    }
}
DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'');
ConvertTojsonString('1',null,'');

?>