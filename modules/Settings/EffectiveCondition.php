<?php

class EffectiveCondition
{
    public static function getAdvCriteriaHTML($selected="",$fLabels=[])
    {
        foreach($fLabels as $key=>$value)
        {
            if($selected == $key)
            {
                $shtml .= "<option value=\"".$key."\" selected>".$value."</option>";
            }else
            {
                $shtml .= "<option value=\"".$key."\">".$value."</option>";
            }
        }
        return $shtml;
    }

    /** to get the Advanced filter for the given customview Id
     * @param $cvid :: Type Integer
     * @returns  $advfilterlist Array
     */
    public static function getAdvFilter() {

        global $adb,  $default_charset;
        $advft_criteria = array();
        $advfiltergroup=ldcrm_json_decode($_REQUEST['advft_criteria_groups']);
        $advfilterlist = ldcrm_json_decode($_REQUEST['advft_criteria']);
        $i = 1;
        $j = 0;
        foreach($advfiltergroup as $key => $relcriteriagroup){
            if(empty($relcriteriagroup)){
                continue;
            }
            $groupId = $key;
            $groupCondition = $relcriteriagroup["groupcondition"];

            foreach($advfilterlist as $k => $relcriteriarow){
                if($relcriteriarow['groupid'] == $key){
                    $columnIndex = $relcriteriarow["columnindex"];
                    $criteria = array();
                    $criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
                    $criteria['comparator'] = $relcriteriarow["comparator"];
                    $criteria['search_comparator']= $relcriteriarow["comparator"];
                    $advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
                    $col = explode(":", $relcriteriarow["columnname"]);
                    $temp_val = explode(",", $relcriteriarow["value"]);
                    if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
                        crm_load_class_file("DateTimeField","include/fields");
                        $val = Array();
                        for ($x = 0; $x < count($temp_val); $x++) {
                            if ($col[4] == 'D') {
                                $date = new DateTimeField(trim($temp_val[$x]));
                                $val[$x] = $date->getDisplayDate();
                            } elseif ($col[4] == 'DT') {
                                $date = new DateTimeField(trim($temp_val[$x]));
                                $val[$x] = $date->getDisplayDateTimeValue();
                            } else {
                                $date = new DateTimeField(trim($temp_val[$x]));
                                $val[$x] = $date->getDisplayTime();
                            }
                        }
                        $advfilterval = implode(",", $val);
                    }
                    $criteria['value'] = $advfilterval;
                    $criteria['column_condition'] = $relcriteriarow["columncondition"];

                    $advft_criteria[$i]['columns'][$j] = $criteria;
                    $advft_criteria[$i]['condition'] = $groupCondition;

                    $j++;
                }
            }
            if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
                $advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
            }
            $i++;
        }
        // Clear the condition (and/or) for last group, if any.
        if (!empty($advft_criteria[$i - 1]['condition']))
            $advft_criteria[$i - 1]['condition'] = '';


        return $advft_criteria;
    }

//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
    public static function getByModule_ColumnsHTML($module,$columnslist,$includeDetail = 'yes') {
        global $mod_strings;

        $columnsList = self::getByModule_ColumnsList($module,$columnslist,"");
        if(get_file_address($module,'ProductDetails') && $includeDetail === 'yes')
        {
            crm_load_class_file('CustomView_Special','modules/CustomView');
            if($module=='ServiceCharge')
            {
                if($servicecharge_list_show == 'servicecontracts'){
                    if(is_array($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]))
                    {
                        $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]
                            ,CustomView_Special::getServiceChargeDetail($module,$adf_column));

                    }
                    else
                        $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getServiceChargeDetail($module,$adf_column);
                }
            }
            else
            {

                if(is_array($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]))
                {
                    $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]
                        ,CustomView_Special::getServiceChargeDetail($module,$adf_column));

                }
                else
                    $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getProductSearchCustom($module,$adf_column);
            }
        }
        //除产品明细模块意外的名字模块
        if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            crm_load_class_file('CustomView_Special','modules/CustomView');
            $columnsList[getTranstab($module).getFixedLabel('INFORMATION')] = CustomView_Special::getFinacialSearchCustom($module,$adf_column);
        }
        if(get_file_address($module,'ProductDetails') && $module == 'ServiceCharge')
        {
            if($servicecharge_list_show == 'servicecontracts'){
                crm_load_class_file('CustomView_Special','modules/CustomView');
                $columnsList[getTranstab('ServiceContracts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('ServiceContracts',$adf_column);
            }else{
                crm_load_class_file('CustomView_Special','modules/CustomView');
                $columnsList[getTranstab('Contacts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('Contacts',$adf_column);
            }
        }
        /**
         * edit:chj
         * date:2014-12-31
         * reason: 客户模块  高级查询里显示联系人信息，去除首要联系人信息
         **/
        if(get_file_address($module,'ContactsDetails') && $includeDetail === 'yes')
        {
            crm_load_class_file('CustomView_Special','modules/CustomView');
            $columnsList[getTranstab('Contacts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('Contacts',$adf_column);
        }
        /**
         * edit:chj
         * date:2014-12-31
         * reason: 供应商模块  高级查询里显示供应商联系人信息
         **/
        if(get_file_address($module,'VendorsDetails'))
        {
            crm_load_class_file('CustomView_Special','modules/CustomView');
            if(is_array($columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]))
            {
                $columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]
                    ,CustomView_Special::getModuleSearchCustom('VendorContact',$adf_column));

            }
            else
                $columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('VendorContact',$adf_column);
        }

        return self::generateSelectColumnsHTML($columnsList,$module);
    }

    public static function getByModule_ColumnsList($module,$columnslist,$selected="") {
        global $oCustomView, $current_language,$theme;
        global $app_list_strings;
        global $adb;
        $advfilter = array();
        //$mod_strings = return_specified_module_language($current_language,$module);

        $check_dup = Array();
        $focus = CRMEntity::getInstance($module);
        //edit: xll 20/11/14 BUG0074940 企业微信移动端，报表->测试单折线图 点击“筛选”操作按钮没有反应
        if(!$oCustomView) {
            $oCustomView = new CustomView();
            $oCustomView->getModuleColumnsList($module);
        }
        foreach($oCustomView->module_list[$module] as $key=>$value)
        {
            $advfilter = array();
            $label = $key;
            if(isset($columnslist[$module][$key]))
            {
                foreach($columnslist[$module][$key] as $field=>$fieldlabel)
                {
                    if(!in_array($fieldlabel,$check_dup))
                    {
                        $arrselected=explode(":",$selected);
                        $arrfield=explode(":",$field);
                        $tmp_field=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$arrfield[2]);

                        if(!$tmp_field){
                            continue;
                        }
                        //不显示图片和附件字段
                        if($tmp_field->isImageField()=='yes'||$tmp_field->getUIType()==1109){
                            continue;
                        }
                        if(isset($mod_strings[$fieldlabel]))
                        {
                            if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "selected";
                            }else
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "";
                            }
                        }else
                        {

                            //if($selected == $field)
                            if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "selected";
                            }else
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "";
                            }
                        }
                        $advfilter[] = $advfilter_option;
                        $check_dup [] = $fieldlabel;
                    }
                }
                if(sizeof($advfilter)>0){
                    $advfilter_out[$label]= $advfilter;
                }
            }
        }

        return $advfilter_out;
    }

    public static function getCvadfilter()
    {
        global $adb;
        $array = array();
        /*$sql = "select columnname from ld_account_set_advfilter where pool_id = -1";
        $result = $adb->pquery($sql,array());
        for ($i=0;$i<$adb->num_rows($result);$i++) {
            $array[$i] = $adb->query_result($result, $i, "columnname");
        }*/
        return $array;
    }

    public static function generateSelectColumnsHTML($columnsList, $module) {
        $shtml = '';
        foreach($columnsList as $blocklabel=>$blockcolumns) {
            $shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
            foreach($blockcolumns as $columninfo) {
                $shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
            }
        }
        return $shtml;
    }
}