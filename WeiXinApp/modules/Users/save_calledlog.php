<?php
global $adb,$current_user;
$_REQUEST['diony'] = 'yes';
$modulename = $_REQUEST['fld_module'];//当前模块
$recordid = $_REQUEST['record'];//关联单据信息
$fieldname = $_REQUEST['fieldname'];//拨打电话选择的字段名称
$phonenum = $_REQUEST['fieldvalue'];//电话号码
$calleduserid = $current_user->id;//拨打人id
$query = "Insert into ld_module_calledlog (modulename, record, fieldname, phonenum, calleduserid) values (?,?,?,?,?)";
$params = array($modulename,$recordid,$fieldname,$phonenum,$calleduserid);
$result = $adb->pquery($query, $params);

//获取相关信息
$module_arr = array('ContactRecords','VendorContactRecords'); //需要关联创建的模块
$tabid_arr = array();
if(sizeof($module_arr)>0){
    foreach($module_arr as $tmp_module){
        $tmp_tabid = getTabid($tmp_module);
        $tabid_arr[] = $tmp_tabid;
    }
    foreach($module_arr as $tmp_module){
        if(isPermitted($tmp_module, 'Create', '') == 'yes'){
            $label = getTranstab($tmp_module);
            $sql = 'SELECT relation_id,related_tabid from ld_relatedlists where tabid = ? AND related_tabid in ('.implode(',',$tabid_arr).');';
            $result = $adb->pquery($sql,array(getTabid($modulename)));
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){
                for($i = 0; $i < $num_rows; $i++){
                    $relation_id = $adb->query_result($result,$i,'relation_id');
                    $related_tabid = $adb->query_result($result,$i,'related_tabid');
                    //hjz 如果是供应商模块或者供应商联系人模块并且关联模块是供应商联系记录才放入数组
                    //如果是联系人模块或者客户模块并且关联模块是跟进记录才放入数组
                    if((($modulename == 'Vendors'||$modulename == 'VendorContact') && $tmp_module == 'VendorContactRecords')
                    ||(($modulename == 'Contacts'||$modulename == 'Accounts') && $tmp_module =='ContactRecords')){
                        $fieldArr[] = array(
                            'modulename' => $modulename,
                            'module' => $tmp_module,//关联模块名
                            'label' => $label,
                            'relation_id' => $relation_id,
                            'recordid' => $recordid,
                        );
                    }
                }
            }
        }
    }        
}
ConvertTojsonString(1,['list'=>$fieldArr],'success');
?>