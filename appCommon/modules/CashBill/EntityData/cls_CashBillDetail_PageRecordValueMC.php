<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/22 0022
 * Time: 下午 7:20
 */
class cls_CashBillDetail_PageRecordValueMC 
{
    var $record;
    var $sourceIds;
    var $sourceModule;
    var $sourceFocus;
    var $pageType;
    var $subtotal;
    var $cashbill_currency_id;
    public $module;
    protected $actionname;
    protected $productdetailObj;
    protected $SourceInfoarr;
    protected $SourceModuleWithDetailarr;
    protected $detailfieldruleobj;

    public function __construct($module, $pagemode, $record, $frommodule,$cashbill_currency_id=1,$actionname='')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
        $this->module = $module;
        if(empty($frommodule))
        {
            crm_load_class_file('cls_OptionModule','include/OptionModule');
            $obj= cls_OptionModule::getInstance($module,$record);
            $frommodule=$obj->getcur_sourceModule();
        }
        $this->pageType=$pagemode;
        $this->sourceModule = $frommodule;
        $this->actionname = $actionname;
        $this->createDetailObj($this->sourceModule);
        $this->cashbill_currency_id=$cashbill_currency_id;
    }
    public function createDetailObj($frommodule){
        $withdetail = $this->getSourceWithDetail($frommodule);
        if($_REQUEST['CashBill_get_CreateView_sourcemodules_empty']){
            return ;
        }
        if($withdetail == 'yes'){
            crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX', 'WeiXinApp/include/ProductDetailsHtml');
            $this->productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module, $this->pageType, $this->record, $frommodule,$this->actionname);
        }
        else{
            
            crm_load_class_file('cls_TabDetail_PageRecordValueWX', 'WeiXinApp/include/TabDetailFields');
            $this->productdetailObj = new cls_TabDetail_PageRecordValueWX($this->module, $this->pageType, $this->record, $frommodule,$this->actionname);
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
    
    
    public function set_entrydetail($action,$outputProductFieldArr=null,$relatedCreationInfo=null){
        global $PlatformMC;
        if($_REQUEST['CashBill_get_CreateView_sourcemodules_empty']){
            //预收单
            return $this->set_entrydetail_nosourcemodule($action);
        }
        $withdetail = $this->getSourceWithDetail($this->sourceModule);
        if($withdetail == 'yes'){
            $outputProductValues = $this->productdetailObj->set_entrydetail($action,$outputProductFieldArr,$relatedCreationInfo);
            //获取实际收款金额label
            $totalfieldinfo = $this->productdetailObj->ProductDetailsData->productToolFields->getFieldInfoobjBykey('columnname','total');
            if(!empty($totalfieldinfo)){
                $totalabel = $totalfieldinfo->getFieldLabel();
                if(!empty($outputProductValues['entry']['p_total']['total'])){
                    $outputProductValues['entry']['p_total']['total']['label'] = $totalabel;
                }
            }
            if($action == 'DetailView'){
                $tmpentry_p_total = [];
                foreach($outputProductValues['entry']['p_total'] as $tmpindex=>$tmpinfo){
                    if($tmpinfo['label']=='合计'){
                        if(!empty($totalfieldinfo)){
                            $tmpinfo['label'] = $totalfieldinfo->getFieldLabel();
                        }
                        $tmpentry_p_total[] = $tmpinfo;
                    }
                }
                $outputProductValues['entry']['p_total'] = $tmpentry_p_total;
            }
        }
        else{
            if($this->pageType == 'sourcemodule_create'){
                $this->productdetailObj->createTabDetailsDataobj();
                $this->productdetailObj->tabDetailFieldDataobj->setEntityTypeId($this->record);
            } 
            $outputProductValues_entry = $this->productdetailObj->set_entrydetail($action);
            if(empty($this->sourceModule)){
                $outputProductValues_entry['listfield']=[];
                $outputProductValues_entry['listformulafield']=[];
            }
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
        
        /*
        if($PlatformMC['type']=='weixin'){
            $detailshowtype='all';
        }else{
            $detailshowtype='part';
        }
        
        $outputProductFieldArr = array('total','now_cashbill_money');
        $outputContentValues = array();
        $detailvalues = array();
        * if($_REQUEST['CashBill_get_CreateView_sourcemodules_empty']){
            $tabdetail['lastRowValue'] = $this->getLastRow_Value();            
        }else{
            $tabdetail = $this->getvalues();
        }
        $lastRowValue = array();
        $focus=CRMEntity::getInstance('CashBill');
        //editor:gyq_20190816 reason:PC端是在cls_CashBill_EntityHtml中处理，移动端无法调用 0037811
        foreach($tabdetail['lastRowValue'] as $key=>$value){
            //hdnGrandTotal->total
            if(is_null($value['value'])) $value['value']='';
            $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$value['fieldname'],'columnname');
            $value_two = $value['value'];
            if ($action == 'DetailView') {
                $value_two = setNumberFormat($value['value']);
            }
            $lastRowValue[$fieldname]['label'] = $value['fieldlabel'];
            $lastRowValue[$fieldname]['value'] = $value_two;
        }
        if($_REQUEST['CashBill_get_CreateView_sourcemodules_empty']){
            $outputContentValues['p_total'] = $lastRowValue;
            $outputContentValues['listfield'] = array();
            $outputContentValues['list'] = array();
            return $outputContentValues;
        }
        
        foreach ($tabdetail['headers'] as $key => $fielddetail) {
            $showfieldslabel[$fielddetail['columnname']] = $fielddetail['fieldlabel'];
        }
        //editor:gyq_20190816 reason:PC端是在cls_CashBill_EntityHtml中处理，移动端无法调用 0037811
        //0037811: （51mis.com/kfbcrm）企业微信、微信小程序>灵当CRM>收款单明细界面：本次收款金额和合计字段的今天没有显示千分号。（如图）
        if ($action == 'DetailView') {
            foreach ($tabdetail['value'] as $key => $content) {
                //zxm 2021-0118 【移动端收款单源单增加超链接】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001191
                //$origin_record = $content['href_columnname']['hiddenvalue'];
                //$origin_module = $content['href_columnname']['parentmodule'];
                if($detailshowtype=='all'){
                    foreach($content as $fieldname=>$mixvalue){
                        if(array_key_exists($fieldname,$showfieldslabel)&&(!empty($mixvalue['value'])||$mixvalue['value']===0||$mixvalue['value']==='0')){
                            $mix_value_two = $mixvalue['value'];
                            if($fieldname=='now_cashbill_money'){
                                $mix_value_two = setNumberFormat($mixvalue['value']);
                            }

                            //zxm 2021-0118 【移动端收款单源单增加超链接】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001191
//                            if($fieldname=='href_columnname'){
//                                $detailvalues[$key]['list'][] = array('k'=>$showfieldslabel[$fieldname],'v'=>$mix_value_two,'recode'=>$origin_record,'module'=>$origin_module);
//                            }else{
                                $detailvalues[$key]['list'][] = array('k'=>$showfieldslabel[$fieldname],'v'=>$mix_value_two);
//                            }

                        }

                    }
                }else{
                    $detailvalues[$key]['list'][] = $content['tranmodule']['value'] . $content['href_columnname']['value'];
                    $detailvalues[$key]['list'][] = $showfieldslabel['total'].'：'.$content['total']['value'];
                    $detailvalues[$key]['list'][] = $showfieldslabel['now_cashbill_money'].'：'.$content['now_cashbill_money']['value'];
                    $detailvalues[$key]['entryid'] = $content['detailid'];
                    $detailvalues[$key]['entrytype'] = 'CashBill';
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