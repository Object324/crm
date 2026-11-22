<?php
if(!empty($_REQUEST['keywords'])){
    $keywords = $_REQUEST['keywords'];
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $open_type = $_REQUEST['open_type'];
    crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
    $cls_GetTianYanCha = new cls_GetTianYanCha($open_type,$keywords);
    $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['frommodule']);
    if(!$businessinformationobj->IsEnableBusiness()){
        ConvertTojsonString(-1,array(),getFixedLabel('BUSINESSQUERYPARAMETERSNOTENABLED'));
    }
    $cls_GetTianYanCha->setOperationType("businesssearchcompanyid");
    $result = $cls_GetTianYanCha->getCurlResult();
    if(!empty($result)){
        $data['url'] = "https://www.tianyancha.com/company/".$result['id'];
        $_REQUEST['diony']='diony';
        ConvertTojsonString(1,$data,"success");
    }
}
ConvertTojsonString(-1,array(),"success");
?>