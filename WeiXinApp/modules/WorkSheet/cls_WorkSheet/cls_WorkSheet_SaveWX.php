<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/3/16 0016
 * Time: 上午 11:20
 */
crm_load_class_file('cls_SalesOrder_SaveWX','WeiXinApp/modules/SalesOrder/cls_SalesOrder');
class cls_WorkSheet_SaveWX extends cls_SalesOrder_SaveWX{
    public function __construct($module)
    {
        parent::__construct($module);
        if ($this->previousAction == 'EditView') {
            $this->focus->id = $_REQUEST['record'];
            $this->focus->mode = 'edit';
            $_REQUEST['mode'] = 'edit';
        } elseif ($this->previousAction == 'CreateView') {
            $this->focus->id = 0;
            $this->focus->mode = 'create';
            $_REQUEST['Create'] = 'yes';
        }
    }
    
    
    public function common_save(){
        global $current_user;
        $focus = $this->focus;
        $module = $this->module;

        //duan 20240125 留空方法重写
        $this->before_save();

        //edit:can 2020-12-23 43917: （企业微信移动端，kfbcrm）审批-合同订单；单据编号SO103，审批流“合同订单加签和条件”，填写必填项后，当前审批人审批提示“该记录正在审批中，不允许编辑！ 请联系审批人”
        $_REQUEST['cur_module_step']='1';
        if($module=='ServiceCharge') $module='Accounts';
        //0025802: （微信端-安卓）联系人：新增自定义的多选框字段，新增联系人选择多选框信息，出现代码
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        
        if(isset($_REQUEST['get_solution']) && $_REQUEST['get_solution'] == 'yes')
        {
        	$focus->retrieve_entity_info($focus->id,$currentModule);
            $before_columnfieldvalue=$focus->column_fields;
            $currency_id = $focus->column_fields['currency_id'];
            $focus->before_field_info=array();
            foreach($focus->column_fields as $fieldname=>$value)
            {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname); 
                if($fieldinfo)   
                {
                    $fieldinfo->setColumn_Value($focus->column_fields[$fieldname]);
                    $focus->before_field_info[]=$fieldinfo;
                }        
            } 
            $fieldinfo=new fieldInfo();
            $fieldinfo->setcolumnName('currencyid');
            $fieldinfo->setFieldName('currency_id');
            $fieldinfo->setColumn_Value($currency_id);
            $focus->before_field_info[]=$fieldinfo;
            $focus->mode='edit';
            //保存修改日志
            $columnname_solution = 'solution';
            $pre_solution = $focus->column_fields[$columnname_solution];
            $post_solution = $_REQUEST[$columnname_solution];
            //生成解决方案时只保存解决方案字段
            $focus->column_fields[$columnname_solution] = $post_solution;
            
            //生成解决方案后保存修改日志
            if($post_solution != $pre_solution){
                $status = 0;
                $time = date('Y-m-d H:i:s',time());
                $id = $focus->db->getUniqueID('ld_modtracker_basic');
                $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
                					values(?,?,?,?,?,?);';
                $focus->db->pquery($query,array($id,$focus->id,$module,$current_user->id,$time,$status));
                
                $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
                $focus->db->pquery($query,array($id,$columnname_solution,$pre_solution,$post_solution));
            }
        }else{
            setObjectValuesFromRequest($focus);
        }
        
        //editor:gyq_129 reason:选择源单字段增加保存到数据库功能  2019/7/11 17:34 ID1000529
        //原单
        //$_REQUEST['selectlistval']=$_REQUEST['salesorder_id'];
        //03gyqDis date:20170320 reason:币种保存方法暂时写在公告保存方法中，客户联系人保存除外！。
        global $adb;
        $currency_id_post = $_REQUEST['currency_id'];
        if($this->action=='EditView')
        {
            $currency_id = $focus->column_fields['currency_id'];
        }
        //edit:can 20220113 49636: （企业微信-kfbtest）（需要补丁）出库单新建》选择合同源单SO119，保存时提示分录的数量、合计和源单不一致
        $_REQUEST['inventory_currency']=$currency_id_post;
        if($currency_id !=$currency_id_post)
            $focus->currency_status = true;
        else
            $focus->currency_status = false;
        $focus->column_fields['currency_id']=$currency_id_post;
        $currencyobj=Currency::getInstance($adb,$currency_id_post);
        $currencySymbol = $currencyobj->getCurrencySymbol();
        $currencyRate = $currencyobj->getCurrencyRate();
        $focus->column_fields['conversion_rate'] = $currencyRate;
        $focus->column_fields['currency_symbol'] = decode_html($currencySymbol);
        if(empty($_REQUEST['confirm_save']))
        {
            crm_load_class_file('cls_PageValidataSave','data');//验证规则，提示保存
            $PageValidataSaveobj=new cls_PageValidataSave($this->module,$this->focus->id,$_REQUEST['rowcnt']);
            $PageValidataSaveobj->setAllowSave('yes');
            
         
            $PageValidataSaveobj->setCurrencyId($focus->column_fields['currency_id']);
            $PageValidataSaveobj->getValidDataInfoPhp();
            
            if(!empty($PageValidataSaveobj->errortip)){
            //edit:can 20210425 保存验证规则
                $_REQUEST['diony']='yes';
                
                ConvertTojsonString("2",array(),$PageValidataSaveobj->errortip);
            }
        }
        
           

        $focus->save($module);

        

        $relatedCreationInfo = $_REQUEST['relatedCreationInfo'];
        $relatedCreationArr = json_decode($relatedCreationInfo,true);
        if(!empty($relatedCreationArr)){
            $frommodule = $relatedCreationArr['frommodule'];
            $fromid = $relatedCreationArr['fromid'];
        }
        if($module=='HelpDesk'&&!empty($relatedCreationArr)){
            if ($frommodule == 'ServiceContracts'||$frommodule=="Project"||$frommodule=='Products') {	     
				$on_focus = CRMEntity::getInstance($frommodule);
				$on_focus->save_related_module($frommodule, $fromid, $module, $focus->id);
			}
        }
      
        if(!empty($_REQUEST['file_save_weixin'])){
            $this->saveAttachmentFromWeiXinApi_CommonModule($focus->id,$module,$_REQUEST['file_save_weixin']);
        }

        //duan 20240125 将签到以及审批必填字段的保存合并到一起
        $this->after_save();
        
    }
}