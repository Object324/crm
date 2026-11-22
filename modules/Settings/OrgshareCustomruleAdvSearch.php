<?php
global $current_user,$default_charset,$modulename,$module;
crm_load_class_file('CommonView',"modules/CustomView");
$tabid=$_REQUEST['tabid'];
$module=getTabname($tabid);
$modulename = getTranstab($module);
//数据分类开始

$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);

$advfilterlist = getAdvFilter($advft_criteria,$advft_criteria_groups);
$advfilterhtml = getAdvCriteriaHTML();
$arr['columns_block'] = getByModule_ColumnsHTML($module,$modulecollist);//高级查询select option

function getAdvCriteriaHTML($selected="")
{
    global $adv_filter_options;
    $adv_filter_options_label = array("e" => "" . getFixedLabel('EQ') . "",
        "n" => "" . getFixedLabel('NEQ')  . "",
        "s" => "" . getFixedLabel('Begins') . "",
        "ew" => "" .getFixedLabel('Ends') . "",
        "c" => "" . getFixedLabel('IN')  . "",
        "k" => getFixedLabel('NOT_IN'),
        "l" => getFixedLabel('LT'),
        "g" => getFixedLabel('GT'),
        "m" => getFixedLabel('LE'),
        "h" =>getFixedLabel('GE'),
        "b" => getFixedLabel('Before'),
        "a" => getFixedLabel('After'),
        "bw" => getFixedLabel('Interval'),
        "isnull" => getFixedLabel('ISNULL'),
        "isnotnull" => getFixedLabel('ISNOTNULL'),
        "or" => getFixedLabel('OR'),
        "and" => getFixedLabel('SEARCHAND'),
        "curuser" => getFixedLabel('CURUSER')
    );

    foreach($adv_filter_options as $key=>$value)
    {
        if(empty($value)){
            $value = $adv_filter_options_label[$key];
        }
        if($selected == $key){
            $shtml .= "<option selected value=\"".$key."\">".$value."</option>";
        }else{
            $shtml .= "<option value=\"".$key."\">".$value."</option>";
        }
    }
    return $shtml;
}

/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilter($s_advft_criteria,$s_advft_criteria_groups) {

    global $adb,  $default_charset;
    $advfiltergroup=!empty($s_advft_criteria_groups)?ldcrm_json_decode(html_entity_decode($s_advft_criteria_groups)):[];
    $advfilterlist = !empty($s_advft_criteria)?ldcrm_json_decode(html_entity_decode($s_advft_criteria)):[];
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

function getByModule_ColumnsHTML($module,$columnslist) {
    global $mod_strings;
    $columnsList = getByModule_ColumnsList($module,$columnslist,"");
    return generateSelectColumnsHTML($columnsList,$module);
}

function getByModule_ColumnsList($module,$columnslist,$selected="") {
    global $oCustomView, $current_language,$theme;
    global $app_list_strings;
    global $adb;

    $check_dup = Array();
    $fieldobj = field::getInstance($module,$adb);
    $module_fields = $fieldobj->getModuleFields();

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
                    $fieldinfoobj = $module_fields[$arrfield[2]];
                    //duan 20230725 工作流程高级查询条件不显示附件字段
                    if(empty($fieldinfoobj)){
                        continue;
                    }else if($fieldinfoobj->getBigType() == 'fileattachment'){
                        continue;
                    }

                    if(isset($mod_strings[$fieldlabel]))
                    {
                        $arrselected=explode(":",$selected);
                        $arrfield=explode(":",$field);

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
            $advfilter_out[$label]= $advfilter;
        }
    }

    return $advfilter_out;
}

function generateSelectColumnsHTML($columnsList, $module) {
    $shtml = '';
    foreach($columnsList as $blocklabel=>$blockcolumns) {
        $shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
        foreach($blockcolumns as $columninfo) {
            $shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
        }
    }
    return $shtml;
}


?>