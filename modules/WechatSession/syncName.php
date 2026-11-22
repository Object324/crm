<?php
global $currentModule, $adb;

$_REQUEST['diony'] = 'yes';
require_once(globalStatic::$root_directory . '/appCommon/appCommon.php');

require_once(globalStatic::$root_directory . '/modules/WechatSession/WechatSession.php');
$focus = new WechatSession();
//$focus = CRMEntity::getInstance('WechatSession');

$isAppMarket = judgeCorpInfo("kehu001"); // true '应用市场'

//开始保存
if (isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'save') {
    
//     if(isset($_REQUEST['import_external_contact']))
//     {
//        unset($_SESSION['WechatSession_syncName']);
//     }
//     require_once globalStatic::$root_directory.'WeiXinApp/lib/EventToApiModel.php';
//     $model_obj = new EventToApiModel();
     
    //if (isset($_REQUEST['import_external_contact']) && $_REQUEST['import_external_contact'] == 'true') {
//        //调用导入外部联系人接口功能
//       $_REQUEST['second_action']='import_contact';
//        $result = $model_obj->get_external_contact_list();
//
//        $tmp_contactList_arr=$result['contactlist'];
//        $_SESSION['WechatSession_syncName']['contactlist']=$tmp_contactList_arr;
//    }
//    else if (isset($_REQUEST['sync_external_contact'])&& $_REQUEST['sync_external_contact'] == 'true'&&!$_SESSION['WechatSession_syncName']['sync_external_contact']){
//       //同步会话存档的外部联系
//      if(!isset($_SESSION['WechatSession_syncName']['contactlist'])||!is_array($_SESSION['WechatSession_syncName']['contactlist']))
//       {
//          
//            //$tmp_contactList_arr=$model_obj->get_externalContactList();
//           //$_SESSION['WechatSession_syncName']['contactlist']=$tmp_contactList_arr;
//           
//       }
//       else
//            $tmp_contactList_arr=$_SESSION['WechatSession_syncName']['contactlist'];
//            
//    }
//    if($_SESSION['WechatSession_syncName']['contactlist'])
//        $tmp_contactList_arr=$_SESSION['WechatSession_syncName']['contactlist'];
// 
//     foreach($tmp_contactList_arr as $key=>$tmpvalue_arr)
//     {
//        foreach( $tmpvalue_arr as $tmpkey=>$value)
//         {
//            $external_userid = $value['external_userid'];
//            $name = $value['name'];
//            $corp_name=$value['corp_name'];
//            $contactList_arr[$name.'##'.$corp_name]=$external_userid;
//         }
//         
//     }
    //获取外部联系人姓名和id
     $contactList_arr=array();
     //判断有无外部联系人姓名和id的缓存
     if(!$_SESSION['WechatSession_syncName']['contactList_arr']){
        //如果导入过外部联系人，使用外部联系人缓存
        if($_SESSION['WechatSession_syncName']['external_contact_list']){
            $tmp_contactList_arr = $_SESSION['WechatSession_syncName']['external_contact_list'];
            foreach($tmp_contactList_arr as $key=>$tmpvalue_arr){
                $external_contact = $tmpvalue_arr['external_contact'];
                $external_userid = $external_contact['external_userid'];
                $name = $external_contact['name'];
                $corp_name = $external_contact['corp_name'];
                $contactList_arr[$name.'##'.$corp_name]=$external_userid;
            }
            $_SESSION['WechatSession_syncName']['contactList_arr'] = $contactList_arr;
         }else{ //没有导入则从数据库缓存二十条记录
            $sql_extrnal = "SELECT accountname,lastname,weixin_external_userid FROM ld_account 
            		INNER JOIN ld_contactdetails ON ld_contactdetails.accountid = ld_account.accountid  
            		where weixin_external_userid  <> '' ORDER BY ld_contactdetails.createdtime DESC limit 20";
            $result = $adb->pquery($sql_extrnal,array());
            $nums = $adb->num_rows($result);
            if($nums>0){
                for($i=0;$i<$nums;$i++){
                    $external_userid = $adb->query_result($result,$i,'weixin_external_userid');
                    $name = $adb->query_result($result,$i,'lastname');
                    $corp_name = $adb->query_result($result,$i,'accountname');
                    $contactList_arr[$name.'##'.$corp_name]=$external_userid;
                }
                $_SESSION['WechatSession_syncName']['contactList_arr'] = $contactList_arr;
            }
         }
     }else{
        $contactList_arr = $_SESSION['WechatSession_syncName']['contactList_arr'];
     }
  
     //统计数量
            if (!$_SESSION['WechatSession_syncName']['sync_external_contact']) {
                $wechatid=0;
                $rows=0;
                if(file_exists(globalStatic::$root_directory."user_privileges/syncwechatcontact.txt"))
                {
                    require_once globalStatic::$root_directory.'appCommon/appCommon.php';
                    include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
                    $auto_info_json = doCorpInfo('get_auth_info','');
                    $info_arr = json_decode($auto_info_json, true);
                    $crm_auth = $info_arr[StaticConst::$suite_crm];
                    $corpid = $crm_auth['auth_corp_info']['corpid'];
                    $wechatid=file_get_contents(globalStatic::$root_directory."user_privileges/syncwechatcontact.txt");
                    $wechatid_arr=explode("##",$wechatid);
                       
                    if($corpid==$wechatid_arr[1])
                    {
                        
                        $sql='select  * from ld_wechatexternalid where id>='.$wechatid_arr[0];
                        $result=$adb->pquery($sql,array());
                        $rows=$adb->num_rows($result);
                        $session_external_userid_arr = [];
                        for($i=0;$i<$rows;$i++)
                        {
                            $externalid=$adb->query_result($result,$i,'externalid');
                            $session_external_userid_arr[]=$externalid;
                            
                        }
                        $sql=" select * from ld_external_contact where external_name is null or external_name='' ";
                        $result=$adb->pquery($sql,array());
                        $rows=$adb->num_rows($result);
                        
                        for($i=0;$i<$rows;$i++)
                        {
                            $externalid=$adb->query_result($result,$i,'session_external_userid');
                            $session_external_userid_arr[]=$externalid;
                            
                        }
                        if($rows>0)
                        {
                            $sql=" delete from ld_external_contact where external_name is null or external_name='' ";
                            $adb->pquery($sql,array());
                        }
                        
                        $_SESSION['WechatSession_syncName']['sync_external_contact']['session_external_userid_arr'] = $session_external_userid_arr;
                        $_SESSION['WechatSession_syncName']['sync_external_contact']['total'] = $rows;
                        $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow'] = ceil($rows/10);//向上取整
                        $_SESSION['WechatSession_syncName']['sync_external_contact']['start'] = 0;
                        $_SESSION['WechatSession_syncName']['sync_external_contact']['end'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow']; //当前处理到第几个
                        
                        $rows=1;
                    }
                    
                }
                
                if($rows<=0){
                        //2、将ld_wechatsession表外部联系人同步到ld_external_contact
                        $sql = " SELECT fromid,tolist,roomid FROM ld_wechatsession WHERE session_type = 'external' order by id desc  limit 2000  ";  //倒序排序  先插入后更新
                       $result = $adb->pquery($sql, array());
                        $rows = $adb->num_rows($result);
                       
                        if ($rows> 0) {
                            $session_external_userid_arr = [];
                            for ($i = 0; $i < $rows; $i++) {
        //                    $roomid = $adb->query_result($result, $i, 'roomid');
                                $fromid = $adb->query_result($result, $i, 'fromid');
                                $tolist = $adb->query_result($result, $i, 'tolist');
        
                                if ((strpos($fromid,'wo') !== false) || (strpos($fromid,'wm') !== false)) {
                                    if (!in_array($fromid, $session_external_userid_arr)) {
                                        array_push($session_external_userid_arr,$fromid);
                                    }
        
                                }
        
                                $tmp_tolist = explode(',',$tolist);
                                if (is_array($tmp_tolist) && sizeof($tmp_tolist) > 1) {//外部群聊
                                    foreach ($tmp_tolist as $userid){
                                        if ((strpos($userid,'wo') !== false) || (strpos($userid,'wm') !== false)) {
                                            if (!in_array($userid, $session_external_userid_arr)) {
                                                array_push($session_external_userid_arr,$userid);
                                            }
                                        }
                                    }
                                }else{//外部单聊
                                    if ((strpos($tolist,'wo') !== false) || (strpos($tolist,'wm') !== false)) {
                                        if (!in_array($tolist, $session_external_userid_arr)) {
                                            array_push($session_external_userid_arr,$tolist);
                                        }
                                    }
                                }
        
                            }
        
                            $total_num1 = count($session_external_userid_arr);
                            $_SESSION['WechatSession_syncName']['sync_external_contact']['session_external_userid_arr'] = $session_external_userid_arr;
                            $_SESSION['WechatSession_syncName']['sync_external_contact']['total'] = $total_num1;
                            $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow'] = ceil($total_num1/10);//向上取整
                            $_SESSION['WechatSession_syncName']['sync_external_contact']['start'] = 0;
                            $_SESSION['WechatSession_syncName']['sync_external_contact']['end'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow']; //当前处理到第几个
        
                        }else{
                            ConvertTojsonString(1, array(), 'success');   // 下一个请求
                        }
                }
                
              //file_put_contents(globalStatic::$root_directory.'modules/WechatSession/a.txt','a',FILE_APPEND);
              

            }else{
             $_SESSION['WechatSession_syncName']['sync_external_contact']['start'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['end'];
             $_SESSION['WechatSession_syncName']['sync_external_contact']['end'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['end'] + $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow'];
            }
             

            $start = $_SESSION['WechatSession_syncName']['sync_external_contact']['start'];
            $intervalrow = $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow'];
            $session_external_userid_arr = $_SESSION['WechatSession_syncName']['sync_external_contact']['session_external_userid_arr'];//待处理结果集
            
    //同步外部联系人姓名
    /*
     * 表示获取企业微信“外部联系人姓名”、“外部联系人ID”、“会话存档联系人的ID”.
     * 说明：
     * 1、如果是应用市场授权“会话存档联系人的ID”等于“外部联系人ID”；
     * 2、如果是非应用市场授权“会话存档联系人的ID”不等于“外部联系人ID”，需要另外调用外部联系人接口获取“外部联系人ID”
    */
    
    if (isset($_REQUEST['sync_external_contact']) && $_REQUEST['sync_external_contact'] == 'true') {
            //同步会话存档外部联系人姓名
         
        if ($isAppMarket) { //应用市场

            //2、将ld_contactdetails表外部联系人同步到ld_external_contact
            $start = $_SESSION['WechatSession_syncName']['sync_external_contact']['start'];
            $intervalrow = $_SESSION['WechatSession_syncName']['sync_external_contact']['intervalrow'];

            //联系人表的外部联系人插入到ld_external_contact
            $sql = "INSERT INTO ld_external_contact (contactid, external_name,weixin_external_userid,session_external_userid,corp_name) 
                      select ld_contactdetails.contactid,ld_contactdetails.lastname,ld_contactdetails.weixin_external_userid
                     , ld_contactdetails.weixin_external_userid,ld_account.accountname 
                from ld_contactdetails INNER JOIN ld_account
                
                on ld_contactdetails.accountid=ld_account.accountid
                LEFT JOIN ld_external_contact on ld_external_contact.weixin_external_userid =ld_contactdetails.weixin_external_userid
                where ld_contactdetails.deleted=0 and  ld_external_contact.weixin_external_userid is null
                and ld_contactdetails.weixin_external_userid <>'' 
                
               GROUP BY ld_contactdetails.weixin_external_userid LIMIT {$start},{$intervalrow};";

            $result = $adb->pquery($sql, array());
            //更新ld_external_contact的表联系人姓名和公司名称
            $sql="update ld_external_contact
                 inner join (
                                      select ld_contactdetails.contactid,ld_contactdetails.lastname,ld_contactdetails.weixin_external_userid
                                      ,ld_account.accountname 
                                from ld_contactdetails INNER JOIN ld_account
                                
                                on ld_contactdetails.accountid=ld_account.accountid
                                
                                where ld_contactdetails.deleted=0 
                                and ld_contactdetails.weixin_external_userid <>'' 
                                
                               GROUP BY ld_contactdetails.weixin_external_userid LIMIT {$start},{$intervalrow})
                as tmp  on    tmp.weixin_external_userid =ld_external_contact.weixin_external_userid
                set ld_external_contact.external_name=tmp.lastname,ld_external_contact.corp_name=tmp.accountname ";
            $result = $adb->pquery($sql, array());
        }
        else {  //非应用市场
            if (isset($_REQUEST['secret']) && $_REQUEST['secret'] != '') {
                 require_once globalStatic::$root_directory.'appCommon/appCommon.php';
                 include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
                $auto_info_json = doCorpInfo('get_auth_info','');
                $info_arr = json_decode($auto_info_json, true);
                $crm_auth = $info_arr[StaticConst::$suite_crm];
                $corpid = $crm_auth['auth_corp_info']['corpid'];
                file_put_contents(globalStatic::$root_directory.'user_privileges/syncwechatsecret.txt',$_REQUEST['secret'].'##'.$corpid);
                
                $secret = trim($_REQUEST['secret']);
            }else{
                ConvertTojsonString(-1, array(), '请填写secret'); //正常不会走到这儿，保险起见防止前端错误
            }
         
             $sql="update ld_external_contact inner join (

                    select weixin_external_userid,lastname,accountname   from ld_contactdetails
                     INNER JOIN ld_account on ld_contactdetails.accountid=ld_account.accountid
                    where ld_contactdetails.deleted=0 and weixin_external_userid<>''  limit  {$start},{$intervalrow})
                    as tmp  on ld_external_contact.external_name=tmp.lastname and case when 
                    	corp_name<>'' then corp_name=accountname
                    else 1=1 end  
                    set ld_external_contact.weixin_external_userid=tmp.weixin_external_userid ";
                $adb->pquery($sql,array());
                
                
                $sql="update ld_external_contact
                     inner join (
                                          select ld_contactdetails.contactid,ld_contactdetails.lastname,ld_contactdetails.weixin_external_userid
                                          ,ld_account.accountname 
                                    from ld_contactdetails INNER JOIN ld_account
                                    
                                    on ld_contactdetails.accountid=ld_account.accountid
                                    
                                    where ld_contactdetails.deleted=0 
                                    and ld_contactdetails.weixin_external_userid <>'' 
                                    
                                   GROUP BY ld_contactdetails.weixin_external_userid LIMIT {$start},{$intervalrow})
                    as tmp  on    tmp.weixin_external_userid =ld_external_contact.weixin_external_userid
                    set ld_external_contact.external_name=tmp.lastname,ld_external_contact.corp_name=tmp.accountname ";
                $result = $adb->pquery($sql, array());
        }
       
           
            
            $tmp_session_external_userid_arr = array_slice($session_external_userid_arr,$start,$intervalrow);
          
                   
            //3、通过外部联系人接口获取姓名
            foreach ($tmp_session_external_userid_arr as $session_external_userid) {

                    //4、根据姓名 公司名称 匹配联系人表  获取联系人表的weixin_external_userid
                    $is_exists_sql = "select   weixin_external_userid from ld_external_contact
                     where session_external_userid = ?
                       LIMIT 1";
                    $is_exists_result = $adb->pquery($is_exists_sql, array($session_external_userid));
                    if($adb->num_rows($is_exists_result)>0)
                    {
                        $db_weixin_external_userid=$adb->query_result($is_exists_result,0,'weixin_external_userid');
                        if(!empty($db_weixin_external_userid))
                            continue;
                    }
                    $data = $focus->getExternalContactInfo($session_external_userid,$secret);
                   
                    if(empty($data)||$data['errcode']!=0)
                        continue;
                    
                    $external_contact = $data['external_contact'];
                    $external_name = $external_contact['name'];// 如果外部联系人为微信用户，则返回外部联系人的名称为其微信昵称；如果外部联系人为企业微信用户，则会按照以下优先级顺序返回：此外部联系人或管理员设置的昵称、认证的实名和账号名称。
                    if ($external_contact['type'] == 2) {//外部联系人的类型，1表示该外部联系人是微信用户，2表示该外部联系人是企业微信用户
                        $corp_name = $external_contact['corp_name'];//企业简称 仅当联系人类型是企业微信用户时有此字段  ，导入外部联系人时取得值是corp_name
//                        $corp_full_name = $external_contact['corp_full_name'];//企业全称 仅当联系人类型是企业微信用户时有此字段
                    }else{
                        $corp_name = '';
                        
                    }
                    //若缓存中没有对应记录，则从数据库获取小于等于当前用户创建时间的二十条数据写入缓存
                    if(!isset($contactList_arr[$external_name.'##'.$corp_name])){
                        $sql = "SELECT lastname,accountname,weixin_external_userid FROM  ld_account
                                INNER JOIN ld_contactdetails ON ld_contactdetails.accountid = ld_account.accountid
                                WHERE weixin_external_userid <> '' AND ld_account.createdtime <= 
                                    (SELECT ld_account.createdtime FROM ld_account
                                    INNER JOIN ld_contactdetails ON ld_contactdetails.accountid = ld_account.accountid
                                    WHERE  weixin_external_userid <> '' AND accountname = ? AND lastname = ?) 
                                ORDER BY ld_account.createdtime DESC LIMIT 20";
                        $result = $adb->pquery($sql,array($corp_name,$external_name));
                        $nums = $adb->num_rows($result);
                        if($nums>0){
                            for($i=0;$i<$nums;$i++){
                                $external_userid = $adb->query_result($result,$i,'weixin_external_userid');
                                $name = $adb->query_result($result,$i,'lastname');
                                $corp_name = $adb->query_result($result,$i,'accountname');
                                $contactList_arr[$name.'##'.$corp_name]=$external_userid;
                            }
                            $_SESSION['WechatSession_syncName']['contactList_arr'] = $contactList_arr;
                        }
                    }
                    $weixin_external_userid=$contactList_arr[$external_name.'##'.$corp_name]; 
                    if ($adb->num_rows($is_exists_result) <= 0) {
//                        $weixin_external_userid = $adb->query_result($query_result, 0, 'weixin_external_userid');
                       // file_put_contents(globalStatic::$root_directory.'tmp_session_external_userid_arr.txt',date("Y-m-d H:i:s")."\r\n".'session_external_userid_data_result: ,'.$external_name.','.$session_external_userid."\r\n",FILE_APPEND);
                        $sql = 'insert into ld_external_contact(external_name,weixin_external_userid,session_external_userid,corp_name) value(?,?,?,?)';
                        $external_name=filterEmoji($external_name);
                        $adb->pquery($sql, array($external_name,$weixin_external_userid, $session_external_userid,$corp_name));
                      
                    }
                    else{
                        $sql='update ld_external_contact set weixin_external_userid=? where session_external_userid=?';
                        $adb->pquery($sql,array($weixin_external_userid,$session_external_userid));                  
                    }
            }

            if ($_SESSION['WechatSession_syncName']['sync_external_contact']['end'] < $_SESSION['WechatSession_syncName']['sync_external_contact']['total']){  //还未结束
                $arr['title'] = getFixedLabel('SyncName');
                $arr['start'] = $start;
                $arr['end'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['end'];
                $arr['total'] = $_SESSION['WechatSession_syncName']['sync_external_contact']['total'];
                $arr['percent'] = floor($arr['end']/($_SESSION['WechatSession_syncName']['sync_external_contact']['total'])*100);
                $arr['SESSION'] = $_SESSION['WechatSession_syncName']['sync_external_contact'];
                ConvertTojsonString(2, $arr, 'success');   //2 继续当前请求
            }else{
              
                $sql='select max(id) as maxchatid from ld_wechatexternalid  ';
                $result=$adb->pquery($sql,array());
                if($adb->num_rows($result)>0)
                {
                    $maxchatid=$adb->query_result($result,0,'maxchatid');
                     require_once globalStatic::$root_directory.'appCommon/appCommon.php';
                     include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
                    $auto_info_json = doCorpInfo('get_auth_info','');
                    $info_arr = json_decode($auto_info_json, true);
                    $crm_auth = $info_arr[StaticConst::$suite_crm];
                    $corpid = $crm_auth['auth_corp_info']['corpid'];
                   file_put_contents(globalStatic::$root_directory."user_privileges/syncwechatcontact.txt",$maxchatid.'##'.$corpid);
                    
                }
                if(!$isAppMarket)
                {
                     $sql="update ld_external_contact inner join (

                    select weixin_external_userid,lastname,accountname   from ld_contactdetails
                     INNER JOIN ld_account on ld_contactdetails.accountid=ld_account.accountid
                    where ld_contactdetails.deleted=0 and weixin_external_userid<>''  )
                    as tmp  on ld_external_contact.external_name=tmp.lastname and case when 
                    	corp_name<>'' then corp_name=accountname
                    else 1=1 end  
                    set ld_external_contact.weixin_external_userid=tmp.weixin_external_userid ";
                $adb->pquery($sql,array());
                }
                $end=$_SESSION['WechatSession_syncName']['sync_external_contact']['end'];
                
//                ConvertTojsonString(1, array('start'=>$start,'end'=>$end), 'success');   // 下一个请求
                ConvertTojsonString(1, array(), 'success');   // 下一个请求
            }
        //}
    }


    //同步群名称
    if (isset($_REQUEST['sync_group_name']) && $_REQUEST['sync_group_name'] == 'true') {
        //更新ld_wechatsession表的 内部群聊名称  roomname字段
        /*$focus->updateRoomName();
        //更新外部群聊名称
        if (isset($_REQUEST['secret']) && $_REQUEST['secret'] != '') {
            $secret = trim($_REQUEST['secret']);
             $focus->updateExternalRoomName('',$secret);  //要是客户联系应用的access_token不能和会话存档应用的access_token，使用同一个类生成，那还得再写方法生成。
        }*/

        $secret = trim($_REQUEST['secret']);

        if(!$_SESSION['WechatSession_syncName']['sync_group_name']){
            $wechatgroupname=0;
            if(file_exists(globalStatic::$root_directory."user_privileges/syncwechatgroupname.txt"))
            {
                require_once globalStatic::$root_directory.'appCommon/appCommon.php';
                include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
                $auto_info_json = doCorpInfo('get_auth_info','');
                $info_arr = json_decode($auto_info_json, true);
                $crm_auth = $info_arr[StaticConst::$suite_crm];
                $corpid = $crm_auth['auth_corp_info']['corpid'];
                $wechatgroupname=file_get_contents(globalStatic::$root_directory."user_privileges/syncwechatgroupname.txt");
                $wechatid_arr=explode("##",$wechatgroupname);

                if($corpid==$wechatid_arr[1]) {
                    $_SESSION['WechatSession_syncName']['sync_group_name']['lastid'] = $wechatid_arr[0];
                }else{
                    $_SESSION['WechatSession_syncName']['sync_group_name']['lastid'] = 0;
                }
            }else{
                $_SESSION['WechatSession_syncName']['sync_group_name']['lastid'] = 0;
            }

            $lastid = $_SESSION['WechatSession_syncName']['sync_group_name']['lastid'];//同步群最后一次主键id的值
            if (!empty($secret)) {
                $sql = "SELECT * FROM (SELECT roomid,session_type,id FROM ld_wechatsession WHERE IFNULL(roomid,'') <> '' AND IFNULL(roomname,'')='' GROUP BY roomid ORDER BY id ASC) AS tmp WHERE id>? limit 2000";
            }else{
                $sql = "SELECT * FROM (SELECT roomid,session_type,id FROM ld_wechatsession WHERE IFNULL(roomid,'') <> '' AND IFNULL(roomname,'')='' AND session_type = 'internal' GROUP BY roomid ORDER BY id ASC) AS tmp WHERE id>? limit 2000";
            }
            $result = $adb->pquery($sql, array($lastid));
            $num_rows = $adb->num_rows($result);
            if ($num_rows >= 1) {
                for ($i = 0; $i < $num_rows; $i++) {
                    $roomid_arr[]=array(
                        'id'=>$adb->query_result($result, $i, 'id'),
                        'roomid'=>$adb->query_result($result, $i, 'roomid'),
                        'session_type'=>$adb->query_result($result, $i, 'session_type')
                    );
                }
            }else{
                unset($_SESSION['WechatSession_syncName']);
                ConvertTojsonString(1, array(), 'success');
            }

            $_SESSION['WechatSession_syncName']['sync_group_name']['roomid_arr'] = $roomid_arr;
            $_SESSION['WechatSession_syncName']['sync_group_name']['total'] = $num_rows;
            $_SESSION['WechatSession_syncName']['sync_group_name']['intervalrow'] = ceil($num_rows/10);//向上取整
            $_SESSION['WechatSession_syncName']['sync_group_name']['start'] = 0;
            $_SESSION['WechatSession_syncName']['sync_group_name']['end'] = $_SESSION['WechatSession_syncName']['sync_group_name']['intervalrow']; //当前处理到第几个
        }else{
            $_SESSION['WechatSession_syncName']['sync_group_name']['start'] = $_SESSION['WechatSession_syncName']['sync_group_name']['end'];
            $_SESSION['WechatSession_syncName']['sync_group_name']['end'] = $_SESSION['WechatSession_syncName']['sync_group_name']['end'] + $_SESSION['WechatSession_syncName']['sync_group_name']['intervalrow'];
        }

        $start = $_SESSION['WechatSession_syncName']['sync_group_name']['start'];
        $intervalrow = $_SESSION['WechatSession_syncName']['sync_group_name']['intervalrow'];
        $roomid_arr = $_SESSION['WechatSession_syncName']['sync_group_name']['roomid_arr'];//待处理结果集

        $tmp_roomid_arr = array_slice($roomid_arr,$start,$intervalrow);
        foreach ($tmp_roomid_arr as $roomid_info) {
            $roomid = $roomid_info['roomid'];
            $session_type = $roomid_info['session_type'];
            if ($session_type == 'internal') {
                $focus->updateRoomName($roomid);
            } elseif ($session_type == 'external' && !empty($secret)) {
                $focus->updateExternalRoomName($roomid,$secret);
            }
            $_SESSION['WechatSession_syncName']['sync_group_name']['lastid'] = $roomid_info['id'];
        }

        if ($_SESSION['WechatSession_syncName']['sync_group_name']['end'] < $_SESSION['WechatSession_syncName']['sync_group_name']['total']){  //还未结束
            $arr['title'] = getFixedLabel('SyncGroupName');
            $arr['start'] = $start;
            $arr['end'] = $_SESSION['WechatSession_syncName']['sync_group_name']['end'];
            $arr['total'] = $_SESSION['WechatSession_syncName']['sync_group_name']['total'];
            $arr['percent'] = floor($arr['end']/($_SESSION['WechatSession_syncName']['sync_group_name']['total'])*100);
            $arr['SESSION'] = $_SESSION['WechatSession_syncName']['sync_group_name'];
            ConvertTojsonString(2, $arr, 'success');   //2 继续当前请求
        }else{
            require_once globalStatic::$root_directory.'appCommon/appCommon.php';
            include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
            $auto_info_json = doCorpInfo('get_auth_info','');
            $info_arr = json_decode($auto_info_json, true);
            $crm_auth = $info_arr[StaticConst::$suite_crm];
            $corpid = $crm_auth['auth_corp_info']['corpid'];
            file_put_contents(globalStatic::$root_directory."user_privileges/syncwechatgroupname.txt",$_SESSION['WechatSession_syncName']['sync_group_name']['lastid'].'##'.$corpid);//$lastid   记录当前最大值

            $end=$_SESSION['WechatSession_syncName']['sync_group_name']['end'];

            unset($_SESSION['WechatSession_syncName']);
            ConvertTojsonString(1, array(), 'success');   // 结束
        }

    }
    unset($_SESSION['WechatSession_syncName']);
    ConvertTojsonString(1, array(), 'success');
}
else{
     unset($_SESSION['WechatSession_syncName']);
}


$smarty = new lingdangCRM_Smarty;
 require_once globalStatic::$root_directory.'appCommon/appCommon.php';
 include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
$auto_info_json = doCorpInfo('get_auth_info','');
$info_arr = json_decode($auto_info_json, true);
$crm_auth = $info_arr[StaticConst::$suite_crm];
$corpid = $crm_auth['auth_corp_info']['corpid'];
$secret='';
if(file_exists(globalStatic::$root_directory.'user_privileges/syncwechatsecret.txt'))
{
    $tmp_secret= file_get_contents(globalStatic::$root_directory.'user_privileges/syncwechatsecret.txt');
    $secret_arr=explode("##",$tmp_secret);
    if($secret_arr[1]==$corpid)
    {
        $secret=$secret_arr[0];
    }
    
}
$smarty->assign("Secret",$secret);


// TODO  判断是否是“应用市场”     由于获取客户群详情需要用到secret，所以不需要判断了，必须显示和填写secret
$smarty->assign('isAppMarket', $isAppMarket);// 如果是“应用市场”授权，不需要显示 Secret

$arr['isAppMarket'] = $isAppMarket;
$arr['title'] = "同步联系人姓名/群名";
$arr['oktext'] = getFixedLabel("CONFIRMED");
$arr['canceltext'] = getFixedLabel("CANCEL");
$arr['content'] = $smarty->fetch('modules/WechatSession/SyncName.tpl');
ConvertTojsonString(1, $arr, 'success');
?>
