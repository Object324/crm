<?php
if (!empty($_REQUEST['selectmodule'])) {
    //editor:gyq_20200221 reason:0039253: （51mis.com/kfbcrm）企业微信>灵当CRM>跟进记录新增选择客户界面：当“客户”模块全部页签为“全部（不含公海）”的情况下，在跟进记录选择客户界面输入值进行搜索公海已分配客户，搜索不出来。（pc端是正常的，需要补丁）
    global $weixin_user,$mobile_pagerecordcount;
    $tmp_mobile_pagerecord=$mobile_pagerecordcount;
    //zxm 20230308 移动端，字段类型为：关联选择单据（单选），设置：最多显示数据条数 ，移动端不生效 例：跟进记录，页面设置，设置关联选择单据字段：销售机会--设置“最多显示数据条数”为5--
    //if($_REQUEST['selectmodule'] == 'Accounts'){
        $weixin_user->action = 'related_popu';
    //}
    $selectmodule = $_REQUEST['selectmodule'];
    $poaction = $_REQUEST['purpose_action'];
    if ($poaction == 'ListView') {
        global $mobile_pagerecordcount, $adb, $singin_tabid;//签到tabid
        $showQuickCreate = 'no';
        $_REQUEST['filter']['SearchScope'] = 'SmOwner_Search_All'; //查看范围
        $_REQUEST['filter']['searchcontent'] = $_REQUEST['search_content']; //序时簿查找内容
		if ($_REQUEST['selectrelationfrom'] == 'main' || $_REQUEST['related_pop_type'] == 'signin' 
        ||$_REQUEST['selectrelationfrom'] == 'undefined'||$_REQUEST['selectrelationfrom'] == ''){ //45426
			crm_load_class_file('cls_RelatePopu_ListViewWX', 'WeiXinApp/list');
			$mobj = new cls_RelatePopu_ListViewWX($selectmodule);
		}else{
			crm_load_class_file('cls_RelatePopu_detail_ListViewWX', 'WeiXinApp/list');
			$mobj = new cls_RelatePopu_detail_ListViewWX($selectmodule);
		}

        $withdetail = $_REQUEST['withdetail'];
        $unallowrepeat = $_REQUEST['unallowrepeat'];
        if ($unallowrepeat == 'yes'){
            if ($withdetail == 'yes'){
                $mobj->setQueryWithDetail('yes');
            }else{
                $mobj->setQueryWithDetail('no');
            }
        }

        //PC端两种弹出框形式，是通过前端控制，这里暂时判断包含产品明细模块区分
        $title = getTranstab($_REQUEST['selectmodule']);
		if($_REQUEST['frommodule'] == 'Work'){
			//这里暂时注销掉。 48975: （https://www.51mis.com/hy/HPYYtj1101/ [^]）数据范围为自己，OA表单->工作汇报，PC端编辑日志时关联客户和联系人是选自己的，但企业微信移动端，能选到其他人员的客户和联系人
			//$_REQUEST['frommodule'] = $_REQUEST['selectmodule'];
		}
        $frommodule = $_REQUEST['frommodule'];
        $selectmodule = $_REQUEST['selectmodule'];
        //wym XUQIU1001764 多选关联字段 先不做关联 后续要做关联可以把这个判断注释
        if(!empty($_REQUEST['fieldname'])&&!empty($frommodule)){
            $fromfocus = cls_Instance::get_module_Instance($frommodule);
            $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $_REQUEST['fieldname']);
            if($fieldinfo){
                $bigtype = $fieldinfo->getBigType();
                if($bigtype=='multireference'){
                    unset($_REQUEST['parent_id']);
                }
            }
        }
        //editor:gyq_20200225
        if($selectmodule=='Accounts')
        {
            setSearchAllAccount();//设置查询所有的客户（包括公海客户）
        }
        //editor:gyq_81 reason:签到考勤优化 2018/9/27 13:54
        //根据当前操作员的数据范围显示，仅显示当前操作员有权限看到的数据，显示5条数据
        if ((isset($_REQUEST['related_pop_type']) && $_REQUEST['related_pop_type'] == 'signin')||($frommodule == 'Singin' &&$_REQUEST['fieldname']=='selectlistval')) {
           
            $_REQUEST['related_pop_type'] = 'signin';
            if (empty($singin_tabid)) {
                $sql = 'select tabid from ld_tab where name="Singin"';
                $result = $adb->pquery($sql, array());

                $tabid = $adb->query_result($result, 0, 'tabid');
                $singin_tabid = $tabid;
            }
            //editor:gyq_158 reason:拜访签到选择拜访对象，显示条数根据源单定制  2019/11/5 20:47
            $mobj->singinRelatePop = $tabid = $singin_tabid;
            crm_load_class_file('cls_OptionModule', 'include/OptionModule');
             $optionmoduleobj = cls_OptionModule::getInstance($frommodule);
            $options = $optionmoduleobj->getData();
            $option_tabid = getTabid($selectmodule);
            if($option_tabid == 16){
                $option_tabid = 9;
            }
            $mobile_pagerecordcount = $options[$tabid][$option_tabid]['maxrowsshow'];
          
            //  $_REQUEST['frommodule']='Singin';
            $poptype = 'droppop';
            //是否有创建权限
            //wyt 221110 XUQIU1000658 主题：关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮
            if($selectmodule=='BudgetChange'||$selectmodule=='QuotesChange'||$selectmodule == 'Checks'||$selectmodule == 'BankAccountSet'||$selectmodule == 'ExpenseBudget'||$selectmodule == 'Reminds'||$selectmodule == 'WeChatUser'){
                $showQuickCreate = 'no';
            } else if(isPermitted($selectmodule,'Create','')=='yes'){
                $showQuickCreate='yes';
            }

//            if ($selectmodule == 'Accounts' && isPermitted('Accounts', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Contacts' && isPermitted('Contacts', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Products' && isPermitted('Products', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Vendors' && isPermitted('Vendors', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'ContactRecords' && isPermitted('ContactRecords', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Potentials' && isPermitted('Potentials', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'ServiceCharge' && isPermitted('ServiceCharge', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else {
//                $showQuickCreate = 'yes';
//            }
            //editor:gyq_148 reason:企业微信新增工作协同选择客户联系人  2019/10/11 15:16
        } elseif ($frommodule == 'Work') {
            $poptype = 'droppop';
        } else {
            //editor:gyq_20190726 reason:0037614报价单相关界面：报价变更单新增->追加，选择产品名称界面产品加载不出来 2019/7/26 11:42
            $fromfocus = cls_Instance::get_module_Instance($frommodule);

            if ($_REQUEST['selectrelationfrom'] == 'main')
                $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $_REQUEST['fieldname']);
            else {
                $fieldinfo = $fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname", $_REQUEST['fieldname']);

            }
			//chj 2020/12/30 44044: （http://akjykj.vicp.cc:85/crm [^]）企业微信移动端，客户问题（安康金源），客户服务单选择客户界面，搜索（安康市诚鹏仓储物流有限公司）搜索不到
            if (get_file_address($selectmodule, 'ProductDetails') || $selectmodule == 'Products') {
                $poptype = 'droppop';
            } else {
                $poptype = 'droppop';
            }
            if ($fieldinfo && $fieldinfo->getFieldName() != '') {
                //edit:can
                //选择原单
                if (strtolower($fieldinfo->getBigType()??'') == 'selectsource') {
                    $tabid = getTabid($frommodule);
                    crm_load_class_file('cls_OptionModule', 'include/OptionModule');
                    $option_tabid = getTabid($selectmodule);
                    $optionmoduleobj = cls_OptionModule::getInstance($frommodule);
                    $options = $optionmoduleobj->getData();
                    $mobile_pagerecordcount = $options[$tabid][$option_tabid]['maxrowsshow'];

                } else
                    $mobile_pagerecordcount = $fieldinfo->getMaxRowsShow();
                   
                $_REQUEST['fieldname'] = $fieldinfo->getFieldName();//用于页面设置的权限控制

            }
            if(empty($mobile_pagerecordcount)){
                //41273: （曙光计划）附件管理新增界面，相关对象选择单据时，界面加载不出来
                $mobile_pagerecordcount=$tmp_mobile_pagerecord;
            }

            //是否有创建权限
            if($selectmodule=='BudgetChange'||$selectmodule=='QuotesChange'||$selectmodule == 'Checks'||$selectmodule == 'BankAccountSet'||$selectmodule == 'ExpenseBudget'||$selectmodule == 'Reminds'||$selectmodule == 'WeChatUser'){
                $showQuickCreate = 'no';
            } else if(isPermitted($selectmodule,'Create','')=='yes'){
                $showQuickCreate='yes';
            }
//            if ($selectmodule == 'Accounts' && isPermitted('Accounts', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Contacts' && isPermitted('Contacts', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Products' && isPermitted('Products', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Vendors' && isPermitted('Vendors', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'Potentials' && isPermitted('Potentials', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else if ($selectmodule == 'ServiceCharge' && isPermitted('ServiceCharge', 'Create', '') == 'yes') {
//                $showQuickCreate = 'yes';
//            } else {
//                $showQuickCreate = 'yes';
//            }
        }
        // 2020-09-22 diony 签到选择联系人后，快速创建联系人，然后选择客户，再快速创建客户，空白问题。不支持多次快速创建
        if ($_REQUEST['related_pop_type'] && $_REQUEST['related_pop_type'] == 'second_relation') {
            $showQuickCreate = 'no';
        }

        $details = $mobj->get_listdetail($poptype, 'PopQueryGeneratorWX');

        $rh_list = $mobj->getHigheSearchField();//diony 20231009 关联选择增加高级查找
        $details['high_search'] = $rh_list;
        $details['poptitle'] = getFixedLabel('RELATIONAL') . $title;
         crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = new cls_PublicAccounts('Accounts');
        $data = $cls_PublicAccounts->getPublicAccount();

        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicLeads = new cls_PublicLeads('Leads');
        $data_Leads = $cls_PublicLeads->getPublicAccountConfig();
       //edit:can 20210511 45809: （kfbcrm61，企业微信移动端）客户问题（李轩），客户模块不启用公海，拜访签到选择客户界面没有快速创建按钮（需要补丁）
        if($selectmodule=='Accounts'&&$data['status']=='yes'){
            if($showQuickCreate=='yes'&&$data['is_commonaccount_create']=='yes')
                $details['showQuickCreate'] ='yes';
            else
                $details['showQuickCreate'] ='no';
        }
        else if($selectmodule=='Leads'&&$data_Leads['status']=='yes'){
            if($showQuickCreate=='yes'&&$data_Leads['is_commonaccount_create']=='yes')
                $details['showQuickCreate'] ='yes';
            else
                $details['showQuickCreate'] ='no';
        }
        else
            $details['showQuickCreate'] =$showQuickCreate;
        
        //duan 20221123 移动端选择源单时，判断是否允许选择同一客户的单据
        if($_REQUEST['fieldname'] == 'selectlistval' && $_REQUEST['selectrelationfrom'] == 'main'){
            //判断当前模块和选择的模块是否存在客户或者供应商字段
            $from_focus = CRMEntity::getInstance($frommodule);
            $select_focus = CRMEntity::getInstance($selectmodule);
            //需要判断的字段uitype
            $details['judgesourcesame'] = 'no';
            $uitype_arr = array(73,75);
            foreach($uitype_arr as $tmp_uitype){
                $from_fieldinfo=$from_focus->fieldobj->getFieldInfoobjBykey("uitype",$tmp_uitype);
                if(!empty($from_fieldinfo) && $from_fieldinfo->getFieldName() != ''){
                    $select_fieldinfo = $select_focus->fieldobj->getFieldInfoobjBykey("uitype",$tmp_uitype);
                    if(!empty($select_fieldinfo) && $select_fieldinfo->getFieldName() != ''){
                        $details['judgesourcesame'] = 'yes';
                        break;
                    }
                }
            }
        }
        
        // $details['list'] = array(array_shift($details['list']));
        unset($details['list']);// 2020-12-30 diony 关联选择增加筛选
        unset($details['listtab']);
        // 2023-05-11 diony 分录选择产品,去掉提示
        if ($_REQUEST['selectrelationfrom'] == 'entry' && $_REQUEST['selectmodule'] == 'Products'){
            unset($details['pageTip']);
        }
       // $details['pagecount']='123';

        ConvertTojsonString(1, $details, 'success');
    }
}
?>