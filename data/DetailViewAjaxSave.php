<?php

class DetailViewAjaxSave{
    public $module;
    public $record;
    public $fieldname;
    public $fieldvalue;
    public  $fieldlabel;
    public  $code;
    public  $errormsg;
    public $ret_arr=array();//设置默认值，否则返回时result为null
    public $workflow_apiinfo;
    function __construct($module,$record,$fieldname,$fieldvalue)
    {
        $this->module=$module;
        $this->record=$record;
        $this->fieldname=$fieldname;
        $this->fieldvalue=$fieldvalue;
        $this->code=1;
        $this->errormsg='success';
    }
    
    public function save()
    {
        $_REQUEST['diony']='yes';
        $modObj=CRMEntity::getInstance($this->module);
        $crmid = $this->record;

        $fieldname = $this->fieldname;
        $fieldvalue = $this->fieldvalue;
        //$fieldid=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'fieldid');
        $fieldlabel=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'fieldlabel');
        $this->fieldlabel=$fieldlabel;
        $fieldonly=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'fieldonly');
        $tablename=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'tablename');

        if($modObj->logaction == ''){
            $modObj->logaction = 'detailviewedit';
        }
        if($crmid != "")
        {
            $uitype=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'uitype');
            /*if($uitype==1101)
            {

                        $value=fieldValueUitype::SetMobileStyle($crmid,$fieldvalue,$currentModule);
                         echo  "##mobile##".$value."##mobile##";

            }*/
            $focus = CRMEntity::getInstance($this->module)->getModuleLogic($this->module);
            $rest=$focus->checkEditInfo($this->module,$record);
            if($rest!='SUCCESS')
            {
                ConvertTojsonString(-1,array(),$rest);
            }

            //查询是否重复
            if($fieldonly=='1') {
                include './modules/lingdang/staticlingdang.class.php';
                $ldcls = new staticlingdang();
                $rest = $ldcls->getFieldDuplicateInfo($this->module,$fieldname,$fieldvalue,$this->record);
            }else{
                $rest='##success##';
            }
            if($rest=='##success##')
              {

                    $modObj->retrieve_entity_info($crmid,$this->module);

                    $modObj->column_fields[$fieldname] = $fieldvalue;
                    $before_column_fields = $modObj->column_fields;

                    $modObj->id = $crmid;
                    $modObj->mode = "edit";

                    foreach($modObj->column_fields as $tmpfieldname=>$tmpvalue)
                    {
                        $tmptablename=$modObj->fieldobj->getFieldInfoBykeyValue("fieldname",$tmpfieldname,'tablename');
                        if(($tmptablename=="ld_contactdetails"||$tmptablename=='ld_contactscf')&&($this->module=='Accounts'||$this->module=='ServiceCharge'))
                        {
                            //edit:can BUG0065816,联系保存客户 ，首要联系人丢失
                            continue;
                        }
                        //zkt 20230908 合计字段值未获取到值 BUG0072351 V8.5.0.6 销售发票模块设置了验证规则：发票总金额不得为0,详情页0.01有提示
                        if($tmpfieldname=='hdnGrandTotal'){
                             if($this->module=='CashBill')
                                {
                                    $tmpfieldname='cashbill_total';
                                }
                                else if($this->module=="SendCashBill")
                                {
                                    if(is_numeric($_REQUEST['sendcashbill_total']))
                                    {
                                        $tmpfieldname='sendcashbill_total';
                                    }
                                    else{
                                        $tmpfieldname='total';
                                    }
                                }
                                else
                                    $tmpfieldname='total';
                        }
                        //edit:can 54649 http://crm.airmaster.com.cn/crm）合同订单编辑字段的时候，验证规则出现BUG
                        if($tmpfieldname!=$fieldname){

                            $_REQUEST[$tmpfieldname]=$tmpvalue;
                        }

                    }
                    // 不走公共代码来保存附件
                    $modObj->set_Is_needcommonsave_attachments('no');

                    $modObj->save($this->module);
                    foreach($modObj->column_fields as $tmpfieldname=>$tmpvalue)
                    {
                        if($tmpfieldname!=$fieldname){

                            unset($_REQUEST[$tmpfieldname]);
                        }
                    }
                    //字段 公式
                    crm_load_class_file("cls_mainfieldformula","include/fields");
                    $mainfieldformula=cls_mainfieldformula::getInstance($this->module);
                    $tmpArr=array($fieldname=>$fieldvalue);
                    //设置哪些字段 在界面上保存
                    $mainfieldformula->setMainFieldHadRequest($tmpArr);
                    $mainfieldformula->setRecord($crmid);
                    //设置数据库字段的值
                    $mainfieldformula->setColumn_fieldsValue($modObj->column_fields);
                    /*可以不需要传入明细，默认明细界面的值没有被修改
                    $keys=array_keys($detailfieldInfo_arr);
                    $mainfieldformula->setDetailFieldHadRequest($keys);
                    $mainfieldformula->setdetailColumn_fieldsValue($detailarr);*/

                    $mainfieldformula->updateDbValue($fieldname,$crmid);
                    $modObj->massEdit_save_after($this->module,array($crmid));
                    $arr=array();
                    if($modObj->id != "")
                    {
                        // $arr['code']=1;
                        $arr['fieldhrefname']=$modObj->list_link_field;
                        $arr['fieldvalue']=$modObj->column_fields;
                        if($uitype==1101){
                              $value=fieldValueUitype::SetMobileStyle($crmid,$fieldvalue,$this->module);
                               $datainfo[$fieldname]=array("fieldname"=>$fieldname,'value'=>$value,'rawvalue'=>'');
                        }
                        elseif ($uitype==251){
                            //ls 2022-07-08 BUG0053490 付款单的付款账户字段，单据详情页小编辑保存后，列表页会显示成数字
                            crm_load_class_file("BankAccountSet", "modules/BankAccountSet");
                            $value = BankAccountSet::getBackAccountNameById($fieldvalue);
                            $datainfo[$fieldname] = array("fieldname"=>$fieldname,'value'=>$value,'rawvalue'=>$fieldvalue);
                        }
                        elseif ($uitype==56 || $uitype==156)
                        {
                            if($fieldvalue==1 || $fieldvalue=='on')
                            {
                                 $datainfo[$fieldname]=array("fieldname"=>$fieldname,'value'=>getFixedLabel("YES"),'rawvalue'=>$fieldvalue);
                            }
                            else{
                                $datainfo[$fieldname]=array("fieldname"=>$fieldname,'value'=>getFixedLabel("NO"),'rawvalue'=>$fieldvalue);
                            }
                        }
                        elseif ($uitype==15)
                        {
                            //edit: xll 2023/08/15 XUQIU1001400 费用预算单按目标预算需要修改翻译方式
                            $fieldvalue_label = getFixedLabel($fieldvalue);
                            if($fieldname == 'budget_indicators' && $this->module == 'ExpenseBudget'){
                                $budgetType = $modObj->column_fields['expensebudget_type'];
                                if($budgetType == 'salesGoalBudget')
                                {
                                    crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
                                    $fieldvalue_label = SalesGoalNew::getFixedLabel_SalesGoal_Byname($fieldvalue);
                                }
                            }
                            $datainfo[$fieldname]=array("fieldname"=>$fieldname,'rawvalue'=>$fieldvalue_label,'value'=>$fieldvalue_label);
                        }
                        else{
                            crm_load_class_file('Cls_FieldShowValue', 'modules/Users');
                            $cls_fieldshowvalueobj = new Cls_FieldShowValue($this->module,$crmid,$fieldname);
                            $cls_fieldshowvalueobj->setshowfieldlist_showtype(SHOW_DETAILVIEW);
                            $showvalue = $cls_fieldshowvalueobj->getShowfieldValue();
                            $datainfo[$fieldname]=array("fieldname"=>$fieldname,'rawvalue'=>$showvalue['rawvalue'],'value'=>$showvalue['value']);
                        }

                        //zkt BUG0054768客户界面使用小编辑修改客户名称之后，再点击工商信息查询，会提示客户名称为空
                        if($fieldname == 'accountname'||$fieldname == 'vendorname'){
                            $datainfo[$fieldname]['value_name'] = $fieldvalue;
                        }
                        if($fieldname!=$modObj->list_link_field)
                        {
                            $datainfo[$modObj->list_link_field]=array("fieldname"=>$modObj->list_link_field,'value'=>$modObj->column_fields[$modObj->list_link_field]);
                            //zkt 20230918 BUG0072823 客户模块，修改某个字段后（小编辑），点击工商查询按钮提示无客户名称（具体见附件视频，视频格式系统不支持上传.mov格式，处理时单独微信发送）（kfbcrm也有这个问题）
                            if($modObj->list_link_field == 'accountname'||$modObj->list_link_field == 'vendorname'){
                                $datainfo[$modObj->list_link_field]['value_name'] = $modObj->column_fields[$modObj->list_link_field];
                            }
                        }
                        $this->ret_arr['datainfo']=$datainfo;
                        $this->ret_arr['fieldhrefname']=$modObj->list_link_field;



                     if(is_array($mainfieldformula->updatecolumn_arr)&&sizeof($mainfieldformula->updatecolumn_arr)>0)
                        {
                             global $reset_retrieve_entity_info;//修改日志需要重新获取数据
                             $reset_retrieve_entity_info='yes';
                             $modObj->retrieve_entity_info($modObj->id,$this->module);
                             //zkt 20240923 BUG20240923-08 销售订单中采购信息区块里面手工填写采购成本字段后，毛利以及毛利率设置了公式不参与计算
                            $tmp_after_column_fields = $modObj->column_fields;
                            $tmpdatainfo = [];
                            if(!empty($tmp_after_column_fields)){
                                crm_load_class_file('Cls_FieldShowValue', 'modules/Users');
                                foreach ($tmp_after_column_fields as $tmpfieldname=>$tmpfieldvalue){
                                    if($before_column_fields[$tmpfieldname]!= $tmpfieldvalue){
                                        $cls_fieldshowvalueobj = new Cls_FieldShowValue($this->module,$crmid,$tmpfieldname);
                                        $cls_fieldshowvalueobj->setshowfieldlist_showtype(SHOW_DETAILVIEW);
                                        $tmpshowvalue = $cls_fieldshowvalueobj->getShowfieldValue();
                                        $tmpdatainfo[$tmpfieldname]=array("fieldname"=>$tmpfieldname,'rawvalue'=>$tmpshowvalue['rawvalue'],'value'=>$tmpshowvalue['value']);
										unset($tmpshowvalue,$cls_fieldshowvalueobj);
                                    }
                                }
                            }
                            if(!empty($tmpdatainfo)){
                                $this->ret_arr['datainfo'] = array_merge($this->ret_arr['datainfo'],$tmpdatainfo);
                            }
                            unset($tmpdatainfo);
                        }

                        crm_load_class_file("cls_savereverse",'include/SaveReverse');

                        $workflowreverseobj=cls_savereverse::getInstance($this->module);
                        $workflowreverseobj->setRecord($modObj->id);
                        $beforefieldvalue_arr=[];
                        $afterfieldvalue_arr=[];

                        foreach($modObj->before_field_info as $fieldinfo)
                        {
                            $beforefieldvalue_arr[$fieldinfo->getFieldName()]=$fieldinfo->getColumn_Value();
                        }


                        $pagemode='updated';
                         $workflowreverseobj->setPageMode($pagemode);
                         if($workflowreverseobj->checkCallApiPop() == 'yes')
                         $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));//无需处理的API类型
                        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$modObj->column_fields,$pagemode);

                         $receive_msg = $workflowreverseobj->checkCallApiPop();
                         $this->workflow_apiinfo['receive_msg'] = $receive_msg;
                         if ($receive_msg == 'yes') {
                             $this->workflow_apiinfo['record'] = $modObj->id;
                             $this->workflow_apiinfo['module'] = $this->module;
                             $this->workflow_apiinfo['pagemode'] = $workflowreverseobj->getPageMode();

                             $this->workflow_apiinfo['before_save_infos'] = $beforefieldvalue_arr;
                             $this->workflow_apiinfo['after_save_infos'] = $modObj->column_fields;
                         }

                        $this->code=1;
                          //ConvertTojsonString(1,$arr,'success');
                         //echo ":#:SUCCESS";
                     }else
                     {
                      //$arr['code']='-1';
                        // echo ":#:FAILURE";
                        $this->code=-1;
                        $this->errormsg='error';
                        //ConvertTojsonString(-1,array(),'error');
                     }

            }
            else{
                $this->code='-1';
                $this->errormsg=$fieldlabel.getFixedLabel('CANNOTREPEAT');
                // ConvertTojsonString(-1,array(),$fieldlabel.getFixedLabel('CANNOTREPEAT'));   ;
            }
        } else {
            // $arr['code']='-1';
            // echo ":#:FAILURE";
            $this->code='-1';
            $this->errormsg='error';
            //ConvertTojsonString(-1,array(),'error');
        }
    }
    public function setEcho()
    {
        $this->ret_arr['workflow'] = $this->workflow_apiinfo;//兼容列表和详情页小编辑
        ConvertTojsonString($this->code,$this->ret_arr,$this->errormsg);
    }
}
?>