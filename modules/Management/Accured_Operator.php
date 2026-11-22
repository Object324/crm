<?php
crm_load_class_file('cls_fund_Instance','include/trade/Jijin');



ob_clean();
ob_flush();
if($_REQUEST['operattype']=='pop')
{
    $accured_pop_obj=cls_fund_Instance::getAccured_Pop_Instance($_REQUEST['module']);
     $_REQUEST['diony']='yes';
    
     $arr=array();
     $arr['content']=$accured_pop_obj->getPop_Content();//弹出层
     $arr['title']="计提-".getTranstab($_REQUEST['module']);
     $arr['oktext']=getFixedLabel("SAVE");
     $arr['canceltext']=getFixedLabel("CANCEL");
     
     ConvertTojsonString(1,$arr,'success');
}
   
else if($_REQUEST['operattype']=='prev_accured_date')//获取上次计提日期
{
    $accured_obj=cls_fund_Instance::getAccured_Computer_Instance('Management',$_REQUEST['productid']);
    echo $accured_obj->getPrev_AccuredDate();
}
else if($_REQUEST['operattype']=='save')//计提保存
{
    $accured_obj=cls_fund_Instance::getAccured_Computer_Instance('Management',$_REQUEST['productid']);
    $accured_obj->Computer();
}
exit();


?>