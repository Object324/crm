<?php
require_once 'modules/Home/Homeboard.php';
class VisualAnalysisBoard extends Homeboard
{
    public function SaveBoardOperate(){
        global $adb,$current_user;
        $boardid = $this->boardid;
        $module = $this->frommodule;
        $actiontype = $_REQUEST['actiontype'];
        $operator = $current_user->id;
        $time = date('Y-m-d H:i:s');

        if($actiontype == 'collect' && $_REQUEST['collect'] == 'yes'){
            //取消收藏
            $delete_sql = 'delete from `ld_operation_log` where `crmid` = ? and `operator` = ? and `module` = ?  and `action` = ?';
            $adb->pquery($delete_sql,array($boardid,$operator,$module,$actiontype));
            $msg = '取消收藏成功';
            return $msg;
        }
        $sql = 'select * from `ld_operation_log` where `crmid` = ? and `operator` = ? and `module` = ?  and `action` = ?';
        $result = $adb->pquery($sql,array($boardid,$operator,$module,$actiontype));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            $id = $adb->query_result($result,0,'id');
            $update_sql = 'update `ld_operation_log` set `operation_time` = ? where `id` = ?';//date('Y-m-d H:i:s')
            $adb->pquery($update_sql,array($time,$id));
        }
        else {
            $insert_sql = 'insert into ld_operation_log(module,crmid,action,operator,operation_time) values (?,?,?,?,?)';
            $adb->pquery($insert_sql,array($module,$boardid,$actiontype,$operator,$time));
        }
        $msg = $actiontype.'成功';

        return $msg;
        //ConvertTojsonString(1,'',"success");
    }

    public function get_BoardStuffList(){

    }

    public static function xCopy($source, $destination, $child = 1){
        //用法：
        // xCopy("feiy","feiy2",1):拷贝feiy下的文件到 feiy2,包括子目录
        // xCopy("feiy","feiy2",0):拷贝feiy下的文件到 feiy2,不包括子目录
        //参数说明：
        // $source:源目录名
        // $destination:目的目录名
        // $child:复制时，是不是包含的子目录

        if(!is_dir($source)){
            echo("Error:the $source is not a direction!");
            return 0;
        }

        if(!is_dir($destination)){
            mkdir($destination,0777);
        }

        $handle=dir($source);
        while($entry=$handle->read()) {
            if(($entry!=".")&&($entry!="..")){
                if(is_dir($source."/".$entry)){
                    if($child)
                        self::xCopy($source."/".$entry,$destination."/".$entry,$child);
                }
                else{
                    copy($source."/".$entry,$destination."/".$entry);
                }
            }
        }
        //return 1;
    }

    //icon单文件上传
    public static function  iconUpload($fieldname,$boardid){
        $dir_path = "storage/VisualAnalysisIcon/";
        $uploaddir = globalStatic::$root_directory .$dir_path;
        if(!is_dir($uploaddir)){
            mkdir($uploaddir, 0777);
        }

        $allowedExts = array("gif", "jpeg", "jpg", "png");
        $temp = explode(".", $_FILES[$fieldname]["name"]);
        FileSecurityCheck($temp);
        $extension = end($temp);        // 获取文件后缀名
        $errorInfo = '';//错误信息
        $filename_destination = $fieldname.'_'.$boardid.".".$extension;
        if ((($_FILES[$fieldname]["type"] == "image/gif")
                || ($_FILES[$fieldname]["type"] == "image/jpeg")
                || ($_FILES[$fieldname]["type"] == "image/jpg")
                || ($_FILES[$fieldname]["type"] == "image/pjpeg")
                || ($_FILES[$fieldname]["type"] == "image/x-png")
                || ($_FILES[$fieldname]["type"] == "image/png"))
            && ($_FILES[$fieldname]["size"] <= 1024*1024)    // 小于 1mb
            && in_array($extension, $allowedExts))
        {
            if ($_FILES[$fieldname]["error"] > 0)
            {
                $errorInfo = $_FILES[$fieldname]["error"];
            }
            else
            {
                //echo "上传文件名: " . $_FILES["file"]["name"] . "<br>";
                //echo "文件类型: " . $_FILES["file"]["type"] . "<br>";
                //echo "文件大小: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
                //echo "文件临时存储的位置: " . $_FILES[$fieldname]["tmp_name"];
                //移动前判断文件存不存在 存在先删除
                if(file_exists($uploaddir.$filename_destination)){
                    unlink($uploaddir.$filename_destination);
                }
                move_uploaded_file($_FILES[$fieldname]["tmp_name"],$uploaddir.$filename_destination);
            }
        }else if ($_FILES[$fieldname]["size"] > 1024*1024){
            $errorInfo = getFixedLabel('menuIconUploadTips');
        }else{
            $errorInfo = '文件格式不合法！';
        }
        if($errorInfo==''){
            return ['code'=>1,'filepath'=>$dir_path.$filename_destination];
        }else{
            return ['code'=>-1,'errorInfo'=>$errorInfo];
        }
    }
}