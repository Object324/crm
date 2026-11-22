<?php

/**
 * Created by PhpStorm.
 * User: gyqCom0314
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_CashBill_DetailViewWX extends cls_DetailViewWX
{
    protected $productEntry_mode = array('CreateView' => 'create', 'DetailView' => 'details', 'EditView' => 'edit');
    protected  $outputProductFieldArr = array('productname','productsheet','sequence_no','quantity','taxprice','tax_amount');
    protected function get_CreateView()
    {
        global $adb;        
         $_REQUEST['cashtype']='cashbill';
        if(isset($_REQUEST['cashbilltype'])){
            $_REQUEST['cashtype']=$_REQUEST['cashbilltype'];
        }
        $this->focus->column_fields['cashtype']=$_REQUEST['cashtype'];
        $this->set_CreateView();
        /* eidtor:gyq_20190319 reason:当前用户源单模块一个模块权限都没有，此时分录只显示一个合计
         * 0036656: （http://183.134.4.6:888/crm [^]）微信小程序>新增打样申请单：显示访问报错。
           参考自PC改过的BUG 33835: 系统设置>模块设置>将合同订单、服务合同、销售发票、回款计划、出库单模块关闭>新增收款单：结果报错了。*/
        $sourcemodules = getSourceModule('CashBill');
        if(empty($sourcemodules[0]['entitytype']))
            $_REQUEST['CashBill_get_CreateView_sourcemodules_empty'] =true;
        
        
        //获取源单类型默认值
        $selectmodule = '';
        foreach($sourcemodules as $ssourcemoduleinfo){
            if($ssourcemoduleinfo['default']==1){
                $selectmodule = $ssourcemoduleinfo['entitytype'];
            }
        }
        if($_REQUEST['cashbilltype'] == 'debuction'){
            $selectmodule = '';
            $_REQUEST['CashBill_get_CreateView_sourcemodules_empty'] =true;
        }
        
        crm_load_class_file('cls_CashBillDetail_PageRecordValueWX', 'WeiXinApp/modules/CashBill/EntityData');
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $id = $relatedInfo['fromid'];
            $selectmodule = $relatedInfo['frommodule'];
            foreach($sourcemodules as $val){
                $sourcearr[] = $val['entitytype'];
            }
            
            if(in_array($selectmodule,$sourcearr)){
                /* duan 20240624 BUG20240621-44 将id读成lineitemid会导致报错,先注释掉
                if($selectmodule=='Invoice'||$selectmodule=='OutboundOrder'){
                    $selectfocus=CRMEntity::getInstance($selectmodule);
                    $detailtable=$selectfocus->Detail_table;
                    $query = "select GROUP_CONCAT(lineitem_id) from $detailtable where id in($id)";
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
                $productdetailObj = new cls_CashBillDetail_PageRecordValueWX($this->module,'sourcemodule_create',$ids,$selectmodule,$currency_info['curid'],$this->actionname);
                //zkt 20230414 BUG0064827 企业微信手机端-回款计划下推收款单-带出计划金额都为0 
                $productdetailObj->productdetailObj->related_create = 'yes';
            }else{
                $productdetailObj = new cls_CashBillDetail_PageRecordValueWX($this->module,'','','','',$this->actionname);
            }
        }else{
            
            if(isset($_REQUEST['sourcemodule_changetype'])&&$_REQUEST['changeheader']=='true')
            {
                //切换源单类型时触发
                $selectmodule=$_REQUEST['sourcemodule_changetype'];
            }
            $productdetailObj = new cls_CashBillDetail_PageRecordValueWX($this->module,'','',$selectmodule,'',$this->actionname);
        }
        $entry = $productdetailObj->set_entrydetail($this->action);
        $this->jsonArr['math'] = $this->getSystemForPoint();
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }

        return $this->jsonArr;
    }

    protected function get_DetailView()
    {
       
        $this->set_DetailView();
        $sourcemodules = getAllSourceModule('CashBill');
        $isSourceModule = $this->focus->getSourceField('entitytype',$this->focus->id);
        $withdetail = 'no';
        foreach($sourcemodules as $sourcemoduleinfo){
            if($sourcemoduleinfo['entitytype']==$isSourceModule&&$sourcemoduleinfo['withdetail']=='yes'){
                $withdetail='yes';
                break;
            }
        }
        //zkt 20240924 BUG20240923-60 云之家手机端收款单-打开GR1201一直加载中（小程序端打开报错）GR1194可以正常打开
        if($this->focus->column_fields['cashtype'] == 'debuction'||(!empty($this->focus->id)&&empty($isSourceModule))){
            $selectmodule = '';
            $_REQUEST['CashBill_get_CreateView_sourcemodules_empty'] =true;
        }
        
        crm_load_class_file('cls_CashBillDetail_PageRecordValueWX','WeiXinApp/modules/CashBill/EntityData');
        $tabdetailObj = new cls_CashBillDetail_PageRecordValueWX($this->module,'edit',$this->record,$isSourceModule,'',$this->actionname);
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
    
        if($this->focus->column_fields['cashtype']=='cashbill'||$this->focus->column_fields['cashtype']=='')
        {
            crm_load_class_file('cls_DebuctionInfo','modules/CashBill');
            $debuctioninfoobj=new cls_DebuctionInfo($this->record,$this->focus);
            $debuction_arr=array();
            $tmp_total_fieldinfo = $this->focus->detailfieldobj->getAllToolFields()['total'];
            $typeofdata_decmail = 2;
            if(count($tmp_total_fieldinfo) > 0){
                for($k = 0;$k<count($tmp_total_fieldinfo);$k++){
                    if($tmp_total_fieldinfo[$k]->getSourceModule() == $isSourceModule){
                        $total_typeofData = $tmp_total_fieldinfo[$k]->getTypeOfData();
                        $typeofdata_decmail = explode(',',$total_typeofData)[1];
                        break;
                    }
                }
            }else{
                $typeofdata_decmail = 2;
            }
            if($this->focus->column_fields['selectlistval']){
                $debuction_arr[]=array('label'=>"小计",'value'=>number_format($this->focus->column_fields['hdnSubTotal'],$typeofdata_decmail));
            }
            else{
                $debuction_arr[]=array('label'=>"本次收款金额",'value'=>number_format($this->focus->column_fields['hdnSubTotal'],$typeofdata_decmail));
            }
             
            $tmparr_debuction=$debuctioninfoobj->getDebuctionListByAccountid();
            
            foreach($tmparr_debuction as $tmpindex=>$debuctioninfo){
                if($debuctioninfo['debuctionid']>0){
                    $debuction_arr[]=array('label'=>"预收".$debuctioninfo['cashbillno'].'本次抵扣金额','value'=>$debuctioninfo['debuctionamount']);
                }
                
            }
            if($_REQUEST['action']=='EditView')
                $outputContentValues['p_total']['total']['value']=$this->focus->column_fields['hdnSubTotal'];
            $outputContentValues['debuctioninfo']=$debuction_arr;
       }
       else
       {
            //预收单的核销日志
            crm_load_class_file("cls_DebuctionInfo",'modules/CashBill');
 
            $totalfieldobj=$this->focus->fieldobj->getFieldInfoobjBykey("columnname",'total');
            $totalamount=0;
            $debuctiontotal= $this->focus->column_fields[$totalfieldobj->getFieldName()];
            $debuctioninfoobj=new cls_DebuctionInfo($this->record,$this->focus);
            $debuction_arr=$debuctioninfoobj->getDebuctionListByDebuctionId();
            $cashbill_nolabel=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",'cashbill_no','fieldlabel');
            $cashbill_datelabel=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",'cashbilldate','fieldlabel');
            
            $ret_debuctioninfo=array();
               foreach($debuction_arr as $index=>$info){
                $cashbillid=$info['cashbillid'];
                
                $totalamount+=$info['amount'];
                $ret_debuctioninfo[$index]['cashbilldate']['k']=$cashbill_datelabel;
                $ret_debuctioninfo[$index]['cashbilldate']['v']=$info['cashbilldate'];
                $ret_debuctioninfo[$index]['cashbill_no']['k']=$cashbill_nolabel;
                $ret_debuctioninfo[$index]['cashbill_no']['v']=$info['cashbill_no'];
                $ret_debuctioninfo[$index]['havaamount']['k']=getFixedLabel('UsedAmount');
                $ret_debuctioninfo[$index]['havaamount']['v']=$info['currecy_symbol']. setNumberFormat($info['amount']);
                $ret_debuctioninfo[$index]['balanceamount']['k']=getFixedLabel('AvailableAmount');
                $ret_debuctioninfo[$index]['balanceamount']['v']=$info['currecy_symbol']. setNumberFormat($debuctiontotal-$totalamount);
                
            }
            $outputContentValues['debuctionlist']=$ret_debuctioninfo;
       }
        
        $this->jsonArr['entry'] = $outputContentValues;
        $this->jsonArr['columnfields_value']=$this->focus->column_fields;
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
?>