<?php

/* createdby:gyq_12 */
class cls_DuplicateColumn
{
    private $module;
    private $focus;
    private $focus_contacts;
    private $fieldobj;
    private $fieldobj_contacts;
    private $adb;
    private $current_user;
    public  function __construct($modulename='')
    {
        global $adb,$currentModule,$current_user;
        $this->adb = $adb;
		if(empty($modulename))
			$this->module = $currentModule;
        else
			$this->module = $modulename;
		$this->focus=CRMEntity::getInstance($currentModule);
        $this->fieldobj =$this->focus->fieldobj;
        if(vtlib_isModuleActive('Contacts')){
            $this->focus_contacts = CRMEntity::getInstance('Contacts');
            $this->fieldobj_contacts = $this->focus_contacts->fieldobj;//联系人也加进来
        }
        $this->current_user =$current_user;
        $this->permit='';
        $this->blackcolumnarr=array('accountname','accountid');
    }
    /* 获取查重可用字段下拉框 */
    public function getSelectOption()
    {
        return $this->focus->getSelectOption();
    }
    /*  查重弹框 */
    public function displayTpl(){
        global $languageType,$adb;
        $smarty = new lingdangCRM_Smarty();
        //判断选择查重字段是否包括客户名称，若有进行黑名单分词判断
        $this->judgeBlacklist();
        if (isset($_REQUEST['hyperlink'])) {
//            @edit:liushuai,2021-03-24,reason: 45115: 客户查重功能（显示超链接要保存设置到数据库）
            $sql = "UPDATE ld_systems_deploy SET deploy_value=? WHERE deploy_type = 280";
            $adb->pquery($sql, array($_REQUEST['hyperlink']));
        }else{  //初始弹框根据上次的设置
            $sql = "SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type = 280 LIMIT 1";//查重按钮是否显示超链接(序时簿列表查重没有查询内容)
            $tmp_result = $adb->pquery($sql, array());
            if ($adb->num_rows($tmp_result) > 0) {
                $_REQUEST['hyperlink'] = $adb->query_result($tmp_result, 0, 0);
            } else {
                $_REQUEST['hyperlink'] = 0;
            }

        }

        if (!empty($_REQUEST['search_content'])) {
            if (empty($_REQUEST['select_option_value'])) {
                $_REQUEST['select_option_value'] = 'ld_account|accountname';
                $smarty->assign("FINDCOLUMNNAME",'ld_account|accountname');
            }
            $detail_value = $this->getDuplicate_related_detail();
         //   dump($detail_value);
            if(!empty($detail_value)){
                $detail_values = $detail_value;
            }
        }
        if(isset($_REQUEST['select_option_value'])){
            $smarty->assign("FINDCOLUMNNAME",$_REQUEST['select_option_value']);
        }
         $system_deploy=getSys_deploy(151);
        $deployvalue=$system_deploy['deploy_value'];
        if(!empty($deployvalue))
        {
            $smarty->assign("LIMITCOUNT",$deployvalue);
        }
        $smarty->assign("ISADMIN",is_admin($this->current_user));
        $smarty->assign("SELECTOPTION",$this->getSelectOption());
        $displaySetting_fieldlabel = $this->getDuplicateColumnDisplaySetting(2);//显示字段
        $search_label = $this->getSearchLabel();
		$smarty->assign('SEARCHLABEL',$search_label);
        $smarty->assign('DISPLAYCOLUMNNUMBER',count($displaySetting_fieldlabel));
        $smarty->assign('TABLEHEADER',$displaySetting_fieldlabel);//列头显示。
        $smarty->assign('TABLE_DUPLICATE_VALUE',$detail_values);
		$smarty->assign('MODULE',$this->module);
        $smarty->assign('SEARCH_CONTENT',$_REQUEST['search_content']); //填写查重内容之后，点击立即查重按钮之后，文本框内记住值

        $smarty->assign('hyperlink',$_REQUEST['hyperlink']);
        $smarty->assign('LANGUAGETYPE',$languageType);
		$_REQUEST['diony']='diony';
		$arr['title']=getFixedLabel('ACCOUNTDUPLICATECHECK');
		$str=$smarty->fetch('DuplicateRelatedPopu.tpl');
		$arr['content']=$str;
		ConvertTojsonString(1,$arr,"success");
		exit();
    }
    /* 显示列设置弹框 */
    public function displaySelectTpl(){
        $smarty = new lingdangCRM_Smarty;

        $searchInfo['select_option'] = $this->getOptionContent();//获取设置字段复选框勾选成功的字段值。
        $searchInfo['search_select_option'] = $this->getOptionContent('search');//获取可选的查询字段
        $smarty->assign('actions_arr', $searchInfo['select_option']);
        $smarty->assign('searchfields_arr', $searchInfo['search_select_option']);

        $smarty->assign('actions_arr_userd',$this->getDuplicateColumnDisplaySetting(3));
        $smarty->assign('searchfields_selected_arr',$this->getDuplicateColumnSearchSetting(3));//已选择的可查询字段
		$smarty->assign('MODULE',$_REQUEST['modulename']);
		$_REQUEST['diony']='diony';
		$arr['title']=getFixedLabel('SETDUPFIELD');
		$str=$smarty->fetch('Accounts/setDuplicateColumnDisplay.tpl');
		$arr['content']=$str;
		ConvertTojsonString(1,$arr,"success");
    }

    /* *
    *editor:gyq_12 reason:获取查重弹框列标题已选字段 explain: date:20160531
     * $type:1：表示获取显示列字段名称，2：表示获取显示列标签名称 3:表示获取已选字段option内容
    **/
    /*public function getDuplicateColumnDisplaySetting($type){
        $fieldobj = $this->fieldobj;
        $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();

        if($type == 1) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo=$this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                if(!$fieldinfo)
                {
                    continue;
                }
                 if($fieldinfo->getTableName()=='ld_contactdetails'||$fieldinfo->getTableName()=='ld_contactscf')
                {
                    continue;
                }
                if($fieldinfo)
                    $field_Arr[] =array("columnname"=>$columnname[2],"fieldname"=>$fieldinfo->getFieldName(),
                        "tablename"=>$fieldinfo->getTableName(),"fieldlabel"=>$fieldinfo->getFieldLabelKey());

            }
        }elseif($type == 2){
            foreach($contentArr as $key=>$value){
                $columnname = explode('|',$value);
                $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                if(!$field_column)
                {
                    continue;
                }
                 if($field_column->getTableName()=='ld_contactdetails'||$field_column->getTableName()=='ld_contactscf')
                {
                    continue;
                }
                if($field_column)
                    $field_Arr[] = $field_column->getfieldLabel();
            }
        }elseif($type == 3){
            foreach($contentArr as $key=>$value){
                $columnname = explode('|',$value);
                $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                if(!$field_column)
                {
                    continue;
                }
                if($field_column->getTableName()=='ld_contactdetails'||$field_column->getTableName()=='ld_contactscf')
                {
                    continue;
                }
                if($field_column)
                    $field_Arr[$value] = $field_column->getfieldLabel();
            }
        }
      
        return $field_Arr;
    }*/

    /*
     * 新增需求：客户查重需要添加查重联系人    date:20200629  getOptionContent方法为[设置查重内容显示字段-》可用字段]
     * $type:  1：查重显示列标题字段，2：查重列表的表头字段 3:表示获取已选字段option内容[设置查重内容显示字段-》已选字段]
    * */
    public function getDuplicateColumnDisplaySetting($type){
        $fieldobj = $this->fieldobj;
        $fieldobj_contacts = $this->fieldobj_contacts;
        $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $accountmodule_label = getTranstab("Accounts");
        $contactmodule_label = getTranstab("Contacts");

        if($type == 1) {
            
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == 'Accounts'){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    if(vtlib_isModuleActive('Contacts')){
                        $fieldinfo = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
					if(!$fieldinfo)
					{
						continue;
					}
                    if($fieldinfo->getUIType()==73){
                        continue;
                    }
                }
                if(!$fieldinfo)
                {
                    continue;
                }
                if($columnname[0] == 'Accounts' && ($fieldinfo->getTableName() == 'ld_contactdetails' || $fieldinfo->getTableName() == 'ld_contactscf')) {
                    continue;
                }
                if($fieldinfo)
                    $field_Arr[] =array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->getFieldName(),
                        "tablename"=>$fieldinfo->getTableName(),"fieldlabel"=>$fieldinfo->getFieldLabelKey());

            }
        }elseif($type == 2){
            foreach($contentArr as $key=>$value){
                $columnname = explode('|',$value);
                $field_column = '';
                $modulelabel = $accountmodule_label;    //字段前缀
                if($columnname[0] == 'Accounts'){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    $modulelabel = $contactmodule_label;
                    if(vtlib_isModuleActive('Contacts')){
                        $field_column = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
                    if(!$field_column){
                        continue;
                    }
                    if($field_column->getUIType()==73 ){
                        continue;
                    }
                }

                if(!$field_column)
                {
                    continue;
                }

                if($columnname[0]=='Accounts' && ($field_column->getTableName() == 'ld_contactdetails' || $field_column->getTableName() == 'ld_contactscf')) {
                    continue;
                }
                if($field_column)
                    $field_Arr[] = $field_column->getfieldLabel();//查重列表表头不用自定义前缀
                    //$field_Arr[] = $modulelabel . "_" . $field_column->getfieldLabel();
            }
        }elseif($type == 3) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $field_column = '';
                $modulelabel = $accountmodule_label;    //字段前缀
                if($columnname[0] == 'Accounts'){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    $modulelabel = $contactmodule_label;
                    if(vtlib_isModuleActive('Contacts')){
                        $field_column = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
                    if(!$field_column){
                        continue;
                    }
                    if($field_column->getUIType()==73 )
                    {
                        continue;
                    }
                     if($field_column=='accountid'){
                        continue;
                    }
                }

                if(!$field_column)
                {
                    continue;
                }

                if ($columnname[0]=='Accounts' && ($field_column->getTableName() == 'ld_contactdetails' || $field_column->getTableName() == 'ld_contactscf')) {
                    continue;
                }

                if ($field_column)
                    $field_Arr[$value] = $modulelabel . "_" . $field_column->getfieldLabel();
            }

        }
        return $field_Arr;
    }

    //editor:gyq_80 reason:微信客户查重改进 2018/9/6 18:10
    public function getDuplicateColumnDisplaySetting_in_filter(){
        $option_selected = $this->getDuplicateColumnDisplaySetting(3);
        $j=0;
        foreach ($option_selected as $key=>$value){
            $temp_key = explode('|',$key);
            $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('columnname', $temp_key[2]);
            $columnlist[$j] = $temp_key[1].':'.$temp_key[2].':'.$fieldinfo->fieldName.':'.$temp_key[0].'_'.':V';
            $j++;
        }
        return $columnlist;
    }

    /**
     * 此函数用于获取查重中已选的可查询字段
     * xxy 2023-11-21 XUQIU1001992 客户、服务收费管理、销售机会、产品查重和移动端模块列表查询，设置的查重字段和显示字段分开控制
     * @param $type: 1：每个字段一个数组的格式，2：搜索框显示需要的的label翻译 3:字段信息拼成以 | 为分隔符的字符串    [设置查询字段-》已选字段]
     * @return array
    */
    public function getDuplicateColumnSearchSetting($type){
        $fieldobj = $this->fieldobj;
        $fieldobj_contacts = $this->fieldobj_contacts;
        $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $accountmodule_label = getTranstab("Accounts");
        $contactmodule_label = getTranstab("Contacts");
        
        if($type == 1) {
            
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == 'Accounts'){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    if(vtlib_isModuleActive('Contacts')){
                        $fieldinfo = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
					if(!$fieldinfo)
					{
						continue;
					}
                    if($fieldinfo->getUIType()==73){
                        continue;
                    }
                }
                if(!$fieldinfo)
                {
                    continue;
                }
                if($columnname[0] == 'Accounts' && ($fieldinfo->getTableName() == 'ld_contactdetails' || $fieldinfo->getTableName() == 'ld_contactscf')) {
                    continue;
                }
                if($fieldinfo)
                    $field_Arr[] =array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->getFieldName(),
                        "tablename"=>$fieldinfo->getTableName(),"fieldlabel"=>$fieldinfo->getFieldLabelKey());

            }
        }elseif($type == 2){
            foreach($contentArr as $key=>$value){
                $columnname = explode('|',$value);
                $field_column = '';
                $modulelabel = $accountmodule_label;    //字段前缀
                if($columnname[0] == 'Accounts'){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    $modulelabel = $contactmodule_label;
                    if(vtlib_isModuleActive('Contacts')){
                        $field_column = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
                    if(!$field_column){
                        continue;
                    }
                    if($field_column->getUIType()==73 ){
                        continue;
                    }
                }

                if(!$field_column)
                {
                    continue;
                }

                if($columnname[0]=='Accounts' && ($field_column->getTableName() == 'ld_contactdetails' || $field_column->getTableName() == 'ld_contactscf')) {
                    continue;
                }
                if($field_column)
                    $field_Arr[] = $field_column->getfieldLabel();//查重列表表头不用自定义前缀
                    // $field_Arr[] = $modulelabel . "_" . $field_column->getfieldLabel();
            }
        }elseif($type == 3) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $field_column = '';
                $modulelabel = $accountmodule_label;    //字段前缀
                if($columnname[0] == 'Accounts'){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } elseif ($columnname[0] == 'Contacts'){
                    $modulelabel = $contactmodule_label;
                    if(vtlib_isModuleActive('Contacts')){
                        $field_column = $fieldobj_contacts->getFieldInfoobjBykey('columnname',$columnname[2]);
                    }
                    if(!$field_column){
                        continue;
                    }
                    if($field_column->getUIType()==73 )
                    {
                        continue;
                    }
                     if($field_column=='accountid'){
                        continue;
                    }
                }

                if(!$field_column)
                {
                    continue;
                }

                if ($columnname[0]=='Accounts' && ($field_column->getTableName() == 'ld_contactdetails' || $field_column->getTableName() == 'ld_contactscf')) {
                    continue;
                }

                if ($field_column)
                    $field_Arr[$value] = $modulelabel . "_" . $field_column->getfieldLabel();
            }

        }
        return $field_Arr;
    }
    //移动端客户查重，获取查询字段
    public function getDuplicateColumnSearchSetting_in_filter(){
        $option_selected = $this->getDuplicateColumnSearchSetting(3);
        $j=0;
        foreach ($option_selected as $key=>$value){
            $temp_key = explode('|',$key);
            $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('columnname', $temp_key[2]);
            $columnlist[$j] = $temp_key[1].':'.$temp_key[2].':'.$fieldinfo->fieldName.':'.$temp_key[0].'_'.':V';
            $j++;
        }
        return $columnlist;
    }
    /* editor:gyq_12 reason:客户查重弹框可用字段列表 date:20160531 */
    public function getOptionContent($fieldstype=''){
        global $currentModule;
        if ($fieldstype == 'search'){
            $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        }else{
            $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        }
        $filecontent = ',,'.$filecontent_str.',';

        $fieldmodules=$this->fieldobj->getModuleFields();

        if(vtlib_isModuleActive('Contacts')){
            $fieldmodules_contacts = $this->fieldobj_contacts->getModuleFields();
        }
        $accountmodule_label = getTranstab("Accounts");
        $contactmodule_label = getTranstab("Contacts");
        foreach($fieldmodules as $fieldname=>$fieldinfo)
        {
            if(!$fieldinfo)
            {
                continue;
            }
            if($fieldinfo->getTableName()=='ld_contactdetails'|| $fieldinfo->getTableName()=='ld_contactscf' || $fieldinfo->getTableName() == 'ld_attachments' || $fieldinfo->getColumnName() == 'locationaddress_map')
            {
                continue;
            }
			$uitype = $fieldinfo->getUIType();
			if(in_array($uitype,array(302))){
			 
             //edit:can BUG0075008  20231106 昨天设置可显示字段时 误操作把所属公海去掉了 现在无法显示出来了（kfbcrm通用bug-客户-查重字段设置中找不到“所属公海”字段） 
			//	continue;
			}
            $field_ceil = $currentModule.'|'.$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName();

            if(strpos($filecontent,','.$field_ceil.',') > 0){
                continue;
            }else{
                $selectoption[$field_ceil] = $accountmodule_label.'-'.$fieldinfo->getFieldLabelKey();
            }
        }
        unset($fieldname, $fieldinfo);
        foreach($fieldmodules_contacts as $fieldname=>$fieldinfo)
        {
            if(!$fieldinfo)
            {
                continue;
            }
            if($fieldinfo->getUIType()==73)
            {
                continue;
            }
            if($fieldinfo->getTableName() == 'ld_attachments')
            {
                continue;
            }
            $field_ceil = 'Contacts|'.$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName();

            if(strpos($filecontent,','.$field_ceil.',') > 0){
                continue;
            }else{
                $selectoption[$field_ceil] = $contactmodule_label.'-'.$fieldinfo->getFieldLabelKey();
            }
        }
        return $selectoption;
    }

    /* editor:gyq_12 reason:从文件中获取相应显示列设置 */
    public function getDuplicateColumnDisplayFromFile(){
        global $currentModule;
        $filecontent_now = '';
        $filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php');
        $filecontent_arr = json_decode($filecontent,true);
        $filecontent_now = $filecontent_arr[$this->module];
        if(empty($filecontent_now)){
            $filecontent_now = 'Accounts|ld_account|accountname,Accounts|ld_account|account_no,Accounts|ld_account|createdtime,Accounts|ld_account|smownerid';
        }
        return $filecontent_now;
    }
    //xxy 2023-11-21 从文件中获取查重已选的可查询字段
    public function getDuplicateColumnSearchFromFile(){
        $display_filepath = globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php';
        $search_filepath = globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php';
        $filecontent_now = '';
        //先判断是否存在查询字段的php
        if (!file_exists($search_filepath)) {
            $display_filecontent = file_get_contents($display_filepath);
            $display_filecontent_arr = json_decode($display_filecontent,true);
            $display_filecontent_now = $display_filecontent_arr[$this->module];
            if (!empty($display_filecontent_now)) {//判断是否已有过去显示字段的数据
                copy($display_filepath, $search_filepath);//复制文件，查询字段继承显示字段数据
            }else{
                $filecontent_now = 'Accounts|ld_account|accountname';
                return $filecontent_now;
            }
        }
        $search_filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php');
        $search_filecontent_arr = json_decode($search_filecontent,true);
        $filecontent_now = $search_filecontent_arr[$this->module];
        if(empty($filecontent_now)){
            $filecontent_now = 'Accounts|ld_account|accountname';
        }
        return $filecontent_now;
    }
    /* editor:gyq_12 reason:保存显示列设置 */
    public function saveDuplicateColumnDisplayFromFile($columnstr){
        $fieldids = rtrim($columnstr,',');
        $fieldids_arr_new = explode(',',$fieldids);
		//chj 2021/6/29 46606: （81mis.com/kfbcrm）客户管理-客户-列表处查重，查重结果联系人相关字段没内容，联系人相关字段前置时，后面字段还会覆盖它
		$account_field = [];
		$contact_field = [];
		foreach($fieldids_arr_new as $fieldstr){
			$field_first = explode('|',$fieldstr);
			if($field_first[0] == 'Accounts')
				$account_field[] = $fieldstr;
			if($field_first[0] == 'Contacts')
            {
    			//查重字段不允许出现”联系人-客户名称“
                if($field_first[2]=='accountid')
                {
    			    continue;
    			}
                $contact_field[] = $fieldstr;
            }
		}
		$fieldids = implode(',',$account_field);
		if(!empty($contact_field)){
			$fieldids .= ','.implode(',',$contact_field);
		}
        $field_modulename = $this->module;
        //echo var_dump(chmod(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php',0777)) ;
        //         exit('wwww');
        $fieldids_content = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php');
        $fieldids_arr_old = json_decode($fieldids_content,true);
        $fieldids_arr_old[$field_modulename] = $fieldids;
        $fieldids_arr_old_json = json_encode($fieldids_arr_old);
       
        file_put_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php',$fieldids_arr_old_json);
    }
    //xxy 2023-11-21 保存查询字段
    public function saveDuplicateColumnSearchFromFile($columnstr){
        $fieldids = rtrim($columnstr,',');
        $fieldids_arr_new = explode(',',$fieldids);
        $account_field = [];
        $contact_field = [];
        foreach($fieldids_arr_new as $fieldstr){
            $field_first = explode('|',$fieldstr);
            // if($field_first[0] == 'Accounts')
                $account_field[] = $fieldstr;
            // if($field_first[0] == 'Contacts')
            // {
            //     //查重字段不允许出现”联系人-客户名称“
            //     if($field_first[2]=='accountid')
            //     {
            //         continue;
            //     }
            //     $contact_field[] = $fieldstr;
            // }
        }
        $fieldids = implode(',',$account_field);
        if(!empty($contact_field)){
            $fieldids .= ','.implode(',',$contact_field);
        }
        $field_modulename = $this->module;

        $fieldids_content = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php');
        $fieldids_arr_old = json_decode($fieldids_content,true);
        $fieldids_arr_old[$field_modulename] = $fieldids;
        $fieldids_arr_old_json = json_encode($fieldids_arr_old);
        
        file_put_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php',$fieldids_arr_old_json);
    }
    //xxy 2023-11-21 获取查重输入框中的内容（请输入客户名称....）
    public function getSearchLabel(){
        $searchSetting_fieldlabel = $this->getDuplicateColumnSearchSetting(2);//查询字段
		$i = 0;
		foreach($searchSetting_fieldlabel as $label){
			if($i <= 2){
				$label_arr[] = $label;
			}
			$i++;
		}
		$search_label = getFixedLabel('pleaseenter') . implode('、',$label_arr);
		if(sizeOf($searchSetting_fieldlabel) > 3){
			$search_label .= '......';
		}
        return $search_label;
    }
	public function getQuery(){
		$current_user = $this->current_user;
        include (globalStatic::$root_directory."modules/Accounts/DupSearch_ProductDetails.php");
        include (globalStatic::$root_directory."modules/Accounts/DupSearch_queryGenerator.php");
        $productdetail_obj=new DupSearch_ProductDetails('Accounts');
        $querygenerator=new DupSearch_queryGenerator('Accounts',$current_user,$productdetail_obj,$productdetail_obj);
        $productdetail_obj->getpermission = $this->permit;
        $productdetail_obj->blackcolumnarray=$this->blackcolumnarr;
        $querygenerator->initForCustomViewById(0);

        //2023-08-14:圣拉维查重特殊处理 add by luyx
        $versioninfo = getVersionInfo();
        if($versioninfo['account']=='shenglawei'){
            //zkt 20231123 XUQIU1002214 【圣拉维】客户查重功能开发
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

        $page_list_query = $querygenerator->getQuery('',1);
        $list_query= $querygenerator->getQuery('',2);
        $where=$querygenerator->getWhereClause();    //新增where条件
        $system_deploy=getSys_deploy(151);
        $deployvalue=5;
        if($system_deploy['deploy_value']>0)
             $deployvalue=$system_deploy['deploy_value'];


        if($versioninfo['account']=='shenglawei'){	
			$where=' WHERE 
			(LEFT(ld_accountscf.cf_7533, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7533, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7537, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7537, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7541, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7541, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7545, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7545, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7554, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7554, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) ';
					
			$list_query=$list_query .$where.' order by '.$productdetail_obj->duplicate_orderby.' limit 0,'.$deployvalue;
		}else{
			$list_query=$list_query .'  inner join   ( '.$page_list_query.' order by '.$productdetail_obj->duplicate_orderby.' limit 0,'.$deployvalue.' ) as tmp on tmp.accountid=ld_account.accountid '.$where.' order by '.$productdetail_obj->duplicate_orderby;
        }

        return $list_query;
	}
    /* 获取查询结果序时簿内容 */
    public function getDuplicate_related_detail(){
        $adb = $this->adb;
        //$focus = $this->fieldobj;
        $displaySetting_columnname = $this->getDuplicateColumnDisplaySetting(1);//查重显示列标题字段
		$list_query = $this->getQuery();

        $result=$adb->pquery($list_query);
        $num_rows=$adb->num_rows($result);

        $detail_value = array();
        $account_cols=array();
        $contactrowindex=0;
        if($num_rows>0)
              $before_accountid=$adb->query_result($result,0,'accountid');

        //zkt 20231121 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
        crm_load_class_file("cls_fieldSensitiverule", "include/fields");
        for($i=0;$i<$num_rows;$i++)
        {
            $recordId = $adb->query_result($result,$i,'accountid');
            $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
            $cls_fieldSensitiveruleobj->resetobj($this->module,$recordId);
            $tmp_columnvalue=$adb->query_result_rowdata($result,$i);
            $cls_fieldSensitiveruleobj->setColumnValues($tmp_columnvalue);
            $sensitiveresultinfo = $cls_fieldSensitiveruleobj->getSensitiveResultInfobyColumnname();
            foreach($displaySetting_columnname as $index=>$content)
            {
				$columnanme = $content['columnname'];
				if(trim($content['tablename']) == 'ld_contactdetails' || trim($content['tablename']) == 'ld_contactscf'){
					$columnanme = 'products_' . $columnanme;
				}
                $value=$adb->query_result($result,$i,$columnanme);
                $accountid=$adb->query_result($result,$i,'accountid');
                $contactid=0;
                if($this->module == 'Accounts' &&  in_array($content['tablename'], $this->focus_contacts->tab_name)){
                    //查重-》联系人模块'Contacts'
                    if(vtlib_isModuleActive('Contacts')){
                        $fieldinfo = $this->fieldobj_contacts->getFieldInfoobjBykey('columnname',$content['columnname']);
                    }
                    $showobjvalue=new ShowFieldValue($this->fieldobj,'Accounts',SHOW_POPUP);
                    $showobjvalue->setRecorId($accountid);//uitype 等于123的bug
                    $contactid=$adb->query_result($result,$i,'contactid');
                    //$detail_value[$i][]=$showobjvalue->getFieldValueByField($fieldinfo,$value,$value);
                    $contactvalue=$showobjvalue->getFieldValueByField($fieldinfo,$value,$value);
                    $contactvalue['rowspan']=1;
                    $detail_value[$accountid]['contactdetailinfo'][$contactid][]=$contactvalue;
                    
                }else{
                    //查重-》客户模块'Accounts'
                    $fieldinfo=$this->fieldobj->getFieldInfoobjBykey('columnname',$content['columnname']);
                    $showobjvalue=new ShowFieldValue($this->fieldobj,'Accounts',SHOW_POPUP);
                    $showobjvalue->setRecorId($accountid);//uitype 等于123的bug
                   // $detail_value[$i][]=$showobjvalue->getFieldValueByField($fieldinfo,$value,$value);
                  
                       if(array_key_exists($accountid,$account_cols)&&in_array($columnanme,$account_cols[$accountid]))
                       {
                       }
                       else
                        {
                            $showobjvalue_arr = $showobjvalue->getFieldValueByField($fieldinfo,$value,$value);
                            //zkt 20220512 0051637（https://www.51mis.com/hy/5510/）销售机会中查重，多选框字段中间会出现#
                            if($fieldinfo->uitype==33){
                                if (!empty($showobjvalue_arr['value'])) {
                                    $tmpvalue = trim($value);//24088: （邹钰明反馈）单据列表：多选框字段显示多了一个逗号。
                                    $new_value = explode('|##|', $tmpvalue);
                                    $tmpvalue = implode(',', array_filter($new_value));
                                    $showobjvalue_arr['value']  = $tmpvalue;
                                    $showobjvalue_arr['rawvalue']  = $tmpvalue;
                                }
                            }
//                            @edit:liushuai,2020-12-29,reason:【ID1000783】PC端：客户查重出来的数据“客户名称”字段增加超链接
//                            if ($columnanme == $this->focus->list_link_field) {     //accountname
                            if ($columnanme == 'accountname') {     //accountname
                                if ($_REQUEST['hyperlink'] == '0') {
                                    $showobjvalue_arr['value'] = '<a fieldname="'.$columnanme.'" module="'.$this->module.'" record="'.$accountid.'" href="javascript:;"  onclick="ListLinkClick(ld(this),event)" title="'.$showobjvalue_arr['value'].'">'.$showobjvalue_arr['value'].'</a>';
                                }
                                $detail_value[$accountid][] = $showobjvalue_arr;
                            }else{
                                $detail_value[$accountid][]=$showobjvalue_arr;
                            }
                           $account_cols[$accountid][]=$columnanme;

                            
                        }
                }

                /*if($columnanme == 'accountname' && $_REQUEST['weixin_mark']!=3){
                    $detail_value[$i][$index]['value']= "<a target='_blank' href='index.php?module=Accounts&action=DetailView&record=$accountid'>".$detail_value[$i][$index]['value']."</a>";
                }*/
            }
            
        }
        
       $arr=array();
       $arrindex=0;
     
       foreach($detail_value as $accountid =>$info){
             $tmpinfo=$info;
           
             $tmps=array();
             if(array_key_exists('contactdetailinfo',$tmpinfo))
             {      
                    unset($tmpinfo['contactdetailinfo']);
                    $rowspan=sizeof($info['contactdetailinfo']);
                    foreach($tmpinfo as $tmpvalue){
                        //清空同一个客户的第二行以上的客户信息
                        $tmps[]=array('value'=>'#&&&&&#','rowspan'=>1);
                     }
                     
                     foreach($tmpinfo as $ret=>$retvalue){
                        $tmpinfo[$ret]['rowspan']=$rowspan;
                     }
                   foreach($info['contactdetailinfo'] as $contactid=>$contactinfo){
                    
                    $tmpvalues= array_merge($tmpinfo,$contactinfo);
                    $arr[]=$tmpvalues;
                     $tmpinfo=$tmps;
                  }
             }
             else{
              // dump($tmpinfo);
                foreach($tmpinfo as $tmpvalue){
                       
                        $tmpvalue['rowspan']=1;
                       // $tmpinfo[]=$tmpvalue;
                }
                     
                $arr[]=$tmpinfo;
                
             }
              
             
       }
      
//       dump($detail_value);
    
        return $arr;
    }
    //判断是否有黑名单字段
    public function judgeBlacklist(){
        global $adb;
       // $smarty = new lingdangCRM_Smarty();
        $blacklistexisit=""; 
        $filecontent_string=$this->getDuplicateColumnSearchFromFile();
        //先判断是否选择”客户名称“查重字段
        foreach($this->blackcolumnarr as $tmpval){
            if(strpos($filecontent_string,$tmpval)!==FALSE){
                 $blacklistexisit="yes";
                 break;
            }
        }
        if($blacklistexisit=="yes"){
            $search_content = $_REQUEST['search_content'];
            //zkt 20230921 XUQIU1001606 【广东丰明】客户查重（必须是两个字以上模糊查询，客户查重需要增加敏感字过滤）
            //搜索客户名两个以下字符时不搜索客户名称
            if(mb_strlen($search_content)<2){
                $this->permit='no';
            }
            else{
                //查重设置黑名单
                crm_load_class_file('phpanalysis.class','modules/Users/PHPAnalysis');
                $pa = new PhpAnalysis('utf-8','utf-8',false);
                $analysis_tags = $pa->GetTianYanSearchByKeywords($search_content);
                $analysis_tags_arr = explode(",", $analysis_tags);

                foreach($analysis_tags_arr as $index => $analysis_tagstr)
                {
                    $this->permit="no";
                    //判断输入内容是否有黑名单中的字
                    $sql="SELECT * FROM ld_business_wordslist WHERE wordkey=? AND wordtype='blackkey'";
                    $resulty=$adb->pquery($sql,array($analysis_tagstr));
                    $rows = $adb->num_rows($resulty);
                    if($rows<=0){
                        //出现黑名单外的字停止遍历
                        $this->permit='yes';
                        break;
                    }
                }
            }
        }else{
            return false;
        }
    }

}