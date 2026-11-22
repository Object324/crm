<?php
crm_load_class_file('Products','modules/Products');
class ShoppingMall extends Products
{
    public $list_fieldname=[];//订货商城列表 显示哪些字段  先写死在这里 后面考虑可能加设置吧
    public $ProductPropertyIsActive='no';//产品属性模块是否激活 yes no
    public function __construct() {
        parent::__construct();

        $version = getVersionInfo();
        if($version['account'] == 'huboshi'){
            //呼博士特殊控制
            $this->list_fieldname = array('productname','product_no','productsheet','imagename');
        }
        else{
            $this->list_fieldname = array('productname','product_no','productsheet','unit_price','imagename');
        }
        //zxm 20241016 产品属性模块授权  不显示产品型号字段 显示属性字段
        if(vtlib_isModuleActive('ProductProperty')){
            $this->ProductPropertyIsActive='yes';
        }

    }
    public function getlist_fieldname(){
        return $this->list_fieldname;
    }

}