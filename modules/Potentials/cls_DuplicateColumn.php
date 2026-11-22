<?php

/* createdby:duan */
class cls_DuplicateColumn
{
    private $module;
    private $module_Products;
    private $focus;
    private $focus_Products;
    private $fieldobj;
    private $fieldobj_Products;
    private $adb;
    private $current_user;
    private $producttoolfields;
    private $potentialsdetails;
    public  function __construct($modulename='')
    {
        global $adb,$currentModule,$current_user;
        $this->adb = $adb;
		if(empty($modulename))
			$this->module = $currentModule;
        else
			$this->module = $modulename;
        $this->module_Products = 'Products';
		$this->focus=CRMEntity::getInstance($currentModule);
        $this->fieldobj =$this->focus->fieldobj;
        
        $this->focus_Products=CRMEntity::getInstance($this->module_Products);
        $this->fieldobj_Products =$this->focus_Products->fieldobj;
        $languageType= getLanguageType($current_user);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->producttoolfields = new ProductToolFields($this->module);
        $this->potentialsdetails = $this->producttoolfields->getModuleProductToolField(getTabid($this->module),$languageType);
        $this->current_user =$current_user;    
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
        if (isset($_REQUEST['hyperlink'])) {
        //查重功能（显示超链接要保存设置到数据库）
            $sql = "UPDATE ld_systems_deploy SET deploy_value=? WHERE deploy_type = 326";
            $adb->pquery($sql, array($_REQUEST['hyperlink']));
            $this->hyperlink = $_REQUEST['hyperlink'];
        }else{  //初始弹框根据上次的设置
            $sql = "SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type = 326 LIMIT 1";//查重按钮是否显示超链接(序时簿列表查重没有查询内容)
            $tmp_result = $adb->pquery($sql, array());
            if ($adb->num_rows($tmp_result) > 0) {
                $this->hyperlink = $adb->query_result($tmp_result, 0, 0);
            } else {
                $this->hyperlink = 0;
            }

        }

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
        $displaySetting_fieldlabel = $this->getDuplicateColumnDisplaySetting(2);
		$search_label = $this->getSearchLabel();
		$smarty->assign('SEARCHLABEL',$search_label);
        $smarty->assign('DISPLAYCOLUMNNUMBER',count($displaySetting_fieldlabel));
        $smarty->assign('TABLEHEADER',$displaySetting_fieldlabel);//列头显示。
        $smarty->assign('TABLE_DUPLICATE_VALUE',$detail_values);
		$smarty->assign('MODULE',$this->module);
        $smarty->assign('SEARCH_CONTENT',$_REQUEST['search_content']); //填写查重内容之后，点击立即查重按钮之后，文本框内记住值
        $smarty->assign('hyperlink',$this->hyperlink);
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
    /*
     * 新增需求：销售机会查重需要添加产品分录    date:20200629  getOptionContent方法为[设置查重字段-》可用字段]
     * $type:  1：查重显示列标题字段，2：查重列表的表头字段 3:表示获取已选字段option内容[设置查重字段-》已选字段]
    * */
    public function getDuplicateColumnDisplaySetting($type){
        $fieldobj = $this->fieldobj;
        $fieldobj_Products = $this->fieldobj_Products;
        $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $Potentialsmodule_label = getTranstab($this->module);
        $Productsmodule_label= getTranstab($this->module_Products);
        if($type == 1) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == $this->module){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->columnName,
                        "tablename"=>$fieldinfo->tableName,"fieldlabel"=>$fieldinfo->fieldLableKey);
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    if($columnname[1] = 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->columnName,
                        "tablename"=>$fieldinfo->tableName,"fieldlabel"=>$fieldinfo->fieldLableKey);
                        continue;
                    }
                    else
                        $fieldinfo = $this->fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);                 
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
                $modulelabel = $Potentialsmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=$fieldinfo->fieldLableKey;
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    if($columnname[1] == 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=$fieldinfo->fieldLableKey;
                        continue;
                    }else
                        $field_column = $fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);
                  
                }
                
                if(!$field_column)
                {
					//chj 2021/8/12 47450: （http://crm.landleaf-tech.com:9999/crm [^]）客户问题（邹晓钰），原“销售机会”模块，点击列表界面的【查重】按钮界面一直显示加载中
                    //dump($columnname[2]);
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
                $modulelabel = $Potentialsmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[$value] = $Productsmodule_label . "_" . $fieldinfo->fieldLableKey;
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    $modulelabel = $Productsmodule_label;
                    if($columnname[1] = 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[$value] = $modulelabel . "_" . $fieldinfo->fieldLableKey;
                        continue;
                    }
                    else
                    $field_column = $fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);
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
        $fieldobj_Products = $this->fieldobj_Products;
        $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        
        $contentArr = explode(',',$filecontent_str);
        $field_Arr = array();
        $Potentialsmodule_label = getTranstab($this->module);
        $Productsmodule_label= getTranstab($this->module_Products);
        if($type == 1) {
            foreach ($contentArr as $key => $value) {
                $columnname = explode('|', $value);
                $fieldinfo = '';
                if($columnname[0] == $this->module){
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->columnName,
                        "tablename"=>$fieldinfo->tableName,"fieldlabel"=>$fieldinfo->fieldLableKey);
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    if($columnname[1] = 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=array("module"=>$columnname[0],"columnname"=>$columnname[2],"fieldname"=>$fieldinfo->columnName,
                        "tablename"=>$fieldinfo->tableName,"fieldlabel"=>$fieldinfo->fieldLableKey);
                        continue;
                    }
                    else
                        $fieldinfo = $this->fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);                 
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
                $modulelabel = $Potentialsmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=$fieldinfo->fieldLableKey;
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    if($columnname[1] == 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[]=$fieldinfo->fieldLableKey;
                        continue;
                    }else
                        $field_column = $fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);
                  
                }
                
                if(!$field_column)
                {
					//chj 2021/8/12 47450: （http://crm.landleaf-tech.com:9999/crm [^]）客户问题（邹晓钰），原“销售机会”模块，点击列表界面的【查重】按钮界面一直显示加载中
                    //dump($columnname[2]);
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
                $modulelabel = $Potentialsmodule_label;    //字段前缀
                if($columnname[0] == $this->module){
                    $field_column = $fieldobj->getFieldInfoobjBykey('columnname',$columnname[2]);
                    if($columnname[2]=='total' ||$columnname[2]=='subtotal')
                    {
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[$value] = $Productsmodule_label . "_" . $fieldinfo->fieldLableKey;
                        continue;
                    }
                } elseif ($columnname[0] == $this->module_Products){
                    $modulelabel = $Productsmodule_label;
                    if($columnname[1] = 'ld_potentialsdetail'||$columnname[1] = 'ld_potentialsdetailscf'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$columnname[2]);
                        $field_Arr[$value] = $modulelabel . "_" . $fieldinfo->fieldLableKey;
                        continue;
                    }
                    else
                    $field_column = $fieldobj_Products->getFieldInfoobjBykey('columnname',$columnname[2]);
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
        if ($fieldstype == 'search'){
            $filecontent_str = $this->getDuplicateColumnSearchFromFile();
        }else{
            $filecontent_str = $this->getDuplicateColumnDisplayFromFile();
        }
        $filecontent = ',,'.$filecontent_str.',';
        $fieldmodules=$this->fieldobj->getModuleFields();
        $potentialsdetails = $this->potentialsdetails;
        $potentialmodule_label = getTranstab($this->module);
        $Productsmodule_label= getTranstab($this->module_Products);
        foreach($fieldmodules as $fieldname=>$fieldinfo)
        {
            if(!$fieldinfo || $fieldinfo->getColumnName()=='filename')
            {
                continue;
            }
            $field_ceil = $this->module.'|'.$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName();   
            if(strpos($filecontent,','.$field_ceil.',') > 0){
                continue;
            }else{
                $selectoption[$field_ceil] = $potentialmodule_label.'_'.$fieldinfo->getFieldLabelKey();
            }
        }
        unset($fieldname, $fieldinfo);
        $system_deploy=getSys_deploy(205);
        if($system_deploy['deploy_value']==0){
            foreach($potentialsdetails as $fieldname=>$fieldinfo)
            {
                if(!$fieldinfo)
                {
                    continue;
                }
                if($fieldinfo->tableName==$this->focus->table_name)
                {
                    $field_ceil = $this->module.'|'.$fieldinfo->tableName.'|'.$fieldinfo->columnName;
                }else
                {
                    $field_ceil = $this->module_Products.'|'.$fieldinfo->tableName.'|'.$fieldinfo->columnName;
                }
                
        
                if(strpos($filecontent,','.$field_ceil.',') > 0){
                    continue;
                }else{
                    $selectoption[$field_ceil] = $Productsmodule_label.'_'.$fieldinfo->fieldLableKey;
                }
            }
        }
        return $selectoption;
    }

    /*从文件中获取相应显示列设置 */
    public function getDuplicateColumnDisplayFromFile(){
        global $currentModule;
        $filecontent_now = '';
        $filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php');
        $filecontent_arr = json_decode($filecontent,true);
        $filecontent_now = $filecontent_arr[$currentModule];
        $contentArr = explode(',',$filecontent_now);
        
        foreach($contentArr as $value)//产品分录未启用时不显示对应字段
        {
            $columname = explode('|',$value);
            $system_deploy=getSys_deploy(205);
            if($system_deploy['deploy_value']==1 && $columname[0]=='Products'){
                continue;
            }
            $contentArr_new[]=$value;
        }
        $filecontent_new = implode(',',$contentArr_new);
        
        if(empty($filecontent_new)){
            $filecontent_new = 'Potentials|ld_potential|potentialid,Potentials|ld_potential|potentialname,Potentials|ld_potential|potential_no,Potentials|ld_potential|sales_stage,Potentials|ld_potential|smownerid';
        }
        return $filecontent_new;
    }
    //xxy 2023-11-21 从文件中获取查重已选的可查询字段
    public function getDuplicateColumnSearchFromFile(){
        global $currentModule;
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
                $filecontent_new = 'Potentials|ld_potential|potentialid,Potentials|ld_potential|potentialname,Potentials|ld_potential|potential_no,Potentials|ld_potential|sales_stage,Potentials|ld_potential|smownerid';
                return $filecontent_now;
            }
        }
        $search_filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnSearch.php');
        $search_filecontent_arr = json_decode($search_filecontent,true);
        $filecontent_now = $search_filecontent_arr[$this->module];
        $contentArr = explode(',',$filecontent_now);
        foreach($contentArr as $value)//产品分录未启用时不显示对应字段
        {
            $columname = explode('|',$value);
            $system_deploy=getSys_deploy(205);
            if($system_deploy['deploy_value']==1 && $columname[0]=='Products'){
                continue;
            }
            $contentArr_new[]=$value;
        }
        $filecontent_new = implode(',',$contentArr_new);
        
        if(empty($filecontent_new)){
            $filecontent_now = 'Potentials|ld_potential|potentialid,Potentials|ld_potential|potentialname,Potentials|ld_potential|potential_no,Potentials|ld_potential|sales_stage,Potentials|ld_potential|smownerid';
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
    //xxy 2023-11-21 获取查重输入框中的内容（请输入机会名称....）
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
        include (globalStatic::$root_directory."modules/Potentials/DupSearch_ProductDetails.php");
        include (globalStatic::$root_directory."modules/Potentials/DupSearch_queryGenerator.php");
        $productdetail_obj=new DupSearch_ProductDetails($this->module);

        $querygenerator=new DupSearch_queryGenerator($this->module,$current_user,$productdetail_obj,$productdetail_obj);

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
        $list_query=$list_query .'  inner join   ( '.$page_list_query.' order by '.$productdetail_obj->duplicate_orderby.' limit 0,'.$deployvalue.' ) as tmp on tmp.potentialid=ld_potential.potentialid '.$where.' order by '.$productdetail_obj->duplicate_orderby;

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
        for($i=0;$i<$num_rows;$i++)
        {
            
            foreach($displaySetting_columnname as $index=>$content)
            {
                $columnanme = $content['columnname'];
                $tablename = $content['tablename'];
                $value=$adb->query_result($result,$i,$columnanme);
                $potentialid=$adb->query_result($result,$i,'potentialid');
                if($content['module']==$this->module_Products){
                    if($tablename='ld_potentialsdetail'||$tablename='ld_potentialsdetailscf'){
                        crm_load_class_file('showProductDetailFieldValue','include/fields');
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$content['columnname']);
                        $showobjvalue=new showProductDetailFieldValue($this->producttoolfields,$this->module_Products,SHOW_POPUP);
                    }else{
                        $fieldinfo=$this->fieldobj_Products->getFieldInfoobjBykey('columnname',$content['columnname']);
                        $showobjvalue=new ShowFieldValue($this->fieldobj_Products,$this->module_Products,SHOW_POPUP);
                    }
                    
                }
                else{
                    if($columnanme=='total'||$columnanme=='subtotal'){
                        $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$content['columnname']);
                        $showobjvalue=new ShowFieldValue($this->producttoolfields,$this->module,SHOW_POPUP);
                    }else{
                        $fieldinfo=$this->fieldobj->getFieldInfoobjBykey('columnname',$content['columnname']);
                        $showobjvalue=new ShowFieldValue($this->fieldobj,$this->module,SHOW_POPUP);
                    }
                    $showobjvalue->setRecorId($potentialid);
                }

               if(!array_key_exists($potentialid,$account_cols)||!in_array($columnanme,$account_cols[$potentialid]))
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
                    if ($columnanme == 'potential_no') {   
                        if ($this->hyperlink == '0') {
                            $showobjvalue_arr['value'] = '<a fieldname="'.$columnanme.'" module="'.$this->module.'" record="'.$potentialid.'" href="javascript:;"  onclick="ListLinkClick(ld(this),event)" title="'.$showobjvalue_arr['value'].'">'.$showobjvalue_arr['value'].'</a>';
                        }
                        $detail_value[$potentialid][] = $showobjvalue_arr;
                    }else {
                        $detail_value[$potentialid][]=$showobjvalue_arr;
                    }
                   $account_cols[$potentialid][]=$columnanme;
                  }  
            }   
        }

       $arr=array();
       $arrindex=0;
       foreach($detail_value as $potentialid =>$info){
             $tmpinfo=$info; 
            $arr[]=$tmpinfo;    
       }

        return $arr;
    }

}