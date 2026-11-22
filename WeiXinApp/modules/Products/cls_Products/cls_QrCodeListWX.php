<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class cls_QrCodeListWX extends cls_ListViewWX {
    public function init_custom()
    {
        /*
         * viewname 数据分类
         * SearchScope 查看范围
         * accounttype 是否公海
         * */
        global $customView,$viewid; //查询语句排序需要
        crm_load_class_file('cls_QrCodeCustomView', 'WeiXinApp/modules/Products/cls_Products');
       // $this->setFilterRequest();//
       
      
       
            $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
        
        $this->customview = $customView = new cls_QrCodeCustomView($this->module);
       $_REQUEST['viewid'] = $this->customview->getViewIdByName('All',$this->module);
       $this->viewid = $_REQUEST['viewid'];

        return $customView;
    }
    
    public function addUsersSearchContent($querygenerator,$plateform){
        
        $advft_criteria[]= array(
                                'groupid' => 1,
                                'columnname' => 'ld_products:productcode:productcode:Products_编码条码:V',
                                'comparator' => 'e',
                                'value' => $_REQUEST['searchcontent'],
                                'columncondition' => '',
                            );
                    
                    
        $advft_criteria_groups=array();      
        $advft_criteria_groups[]='null';      
         $advft_criteria_groups[]= array(
                                'groupcondition'=>''
                            );
         $_REQUEST['searchtype']='advance';
         $_REQUEST['advft_criteria']=json_encode($advft_criteria);
         $_REQUEST['advft_criteria_groups']= json_encode($advft_criteria_groups);           
         $querygenerator->addUserSearchConditions($_REQUEST);
         

    }
    
}

?>