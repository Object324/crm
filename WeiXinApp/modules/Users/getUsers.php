<?php
/**
*  获取所有用户信息
*/
global $adb;
crm_load_function_file("getListQuery",'include/utils','ListViewUtils');
$list_query = getListQuery("Users");

$result = $adb->pquery($list_query,array());

$num_rows = $adb->num_rows($result);
$pyarr = array('A','B','N','T','R','W','X');

for($i=0;$i<$num_rows;$i++){
    $userid = $adb->query_result($result,$i,'id');
    $lastname = $adb->query_result($result,$i,'last_name');
    $department = $adb->query_result($result,$i,'rolename');
    
    $py = $pyarr[rand(0,6)];
    $userInfo[] = array('userid'=>$userid,'name'=>$lastname,'department'=>$department,'py'=>$py);
}

ConvertTojsonString(1,array('list'=>$userInfo,'pylist'=>$pyarr),'success');
?>