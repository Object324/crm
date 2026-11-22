<?php
class cls_QustionDuplicateColumn
{
    private $module;
    private $focus;
    private $fieldobj;
    private $adb;

    public function __construct($modulename = '',$advance_demand = [],$advance_demand_groups =[],$approve_demand = 0,$maxrowsshow = 5,$languege='zh',$topicid)
    {
        global $adb;
        $this->adb = $adb;
        $this->module = $modulename;
        $this->focus = CRMEntity::getInstance($modulename);
        $this->fieldobj = $this->focus->fieldobj;

        $this->advance_demand = $advance_demand;
        $this->advance_demand_groups = $advance_demand_groups;
        //$this->approve_demand = $approve_demand;
        $this->approve_demand = 0;
        $this->maxrowsshow = $maxrowsshow;
        $this->popupProductDetails = crm_load_class_obj("PopupProductDetails", 'include/ProductDetails', array($this->module));
        $this->customView = $this->popupProductDetails;//new PopupCustomView($selectmodule);
        $this->topicid = $topicid;
    }

    public function displayTpl(){
        $languageType = $_REQUEST['languege'];
        global $adb;
        require_once (globalStatic::$root_directory.'Smarty_setup.php');
        $smarty = new lingdangCRM_Smarty();
        $detail_value = $this->getDuplicate_related_detail();
        if(!empty($detail_value)){
            $detail_values = $detail_value;
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
        //$smarty->assign("SELECTOPTION",$this->getSelectOption());
        $displaySetting_fieldlabel = $this->getDuplicateColumnDisplaySetting();
        $i = 0;
        foreach($displaySetting_fieldlabel as $label){
            if($i <= 2){
                $label_arr[] = $label;
            }
            $i++;
        }
        $search_label = getFixedLabel('pleaseenter') . implode('、',$label_arr);
        if(sizeOf($displaySetting_fieldlabel) > 3){
            $search_label .= '......';
        }
        $smarty->assign('SEARCHLABEL',$search_label);
        $smarty->assign('DISPLAYCOLUMNNUMBER',count($displaySetting_fieldlabel));
        $smarty->assign('TABLEHEADER',$displaySetting_fieldlabel);//列头显示。
        $smarty->assign('TABLE_DUPLICATE_VALUE',$detail_values);
        $smarty->assign('MODULE',$this->module);
        $smarty->assign('SEARCH_CONTENT',$_REQUEST['value']); //填写查重内容之后，点击立即查重按钮之后，文本框内记住值
        $smarty->assign('MAXROWSSHOW',$this->maxrowsshow);
        $smarty->assign('TOPICID',$this->topicid);
        $_REQUEST['diony']='diony';
        $str=$smarty->fetch('QuestionnairelicateRelatedPopu.tpl');
        //$str=$smarty->fetch('SelectRelPopupContents.tpl');
        $arr['content']=$str;
        $arr['module']=$this->module;
        $sql = "select fieldlabel from ld_tranlabel where tabid = ? and trantable = 'ld_tab' and languagetype = ?";
        $result=$adb->pquery($sql,array(getTabid($this->module),$languageType));
        $rows=$adb->num_rows($result);
        $module_lable= '';
        if($rows>0){
            $module_lable = $adb->query_result($result,0,'fieldlabel');
        }
        $arr['title'] = $module_lable;
        ConvertTojsonString(1,$arr,"success");
        exit();
    }

    public function getDuplicate_related_detail(){
        $adb = $this->adb;
        $displaySetting_columnname = [];
        //超链接字段
        $sql = 'select ld_entityname.modulename,ld_field.columnname,ld_field.fieldname,ld_field.tablename,ld_field.fieldlabel from ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname and ld_field.tabid = ld_entityname.tabid where ld_entityname.tabid = ? ';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $displaySetting_columnname[] = array(
                'module'=>$adb->query_result($result,0,'modulename'),
                'columnname'=>$adb->query_result($result,0,'columnname'),
                'fieldname'=>$adb->query_result($result,0,'fieldname'),
                'tablename'=>$adb->query_result($result,0,'tablename'),
                'fieldlabel'=>$adb->query_result($result,0,'fieldlabel')
            );
        }
        //负责人 编号字段
        $sql = 'select columnname,fieldname,tablename,fieldlabel from ld_field where tabid = ? and (uitype=4  or uitype=53) ORDER BY uitype desc';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            for($i = 0;$i<$rows;$i++){
                $displaySetting_columnname[] = array(
                    'module'=>$this->module,
                    'columnname'=>$adb->query_result($result,$i,'columnname'),
                    'fieldname'=>$adb->query_result($result,$i,'fieldname'),
                    'tablename'=>$adb->query_result($result,$i,'tablename'),
                    'fieldlabel'=>$adb->query_result($result,$i,'fieldlabel')
                );
            }
        }
        $this->display_columnname = $displaySetting_columnname;
        $list_query = $this->getQuery();
        $result=$adb->pquery($list_query);
        $num_rows=$adb->num_rows($result);

        for($i=0;$i<$num_rows;$i++)
        {

            foreach($displaySetting_columnname as $index=>$content)
            {
                $columnanme = $content['columnname'];
                $tablename = $content['tablename'];
                $value=$adb->query_result($result,$i,$columnanme);
                $module_table_index=$adb->query_result($result,$i,$this->focus->table_index);

                if($columnanme=='total'||$columnanme=='subtotal'){
                    $fieldinfo=$this->producttoolfields->getFieldInfoobjBykey('columnname',$content['columnname']);
                    $showobjvalue=new ShowFieldValue($this->producttoolfields,$this->module,SHOW_POPUP);
                }else{
                    $fieldinfo=$this->fieldobj->getFieldInfoobjBykey('columnname',$content['columnname']);
                    $showobjvalue=new ShowFieldValue($this->fieldobj,$this->module,SHOW_POPUP);
                }
                $showobjvalue->setRecorId($module_table_index);



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

                $detail_value[$module_table_index][]=$showobjvalue_arr;

                $account_cols[$module_table_index][]=$columnanme;

            }
        }

        return $detail_value;

    }

    public function getQuery(){
        $_REQUEST['advance_demand'] = $this->advance_demand;
        $_REQUEST['advance_demand_groups'] = $this->advance_demand_groups;
        $_REQUEST['approve_demand'] = $this->approve_demand;
        $_REQUEST['maxrowsshow'] = $this->maxrowsshow;

        require_once (globalStatic::$root_directory.'modules/Questionnaire/cls_QueQueryGenerator.php');
        $queryGenerator = new cls_QueQueryGenerator($this->module,$this->customView);

        $queryGenerator->initForCustomViewById(0);

        $page_list_query = $queryGenerator->getQuery('',1);
        $list_query= $queryGenerator->getQuery('',2);


        $list_query=$list_query .'  inner join   ( '.$page_list_query.' ) as tmp on tmp.'.$this->focus->table_index.'='.$this->focus->table_name.'.'.$this->focus->table_index.' order by '. $this->focus->table_name . '.createdtime DESC ';
        return $list_query;
    }

    public function getDuplicateColumnDisplaySetting(){
        $displaySetting_fieldlabel = [];
        for($i = 0;$i<count($this->display_columnname);$i++){
            $displaySetting_fieldlabel[] = $this->display_columnname[$i]['fieldlabel'];
        }
        return $displaySetting_fieldlabel;
    }
}
?>
