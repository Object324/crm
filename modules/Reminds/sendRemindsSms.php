<?php
//百特的短信扫描提醒  特殊开发
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir=dirname( dirname(dirname(__FILE__)));
 
require_once($root_dir.'/includefile.php');
require_once($root_dir.'/Register/RegOp.php');

global  $adb,$current_user;
if(!$adb)
{
    $adb=PearDatabase::getInstance();
}
$adb=PearDatabase::getInstance();
$current_user->is_admin='on';
$current_user->user_name='系统自动发送';

$date = date('Y-m-d');
//活动邮件提醒只提醒自己
//$query="select t2.templatecode,t2.templateparaminfo,t1.* from ld_smssend t1 LEFT JOIN ld_smstemplates t2 ON t1.templateid=t2.templateid where t1.FDataStatu = 1 limit 0,20; ";
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$where = "";
if ($platform == 'aliyun') {
    $where = " and ifnull(t2.templatecode,'') <> ''";
}
$query="select t2.templatecode,t2.templateparaminfo,t1.* from ld_smssend t1 LEFT JOIN ld_smstemplates t2 ON t1.templateid=t2.templateid where t1.FDataStatu <> 2 $where limit 0,20; ";

$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows>0)
{
    crm_load_class_file('AutoRemindContent', 'include/VarGeneralBol');
    for($i=0;$i<$num_rows;$i++)
    {

        $templateid = $adb->query_result($result,$i,'templateid');
        $BatchNo = $adb->query_result($result,$i,'batchno');
        $templateCode = $adb->query_result($result,$i,'templatecode');//短信模板code
        $templateparaminfo = decode_html($adb->query_result($result,$i,'templateparaminfo'));//短信解析参数
        $CalledNumber = $adb->query_result($result,$i,'callednumber');//接收手机号
        $smstype = $adb->query_result($result,$i,'type');//短信类型 阿里云都不需要这个参数了，老的腾讯短信账户还需要有
        $receivecontent = $adb->query_result($result,$i,'smscontent');//短信内容
        $crmid = $adb->query_result($result,$i,'relatieid');//短信解析参数

        if(empty($CalledNumber) || !preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber))
        {
            //更新状态为2
            $query = 'update ld_smssend set failed_msg = ?,lossreason=?,SubmitTime = ?,FDataStatu = ? where BatchNo = ?';
            $adb->pquery($query,array('接收人手机号错误','',date('Y-m-d H:i:s'),'2',$BatchNo));
            continue;
        }
        $templateParam = '';
        //如果短信变量需要解析
        if (!empty($crmid) && !empty($templateparaminfo) && json_decode($templateparaminfo)!== null) {
            $reltab = getSalesEntityType($crmid);
            $approvenotice = new AutoRemindContent($reltab, $crmid);//变量提醒内容
            $receivecontent = $approvenotice->getContent($receivecontent);//解析短信内容
            $templateParam = $approvenotice->getContent($templateparaminfo);//解析模板变量信息
        }

        $cls_Send_MassSms->smstype = $smstype;
        $cls_Send_MassSms->setInsertSmsLog("no");
        $cls_Send_MassSms->setSmsBatchNo($BatchNo);
        $arr = $cls_Send_MassSms->send($CalledNumber,$receivecontent,$crmid,'',$templateid,$templateParam);

    }


}


if($_GET['intervalsearch']!='yes')
{
    
    //不是每隔5分钟的扫描
    unset($adb);
    unset($current_user); 
}

 
?>
