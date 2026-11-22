<?php
/*
edit:duan
date:2021-9-28
增加搜索历史功能
*/
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$_REQUEST['diony']='yes';
$searchtype = $_REQUEST['searchtype'];
if($searchtype!='BasicSearch' &&$searchtype!='advance'&&$searchtype!='TiledSearch'&&$searchtype!='tiled'){
    ConvertToJsonString(-1,array(),'success');
}
$module = $_REQUEST['module'];
//zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
if($module == 'Approve'&& isset($_REQUEST['searchmodule']))
{
    $module=$_REQUEST['searchmodule'];
}
$mode = $_REQUEST['mode'];
$smownerid = $current_user->id;
$arr = array();
$smarty = new lingdangCRM_Smarty();
$history_limit = 10; //搜索历史上限10条
if($searchtype=='tiled'){
    $history_limit = 1; //平铺查找搜索历史保存一条
}
$searchfrom=$_REQUEST['searchfrom'];
$smarty->assign('searchfrom',$searchfrom);
if(isset($_REQUEST['advancefiltersearch']) && !empty($_REQUEST['advancefiltersearch'])){
    $smarty->assign('advancefiltersearch',$_REQUEST['advancefiltersearch']);
}
//保存搜索历史
if($mode == 'save'){
    $searchtime = date('Y-m-d H:i:s');
    if($searchtype=='BasicSearch'){
        $search_field = $_REQUEST['search_field'];
        $search_text = $_REQUEST['search_text'];
        //基本查询关键字为空时不保存，高级查询因为条件比较复杂，需要保存空关键字
        if(empty($search_text)||trim($search_text)==""){
            ConvertToJsonString(-1,array(),'success');
        }
        if(strpos($search_text,"\\")!==false){
            $search_text = stripslashes($search_text);
        }

        $searchvalue = array('search_field'=>$search_field,'search_text'=>$search_text);
        $searchvalue_json = ldcrm_json_encode($searchvalue); //以json格式保存查询条件
    }else if($searchtype=='advance'||$searchtype=='tiled'||$searchtype=='TiledSearch'){
        $advft_criteria = ldcrm_json_decode($_REQUEST['advft_criteria']);
        $advft_criteria = advft_stripslashes($advft_criteria);
        $advft_criteria_groups = ldcrm_json_decode($_REQUEST['advft_criteria_groups']);
        $searchvalue = array('advft_criteria'=>$advft_criteria,'advft_criteria_groups'=>$advft_criteria_groups);
        $searchvalue_json = ldcrm_json_encode($searchvalue); //以json格式保存查询条件
    }
    //---2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
    //客户地图只保存一条数据
    if($module=="ChinaMap"&&$searchtype=='TiledSearch'){
        $sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and searchtype = ? and searchfrom=?  ';
        $result = $adb->pquery($sql,array($module,$searchtype,$searchfrom));
    }else{
        $sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ? and searchfrom=? order by searchtime desc';
        $result = $adb->pquery($sql,array($module,$smownerid,$searchtype,$searchfrom));
    }

    $num_rows = $adb->num_rows($result);
    $old_history = 'no';
    //判断新搜索历史与原有的历史是否相同
    if($num_rows >0){
        for($i=0;$i<$num_rows;$i++){
            $tmp_id = $adb->query_result($result,$i,'id');
            $tmp_searchvalue_json = $adb->query_result($result,$i,'searchvalue');
            $tmp_searchvalue = ldcrm_json_decode($tmp_searchvalue_json);
            if($searchtype=='BasicSearch'){
                $tmp_search_field = $tmp_searchvalue['search_field'];
                $tmp_search_field_arr = explode(':',$tmp_search_field);
                if(sizeof($tmp_search_field_arr)>1){
                    $tmp_columnname = $tmp_search_field_arr[1];
                }else{
                    $tmp_columnname = $tmp_search_field;
                }
                
                $search_field = $searchvalue['search_field'];
                $search_field_arr = explode(':',$search_field);
                if(sizeof($search_field_arr)>1){
                    $columnname = $search_field_arr[1];
                }else{
                    $columnname = $search_field;
                }
                if(strpos($tmp_searchvalue['search_text'],"\\")!==false){
                    $tmp_searchvalue['search_text'] = stripslashes($tmp_searchvalue['search_text']);
                }
                
                if($tmp_columnname==$columnname&&$tmp_searchvalue['search_text']==$searchvalue['search_text']){
                    $sql = 'update ld_searchhistory set searchtime = ? where id = ?';
                    $adb->pquery($sql,array($searchtime,$tmp_id));
                    $old_history = 'yes';
                    break;
                }
            }else if($searchtype=='advance'){
                //高级查询判断是否相同时有拓展空间，单独拿出来，方便以后修改
                $tmp_searchvalue['advft_criteria'] = advft_stripslashes($tmp_searchvalue['advft_criteria']);
                if(CompareHistory($tmp_searchvalue,$searchvalue) == 'yes'){
                    $sql = 'update ld_searchhistory set searchtime = ? where id = ?';
                    $adb->pquery($sql,array($searchtime,$tmp_id));
                    $old_history = 'yes';
                    break;
                }
            }
        }
        //原有历史不存在则新加历史
        if($old_history=='no'&&$module!="ChinaMap"&$searchtype!='TiledSearch'){
            //超过上限之后替换最旧的搜索历史
            if($num_rows<$history_limit){
                $sql = 'insert into ld_searchhistory(modulename,smownerid,searchtype,searchvalue,searchtime,searchfrom) values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($module,$smownerid,$searchtype,$searchvalue_json,$searchtime,$searchfrom));
            }else{
                $sql = 'update ld_searchhistory set searchtime = ?,searchvalue = ? where id = ?';
                $adb->pquery($sql,array($searchtime,$searchvalue_json,$tmp_id));
            } 
        }else if($old_history=='no'&&$module=="ChinaMap"&$searchtype=='TiledSearch'){
            //--2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $sql = 'update ld_searchhistory set searchtime = ?,searchvalue = ? where id = ?';
            $adb->pquery($sql,array($searchtime,$searchvalue_json,$tmp_id));
        }
    }else{
        $sql = 'insert into ld_searchhistory(modulename,smownerid,searchtype,searchvalue,searchtime,searchfrom) values(?,?,?,?,?,?)';
        $adb->pquery($sql,array($module,$smownerid,$searchtype,$searchvalue_json,$searchtime,$searchfrom));
    }
}
else if($mode=='showhistory'){
    //显示搜索历史
    $focus = CRMEntity::getInstance($module);
    $sql = 'select id,searchvalue,searchtime from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ? and searchfrom=? order by searchtime desc limit ?';
    $result = $adb->pquery($sql,array($module,$smownerid,$searchtype,$searchfrom,$history_limit));
    $num_rows = $adb->num_rows($result);
    
    if($num_rows>0){
        $searchvalue_arr = array();
        /*$searchvalue_arr_new = array();// zxm 20221205新的基本搜索 按字段搜索*/
        for($i=0;$i<$num_rows;$i++){
            //读取所有搜索历史
            $tmp_id = $adb->query_result($result,$i,'id');
            $tmp_searchvalue_json = $adb->query_result($result,$i,'searchvalue');
            $tmp_searchtime = $adb->query_result($result,$i,'searchtime');
            //ljj 20240717 BUG20240715-01 销售机会搜索栏，其中搜索内容包含“&”符号的话，搜索历史中将此符号转化为“\u0026”
            $tmp_searchvalue = json_decode($tmp_searchvalue_json,true);
//            $tmp_searchvalue = ldcrm_json_decode($tmp_searchvalue_json);
            $tmp_arr = array('id'=>$tmp_id,'searchvalue'=>$tmp_searchvalue);
            //搜索历史显示内容
            if($searchtype == 'BasicSearch'){
                $search_field = $tmp_searchvalue['search_field'];
                $search_field_arr = explode(':',$search_field);
                if(sizeof($search_field_arr)>1){
                    $fieldname = $search_field_arr[2];
                    $columnname = $search_field_arr[1];
                    //BUG20240814-48 ls240816 客户管理--基本查找，查找联系人字段（非首要联系人字段）不显示历史记录
                    $tmp_modulename = explode('_',$search_field_arr[3])[0];
                    if ($focus->moduleName == 'Accounts' && $tmp_modulename== 'Contacts') {
                        $focus = CRMEntity::getInstance($tmp_modulename);
                    }
                }else{
                    $fieldname = $search_field_arr[0];
                }
                $fieldlabel = $focus->fieldobj->getFieldInfoBykeyValue('fieldname',$fieldname,'fieldlabel');
                //单据分录字段
                if(empty($fieldlabel)){
                    //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
                    if($fieldname=='all'){
                        $fieldlabel = getFixedLabel('AllFields');
                    }else{
                        if(empty($focus->detailfieldobj)){
                            continue;
                        }
                        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
                        if(empty($fieldinfo)){
                            //如果字段信息还是空说明字段未启用
                            continue;
                        }
                        $fieldlabel = $fieldinfo->getFieldLabelKey();
                    }
                }
                $tmp_arr['label']= $fieldlabel.'： '.$tmp_searchvalue['search_text'];

                // zxm 20221205新的基本搜索 按字段搜索
                /*if(isset($_REQUEST['fieldinfo'])&&!empty($_REQUEST['fieldinfo'])&&$_REQUEST['fieldinfo']==$search_field){
                    $basickeywords = $_REQUEST['basickeywords'];
                    if(!empty($basickeywords)&&strpos($tmp_searchvalue['search_text'],$basickeywords)!==FALSE){
                        $searchvalue_arr_new[$i] = $tmp_searchvalue['search_text'];
                    }
                    if(empty($basickeywords)){
                        $searchvalue_arr_new[$i] = $tmp_searchvalue['search_text'];
                    }
                }*/
            }
            else if($searchtype == 'advance'){
                $adv_filter_options = getAdvCriteria();//高级查询条件
                $advft_criteria = $tmp_searchvalue['advft_criteria'];
                $advft_criteria_groups = $tmp_searchvalue['advft_criteria_groups'];
                $label = "";
                
                foreach($advft_criteria as $key=>$value){
                    if(empty($value)){
                        continue;
                    }
                    $search_field = $value['columnname'];
                    $search_field_arr = explode(':',$search_field);
                    if(sizeof($search_field_arr)>1){
                        $fieldname = $search_field_arr[2];
                    }else{
                        $fieldname = $search_field_arr[0];
                    }
                    $fieldlabel = '';
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                    if(!empty($fieldinfo)){
                        $fieldlabel = $fieldinfo->getFieldLabelKey();
                    }
                    
                    if(empty($fieldlabel)){//字段翻译为空则检查单据分录字段
                        if(empty($focus->detailfieldobj)){
                            continue;
                        }
                        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey('columnname',$fieldname);
                        if(empty($fieldinfo)){
                            //如果字段信息还是空说明字段未启用
                            continue;
                        }
                        $fieldlabel = $fieldinfo->getFieldLabelKey();
                    }
                   
                    $comparator = $value['comparator'];//高级查询条件
                    if(array_key_exists($comparator,$adv_filter_options)){
                        if($comparator == 'curuser' &&Field::user_multi_fields($fieldinfo->getUIType())){
                            $comparator_label = getFixedLabel('INCULDECURUSER');
                        }
                        else{
                            $comparator_label = $adv_filter_options[$comparator];
                        }
                    }else{
                        //不在通用条件中则获取翻译
                        $comparator_label = getFixedLabel($comparator);
                    }
                    if($label!=""){
                        $label.=' | ';
                    }
                    
                    //把且、或条件也显示出来,但效果不好，先隐藏，有需要再显示
                    /*
                    if(!empty($condition)){ //每行
                        $label.=' '.$adv_filter_options[$condition].' ';
                    }else if(!empty($group_condition)&&$value['groupid']!=$groupid){ //查询组之间
                        $label.=' | '.$adv_filter_options[$group_condition].' | ';
                    }else{
                        if($label!=""){
                            $label.=' | ';
                        }
                    }
                    $condition = $value['columncondition'];
                    $groupid = $value['groupid'];
                    $group_condition = $advft_criteria_groups[$groupid]['groupcondition'];
                    */
                    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                    $valueLabel = $value['value'];
                    if(isset($value['valueLabel'])) {
                        $valueLabel = $value['valueLabel'];
                    }
                    
                    $label .= $fieldlabel.' '.$comparator_label.' '.$valueLabel;
                }
                if($label==""){
                    continue;
                }
                $tmp_arr['label'] = $label;
            }
            $searchvalue_arr[]=$tmp_arr;
        }
    }
    // zxm 20221205新的基本搜索 按字段搜索
    if(isset($_REQUEST['newbasicsearch'])&&$_REQUEST['newbasicsearch']=='yes'){
        $code = -1;
        if(!empty($searchvalue_arr)){
            $code = 1;
        }
        ConvertToJsonString($code,['searchvalue_arr'=>$searchvalue_arr,'clearlabel'=>getFixedLabel('CELARALL').getFixedLabel('SEARCHHISTORY')],'success');
    }
    $smarty->assign('divid',$_REQUEST['divid']);
    $smarty->assign('searchtype',$searchtype);
    $smarty->assign('SEARCHVALUEARR',$searchvalue_arr);
    $smarty->assign('newAdvanceFilter',$_REQUEST['newAdvanceFilter']);

    $arr['num_rows'] = $num_rows;
    $arr['content'] = $smarty->fetch('SearchHistory.tpl');
}else if ($mode=='clearhistory'){
    //清空搜索历史
    $sql = 'delete from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ? and searchfrom=?';
    $adb->pquery($sql,array($module,$smownerid,$searchtype,$searchfrom));
    $smarty->assign('searchtype',$searchtype);
    $arr['num_rows'] = 0;
    $arr['content'] = $smarty->fetch('SearchHistory.tpl');
    //2023-4-26 BUG0063913 fengxh 当查询为空时返回emptycontent，使显示正常
    $arr['emptycontent'] = 
    '<select class="commonSelectPop gwidth90">
    <option>'.getFixedLabel('NOTTOEXIST').getFixedLabel('SEARCHHISTORY').'</option>
    </select>';
}else if ($mode == 'choosehistory'){
    //高级搜索选择历史后带出查询条件
    $id = $_REQUEST['id'];
    $sql = 'select searchvalue from ld_searchhistory where id = ?';
    $result = $adb->pquery($sql,array($id));
    $searchvalue_json = $adb->query_result($result,0,'searchvalue');
    $searchvalue = ldcrm_json_decode($searchvalue_json);
    $advft_criteria = advft_stripslashes($searchvalue['advft_criteria']);

	$advft_criteria_groups = $searchvalue['advft_criteria_groups'];
    $customView = CustomView::getInstance($module);
    $queryGenerator =QueryGenerator::getInstance($module, $current_user,$customView);
    $advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $module,$queryGenerator);
    $arr['criteria_groups'] = $advfilterlist;
}

ConvertToJsonString(1,$arr,'success');

//比较两个高级搜索记录是否相同
function CompareHistory($tmp_searchvalue,$searchvalue){
    $advft_criteria = $searchvalue['advft_criteria'];
    $advft_criteria_groups = $searchvalue['advft_criteria_groups'];
    $tmp_advft_criteria = $tmp_searchvalue['advft_criteria'];
    $tmp_advft_criteria_groups = $tmp_searchvalue['advft_criteria_groups'];
    //判断条件数量是否相同
    if(sizeof($advft_criteria)!=sizeof($tmp_advft_criteria) ||sizeof($advft_criteria_groups)!=sizeof($tmp_advft_criteria_groups)){
        return 'no';
    }
    //判断搜索组合之间的关系是否相同
    if(sizeof($advft_criteria_groups)>=2){
        foreach($advft_criteria_groups as $key => $value){
            if($value['groupcondition']!=$tmp_advft_criteria_groups[$key]['groupcondition']){
                return 'no';
            }
        }
    }
    //判断搜索条件是否相同
    foreach($advft_criteria as $key=>$value){
        foreach($value as $tmp_key =>$tmp_value){
            if($tmp_advft_criteria[$key][$tmp_key]!=$tmp_value){
                return 'no';
            }
        }
    }
    return 'yes';
}
//高级查询条件
function getAdvCriteria(){
    $adv_filter_options = array(
        "e" => "" . getFixedLabel('EQ') . "",
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
        "curuser" => getFixedLabel('CURUSER'),
        "belong" => getFixedLabel('BELONG'),
        "notbelong" => getFixedLabel('NOTBELONG'),
        "new_belong" => getFixedLabel('BELONG'),
        "new_notbelong" => getFixedLabel('NOTBELONG'),
    );
    return $adv_filter_options;
}
//对查询条件中的特殊字符进行反转义
function advft_stripslashes($advft_criteria){
    foreach ($advft_criteria as $tmp_key=>$tmp_arr){
        if(strpos((string)$tmp_arr['value'],"\\")!==false){
            $advft_criteria[$tmp_key]['value'] = stripslashes((string)$tmp_arr['value']);
        }
    }
    return $advft_criteria;
}


?>