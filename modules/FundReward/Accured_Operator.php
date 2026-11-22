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
      crm_load_class_file('cls_base_reward','include/trade/Jijin/Computer/reward');
      $prev_navinfo=cls_base_reward::getPrev_date_net($_REQUEST['productid'],$_REQUEST['module']);
      
      if(is_array($prev_navinfo))
      {
        $prev_navinfo['code']='1';
      }else
      {
        $prev_navinfo['code']='-1';
      }
      echo json_encode($prev_navinfo);
}
else if($_REQUEST['operattype']=='save')//计提保存
{
    $accured_obj=cls_fund_Instance::getAccured_Computer_Instance('FundReward',$_REQUEST['productid']);
    $accured_obj->Computer();
}
exit();


?>