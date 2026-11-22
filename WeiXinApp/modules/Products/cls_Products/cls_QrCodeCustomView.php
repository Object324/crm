<?php

crm_load_class_file('cls_CustomViewWX', 'WeiXinApp/WeiXin_CustomView');
class cls_QrCodeCustomView extends cls_CustomViewWX{
   
    
  //  public function getColumnsListByCvid($cvid) {
//        
//        return array();
//    }
    function getAdvFilterByCvid($cvid) {
        return array();
    }
    
}

?>