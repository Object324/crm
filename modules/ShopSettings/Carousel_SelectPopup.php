<?php
/**
 * 产品明细HTML
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
crm_load_class_file('SelectRelatedPopu','include/SelectRelatedPopu');

Class Carousel_SelectPopup extends  SelectRelatedPopu
{

    function __construct($selectmodule, $adb)
    {
        global $current_user, $theme, $weixin_user;
        $this->selectmodule = $selectmodule;
        $this->focus = CRMEntity::getInstance($selectmodule);
        //editor:gyq_129 reason:分割构造方法，方便移动端调用  2019/7/25 17:27 ID1000529
        if (!$weixin_user->environment_weixin) {
            $languageType = getLanguageType($current_user);
            //特殊模块 - 查询字段
            //$this->specialModuleSearchField = array('SalesOrder' => array('salesorder_no', 'subject', 'account_id'), 'ServiceContracts' => array('contract_no', 'subject', 'account_id'));
            //特殊模块 - 列表字段//21576: 新增项目界面：源单选择【服务合同】时，【服务合同】弹出层界面字段排列出现问题
         //存入数据库，以后尽量不要特殊判断
          //  $this->specialModuleListField = array(
              //  'SalesOrder' => array('salesorder_no', 'subject', 'accountid', 'signed_data', 'total', 'sostatus', 'smownerid'),
             //   'ServiceContracts' => array('subject', 'contract_no', 'contract_status', 'total', 'accountid', 'smownerid', 'due_date')
          //  );
            //审批模块
            //ecdit:can 2020-11-03 客户选择查看范围为高级查询内容为空，然后合同订单新增界面选择客户为空
            $_REQUEST['SearchScope']='SmOwner_Search_All';
            $this->approveModules = array('Contacts', 'Accounts', 'Users', 'ContactRecords', 'Vendors', 'VendorContact', 'VendorContactRecords');
            $this->db = $adb;
            $this->field_obj = Field::getInstance($selectmodule, $this->db);
            $this->setRelatedHeader();
            $this->setRelatedSearchFields();
            $this->setRelatedFieldDateType();
            $this->createCustomView();
            $this->list_query = $this->setRelatedPopopSql();
         
            $this->setSearchEntries();
        }
    }

    private function createCustomView()
    {

        $this->popupProductDetails = crm_load_class_obj("PopupProductDetails", 'include/ProductDetails', array($this->selectmodule));
        $this->customView = $this->popupProductDetails;//new PopupCustomView($selectmodule);
    }
    public function setRelatedPopopSql()
    {
        global $current_user;
    
        $frommodule = $_REQUEST['frommodule'];
        $fromfocus = CRMEntity::getInstance($frommodule);
        $fieldname = $_REQUEST['fieldname'];
        $selectmodule = $_REQUEST['selectmodule'];
        if ($_REQUEST['maxrowsshow'] > 0) {
            $maxrowsshow = $_REQUEST['maxrowsshow'];//控制面板页面设置，设置默认值
            $approvedemand = $_REQUEST['approvedemand'];//审批要求


            if ($approvedemand == 1)//已批准
            {
                $tablename = $this->focus->table_name;
                $wheretable = ' and ifnull( ' . $tablename . ".approvestatus,'')='" . constant('D_A_S_APPROVED') . "' ";
            }
        } else {
            $wheretable = $this->approveModuleSql();
            
			//39343: (http://kehu001.com/weixin/kh34072/ [^])页面设置>项目立项>编辑“选择源单”字段>“服务合同” 最多显示数据条数为“50”条：项目模块新建单据界面，选择“服务合同”序列簿显示条数未按参数控制
			if($frommodule=='Project'&&($this->selectmodule=='ServiceContracts'||$this->selectmodule=='SalesOrder'))
            {
                $fieldname='salesorder_id';
            }
            if (!empty($fieldname)) {
                if ($_REQUEST['selectrelationfrom'] == 'entry') {
                    $fieldinfo = $fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname", $fieldname);
                } else
                    $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
				if(!empty($fieldinfo)){
					if (strtolower($fieldinfo->getBigType()??'') == 'selectsource') {
						crm_load_class_file('cls_OptionModule', 'include/OptionModule');
						$optionmoduleobj = cls_OptionModule::getInstance($frommodule);
						$options = $optionmoduleobj->getData();
						$tabid = getTabid($frommodule);
						$option_tabid = getTabid($selectmodule);
						$maxrowsshow = $options[$tabid][$option_tabid]['maxrowsshow'];
					} else
						$maxrowsshow = $fieldinfo->getMaxRowsShow();//获取最大显示行数
				}else{
					$maxrowsshow = 5;
				}
            } else {
                $maxrowsshow = 5;
            }
        }
        $key_where_mu = $this->related_key_where($_REQUEST['keyids'], $maxrowsshow);
        $keywhere = $key_where_mu['keywhere'];
        $limit_sql = $key_where_mu['limit'];
       
        $relatecreateconditionobj=cls_RelateCreateCondition::getInstance($selectmodule,$frommodule);
    
        $columnvalues=ldcrm_json_decode($_REQUEST['requestvalues']);
   
        $relatecreateconditioninfos=  $relatecreateconditionobj->getChooseDataWhere($columnvalues);
        
        $keywhere .= $this->specialWhere();
        $tablename = $this->focus->fieldobj->getFieldInfoBykeyValue('columnname', $this->focus->list_link_field, 'tablename');
         
        //$orderby = ' order by convert('.$tablename.'.'.$this->focus->list_link_field.' using gbk) DESC,'.$this->focus->table_name.'.createdtime DESC ';
        //@edit:luyx @date:2021-05-06 @reason: 恒银、泰开 客户名称前面几个字一模一样的有几百个，搜素显示不出来
        if($this->selectmodule=='Accounts' && $_REQUEST['keywords'] != ''){
            $orderby = ' order by FIELD(ld_account.accountname,"'.$_REQUEST['keywords'].'") DESC, ld_account.createdtime DESC';
        }else{
            $orderby = ' order by ' . $this->focus->table_name . '.createdtime DESC ';
        }
        
		//chj 2020/12/30 44047: (本地php72，8.3.6)客户管理-客户-旧公海（需要补丁）；在公海已分配界面，点击跟进，创建跟进记录保存后；点击管理分类，弹出层显示的是“全部（含所有公海）”的数据分类
        if($this->selectmodule=='Accounts' && $_REQUEST['relatedcreate'] !='yes')
        {
                //快速查询
           setSearchAllAccount();//设置查询所有的客户（包括公海客户）
        }
        if($this->selectmodule=='ServiceCharge'){
            $queryGenerator =new QueryGenerator($this->selectmodule,$current_user,$this->customView);
        }
        else
            $queryGenerator = QueryGenerator::getInstance($this->selectmodule, $current_user, $this->customView, $this->popupProductDetails);
        $queryGenerator->initForCustomViewById(0);
      
        foreach($relatecreateconditioninfos['tables'] as $tmptable=>$leftjoin)
        {
            $queryGenerator->whereFieldTables[$tmptable]=$leftjoin;
        }
        
        //edit:duan 东贸:新建活动参与记录(customform98)时，选择活动(customform99)后，选择客户(ServiceCharge)时受活动的客户范围限制
        $VersionInfo = getVersionInfo();        
        if ($_REQUEST['selectmodule'] == 'ServiceCharge' && $_REQUEST['frommodule'] == 'CustomForm98' && $VersionInfo['account'] == 'dongmao') {	
            global $adb;
            $request_value_json = $_REQUEST['requestvalues'];
            $request_value = json_decode($request_value_json,true);
            $customform99id = $request_value['customform99_id'];
            if($customform99id>0){
                //获取客户范围条件
                $sql = 'SELECT advft_criteria,advft_criteria_groups from ld_customform99 where customform99id = ? and deleted = 0';
                $result = $adb->pquery($sql,array($customform99id));
                $advft_criteria = $adb->query_result($result,0,'advft_criteria');   
                $advft_criteria_groups = $adb->query_result($result,0,'advft_criteria_groups');
                $input['advft_criteria']=$advft_criteria;
                $input['advft_criteria_groups']=$advft_criteria_groups;
                $input['searchtype']='advance';
                //调用查询条件增加方法
                crm_load_class_file("ProductDetails",'include/ProductDetails');
                $queryGenerator->productDetails=ProductDetails::getInstance($_REQUEST['selectmodule']);
                $queryGenerator->productDetails->querygenerator=$this;
                $queryGenerator->addUserSearchConditions($input);
            }
		}
       
        $this->querygeneratoryobj=$queryGenerator;
        $list_query = $queryGenerator->getQuery('droppop', 2);

		//@edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮 (把条件拼接到sql语句中)
        $advanceDemandSql_res = $this->advanceDemandSql();
        if(isset($_REQUEST['Carousel_productstatus'])&&$_REQUEST['Carousel_productstatus']=='true'){
            //添加条件商品状态为“上架”字段
            $queryGenerator->addCondition('productstatus', constant('PUTON_SHELF'), 'e','ld_shop_productproperty');
        }
        
        $wheretable .= $advanceDemandSql_res['wheretable'];
        if ($_REQUEST['keywords'] == '' && $advanceDemandSql_res['wheretable'] != '') { //只在第一次点击+号（没有搜索条件），且在页面设置设置了其他条件时才使用该对象
            $page_list_query = $advanceDemandSql_res['page_list_query'];
        }else{
            //@edit:can,2020-11-26,reason: 0043441: 付款单，新建界面选择“合同订单”弹出层中数据显示为空（需要补丁）
            //chj 2020/12/17 43627: 易冲（http://171.221.206.240:88/crm/ [^]）CPSCPS 这个账号，创建样品申请单时，填写申请人公司，关联信息可以带出勤基，点击+进入查找界面，带不出。
            $page_list_query = $queryGenerator->getQuery('droppop', 1) . $keywhere;
        }

        
        $page_list_query.=' '.$relatecreateconditioninfos['where'];

         //edit:can 2020-10-19 42930: (61mis.com/kfbcrm)系统设置-页面设置-合同订单-客户名称；在系统设置-页面设置-合同订单-客户名称字段，设置筛选条件后，在合同订单模块，新建订单，不符合条件的客户不显示；但在客户模块，不符合条件的客户却可以新建订单。
         if(empty($this->page_list_query))
            $this->page_list_query=$page_list_query.$wheretable;
    
        $list_query .= ' inner join ( ' . $page_list_query . $wheretable . $orderby . $limit_sql . ' ) as tmp on tmp.' . $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index . $orderby;
        //echo $list_query;echo '<br><br>';die;
        unset($_REQUEST['publicaccount_whethershow']);
        return $list_query;
        
    }
    //关联单据 其他条件的过滤设置sql
    public function advanceDemandSql()
    {
        global $adb,$current_user,$currentModule;
        $page_list_query = '';
        $wheretable = '';
        $frommodule = $_REQUEST['frommodule'];
       
        $fieldname = $_REQUEST['fieldname'];
        $tabid = getTabid($frommodule);
        if ($tabid > 0) {
            $query = "SELECT * FROM ld_field WHERE tabid=? AND fieldname=? AND displaytype=1 LIMIT 1";//displaytype 1 新增编辑界面显示   2 不显示
            $result = $adb->pquery($query,array($tabid, $fieldname));
            $rows = $adb->num_rows($result);
         
            if($rows > 0){
                $advance_demand = $adb->query_result($result,0,'advance_demand');
                $advance_demand_groups = $adb->query_result($result,0,'advance_demand_groups');
                
                if ($advance_demand && $advance_demand != '[]') {
//                    $advft_criteria_groups = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
                $advance_demand_group_arr=json_decode($advance_demand_groups,true);
				$advance_demand_group_arr[sizeof($advance_demand_group_arr)-1]['groupcondition']='';
				$advance_demand_groups=json_encode($advance_demand_group_arr);
                    $customView = new CustomView($this->selectmodule);
                    $queryGenerator =QueryGenerator::getInstance($this->selectmodule, $current_user,$this->customView);

                    $_REQUEST['advft_criteria'] = $advance_demand;
                    $_REQUEST['advft_criteria_groups'] = $advance_demand_groups; //  ''
                    $_REQUEST['searchtype'] = 'advance';
                   // $_REQUEST['search_type'] = 'false';

                    $queryGenerator->addUserSearchConditions($_REQUEST);
                    $page_list_query = $queryGenerator->getQuery('droppop', 1);
                    $where = $queryGenerator->getConditionalWhere();
                      
                    if ($where)
                        $wheretable = ' and '.$where;
                }
            }

        }
        return array('wheretable'=>$wheretable,'page_list_query'=>$page_list_query);
    }
}

?>