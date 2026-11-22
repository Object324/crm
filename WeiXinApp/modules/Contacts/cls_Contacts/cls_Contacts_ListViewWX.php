<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');//gyq_24
class  cls_Contacts_ListViewWX extends cls_ListViewWX
{
    //联系人模块获取查询手机号码的查询语句 gyq_32
    protected function get_phone_sql($focus,$list_query){
        /*
        $moduleFields = $focus->fieldobj->getModuleFields();
//设置手机号码的显示样式:如果手机控制样式，则只取uitype等于11的字段值
        $sysdeploy_mobile_style = getSys_deploy(80);
        foreach ($moduleFields as $fieldname => $fieldinfo) {
            if ($sysdeploy_mobile_style['deploy_value'] >= 1 && $fieldinfo->getUIType() == 11
                || $sysdeploy_mobile_style['deploy_value'] == 0 && ($fieldinfo->getUIType() == 11 || $fieldinfo->getUIType() == 1101)
            ) {
                $tablename = $fieldinfo->getTableName();
                $columnname = $fieldinfo->getColumnName();
                if ($tablename == 'ld_contactscf') {
                    $listscf = ' FROM ld_contactdetails left join ld_contactscf on ld_contactdetails.contactid = ld_contactscf.contactid ';
                    if(stripos(str_replace(' ','', $list_query),'leftjoinld_contactscf')  === false) {
                        $list_query = str_replace('FROM ld_contactdetails', $listscf, $list_query);
                    }
                }
                $querycolumnname[] = $tablename . '.' . $columnname;
            }
        }
        if (sizeOf($querycolumnname) >= 1) {
            $querycolumnname = 'CONCAT_WS(" ",' . implode(',', $querycolumnname) . ') as mobile,';
            $list_query = str_replace("ld_contactdetails.mobile,", $querycolumnname, $list_query);
        }*/
        return $list_query;

    }
    public function get_page_query($showtype,$isSingle){
        $page_list_query = parent::get_page_query($showtype,$isSingle);
        //zxm 1222 生日
        if(!empty($_REQUEST['birthday'])){
            $page_list_query .= " and ".$_REQUEST['birthday'];
        }
        //zxm 获取外部联系人  需要weixin_external_userid不为空
        if(!empty($_REQUEST['weixin_external_userid'])&&$_REQUEST['weixin_external_userid']=='yes'){
            $page_list_query .= " and ld_contactdetails.weixin_external_userid is not null and ld_contactdetails.weixin_external_userid!=''";
        }
        return $page_list_query;
    }
}
?>