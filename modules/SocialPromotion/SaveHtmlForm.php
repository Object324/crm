<?php
/**
 * 社交推广外部访问保存form的数据
 *
 */


require_once ('ExternalAccessRequire.php');

global  $adb ,$currentModule,$current_user;
//假的当前用户id
$current_user->id =1;
$currentModule ='SocialPromotion';

$record = intval(vtlib_purify($_REQUEST['record']));
$userid = intval(vtlib_purify($_REQUEST['uid']));
$userid = !empty($userid)?$userid:1;
$mappingmodule = strval(vtlib_purify($_REQUEST['mappingmodule']));
//end
$_REQUEST['diony']='yes';

$focus = CRMEntity::getInstance($currentModule);
$focus->id =$record;
$focus->mode = 'edit';
$focus->retrieve_entity_info($focus->id, $currentModule);
//获取自定义字段信息
require_once ($root_dir.'modules/SocialPromotion/SocialPromotionForm.php');
$sForm = new SocialPromotionForm($focus->column_fields);

//判断post数据在对应模块中是否唯一
$onlyStatus = 1;
$accountnameStatus =1;
//$statusMsg='创建成功';
$statusMsg=getFixedLabel('SOCIALPROMOTIONCREATESUCCESS');

$onlyFields = $sForm->getOlnyFields();
$mFouce = CRMEntity::getInstance($mappingmodule);
$mTable=$mFouce->tab_name;
$mTableIndex=$mFouce->tab_name_index;
foreach ($onlyFields as $field){
    if($field['module'] == $mappingmodule){
        if($field['isfixedtable'] == 1){
            $table  =$mTable[1];
        }else{
            $table = $mTable[2];
        }
        $tableIndex =$mTableIndex[$table];
    }else{
        //字段不属于映射模块的 主要是映射客户模块的默认字段中的lastname和mobile
        $tmpFouce = CRMEntity::getInstance($field['module']);
        $table = $tmpFouce->table_name;
        $tableIndex =$tmpFouce->tab_name_index[$table];
    }
    //开始验证
    if($result = valueIsOnly($table,$tableIndex,$field)){
        $onlyStatus = -1;
//        $statusMsg='创建失败,原因：唯一性校验失败';
        $statusMsg=getFixedLabel('FAILEDTOCREATEREASON');
        break;
    }
}
//插入映射模块的数据的 arrar('accounts'=>'1')
$mappingmoduleid[$mappingmodule] = '';
if($mappingmodule=='Accounts'){
    $mappingmoduleid['Contacts'] = '';
}
if($onlyStatus != -1){
    //仅映射模块为客户时验证
    //特殊验证 客户模块 客户名称唯一性验证
    if($mappingmodule =='Accounts' ){
        $accountNameField = $sForm->getAccountNameField();
        if(is_array($accountNameField) && !empty($accountNameField)){
            if($accountNameField['isfixedtable'] == 1){
                $table  =$mTable[1];
            }else{
                $table = $mTable[2];
            }
            $tableIndex =$mTableIndex[$table];
        }
        if($accountid = valueIsOnly($table,$tableIndex,$accountNameField)){
            $accountnameStatus =-1;
            $onlyStatus =2;
            $statusMsg=getFixedLabel('USERALREADYEXISTSCONTACT');
            $statusMsg=str_replace('客户',getTranstab('Accounts'),$statusMsg);
            $statusMsg=str_replace('联系人',getTranstab('Contacts'),$statusMsg);
        }
    }


    //    唯一性校验成功插入数据
    //把所有自定义的字段按模块分组。
    $sForm->classification();
    //插入数据
    if($accountnameStatus != -1) {
        $mFouce = CRMEntity::getInstance($mappingmodule);
        //保存过程中operate_api 有判断 不设置会重置创建人
        $mFouce->operate_api = 'api';
        //保存单据前获取当前模块的单据编号
        $seqNum = $mFouce->Library('SystemCode')->getModuleSeqNumRecord($mappingmodule);
        $_REQUEST[$mFouce->table_code] = $seqNum;
        //ls 2022-03-25 0050618: （东方报警）http://82.156.43.185:85/crm/ [^]，营销管理——表单推广，通过表单推广扫码填信息生成的单据的单据负责人为空，而不是表单推广的负责人
        $_REQUEST['smcreatorid'] = $userid;
        $_REQUEST['smownerid'] = $userid;
        unset($_REQUEST['record']);
        setObjectValuesFromRequest($mFouce);
        $mFouce->column_fields['assigned_user_id'] = $focus->column_fields['assigned_user_id'];
        $mFouce->column_fields['smcreatorid'] = $focus->column_fields['assigned_user_id'];
        if($_REQUEST['uid'] > 0){
            $mFouce->column_fields['assigned_user_id'] = $_REQUEST['uid'];
            $mFouce->column_fields['smcreatorid'] = $_REQUEST['uid'];
        }
        $mFouce->save($mappingmodule);
        $mfouceId = $mFouce->id;
        $mappingmoduleid[$mappingmodule] = $mfouceId;
    }

    //映射客户模块的时候 有几个默认的字段是联系人模块的
    //判断对应联系人模块的字段是否为空。
    if ($mappingmodule == 'Accounts'){
        $subMmodule = 'Contacts';
        $mappingmoduleid[$subMmodule] = '';
        if(!empty($sForm->moduleFields[$subMmodule])){
            $subFouce = CRMEntity::getInstance($subMmodule);
            $subFouce->operate_api='api';
            $seqNum = $subFouce->Library('SystemCode')->getModuleSeqNumRecord($subMmodule);
            $_REQUEST[$mFouce->table_code] = $seqNum;
            //上一步保存的id
            if ($onlyStatus == 1) {
                $_REQUEST['account_id'] = $mfouceId;
            }
            if ($accountnameStatus == -1) {
                $mappingmoduleid[$mappingmodule] = $accountid;
                $_REQUEST['account_id'] = $accountid;
            }
            unset($_REQUEST['record']);
            setObjectValuesFromRequest($subFouce);
            $subFouce->column_fields['assigned_user_id'] = $focus->column_fields['assigned_user_id'];
            $subFouce->column_fields['smcreatorid'] = $focus->column_fields['assigned_user_id'];
            $subFouce->save($subMmodule);
            $mappingmoduleid[$subMmodule] = $subFouce->id;
        }
    }


}

$mappingmoduleid =str_replace('"','\"',json_encode($mappingmoduleid));
//保存数据
$return_id = $sForm->save(array('userid'=>$userid,'socialpromotionid'=>$record,'status'=>$onlyStatus,'statusmsg'=>$statusMsg,'mappingmoduleid'=>$mappingmoduleid));

//更新模块主表数据插入状态
//$sForm->updateStatus($return_id,$onlyStatus,$statusMsg,$mappingmoduleid);
//更新主表的表单数量
updataNum($focus->table_name,$record,$focus->table_index,'documentquantity');


ConvertTojsonString(1,array('onlyStatus'=>$onlyStatus,'accountnameStatus'=>$accountnameStatus),'success');


    /**
     * Name: 判断要插入对应模块的数据是否是唯一的
     * User: Dong
     * Date: 2020/7/7 16:30
     */
function valueIsOnly($table,$tableIndex,$field){
    global  $adb;
    $sql = 'select '.$tableIndex.','.$field['columnname'].' from '.$table.' where '.$field['columnname'].' = '.'\''.$field['value'].'\'';
    $result = $adb->pquery($sql);
    //客户模块的accountname不唯一 可能会取出多个值 只取第一个最新的
    if($adb->num_rows($result) >0){
        $value = $adb->query_result($result,0,0);
        return $value;
    }else{
        return  false;
    }
}

/**
 * Name: 更新模块表单单据个数
 * User: Dong
 * Date: 2020/7/7 18:40
 * @param $tableName
 * @param $record
 * @param $filedIndex
 * @param $fieldName
 */
function  updataNum($tableName,$record,$filedIndex,$fieldName){
    global $adb;
    $sql = 'update '.$tableName.' set '.$fieldName.'= '.$fieldName.'+1 where '.$filedIndex.'='.$record;
    $adb->pquery($sql);
}