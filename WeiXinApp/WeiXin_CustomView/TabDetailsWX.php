<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017/2/22 0022
 * Time: 上午 11:50
 */

crm_load_class_file('TabDetails','include/TabDetailFields');
Class TabDetailsWX extends TabDetails{

    public function __construct($module,$langagetran=""){
        global $current_user;
        parent::__construct($module,$langagetran="");
    }
//0028247: 微信端：工时序列表界面：【创建时间】值没有显示出来
    public function getSelectColumn($tabid)
    {
        //editor:gyq_32  data:20170519 reason:移动端序时簿显示列内容统一
        //$column_header = $_REQUEST['displayColumns'];
        crm_load_class_file('QueryGenerator_FunctionsMC', 'appCommon/include/QueryGenerator');
        $OBJ = new QueryGenerator_FunctionsMC();
        $result = $OBJ->getSelectColumn_SQL($this->customviewmodule);
        $columnlist=$this->setHeaderColumnInfo($result);
        return implode(',', $columnlist);

    }

}