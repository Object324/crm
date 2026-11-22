<?php
/**
 * 自助服务平台PC端设置界面响应后台Model类
 * Date: 2018/8/7
 * Time: 10:03
 */
class SelfServiceConfigModel{
    //删除 单据界面字段设置
    public function field_action_delete($r_fieldid,$r_module){
        global $adb;
        //删除通用字段时删除列表字段
        $sql = 'select fieldname from ld_weixinmp_fields where id=?';
        $result = $adb->pquery($sql,array($r_fieldid));
        $adb->pquery('delete from ld_weixinmp_listfields where fieldname=? and modulename=?',array($adb->query_result($result,0,0),$r_module));
        $adb->pquery('delete from ld_weixinmp_fields where id=?',array($r_fieldid));
    }
    //字段上移
    public function field_action_move_up($r_fieldid){
        global $adb;
        $sequence = $adb->query_result($adb->pquery('select sequence from ld_weixinmp_fields where id=?',array($r_fieldid)),0,0);
        $adb->pquery('update ld_weixinmp_fields set sequence=sequence+1 where sequence=?',array($sequence-1));
        $adb->pquery('update ld_weixinmp_fields set sequence=sequence-1 where id=?',array($r_fieldid));
    }
    //字段下移
    public function field_action_move_down($r_fieldid){
        global $adb;
        $sequence = $adb->query_result($adb->pquery('select sequence from ld_weixinmp_fields where id=?',array($r_fieldid)),0,0);
        $adb->pquery('update ld_weixinmp_fields set sequence=sequence-1 where sequence=?',array($sequence+1));
        $adb->pquery('update ld_weixinmp_fields set sequence=sequence+1 where id=?',array($r_fieldid));
    }
    //字段新增、编辑
    public function field_action_edit($r_fieldid,$r_module){
        $allFields = $this->getModuleDisplayFields($r_module,$r_fieldid,'ld_weixinmp_fields');
        /*editor:gyq_74 date:20180730 reason:优化自助服务平台设置代码*/
        $default_permit_arr = array(1,71,17,11,13,15,21,19,2);
        // 1 表示'是'，0表示'否'
        foreach ($allFields as $key=>$value){
            $show_type = array();
            $show_type['uitype'] = $value['uitype'];
            $show_type['bigtype'] = $value['bigtype'];
            $fieldname_v = $value['fieldname'];
            if($value['displaytype']==1 || $value['tabletype']=='detail'){
                $show_type['show'] = 1;   //新增界面是否显示
                $show_type['mandatory'] = 0;//是否必录

                if($fieldname_v=='account_id' ||$fieldname_v=='contact_id' ){
                    $show_type['show_edit'] = 0;//显示单选项是否允许修改
                    $show_type['mandatory_edit'] = 0;//必录单选项是否允许修改
                }else{
                    $show_type['show_edit'] = 1;//显示单选项是否允许修改
                    $show_type['mandatory_edit'] = 1;//必录单选项是否允许修改
                }
                if(in_array($value['uitype'],$default_permit_arr) || !isset($value['uitype'])){
                    $show_type['default'] = 1;//默认值是否允许修改
                }else{
                    $show_type['default'] = 0;//默认值是否允许修改
                }
                if($fieldname_v=='productname'){
                    $show_type['default'] = 0;
                }
            }else{
                //	0034883: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置：新增界面选择只读字段时“*新增界面是否显示”和“*新增时是否必录项”应都控制为“否”，且不可修改
                $show_type['show'] = 0;   //新增界面是否显示
                $show_type['mandatory'] = 0;//是否必录
                $show_type['show_edit'] = 0;//显示单选项是否允许修改
                $show_type['mandatory_edit'] = 0;//必录单选项是否允许修改
                $show_type['default'] = 0;//默认值是否允许修改
            }
            if(isset($value['set_detail'])){
                $transfor_arr = array('createno'=>0,'all'=>1,'m'=>1,'o'=>0);
                $show_type['show'] = $transfor_arr[$value['set_detail']['displaytype']];   //新增界面是否显示
                $show_type['mandatory'] = $transfor_arr[$value['set_detail']['typeofdata']];//是否必录
                $show_type['default_value'] = $value['set_detail']['defaultvalue'];
            }else{
                $show_type['default_value'] = $value['default_value'];
            }
            //editor:gyq_20180816 0034913: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置：“服务人员”和“销售负责人”编辑界面不重新选择成员点击确认按钮时弹出提示信息“undefined!”无法保存
            if(empty($show_type['default_value'])){
                $show_type['default_value'] = '';
            }
            //editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/27 11:11 
            if($value['uitype']=='53'){
                $show_type['default'] = 1;
                $show_type['show'] = 0;
                //editor:gyq_74 reason:自助服务平台_客户注册 20180802 19:55  0034814: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置：“服务人员”和“销售负责人”编辑界面“*新增界面是否显示”和“*新增时是否必录项”应都控制为“否”，且不可修改
                $show_type['show_edit'] = 0;
                $show_type['mandatory'] = 0;
                $show_type['mandatory_edit'] = 0;
            }
            $allFields[$key]['show_type'] = str_replace('"','##',json_encode($show_type))  ;
        }
        return $allFields;
    }
    //字段保存
    public  function field_action_save(){

    }
    //获取模块可以显示的字段
    public function getModuleDisplayFields($modulename,$r_fieldid,$tablename){
        global $adb;
        // editor:gyq 2018/8/8 17:13  增加过滤 uitype=51	0034817: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）客户模块自助服务平台新增单据界面字段设置：新增弹出层界面下拉框中应不显示“上级单位”字段
        $nonsupuitype = array('HelpDesk'=>array('76','79','243','80'),
            'SalesOrder'=>array('78','53','80','76'),
            'Accounts'=>array('73','80','57','76','51'));
        $nonsupname = array('SalesOrder'=>array('express_company','express_no','hdnSubTotal'));
        $nonsupdetail = array('SalesOrder'=>array('productcost'));
        $nonsuplist = array('69','1109','1108','28','202','200','222');
        //合同订单下拉选项暂时限制仅显示三个产品字段
        $product_field_limit = array('productsheet','quantity','productname','listprice','tax_amount');
        $query = 'select fieldname from '.$tablename.' where modulename = ?';
        if(!empty($r_fieldid)){
            $query .= ' and id != ' . $r_fieldid;
        }
        $result = $adb->pquery($query,array($modulename));
        $num_rows = $adb->num_rows($result);
        $haveFields = [];
        for($i = 0;$i < $num_rows;$i++){
            $col = $adb->query_result($result,$i,'fieldname');
            $haveFields[] = $col;
        }
        $fieldobj=Field::getInstance($modulename,$adb);
        //非管理员有后台权限
        $moduleFields=$fieldobj->getModuleAllPreseneceFields();
        $productmoduleFields = array();
        //editor:gyq_20190422 reason:合同订单产品分录不允许设置
       /* if($modulename=='SalesOrder'){
            crm_load_class_file("ProductDetails",'include/ProductDetails');
            $productDetails=ProductDetails::getInstance($modulename);
            $productmoduleFields=$productDetails->getModuleFields();
        }*/
        $modulehavefields = cls_MP_CommonFun::getMpModuleFields($modulename);
        foreach($moduleFields as $fieldname => $fieldinfo){
            $uitype = $fieldinfo->getUIType();
            /*editor:gyq date:20180728 reason:新增displaytype 0034675: （客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置：选择CRM系统中的只读字段时，控制“新增界面时是否显示”和“*新增时是否必录项”为否，且不能修改*/
            $displaytype = $fieldinfo->getDisplaytype();
            //editor:gyq date:20180728 reason:仅序时簿可见的字段无需显示
            if($displaytype==3) continue;
            if((is_array($nonsupuitype[$modulename]) && in_array($uitype,$nonsupuitype[$modulename]))
                || (is_array($nonsupname[$modulename]) && in_array($fieldname,$nonsupname[$modulename]))
                || in_array($fieldname,$haveFields)) 
                continue;
            if($tablename=='ld_weixinmp_listfields'&&(!array_key_exists($fieldname,$modulehavefields)||in_array($uitype,$nonsuplist))) continue;

            $cell_field = array(
                'fieldlabel' => $fieldinfo->getFieldLabel(),
                'fieldname' => $fieldname,
                'tabletype' => 'main',
                'uitype' => $fieldinfo->getUIType(),
                'bigtype' => $fieldinfo->getBigType(),
                'displaytype' => $displaytype,
                'default_value' => $fieldinfo->getDefaultvalue()
            );
            //editor:gyq 2018/8/8 17:29  0034820: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置界面“	新增界面是否显示”和“新增时是否必录项”与编辑弹出层界面设置显示不一致
            if(isset($modulehavefields[$fieldname])){
                $cell_field['set_detail'] = $modulehavefields[$fieldname];
            }
            $allFields[] = $cell_field;
        }
        /*if($tablename=='ld_weixinmp_fields'){
            foreach($productmoduleFields as $fieldname=>$productfieldinfo){
                if(in_array($fieldname,$nonsupdetail[$modulename])||in_array($fieldname,$haveFields)) continue;
                if(in_array($fieldname,$product_field_limit)){
                    //editor:gyq 2018/8/8 17:29 0034820: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）自助服务平台新增单据界面字段设置界面“	新增界面是否显示”和“新增时是否必录项”与编辑弹出层界面设置显示不一致
                    $cell_field = array(
                        'fieldlabel' => getTransTab('Products').'_'.$productfieldinfo->getFieldLabel(),
                        'fieldname' => $fieldname,
                        'tabletype' => 'detail'
                    );
                    if(isset($modulehavefields[$fieldname])){
                        $cell_field['set_detail'] = $modulehavefields[$fieldname];
                    }
                    $allFields[] = $cell_field;
                }
            }
        }*/
        return $allFields;
    }
}