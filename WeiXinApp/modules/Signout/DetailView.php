<?php
//zkt 20231023 XUQIU1002065 ��¼��ס�����Ż�+SQLע���������XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance('Singin','DetailView');
$details = $mobj->common_getInfo();
echo $details;

?>