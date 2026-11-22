<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ShoppingMallLogic extends BaseLogic {

    public function getListBasicBtn()
    {
        //parent::getListBasicBtn();//调用父类方法

        $list_buttons = [];
        crm_load_class_file('Shopcart','modules/Products');
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $shopcartobj->check_nums();
            $btn = array();
            $btn['opencart']['label'] = getFixedLabel('SHOPCART');
            $btn['opencart']['permit'] ='yes';
            $btn['opencart']['icon'] = 'icon-cart';
            $btn['opencart']['btnkey'] = 'opencart';
            //列表页购物车上显示购物车记录数目
            $btn['opencart']['num'] = $shopcartobj->cartdetail_num;
            $list_buttons = $btn;
        }
        $this->list_buttons = $list_buttons;
    }
    public function getListMoreBtn() {
        global $current_user;
        //树结构设置
        if(is_admin($current_user)){
            $this->list_buttons['More']['list']['ModuleTreeSettings']['label'] = getFixedLabel('treestruturesettings');
            $this->list_buttons['More']['list']['ModuleTreeSettings']['permit'] = 'yes';
        }
    }
}
?>