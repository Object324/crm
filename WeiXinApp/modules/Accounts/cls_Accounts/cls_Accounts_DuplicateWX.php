<?php
//editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 14:39
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class  cls_Accounts_DuplicateWX extends cls_ListViewWX
{
    public function get_page_query($showtype,$isSingle){
        global  $current_user;
        //wym 240416 查重类文件结构优化
        $module = $this->module;
        crm_load_class_file ('DupSearch_ProductDetails',"modules/lingdang");
        crm_load_class_file ('DupSearch_queryGenerator',"modules/lingdang");
        $productdetail_obj=DupSearch_ProductDetails::getInstance('Accounts');
        $this->obj_query = $querygenerator=DupSearch_queryGenerator::getInstance('Accounts',$current_user,$productdetail_obj,$productdetail_obj);
        if($_REQUEST['action'] =='duplicate_related_popu_multifields'){
            $mixedDisplayColumns=array();
            crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
            $duplicate_obj=cls_DuplicateColumn::getInstance($module);
            $duplicate_obj->judgeBlacklist();
            $productdetail_obj->blackcolumnarray=$duplicate_obj->blackcolumnarr;
            $productdetail_obj->getpermission = $duplicate_obj->permit;
        }
        $querygenerator->initForCustomViewById(0);
        $versioninfo = getVersionInfo();
        if($versioninfo['account']=='shenglawei'){
            //zkt 20240311 XUQIU1002214 【圣拉维】客户查重功能开发
            $tmpcolumns = $querygenerator->getSelectColumn(getTabId($querygenerator->module));
            $tmpneedcolumn = array('cf_7533','cf_7537','cf_7541','cf_7545','cf_7554');//cf_7533:电话（男）,cf_7537:电话（女）,cf_7541:其它电话1,cf_7545:其它电话2,cf_7554:微信
            foreach ($tmpneedcolumn as $tmpcolumnname){
                $tmpselect = 'ld_accountscf.'.$tmpcolumnname;
                if(strpos($tmpcolumns,$tmpselect) === false){
                    $tmpcolumns .= ','.$tmpselect;
                    if(empty($querygenerator->whereFieldTables['ld_accountscf'])){
                        $querygenerator->whereFieldTables['ld_accountscf']=' ld_accountscf on ld_accountscf.accountid = ld_account.accountid';
                    }
                }
            }
            $querygenerator->columns = $tmpcolumns;
        }
        $this->order_by = $productdetail_obj->duplicate_orderby;
        $page_list_query = $this->page_list_query = $querygenerator->getQuery('',1);
        return $page_list_query;
    }
}
?>