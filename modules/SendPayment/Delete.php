<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;


$url = getBasic_Advance_SearchURL();
if(isset($_REQUEST['record']))
{   
    $record=$_REQUEST['record'];
    /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select sendpaymentid from ld_sendpayment where sendpaymentid in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);
    if($dnum_rows==0)
    $srt = getFixedLabel('Thisrecordisdeleted');

    $checkdeletesql="select sendpaymentid from ld_sendpayment where sendpaymentid in($record) and deleted=0 and
     CPStatus not IN ('已付','部分已付')";
    
    $dresult=$adb->query($checkdeletesql);
    $dnum_rows2=$adb->num_rows($dresult);
    if($dnum_rows2==0)
    $srt = getFixedLabel('PAYMENTRECORDPARITIALLYDELETEFAILED');
    
    
    if($dnum_rows==0||$dnum_rows2==0){
        
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
         $json = new Zend_Json();
         $jsonentity = $json->encode($entity);
	     echo $jsonentity;die;;
    }
    //wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
    $deploy_values=getSys_deploy("69");
    if($deploy_values['deploy_value']==1&&Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
        $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
        $entity['log']['value'] = $srt1;
        $entity['title']['value'] = getFixedLabel('DELETE');
        $json = new Zend_Json();
        $jsonentity = $json->encode($entity);
        echo $jsonentity;die;
    }
     DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);
     $parenttab = getParentTab();
        
}
echo '##YES##';

?>