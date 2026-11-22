<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Vendors_DetailViewWX extends cls_DetailViewWX
{
    //名片新增时给字段添加默认值
    protected function setDefaultValue($focus)
    {
        if(!empty($_REQUEST['cardserverId']) && !empty($_REQUEST['camcard'])){
            require_once(globalStatic::$root_directory.'expansion/camcard/cls_camcard.php');
            $camobj = new cls_camcard();
            $fieldComparison = $camobj->createViewDefaultValues($_REQUEST['camcard'],$_REQUEST['cardserverId']);
            if(!empty($fieldComparison)) {
                foreach ($focus->column_fields as $fieldname => $val) {
                    if (!empty($fieldComparison[$fieldname])) {
                        $defaultvalue = $fieldComparison[$fieldname];
                        $focus->column_fields[$fieldname] = $defaultvalue;
                    }
                }
            }
        }
    }
    protected function get_CreateView()
    {
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
    public function get_DetailView_Extra($focus)
    {

    }

    protected function set_DetailView(){
        parent::set_DetailView();
        $focus = $this->focus;
        //zkt 20231024 BUG0073893 客户管理--工商查询功能应与角色的编辑权限挂钩，没有编辑权限应不显示工商查询按钮
        if (isPermitted($this->module,'EditView',$focus->id)=='yes'){
            //明细增加工商查询
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($this->module);
            $GetTianYanSearchInfo = 'no';
            //工商查询
            if($businessinformationobj->IsEnableBusiness()){
                $GetTianYanSearchInfo = 'yes';
            }
        }
        if ($this->action == 'DetailView') {
            $this->jsonArr['GetTianYanSearchInfo'] = $GetTianYanSearchInfo;
        }
        elseif ($this->action == 'EditView'){
            if (isPermitted($this->module,'accountdatadup')=='yes'){
                $this->jsonArr['list2']['Datadupcheck'] = 'yes';
            }
            $this->jsonArr['list2']['GetTianYanSearchInfo'] = $GetTianYanSearchInfo;
        }
    }
}