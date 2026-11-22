<?php
global $adb;
include_once globalStatic::$root_directory.'include/tencentcloud/cls_SendSMSVoice.php';

if(!empty($_REQUEST['jsondata'])){
    $SMSVoicearray = tencentcloud_sms_voice();
    $SendSMSVoiceObj = new SendSMSVoice($SMSVoicearray);
    $jsondata = json_decode($_REQUEST['jsondata']);
    $phones_array = explode(',',$jsondata[0]->receivephone);
    $receivetem = $_REQUEST['receivetem'];//语音模板ID

    if(!empty($phones_array)){
        foreach($phones_array as $phoneNumbers){
            if(empty($phoneNumbers))
            {
                continue;
            }
            $mobile = $SendSMSVoiceObj->getReceiveTel($phoneNumbers);
            $tel = $mobile['tel'];
            $receivename = $mobile['receivename'];
            $batch_no = $SendSMSVoiceObj->insertSmsSendLog($tel,'语音模板ID：'.$receivetem,$receivename);//������־
            $tel = "+86".$tel;
            $SendSMSVoiceObj->send($tel,$receivetem,$batch_no);
        }
    }
    $data['code'] = 1;
    require_once('./include/Zend/Json.php');
    $json = new Zend_Json();
    $jsonentity = $json->encode($data);
    echo $jsonentity;die;
}

