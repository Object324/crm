<?php
global  $adb ,$currentModule;
$focus =CRMEntity::getInstance($currentModule);
if($_REQUEST['record']>0)
{
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
}

$search=vtlib_purify($_REQUEST['search_url']);
//加载类 获取表的名称
require_once ('SocialPromotionForm.php');
$form = new SocialPromotionForm('');
$fixedTableName = $form->fixedTableName;
$customTableName = $form->customTableName;

$fsArray = array();
if(!empty($_REQUEST['customFieldsNum'])){
    foreach ($_REQUEST as $key =>$value){
        if(strstr($key,'fs_')){
            $tmpArr = explode('_',$key);
            $num = $tmpArr[2];
            $fsArray[$num][$tmpArr[1]] =$value;
        }
    }
    foreach ($fsArray as $key => $field){
        $fieldName =$field['columnname'];
        $bigtype =$field['bigtype'];
        // @edit:dong @date:2020-07-14 @reason:  字段规则暂不判断
        $typeofdata =explode('~',$field['typeofdata']);
        //是否是主表字段 1是 0 否
        $isfixedtable = $field['isfixedtable'];
        //区分固定字段还是自定义字段
        $isfixedtable == 1 ? $table = $fixedTableName: $table = $customTableName;

        $columnLen =0; //数据库字段长度
        $fieldType= ''; //数据库字段类型
        switch($bigtype){
            case 'text':
            case 'textarea':
            case 'longtextarea':
                $fieldType = 'text';
                break;
            case 'number':
                $fieldType = 'int';
                $columnLen =19;
                break;
            case 'datetime':
                $fieldType = 'datetime';
                break;
            case 'date':
                $fieldType='date';
                break;
            case 'time':
                $fieldType='time';
                break;
            default:
                $fieldType='varchar';
                $columnLen=255;
        }

        //动态往 ld_socialpromotionformfixed 表增加字段
        // @edit:dong @date:2020/07/16 @reason: 暂不使用存储过程 使用sql判断
        $findSql = 'SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME= ? AND COLUMN_NAME=?';
        $findResult = $adb->pquery($findSql,array($table,$fieldName));
        $num_row = $adb->num_rows($findResult);
        if($num_row == 0){
            $addColumnSql = 'ALTER TABLE '.$table.' ADD '.$fieldName.' '.$fieldType.'('.$columnLen.') NULL;';
            $adb->pquery($addColumnSql);
            //暂不使用存储过程
            //$adb->pquery("call AddColumn('ld_socialpromotionformfixed','potentialid','int','11',0)",array());
//            $adb->pquery("CALL AddColumn(?,?,?,?,0)",array($table,$fieldName,$fieldType,$columnLen));
        }
    }

    $_REQUEST['customfieldsorder'] = ldcrm_json_encode($fsArray);
}

setObjectValuesFromRequest($focus);

$focus->save($currentModule);
$return_id = $focus->id;
$focus->retrieve_entity_info($focus->id, $currentModule);
$socialpromotion_no =$focus->column_fields['socialpromotion_no'];
$smownerid =$focus->column_fields['smownerid'];
$smcreatorid = $focus->column_fields['smcreatorid'];

//获取post的共享单据的用户id 插入数据库
$newShareUsers = $_REQUEST['newShareUsers'];
//第三步分享设置，共享给其他人 确认后已经调用公共方法了，保存就不需要了，否则提醒重复
if(empty($_REQUEST['record'])){
    crm_load_class_file('cls_share','include/Functions/Share');
    $objShare = new cls_share();
    $recordArr = $objShare->check_permit($currentModule,$return_id,'',$newShareUsers,'detailview');
}

//返回数据 第四步要用
$_REQUEST['newShareUsers'] = $newShareUsers;
$_REQUEST['socialpromotion_no'] =$socialpromotion_no;
if($focus->column_fields['social_activitytype'] =='仅表单'){
    $_REQUEST['form'] = 0;
}else{
    $_REQUEST['form'] = 1;
}

$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
// 模块下的socialpromotion类中重写ReturnAfterSave;
$focus->ReturnAfterSave($before_columnfieldvalue);
?>