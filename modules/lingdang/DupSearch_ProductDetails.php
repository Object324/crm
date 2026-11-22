<?php
/* reason:查重显示列序时簿  */
crm_load_class_file('ProductDetails','include/ProductDetails');
class DupSearch_ProductDetails extends ProductDetails
{

    private $focus;
    // reason:微信查重，查询方法改为继承PC端 
    public $duplicate_orderby;
    public $searchFieldArr = [];
    public $fields_forsearch_arr = [];
    public $getpermission;
    public $blackcolumnarray = [];
    function __construct($module){
        global $current_user;
        $languageType= getLanguageType($current_user);
        crm_load_class_file($languageType,'include/language');
        crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
		$focusobj = cls_DuplicateColumn::getInstance($module);
		$filecontent_now = $focusobj->getDuplicateColumnDisplayFromFile();
        $this->userlanguage=$languageType;
        $select_option_arr = explode(',',$filecontent_now);
        $this->customviewmodule = $module;
        $focus=CRMEntity::getInstance($module);
        $this->duplicate_orderby = $focus->table_name.'.createdtime desc,'.$focus->table_name.'.'.$focus->table_index.' desc ';
        foreach($select_option_arr as $select_option){
            $arr = explode('|',$select_option);
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$arr[2]);

            if(!empty($fieldinfo)){
                $this->searchFieldArr[] = array('columnname'=>$arr[2],"fieldname"=>$fieldinfo->getFieldName(),
                    "tablename"=>$arr[1],"fieldlabel"=>$fieldinfo->getFieldLabelKey());
            }
        }
        //查重已选的可查询字段
        $search_select_option =$focusobj->getDuplicateColumnSearchSetting(1);
        foreach($search_select_option as $select_option){
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$select_option['columnname']);
            if(!empty($fieldinfo)){
                $this->fields_forsearch_arr[] = array('columnname'=>$select_option['columnname'],"fieldname"=>$fieldinfo->getFieldName(),
                    "tablename"=>$select_option['tablename'],"fieldlabel"=>$fieldinfo->getFieldLabelKey());
            }
        }

        $this->focus=$focus;
    }

    private static $instanceobj;
    public static function getInstance($module="",$languagetran=""){
        if(!empty(self::$instanceobj[$module])){
            return self::$instanceobj[$module];
        }
        if($module=='Accounts') {
            crm_load_class_file("DupSearch_ProductDetails_account",'modules/Accounts');
            self::$instanceobj[$module] = new DupSearch_ProductDetails_account($module);
        } else if($module=='Potentials') {
            crm_load_class_file("DupSearch_ProductDetails_potentials",'modules/Potentials');
            self::$instanceobj[$module] = new DupSearch_ProductDetails_potentials($module);
        }else{
            self:: $instanceobj[$module] = new DupSearch_ProductDetails($module);
        }
        return self:: $instanceobj[$module];
    }
    /**
     *
     * @param String:ModuleName $module
     * @return EntityMeta
     */
    function getSelectColumn($tabid){
        global $adb,$current_user,$PlatformMC;
        if(!empty($this->HeaderColumns)){
            //zxm 20230830 这个方法返回值应该是个字符串
            return implode(',', $this->HeaderColumns);;
            return $this->HeaderColumns;
        }
        $module = $this->customviewmodule;

        //wym 240416 查重类文件结构优化
        crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
        $focusobj = cls_DuplicateColumn::getInstance($module);
        $column_header =$focusobj->getDuplicateColumnDisplaySetting(1);//查重显示列标题字段
        foreach($column_header as $index=>$content)
        {
            $column_list[$index]=$content['tablename'].':'.$content['columnname'].':'.$content['fieldname'].':'.$module.'_fieldlabel:'.$content['typeofdata'];
        
        }
        for($i = 0; $i<sizeof($column_list); $i++){
            $columnviewArray = explode(':',$column_list[$i]);
            $module_fieldlabels=explode('_',$columnviewArray[3]);
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
            foreach($this->fields_forsearch_arr as $index=>$content)
            {
                //当有黑名单的字且选择被黑名单影响查重字段时，跳过此次循环
                if($this->getpermission=='no'&&(in_array($content['columnname'],$this->blackcolumnarray))){
                    continue;
                }
                //20791: 新建单据界面：选择名称弹出层，输入字母查询，建议统一不区分大小写。
				
                $column_condition = 'or';
				if($index == sizeOf($this->fields_forsearch_arr) - 1){
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