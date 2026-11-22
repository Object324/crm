<?php
/* createdby:can editor:gyq_12 reason:查重显示列序时簿 date:20160601 */
crm_load_class_file('ProductDetails','include/ProductDetails');
class DupSearch_ProductDetails extends ProductDetails
{

    private $focus;
    //editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 15:03
    public $duplicate_orderby = ' ld_account.createdtime desc,ld_account.accountid desc ';
    function __construct($module){
        global $current_user;
        $languageType= getLanguageType($current_user);
        require(globalStatic::$root_directory.'include/language/'.$languageType.'.php');
        $filecontent = file_get_contents(globalStatic::$root_directory.'user_privileges/setDuplicateColumnDisplay.php');
        $filecontent_arr = json_decode($filecontent,true);
        $filecontent_now = $filecontent_arr[$module];
        require_once (globalStatic::$root_directory.'modules/Accounts/cls_DuplicateColumn.php');
        $focusobj = new cls_DuplicateColumn();
		if(empty($filecontent_now)){
			/*$focusmodule=$module;
			$focusobj=CRMEntity::getInstance($focusmodule);*/

			$column_header =$focusobj->getDuplicateColumnDisplaySetting(1);//查重显示列标题字段
			foreach($column_header as $columns){
				$columns_arr[] = $module . '|' . $columns['tablename'] . '|' . $columns['columnname'];
			}
			$filecontent_now = implode(',',$columns_arr);
		}
        $this->userlanguage=$languageType;
        $select_option_arr = explode(',',$filecontent_now);
        $this->customviewmodule = $module;

        $focus=CRMEntity::getInstance($module);
		/*foreach($select_option_arr as $select_option){  //老的客户查重逻辑
			$arr = explode('|',$select_option);
			$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$arr[2]);
			if(!empty($fieldinfo)){
				$this->searchFieldArr[]=array('columnname'=>$select_option_arr[1],"fieldname"=>$fieldinfo->getFieldName(),
            "tablename"=>$select_option_arr[0],"fieldlabel"=>$fieldinfo->getFieldLabelKey());
			}
		}*/

        //新增联系人相关查重
        $contact_focus = null;
        if($module == 'Accounts'){
            $contact_focus = CRMEntity::getInstance('Contacts');
            $contactfields = $contact_focus->fieldobj->getModuleFields();
        }
        foreach($select_option_arr as $select_option){
            $arr = explode('|',$select_option);
            if($module == 'Accounts' && $arr[0] == 'Contacts'){
                $fieldinfo = $contact_focus->fieldobj->getFieldInfoobjBykey('columnname',$arr[2]);
            }else{
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$arr[2]);
            }
            if(!empty($fieldinfo)){
                $this->searchFieldArr[] = array('columnname'=>$arr[2],"fieldname"=>$fieldinfo->getFieldName(),
                    "tablename"=>$arr[1],"fieldlabel"=>$fieldinfo->getFieldLabelKey());
            }
        }
        //查重已选的可查询字段
        $search_select_option =$focusobj->getDuplicateColumnSearchSetting(1);
        foreach($search_select_option as $select_option){
            if($module == 'Accounts' && $select_option['module'] == 'Contacts'){
                $fieldinfo = $contact_focus->fieldobj->getFieldInfoobjBykey('columnname',$select_option['fieldname']);
            }else{
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$select_option['fieldname']);
            }
            if(!empty($fieldinfo)){
                $this->fields_forsearch_arr[] = array('columnname'=>$select_option['fieldname'],"fieldname"=>$fieldinfo->getFieldName(),
                    "tablename"=>$select_option['tablename'],"fieldlabel"=>$fieldinfo->getFieldLabelKey());
            }
        }
        
        $this->focus=$focus;
    }
   
    
    /**
     *
     * @param String:ModuleName $module
     * @return EntityMeta
     */
    function getSelectColumn($tabid){
        global $adb,$current_user,$PlatformMC;

        if(!empty($this->HeaderColumns)){
            return $this->HeaderColumns;
        }
        $module = $this->customviewmodule;

        //新增联系人相关查重
        $contact_focus=null;
        if($module == 'Accounts'){
            $contact_focus = CRMEntity::getInstance('Contacts');
            $contactfields = $contact_focus->fieldobj->getModuleFields();
        }

        require_once (globalStatic::$root_directory.'modules/Accounts/cls_DuplicateColumn.php');
        $focusobj = new cls_DuplicateColumn();
        /*$focusmodule=$module;
        $focusobj=CRMEntity::getInstance($focusmodule);*/
        //editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 14:51
        // @edit:dong @date:2020/08/05 @reason:
//        if(isset( $PlatformMC['type'])&&$PlatformMC['type']=='weixin'){
//            crm_load_class_file('QueryGenerator_FunctionsMC', 'appCommon/include/QueryGenerator');
//            $OBJ = new QueryGenerator_FunctionsMC();
//            $colunmlist_mc = $OBJ->getColumnsListByModule($this->customviewmodule);
//            $column_list = $colunmlist_mc['base'];
//        }else{
            $column_header =$focusobj->getDuplicateColumnDisplaySetting(1);//查重显示列标题字段
//            print_r($column_header);exit;
            foreach($column_header as $index=>$content)
            {
                if ($module == 'Accounts' && in_array($content['tablename'], $contact_focus->tab_name))
                {
                    $column_list[$index]=$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.'Contacts_fieldlabel:'.$content['typeofdata'];
                }else{
                    $column_list[$index]=$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$module.'_fieldlabel:'.$content['typeofdata'];
                }

            }
//        }
//        print_r($column_list);exit;
        for($i = 0; $i<sizeof($column_list); $i++){
            $columnviewArray = explode(':',$column_list[$i]);

            $module_fieldlabels=explode('_',$columnviewArray[3]);
            $meta = $this->querygenerator->getMeta($module);
            $objmoduleFields = $meta->getModuleFields();
            $Objfield=$objmoduleFields[$columnviewArray[2]];

            if (in_array($columnviewArray[0], $contact_focus->tab_name))
            {
                //查重-》联系人字段
                $Objfield = $contactfields[$columnviewArray[2]];
            }

            if(!isset($Objfield)){

                continue;
            }
            $this->fields_property[]=$module_fieldlabels[0];

            if(isProductTable($columnviewArray[0])){
                $field=$this->modulefields[$columnviewArray[2]];
                if($field)
                    $fieldlabel=$field->getFieldLabelKey();
            }
            else{
                $fieldobj=Field::getInstance($this->customviewmodule,$adb);
                $arrFieldlabels=$fieldobj->getFieldLables();
                $fieldlabel=$arrFieldlabels[$columnviewArray[2]];
            }


            $this->listViewHeaderSearch[$content['columnname']]=$fieldlabel;
            //edit: xll 2023/06/28 XUQIU1000357 单据分录定制，增加“附件”字段类型（搜索字段和和表字段分成两个不同方法获取）
            $this->ListViewHeaderFields[$content['columnname']]=$fieldlabel;

            $columnlist[$i+1] = $columnviewArray[0] . '.' . strtolower($columnviewArray[1]);

            $this->list_fields[]=$columnviewArray[2];
        }
        $columnlist=array_filter($columnlist);
        $this->HeaderColumns=$columnlist;
        return implode(',', $columnlist);
    }



    /**
     * 重写父类方法(排序)
     * */
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name=$this->focus->table_name;
        return $maintable_name.'.createdtime desc';
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {

        foreach($this->searchFieldArr as $index=>$content)
        {
            $column_list[$index]=$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$this->module.'_fieldlabel'.$content['typeofdata'];
        }

        return $column_list;
    }
    public function getModuleFields()
    {
       if(!is_array($this->modulefields)||sizeof($this->modulefields)<0)
          parent::setModuleFields();
       
        return parent::getModuleFields();
    }
    /**
     * 重写父类基本查询方法
     * */
    function getStdFilterByCvid($cvid) {
        return $this->getStdFilterByautoid();

    }
    /**
     * 重写父类高级查询方法
     * */
    public function  getAdvFilterByCvid($cvid) {
        return $this->getAdvFilterByautoid();
    }
    /**
     * 获取基本查询条件
     * */
    function getStdFilterByautoid() {
        return array();
    }


    /**
     * 获取高级查询条件
     * */
    function getAdvFilterByautoid() {

        $keywords=$_REQUEST['search_content'];

        if(!empty($keywords))
        {
            //筛选掉黑名单影响的字段
            $new_column_arr = array();
            foreach($this->fields_forsearch_arr as $content){
                //当有黑名单的字且选择被黑名单影响查重字段时，跳过此次循环
                if($this->getpermission=='no'&&(in_array($content['columnname'],$this->blackcolumnarray))){
                    continue;
                }else{
                    $new_column_arr[] = $content;
                }
            }
            
            foreach($new_column_arr as $index=>$content)
            {
                //20791: 新建单据界面：选择客户名称弹出层，输入字母查询，建议统一不区分大小写。
				$column_condition = 'or';
				if($index == sizeOf($new_column_arr) - 1){
					$column_condition = '';
				}
                $advft_criteria[1]['columns'][]=array('columnname'=>$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$this->module.'_fieldlabel',
                    'comparator'=>'c','value'=>$keywords,'column_condition'=> $column_condition);
            }

            $advft_criteria[1]['condition']='';
        }
        else
        {
            $advft_criteria=array();
        }

        return $advft_criteria;
    }
}


?>