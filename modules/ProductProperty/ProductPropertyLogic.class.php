<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ProductPropertyLogic extends BaseLogic {
	
	public function getListMoreBtn() {
		parent::getListMoreBtn();
	}
    public function getDeleteBtn()
    {
        global $adb;
        $module = self::$module;
        $buttons = parent::getDeleteBtn();
        //判断删除 产品属性被使用不允许删除

        $focus = CRMEntity::getInstance($module);
        $tmpsql = "select productid,productname from ld_products where find_in_set(?,propertyids) ";
        $tmpres = $adb->pquery($tmpsql,array($focus->id));
        $tmpnum = $adb->num_rows($tmpres);
        if($tmpnum>0){
            $buttons['permit'] = 'no';
        }
        return $buttons;
    }
}
?>