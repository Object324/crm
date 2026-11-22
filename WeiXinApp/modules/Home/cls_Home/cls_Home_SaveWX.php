<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Home_SaveWX extends cls_SaveWX
{
    public function __construct($module)
    {

    }
    public function saveFileFromWeiXinApi($id, $module, $imageArr){
        //editor:gyq_97 reason:小程序附件上传  2019/1/15 16:56
        global $adb,$current_user,$PlatformMC;
    //    if($PlatformMC['type_mini']) {
            foreach ($imageArr as $key => $value) {
                if (!empty($value['filesize'])) {
                    $matchesArr = explode('/', $value['filetype']);
                    $file_type = $matchesArr[0];
                    $sql2 = "insert into ld_workachments(workreportid,name,newfile_name, type,path,size,storage_location,cloud_path) 
                        values(?, ?, ?,? ,?,?,?,?)";
                    if($value['storage_location']=='cos')
                    {
                        if(stripos($value['cloud_path'],'https://')!==false||stripos($value['cloud_path'],'http://')!==false)
                        {
                            //edit:can 20230710 69371
                        }
                        else
                        {
                            $value['cloud_path']='https://'.$value['cloud_path'];
                        }
                    }
                    $params2 = array($id, $value['filename'],$value['newfile_name'], $file_type, $value['filepath'], $value['filesize'],$value['storage_location'],$value['cloud_path']);
                    $result = $adb->pquery($sql2, $params2);
                }
            }
       /* }else{
            //  access_token获取方法是否进行统一
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $newsport = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:17
            //gyq_31 gyq_33
            $ACCESS_TOKEN = $newsport->getCorpToken();
            if (!empty($imageArr) && !empty($ACCESS_TOKEN)) {
                $upload_file_path = decideFilePath();
                $ch = curl_init();
                foreach ($imageArr as $imageval) {
                    //0025666: 微信端 写日志 上传照片 保存后 照片无法显示   media_id取值不一样！
                    $imageurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $imageval;
                    curl_setopt($ch, CURLOPT_URL, $imageurl);
                    // 返回 response_header, 该选项非常重要,如果不为 true, 只会获得响应的正文
                    curl_setopt($ch, CURLOPT_HEADER, true);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                    $curlresult = curl_exec($ch);
                    $downloadcode= curl_getinfo($ch, CURLINFO_HTTP_CODE);
                  //  file_put_contents(globalStatic::$root_directory.'WeiXinApp/modules/Home/cls_Home/testaa.txt',$downloadcode);
                   if($downloadcode!=200)
                   {
                    //edit:can 2020-09-19 42708: （61mis.com/kfbcrm）客户问题（广州新业）移动端>企业微信>灵当CRM>工作汇报模块：填写“日志”，插入“照片”后点击“发布”，一直显示“转圈”
                    $this->checkCurlResult($curlresult);
                   }
                   
                    // 获得响应结果里的：头大小
                    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
// 根据头大小去获取头信息内容
                    $header = substr($curlresult, 0, $headerSize);
                    $content = substr($curlresult, $headerSize);

                    $pattern = "/Content-Type:(.*)Content-disposition/";
                    preg_match_all($pattern, str_replace("\n", "", $header), $matches);
                    $matchesArr = explode('/', $matches[1][0]);
                    $content_type = $matchesArr[1];
                    //editor:gyq_20191203 reason:文件名异常处理：2019120316535059393.jpeg Content-Length: 368432 Connection: keep-alive
                    if(stripos($content_type,'Content-Length') !== false){
                        $contentTypeArr = explode('Content-Length',$content_type);
                        $content_type = $contentTypeArr[0];
                    }
                    $file_type = $matchesArr[0];
                    $time = date('YmdHis', time());
                    $rand = mt_rand(1, 100000);

                    if (trim($content_type) == 'jpeg') {
                        $content_type = 'jpg';
                    }
                    $filename = $time . $rand . '.' . $content_type;
                    $save_path = globalStatic::$root_directory . $upload_file_path . $filename;
                    mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                    $zijie = file_put_contents($save_path, $content);//返回的是字节数
                    $sql2 = "insert into ld_workachments(workreportid,name, type,path,size) values(?, ?, ?,? ,?)";
                    $params2 = array($id, $filename, trim($file_type), $upload_file_path, $zijie . ' B');
                    $result = $adb->pquery($sql2, $params2);
                }
                curl_close($ch);
                return true;
            }
        }*/
    }
}