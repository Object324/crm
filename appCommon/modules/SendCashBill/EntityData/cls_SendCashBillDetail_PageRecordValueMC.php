<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/22 0022
 * Time: 下午 7:20
 */
crm_load_class_file('cls_SendCashBillDetail_PageRecordValue','modules/SendCashBill/EntityData');
class cls_SendCashBillDetail_PageRecordValueMC 
{
    
    var $record;
    var $sourceIds;
    var $sourceModule;
    var $sourceFocus;
    var $pageType;
    var $subtotal;
    var $sendcashbill_currency_id;
    
    public function __construct($module, $pagemode, $record, $frommodule,$sendcashbill_currency_id=1,$actionname='')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
        $this->module = $module;
         if(empty($frommodule))
            {
                crm_load_class_file('cls_OptionModule','include/OptionModule');
                
               $obj= cls_OptionModule::getInstance($module,$record);
                $frommodule=$obj->getcur_sourceModule();
            }
        $this->sourceModule = $frommodule;
         $this->actionname = $actionname;
        $this->pageType=$pagemode;
        $this->record=$record;
        if($pagemode=='sourcemodule_create')
        {
            $sourceIds = explode(',', $record);
            $sourceIds = array_filter(array_unique($sourceIds));
            $this->sourceIds = implode(',', $sourceIds);
            //$this->pageType='select_source';
            
        }
        $this->createDetailObj($this->sourceModule);
       $this->sendcashbill_currency_id=$sendcashbill_currency_id;
        
    }
    public function createDetailObj($frommodule){
        $withdetail = $this->getSourceWithDetail($frommodule);
        if($_REQUEST['SendCashBill_get_CreateView_sourcemodules_empty']){
            return ;
        }
        if($withdetail == 'yes'){
            crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX', 'WeiXinApp/include/ProductDetailsHtml');
            $this->productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module, $this->pageType, $this->record, $frommodule, $this->actionname);
            $this->productdtailFieldsObj = $this->productdetailObj->ProductDetailsData->productToolFields;
        }
        else{
            
            crm_load_class_file('cls_TabDetail_PageRecordValueWX', 'WeiXinApp/include/TabDetailFields');
            $this->productdetailObj = new cls_TabDetail_PageRecordValueWX($this->module, $this->pageType, $this->record, $frommodule,$this->actionname);
            $this->productdtailFieldsObj = $this->productdetailObj->tabDetailFieldDataobj->TabDetailFields;
        }
    }
    //获取收款单对应源单的withdetail属性（yes:显示产品分录。no：显示非产品分录）
    public function getSourceWithDetail($sourceModule){
        if(empty($sourceModule)){
            return 'no';
        }
        if(!empty($this->SourceModuleWithDetailarr[$sourceModule])){
            return $this->SourceModuleWithDetailarr[$sourceModule];
        }
        //获取收款单对应的源单类型
        $sourceModuleinfoarr=getAllSourceModule($this->module);
        foreach($sourceModuleinfoarr as $tmpindex=>$SourceInfo){
            $tmpSourceModulename = $SourceInfo['entitytype'];
            $this->SourceInfoarr[$tmpSourceModulename] = $SourceInfo;
        }
        $moduleSourceInfo = $this->SourceInfoarr[$sourceModule];
        $this->SourceModuleWithDetailarr[$sourceModule] = $moduleSourceInfo['withdetail'];
        return $this->SourceModuleWithDetailarr[$sourceModule];
    }
    
    public function set_entrydetail($action){
        global $weixin_user;
        if($_REQUEST['SendCashBill_get_CreateView_sourcemodules_empty']){
            //预收单
            return $this->set_entrydetail_nosourcemodule($action);
        }
        
        $withdetail = $this->getSourceWithDetail($this->sourceModule);
        if($withdetail == 'yes'){
            $outputProductValues = $this->productdetailObj->set_entrydetail($action,$outputProductFieldArr,$relatedCreationInfo);
            //获取实际收款金额label
            $totalfieldinfo = $this->productdtailFieldsObj->getFieldInfoobjBykey('columnname','total');
            if(!empty($totalfieldinfo)){
                $totalabel = $totalfieldinfo->getFieldLabel();
                if(!empty($outputProductValues['entry']['p_total']['total'])){
                    $outputProductValues['entry']['p_total']['total']['label'] = $totalabel;
                }
            }
        }
        else{
            if($this->pageType == 'sourcemodule_create'){
                $this->productdetailObj->createTabDetailsDataobj();
                $this->productdetailObj->tabDetailFieldDataobj->setEntityTypeId($this->record);
            }
            $outputProductValues_entry = $this->productdetailObj->set_entrydetail($action);
            $outputProductValues['entry'] = $outputProductValues_entry;
            $cls_DetailView_CommonFun = crm_load_class_obj('cls_DetailView_CommonFun','WeiXinApp/include');
            $outputProductValues['currency']['current']=  $cls_DetailView_CommonFun->getCurrencyMC($this->sourceModule,$this->record,null,'');
            $outputProductValues['currency']['allcurrencies'] = $cls_DetailView_CommonFun->getCurrencyMC(null,null,'all',null);
        
        }
        
        $outputProductValues['entry']['productdetail'] = $withdetail;
        crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
		$this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);
		$fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

		$outputProductValues['entry']['detailfieldruleinfo']=$this->detailfieldruleobj->getFieldRuleProperty();
		$detailfieldrulecolumn=$this->detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
		$outputProductValues['entry']['detailfieldrulefieldnames']=$detailfieldrulecolumn;
        return $outputProductValues;
        
        /*if($weixin_user->environment_weixin){
            $detailshowtype='all';
        }else{
            $detailshowtype='part';
        }
        $tabdetail = $this->getvalues();
        //editor:gyq_20190910 reason:总金额字段已格式化，不需要再处理  2019/9/10 18:38
        $outputProductFieldArr = array('now_sendcashbill_money');
        $outputContentValues = array();
        $detailvalues = array();
        $lastRowValue = array();
        $focus=CRMEntity::getInstance('SendCashBill');
        foreach($tabdetail['lastRowValue'] as $key=>$value){
            //hdnGrandTotal->total
            if(is_null($value['value'])) $value['value']='';
            $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$value['fieldname'],'columnname');
            $lastRowValue[$fieldname]['label'] = $value['fieldlabel'];
            if(in_array($fieldname,$outputProductFieldArr) && $action == 'DetailView'){
                $lastRowValue[$fieldname]['value'] = setNumberFormat($value['value']) ;
            }else{
                $lastRowValue[$fieldname]['value'] = $value['value'];
            }
        }
        
        foreach ($tabdetail['headers'] as $key => $fielddetail) {
            $showfieldslabel[$fielddetail['columnname']] = $fielddetail['fieldlabel'];
        }
        
        if ($action == 'DetailView') {
            foreach ($tabdetail['value'] as $key => $content) {
                if($detailshowtype=='all'){
                    foreach($content as $fieldname=>$mixvalue){
                        if(array_key_exists($fieldname,$showfieldslabel)&&(!empty($mixvalue['value'])||$mixvalue['value']===0||$mixvalue['value']==='0')){
                            //editor:gyq_20190821 reason:金额字段格式化千分位
                            $misvalue_mu = $mixvalue['value'];
                            if(in_array($fieldname,$outputProductFieldArr)){
                                $misvalue_mu =setNumberFormat($mixvalue['value']);
                            }
                            $detailvalues[$key]['list'][] = array('k'=>$showfieldslabel[$fieldname],'v'=>$misvalue_mu);
                        }
                    }
                }else{
                    $detailvalues[$key]['list'][] = $content['tranmodule']['value'] . $content['href_columnname']['value'];
                    $detailvalues[$key]['list'][] = $showfieldslabel['total'].'：'.$content['total']['value'];
                    $detailvalues[$key]['list'][] = $showfieldslabel['now_sendcashbill_money'].'：'.$content['now_sendcashbill_money']['value'];
                    $detailvalues[$key]['entryid'] = $content['detailid'];
                    $detailvalues[$key]['entrytype'] = 'SendCashBill';
                }
            }
            //$outputContentValues['detailshowtype'] = $detailshowtype;
        }else{
            foreach($tabdetail['value'] as $key=>$content){
                foreach($content as $fieldname=>$values){
                    if(is_array($values)){
                        $detailvalues[$key][$fieldname]['value'] = $values['value'];
                        $detailvalues[$key][$fieldname]['hiddenvalue'] = $values['hiddenvalue'];
                    }else{
                        $detailvalues[$key][$fieldname]['value'] = $values;
                        $detailvalues[$key][$fieldname]['hiddenvalue'] = $values;
                    }
                }
            }
            foreach($tabdetail['headers'] as $key=>$fieldcontent){
                $tabdetail['headers'][$key]['text'] = '';
            }
            $outputContentValues['listfield'] = $tabdetail['headers'];//headers中的字段缺少fieldtype
            $cls_DetailView_CommonFun = crm_load_class_obj('cls_DetailView_CommonFun','WeiXinApp/include');
            $outputContentValues['currency']['current']=  $cls_DetailView_CommonFun->getCurrencyMC($this->sourceModule,$_REQUEST['id'],null,'');
            $outputContentValues['currency']['allcurrencies'] = $cls_DetailView_CommonFun->getCurrencyMC(null,null,'all',null);
        }

        if($detailshowtype=='part') $outputContentValues['blocklabel'] = getTranstab($this->module).getFixedLabel('INFORMATION');
        $outputContentValues['list'] = $detailvalues;
        $outputContentValues['p_total'] = $lastRowValue;
        return $outputContentValues;*/
    }
    public function set_entrydetail_nosourcemodule($action){
        $focus = CRMEntity::getInstance($this->module);

        $total = 0;
        if($focus->id>0)
        {
            $total = $focus->column_fields['hdnGrandTotal'];
        }
        $withdetail = '';
        $outputProductValues_entry['list'] = [];
        $outputProductValues_entry['listfield'] = [];
        $outputProductValues_entry['p_total'] = [];
        $outputProductValues_entry['p_total']['total']['label'] = '实际收款金额';
        $outputProductValues_entry['p_total']['total']['value'] = $total;
        $outputProductValues['entry'] = $outputProductValues_entry;
        $cls_DetailView_CommonFun = crm_load_class_obj('cls_DetailView_CommonFun','WeiXinApp/include');
        $outputProductValues['currency']['current']=  $cls_DetailView_CommonFun->getCurrencyMC($this->sourceModule,$this->record,null,'');
        $outputProductValues['currency']['allcurrencies'] = $cls_DetailView_CommonFun->getCurrencyMC(null,null,'all',null);
        $outputProductValues['entry']['productdetail'] = $withdetail;

        $outputProductValues['entry']['detailfieldruleinfo']=array('displaycolumns'=>[],'hidecolumns'=>[],'requiredcolumns'=>[]);
        $outputProductValues['entry']['detailfieldrulefieldnames']=[];

        return $outputProductValues;

    }
}