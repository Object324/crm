<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class CustomForm54Logic extends BaseLogic {
    public function getListMoreBtn() {
        global $current_user;
        parent::getListMoreBtn();//调用父类方法
        $module = self::$module;
        $focus = CRMEntity::getInstance($module);
        if($focus->isShowMap == 'yes' && false){
            $update_addresss = 'no';
            if('yes' == isPermitted($module, 'EditView','')){
                $update_addresss = 'yes';$more_idx = 1;
            }
            $btn = array();
            $btn['Update_addresss']['label'] = getFixedLabel('UpdateAddress');
            $btn['Update_addresss']['permit'] = $update_addresss;
            $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,8);
        }
        $versioninfo = getVersionInfo();
		if($versioninfo['account'] == "zhongsi" && $versioninfo['trade'] == "zhongsiplatfrom"){
            $btn = array();
            $btn['CF54massget']['label'] = getFixedLabel('CF54massget');
            $btn['CF54massget']['permit'] = 'yes';
            $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,9);
		}
    }
}
?>