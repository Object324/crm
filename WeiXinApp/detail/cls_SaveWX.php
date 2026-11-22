<?php

class cls_SaveWX
{
    protected $module;
    public $focus;
    protected $action;
    protected $jsonArr;
    public $previousAction;
    public $checkeditpermit;
    public function __construct($module)
    {
        if(!empty($module)) {
            $this->module = $module;
            $this->focus = cls_Instance::get_module_Instance($module); //gyq161208
           // $this->focus = CRMEntity::getInstance($module);
            $this->action = $_REQUEST['action'];  //CreateView EditView DetailView
            $this->previousAction = $_REQUEST['previousAction'];  //CreateView EditView DetailView
            $this->checkeditpermit = 'yes';
            if ($this->previousAction == 'EditView') {
                $this->focus->id = $_REQUEST['record'];
                $this->focus->mode = 'edit';
                $_REQUEST['mode'] = 'edit';
            } elseif ($this->previousAction == 'CreateView') {
                $this->focus->id = 0;
                $_REQUEST['Create'] = 'yes';
            }
            //editor:gyq_20181228 reason:附件模块删除附件，不再在执行微信保存附件之前又执行PC端附件保存 0035709: 附件上传删除保存后，希望将服务器里附件同步删除
            $this->special_request();
            //editor:gyq_164 reason:去除参数$_REQUEST['WXUPLOAD']  2019/12/20 14:26
            //editor:gyq_97 reason：小程序编辑保存，需要删除旧记录  2019/1/15 14:45
            //微信端编辑暂时不保存附件信息
            /*global $PlatformMC;
            if($PlatformMC['type_mini'] != true){
                $_REQUEST['WXUPLOAD'] = 'yes';
            }*/
        }
    }
    //企业微信参数应PC代码需要特殊转换
    public function special_request(){
        if(isset($_REQUEST['wx_fieldInfo']['filename']['delete'])){
            $filename_delete = $_REQUEST['wx_fieldInfo']['filename']['delete'];
            if(!empty($filename_delete)){
                $_REQUEST['attachmentdelfileid'] = implode(',',$filename_delete);
            }
        }

        //ls 20221231  XUQIU1000922：表单码-分录可编辑表单码（隐藏的主表字段，前端没有传值，需要从数据库取出来拼上）
        if ($_REQUEST['is_qrcode_expand'] == 'yes') {
            $this->focus->retrieve_entity_info($this->focus->id, $this->module);
//            ConvertTojsonString(1, array($this->focus->column_fields), "测试小程序返回值");
            foreach ($this->focus->column_fields as $fieldnname=>$value){
                if (!isset($_REQUEST['wx_fieldInfo'][$fieldnname])) {//前端没传的值默认使用数据库已存的值
                    $_REQUEST['wx_fieldInfo'][$fieldnname] = $value;
                }
            }
        }
    }
    public function common_save(){


        $focus = $this->focus;
        $module = $this->module;

        //edit:can 2020-12-23 43917: （企业微信移动端，kfbcrm）审批-合同订单；单据编号SO103，审批流“合同订单加签和条件”，填写必填项后，当前审批人审批提示“该记录正在审批中，不允许编辑！ 请联系审批人”
        $_REQUEST['cur_module_step']='1';
        if($module=='ServiceCharge') $module='Accounts';
        //0025802: （微信端-安卓）联系人：新增自定义的多选框字段，新增联系人选择多选框信息，出现代码
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        setObjectValuesFromRequest($focus);
        //editor:gyq_129 reason:选择源单字段增加保存到数据库功能  2019/7/11 17:34 ID1000529
        //原单
        //$_REQUEST['selectlistval']=$_REQUEST['salesorder_id'];
        //03gyqDis date:20170320 reason:币种保存方法暂时写在公告保存方法中，客户联系人保存除外！。
        global $adb;

        $currency_id_post = $_REQUEST['currency_id'];
        if($this->action=='EditView')
        {
            $currency_id = $focus->column_fields['currency_id'];
        }
        //edit:can 20220113 49636: （企业微信-kfbtest）（需要补丁）出库单新建》选择合同源单SO119，保存时提示分录的数量、合计和源单不一致
        $_REQUEST['inventory_currency']=$currency_id_post;
        if($currency_id !=$currency_id_post)
            $focus->currency_status = true;
        else
            $focus->currency_status = false;
        $focus->column_fields['currency_id']=$currency_id_post;
        $currencyobj=Currency::getInstance($adb,$currency_id_post);
        $currencySymbol = $currencyobj->getCurrencySymbol();
        $currencyRate = $currencyobj->getCurrencyRate();
        $focus->column_fields['conversion_rate'] = $currencyRate;
        $focus->column_fields['currency_symbol'] = decode_html($currencySymbol);

        $this->before_save();

        $focus->save($module);

        

        $relatedCreationInfo = $_REQUEST['relatedCreationInfo'] ?? '';
        $relatedCreationArr = json_decode($relatedCreationInfo,true);
        if(!empty($relatedCreationArr)){
            $frommodule = $relatedCreationArr['frommodule'];
            $fromid = $relatedCreationArr['fromid'];
        }
        if($module=='HelpDesk'&&!empty($relatedCreationArr)){
            if ($frommodule == 'ServiceContracts'||$frommodule=="Project"||$frommodule=='Products') {	     
				$on_focus = CRMEntity::getInstance($frommodule);
				$on_focus->save_related_module($frommodule, $fromid, $module, $focus->id);
			}
        }
      
        if(!empty($_REQUEST['file_save_weixin'])){
            $this->saveAttachmentFromWeiXinApi_CommonModule($focus->id,$module,$_REQUEST['file_save_weixin']);
        }

        $this->after_save();
    }

    public function setFieldInfoFromPost(){
        
        global $weixin_user,$adb;
        $_REQUEST['cur_module_step']='1';
        //editor:gyq_150 reason:客户/联系人保存字段重复提示自定义  2019/10/15 14:19
        include globalStatic::$root_directory.'modules/lingdang/staticlingdang.class.php';
        $this->check_before_field_duplicate();
        if(!empty($_REQUEST['wx_fieldInfo'])) {
            $fieldobj=Field::getInstance($this->module,$adb);
            $moduleFields=$fieldobj->getModuleFields();
           // PC端+微信端：模块单据提交审批后，系统应该做实时判断
            $ldcls = new staticlingdang();
            $input['record']=$_REQUEST['record'];
            $input['fld_module']=$this->module;
            $approvepermit= $ldcls->checkEditInfo($input);
            if(strtolower($approvepermit['check'])!='success' && $_REQUEST['isApproveMandatoryField'] != 'yes' && $this->checkeditpermit == 'yes')
            { 
                ConvertTojsonString(-1,array(),$approvepermit['check']);
            }
          
            foreach ($_REQUEST['wx_fieldInfo'] as $key=>$val) {
                $field = $moduleFields[$key];
                //editor:gyq_113 reason:新增知识管理模块  2019/5/23 15:18
                //由于知识管理模块的附件uitype是特殊值28，故新增$field->uitype==28
                if ($field->uitype == 69||$field->uitype==1109||$field->uitype==1108||$field->uitype==28) {
                    //editor:gyq_97 reason:小程序附件上传  2019/1/11 15:16
                    //if($PlatformMC['type_mini']){
                       //20210120
                   /* if($weixin_user->environment=='weixinh5'){
                        if ($field->uitype == 69) {
                            $_REQUEST['image_save_weixin'] = $val;
                        }elseif($field->uitype==1109||$field->uitype==28){
                            $_REQUEST['file_save_weixin'][$field->getColumnName()] = $val;
                        }elseif($field->uitype==1108){
                            $_REQUEST['attachment_save_weixin'] = $val;
                        }
                    }else{*/
                        foreach($val as $k=>$v){
                            $_REQUEST[$k] = $v;
                        }
                        unset($_REQUEST[$key]);
                    //}
                }else{
                    $_REQUEST[$key] = $val;
                    if($field->fieldonly == 1 && !empty($val)){
                        $this->FieldDuplicate($key,$val);
                    }
                }
            }


        }
    }
    //editor:gyq_150 reason:客户/联系人保存字段重复提示自定义  2019/10/15 14:20
    protected function check_before_field_duplicate(){}
    //字段重复判断
    protected function FieldDuplicate($fieldname,$fieldvalue){
        $ldcls = new staticlingdang();
        $rest = $ldcls->getFieldDuplicateInfo($this->module,$fieldname,$fieldvalue,$this->focus->id);
        if(strpos($rest,'##error##')  !== false){
            $restFinal = str_replace('##error##','',$rest);
            $detail['fieldname'] =  $fieldname;
            ConvertTojsonString(-1,$detail,$restFinal);
        }
    }
    //考勤签到图片保存
    public function saveFileFromWeiXinApi($id, $module, $imageArr){
        $T1 = array('album'=>'从相册选择','camera'=>'手机拍照');
        global  $adb,$PlatformMC,$current_user,$weixin_user;
        //editor:gyq_97 reason:小程序附件上传  2019/1/11 16:04
        //editor:gyq_152 reason:签到考情图片上传  2019/10/17 17:12 
        $retinfo_arr=[];
        //dump($PlatformMC);
        if($PlatformMC['type'] || $PlatformMC['type_mini'] || $weixin_user->environment=='dingtalk'||$weixin_user->environment=='yunzhijia'){
            foreach($imageArr as $imageval) {
                $sql2 = "insert into ld_attachmentsforsign(signid,filename, type,imagefromtype,path,size
                        ,storage_location,cloud_path) values(?,?,?, ?,? ,?,?,?)";
                if($imageval['storage_location']=='')
                {
                    $imageval['storage_location']='local';
                    
                }
                if($imageval['storage_location']=='cos')
                {
                    if(stripos($imageval['cloud_path'],'https://')!==false||stripos($imageval['cloud_path'],'http://')!==false)
                    {
                       
                    }
                    else{
                         $imageval['cloud_path']='https://'.$imageval['cloud_path'];
                    }
                }
                
                $params2 = array($id,$imageval['filename'] , $imageval['filetype'] , $T1[$imageval['type']]
                            , $imageval['filepath'] ,$imageval['filesize'] .' B',$imageval['storage_location'],$imageval['cloud_path']);
                $result = $adb->pquery($sql2, $params2);
                
                $retinfo_arr[]=array("filename"=>$imageval['filename'],'path'=>$imageval['filepath'],'type'=>"new",'storage_location'=>$imageval['storage_location'],'cloud_path'=>$imageval['cloud_path']);
            }
             return $retinfo_arr;
        }else {
         /*   crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            
            
            $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:22
            //gyq_31
            $ACCESS_TOKEN = $port_obj->getCorpToken();//gyq_33
            if (!empty($imageArr) && !empty($ACCESS_TOKEN)) {
                $upload_file_path = decideFilePath();
                $ch = curl_init();
              
                foreach ($imageArr as $imageval) {
                    $imageurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $imageval['serverId'];
                    curl_setopt($ch, CURLOPT_URL, $imageurl);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                    $curlresult = curl_exec($ch);
                    
                    $this->checkCurlResult($curlresult,'');
                    $time = date('YmdHis', time());
                    $rand = mt_rand(1, 100000);
                    $filename = $time . $rand . '.jpg';
                   
                    $save_path = globalStatic::$root_directory . $upload_file_path . $filename;
                    mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                    
                    $zijie = file_put_contents($save_path, $curlresult);//返回的是字节数
                    $sql2 = "insert into ld_attachmentsforsign(signid,filename, type,imagefromtype,path,size) values(?, ?, ?, ?,? ,?)";
                    $params2 = array($id, $filename, 'image/jpeg', $T1[$imageval['type']], $upload_file_path, $zijie . ' B');
                    $result = $adb->pquery($sql2, $params2);
                    $retinfo_arr[]=array("filename"=>$filename,'path'=>$upload_file_path,'type'=>"new");
                }
                curl_close($ch);
                
                return $retinfo_arr;
            } else {
                file_put_contents('curl.txt', json_encode($ACCESS_TOKEN, $imageval['serverId']));
            }*/
        }
    }
    //用户头像保存的方法 $imageval 因为头像一次只传一个 zxm 20201221 
    public function saveFileForAvatar($id,$imageval)
    {
        global $adb, $PlatformMC, $weixin_user, $current_user, $upload_badext;
        crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
        crm_load_class_file("Users", 'modules/Users');
        $userobj = new Users();
        $port_obj = new cls_WeixinPort();
        $ACCESS_TOKEN = $port_obj->getCorpToken();

        if (!empty($imageval) && !empty($ACCESS_TOKEN)) {
            $upload_file_path = decideFilePath();
            //edit:can 20210629 46284: （企业微信移动端-kfbcrm）在电子名片中修改头像后，PC端查看成员信息头像，显示图片加载失败；PC端更换头像后，移动端只在修改头像界面加载失败
            if(stripos($upload_file_path,globalStatic::$root_directory)!==false)
            {
                
            }
            else
            {
                $upload_file_path=globalStatic::$root_directory.$upload_file_path;
            }
            $ch = curl_init();
            $imageurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $imageval;
            curl_setopt($ch, CURLOPT_URL, $imageurl);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            $curlresult = curl_exec($ch);
            $this->checkCurlResult($curlresult, '');
            //$upload_file_path:包含了globalStatic::$root_directory
            $time = date('YmdHis', time());
            $rand = mt_rand(1, 100000);
            $filename = $time . $rand . '.jpg';
            $save_path = $upload_file_path . $filename;
           // file_put_contents(globalStatic::$root_directory.'WeiXinApp/detail/wagncan.txt',$upload_file_path);
            
            mkdir($upload_file_path, 0777, true);

            $zijie = file_put_contents($save_path, $curlresult);//返回的是字节数
            //删除原有头像
            $sql = 'select concat(path,newfile_name) as file_path from ld_attachments where attachmentsid in( select attachmentsid from ld_salesmanattachmentsrel where smid = ?)';
            $result = $adb->pquery($sql, array($id));
            $file_path = $adb->query_result($result, 0, 'file_path');
            if (file_exists(globalStatic::$root_directory . $file_path)) {
                @unlink(globalStatic::$root_directory . $file_path);
            }
            $delquery = 'delete from ld_attachments where attachmentsid in( select attachmentsid from ld_salesmanattachmentsrel where smid = ?)';
            $adb->pquery($delquery, array($id));
            $delquery = 'delete from ld_salesmanattachmentsrel where smid = ?';
            $adb->pquery($delquery, array($id));
            //将新文件数据存储进去
            //$filename;	//附件名称
            $filename = from_html(preg_replace('/\s+/', '_', $filename));
            $filetype = 'image/jpeg';    //附件类型
            $filesize = $zijie . 'B';    //附件大小
            $newfile_name = $filename;
            $newfile_name = str_replace("&", "_", $newfile_name);
            $cloud_path = '';
            $imagefromtype = $imageval['type'];
            //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 17:09
            //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
            if (empty($upload_from) || $upload_from == 'undefined') {
                $upload_from = '';
            }
            //文件存储位置:腾讯云存储桶/本地 （cos/local）
            $storage_location = 'local';
            if (empty($storage_location) || $storage_location == 'undefined') {
                $storage_location = 'local';
                $cloud_path = '';
            } elseif ($storage_location == 'cos') {
                //给存储桶链接增加头，以便界面显示
                $cloud_path = str_replace("http://", 'https://', $cloud_path);
                if (stripos($cloud_path, 'https://') === false) {
                    $cloud_path = 'https://' . $cloud_path;
                }
            }
            $binFile = sanitizeUploadFileName($filename, $upload_badext);
            $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
            $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id

            if (!strpos($filesize, 'B')) {//Liver 只有新增的附件，才需要计算附件大小并加上單位
                if ($filesize < 1024)
                    $filesize = $filesize . ' B';
                elseif ($filesize > 1024 && $filesize < 1048576)
                    $filesize = round($filesize / 1024, 2) . ' KB';
                else if ($filesize > 1048576)
                    $filesize = round($filesize / (1024 * 1024), 2) . ' MB';
            }

            if ($filename != '') {
                $sql1 = "insert into ld_crmentity (crmid,setype) values(?,?)";
                $params1 = array($current_id, "Users" . " Attachment");
                $userobj->db->pquery($sql1, $params1);
                $db_filepath=substr($upload_file_path,strlen(globalStatic::$root_directory));
                
                $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name, description, type, path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?,?,?,?,?,?,?,?,?,?)";
                $params2 = array($current_id, $filename, $newfile_name, $userobj->column_fields['description'], $filetype, $db_filepath, $filesize, $imagefromtype, $cloud_path, $storage_location, $upload_from);
                $result = $userobj->db->pquery($sql2, $params2);

                if ($id != '') {
                    $delquery = 'delete from ld_salesmanattachmentsrel where smid = ?';
                    $userobj->db->pquery($delquery, array($id));
                }

                $sql3 = 'insert into ld_salesmanattachmentsrel values(?,?)';
                $userobj->db->pquery($sql3, array($id, $current_id));

                //we should update the imagename in the users table
                $userobj->db->pquery("update ld_users set imagename=? where id=?", array($filename, $id));
                return $newfile_name;
            }
        }
    }
    //普通模块图片保存
    public function saveFileFromWeiXinApi_CommonModule($id, $module, $imagestr){
        return false;
        $imageArrNew = $imagestr['new']; // 新增的图片
        $imageArrExist = $imagestr['delete']; //待删除的图片
        global $adb,$current_user;
        if(!empty($imageArrExist)){
            foreach($imageArrExist as $key=>$val){
                $adb->pquery("delete from ld_attachments where attachmentsid=?", array($val));
				$adb->pquery("delete from ld_seattachmentsrel where attachmentsid=?", array($val));
            }
        }
        if(!empty($imageArrNew)) {
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:22

            $ACCESS_TOKEN = $port_obj->getCorpToken();//gyq_33

            if (!empty($ACCESS_TOKEN)) {
                $upload_file_path = decideFilePath();
                $ch = curl_init();
                foreach ($imageArrNew as $imageval) {

                    $imageurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $imageval;

                    curl_setopt($ch, CURLOPT_URL, $imageurl);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                    $curlresult = curl_exec($ch);
                    $curlresult = $this->checkCurlResult($curlresult,$imageurl);
                    $imagetypeEX = 'jpg'; //暂时将图片类型写死 gyqTE
                    $imagetype = 'image/jpeg';
                    $time = time();
                    $rand = mt_rand(1, 100000);
                    $filename = $time . $rand;
                    $current_id = $adb->getUniqueID("ld_crmentity");
                    //$file_name_final = $filename . '.' . $imagetypeEX;//id加附件名称
                    $filename_sql = $filename . '.' . $imagetypeEX;
                    //editor:gyq_20200106 reason:纠正不正常变量 2020/1/6 13:36
                    $newfile_name=getUploadFileName($filename_sql,$module);
                    $save_path = globalStatic::$root_directory . $upload_file_path . $newfile_name;
                    mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                    $zijie = file_put_contents($save_path, $curlresult);//返回的是字节数
                    if ($zijie > 0) {
                        $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?)';
                        $params1 = array($current_id, $module . " Image");
                        $adb->pquery($sql1, $params1);
                        $sql2 = "insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,storage_location) values(?,?,?,?,?,?,?,?)";
                        $params2 = array($current_id, $filename_sql,$newfile_name, '', $imagetype, $upload_file_path,$zijie,'local');
                        $result = $adb->pquery($sql2, $params2);
                        //editor:gyq_20200106 reason:插入语句必须写明哪些字段 2020/1/6 13:36
                        $sql3 = 'insert into ld_seattachmentsrel (crmid,attachmentsid) values(?,?)';
                        $adb->pquery($sql3, array($id, $current_id));
                    }
                }
                curl_close($ch);
                return true;
            }
        }
    }

    //普通模块附件保存，暂时只有图片
    public function saveAttachmentFromWeiXinApi_CommonModule($id, $module, $arr_filestr){
        return false;
            $T1 = array('album'=>'Albums','camera'=>'Takephoto');
            $upload_file_path = decideFilePath();
             crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
             $port_obj = new cls_WeixinPort();
          
      //   file_put_contents(globalStatic::$root_directory.'WeiXinApp/detail/6.txt',json_encode($arr_filestr));
        foreach($arr_filestr as $columnname=>$filestr)
        {
            $fileArrNew = $filestr['new']; // 新增的图片
            $fileArrExist = $filestr['delete']; //待删除的图片
            //editor:gyq_20190325 reason:区分拍照、相册、电脑上传
         
            global $adb,$current_user;
            if(!empty($fileArrExist)){
                foreach($fileArrExist as $key=>$val){
                    $adb->pquery("delete from ld_attachments where attachmentsid=?", array($val));
    				$adb->pquery("delete from ld_seattachmentsrel where attachmentsid=?", array($val));
                }
            }
            if(!empty($fileArrNew)) {
                
               
    
                $ACCESS_TOKEN = $port_obj->getCorpToken();
    
                if (!empty($ACCESS_TOKEN)) {
                   
                    $ch = curl_init();
                    foreach ($fileArrNew as $fileval) {
    
                        $fileurl = 'https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token=' . $ACCESS_TOKEN . '&media_id=' . $fileval['serverId'];
    
                        curl_setopt($ch, CURLOPT_URL, $fileurl);
                        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                        $curlresult = curl_exec($ch);
                        $curlresult = $this->checkCurlResult($curlresult,$fileurl);
                        $imagetypeEX = 'jpg'; //暂时将图片类型写死 gyqTE
                        $imagetype = 'image/jpeg';
                        $time = time();
                        $rand = mt_rand(1, 100000);
                        $filename = $time . $rand;
                        $current_id = $adb->getUniqueID("ld_crmentity");
                        //$file_name_final = $filename . '.' . $imagetypeEX;//id加附件名称
                        $filename_sql = $filename . '.' . $imagetypeEX;
                        $newfile_name=getUploadFileName($filename_sql,$module);
                        $save_path = globalStatic::$root_directory . $upload_file_path . $newfile_name;
                        mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                        $zijie = file_put_contents($save_path, $curlresult);//返回的是字节数
                        if ($zijie > 0) {
                            $filesize = filesize($save_path);
                            //确定文件大小
                			if ($filesize < 1024)
                				$filesize = $filesize . ' B';
                			elseif ($filesize > 1024 && $filesize < 1048576)
                				$filesize = round($filesize / 1024, 2) . ' KB';
                			else if ($filesize > 1048576)
                				$filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                            $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?)';
                            $params1 = array($current_id, "Attachment");
                            $adb->pquery($sql1, $params1);
                            $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name, description, type, path,size,imagefromtype,storage_location) values(?,?, ?, ?, ?, ?, ?,?,?)";
                            $params2 = array($current_id, $filename_sql, $newfile_name,'', $imagetype, $upload_file_path,$filesize,$T1[$fileval['type']],'local');
                            $result = $adb->pquery($sql2, $params2);
                           //  $filehandler=fopen(globalStatic::$root_directory.'WeiXinApp/detail/2.txt','w');
                           //  fwrite($filehandler,$sql2."\n");
                           //  fwrite($filehandler,json_encode($params2));
                           //  fclose($filehandler);
                            //editor:gyq_20200106 reason:插入语句必须写明哪些字段 2020/1/6 13:36
                            $sql3 = 'insert into ld_seattachmentsrel (crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                            $adb->pquery($sql3, array($id, $current_id,$columnname));
                        }
                    }
                    curl_close($ch);
                   
                }
            }
        }
         return true;
    }
    public function uploadAndSaveFileForBase64($id, $module, $imagestr){
        $imageArrNew = $imagestr['new']; // 新增的图片
        $imageArrExist = $imagestr['delete']; //待删除的图片
        global $adb,$current_user;
        if(!empty($imageArrExist)){
            foreach($imageArrExist as $key=>$val){
                $delquery = 'delete from ld_seattachmentsrel where crmid = ? and attachmentsid = ?';
                $delparams = array($id, $val);
                $adb->pquery($delquery, $delparams);
            }
        }
        if(!empty($imageArrNew)) {
            $pregstr = '/:.*;/';
            $upload_file_path = decideFilePath();
            foreach($imageArrNew as $imageval) {
                if (preg_match($pregstr, $imageval, $search, PREG_OFFSET_CAPTURE)) {
                    $imagetype = substr($search[0][0], 1, strlen($search[0][0]) - 2);
                    $imagetypeEX = substr($imagetype, 6);
                }
                $base64_body = substr(strstr($imageval, ','), 1);
                $img = base64_decode($base64_body);
                $time = time();
                $rand = mt_rand(1, 100000);
                $filename = $time . $rand;
                $current_id = $adb->getUniqueID("ld_crmentity");
                $file_name_final = $current_id . "_" . $filename . '.' . $imagetypeEX;//id加附件名称
                $filename_sql = $filename . '.' . $imagetypeEX;
                $save_path = globalStatic::$root_directory . $upload_file_path . $file_name_final;
                mkdir(globalStatic::$root_directory . $upload_file_path, 0777, true);
                $zijie = file_put_contents($save_path, $img);//返回的是字节数
                if ($zijie > 0) {
                    $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?)';
                    $params1 = array($current_id, $module . " Image");
                    $adb->pquery($sql1, $params1);
                    $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name description, type, path) values(?, ?, ?, ?, ?,?)";
                    $params2 = array($current_id, $filename_sql,$filename_sql, '', $imagetype, $upload_file_path);
                    $result = $adb->pquery($sql2, $params2);

                    $sql3 = 'insert into ld_seattachmentsrel values(?,?)';
                    $adb->pquery($sql3, array($id, $current_id));
                }
            }
            return true;
        }

    }
    //判断获取微信接口图片结果是否为空
    public function checkCurlResult($curlresult,$url){
        if(empty($curlresult)){
            ConvertTojsonString(-701,'fail','图片上传不成功，是否继续保存？');
        }elseif(!empty($url)){
            //editor:gyq_20190409 记录附件保存错误时的token和mediaid，方便调试
            $curl_arr = json_decode($curlresult,true);
            if($curl_arr['errcode'] > 0){
                $curl_arr['last_url'] = $url;
                $curlresult = json_encode($curl_arr);
            }
        }
        return $curlresult;
    }
    // editor:gyq_93 reason:单据编号重复时，编号在最大编号上自动加一，并且弹出提示信息  2018/12/21 15:06
    public function ConvertTojsonStringInSave(){
        $output  = array();
        $remind_tip = $_SESSION[$this->module.'_modulebillnotip'];
        if($remind_tip=='yes'){
            //edit:can 2021-02-26 44726: （企业微信移动端-kfbcrm）联系人-新建；新建联系人保存，当联系人编号重复，保存时的提示信息有问题“单据编号AOTO...”，不是中文提示
            $fieldlabel =getFixedLabel('DocumentNumber')."重复，已自动生成新的编号";
            $output['billno_repeattip'] = $fieldlabel;
        }
        
        $output['recordid']  =$this->focus->id;

        //检查是否有API调用
        crm_load_class_file("cls_savereverse",'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($this->module);
        $receive_msg = $workflowreverseobj->checkCallApiPop();
        $output['workflow']['receive_msg'] = $receive_msg;
        if ($receive_msg == 'yes') {
            $output['workflow']['record'] = $this->focus->id;
            $output['workflow']['module'] = $this->module;
            $output['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
        }

        ConvertTojsonString(1,$output,'success');
    }
    //editor:gyq_96 reason:企业微信客户服务单增加签到  2019/1/9 14:16
    //editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型   2020/1/21 11:43
    public function insert_signin(){
        //echo 11111;die;
        if(!empty($_REQUEST['signData'])){
            global $adb,$current_user,$PlatformMC,$weixin_user;
            $signdata = $_REQUEST['signData'];
            // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化
            $tmpFocus = cls_Instance::get_module_Instance($this->module);
            $tableName = $tmpFocus->table_name;
            $tableIndex =$tmpFocus->table_index;
            $sql = 'update '.$tableName.' set sign_longtitude=?,sign_latitude=?,sign_location_address=? where '.$tableIndex.'=?';

            //说明：跟进记录、客户服务单签到，只做新增保存时统计到签到统计表，编辑保存时，不统计到签到统计表
            if($signdata['latitude'] != '') {
                //duan 20230213 特殊情况处理，对于传地址错误的情况下，重新获取地址
                if(empty($signdata['address']) || strpos($signdata['address'],'定位中')!==false ){
					crm_load_class_file('cls_Tencent_Map', 'include/utils');
                    $cls_Tencent_Map = new cls_Tencent_Map();
                    $tmp_info = $cls_Tencent_Map->getAddressForPoint($signdata['longitude'],$signdata['latitude']);
                    $signdata['address'] = $tmp_info['address'];
				}
                $adb->pquery($sql, array($signdata['longitude'], $signdata['latitude'], $signdata['address'], $this->focus->id));
                $firstdistance = '无法计算';
                $entityaddress = '';

                if(isset($signdata['distance'])&&is_numeric($signdata['distance'])){
                    $firstdistance = intval($signdata['distance']);
                    $entityaddress = $signdata['sysaddress'];
                }else{
                    if (!empty($signdata['sysaddress']) && $signdata['sysaddress'] != '--无--') {
                        $data_address = $signdata['sysaddress'];
                        $entityaddress = $data_address;
                        $accountAddressInfos = getCoordinateByTecentApi($data_address);
                        if (array_key_exists('result', $accountAddressInfos)) {
                            $account_latitude = $accountAddressInfos['result']['location']['lat'];
                            $account_longtitude = $accountAddressInfos['result']['location']['lng'];
                            $firstdistance = getDistance($account_latitude, $account_longtitude,$signdata['latitude'], $signdata['longitude']);
                        }
                    }
                }

                $time = date('Y-m-d H:i:s', time());
                $uuid = $signdata['uuid'];
                //editor:diony 20210511 拜访签到保存时
                if($PlatformMC['type_mini']){
                    //editor:gyq_20190412 0036567: 小程序-考勤签到-常用报表-签到考勤表不显示手机设备号。
                    $sql = 'select wx_openid from ld_users where id=?';
                    $result = $adb->pquery($sql,array($current_user->id));
                    $uuid = $adb->query_result($result,0,'wx_openid');
                }

                //判断是否存在签到记录
                $record = $this->focus->id;
                $pre_sql = 'SELECT longtitude,latitude,address,distince,signid from ld_singin where record = ? and from_module = ?';
                $pre_result = $adb->pquery($pre_sql,array($record,$this->module));
                if($adb->num_rows($pre_result)>0){
                    $signid = $adb->query_result($pre_result,0,'signid');
                    $pre_address = $adb->query_result($pre_result,0,'address');
                    $pre_distince = $adb->query_result($pre_result,0,'distince');
                    if($pre_address != $signdata['address'] || $pre_distince != $firstdistance ){
                        $updatesql = "UPDATE ld_singin set longtitude = ?,latitude = ?,address = ?,distince = ?,accounts_lng = ?,accounts_lat = ?,
	                    entityname = ?,entityaddress = ?,modifiedtime = NOW(),modifiedby = ?,signin_address = ? where signid = ?";
                        $adb->pquery($updatesql,[$signdata['longitude'],$signdata['latitude'],$signdata['address'],$firstdistance,$account_longtitude,
                            $account_latitude,$this->focus->column_fields[$this->focus->list_link_field],$entityaddress,$current_user->id,$signdata['address'],$signid]);

                        //添加签到字段修改日志
                        $signin_field = $this->focus->fieldobj->getFieldInfoobjBykey('bigtype','signin');
                        if(!empty($signin_field)){
                            $time = date('Y-m-d H:i:s',time());$status = 0;
                            $trackid = $adb->getUniqueID('ld_modtracker_basic');
                            $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
							values(?,?,?,?,?,?);';
                            $field_cur_value = $pre_address;
                            $new_value = $signdata['address'];
                            $adb->pquery($query,array($trackid,$record,$this->module,$current_user->id,$time,$status));
                            $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
                            $adb->pquery($query,array($trackid,$signin_field->getFieldName(),$field_cur_value,$new_value));
                        }

                        $savetype = 'edit';
                    }
                }else{
                    //editor:gyq_20200119 reason:插入语句错误，少一个问号
                    $signsql = 'insert into ld_singin (createdtime,userid,longtitude,latitude,address,tabid,record,entityname,distince,entityaddress,signway,uuid) value (?,?,?,?,?,?,?,?,?,?,?,?)';
                    $adb->pquery($signsql, array($time, $current_user->id, $signdata['longitude'], $signdata['latitude'], $signdata['address'], getTabid($this->module),
                        $this->focus->id, $this->focus->column_fields[$this->focus->list_link_field], $firstdistance, $entityaddress, $signdata['signway'], $uuid));

                    //duan 20221210 模块的签到字段保存后，在ld_crmentity 中增加关联关系,并更新需要显示的字段值
                    $newid = $adb->getLastInsertID();
                    $Singin_focus = CRMEntity::getInstance('Singin');
                    $Singin_focus->insertIntoCrmEntity('Singin');
                    $singid = $Singin_focus->id;
                    $updatesql = "update ld_singin set signid=?,entitytype=?,source_list=?,smcreatorid=?,smownerid=?,deleted=?,from_module=? where id =?";
                    $adb->pquery($updatesql,array($singid,$this->module,$this->focus->id,$current_user->id,$current_user->id,0,$this->module,$newid));
                    $insertsql = "insert into ld_singinscf(signid) values(?)";
                    $adb->pquery($insertsql,array($singid));
                
                    $savetype = 'create';
                    // file_put_contents(globalStatic::$root_directory.'WeiXinApp/detail/a.txt',json_encode($_REQUEST['file_save_weixin']));
                    
                    // if($PlatformMC['type_mini'] || $weixin_user->environment=='dingtalk'){
                        //if(!empty($_REQUEST['file_save_weixin'])
                        //||($PlatformMC['type_mini'] || $weixin_user->environment=='dingtalk'))
                        //{


                    // }
                }
                //签到源单模块开启后添加水印文字
                $SQL='select attachmentcolumnname,ld_attachments.* from ld_seattachmentsrel
                    inner join ld_attachments   on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                    where ld_seattachmentsrel.crmid=?';
                $result=$adb->pquery($SQL,array($this->focus->id));

                $rows=$adb->num_rows($result);
                crm_load_class_file('cls_ImageText','include');
                $line_arr=array();
                $line_arr[]=$current_user->last_name;
                $line_arr[]=DateOperation::getDateChinese(date("Y-m-d")).' '.DateOperation::getWeekName(date("Y-m-d"))." ".date("H:i");
                $line_arr[]=$signdata['address'];
                $pre_attachmentcolumnname = null;//记录字段columnname
                $uploadwatermark_arr = [];
                $k = 0;
                for($i=0;$i<$rows;$i++)
                {
                    $newfile_name=$adb->query_result($result,$i,'newfile_name');
                    $storage_location=$adb->query_result($result,$i,'storage_location');

                    $attachmentcolumnname = $adb->query_result($result,$i,'attachmentcolumnname');
                    if(isset($uploadwatermark_arr[$attachmentcolumnname])){
                        $uploadwatermark = $uploadwatermark_arr[$attachmentcolumnname];
                    }else{
                        $uploadwatermark = $this->isUploadWaterMarkWhenCreate(getTabid($this->module),$attachmentcolumnname);
                        $uploadwatermark_arr[$attachmentcolumnname] = $uploadwatermark;
                    }
                    
                    if ($pre_attachmentcolumnname !== null && $attachmentcolumnname !== $pre_attachmentcolumnname) {//当attachmentcolumnname改变时重置k计数
                        $k = 0;
                    }
                
                    if ($uploadwatermark == 'yes') {
                        $path=$adb->query_result($result,$i,'path');
                        $extension_arr=pathinfo($newfile_name);
                        $extension=strtolower($extension_arr['extension']);
                        if(($extension=='png'||$extension=='jpg'||$extension=='jpeg') )
                        {
                            $attachment_id = $_REQUEST[$attachmentcolumnname . '-id_' .($k+1)];
                            if($attachment_id == '0' || $attachment_id == 0 || empty($attachment_id)){//判断是否为新上传的，id=0就是新上传的
                                if($storage_location=='cos'){
                                    $cloud_path = $adb->query_result($result,$i,'cloud_path');
                                    $this->saveCosWaterMark($cloud_path,$path,$newfile_name,$line_arr);//cos图片添加文字水印方法
                                }else{
                                    $imagetextobj=new cls_ImageText($path.$newfile_name,$newfile_name,$line_arr);
                                    $imagetextobj->saveImage();
                                }
                            }
                        }
                    }
                    $pre_attachmentcolumnname = $attachmentcolumnname;
                    $k++;
                }
                //工作流程反写
                crm_load_class_file("cls_savereverse",'include/SaveReverse');
                $workflowreverseobj=cls_savereverse::getInstance('Singin');
                $workflowreverseobj->setRecord($signid);
                $beforefieldvalue_arr=[];
                $afterfieldvalue_arr=[];

                foreach($Singin_focus->before_field_info as $fieldinfo)
                {
                    $beforefieldvalue_arr[$fieldinfo->getFieldName()]=$fieldinfo->getColumn_Value();
                }
                
                $afterfieldvalue_arr=$Singin_focus->after_save_infos[0];
                
                if($savetype=='edit')
                {
                    $pagemode='updated';
                }else{
                    $pagemode='creation';
                }
                // $_REQUEST['aaa'] = 111;
                $workflowreverseobj->setPageMode($pagemode);
                if ($workflowreverseobj->checkCallApiPop() == 'yes')
                    $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));//无需处理的API类型
                $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
            }
        }
    }


    //@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）（uploadwatermark）
    /**
     * @Description 页面设置，销售线索、客户、联系人、跟进记录、销售机会、客户服务单、项目立项、市场活动Campaigns、产品管理 签到地址 增加字段属性“移动端上传图片添加签到水印” 是否开启 （移动端模块新增单据时 签到地址开启后上传图片添加水印）
     * @return  'yes' or 'no'
     *
     * $attachmentcolumnname  1、imagename 图片或照片  2、filename 预置附件字段  3、自定义附件字段。eg：cf_4416
     */
    public function isUploadWaterMarkWhenCreate($tabid,$attachmentcolumnname){
        global $adb;
        $sql = "select uploadwatermark from ld_field where tabid = ? and columnname = ? and presence <> 1 limit 1"; // 启用签到地址，presence为2 ，默认不启用 为1
        $result = $adb->pquery($sql,array($tabid,$attachmentcolumnname));
        if ($adb->num_rows($result) > 0) {
            $uploadwatermark = $adb->query_result($result,0,'uploadwatermark');
        }else{
            $uploadwatermark = 'no';
        }
        return $uploadwatermark;

    }

    //@edit:liushuai,2021-06-02,reason:【ID1001653】签到源单类型定制，增加参数“拜访签到上传图片添加水印”（第一版）
    /**
     * @Description 拜访签到上传图片添加水印 是否开启  $tabid = 142，表示签到模块Singin
     * @return  'yes' or 'no'
     */
    public function isUploadWaterMark($tabid, $option_tabid){
        global $adb;
        $sql = 'select * from ld_option_module where tabid = ? and option_tabid = ? limit 1';
        $result = $adb->pquery($sql,array($tabid, $option_tabid));
        if ($adb->num_rows($result) > 0) {
            $uploadwatermark = $adb->query_result($result,0,'uploadwatermark');
        }else{
            $uploadwatermark = 'no';
        }
        return $uploadwatermark;

    }

    /**
     * 给cos添加图片水印
     * @return bool
     */
    public function saveCosWaterMark($remotePath, $filepath, $filename, $text)
    {
//        $remotePath = $imageInfo['cloud_path'];  //cos文件的远程路径  'https://'.$addressinfo['image'][0]['cloud_path']

        if (is_array($text)) {
            $tmp_text = '';
            foreach($text as $line)
            {
                $tmp_text .= $line."\r\n";
            }
            $text = $tmp_text;
        }

        //获取图片的基本信息
        $imageInfo = $this->curl_get($remotePath.'?imageInfo');
        if ($imageInfo === NULL) {
            return false;
        }
        $imagewidth = $imageInfo['width'];
        $imageheight = $imageInfo['height'];
        $type = strtolower($imageInfo['format']);
        $filesize = $imageInfo['size'];

        //判断类型是图片、文件大小小于20MB、长宽小于9999像素时添加水印
        if (in_array($type, array('jpeg','jpg','png')) && $filesize > 0 && $filesize < 20*1024*1024 && $imagewidth < 9999 && $imageheight < 9999 ) {
            try {
                require globalStatic::$root_directory . 'WeiXinApp/lib/qcloud/cos_sdk/vendor/autoload.php';
//                crm_load_class_file('StaticConst','WeiXinApp/WeiXin_common');
//                    require_once globalStatic::$root_directory . 'include/cls_File.php';
                //ls 20220919 cos对象存储允许客户自定义(水印)
                require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
                $sts = new QcloudSTS();

                $cosClient = new Qcloud\Cos\Client(
                    array(
                        'region' =>$sts->region,
                        'schema' => 'https', //协议头部，默认为http
                        'credentials' => array(
                            'secretId' => $sts->secretId,
                            'secretKey' => $sts->secretKey
                        )
                    )
                );

                $text = $this->stringBase64($text);
                $font = $this->stringBase64('simfang仿宋.ttf');

                $fontsize = 25;//文字大小
                $fontsize = intval($imagewidth / 960 * $fontsize * 1.3);

                $photo_rgb = $imageInfo['photo_rgb'];//图片主色调   十六进制  0x736246
                $photo_rgb = str_replace('0x','#',$photo_rgb);
                $photo_rgb = $this->hex2rgb($photo_rgb);//16进制转RGB
//                if ($photo_rgb['r'] >= 235 && $photo_rgb['g'] >= 235 && $photo_rgb['b'] >= 235)
                if (array_sum($photo_rgb) > 128*3)//如果背景色为白色或接近白色(RGB取平均值128), 就用黑色字体
                    $fill = "#000000"; //黑色
                else
                    $fill = "#FFFFFF"; //白色
                $fill = $this->stringBase64($fill);

                $remote_watermark_path = $remotePath.'?watermark/2/text/'.$text.'/font/'.$font.'/fontsize/'.$fontsize.'/fill/'.$fill.'/gravity/southwest/dx/20/dy/20/ignore-error/1';
//                file_put_contents(globalStatic::$root_directory.'aaaaaaa.txt',date("Y-m-d H:i:s")."remote_watermark_path:".$remote_watermark_path."\r\n",FILE_APPEND);

                if(file_exists($remote_watermark_path)){
                    $fileBody = fopen($remote_watermark_path, 'rb');
                }else{
                    //本地cos测试 file_exists远程判断返回false，所以执行else
                    $fileBody = fopen(iconv('UTF-8', 'GBK', $remote_watermark_path), 'rb');
                }

                $result = $cosClient->putObject(array(
                    'Bucket' => $sts->bucket,
                    'Key' => $filepath.$filename,
                    'Body' => $fileBody,
//                'ACL' => 'public-read'
                ));

                // 请求成功
//                $cosContent = $result->toArray(); //$cosContent['ObjectURL']
                return true;
            } catch (\Exception $e) {
                // 请求失败
                return false;
            }
        }
    }

    //获取远程文件大小   file_exists方法判断不可用
    public function getfilesize($filepath){
        $content = file_get_contents($filepath);
        $size = strlen($content);

        return $size;
    }

//文字水印base64编码
    public function stringBase64($string){
        if (!empty($string)) {
            $string = base64_encode($string);
            $string = str_replace('+','-',$string);
            $string = str_replace('/','_',$string);
        }

        return $string;
    }


    /**
     * 将16进制颜色转换为RGB
     * @param string $color 16进制颜色值   #736246
     * @return array
     */
    function hex2rgb($hexColor){
        $color=str_replace('#','',$hexColor);
        if (strlen($color)> 3){
            $rgb=array(
                'r'=>hexdec(substr($color,0,2)),
                'g'=>hexdec(substr($color,2,2)),
                'b'=>hexdec(substr($color,4,2))
            );
        }else{
            $r=substr($color,0,1). substr($color,0,1);
            $g=substr($color,1,1). substr($color,1,1);
            $b=substr($color,2,1). substr($color,2,1);
            $rgb=array(
                'r'=>hexdec($r),
                'g'=>hexdec($g),
                'b'=>hexdec($b)
            );
        }
        return $rgb;
    }

    /**
     * @from 菜鸟教程
     * curl  get 请求
     * @param string $url
     * @return array or NULL
     */
    function curl_get($url){
        $headerArray =array("Content-type:application/json;","Accept:application/json");
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch,CURLOPT_HTTPHEADER,$headerArray);
        $output = curl_exec($ch);
        curl_close($ch);
        $output = json_decode($output,true);
        return $output;
    }
    //保存前操作方法
    public function before_save(){
        //duan 20230719 XUQIU1000232 审批必填字段保存时不需要走公共的方法
        if($_REQUEST['isApproveMandatoryField'] == 'yes' && $_REQUEST['miniedit_fieldrule'] == 'no'){
            //保存必填的字段值
            crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
            $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($this->module);
            $mandatoryfieldobj->saveFieldValue($this->focus->id,ldcrm_json_encode($_REQUEST['wx_fieldInfo']));
            //保存执行完成之后执行审批操作
            $approveinfo = ldcrm_json_decode($_REQUEST['approveMandatoryFieldData']);
            $mandatoryfieldobj->saveApproveLog($approveinfo);
            $this->ConvertTojsonStringInSave();
        }

        if(empty($_REQUEST['confirm_save']))
        {
            crm_load_class_file('cls_PageValidataSave','data');//验证规则，提示保存
            $PageValidataSaveobj=new cls_PageValidataSave($this->module,$this->focus->id,$_REQUEST['rowcnt']);
            $PageValidataSaveobj->setAllowSave('yes');


            $PageValidataSaveobj->setCurrencyId($this->focus->column_fields['currency_id']);
            $PageValidataSaveobj->getValidDataInfoPhp();

            if(!empty($PageValidataSaveobj->errortip)){
                //edit:can 20210425 保存验证规则
                $_REQUEST['diony']='yes';
                //zkt 20230809 BUG0070825  从钉钉进入灵当CRM，从报价单下推生成销售订单，当订单金额超出客户信誉金额时无法保存。详见附件视频。
                ConvertTojsonString("confirm_save",array(),$PageValidataSaveobj->errortip);
            }

            //duan 20240716 移动端保存并提交审批时增加提交审批判断
            if($_REQUEST['issavesubmit'] == 'yes'){
                $PageValidataSaveobj->all_validatainfo_arr = [];
                $PageValidataSaveobj->setApplication('savesubmit');
                $PageValidataSaveobj->setAllowSave('yes');
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $_REQUEST['diony']='yes';
                    ConvertTojsonString("confirm_save",array(),$PageValidataSaveobj->errortip);
                }
            }

        }

    }
    //保存后操作方法
    public function after_save(){
        // @edit:dong @date:2020/07/23 @reason: 【签到源单类型定制功能优化】 判断当前模块是开启了源单定位
        //edit:can 2020-12-30 签到图片水印
        $detialViewWx = cls_Instance::get_moduleAction_Instance($this->module,'DetailView');
        if($detialViewWx->isOpenSignIn($this->module,'boolean')){
            $this->insert_signin();
        }

        //duan 20240125 如果审批字段有布局规则，则走通用的保存方法
        if($_REQUEST['isApproveMandatoryField'] == 'yes' && $_REQUEST['miniedit_fieldrule'] == 'fromapprove'){
            crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
            $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($this->module);
            //保存执行完成之后执行审批操作
            $approveinfo = ldcrm_json_decode($_REQUEST['approveMandatoryFieldData']);
            $mandatoryfieldobj->saveApproveLog($approveinfo);
            $this->ConvertTojsonStringInSave();
        }

    }

}