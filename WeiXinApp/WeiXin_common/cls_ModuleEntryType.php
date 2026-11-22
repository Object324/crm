<?php
/**
 * 操作人: Diony
 * 日期: 2023/11/17
 * 说明: 判断模块分录类别
 */
class cls_ModuleEntryType
{
    public static function get_module_entry_type($module){
        //判断模块分录类别
        $entry_type = 'no';
        //产品分录
        if(get_file_address($module, 'ProductDetails')){
            $entry_type = 'Products';
        }
        //非产品分录
        if(get_file_address($module, $module."DetailFieldsHtml")){
            $entry_type = 'Details';
            //非产品分录-OA
            $module_oa_arr = ['AddJobBill', 'BusinessApply', 'MinusJobBill', 'CollectionSlip'];
            if(in_array($module, $module_oa_arr)){
                $entry_type = 'OA';
            }
            if(strpos($module,'CustomForm')!==false){
                $tmparr = explode('CustomForm', $module);
                $tmpformindex = (int)$tmparr[1];
                if((21 <= $tmpformindex && $tmpformindex <= 35) || (181 <= $tmpformindex && $tmpformindex <= 200)){
                    $entry_type = 'OA';
                }
            }
        }
        return $entry_type;
    }
}
?>