<?php
global $current_user;

if(empty($current_user)){
    exit('不允许访问');

}
//$tmp_dir=dirname(dirname(dirname(__FILE__))).'/';
//include $tmp_dir.'/include/cls_AESencryptionbykey.php';
$tmp_dir=globalStatic::$root_directory;
$cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
$path = $cls_AESencryptionbykeyobj->getdecryption($_REQUEST['path']);
$filename = $cls_AESencryptionbykeyobj->getdecryption($_REQUEST['filename']);
$action = (empty($_REQUEST['mode']))?$_REQUEST['mode']:'';

// 文件预览和下载的 PHP 代码
// 定义文件存储路径
$storagePath=$tmp_dir.$path;

// 获取请求的文件名
$requestedFile = isset($filename) ? basename($filename) : '';
$filePath = $storagePath . $requestedFile;
ob_clean();
ob_flush();
// 验证文件是否存在，且防止访问超出 storage 目录
if (!empty($requestedFile) && file_exists($filePath) && strpos($filePath, $storagePath) === 0) {
    // 根据需求判断是否提供下载或直接预览
    // 假设用户通过 GET 参数指定下载还是预览：download 或 preview

    if (isset($action) && $action === 'download') {
        // 文件下载
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . $requestedFile . '"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($filePath));
        readfile($filePath);
        exit;
    } else {
        // 文件预览
        if (false&&function_exists ( 'mime_content_type' )) {
            $mimeType = mime_content_type ( $filePath );
        } else {
            // 根据扩展名定义常见的 MIME 类型
            $mimeTypes = [
                // 文档类型
                'pdf' => 'application/pdf',
                'doc' => 'application/msword',
                'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'xls' => 'application/vnd.ms-excel',
                'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'ppt' => 'application/vnd.ms-powerpoint',
                'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',

                // 图片类型
                'jpg' => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'png' => 'image/png',
                'gif' => 'image/gif',
                'bmp' => 'image/bmp',
                'svg' => 'image/svg+xml',
                'ico' => 'image/vnd.microsoft.icon',

                // 压缩文件类型
                'zip' => 'application/zip',
                'rar' => 'application/vnd.rar',
                '7z' => 'application/x-7z-compressed',
                'tar' => 'application/x-tar',
                'gz' => 'application/gzip',

                // 其他常见文件类型
                'txt' => 'text/plain',
                'html' => 'text/html',
                'css' => 'text/css',
                'js' => 'application/javascript',
                'json' => 'application/json',
                'xml' => 'application/xml',
                'mp3' => 'audio/mpeg',
                'wav' => 'audio/wav',
                'mp4' => 'video/mp4',
                'mov' => 'video/quicktime',
                'avi' => 'video/x-msvideo',
                'flv' => 'video/x-flv'
            ];
            // 获取文件扩展名并转为小写
            $fileExtension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
            if (array_key_exists($fileExtension, $mimeTypes)) {
                $mimeType = $mimeTypes[$fileExtension];
            } else {
                // 默认 MIME 类型，可根据需求设置
                $mimeType = 'application/octet-stream';
            }
        }

        //header('Content-Disposition: inline; filename="' . $requestedFile . '"');

        header('Content-Type: ' . $mimeType);
        header('Content-Length: ' . filesize($filePath));
        //新页签title
        header('Content-Disposition: inline; filename="' . $requestedFile . '"');

        ob_clean();
        readfile($filePath);
        exit;
    }
} else {
    // 文件不存在或非法请求
    header("HTTP/1.1 404 Not Found");
    echo "File not found or access denied.";
    exit;
}



?>