<?php
global $adb;
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
//腾讯云接口 - 发送短信
if(!empty($_REQUEST['jsondata'])){
	$jsondata = json_decode($_REQUEST['jsondata']);
    $phones_array = explode(',',$jsondata[0]->receivephone);

    if ($platform == 'aliyun') {
        if (isset($_REQUEST['smstemplateid']) && $_REQUEST['smstemplateid']>0) {
            $templateid = $_REQUEST['smstemplateid'];
            $templateparamconf = $_REQUEST['smstemplateparamconf'];

            $sql = "select 1 from ld_smsrelated where relatedtable=? and relatedid=? and scene=?";
            $result = $adb->pquery($sql,array("ld_smstemplates",$templateid,'masssms'));
            if ($adb->num_rows($result) > 0) {
                //群发短信特殊，没有中间关联表，直接关联的短信模板表
                $sql = "update ld_smsrelated set templateparamconf=? where relatedtable=? and relatedid=? and scene=?";

                $adb->pquery($sql,array($templateparamconf,"ld_smstemplates",$templateid,'masssms'));
            }else{
                //写入关联表
                $cls_Send_MassSms->insertSmsRelated("ld_smstemplates", $templateid, '', $templateid, $templateparamconf,'masssms');
            }

            if(!empty($phones_array)){
                foreach($phones_array as $phoneNumbers){
                    if(empty($phoneNumbers))
                    {
                        continue;
                    }
                    $cls_Send_MassSms->send($phoneNumbers,'','','',$templateid,$templateparamconf);

                }
            }
        }
    }else{
        $receivecontent = $jsondata[0]->receivecontent;
        $template_type = $_REQUEST['template_type'];
        if($template_type == 'marketing'){
            $smstype = 1;
        }else{
            $smstype = 0;
        }
        if(!empty($phones_array)){
            foreach($phones_array as $phoneNumbers){
                if(empty($phoneNumbers))
                {
                    continue;
                }
                $cls_Send_MassSms->send($phoneNumbers,$receivecontent,'',$smstype);
            }
        }
    }

	$data['code'] = 1;
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($data);
	echo $jsonentity;die;
}
//重新发送
if(!empty($_REQUEST['resend']) && $_REQUEST['resend'] == 'yes' && !empty($_REQUEST['ids'])){
    $query = 'select CalledNumber,SmsContent,TaskID,ReceiveContacts,templateparam,templateid from ld_smssend ';
    if($_REQUEST['ids'] != 'all'){
        $ids = rtrim($_REQUEST['ids'],',');
        $query .= ' where TaskID in ('.$ids.') and platform=?';//重发仅发送当前后台配置短信厂商的短信
        $result = $adb->pquery($query,array($platform));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            for($i = 0; $i < $num_rows; $i++){
                $CalledNumber = $adb->query_result($result,$i,'callednumber');
                $SmsContent = $adb->query_result($result,$i,'smscontent');
                $ReceiveContacts = $adb->query_result($result,$i,'receivecontacts');
                if($ReceiveContacts != $CalledNumber){
                    $CalledNumber .= '<' . $ReceiveContacts . '>';
                }

                if ($platform == 'aliyun') {
                    $templateid = $adb->query_result($result,$i,'templateid');
                    $templateParam = $adb->query_result($result,$i,'templateparam');
                    $cls_Send_MassSms->send($CalledNumber,'','','',$templateid,$templateParam);
                }else{
                    $cls_Send_MassSms->send($CalledNumber,$SmsContent);
                }
            }
        }
    }


}
?>