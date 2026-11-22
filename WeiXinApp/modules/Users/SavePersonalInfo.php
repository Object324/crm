<?php
//手机端 编辑个人资料保存的方法  zxm  2020-1218
global $adb,$currentModule;
global $current_user;
$crm_id = $current_user->id;
$field_info = $_REQUEST['wx_fieldInfo'];

// //如果修改了头像
// $imageval = $field_info['imagename']['new'][0];
// if(!empty($imageval)){
//     crm_load_class_file("cls_SaveWX",'WeiXinApp/detail');
//     $saveObj = new cls_SaveWX('');
//     $returnsave = $saveObj->saveFileForAvatar($crm_id,$imageval);
// }
// unset($field_info['imagename']);

if(!empty($_REQUEST['wx_fieldInfo']['imagename'])) {
    foreach ($_REQUEST['wx_fieldInfo']['imagename'] as $key=>$val) {
        $_REQUEST[$key] = $val;
    }
    //附件字段单独保存
    $attachfield_arr = [];
    $attachfield_arr['imageattachment'][] = 'imagename';
    if(sizeof($attachfield_arr)>0){
        $current_user->uploadAndSaveFile($crm_id,$currentModule,[]);
    }
}
unset($field_info['imagename']);

//个人资料
//edit:duan 2022-5-9 客户001问题，企业微信端不允许编辑姓名，所以此处判断是否需要修改姓名
if(isset($field_info['last_name'])){
    $list_field_arr=['last_name','phone_mobile','phone_home','email1']; 
    $sql = "update ld_users set last_name=?,phone_mobile=?,phone_home=?,email1=? ";
}else{
    $list_field_arr=['phone_mobile','phone_home','email1']; 
    $sql = "update ld_users set phone_mobile=?,phone_home=?,email1=? ";
}

$scfsql=' update  ld_usersscf set ';
$allfieldInfo_arr=$current_user->fieldobj->getModuleFields();

foreach($allfieldInfo_arr as $tmpfiedname=>$tmpfieldinfo)
{
    if($tmpfieldinfo->getColumnName()=='user_name')
                continue;
    if($tmpfieldinfo->getKeywords()=='yes')
    {
        if(!in_array($tmpfiedname,$list_field_arr))
        {
            if($tmpfieldinfo->getTableName()=='ld_usersscf')
            {
                $scfsql.=$tmpfieldinfo->getColumnName().'=?, ';
            }
            else
             $sql.=','.$tmpfiedname.'=? ';
        }
        
    }
}
$sql.=" where id=? ";

$scfsql=trim(trim($scfsql),',')." where id=? ";

$update_param=[];
$scf_update_param=[];
$isscf='no';

foreach($field_info as $fieldname=>$value)
{
    $fieldinfo=$allfieldInfo_arr[$fieldname];
    if($fieldinfo->getTableName()=='ld_users')
        $update_param[]=$value;
    else
    {
        $isscf='yes';
        $scf_update_param[]=$value;
    }
}
$update_param[]=$crm_id;
// echo $sql;dump($update_param);
$res = $adb->pquery($sql,$update_param);

$affect_num = $adb->getAffectedRowCount($res);

// file_put_contents(globalStatic::$root_directory.'3.txt','bfore:'.$sql.'bfore1:'.json_encode($update_param).$current_user->id.date("Y-m-d H:i:s")."\r\n",FILE_APPEND);


if($isscf=='yes')
{
    $scf_update_param[]=$crm_id;
    // echo $scfsql;dump($scf_update_param);
    $res = $adb->pquery($scfsql,$scf_update_param);
    // file_put_contents(globalStatic::$root_directory.'4.txt','bfore:'.$scfsql.'bfore1:'.json_encode($scf_update_param).$current_user->id.date("Y-m-d H:i:s")."\r\n",FILE_APPEND);
}
ConvertTojsonString(1, ['affect_num'=>$affect_num], $affect_num>=1?getFixedLabel('SUCCESSFULLYMODIFIED'):getFixedLabel('MODIFICATIONFAILED'));
