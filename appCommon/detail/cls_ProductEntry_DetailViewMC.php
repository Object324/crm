<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/17 0017
 * Time: 下午 4:44
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_ProductEntry_DetailViewMC extends cls_DetailViewWX
{
    protected $productEntry_mode = array('CreateView' => 'create', 'DetailView' => 'details', 'EditView' => 'edit');
    protected  $outputProductFieldArr = array('productname','productsheet','sequence_no','quantity','taxprice','tax_amount');
    protected function get_CreateView()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
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
            
            //duan 20230201 根据pc端代码逻辑(EditView.php 中有传DEPLOY_VALUE_205参数到tpl中,选择销售机会就会带出分录)
            //目前只有（销售合同、服务合同、销售发票、报价单）这四个模块选择了销售机会单据后可以带出分录，后续根据需要再补充  
            /*if($relatedInfo['frommodule'] == 'Potentials'){
                $potentials_entrymodule_arr = array('Invoice','Quotes','SalesOrder','ServiceContracts');
                if(!in_array($this->module,$potentials_entrymodule_arr)){
                    $withdetail = 'no';
                }
            }*/
            
            if($withdetail=='no')
            {
                $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'sourcemodule_create_nodetail',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
            }
            else
                $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'module_create',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
        }else{
            $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'','','',$this->actionname);
        }
        
        $entry = $productdetailObj->set_entrydetail($this->action,'',$relatedInfo);
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }
        $this->jsonArr["relatedproducttoolfield"]=getRelatedProducttoolfield($this->module);
        return $this->jsonArr;
    }
    protected function get_DetailView(){
         
        $this->record = $_REQUEST['record'];
         if($this->record>0){
            //40787: （http://kehu001.com/weixin/kh38567/ [^]）系统设置>参数设置>自动提醒设置：提醒人为“普通用户”，普通用户企业微信手机端点击“消息提醒”可以查看其他成员单据
            if(isPermitted($this->module,'DetailView',$this->record)!='yes'){
                ConvertTojsonString('-1',array(),getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE'));
            }
        }
       
        $this->set_DetailView();
        
        
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        //gyq170614
        //$productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'',$this->record,'Products');
        $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,$this->productEntry_mode[$this->action],$this->record,'Products',$this->actionname);
        //审批结束后编辑字段
        $productdetailObj->setFocusColumn_fields($this->focus->column_fields);
        $entry = $productdetailObj->set_entrydetail($this->action,$this->outputProductFieldArr,null);
       
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }
      
        $this->DetailLastExtra();
        $this->jsonArr["relatedproducttoolfield"]=getRelatedProducttoolfield($this->module);
        $deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
        $noshowdiscontinuedproduct = 'no';
        if($deployarray_82['deploy_value']=='0'){
            $noshowdiscontinuedproduct = 'yes';
        }
        $this->jsonArr['sys']["isCheckDuplicate"]=$noshowdiscontinuedproduct;
        return $this->jsonArr;
    }
}