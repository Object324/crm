<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_ServiceCharge_DetailViewWX extends cls_DetailViewWX
{
    //首要联系人
    public function get_DetailView_Extra($focus)
    {
        crm_load_class_file('Detail_Edit_View','include/utils');
        $focus->column_fields['contact_id']=Detail_Edit_View::getAccountPrimaryContactInfo($focus);//gyq_26 关系信息新增
        $this->get_trends_permit();
    }

    protected function get_CreateView()
    {
        //客户查重权限判断，新增界面客户名称旁边有搜索功能 editor:gyq_20180906  0035158: （珞落计划企业微信登录）客户模块：当前操作员没有“客户查重”权限时，客户新增界面也应该没有“查重”权限
        if (isPermitted($this->module,'accountdatadup')=='yes'){
            $list_buttons['Datadupcheck'] = 'yes';
        }
        //editor:gyq_20190509 reason:0037039: 企业微信-客户新增时，返回是否开启工商查询参数
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($this->module);
        //工商查询
        if($businessinformationobj->IsEnableBusiness()){
            $list_buttons['GetTianYanSearchInfo'] = 'yes';
        }
        //工商查询列表
        if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            $list_buttons['GetTianYanSearchInfoVague'] = 'yes';
        }
        $this->jsonArr['list2'] = $list_buttons;
        return parent::get_CreateView();
    }
    //判断移动端动态模块是否启用
    protected function get_trends_permit()
    {
        global $adb;
        $tabid = getTabid($this->module);
        $sql = "SELECT presence from ld_relatedlists where tabid=? and related_tabid=?";
        $result = $adb ->pquery($sql,array($tabid,-16));
        $numrows = $adb->num_rows($result);
        $tmp_permit = 'no';
        if($numrows >0){
            $presence = $adb->query_result($result,0,'presence');
            if($presence==0) {
                $tmp_permit = 'yes';
            }
        }
        $version = getVersionTradeInfo();
        $old_version = 'V8.4.3.4';
        $current_version = $version['current_version'];
        if($current_version<$old_version)
            $tmp_permit = 'yes';
        $this->jsonArr['defaultSetting']['trends_permit']=$tmp_permit;
        return ;
    }
    protected function set_DetailView(){
        parent::set_DetailView();
        $focus = $this->focus;
        if ($this->action == 'DetailView') {
            //zkt 20231024 BUG0073893 客户管理--工商查询功能应与角色的编辑权限挂钩，没有编辑权限应不显示工商查询按钮
            if (isPermitted($this->module,'EditView',$focus->id)=='yes'){
                //明细增加工商查询
                crm_load_class_file('cls_BusinessInformation', 'modules/Users');
                $businessinformationobj = cls_BusinessInformation::getInstance($this->module);
                $this->jsonArr['GetTianYanSearchInfo'] = 'no';
                //工商查询
                if($businessinformationobj->IsEnableBusiness()){
                    $this->jsonArr['GetTianYanSearchInfo'] = 'yes';
                }
            }
        }

    }

}