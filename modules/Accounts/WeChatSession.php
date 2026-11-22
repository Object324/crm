<?php
//@edit:liushuai,2020-10-22,reason:ID1000713/企业微信会话存档(获取相关会话数据)
//header("Content-type: audio/amr");
//header("Access-Control-Allow-Origin:*");
//header("Access-Control-Allow-Methods:GET, POST, OPTIONS, DELETE");
//header("Access-Control-Allow-Headers:DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type, Accept-Language, Origin, Accept-Encoding");
global $default_charset;
if (isset($_REQUEST['search'])) {
    $search =  vtlib_purify($_REQUEST['search']);
    $record =  vtlib_purify($_REQUEST['record']);
    $frommodule = vtlib_purify($_REQUEST["frommodule"]);
    $smarty = new lingdangCRM_Smarty;
//    $weChatSession = new WeChatSession();
//    $weChatSession->get_wechatsession($smarty,$record,'',$search);

    $data = get_wechatsession($frommodule,$record,$search);
    $smarty->assign('record', $data["record"]);
    $smarty->assign('wx_userid', $data["wx_userid"]);
    $smarty->assign('weChatDatas', $data["weChatDatas"]);
//    $smarty->assign('page_num', $data['page_num']); //总页数
//    $smarty->assign('page', $data['page']);  //当前显示页数
    $content = $smarty->fetch('Accounts/ChatData.tpl');
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array('content'=>$content,'page_num' => $data['page_num'], 'page' => $data['page']),'success');
}

if (isset($_REQUEST['type']) && $_REQUEST['type'] == 'download' ) {
    ob_get_clean();
    $filepath = $_REQUEST['filepath'];
    $filename = $_REQUEST['filename'];

    $filename = html_entity_decode($filename, ENT_QUOTES, $default_charset);
    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
        //获取系统类型，如果是非windows系统则不用修改编码格式
    } else
        $filename = mb_convert_encoding($filename, 'gbk', 'UTF-8');

    if (strpos($filepath, 'http') !== false) {
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $_GET['temp_saved_filename'] =  $filename;
        downloadCloudFile($filepath);
    }
    ob_flush();
    ob_clean();
    exit;
}

if (isset($_REQUEST['type']) && $_REQUEST['type'] == 'preview' ) {
//    $filepath = $_REQUEST['filepath'];
//    $filename = $_REQUEST['filename'];
    $msgid = $_REQUEST['msgid'];
    $sessionid = $_REQUEST['sessionid'];

    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('mode','Accounts');
    $smarty->assign("FROMMODULE",'Accounts');

    $query = "select * from ld_wechatsession  where id = ?" ;
    $result = $adb->pquery($query, array($sessionid)) or die("Couldn't get file list");
    if($adb->num_rows($result) == 1){
        $filepath = $adb->query_result($result, 0, "filepath");
        $filename = $adb->query_result($result, 0, "filename");
        $storage_location = @$adb->query_result($result, 0, "upload_way");
        $smarty->assign('storage_location',$storage_location);

        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
        }
        else
        {
            $filename= html_entity_decode($filename, ENT_QUOTES, $default_charset);
            $filename=iconv ( 'UTF-8', 'GBK', $filename );
        }

        $file_exist = false;
        if($storage_location=='cos'){
            $httppath=$filepath;
            $image_path=$filepath;
            $header_response = @get_headers($filepath, 1);
            if ( strpos( $header_response[0], "404" ) === false ){
                $file_exist = true;
            }
        }else{
            $filepath = explode('storage',$filepath);//   /ldcrm/storage/wechatsession/2020/10/20/13137031303471600295_1604045319_external.jpg
            $filepath = 'storage'.$filepath[1];//   storage/wechatsession/2020/10/20/13137031303471600295_1604045319_external.jpg

            $httppath=$filepath;
            $image_path=$filepath;
            $file_exist = file_exists($filepath);
        }

        if($file_exist){
            $image_info = getimagesize($httppath);
            $image_type = end($image_info);

            $newfiles=explode('.',strtolower($filename));
            if($newfiles[sizeof($newfiles)-1]=='doc'||$newfiles[sizeof($newfiles)-1]=='docx'
                ||$newfiles[sizeof($newfiles)-1]=='xls'||$newfiles[sizeof($newfiles)-1]=='xlsx'
                ||$newfiles[sizeof($newfiles)-1]=='ppt'||$newfiles[sizeof($newfiles)-1]=='pptx')
            {
                $fileType="application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            }
            if($fileType == 'text/plain' || $fileType == 'application/octet-stream'){	//文本
                $pops=explode('.',$filename);
                $extname=array_pop($pops);
                if($extname=='rar'||$extname=='zip')
                {
                    $smarty->assign('type','rar');
                }
                else
                {
                    $f = fopen ($httppath, "r");
                    $ln= 0;
                    while (! feof ($f)) {
                        $line= fgets ($f);
                        ++$ln;
                        $content .= $line;
                    }
                    fclose ($f);
                    $encodetype=mb_detect_encoding($content, array("ASCII",'UTF-8',"GB2312","GBK"));
                    $content=mb_convert_encoding($content,"utf-8",$encodetype);
                    $smarty->assign('content','<pre>' . $content . '</pre>');
                    $smarty->assign('type','text');
                }
            }else if(!empty($image_type)){	//图片

                $img_src= $image_path;

                $smarty->assign('img_src',$img_src);
                $smarty->assign('type','img');
            }elseif($fileType == 'application/pdf'){	//PDF
                $smarty->assign('type','pdf');
                $smarty->assign('name',$filename);

                $smarty->assign('filepah',$filepath);//PDF路径访问路径
            }elseif($fileType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation' ){	//ppt
                $smarty->assign('type','ppt');
            }elseif($fileType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
                $fileType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || $fileType == 'application/msword' ||
                $fileType == 'application/octet-stream' || $fileType == 'docx'||$fileType == 'doc' || $fileType=='xlsx' ||$fileType=='xls' ||
                $fileType == 'application/vnd.ms-excel'){	//word xls xlss
                if($storage_location=='cos'){
                    $attachmenturl= $filepath.'?a=1';
                }else{
                    $httphost=$_SERVER['HTTP_HOST'];
                    $tmphost=$httphost;
                    $tmphosts=explode(".",$tmphost);
                    $port = $_SERVER['SERVER_PORT'];

                    if(stripos($httphost,"http://")===false)
                    {
                        $httphost="http://".$httphost.":".$port;
                    }
                    $self=substr($_SERVER['PHP_SELF'],0,stripos($_SERVER['PHP_SELF'],"index.php"));
                    $hosturl=$httphost.$self;
                    //@chj mantis:41918:附件管理模块>选择编号为“ATT90 ”单据详情界面：附件名称含“+”无法预览和下载（需要补丁））
                    $attachmenturl=$hosturl.$filepath.urlencode(decode_html($filename)).'?a=1';
                }
                $smarty->assign("ATTACHMENTURL",$attachmenturl);
                crm_load_class_file('cls_uploads','modules/uploads');
                $cls_uploads = new cls_uploads($filename,$filepath,$sessionid);
                $uploads_info = $cls_uploads->ConvertOffice();
                if($uploads_info['code'] == 1){
                    $smarty->assign('type','pdf');
                    $smarty->assign('pdfname',$uploads_info['pdfname']);//转换文件名称
                    $smarty->assign('filepah',$uploads_info['filepath']);//PDF路径访问路径
                }else{

                    if((sizeof($tmphosts)>=4&&is_numeric($tmphosts[1])&&is_numeric($tmphosts[2]))||stripos($tmphost,'localhost')!==false)
                    {
                        //ip地址无法预览
                    }
                    else
                        $smarty->assign('type','application/msword');
                }
            }else{
                $smarty->assign('type','other');
            }

            $att_query = "select id,filename from ld_wechatsession  where msgid = ?" ;
            $att_result = $adb->pquery($att_query,array($msgid));
            $att_num_rows = $adb->num_rows($att_result);
            for($k = 0; $k < $att_num_rows; $k++){
                $attachmentsid = $adb->query_result($att_result,$k,'id');
                $att_data[$attachmentsid] = $adb->query_result($att_result,$k,'filename');
                $att_data_key[] = $attachmentsid;
            }

            $pre = 0;
            foreach($att_data_key as $key => $attachmentsid){
                if($attachmentsid == $sessionid){
                    $pre = $key;
                }
            }
            if($pre >= 1){
                $smarty->assign('PRE_ATTACHID',$att_data_key[$pre-1]);
                $smarty->assign('PRE_STAT','yes');
            }else{
                $smarty->assign('PRE_STAT','no');
            }
            if($pre == sizeOf($att_data_key)-1){
                $smarty->assign('NEXT_STAT','no');
            }else{
                $smarty->assign('NEXT_ATTACHID',$att_data_key[$pre+1]);
                $smarty->assign('NEXT_STAT','yes');
            }
            $smarty->assign('ATT_NUM_ROWS',$att_num_rows);
            $smarty->assign('ATT_DATA',$att_data);

//            SaveAuditlog($msgid,'预览',$filename,$frommodule);//存储附件的预览记录
            $smarty->assign('name',$filename);
            $replace_filename = str_replace("%","%25",$filename);
            $replace_filename = str_replace("#","%23",$replace_filename);
            $smarty->assign('replace_filename',$replace_filename);
            $smarty->assign('entityid',$msgid);
            $smarty->assign('fileId',$sessionid);
            $smarty->display('Preview_now.tpl');
            exit;

        }
        else{
            $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');//文件已丢失，请返回
            echo $str=json_encode($jarr);
            exit();
        }
    }
    else{
        $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');
        echo $str=json_encode($jarr);//将数组进行json编码
        exit();
    }



}


//新需求 修改表连接，将ld_contactdetails表替换为ld_external_contact
function get_wechatsession($frommodule,$record, $search = '')
{
    global $currentModule, $adb, $current_user;
    global $wechatsession_page_size;

    $ScopOfAuthority = ScopOfAuthority::getInstance($adb, $currentModule);
    $sec_parameter_where = $ScopOfAuthority->getWechatSessionModuleListViewQuery(); //为空：全部权限
//        dump($sec_parameter_where);


    //获取客户微信id
    if ($frommodule == 'Accounts') {
        
        $query = "SELECT
        	c.*,d.external_name AS lastname,d.weixin_external_userid,ld_users.wx_userid
        FROM ld_account a
        LEFT JOIN ld_contactdetails b ON a.accountid=b.accountid
        LEFT JOIN ld_external_contact d ON b.weixin_external_userid=d.weixin_external_userid or b.lastname=d.external_name
        LEFT JOIN ld_wechatsession c ON FIND_IN_SET(d.session_external_userid,c.fromid)>0 OR FIND_IN_SET(d.session_external_userid,c.tolist)>0
        LEFT JOIN ld_users on ld_users.wx_userid=c.fromid";
                $where = " WHERE a.accountid={$record}
        	AND IFNULL(b.weixin_external_userid,'')<>'' ";
                $orderby = " ORDER BY c.msgtime DESC";
    } elseif ($frommodule == 'Contacts') {
       
        $query = "SELECT
                	c.*,d.external_name AS lastname,d.weixin_external_userid,ld_users.wx_userid
                FROM  ld_contactdetails b
                LEFT JOIN ld_external_contact d ON b.weixin_external_userid=d.weixin_external_userid
                    or b.lastname=d.external_name
                LEFT JOIN ld_wechatsession c ON 
                FIND_IN_SET(d.session_external_userid,c.fromid)>0 OR FIND_IN_SET(d.session_external_userid,c.tolist)>0
                LEFT JOIN ld_users on ld_users.wx_userid=c.fromid";
                        $where = " WHERE b.contactid={$record}
                	AND IFNULL(b.weixin_external_userid,'')<>''
                      ";
                        $orderby = " ORDER BY c.msgtime DESC";
    } else {
        return '';
    }

    //获取客户相关的聊天数据
    if (empty($search)) {
        $query = $query.$where.$orderby;

    } else {
//        $query = "select * from ld_wechatsession where (fromid = ? or FIND_IN_SET(?,tolist)) and content like '%{$search}%' order by msgtime desc";
        $query = $query.$where." AND c.content LIKE '%{$search}%'".$orderby;
    }
    
    //zkt 20221009 BUG0057363客户-相关信息-会话存档，搜索一直转圈
    if(empty($wechatsession_page_size)){
        $wechatsession_page_size = 10;
    }
    $page_size = $wechatsession_page_size;  //每页显示10条
    
    //计算总页数
    $page_num =  ceil($adb->num_rows($adb->pquery($query,array()))/$page_size);
    $page = 1;//请求的页数 默认为第一页  倒序排序
//    $page = $page_num >1 ? $page_num:1;//请求的页数 默认为最后一页

    if (isset($_REQUEST['page'])) {
        $page = $_REQUEST['page'] >= 1 ? $_REQUEST['page'] : '1';  //上一页 下一页  当前请求的页数
        $page = $page <= $page_num ? $page : $page_num;
    }
    $index = ($page-1) * $page_size;

    $limit = " LIMIT ".$index."," .$page_size;

    $query = $query.$limit;
    $result = $adb->pquery($query, array());
    $num_rows = $adb->num_rows($result);
    $weChatDatas = [];
    if ($num_rows >= 1) {
        $userobj = new Users();
        for ($i = 0; $i < $num_rows; $i++) {
//            $weChatDatas[$i] = $adb->query_result_rowdata($result,$i);
//            $msgtype = $adb->query_result($result,$i,'msgtype');
//            $fromid = $adb->query_result($result,$i,'fromid');
            $roomid =$adb->query_result($result, $i, 'roomid');
            $sessiontype=$adb->query_result($result, $i, 'session_type');
            $weChatDatas[$i]['session_type'] = '';
            if($sessiontype=='external')
                $weChatDatas[$i]['session_type'] = $adb->query_result($result, $i, 'session_type');
            else if(!empty($roomid))
                    $weChatDatas[$i]['session_type'] = 'groupchat';
            $weChatDatas[$i]['msgtype'] = $adb->query_result($result, $i, 'msgtype');
            $weChatDatas[$i]['id'] = $adb->query_result($result, $i, 'id');
            $weChatDatas[$i]['msgid'] = $adb->query_result($result, $i, 'msgid');
            $wx_userid = $adb->query_result($result, $i, 'wx_userid');
                
            if (empty($wx_userid)) {  //外部联系人  取 lastname
                $weChatDatas[$i]['fromid'] = $adb->query_result($result, $i, 'lastname');
                $weChatDatas[$i]['last_name']=$adb->query_result($result, $i, 'lastname');
            }else{
                $query = "select last_name from ld_users where wx_userid = ? limit 1";
                $lastname_result = $adb->pquery($query, array($wx_userid));
                $lastname_num_rows = $adb->num_rows($lastname_result);
                if ($lastname_num_rows >= 1) {
                    $userobj->wx_userid = $wx_userid;
                    $userobj->last_name = $adb->query_result($lastname_result, 0, 'last_name');
                    $weChatDatas[$i]['fromid'] = getUserlastName($userobj);
                    $weChatDatas[$i]['last_name']=getUserlastName($userobj);
                } else {
                    $weChatDatas[$i]['fromid'] = $adb->query_result($result, $i, 'fromid');
                    $weChatDatas[$i]['last_name']=$adb->query_result($result, $i, 'fromid');
                }
                
            }

            $weChatDatas[$i]['tolist']=$adb->query_result($result, $i, 'tolist');
            $weChatDatas[$i]['msgtime']=$adb->query_result($result, $i, 'msgtime');
            $weChatDatas[$i]['content']=$adb->query_result($result, $i, 'content');
            $weChatDatas[$i]['filename']=$adb->query_result($result, $i, 'filename');
            $weChatDatas[$i]['filepath']=$adb->query_result($result, $i, 'filepath');
            $weChatDatas[$i]['upload_way']=$adb->query_result($result, $i, 'upload_way');
            $weChatDatas[$i]['play_length']=$adb->query_result($result, $i, 'play_length');
            

        }
    }
    
    // 取得列的列表  按照 msgtime 倒序排序
    $order_msgtime = _array_column($weChatDatas,'msgtime');
    array_multisort($order_msgtime,SORT_ASC,$weChatDatas);


    $data = compact("record", "wx_userid", "weChatDatas", "page_num", "page");
    return $data;
}

/*
function get_wechatsession_old($frommodule,$record, $search = '')
{
    global $currentModule, $adb, $current_user;


    $ScopOfAuthority = ScopOfAuthority::getInstance($adb, $currentModule);
    $sec_parameter_where = $ScopOfAuthority->getWechatSessionModuleListViewQuery(); //为空：全部权限



    //获取客户微信id
    if ($frommodule == 'Accounts') {
        $query = "SELECT
	c.*,b.lastname,b.weixin_external_userid,ld_users.wx_userid
FROM ld_account a
LEFT JOIN ld_contactdetails b ON a.accountid=b.accountid
LEFT JOIN ld_wechatsession c ON FIND_IN_SET(b.weixin_external_userid,c.fromid)>0 OR FIND_IN_SET(b.weixin_external_userid,c.tolist)>0
LEFT JOIN ld_users on ld_users.wx_userid=c.fromid";
        $where = " WHERE a.accountid={$record}
	AND IFNULL(b.weixin_external_userid,'')<>'' ";
        $orderby = " ORDER BY c.msgtime DESC";
    } elseif ($frommodule == 'Contacts') {
        $query = "SELECT
	c.*,b.lastname,b.weixin_external_userid,ld_users.wx_userid
FROM  ld_contactdetails b
LEFT JOIN ld_wechatsession c ON FIND_IN_SET(b.weixin_external_userid,c.fromid)>0 OR FIND_IN_SET(b.weixin_external_userid,c.tolist)>0
LEFT JOIN ld_users on ld_users.wx_userid=c.fromid";
        $where = " WHERE b.contactid={$record}
	AND IFNULL(b.weixin_external_userid,'')<>'' ";
        $orderby = " ORDER BY c.msgtime DESC";
    } else {
        return '';
    }

    //获取客户相关的聊天数据
    if (empty($search)) {
        $query = $query.$where.$orderby;

    } else {
//        $query = "select * from ld_wechatsession where (fromid = ? or FIND_IN_SET(?,tolist)) and content like '%{$search}%' order by msgtime desc";
        $query = $query.$where." AND c.content LIKE '%{$search}%'".$orderby;
    }

    $page_size = 10;  //每页显示10条
    //计算总页数
    $page_num =  ceil($adb->num_rows($adb->pquery($query,array()))/$page_size);
    $page = 1;//请求的页数 默认为第一页  倒序排序


    if (isset($_REQUEST['page'])) {
        $page = $_REQUEST['page'] >= 1 ? $_REQUEST['page'] : '1';  //上一页 下一页  当前请求的页数
        $page = $page <= $page_num ? $page : $page_num;
    }
    $index = ($page-1) * $page_size;

    $limit = " LIMIT ".$index."," .$page_size;

    $query = $query.$limit;
    $result = $adb->pquery($query, array());
    $num_rows = $adb->num_rows($result);
    $weChatDatas = [];
    if ($num_rows >= 1) {
        $userobj = new Users();
        for ($i = 0; $i < $num_rows; $i++) {

            $weChatDatas[$i]['msgtype'] = $adb->query_result($result, $i, 'msgtype');
            $weChatDatas[$i]['id'] = $adb->query_result($result, $i, 'id');
            $weChatDatas[$i]['msgid'] = $adb->query_result($result, $i, 'msgid');
            $wx_userid = $adb->query_result($result, $i, 'wx_userid');

            if (empty($wx_userid)) {  //外部联系人  取 lastname
                $weChatDatas[$i]['fromid'] = $adb->query_result($result, $i, 'lastname');
            }else{
                $query = "select last_name from ld_users where wx_userid = ? limit 1";
                $lastname_result = $adb->pquery($query, array($wx_userid));
                $lastname_num_rows = $adb->num_rows($lastname_result);
                if ($lastname_num_rows >= 1) {
                    $userobj->wx_userid = $wx_userid;
                    $userobj->last_name = $adb->query_result($lastname_result, 0, 'last_name');
                    $weChatDatas[$i]['fromid'] = getUserlastName($userobj);
                } else {
                    $weChatDatas[$i]['fromid'] = $adb->query_result($result, $i, 'fromid');
                }
            }

            $weChatDatas[$i]['tolist'] = $adb->query_result($result, $i, 'tolist');
            $weChatDatas[$i]['msgtime'] = $adb->query_result($result, $i, 'msgtime');
            $weChatDatas[$i]['content'] = $adb->query_result($result, $i, 'content');
            $weChatDatas[$i]['filename'] = $adb->query_result($result, $i, 'filename');
            $weChatDatas[$i]['filepath'] = $adb->query_result($result, $i, 'filepath');
            $weChatDatas[$i]['upload_way'] = $adb->query_result($result, $i, 'upload_way');
            $weChatDatas[$i]['play_length'] = $adb->query_result($result, $i, 'play_length');


        }
    }

    // 取得列的列表  按照 msgtime 倒序排序
    $order_msgtime = _array_column($weChatDatas,'msgtime');
    array_multisort($order_msgtime,SORT_ASC,$weChatDatas);


    $data = compact("record", "wx_userid", "weChatDatas", "page_num", "page");
    return $data;
}*/


