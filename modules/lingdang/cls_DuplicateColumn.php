<?php

/* createdby:duan */
class cls_DuplicateColumn
{
    public $module;
    public $focus;
    public $fieldobj;
    public $adb;
    public $current_user;
    public $permit;
    public $blackcolumnarr = [];
    public $hyperlink;
    public $entityInfo;
    public $DisplayjoinCheckDup;
    public $joinCheckDup;

    protected $filecontent_now ;
    protected $listHeaderWidthArr;//列头显示字段和宽度
    protected $listHeaderFieldInfoArr;//列头显示字段fieldinfo
    protected $listHeaderFieldNameArr;//列头显示字段columnname

    public  function __construct($modulename='')
    {
        global $adb,$currentModule,$current_user;
        $this->adb = $adb;
		if(empty($modulename))
			$this->module = $currentModule;
        else
			$this->module = $modulename;
		$this->focus=CRMEntity::getInstance($this->module);
        $this->fieldobj =$this->focus->fieldobj;        
        $this->current_user =$current_user;
        $this->permit='';
        $this->blackcolumnarr=array();
        if($this->module == 'Accounts'){
            if(vtlib_isModuleActive('Contacts')){
                $this->focus_contacts = CRMEntity::getInstance('Contacts');
                $this->fieldobj_contacts = $this->focus_contacts->fieldobj;//联系人也加进来
            }
            $this->blackcolumnarr=array('accountname','accountid');
        }
        if($this->module == 'Potentials'){
            $this->module_Products = 'Products';
            $this->focus_Products=CRMEntity::getInstance($this->module_Products);
            $this->fieldobj_Products =$this->focus_Products->fieldobj;
            $languageType= getLanguageType($current_user);
            crm_load_class_file('ProductToolFields','include/ProductDetails');
            $this->producttoolfields = new ProductToolFields($this->module);
            $this->potentialsdetails = $this->producttoolfields->getModuleProductToolField(getTabid($this->module),$languageType);
        }
    }

    private static $instanceobj;
    public static function getInstance($module){
        if(!empty(self::$instanceobj[$module])){
            return self::$instanceobj[$module];
        }
        if($module=='Accounts') {
            crm_load_class_file("cls_DuplicateColumn_account",'modules/Accounts');
            self::$instanceobj[$module] = new cls_DuplicateColumn_account($module);
        } else if($module=='Potentials') {
            crm_load_class_file("cls_DuplicateColumn_potentials",'modules/Potentials');
            self::$instanceobj[$module] = new cls_DuplicateColumn_potentials($module);
        }else{
            self:: $instanceobj[$module] = new cls_DuplicateColumn($module);
        }
        return self:: $instanceobj[$module];
    }

    /* 获取查重可用字段下拉框 */
    public function getSelectOption()
    {
        $fieldmodules=$this->focus->fieldobj->getModuleFields();
        foreach($fieldmodules as $fieldname=>$fieldinfo)
        {
            if($fieldinfo->getduplicatefield()=='0')
            {
                $selectoption[$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName()] = $fieldinfo->getFieldLabelKey();
            }
        }
        return $selectoption;
    }
    //判断是否有黑名单字段
    public function judgeBlacklist(){
        if($this->module == 'Leads'){
            //销售线索查重增加过滤
            $this->blackcolumnarr = array('accountname','accountid');
            global $adb;
            $blacklistexisit="";
            $filecontent_string=$this->getDuplicateColumnSearchFromFile();
            foreach($this->blackcolumnarr as $tmpval){
                if(strpos($filecontent_string,$tmpval)!==FALSE){
                    $blacklistexisit="yes";
                    break;
                }
            }
            if($blacklistexisit=="yes"){
                $search_content = $_REQUEST['search_content'];
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
    
    /*  查重弹框 */
    public function displayTpl(){
        global $languageType,$adb;
        $smarty = new lingdangCRM_Smarty();
        $this->judgeBlacklist();
        $this->gethyperlink();
        $listModuleArr = [];
        $listModuleArr[] = $this->module;
        $detail_values = [];
        if (!empty($_REQUEST['search_content'])) {
            $detail_value = $this->getDuplicate_related_detail();
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
        $listHeaderWidthArr = $this->getListHeaderWidth();
        $smarty->assign('listHeaderWidth',$listHeaderWidthArr);
        $smarty->assign('listHeaderFieldName',$this->getListHeaderFieldName());
        $smarty->assign('DISPLAYCOLUMNNUMBER',count($displaySetting_fieldlabel));
        $smarty->assign('TABLEHEADER',$displaySetting_fieldlabel);//列头显示。
        $smarty->assign('TABLE_DUPLICATE_VALUE',$detail_values);
		$smarty->assign('MODULE',$this->module);
        $smarty->assign('SEARCH_CONTENT',$_REQUEST['search_content']); //填写查重内容之后，点击立即查重按钮之后，文本框内记住值
        $smarty->assign('hyperlink',$this->hyperlink);
        $smarty->assign('LANGUAGETYPE',$languageType);

        //wym 240412 XQ1000195 销售线索和客户增加一起查重功能，包括新增、导入和还原数据，且支持自定义查重规则（邹晓宇）
        $join_isplaySetting_fieldlabel = [];
        $join_detail_values = [];
        $join_listHeaderWidthArr = [];
        $join_listHeaderFieldNameArr = [];
        $this->getjoinCheckDup();
        if(!empty($this->joinCheckDup) && $this->DisplayjoinCheckDup){
            if($this->joinCheckDup != 'no'){
                $obj=cls_DuplicateColumn::getInstance($this->joinCheckDup);
                $obj->jointcheck = 'yes';//标记下当前对象是关联查找才生成的
                $join_isplaySetting_fieldlabel = $obj->getDuplicateColumnDisplaySetting(2);//显示字段
                if (!empty($_REQUEST['search_content'])) {
                    $obj->gethyperlink();//获取数据超链接字段
                    $join_detail_value = $obj->getDuplicate_related_detail();
                    if(!empty($join_detail_value)){
                        $join_detail_values = $join_detail_value;
                    }
                }
                $join_listHeaderWidthArr = $obj->getListHeaderWidth();
                $join_listHeaderFieldNameArr = $obj->getListHeaderFieldName();
                $smarty->assign('CHECKMODULELABEL',getTranstab($this->joinCheckDup));//联合查重标题
            }
            $listModuleArr[] = $this->joinCheckDup;
            $smarty->assign('JOINMODULE',$this->joinCheckDup);//标题
            $smarty->assign('join_listHeaderWidth',$join_listHeaderWidthArr);
            $smarty->assign('join_listHeaderFieldName',$join_listHeaderFieldNameArr);
            $smarty->assign('joinCheckDup',$this->joinCheckDup);//联合查重参数
            $smarty->assign('MODULELABEL',getTranstab($this->module));//标题
            $smarty->assign('JOIN_TABLEHEADER',$join_isplaySetting_fieldlabel);//列头显示
            $smarty->assign('JOIN_DISPLAYCOLUMNNUMBER',count($join_isplaySetting_fieldlabel));//列头数量
            $smarty->assign('TABLE_DUPLICATE_NUM',count($detail_values));
            $smarty->assign('JOIN_TABLE_DUPLICATE_VALUE',$join_detail_values);//列表数据
            $smarty->assign('JOIN_TABLE_DUPLICATE_NUM',count($join_detail_values));//列表数量
        }
        $smarty->assign('DisplayjoinCheckDup',$this->DisplayjoinCheckDup);//联合查重模块是否开启

		$_REQUEST['diony']='diony';
		$arr['title']=getFixedLabel('ACCOUNTDUPLICATECHECK');
		$str=$smarty->fetch('DuplicateRelatedPopu.tpl');
		$arr['content']=$str;
        $arr['listModule'] = $listModuleArr;
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
    /*
     * 新增需求：销售机会查重需要添加产品分录    date:20200629  getOptionContent方法为[设置查重字段-》可用字段]
     * $type:  1：查重显示列标题字段，2：查重列表的表头字段 3:表示获取已选字段option内容[设置查重字段-》已选字段]
    * */
    public function getDuplicateColumnDisplaySetting($type){
        $fieldobj = $this->fieldobj;
        $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $currentmodule_label = getTranstab($this->module);
        if($type == 1) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == $this->module){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } 
                if(!$fieldinfo)
                {
                    continue;
                }
                if($fieldinfo)
                    $field_Arr[] =array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->getFieldName(),
                        "tablename"=>$fieldinfo->getTableName(),"fieldlabel"=>$fieldinfo->getFieldLabelKey());
            }
            
        }
        elseif($type == 2){
            $fieldinfoArr = [];
            foreach($contentArr as $key=>$value){
                $columnname = explode('|',$value);
                $field_column = '';
                $modulelabel = $currentmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                }
                if(!$field_column)
                {
                    continue;
                }
                if($field_column){
                    $field_Arr[] = $field_column->getfieldLabel();//查重列表表头不用自定义前缀
                    $fieldinfoArr[$columnname[0].':'.$columnname[2]] = $field_column;
                }
//                    $field_Arr[] = $modulelabel . "_" . $field_column->getfieldLabel();
            }
            $this->listHeaderFieldInfoArr = $fieldinfoArr;
            
        }
        elseif($type == 3) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $field_column = '';
                $modulelabel = $currentmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                }
                if(!$field_column)
                {
                    continue;
                }
                if ($field_column)
                    $field_Arr[$value] = $modulelabel . "_" . $field_column->getfieldLabel();
            }

        }
        return $field_Arr;
    }

    ////微信查重改进
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
        $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $currentmodule_label = getTranstab($this->module);
        if($type == 1) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == $this->module){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                } 
                if(!$fieldinfo)
                {
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
                $modulelabel = $currentmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                }
                if(!$field_column)
                {
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
                $modulelabel = $currentmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                }
                if(!$field_column)
                {
                    continue;
                }
                if ($field_column)
                    $field_Arr[$value] = $modulelabel . "_" . $field_column->getfieldLabel();
            }

        }
        return $field_Arr;
    }
    /* 查重弹框可用字段列表*/
    public function getOptionContent($fieldstype=''){
        global $currentModule;
        if ($fieldstype == 'search'){
            $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        }else{
            $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        }
        $filecontent = ',,'.$filecontent_str.',';
        $fieldmodules=$this->fieldobj->getModuleFields();
        $currentmodule_label = getTranstab($this->module);
        foreach($fieldmodules as $fieldname=>$fieldinfo)
        {
            if(!$fieldinfo)
            {
                continue;
            }
            if($fieldinfo->getSaveDataBase()=='no')
                continue;
            if($fieldinfo->getBigType()=='fileattachment')
            {
                continue;
            }
            $field_ceil = $this->module.'|'.$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName();

            if(strpos($filecontent,','.$field_ceil.',') > 0){
                continue;
            }else{
                $selectoption[$field_ceil] = $currentmodule_label.'_'.$fieldinfo->getFieldLabelKey();
            }
        }
        return $selectoption;
    }

    /*从文件中获取相应显示列设置 */
    public function getDuplicateColumnDisplayFromFile(){
        $filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php');
        $filecontent_arr = json_decode($filecontent,true);
        $filecontent_now = $filecontent_arr[$this->module];
        if(empty($filecontent_now)){
            $filecontent_now = $this->getDefultDuplicateDisplayColumnarr();
        }
        return $filecontent_now;
    }
    public function getDefultDuplicateDisplayColumnarr(){
        if($this->module == 'Leads'){
            return 'Leads|ld_leads|accountname,Leads|ld_leads|leads_no,Leads|ld_leads|contactname,Leads|ld_leads|mobile,Leads|ld_leads|leadsource,Leads|ld_leads|smownerid';
        }
        $count = 3;
        $filecontent_now = "";
        foreach($this->focus->column_fields as $key=>$value){
            $filecontent_now .= $this->focus->module_name.'|'.$this->focus->table_name.'|'.$key;
            $count--;
            if($count>0)
            {
                $filecontent_now .=',';
            }
            else
            {
                break;
            }
        }
        return $filecontent_now;
    }
    public function getDefultDuplicateSearchColumnarr(){
        if($this->module == 'Leads'){
            return 'Leads|ld_leads|accountname';
        }
        $filecontent_now = "";
        foreach($this->focus->column_fields as $key=>$value){
            $filecontent_now .= $this->focus->module_name.'|'.$this->focus->table_name.'|'.$key;
            break;
        }
        return $filecontent_now;
    }
    //xxy 2023-11-21 从文件中获取查重已选的可查询字段
    public function getDuplicateColumnSearchFromFile(){
        $display_filepath = globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php';
        $search_filepath = globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php';
        //先判断是否存在查询字段的php
        if (!file_exists($search_filepath)) {
            $display_filecontent = file_get_contents($display_filepath);
            $display_filecontent_arr = json_decode($display_filecontent,true);
            $display_filecontent_now = $display_filecontent_arr[$this->module];
            if (!empty($display_filecontent_now)) {//判断是否已有过去显示字段的数据
                copy($display_filepath, $search_filepath);//复制文件，查询字段继承显示字段数据
            }else{
                $filecontent_now = $this->getDefultDuplicateSearchColumnarr();
                return $filecontent_now;
            }
        }
        $search_filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php');
        $search_filecontent_arr = json_decode($search_filecontent,true);
        $filecontent_now = $search_filecontent_arr[$this->module];
        if(empty($filecontent_now)){
            $filecontent_now = $this->getDefultDuplicateSearchColumnarr();
        }
        return $filecontent_now;
    }
    /*保存显示列设置 */ 
    public function saveDuplicateColumnDisplayFromFile($columnstr){
        $fieldids = rtrim($columnstr,',');
        $fieldids_arr_new = explode(',',$fieldids);
        $field_first = explode('|',$fieldids_arr_new[0]);
        $field_modulename = $this->module;
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
        $field_first = explode('|',$fieldids_arr_new[0]);
        $field_modulename = $this->module;
        $fieldids_content = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php');
        $fieldids_arr_old = json_decode($fieldids_content,true);
        $fieldids_arr_old[$field_modulename] = $fieldids;
        $fieldids_arr_old_json = json_encode($fieldids_arr_old);
       
        file_put_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php',$fieldids_arr_old_json);
    }
    //xxy 2023-11-21 获取查重输入框中的内容（请输入产品名称....）
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
        //wym 240416 查重类文件结构优化
        crm_load_class_file('DupSearch_ProductDetails','modules/lingdang');
        $productdetail_obj=DupSearch_ProductDetails::getInstance($this->module);
        crm_load_class_file('DupSearch_queryGenerator','modules/lingdang');
        $querygenerator=DupSearch_queryGenerator::getInstance($this->module,$current_user,$productdetail_obj,$productdetail_obj);

        $productdetail_obj->getpermission = $this->permit;
        $productdetail_obj->blackcolumnarray=$this->blackcolumnarr;
        $querygenerator->initForCustomViewById(0);
        
        $page_list_query = $querygenerator->getQuery('',1);
        $list_query= $querygenerator->getQuery('',2);
        $where=$querygenerator->getWhereClause(); 
          //新增where条件 
        $system_deploy=getSys_deploy(151);
        $deployvalue=5;
        if($system_deploy['deploy_value']>0)
             $deployvalue=$system_deploy['deploy_value'];
        //销售机会查重增加产品分录字段
        $list_query=$list_query .'  inner join   ( '.$page_list_query.' order by '.$productdetail_obj->duplicate_orderby.' limit 0,'.$deployvalue.' ) as tmp on tmp.'.$this->focus->table_index.'='.$this->focus->table_name.'.'.$this->focus->table_index.' '.$where.' order by '.$productdetail_obj->duplicate_orderby;
        return $list_query;
	}
    /* 获取查询结果序时簿内容 */
    public function getDuplicate_related_detail(){
        global $global_picklist_colors_byvalue;
        $adb = $this->adb;
        //$focus = $this->fieldobj;  
        $displaySetting_columnname = $this->getDuplicateColumnDisplaySetting(1);//查重显示列标题字段
		$list_query = $this->getQuery();
        $result=$adb->pquery($list_query);
        $num_rows=$adb->num_rows($result);
        $detail_value = array();
        $account_cols=array();
        crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
        $picklistobj = new cls_PickList_Ori();
        for($i=0;$i<$num_rows;$i++)
        {
            foreach($displaySetting_columnname as $index=>$content)
            {
                $columnanme = $content['columnname'];
                $value=$adb->query_result($result,$i,$columnanme);
                $currentmoduleid=$adb->query_result($result,$i,$this->focus->table_index);
                $fieldinfo=$this->fieldobj->getFieldInfoobjBykey('columnname',$content['columnname']);
                $showobjvalue=new ShowFieldValue($this->fieldobj,$this->module,SHOW_POPUP);
                $showobjvalue->setRecorId($currentmoduleid);
                
               if(!array_key_exists($currentmoduleid,$account_cols)||!in_array($columnanme,$account_cols[$currentmoduleid]))
                {
                    $showobjvalue_arr = $showobjvalue->getFieldValueByField($fieldinfo,$value,$value);
                    //zkt 20220512 0051637（https://www.51mis.com/hy/5510/）销售机会中查重，多选框字段中间会出现#
                    $uitype = $fieldinfo->uitype;
                    if($uitype==33){
                        if (!empty($showobjvalue_arr['value'])) {
                            $tmpvalue = trim($value);//24088: （邹钰明反馈）单据列表：多选框字段显示多了一个逗号。
                            $new_value = explode('|##|', $tmpvalue);
                            $tmpvalue = implode(',', array_filter($new_value));
                            $showobjvalue_arr['value']  = $tmpvalue;
                            $showobjvalue_arr['rawvalue']  = $tmpvalue;
                        }
                    }else if ($uitype == 15){//下拉框
                        $fieldname = $fieldinfo->getFieldName();
                        $textColor = $global_picklist_colors_byvalue[$fieldname][$value];
                        if (empty($textColor)){
                            $picklistobj->getPickListValues($fieldname,$fieldinfo,'','');
                            $textColor = $global_picklist_colors_byvalue[$fieldname][$value];
                        }
                        if (!empty($textColor)){
                            $tmpvalue = '<a class="ld-fieldbg-common" style="background-color:'.$textColor.';" title="'.$value.'">'.$value.'</a>';
                            $showobjvalue_arr['value']  = $tmpvalue;
                            $showobjvalue_arr['rawvalue']  = $tmpvalue;
                        }
                    }
                    $showobjvalue_arr['uitype'] = $uitype;
                    if ($this->hyperlink  == '0' && $content['fieldname'] == $this->entityInfo['fieldname']) {
                        $showobjvalue_arr['value'] = '<a fieldname="' . $columnanme . '" module="' . $this->module . '" record="' . $currentmoduleid . '" href="javascript:;"  onclick="ListLinkClick(ld(this),event)" title="' . $showobjvalue_arr['value'] . '">' . $showobjvalue_arr['value'] . '</a>';
                    }
                    $detail_value[$currentmoduleid][]=$showobjvalue_arr;
                    $account_cols[$currentmoduleid][]=$columnanme;
                }  
            }   
        }
        unset($picklistobj);
        $arr=array();
        $arrindex=0;
        foreach($detail_value as $potentialid =>$info){
             $tmpinfo=$info; 
             $arr[]=$tmpinfo;    
        }
        return $arr;
    }
    public function gethyperlink()
    {
        global $adb,$current_user;
        //模块超链接显示参数
        $sql='select content from ld_module_setting_byuser where modulename=? and label=? and userid=1';
        $result=$adb->pquery($sql,array($this->module,'DuplicateCheckShowHyperLink'));
        $num_row=$adb->num_rows($result);
        if(isset($_REQUEST['hyperlink'])){
            if($this->jointcheck =='yes'){
                //联合查找时根据当前模块是否开启超链接来显示,不修改另一模块数据
            }else{
                if ($num_row > 0){
                    //查重功能（显示超链接要保存设置到数据库）
                    $updatesql = "UPDATE ld_module_setting_byuser SET content=? WHERE modulename = ? and label=? and userid=1";
                    $adb->pquery($updatesql, array($_REQUEST['hyperlink'],$this->module,'DuplicateCheckShowHyperLink'));
                }else{
                    $insertsql="insert into ld_module_setting_byuser(modulename,userid,label,content)";
                    $insertsql.=" select '".$this->module."',1,'DuplicateCheckShowHyperLink',".$_REQUEST['hyperlink'];
                    $insertsql.=" from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='".$this->module."');";
                    $adb->pquery($insertsql,array());
                }
            }
            $this->hyperlink = $_REQUEST['hyperlink'];
        }else{
            $serachsql = "SELECT content FROM ld_module_setting_byuser WHERE modulename = ? and label=? and userid=1 LIMIT 1";//查重按钮是否显示超链接(序时簿列表查重没有查询内容)
            $serachresult = $adb->pquery($serachsql, array($this->module,'DuplicateCheckShowHyperLink'));
            if ($adb->num_rows($serachresult) > 0){
                $this->hyperlink = $adb->query_result($serachresult, 0, 'content');
            }else{
                $this->hyperlink = 0;
            }
        }
        if ($this->hyperlink == '0'){
            $entitysql = 'select * from ld_entityname where modulename = ?';
            $result = $adb->pquery($entitysql,array($this->module));
            if ($adb->num_rows($result)> 0){
                $this->entityInfo = $adb->query_result_all($result)[0];
            }
        }
    }
    // 联合查重参数
    public function getjoinCheckDup()
    {
        //wym 240412 XQ1000195 销售线索和客户增加一起查重功能，包括新增、导入和还原数据，且支持自定义查重规则（邹晓宇）
        $this->DisplayjoinCheckDup=vtlib_isModuleActive('Accounts');
        if (isset($_REQUEST['joinCheckDup'])) {
            $this->joinCheckDup=$_REQUEST['joinCheckDup'];
            if($_REQUEST['joinCheckDup']=='yes'){
                $this->joinCheckDup='Accounts';//yes时数据库存值查重模块,no时存为no
            }
            setUsersettingByLabel($this->module,'1','JointCheckDuplicate',$this->joinCheckDup);
        }else{
            $this->joinCheckDup=getUsersettingByLabel($this->module,'1','JointCheckDuplicate');
            if(empty($this->joinCheckDup)){
                $this->joinCheckDup = 'no'; //默认值为不开启联合查重
            }
        }
    }

    //获取列头宽度
    public function getListHeaderWidth(){
        if (is_array($this->listHeaderWidthArr) && sizeof($this->listHeaderWidthArr) > 0){
            return $this->listHeaderWidthArr;
        }
        $listHeaderFieldinfoArr = $this->getListHeaderFieldInfo();
        $listHeaderWidthArr = [];
        $listHeaderFieldNameArr = [];
        $list_header_width_arr = getCvColumnListWidth($this->module,'duplicatePopup',0);
        crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
        foreach ($listHeaderFieldinfoArr as $columns => $fieldinfo){
            $columns_arr = explode(':',$columns);
            $module = $columns_arr[0];
            $columnname = $columns_arr[1];
            if (empty($fieldinfo)){
                $listHeaderWidthArr[$columnname] = 1;
                continue;
            }
            $tablename = $fieldinfo->getTableName();
            $fieldname = $fieldinfo->getFieldName();
            $columns = $tablename.':'.$columnname.':'.$fieldname.':'.$module;
            if (isset($list_header_width_arr[$columns]) && !empty($list_header_width_arr[$columns])){
                $listHeaderWidthArr[$columnname] = $list_header_width_arr[$columns] . 'setting';;
            }else{
                $uitype = $fieldinfo->getUIType();
                $listHeaderWidthArr[$columnname] = getModuleFieldProportion($uitype);
            }
            $listHeaderFieldNameArr[] = array('fieldname'=>$fieldname,'module'=>$module);
        }
        $this->listHeaderFieldNameArr = $listHeaderFieldNameArr;
        $this->listHeaderWidthArr = getModuleWidth($this->focus,$listHeaderWidthArr,$this->module);
        unset($listHeaderWidthArr,$listHeaderFieldinfoArr,$list_header_width_arr,$listHeaderFieldNameArr);
        return $this->listHeaderWidthArr;
    }

    public function getListHeaderFieldInfo(){
        if (is_array($this->listHeaderFieldInfoArr) && sizeof($this->listHeaderFieldInfoArr) > 0){
            return $this->listHeaderFieldInfoArr;
        }else{
            $this->getDuplicateColumnDisplaySetting(2);
            return $this->listHeaderFieldInfoArr;
        }
    }

    public function getListHeaderFieldName(){
        if (is_array($this->listHeaderFieldNameArr)){
            return $this->listHeaderFieldNameArr;
        }
        $listHeaderFieldinfoArr = $this->getListHeaderFieldInfo();
        $listHeaderFieldNameArr = [];
        foreach ($listHeaderFieldinfoArr as $columns => $fieldinfo){
            $columns_arr = explode(':',$columns);
            $module = $columns_arr[0];
            $listHeaderFieldNameArr[] = array('fieldname'=>$fieldinfo->getFieldName(),'module'=>$module);
        }
        $this->listHeaderFieldNameArr = $listHeaderFieldNameArr;
        unset($listHeaderFieldNameArr);
        return $this->listHeaderFieldNameArr;
    }


}