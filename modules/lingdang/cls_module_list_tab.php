<?php

/*
createdby:duan
date:20240722
reasion:列表页签信息操作类
*/
class cls_module_list_tab
{
    public $db;
    public $module;
    public $show_list;
    public $all_list;

    public static function getInstance($module)
    {
        static $static_module_list_tab_arr;
        if(isset($static_module_list_tab_arr[$module]))
        {
            return $static_module_list_tab_arr[$module];
        }
        $static_module_list_tab_arr[$module]=new cls_module_list_tab($module);
        return $static_module_list_tab_arr[$module];

    }

    public function __construct($module)
    {
        global $adb;
        $this->module = $module;
        $this->db = $adb;
    }

    public function getAllListTab(){
        if(!empty($this->all_list)){
            return $this->all_list;
        }
        $adb = $this->db;
        $sql = 'SELECT * from ld_module_list_tab where modulename = ? order by sequence asc';
        $result = $adb->pquery($sql,[$this->module]);
        $resultinfo = $adb->query_result_all($result);

        $this->all_list = $resultinfo;
        return $resultinfo;
    }

    public function getShowListTab(){
        if(!empty($this->show_list)){
            return $this->show_list;
        }
        $adb = $this->db;

        $sql = 'SELECT * from ld_module_list_tab where modulename = ? and active = "yes" order by sequence asc';
        $result = $adb->pquery($sql,[$this->module]);
        $resultinfo = $adb->query_result_all($result);
        $this->show_list = $resultinfo;
        return $resultinfo;
    }

    public function get_defualt_tab($public_module_type){
        $listtabname = '';
        $all_list_tab = $this->getShowListTab();
        if($public_module_type != ''){
            //判断当前页签是否属于当前公海模块下的,如果不是则清除session
            if(isset($_SESSION['lvsAccount'][$this->module]['pagepublicaccounttype'])){
                $session_accounttype = $_SESSION['lvsAccount'][$this->module]['pagepublicaccounttype'];
            }else{
                $session_accounttype = 'error';
            }
            foreach ($all_list_tab as $tmp_arr){
                if($tmp_arr['fromtype'] == $public_module_type ){
                    if(empty($listtabname) || $tmp_arr['isdefault'] == 'yes'){
                        $listtabname = $tmp_arr['listtabname'];
                    }
                    if($session_accounttype == $tmp_arr['listtabname'] && $tmp_arr['fromtype'] != $public_module_type ){
                        unset($_SESSION['lvsAccount'][$this->module]['pagepublicaccounttype']);
                    }
                }
            }
        }else{
            if(count($all_list_tab)>0){
                foreach ($all_list_tab as $tmp_arr){
                    if(empty($listtabname) || $tmp_arr['isdefault'] == 'yes'){
                        $listtabname = $tmp_arr['listtabname'];
                    }
                }
            }else{
                $listtabname = 'ALLACCOUNT';
            }
        }
        return $listtabname;
    }
}