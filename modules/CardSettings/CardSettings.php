<?php
class CardSettings
{
    public function getUploadFileName($file_name) {
        $arr = array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
        $encode = mb_detect_encoding($file_name, $arr);
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {
            //获取系统类型，如果是非windows系统则不用修改编码格式
            $targetFile = $file_name;
        }
        else if($encode=='UTF-8')
        {
            $targetFile = iconv('UTF-8','gb2312',$file_name);
        }

        if(empty($targetFile)) $targetFile = $file_name;
        return $targetFile;
    }
}
?>