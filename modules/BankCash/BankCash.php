<?php
/*******************************************************
**库存导航
**edit:chj
**date:2013-11-14
**reason:库存导航
*******************************************************/
class BankCash extends CRMEntity {
    
    
    static  function require_file($requiremodules='')
    {
		globalStatic::$arr_module_require['BankCash']='BankCash';
	}
}
?>