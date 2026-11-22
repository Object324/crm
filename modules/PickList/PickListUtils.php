<?php


/**
 * this file will be used to store the functions to be used in the picklist module
 */

/**
 * Function to get picklist fields for the given module
 * @ param $fld_module
 * It gets the picklist details array for the given module in the given format
 * $fieldlist = Array(Array('fieldlabel'=>$fieldlabel,'generatedtype'=>$generatedtype,'columnname'=>$columnname,'fieldname'=>$fieldname,'value'=>picklistvalues))
 */
function getUserFldArray($fld_module,$roleid){
    global $adb, $current_user;
    $languageType= getLanguageType($current_user);
    $user_fld = Array();
    $tabid = getTabid($fld_module);
    if($fld_module=='Calendar') $tabid=16;
    /**
     * 2016-04/11
     * Liver
     * 	0021388: 控制面板>页面设置：新建下拉框字段，保存后，控制面板-下拉框编辑中显示两个该字段。
     * 增加ld_tranlabel.tabid=?来区分客户和服务收费管理模块
     */
    $query="select ld_tranlabel.fieldlabel,ld_field.columnname,ld_field.fieldname, ld_field.uitype" .
        " FROM ld_field " .
        " inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid ".
        " where ((displaytype=1 and ld_field.tabid=? and ld_field.uitype in ('15','55','33','16') " .
        " or (ld_field.tabid=? and fieldname='salutationtype' and fieldname !='vendortype')))   and ld_tranlabel.tabid=? and ld_tranlabel.languagetype=? and ld_tranlabel.trantable=?" .
        " and ld_field.presence in (0,2) ORDER BY ld_field.block  ASC,ld_field.sequence";

    //print_r(array($tabid, $tabid,$languageType,'ld_field'));
    $result = $adb->pquery($query, array($tabid,$tabid,$tabid,$languageType,'ld_field'));
    // echo $result->sql;
    $noofrows = $adb->num_rows($result);

    if($noofrows > 0){

        $fieldlist = array();
        for($i=0; $i<$noofrows; $i++){
            $user_fld = array();
            $fld_name = $adb->query_result($result,$i,"fieldname");
            if($tabid==29)
            {
                if($fld_name=='lead_view' ||$fld_name=='activity_view'
                    ||$fld_name=='reminder_interval'||$fld_name=='currency_symbol_placement'
                    ||$fld_name=='currency_grouping_pattern'||$fld_name=='currency_decimal_separator'
                    ||$fld_name=='currency_grouping_separator'||$fld_name=='approvestatus')
                {
                    continue;
                }
            }
            $user_fld['fieldlabel'] = $adb->query_result($result,$i,"fieldlabel");
            $user_fld['generatedtype'] = $adb->query_result($result,$i,"generatedtype");
            $user_fld['columnname'] = $adb->query_result($result,$i,"columnname");
            $user_fld['fieldname'] = $adb->query_result($result,$i,"fieldname");
            $user_fld['uitype'] = $adb->query_result($result,$i,"uitype");


            $user_fld['value'] = getAssignedPicklistValues($user_fld['fieldname'], $roleid, $adb);

            $fieldlist[] = $user_fld;
        }
    }
    /**
     * 更新操作
     * edit:can
     * date:20131030
     * reason:5547: 控制面板>下拉框编辑：希望在下拉框编辑中添加费用报销模块，以便定制费用报销单据中费用类别下拉框选项
     * */

    if(strtolower($fld_module)=="expense")
    {
        $user_fld=array();
        $user_fld['fieldlabel'] ="费用类别";
        if($languageType=='en')
        {
            $user_fld['fieldlabel'] ="fee type";
        }
        $user_fld['generatedtype']=1;
        $user_fld['columnname']="expensetype";
        $user_fld['fieldname']="expensetype";
        $user_fld['uitype']=15;
        $user_fld['value']=getAssignedPicklistValues($user_fld['fieldname'], $roleid, $adb);
        $fieldlist[] = $user_fld;
    }

    return $fieldlist;
}

/**
 * Function to get modules which has picklist values
 * It gets the picklist modules and return in an array in the following format
 * $modules = Array($tabid=>$tablabel,$tabid1=>$tablabel1,$tabid2=>$tablabel2,-------------,$tabidn=>$tablabeln)
 */
function getPickListModules(){
    global $adb;
    // vtlib customization: Ignore disabled modules.
    /**
     *AUTHOR: BY LD KEVIN
     * DATE:20130312
     * DESPRITION:修改bug3284
     */
    /**
     * 更新操作
     * edit:can
     * date:20131030
     * reason:5547: 控制面板>下拉框编辑：希望在下拉框编辑中添加费用报销模块，以便定制费用报销单据中费用类别下拉框选项
     * */
    /**
     * 更新操作
     * edit:andrew
     * date:20140122
     * DESPRITION:修改bug2840006809
     * */
    $query = "select distinct ld_field.fieldname,ld_field.tabid,ld_tab.tablabel, ld_tab.name as tabname,uitype from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid 
    where (uitype IN (15,33) or ld_tab.name='expense') and ld_tab.presence in (0,2) and 
    ld_field.presence in (0,2)  and name not in('Events')  order by tabsequence";//,'Users'
    // echo $query.'<br>';
    // END
    $result = $adb->pquery($query, array());
    while($row = $adb->fetch_array($result)){
        $modules[$row['tablabel']] = $row['tabname'];
    }
    return $modules;
}

/*function getrole2picklist(){
	global $adb;
	$query = "select rolename,roleid from ld_role where roleid not in('H1') order by roleid";
	$result = $adb->pquery($query, array());
	while($row = $adb->fetch_array($result)){
		$role[$row['roleid']] = $row['rolename'];
	}
	return $role;

}*/

/**
 * this function returns the picklists available for a module
 * @param array $picklist_details - the details about the picklists in the module
 * @return array $module_pick - the picklists present in the module in an array format
 */
function get_available_module_picklist($picklist_details){
    $avail_pick_values = $picklist_details;

    foreach($avail_pick_values as $key => $val){
        $module_pick[$avail_pick_values[$key]['fieldname']] = $avail_pick_values[$key]['fieldlabel'];
    }

    return $module_pick;
}

/**
 * this function returns all the picklist values that are available for a given
 * @param string $fieldName - the name of the field
 * @return array $arr - the array containing the picklist values
 */
function getAllPickListValues($rFieldName,$lang = Array() ){
    global $adb;
    //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 上午 11:23
    $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
    $arrResult = $objPickList->getPickListValues($rFieldName,$lang);
    return $arrResult;
    /*
        //旧代码001
        $sql = 'select '.$rFieldName.' from ld_'.$adb->sql_escape_string($rFieldName).' where presence=1 order by picklist_valueid asc';
        $result = $adb->query($sql);
        $count = $adb->num_rows($result);
        for($i=0;$i<$count;$i++){
            $pick_val = decode_html($adb->query_result($result, $i, 0));
            if($lang[$pick_val] != ''){
                $arrResult[$pick_val] = $lang[$pick_val];
            }
            else{
                $arrResult[$pick_val] = $pick_val;
            }
        }
    return $arrResult;*/
}


/**
 * this function accepts the fieldname and the language string array and returns all the editable picklist values for that fieldname
 * @param string $fieldName - the name of the picklist
 * @param array $lang - the language string array
 * @param object $adb - the peardatabase object
 * @return array $pick - the editable picklist values
 */
function getEditablePicklistValues($fieldName, $lang= array(), $adb=null){

    //Eidtor:gyq_64 Reason:下拉框改进  Date:2018/4/3 0003 下午 2:49
    $arrResult = array();
    $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
    $arrResult = $objPickList->getPickListValues($fieldName,$lang);
    return $arrResult;

    /*$values = array();
    $fieldName = $adb->sql_escape_string($fieldName);
    $sql="select $fieldName from ld_$fieldName where presence=1 and $fieldName <> '--None--'";
    $res = $adb->query($sql);
    $RowCount = $adb->num_rows($res);
    if($RowCount > 0){
        for($i=0;$i<$RowCount;$i++){
            $pick_val = $adb->query_result($res,$i,0);
            if($lang[$pick_val] != ''){
                $values[$pick_val]=$lang[$pick_val];
            }else{
                $values[$pick_val]=$pick_val;
            }
        }
    }*/
    return $values;
}

/**
 * this function accepts the fieldname and the language string array and returns all the non-editable picklist values for that fieldname
 * @param string $fieldName - the name of the picklist
 * @param array $lang - the language string array
 * @param object $adb - the peardatabase object
 * @return array $pick - the no-editable picklist values
 */
/*function getNonEditablePicklistValues($fieldName, $lang=array(), $adb){
	$values = array();
	$fieldName = $adb->sql_escape_string($fieldName);
	$sql = "select $fieldName from ld_$fieldName where presence=0";
	$result = $adb->query($sql);
	$count = $adb->num_rows($result);
	for($i=0;$i<$count;$i++){
		$non_val = $adb->query_result($result,$i,0);
		if($lang[$non_val] != ''){
			$values[]=$lang[$non_val];
		}else{
			$values[]=$non_val;
		}
	}
	if(count($values)==0){
		$values = "";
	}
	return $values;
}*/

/*
edit:Can
date:20130423
reason:城市，省份，国家不许要角色分配下来框内容
explain:查看和编辑界面的下拉框 的值
*/
function getPicklistValesForNORole($tableName,$adb, $lang=array(),$rObjField=null){
    /**
     * 下拉框项增加缓存
     * @author Tujt 2015-03-04
     */
    global $currentModule,$picklistmodule;//获取当前模块
    if(!empty($picklistmodule)){
        $fld_module = $picklistmodule;
    }else{
        $fld_module = $currentModule;
    }
    $tableName = strtolower($tableName);//小写，保持一致
    $tabid = getTabid($fld_module);//获取tabid值
    $cachekey = 'getPicklistValesForNORole'.$tabid;
    static $staticpicklist;//静态变量，防止多次从缓存文件中读取数据
//	$picklist = Cache($cachekey);//获取缓存信息
    if(!$picklist || !isset($picklist[$tableName])){
        //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 下午 4:04
        $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());

        if ($fld_module == 'Users' && $rObjField && $rObjField->getFieldName() == 'gender'){
            $picklist[$tableName] = $objPickList->getPickListValues($tableName,$rObjField,$lang,'');
        }else{
            $picklist[$tableName] = array_merge(array(''=>''),$objPickList->getPickListValues($tableName,$rObjField,$lang,''));
        }
        // Cache($cachekey,$picklist);//存入缓存
        //旧代码002
    }
    $staticpicklist[$cachekey] = $picklist;
    return $picklist[$tableName];
    /*旧代码002 $sql = 'select * from ld_'.$tableName.' where presence = 1
					order by picklist_valueid asc ';
		$result = $adb->pquery($sql, array());
		$rows = $adb->num_rows($result);
		$arr = array(''=>'');
		if($rows > 0){ // editor:gyq reason:新增$rows>0判断 date:gyq161206
			while($resultrow = $adb->fetch_array($result)) {//获取下拉框信息值
				$pick_val = decode_html($resultrow[$tableName]);
				if($lang[$pick_val] != '') $arr[$pick_val] = $lang[$pick_val];
				else $arr[$pick_val] = $pick_val;
			}
		}
		$picklist[$tableName] = $arr;*/
}
/**
 * this function returns all the assigned picklist values for the given tablename for the given roleid
 * @param string $tableName - the picklist tablename
 * @param integer $roleid - the roleid of the role for which you want data
 * @param object $adb - the peardatabase object
 * @return array $val - the assigned picklist values in array format
 */
//Eidtor:gyq_64 Reason:下拉框改进增加$rObjField参数 Date:2018/3/12 0012 下午 2:40
/**
 * @param $fieldName
 * @param $roleid
 * @param $adb
 * @param array $lang
 * @param $rObjField
 * @return array
 */
function getAssignedPicklistValues($fieldName, $roleid, $adb, $lang=array(),$rObjField=null){
    return getPicklistValesForNORole($fieldName,$adb, $lang,$rObjField);
}


/**
 * @param $fieldName
 * @param $value
 * @param $uitype
 * @param $rObjField
 * @return mixed
 * @throws Exception
 * 查看和编辑界面的下拉框
 * Eidtor:gyq_64 Reason:下拉框改进增加字段对象$rObjField Date:2018/3/9 0009 下午 2:39
 */
function getEditViewPagePickList($fieldName,$value,$uitype,$rObjField)
{
    global $adb;
    global $default_charset;
    if ($fieldName === 'role_module') {
        crm_load_class_file('PricePolicyUtils','modules/PricePolicy');
        $optionvalue =  PricePolicyUtils::getRoleModules(CRMEntity::getInstance('PricePolicy'));
    }
    $picklistValues = getAssignedPicklistValues($fieldName, 1, $adb,array(),$rObjField);//获取下拉列表显示值。

    $options = array();
    $selected_entries = Array();
    if($uitype==601)
    {
        if(!empty($value)){
            $selected_entries[] = $value;
        }
        $trackpostion_query="SELECT trackpostion_id,trackpostion from ld_trackpostion";
        $trackpostion_result=$adb->pquery($trackpostion_query,array());
        $trackpostion_nums=$adb->num_rows($trackpostion_result);

        if($trackpostion_nums>0)
        {
            for($i = 0; $i < $trackpostion_nums; $i++){
                $trackpostion_id = $adb->query_result($trackpostion_result,$i,'trackpostion_id');
                $trackpostion = $adb->query_result($trackpostion_result,$i,'trackpostion');
                $picklistValues[$trackpostion_id] = $trackpostion;
            }
        }
    }
    else{
        //24693: 联系人编辑界面：新增联系人，多选框字段只选择“3”，保存后，点击【编辑】，编辑界面自动多选择了“空”
        $selected_entries = explode(' |##| ', $value??"");

    }
    if(!empty($rObjField) && method_exists($rObjField,'getBigType')) {
        $bigtype = $rObjField->getBigType();
    }
    global $global_picklist_colors_byvalue;
    $pickcolors = $global_picklist_colors_byvalue[$fieldName];
    if (!empty($picklistValues)) {
        $index = $selectedIndex = 0;
        foreach ($picklistValues as $order => $pickListValue) {
            foreach ($selected_entries as $selected_entries_value) {
                //chj htmlspecialchars 特殊符号转义  &
                if (htmlspecialchars(trim($selected_entries_value)) == htmlspecialchars(trim($pickListValue))) {
                    $chk_val = 'selected';
                    $pickcount++;
                    break;
                }
                else if ($bigtype ==='picklist_key' && htmlspecialchars(trim($selected_entries_value)) === htmlspecialchars(trim($order))) {
                    $chk_val = 'selected';
                    $selectedIndex = $index;
                    $pickcount++;
                    break;
                }
                else {
                    $chk_val = '';
                }
            }
            //edit: xll 2023/07/31 BUG0064020 kfbcrm 客户---新增---“多选框”字段---删除某个下拉选项--保存后----框内会出现一个× 空白值
            //zkt 20230919 BUG0072954 kfbcrm-下拉框字段应有个空值选项 （之前的8.4.8的版本是有的 如图二）
            if($order !== 0 && empty($order) && $bigtype =='multipicklist')
                continue;
            if($bigtype === 'picklist_key') {
                $optionvalue[] = [
                    'value' => $order,
                    'label' => $pickListValue,
                    'selected' => $chk_val,
                    'color' => $pickcolors[$pickListValue],
                ];
            }
            else {
                if (isset($_REQUEST['file']) && $_REQUEST['file'] == 'QuickCreate') {
                    $optionvalue[] = array(htmlentities($pickListValue, ENT_QUOTES, $default_charset), $pickListValue, $chk_val, $pickcolors[$pickListValue]);
                } else {
                    $optionvalue[] = array($pickListValue, $pickListValue, $chk_val, $pickcolors[$pickListValue]);
                }
            }
            $index ++;
        }
        //echo  $pickcount.'-'. $value;
        if ($pickcount ==0 && !empty($value) && $uitype=!34) {
            $not_access_lbl = "<font color='red'>" . getFixedLabel('NOTACCESS') . "</font>";
            $optionvalue[] = array($not_access_lbl, trim($selected_entries_value), 'selected',$pickcolors[trim($selected_entries_value)]);
        }
    }
    if($bigtype === 'picklist_key') {
        return [
            'option' => $optionvalue,
            'selectedIndex' => $selectedIndex,
        ];
    }
    return $optionvalue;
}
?>