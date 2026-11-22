<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_Stock_DetailViewWX extends cls_ProductEntry_DetailViewWX
{
    //审核与反审核
    protected function init_detailButton(){
        parent::init_detailButton();
        $module = $this->module;
        $record = $this->record;
        $presence = $this->focus->column_fields['presence'];
        if(empty($presence)) $presence = NOTINSTOCK;
        $sys_approvearr = getSys_Approvedeploy($module);
        $sys_approve = $sys_approvearr['deploy_value'];
        /*if($sys_approve==1){
            $checkout = isPermitted($module,'Checkout',$record);
            $acheckout = isPermitted($module,'ACheckout',$record);
            if(NOTINSTOCK == $presence && 'yes' == $checkout){
				$this->jsonArr['list2'][] = 'checkout';
			}else if(ALLINSTOCK == $presence && 'yes' == $acheckout){
				$this->jsonArr['list2'][] = 'acheckout';
			}
        }*/
    }
}