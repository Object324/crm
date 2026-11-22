<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 *  The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *********************************************************************************/
//D:\wamp\www\ldcrm\WeiXinApp\WeiXin_CustomView\cls_CustomViewWX.php
 crm_load_class_file('cls_CustomViewWX','WeiXinApp/WeiXin_CustomView');
Class cls_Approve_CustomViewWX extends cls_CustomViewWX{

	public function __construct($module){
		parent::__construct($module);
	}
    
    public function getCustomViewOrderBy($viewid)
    {
        global $approvestatus;
		if(empty($approvestatus)){
			$customorder = ' tmp_approve.approveby_datetime asc ';
		}else if($approvestatus == 1){
			$customorder = ' tmp_approve.approveby_datetime desc ';
		}else if($approvestatus == 2){
			return parent::getCustomViewOrderBy($viewid);
		}
        return $customorder;
    }
    
    /**
     * edit:can
     * date:20140422
     * reason:视图手机开发
     * */
    function jsongetCustomViewCombo2($viewid = '',$thismodulename='', $markselected = true, $popup='') {
	       crm_load_class_file('CustomView_Special','modules/CustomView');
           return CustomView_Special::jsongetCustomViewCombo2($viewid ,$thismodulename,$this, $markselected , $popup);
	}

	/**
	 * 重写父类方法(分类排序)
	 * */
	/**
	 * 重写父类基本查询方法
	 * */
	function getStdFilterByCvid() {
		return $this->getStdFilterByautoid();

	}

	/**
	 * 重写父类高级查询方法
	 * */
	public function  getAdvFilterByCvid($cvid) {
		return $this->getAdvFilterByautoid();
	}

	/**
	 * 获取基本查询条件
	 * */
	function getStdFilterByautoid() {
		return array();
	}

	/**
	 * 获取高级查询条件
	 * */
	function getAdvFilterByautoid() {
		return array();
	}

}
?>