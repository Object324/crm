<?php

/**
 * Created by PhpStorm.
 * User: gyqCom0314
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');

class cls_SendCashBill_DetailViewWX extends cls_DetailViewWX
{
    protected $productEntry_mode = array('CreateView' => 'create', 'DetailView' => 'details', 'EditView' => 'edit');
    protected  $outputProductFieldArr = array('productname','productsheet','sequence_no','quantity','taxprice','tax_amount');
    protected function get_CreateView()
    {
        global $adb;        
        $this->set_CreateView();
        $sourcemodules = getSourceModule('SendCashBill');
        //获取源单类型默认值
        $selectmodule = '';
        foreach($sourcemodules as $ssourcemoduleinfo){
            if($ssourcemoduleinfo['default']==1){
                $selectmodule = $ssourcemoduleinfo['entitytype'];
            }
        }
        if(empty($selectmodule))
            $_REQUEST['SendCashBill_get_CreateView_sourcemodules_empty'] =true;
        crm_load_class_file('cls_SendCashBillDetail_PageRecordValueWX', 'WeiXinApp/modules/SendCashBill/EntityData');
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $id = $relatedInfo['fromid'];
            $selectmodule = $relatedInfo['frommodule'];
            $sourcemodules = getSourceModule('SendCashBill');
            foreach($sourcemodules as $val){
                $sourcearr[] = $val['entitytype'];
            }
            if(in_array($selectmodule,$sourcearr)){
                /* duan 20240624 BUG20240621-44 将id读成lineitemid会导致报错,先注释掉
                if($selectmodule=='PurchaseInvoice'||$selectmodule=='Stock'){
                    $selectfocus=CRMEntity::getInstance($selectmodule);
                    $query = "select GROUP_CONCAT(lineitem_id) from ".$selectfocus->Detail_table."  where id in($id)";
        			$result = $adb->pquery($query,array());
                    $ids=$adb->query_result($result,0,0);
                }else{
                    $ids = $id;
                }
                */
                $ids = $id;

                $relatedfocus=cls_Instance::get_module_Instance($selectmodule);
                $relatedfocus->retrieve_entity_info($relatedInfo['fromid'],$selectmodule);
                $currency_info = getModuleCurrencyInfo($relatedInfo['fromid'],$selectmodule);
                $productdetailObj = new cls_SendCashBillDetail_PageRecordValueWX($this->module,'sourcemodule_create',$ids,$selectmodule,$currency_info['curid'],$this->action);
                $productdetailObj->productdetailObj->related_create = 'yes';
            }else{
                $productdetailObj = new cls_SendCashBillDetail_PageRecordValueWX($this->module,'','',$selectmodule,'',$this->action);
            }
        }else{
            
            if(isset($_REQUEST['sourcemodule_changetype'])&&$_REQUEST['changeheader']=='true')
            {
                //切换源单类型时触发
                $selectmodule=$_REQUEST['sourcemodule_changetype'];
            }
            $productdetailObj = new cls_SendCashBillDetail_PageRecordValueWX($this->module,'','',$selectmodule,'',$this->action);
        }
        $entry = $productdetailObj->set_entrydetail($this->action);
        /*$tabdetailObj = new cls_CashBillDetail_PageRecordValueWX($this->module, 'edit', $this->record, '');
        $outputContentValues = $tabdetailObj->set_entrydetail($this->action);*/
        $this->jsonArr['math'] = $this->getSystemForPoint();
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }

        return $this->jsonArr;
    }

    protected function get_DetailView()
    {
        $this->set_DetailView();
        $isSourceModule = $this->focus->getSourceField('entitytype',$this->focus->id);
        $sourcemodules = getAllSourceModule('SendCashBill');
        //获取源单类型默认值
        $selectmodule = '';
        foreach($sourcemodules as $ssourcemoduleinfo){
            if($ssourcemoduleinfo['entitytype']==$isSourceModule&&$ssourcemoduleinfo['withdetail']=='yes'){
                $withdetail='yes';
                break;
            }
        }
        if((!empty($this->focus->id)&&empty($isSourceModule))){
            $selectmodule = '';
            $_REQUEST['SendCashBill_get_CreateView_sourcemodules_empty'] =true;
        }
        crm_load_class_file('cls_SendCashBillDetail_PageRecordValueWX', 'WeiXinApp/modules/SendCashBill/EntityData');
        $tabdetailObj = new cls_SendCashBillDetail_PageRecordValueWX($this->module, 'edit', $this->record, $isSourceModule, '',$this->action);
        if($withdetail=='yes'){
            $outputProductValues = $tabdetailObj->set_entrydetail($this->action,$this->outputProductFieldArr,null);
            
        }
        else{
            $outputProductValues = $tabdetailObj->set_entrydetail( $this->action);
        }
        
        $outputContentValues = $outputProductValues['entry'];
        foreach($outputProductValues as $key=>$val){
            $this->jsonArr[$key] = $val;
        }

        if ($this->action == 'EditView') {
            $this->jsonArr['math'] = $this->getSystemForPoint();
        }
        $this->jsonArr['entry'] = $outputContentValues;
        $this->jsonArr['sys']["isCheckDuplicate"] = 'no';
        if($withdetail == 'yes'){
            $deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
            $noshowdiscontinuedproduct = 'no';
            if($deployarray_82['deploy_value']=='0'){
                $noshowdiscontinuedproduct = 'yes';
            }
            $this->jsonArr['sys']["isCheckDuplicate"]=$noshowdiscontinuedproduct;
        }
        $this->DetailLastExtra();
        return $this->jsonArr;
    }
    //审核与反审核
    protected function init_detailButton(){
        parent::init_detailButton();
        $module = $this->module;
        $record = $this->record;
        $checkoutstatus = $this->focus->column_fields['checkoutstatus'];
        $sys_approvearr = getSys_Approvedeploy($module);
        $sys_approve = $sys_approvearr['deploy_value'];
        /*if($sys_approve==1){
            $checkout = isPermitted($module,'Checkout',$record);
            $acheckout = isPermitted($module,'ACheckout',$record);
            if(('未审核' == $checkoutstatus || $checkoutstatus == '') && 'yes' == $checkout){
				$this->jsonArr['list2'][] = 'checkout';
			}else if('已审核' == $checkoutstatus && 'yes' == $acheckout){
				$this->jsonArr['list2'][] = 'acheckout';
			}
        }*/
    }
}