<?php
//editor:gyq_162 reason:上传导入文件，保存到crm本地,并返回文件名   2019/12/6 16:33
$currentModule = $_REQUEST['frommodule'];
global $current_user;
$_REQUEST['diony'] = 'yes';

//第二步,导入界面2字段映射
foreach ($_FILES['ImportXlsFile'] as $key1 => $value1) {
    $filenamess = $_FILES['ImportXlsFile']['name'];//获取导入文件的名称
}

$filetype = pathinfo($filenamess, PATHINFO_EXTENSION);//获取导入文件的后缀名

if(strtolower($filetype)=='xls'||strtolower($filetype)=='xlsx')
{

}
else{
    ConvertTojsonString(-1,"",'后缀不合法');
}
$pathname = "storage/" . $current_user->id . '_' . $currentModule . "." . $filetype;
if (isset($_FILES['ImportXlsFile'])) {
    if ($_FILES['ImportXlsFile']['error'] != UPLOAD_ERR_OK) {
        ConvertTojsonString(-1, array(), '引入文件上传失败！');

    } else {
        if (file_exists("storage/" . $current_user->id . '_' . $currentModule . "." . $filetype)) {
            $result = @unlink("storage/" . $current_user->id . '_' . $currentModule . "." . $filetype);
            if ($result == false) {

                ConvertTojsonString(-1, array(), '删除文件失败！');
            }
        }

        move_uploaded_file($_FILES['ImportXlsFile']['tmp_name'], $pathname);
        ConvertTojsonString(1, array('filename' => $current_user->id . '_' . $currentModule . "." . $filetype), 'success');

    }
}

?>