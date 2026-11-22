<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Products_DetailViewWX extends cls_DetailViewWX
{
    //获取税别信息
    public function getAllTaxes(){
        crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
        if($this->action=='EditView')
        {
            $retrieve_taxes = true;
            $productid = $this->focus->id;
            $tax_details = getAllTaxes('available');
        }
        elseif($_REQUEST['isDuplicate'] == 'true')
        {
            $retrieve_taxes = true;
            $productid = $_REQUEST['record'];
            $tax_details = getTaxDetailsForProduct($productid,'available_associated');
        }
        else
            $tax_details = getAllTaxes('available');
        for($i=0;$i<count($tax_details);$i++){
            $tax_details[$i]['check_name'] = $tax_details[$i]['taxname'].'_check';
            $tax_details[$i]['check_value'] = 0;
        }
        if($retrieve_taxes)
        {
            for($i=0;$i<count($tax_details);$i++)
            {
                $tax_value = getProductTaxPercentage($tax_details[$i]['taxname'],$productid);
                $tax_details[$i]['percentage'] = $tax_value;
                $tax_details[$i]['check_value'] = 1;
                if($tax_value == '')
                {
                    $tax_details[$i]['check_value'] = 0;
                    $tax_details[$i]['percentage'] = getTaxPercentage($tax_details[$i]['taxname']);
                }
            }
        }
        return $tax_details;
    }
    protected function get_DetailView(){
        $jsonArr= parent::get_DetailView();
        $this->jsonArr['tax_info'] = $this->getAllTaxes();
        $this->jsonArr['list'] = $this->setProductCode();
        if (isPermitted($this->module,'accountdatadup')=='yes' &&$this->action =='EditView'){
            $this->jsonArr['list2']['Datadupcheck'] = 'yes';
        }
        return $this->jsonArr;
    }
    protected function get_CreateView()
    {
        parent::get_CreateView();
        $this->jsonArr['tax_info'] = $this->getAllTaxes();
        $this->jsonArr['list'] = $this->setProductCode();
        //查重权限判断，新增界面产品名称旁边有查重功能
        if (isPermitted($this->module,'accountdatadup')=='yes'){
            $list_buttons['Datadupcheck'] = 'yes';
        }
        $this->jsonArr['list2'] = $list_buttons;
        return $this->jsonArr;
    }
    //zxm 2021-0223 0044704: (61mis.com/kfbcrm)产品扫码功能；工具-产品管理-详情；系统参数中“设置移动端是否启用产品扫码功能”为 否；在产品详情页仍显示【产品条形码】的按钮
    protected function setProductCode()
    {
        global $adb;
        $list =  $this->jsonArr['list'];
        $deploy_sql = "select deploy_value from ld_systems_deploy where deploy_type=211";
        $deploy_res = $adb->pquery($deploy_sql);
        $productcode_isopen = $adb->query_result($deploy_res,0,'deploy_value');
        if($_REQUEST['module'] == 'Products'&&$productcode_isopen==1){
            foreach($list as $act_dataIndex=>$v){
                foreach($v['fieldinfo'] as $kk=>$vv)
                {
                    if($vv['fieldname']=='productcode'){
                        unset($list[$act_dataIndex]['fieldinfo'][$kk]);
                        $list[$act_dataIndex]['fieldinfo'] = array_values($list[$act_dataIndex]['fieldinfo']);
                    }
                }
            }
        }
        return $list;
    }
}