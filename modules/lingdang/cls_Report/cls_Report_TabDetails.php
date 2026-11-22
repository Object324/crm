<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('TabDetails','include/TabDetailFields');

class cls_Report_TabDetails extends TabDetails
{
    public static $_instance_tabdetails=array();//单例
    //zxm 20230829 单例
    public static function getInstance($module="",$languagetran="")
    {
        if(isset(self::$_instance_tabdetails[$module])){
            return self::$_instance_tabdetails[$module];
        }
        self::$_instance_tabdetails[$module]=new cls_Report_TabDetails($module,$languagetran);
        return self::$_instance_tabdetails[$module];
    }
}
?>