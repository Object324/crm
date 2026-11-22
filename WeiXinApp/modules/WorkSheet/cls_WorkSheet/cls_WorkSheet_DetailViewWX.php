<?php

crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_WorkSheet_DetailViewWX extends cls_ProductEntry_DetailViewWX
{
    public function common_getInfo()
    {
        //跳过单据的查看权限显示领取按钮
        $fromList = $_REQUEST['fromList'];
        if ($fromList == 'yes') {
            $display = isPermitted($this->module, 'DetailView', $_REQUEST['record']);
            if($display == 'no'){
                $this->focus->retrieve_entity_info($_REQUEST['record'], $this->module);
                $button_list2 = array();
                $buttons = array();
                $buttons = $this->focus->getModuleLogic($this->module)->getReceiveButton($buttons);
                foreach($buttons as $key =>$buttoninfo){
                    if($buttoninfo['permit']=='yes'){
                          $button_list2[]= $buttoninfo['btnkey'];
                    }
                }
                $fromListRes['list2'] = $button_list2;
                ConvertTojsonString(1, $fromListRes, 'success');
            }
        }
        parent::common_getInfo();
    }
    
    public function get_DetailView_Extra($focus){
        $this->get_trends_permit();
    }
    
    protected function get_trends_permit()
    {
        global $adb;
        $tabid = getTabid($this->module);
        $sql = "SELECT presence from ld_relatedlists where tabid=? and related_tabid=?";
        $result = $adb ->pquery($sql,array($tabid,-16));
        $numrows = $adb->num_rows($result);
        $tmp_permit = 'no';
        if($numrows >0){
            $presence = $adb->query_result($result,0,'presence');
            if($presence==0) {
                $tmp_permit = 'yes';
            }
        }
        $this->jsonArr['defaultSetting']['trends_permit']=$tmp_permit;
        return ;
    }
    
    public function get_DetailView(){
        parent::get_DetailView();
        $this->getSpecialDetail();
        return  $this->jsonArr;
    }
    
    //工单管理增加报修产品分录
    public function getSpecialDetail(){
        global $adb;
        $module = $this->module;
        $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$module/ProductDetails",array($this->module));
        crm_load_class_file("Detail_Edit_View",'include/utils');
        $this->focus->id = $_REQUEST['record'];
        
        if($this->action == 'DetailView'){
            if($this->focus->id>0){
                $entitytype = Detail_Edit_View::getInventoryField('entitytype',$this->focus->id);
                
                if(!empty($entitytype)){
                    $sourcemodule_ProductDetailsHtml = $ProductDetailsHtml->getDetailobjbyEntitytypeMobile($entitytype);
                    $sourcemodule_ProductDetailsHtml->record = $this->focus->id;
                    $sourcemodule_ProductDetailsHtml->ProductDetailsData->record = $this->focus->id;
                    $detail_list = $sourcemodule_ProductDetailsHtml->getMobileSpecialDetail($this->actionname);
                    $this->jsonArr['entry']['worksheetlist'] = $detail_list;
                }
            }
            
            foreach($this->jsonArr['entry']['list'] as $key=>$value){
                $related_productinfo = $value['related_productinfo'];
                if($related_productinfo['id']>0){
                    $related_productid = $value['related_productinfo']['id'];
                    $sql = 'select productname,product_no from ld_products where productid = ?';
                    $result = $adb->pquery($sql,array($related_productid));
                    $valueinfo['k'] = "原产品名称";
                    $valueinfo['v'] = $adb->query_result($result,0,'productname');
                    $related_productinfo['list'][] = $valueinfo;
                    $valueinfo['k'] = "原产品编号";
                    $valueinfo['v'] = $adb->query_result($result,0,'product_no');
                    $related_productinfo['list'][] = $valueinfo;
                }
                $this->jsonArr['entry']['list'][$key]['related_productinfo'] = $related_productinfo;
            }
        }else{
            if($this->focus->id>0){
                $entitytype = Detail_Edit_View::getInventoryField('entitytype',$this->focus->id);
                if(!empty($entitytype)){
                    crm_load_class_file('cls_WorkSheet_PageRecordValueWX','WeiXinApp/modules/WorkSheet/cls_WorkSheet');
                    
                    $productdetailObj = new cls_WorkSheet_PageRecordValueWX($this->module,'EditView',$this->focus->id,$entitytype,$this->actionname);
                    $entry = $productdetailObj->set_entrydetail($this->action,'',$relatedInfo);
                    foreach($entry as $key=>$val){
                        $this->jsonArr[$key] = $val;
                    }
                }
            }
        }
        
        
    }
    
    protected function get_CreateView()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        crm_load_class_file('cls_WorkSheet_PageRecordValueWX','WeiXinApp/modules/WorkSheet/cls_WorkSheet');
        //edit:can 20210406 45334: （企业微信移动端-kfbcrm）销售管理区块-报价单-详情-相关创建服务合同，界面一直转圈
        crm_load_class_file("cls_OptionModuleWX",'WeiXinApp/include/OptionModule');
        
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $relatedfocus=cls_Instance::get_module_Instance($relatedInfo['frommodule']);
            $relatedfocus->retrieve_entity_info($relatedInfo['fromid'],$relatedInfo['frommodule']);
            $optiontobj= cls_OptionModuleWX::getInstance($this->module,0);
            $moduleoption_arr=$optiontobj->getSourceModule($this->module);
            $withdetail='yes';//是否带出分录，yes:带出分录
            foreach($moduleoption_arr as $moduleoptioninfo)
            {
                if($moduleoptioninfo['entitytype']==$relatedInfo['frommodule'])
                {
                    $withdetail=$moduleoptioninfo['withdetail'];
                    
                    break;
                }
            }
            if($withdetail=='no')
            {
                $productdetailObj = new cls_WorkSheet_PageRecordValueWX($this->module,'sourcemodule_create_nodetail',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
            }
            else
                $productdetailObj = new cls_WorkSheet_PageRecordValueWX($this->module,'module_create',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
        }else{
            $productdetailObj = new cls_WorkSheet_PageRecordValueWX($this->module,'','','',$this->actionname);
        }
        $productdetailObj->producttype = 'product';
        $entry = $productdetailObj->set_entrydetail($this->action,'',$relatedInfo);
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }
        $this->jsonArr["relatedproducttoolfield"]=getRelatedProducttoolfield($this->module);
        return $this->jsonArr;
    }

    public function getApproveStep(){
        if($_REQUEST['get_solution'] == 'yes'){
        }else{
            parent::getApproveStep();
        }
    }
}