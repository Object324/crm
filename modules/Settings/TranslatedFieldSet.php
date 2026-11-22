<?php
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$mode = $_REQUEST['mode'];
if(isset($_REQUEST['frommodule'])){
    $frommodule = $_REQUEST['frommodule'];
}else{
    $frommodule = 'lingdang';
}
if(isset($_REQUEST['columnname'])){
    $columnname = $_REQUEST['columnname'];
}else{
    $columnname = 'approvestatus';
}
//记录原始值跟labelbol的对应关系，编辑和保存都用得到
$origin_arr = [];
if($columnname == 'approvestatus'){
    $origin_arr[constant('D_A_S_UNAPPROVED')] = 'APPROVESTATUS_UNAPPROVED';//'未提交'
    $origin_arr[constant('D_A_S_APPROVALOF')] = 'APPROVESTATUS_APPROVALOF';//'审批中'
    $origin_arr[constant('D_A_S_APPROVED')] = 'APPROVESTATUS_APPROVED';//'已批准'
    $origin_arr[constant('D_A_S_DISMISSED')] = 'APPROVESTATUS_DISMISSED';//'已驳回'
    $origin_arr[constant('D_A_S_REJECTED')] = 'APPROVESTATUS_REJECTED';//'已拒绝'
}
$return_arr = array();
if($mode == 'edit'){
    $smarty=new lingdangCRM_Smarty;
    $translate_sql = 'SELECT a.column_Dbvalue,a.labelbol,a.value_color,b.languagetype,b.fieldlabel from ld_translatefield a INNER JOIN ld_desk b on a.labelbol = b.labelbol
        where a.module = ? and a.columnname = ? and b.Labeltype = ? ';
    $translate_result = $adb->pquery($translate_sql,[$frommodule,$columnname,'fixedstr']);
    $num_rows = $adb->num_rows($translate_result);
    //生成原始数据
    $translate_label_arr = [];
    foreach ($origin_arr as $tmp_dbvalue => $tmp_labelbol ){
        $translate_label_arr[$tmp_dbvalue] = ['labelbol'=>$tmp_labelbol,'origin_label'=>$tmp_dbvalue,'show_label_zh'=>$tmp_dbvalue,'show_label_en'=>$tmp_dbvalue,'value_color'=>''];
    }
    //如果存在模块自定义设置，则覆盖
    if($num_rows > 0){
        $all_result_arr = $adb->query_result_all($translate_result);

        foreach ($all_result_arr as $tmp_arr){
            $tmp_dbvalue = $tmp_arr['column_dbvalue'];
            $tmp_fieldlabel = html_entity_decode($tmp_arr['fieldlabel']);
            $tmp_value_color = $tmp_arr['value_color'];
            $tmp_labelbol = $tmp_arr['labelbol'];

            if(isset($translate_label_arr[$tmp_dbvalue])){
                if($tmp_arr['languagetype'] == 'zh'){
                    $translate_label_arr[$tmp_dbvalue]['show_label_zh'] = $tmp_fieldlabel;
                }else{
                    $translate_label_arr[$tmp_dbvalue]['show_label_en'] = $tmp_fieldlabel;
                }
                $translate_label_arr[$tmp_dbvalue]['labelbol'] = $tmp_labelbol;
                $translate_label_arr[$tmp_dbvalue]['value_color'] = $tmp_value_color;
            }else{
                $translate_label_arr[$tmp_dbvalue] = ['labelbol'=>$tmp_labelbol,'origin_label'=>$tmp_dbvalue,'value_color'=>$tmp_value_color];
                if($tmp_arr['languagetype'] == 'zh'){
                    $translate_label_arr[$tmp_dbvalue]['show_label_zh'] = $tmp_fieldlabel;
                }else{
                    $translate_label_arr[$tmp_dbvalue]['show_label_en'] = $tmp_fieldlabel;
                }
            }
        }
    }
    $smarty->assign('COLUMNNAME',$columnname);
    $smarty->assign('TRANSLATE_LABEL_ARR',array_values($translate_label_arr));
    $return_arr['title'] = getFixedLabel('APPROVALSTATUSSETTING');
    $return_arr['oktext'] = getFixedLabel('SAVE');
    $return_arr['canceltext'] = getFixedLabel('CANCEL');
    $return_arr['content']= $smarty->fetch('Settings/TranslatedFieldSet.tpl');
}elseif($mode == 'save'){
    $translateset_info = $_REQUEST['translateset_info'];

    $translate_sql = 'SELECT id,labelbol from ld_translatefield where module = ? and columnname = ?  ';
    $translate_result = $adb->pquery($translate_sql,[$frommodule,$columnname]);
    $num_rows = $adb->num_rows($translate_result);
    $old_labelbol_arr = [];
    if($num_rows > 0) {
        $all_result_arr = $adb->query_result_all($translate_result);
        foreach ($all_result_arr as $tmp_arr){
            $old_labelbol_arr[$tmp_arr['id']] = $tmp_arr['labelbol'];
        }
    }
    foreach ($translateset_info as $tmp_info){
        $labelbol = $tmp_info['labelbol'];
        $dbvalue = $tmp_info['dbvalue'];
        $show_label_zh = $tmp_info['show_label_zh'];
        $show_label_en = $tmp_info['show_label_en'];
        $value_color = $tmp_info['value_color'];
        if(in_array($labelbol,$old_labelbol_arr)){
            $trans_id = array_search($labelbol,$old_labelbol_arr);
            $new_labelbol = $labelbol;
            $tmp_sql = 'UPDATE ld_translatefield set value_color = ? where id = ?';
            $adb->pquery($tmp_sql,[$value_color,$trans_id]);
        }else{
            //添加翻译字段设置
            if($frommodule == 'lingdang'){
                $new_labelbol = $labelbol;
            }else{
                $new_labelbol = $labelbol.'_'.$frommodule;
            }

            $tmp_sql = 'insert into ld_translatefield(columnname,column_dbvalue,module,labelbol,value_color) value(?,?,?,?,?)';
            $adb->pquery($tmp_sql,[$columnname,$dbvalue,$frommodule,$new_labelbol,$value_color]);
        }

        $select_sql = 'select 1 from ld_desk where labelbol = ?';
        $select_result = $adb->pquery($select_sql,[$new_labelbol]);
        if($adb->num_rows($select_result) > 0){
            $tmp_sql = 'UPDATE ld_desk SET fieldlabel = ? where labelbol = ? AND Labeltype = ? AND languagetype = ? ';
            $adb->pquery($tmp_sql,[$show_label_zh,$new_labelbol,'fixedstr','zh']);
            $adb->pquery($tmp_sql,[$show_label_en,$new_labelbol,'fixedstr','en']);
        }else{
            //添加翻译内容
            $tmp_sql = 'INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) value(?,?,?,?)';
            $adb->pquery($tmp_sql,['zh',$new_labelbol,$show_label_zh,'fixedstr']);
            $adb->pquery($tmp_sql,['en',$new_labelbol,$show_label_en,'fixedstr']);
        }

    }
    //清除翻译字段缓存
    $cache_key = 'translatefield_dbvalue_cache';
    unsetCache($cache_key);
    //清除语言包缓存
    @unlink(globalStatic::$root_directory.'include/language/zh.php');
    @unlink(globalStatic::$root_directory.'include/language/en.php');
    setFixedLable($current_user);//重新生成语言包
}



$_REQUEST['diony'] = 'yes';


ConvertTojsonString(1, $return_arr, 'success');
?>