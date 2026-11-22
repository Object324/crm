<?php

crm_load_class_file('cls_productDetailsHtml','modules/WorkSheet/ProductDetails');
class cls_ServiceContracts_DetailsHtml extends cls_productDetailsHtml{
    
    public function __construct($module){
        parent::__construct($module);
        $this->frommdouleFocus = CRMEntity::getInstance($module); 
        $this->product_columnname_arr = array('productname','product_no','productsheet','servicecontracts_start_date','servicecontracts_end_date');
        $this->ProductDetailsData = crm_load_class_obj('cls_ServiceContracts_DetailsData',"modules/WorkSheet/ProductDetails",array($module));  
        $this->producttype = 'product';
    }
    
    public function create_html($productdetail_mode=''){
        $frommdoulefocus = $this->frommdouleFocus;
        $this->ProductDetailsData->record = $this->record;
        $frommdoulefocus->mode = $productdetail_mode;
        $frommdoulefocus->id = $this->record;
        $table = $this->getspecialDetailsHtml($frommdoulefocus,$productdetail_mode,$this->producttype);
        return $table;
    }
    
    public function checkdisplay(){
        return 'display:block';
    }
       
}
?>