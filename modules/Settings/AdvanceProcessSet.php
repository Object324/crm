<?php
/*
 * edit:duan
 * date:20231117
 * reason:推进流程图后台设置界面
 * */

global $adb,$current_user;
crm_load_class_file('cls_module_advance','modules/Settings');
crm_load_class_file('cls_advance_process','modules/lingdang');

$modulename = $_REQUEST['modulename'];
$sub_mode = $_REQUEST['sub_mode'];
if($modulename == 'Events'){
    $modulename = 'Calendar';
}
$return_arr = [];
if(!empty($modulename)){
    $fieldname = $_REQUEST['fieldname'];
    //获取当前模块设置内容
    $cls_module_advance_obj =  cls_module_advance::getInstance($modulename);
    $advance_processobj = cls_advance_process::getInstance($modulename);
    if($sub_mode == 'preview'){
        $return_arr['moduleadvance'] = $cls_module_advance_obj->getModuleAdvance();
        $return_arr['stepinfo'] = $advance_processobj->getNodeSetting('');
        $return_arr['label_arr'] = getLabelArr();
    }elseif($sub_mode == 'popupset'){

        $module_advance = $cls_module_advance_obj->getModuleAdvance();
        $showwtype = $module_advance['defaultshow'];
        $module_advance['defaultshow'] = empty($showwtype)?'yes':$showwtype;
        $return_arr['moduleadvance'] = $module_advance;

        //获取推进可设置选项
        $advance_setting = get_advace_setting($modulename);
        $return_arr['checkbox'] = $advance_setting['checkbox'];
        $return_arr['selectdom'] = $advance_setting['selectdom'];

        $return_arr['label_arr'] = getLabelArr();
        if($module_advance['method'] == 'field'){
            $return_arr['stepinfo'] = $advance_processobj->getNodeSetting('');
            $return_arr['picklistcontent'] = $cls_module_advance_obj->getAdvanceStageValues();
        }else{
            $return_arr['stepinfo'] = [];
            $return_arr['picklistcontent'] = [];
        }
        $return_arr['oktext']=getFixedLabel("SAVE");
        $return_arr['canceltext']=getFixedLabel("CANCEL");
        $return_arr['title']=getFixedLabel('SFAProgress');
    }else if($sub_mode == 'getpicklist'){
        if(!empty($fieldname)){
            $return_arr['picklistcontent'] = $cls_module_advance_obj->getAdvanceStageValuesbyfiled($fieldname);
            $return_arr['stepinfo'] = $advance_processobj->getNodeSetting($fieldname);
        }else{
            $return_arr['picklistcontent'] = [];
            $return_arr['stepinfo'] = [];
        }

    }else if($sub_mode ==  'getadvancelist'){
        $cls_module_advance_obj->moduleadvance['module_field'] = $fieldname;
        $allAdvanceRelation = $cls_module_advance_obj->getAdvanceRelations($fieldname);

        $stagevalue = $_REQUEST['stagevalue'];
        $tmp_info = $allAdvanceRelation[$stagevalue];
        if(!empty($stagevalue) && !empty($tmp_info)){
            foreach ($tmp_info as $tmp_key => &$tmp_item){
                $tmp_item['stagevalue'] = $tmp_key;
            }
            $new_arr = array_values($tmp_info);
            $return_arr['advancerelation'] = $new_arr;
        }else{
            $return_arr['advancerelation'] = [];
        }
    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$return_arr,"success");

function get_advace_setting($module){
    //获取当前模块的所有设置信息
    $focus=CRMEntity::getInstance($module);
    $modulefields=$focus->fieldobj->getModuleFields();
    if(!empty($modulefields)){
        foreach($modulefields as $fieldname => $field){
            $uitype = $field->getUIType();
            $fieldtype = $field->getFieldDataType();
            $displaytype = $field->getDisplaytype();
            $tablename = $field->getTableName();
            if($tablename != $focus->table_name && $tablename != $focus->customFieldTable[0]){
                continue;
            }
            if($uitype == 15){
                $fieldname = $field->getFieldName();
                $fieldlabel = $field->getFieldLabelKey();
                $selectField[$fieldname] = $fieldlabel;
                $filedname_arr[] = $fieldname;
            }else if(($fieldtype == 'date' || $fieldtype == 'datetime') && $displaytype == 1){
                $fieldname = $field->getFieldName();
                $fieldlabel = $field->getFieldLabelKey();
                $selectFieldDate[$fieldname] = $fieldlabel;
            }
        }
    }

    $checkbox_arr = [];
    //PC端启用进度跟踪
    $checkbox_arr[] = ['divid'=>'enable','label'=>getFixedLabel('Enableprogresstracking')];
    //移动端启用进度跟踪
    $checkbox_arr[] = ['divid'=>'showadvancemobile','label'=>getFixedLabel('Enableprogresstrackingonmobile')];
    //详情页默认展开
    $checkbox_arr[] = ['divid'=>'defaultshow','label'=>getFixedLabel('DETAILPAGESHOWTYPE')];

    $selectdom_arr = [];
    //进度跟踪方式
    $selectdom_arr[] = ['divid'=>'method','label'=>getFixedLabel('Progresstrackingmethod'),
        'option'=>[
            'field'=>getFixedLabel('Byspecifiedfield'),
            'period'=>getFixedLabel('Byspecifiedperiod')
        ]];
    //显示推进人和时间
    $selectdom_arr[] = ['divid'=>'showadvancelog','label'=>getFixedLabel('Showadvancelog'),
        'option'=>[
            'no'=>getFixedLabel('HIDE'),
            'getin'=>getFixedLabel('ENTERPUSHERTIME'),
            'getout'=>getFixedLabel('LEAVEPUSHERTIME')
        ]];
    //推进操作显示样式
    $selectdom_arr[] = ['divid'=>'operatestyle','label'=>getFixedLabel('PUSHOPERAATIONSTYLE'),
        'option'=>[
            'underadvance'=>getFixedLabel('BELOWPROPULSIONLOG'),
            'inpopup'=>getFixedLabel('NEWDIALOG')
        ]];
    //推进日志显示样式
    $selectdom_arr[] = ['divid'=>'logshowstyle','label'=>getFixedLabel('PUSHLOGSTYLE'),
        'option'=>[
            'inpopup'=>getFixedLabel('UNDERADVANCENODE'),
            'underadvance'=>getFixedLabel('TILEBELOWNODE')
        ]];
    //选择跟踪字段
    $selectdom_arr[] = ['divid'=>'module_field','label'=>getFixedLabel('Selecttrackingfield'),'option'=>$selectField];
    //选择起始日期字段
    $selectdom_arr[] = ['divid'=>'module_period_start_date_field','label'=>getFixedLabel('Selectstartdatefield'),'option'=>$selectFieldDate];
    //选择截止日期字段
    $selectdom_arr[] = ['divid'=>'module_period_end_date_field','label'=>getFixedLabel('Selectenddatefield'),'option'=>$selectFieldDate];
    //停留时长计算方法
    $selectdom_arr[] = ['divid'=>'staytimemethod','label'=>getFixedLabel('DURATIONMETHOD'),
        'option'=>[
            'getlast'=>getFixedLabel('LATESTDURATION'),
            'sum'=>getFixedLabel('TOTALDURATION')
        ]];

    return ['checkbox'=>$checkbox_arr,'selectdom'=>$selectdom_arr];
}

function getLabelArr(){
    $label_arr=array(
        'BASICINFORMATION',//基本信息
        'CURRENTSTAGE',//当前阶段
        'addcondition',//添加条件
        'ConditionBranch',//条件分支
        'endworkflow',//流程结束
        'STEPNAME',//步骤名称
        'STEP',//步骤
        'SETSTEPINFORMATION',//请设置步骤信息
    );
    $fieldlabel_arr = TransFieldlabel($label_arr,'no');
    return $fieldlabel_arr;
}

?>