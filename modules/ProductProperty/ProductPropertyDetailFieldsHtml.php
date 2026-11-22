<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
Class ProductPropertyDetailFieldsHtml extends cls_TabDetailFieldsHtml {
    function __construct($focus,$module){
        parent::__construct($focus,$module);
    }
    public function getProductHtmlLastContent(){

    }

    
}

?>