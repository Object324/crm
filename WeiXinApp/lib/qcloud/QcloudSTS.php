<?php
//editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/25 23:34
require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/qcloud-sts-sdk.php';
class QcloudSTS extends STS
{
    public $use_custom_cos = false;//是否使用自定义的cos对象存储
    public $secretId, $secretKey, $bucket, $region;//cos对象存储 系统参数
    public function __construct()
    {
        //include_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
        crm_load_class_file("StaticConst","WeiXinApp/WeiXin_common");
        //ls 20220919 cos对象存储允许客户自定义
        global $cosconfig;
        require_once(globalStatic::$root_directory."config.inc.php");
        if (!empty($cosconfig['secretId']) && !empty($cosconfig['secretKey']) && !empty($cosconfig['bucket']) && !empty($cosconfig['region'])) {
            $this->use_custom_cos = true;
            $this->secretId = $cosconfig['secretId'];
            $this->secretKey = $cosconfig['secretKey'];
            $this->bucket = $cosconfig['bucket'];
            $this->region = $cosconfig['region'];
        }else{
            $this->secretId = StaticConst::$cloudSecretId; // 固定密钥
            $this->secretKey = StaticConst::$cloudSecretKey;
            $this->bucket = StaticConst::$cloudBucket;
            $this->region = StaticConst::$cloudRegion;
        }
    }
    //获取临时密钥，计算签名
    public function getCredentials(){
        // 配置参数
        $config = array(
            'url' => 'https://sts.tencentcloudapi.com/',
            'domain' => 'sts.tencentcloudapi.com',
            'proxy' => '',
            'secretId' => $this->secretId, // 固定密钥
            'secretKey' => $this->secretKey, // 固定密钥
            'bucket' => $this->bucket, // 换成你的 bucket
            'region' => $this->region, // 换成 bucket 所在园区
            'durationSeconds' => 7200, // 密钥有效期
            'allowPrefix' => '*', // 这里改成允许的路径前缀，可以根据自己网站的用户登录态判断允许上传的目录，例子：* 或者 a/* 或者 a.jpg
            // 密钥的权限列表。简单上传和分片需要以下的权限，其他权限列表请看 https://cloud.tencent.com/document/product/436/31923
            'allowActions' => array (
                // 所有 action 请看文档 https://cloud.tencent.com/document/product/436/31923
                // 简单上传
                'name/cos:PutObject',
                'name/cos:PutObjectACL',
                'name/cos:PostObject',
                // 分片上传
                'name/cos:InitiateMultipartUpload',
                'name/cos:ListMultipartUploads',
                'name/cos:ListParts',
                'name/cos:UploadPart',
                'name/cos:CompleteMultipartUpload'
            )
        );
// 获取临时密钥，计算签名
        $tempKeys = $this->getTempKeys($config);
        $tempKeys['bucket'] = $config['bucket'];
        $tempKeys['region'] = $config['region'];
        return $tempKeys;
    }
    //获取上传类型:cos腾讯云存储桶，
    public function getUploadType(){
        global $current_user;
        if ($this->use_custom_cos){
            return 'cos';
        }

        $regop=RegOp::getInstance();
        if($regop instanceof RegOp){
            $uploadType = 'local';
        }else{
            $uploadType = 'cos';
        }
        // $uploadType = 'cos';
        // editor:gyq_169待确认 reason:腾讯云COS文件上传预览   2020/2/26 10:12
        // $uploadType = 'local';
        return $uploadType;
    }
    //将附件信息保存进文件临时表  2020/3/5 13:54
    public function saveIntoTemptable(){
        global $adb,$current_user;
        $fileinfo = Zend_Json::decode( $_REQUEST['fileinfo']);
        $location = $fileinfo['Location'];
        $filename = $fileinfo['Key'];
        $orign_filename = $fileinfo['orign_filename'];
        $locationArr = explode($filename,$location);
        $path = $locationArr[0];
        $createtime = date('Y-m-d H:i:s',time());
        $sqlInsertAttachments='insert into ld_attachments_tempsave(newfile_name,path,userid,create_time) values(?,?,?,?)';//description不知道什么，暂时去掉
        $adb->pquery($sqlInsertAttachments,array($filename,$path,$current_user->id,$createtime));
        $response = array();
        if($_REQUEST['CooperativeWork'] == 'yes'){
            if ($_REQUEST['uitype'] == 69) {
                $type = 'image';
            } else {
                $type = 'att';
            }
            $query = 'insert into ld_workachments(newfile_name,name,type,path,size) 
						values(?,?,?,?,?)';
            $adb->pquery($query,array($filename,$orign_filename,$type,$path,$fileinfo['size']));
            $adb->pquery($query, array());
            $response['record'] = $adb->getLastInsertID();
        }
        return $response;
    }
    //删除云端文件 editor:gyq_169待确认
    public function deleteCloudFile($rFileList){
        return true;
    }
}