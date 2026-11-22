<?php
include('./miniprogram/wxBizDataCrypt.php');
class CloudUsers
{
    public static $api_url = 'https://xiaoshouzhushou.com/webapi/cloudpro/index.php';
    //自用    小程序、自助平台
    public static $demo_appid = 'wx67393d56c3ac9170';
    public static $demo_secret = 'd7645a364af32b0039e8c45f4867b985';
    //发版    小程序
    public static $default_appid = 'wx6a8939ad8cc3946e';
    public static $default_secret = 'f947f6f768caaf9e3bdb370f80dd69d6';

    /**
     * @param null $type_id
     * @return string|string[]
     * 获取报备类型名称
     */
    public static function getReportTypeName($type_id=null)
    {
        $arr = [
            1=>'关注客户',
            2=>'直接报备',
        ];
        if($type_id == -1){
            return $arr;
        }
        if(empty($type_id) || !isset($arr[$type_id])){
            return '其他方式';
        }
        return $arr[$type_id];

    }
    /***
     * 名片小程序页面 crm用户的个人信息返回
     * @return array
     * @throws Exception
     */
    public function ListView()
    {
        SqlSearchFilter($_REQUEST);
        global $adb;
        $res = ['title'=>'灵当电子名片'];
        //名片信息
        if(isset($_REQUEST['usid'])&&!empty($_REQUEST['usid'])){
            $admin_info = $this->getCrmUserInfo($_REQUEST['usid']);
        }
        //介绍信息 ld_organizationdetails_brief
        $company_sql = "select * from ld_organizationdetails";
        $company_res = $adb->pquery($company_sql);
        $title = $adb->query_result($company_res,0,"brief_title");
        $product_title = $adb->query_result($company_res,0,"product_title");
        $brief_sql = "select * from ld_organizationdetails_brief where type='text'";
        $brief_res = $adb->query($brief_sql);
        $brief_rows = $adb->num_rows($brief_res);
        if($brief_rows >0 ) {
            $list = [];
            foreach ($brief_res as $v) {
                $list[] = $v['brief'];
            }
            $introduce = [
                'title' => $title,
                'list' => $list
            ];
            $res['introduce'] = $introduce;
        }
        // 'video_url'=>'http://wxsnsdy.tc.qq.com/105/20210/snsdyvideodownload?filekey=30280201010421301f0201690402534804102ca905ce620b1241b726bc41dcff44e00204012882540400&bizid=1023&hy=SH&fileparam=302c020101042530230204136ffd93020457e3c4ff02024ef202031e8d7f02030f42400204045a320a0201000400',
        //     'videohome_url'=>'http://www.71mis.cn/wx_images/cloud/card_bg.jpg'
        //产品ld_organizationdetails_product
        $product_sql = "select * from ld_organizationdetails_product order by `order` asc";
        $product_res = $adb->query($product_sql);
        $product_rows = $adb->num_rows($product_res);
        if($product_rows >0 ) {
            $product = [];
            foreach ($product_res as $k => $val) {
                $product[$k]['name'] = $val['title'];
                $product[$k]['image'] = $val['image_link'];
                $product[$k]['content'] = explode('|', $val['brief']);
            }
            $product = [
                'title' => $product_title,
                'list' => $product
            ];
            $res['product'] = $product;
        }
        //根据openid判断是否授权过
        $auth_status = 'no';
        $user_exits = "select id,cloud_id,avatar,nickname from ld_cloud_users where open_id=?";
        $users = $adb->pquery($user_exits,array($_REQUEST['userid']));
        $rows = $adb->num_rows($users);
        if(!empty($_REQUEST['userid'])&&($rows>=1)){
            $auth_status = 'yes';
            $admin_info['my_cloudid'] = $adb->query_result($users,0,'id');
            $user_info['avatarUrl'] = $adb->query_result($users,0,'avatar');
            $user_info['nickName'] = $adb->query_result($users,0,'nickname');
            $res['userInfo'] = $user_info;
        }
        //根据LOGO、联系title
        $admin_info['logo'] = 'http://71mis.com/images/whitelogo.png';
        $admin_info['lianxi_title'] = '联系我们';
        $res['info'] = $admin_info;
        $res['auth_status'] = $auth_status;
        return $res;
    }

    /***
     * 检查小程序用户是否授权
     * @return array
     * @throws Exception
     */
    public function checkCloudUser()
    {
        global $adb;
        // 通过openid去数据库匹配之前是否授权过 没有则新增一条数据 有则更新基本信息
        // 点别人链接 带参授权的 crm_company_id（必有） crm_user_id（必有） cloud_id（可有）
        //参数 nickname avatar sex
        //openid
        $user_exits = "select id,cloud_id from ld_cloud_users where open_id=?";
        $users = $adb->pquery($user_exits,array($_REQUEST['userid']));
        $rows = $adb->num_rows($users);
        $my_cloudid = 0;
        if($rows < 1) {
            //新建数据
            $field_insert = " crm_company_id,crm_user_id,cloud_id,nickname,avatar,open_id,sex,create_time";
            $value_insert = [
                //有推荐人id 无推荐人id
                $_REQUEST['coid'] ? $_REQUEST['coid'] : 0,
                $_REQUEST['usid'] ? $_REQUEST['usid'] : 0,
                $_REQUEST['cloudid'] ? $_REQUEST['cloudid'] : 0,
                $_REQUEST['nickName'],
                $_REQUEST['avatarUrl'],
                $_REQUEST['userid'],
                $_REQUEST['gender'],
                date('Y-m-d H:i:s', time())
            ];
            $res_sql = "insert into ld_cloud_users ($field_insert) values (?,?,?,?,?,?,?,?)";
            $result = $adb->pquery($res_sql, $value_insert);
            $my_cloudid = $adb->getLastInsertID();
        }else{
            $user_id = $adb->query_result($users,0,'id');
            $my_cloudid = $user_id;

            //更新数据 更新crm_company_id crm_user_id cloud_id avatar nickname sex update_time
            $update_value = [
                "crm_company_id=?",
                "crm_user_id=?",
                "cloud_id=?",
                "nickname=?",
                "avatar=?",
                "sex=?",
                "update_time=?"
            ];
            $query_paramarr = [
                $_REQUEST['coid']?"".$_REQUEST['coid']."'":'',
                $_REQUEST['usid']?"".$_REQUEST['usid']."'":'',
                $_REQUEST['cloudid']?"".$_REQUEST['cloudid']."'":'',
                $_REQUEST['nickName']."'",
                $_REQUEST['avatarUrl']."'",
                $_REQUEST['gender']."'",
                date('Y-m-d H:i:s', time())."'",
                $user_id
            ];
            $update_value = implode(',',array_filter($update_value));
            $res_sql = "update ld_cloud_users set ".$update_value.' where id=?';
            $result = $adb->pquery($res_sql,$query_paramarr);
        }
        return ['auth'=>$_REQUEST['userid'],'my_cloudid'=>$my_cloudid,'info'=>$result];
    }

    /***
     * 点击预约按钮
     * @param encryptedData
     * @param iv
     * @return array
     */
    public function checkPhone()
    {
        global $adb;
        if($_REQUEST['minipro_const_type'] == 'demo'){
            $pc = new WXBizDataCrypt(self::$demo_appid, $_REQUEST['sessionKey']);    
        }
        else{
            $pc = new WXBizDataCrypt(self::$default_appid, $_REQUEST['sessionKey']);
        }
        $errCode = $pc->decryptData($_REQUEST['encryptedData'], $_REQUEST['iv'], $data );
        if ($errCode == 0) {
            //更新open_id用户数据的手机号 并且返回数据
            /*{
                "phoneNumber": "13580006666",
                "purePhoneNumber": "13580006666",
                "countryCode": "86",
                "watermark":
                    {
                        "appid":"APPID",
                        "timestamp": TIMESTAMP
                    }
            }*/ 

            $data = json_decode($data,true);
            // 咨询信息发邮件
//            $cloud_sql = "select u.email1 from ld_cloud_users as c left join ld_users as u on u.id=c.crm_user_id where id=".$_REQUEST['my_cloudid'];
//            $cloud_user = $adb->pquery($cloud_sql);
//            $email1 = $adb->query_result($cloud_user,0,"email1");
//            $subject = "预约中心邮件";
//            $content = "微信用户".$data['purePhoneNumber']."点击咨询了，请安排联系";
//            require_once(globalStatic::$root_directory."modules/Emails/mail.php");
//            send_mail("CloudUsers",$email1,"admin","",$subject,$content);
            // 咨询信息写表
            $sql = 'insert into ld_cloud_book (tel, cloud_id) values (?,?);';
            $result = $adb->pquery($sql,array($data['purePhoneNumber'],$_REQUEST['my_cloudid']));

            $sql2 = "update ld_cloud_users set tel='".$data['purePhoneNumber']."' where id=?";
            $result2 = $adb->pquery($sql2,array($_REQUEST['my_cloudid']));
            return ['auth'=>$errCode,'info'=>$data];
        } else {
            return ['auth'=>$errCode];
        }
    }
    /***
     * 个人名片上的信息
     * @param $usid
     * @return array
     * @throws Exception
     */
    public function getCrmUserInfo($usid)
    {
        global $adb;
        $admin_sql = "SELECT
             u.last_name,
             u.real_name,
             g.groupname,
             u.userlevel,
             u.phone_home,
             u.phone_mobile,
             u.email1,
             a.newfile_name as name,
             a.path,
             a.storage_location,
             a.cloud_path
            FROM
             ld_users AS u
            left join ld_groups as g on g.groupid=u.groupid
            left join ld_salesmanattachmentsrel as s on u.id = s.smid
            left join ld_attachments as a on a.attachmentsid = s.attachmentsid 
            WHERE u.id =? ";
        $admin = $adb->pquery($admin_sql,array($usid));
        $company_sql = "select * from ld_organizationdetails";
        $company = $adb->pquery($company_sql);
        $rows = $adb->num_rows($admin);
        $admin_info = [];
        $iskehu001 = isKehu001ServerPc();
        if($rows>=1){
            $admin_info['username'] = $adb->query_result($admin,0,'last_name');
            if($iskehu001 == "yes"){
                $admin_info['username'] = $adb->query_result($admin,0,'real_name');
            }
            $admin_info['groupname'] = $adb->query_result($admin,0,'groupname');
            $admin_info['userlevel'] = $adb->query_result($admin,0,'userlevel');
            $admin_info['phone_mobile'] = $adb->query_result($admin,0,'phone_mobile');
            $admin_info['phone_home'] = $adb->query_result($admin,0,'phone_home');
            $admin_info['email'] = $adb->query_result($admin,0,'email1');
            $storage_location = $adb->query_result($admin,0,'storage_location');
            $admin_info['storage_location'] = $storage_location;
            if($storage_location == 'cos'){
                $admin_info['image_str'] = $adb->query_result($admin,0,'cloud_path');
            }else{
                $admin_info['image_str'] = $adb->query_result($admin,0,'path').$adb->query_result($admin,0,'name');
            }
            // ljj 20231201 XUQIU1000927 更换默认头像
            $userfilepath=getDefaultAvatar($usid);
            $admin_info['image_str'] = ($admin_info['image_str']=='')?$userfilepath:$admin_info['image_str'];
            $admin_info['company'] = $adb->query_result($company,0,'organizationname');
            $admin_info['address'] = $adb->query_result($company,0,'state') . $adb->query_result($company,0,'city').$adb->query_result($company,0,'address');
        }
        return $admin_info;
    }

    /**
     * 获取某个用户的所推荐的打开过名片授权的人
     * @param $usid
     * @return array
     * @throws Exception 昵称 咨询次数 来源
     */
    public function getMyCloudUsers()
    {
        global $adb;
        $usid = $_REQUEST['usid'];
        SqlSearchFilter($_REQUEST);
        
        if(!isset($_REQUEST['my_cloudid']) || empty($_REQUEST['my_cloudid'])){
            $arr['list'] = [];
            $arr['search_reminds'] = '搜索姓名、手机号码';
            $arr['havenextpage'] = 'no';
            $arr['pagecount'] = '0';
            $arr['totalrows'] = '0';
            return $arr;
        }
        $cloud_id = $_REQUEST['my_cloudid'];

        $page = $_REQUEST['page'];
        $num = 10;
        $start = $page*$num;
        $param_arr=[];
        $param_arr[]=$usid;
        // 组合条件
        $where = " where u.crm_user_id=?";
        if($cloud_id > 0){
            //$where .= " and u.cloud_id=".$cloud_id;
            $where .= " and u.cloud_id=?";
            $param_arr[]=$cloud_id;
            
           
        }
        if(isset($_REQUEST['keywords'])&&!empty($_REQUEST['keywords'])){
            $keywords = $_REQUEST['keywords'];
            $where .= " and (locate(trim('$keywords'),u.nickname)>0 or locate(trim('$keywords'),u.tel)>0)";
        }

        $sql = "SELECT u.status,u.id,u.nickname,u.`share`,b.tel,count(b.id) as book_time from ld_cloud_users as u left join ld_cloud_book as b on u.id=b.cloud_id  $where group by u.id order by u.id desc limit $start,$num";
        $users = $adb->pquery($sql,$param_arr);
        $rows = $adb->num_rows($users);
        //查询总条数
        $all_rows_sql = "SELECT count(1) as rows from ld_cloud_users as u $where";
       
        $all_rows_result = $adb->pquery($all_rows_sql,$param_arr);
        $all_rows = $adb->query_result($all_rows_result,0,'rows');
        $all_pages = ceil($all_rows/$num);
        $havenextpage = ($page+1)<$all_pages?"yes":"no";
        $result = [];
        for($i=0;$i<$rows;$i++){
            $temp = $adb->query_result_rowdata($users,$i);
            $result[$i]['title'] = "姓名：".$temp['nickname'];
            $field = [];
            $tel = $temp['tel']?$temp['tel']:"空";
            array_push($field,"转发次数：".$temp['share']);
            array_push($field,"咨询次数：".$temp['book_time']);
            array_push($field,"手机号码：".$tel);
            $result[$i]['field'] = $field;
            $result[$i]['cloud_id'] = $temp['id'];
            $result[$i]['hiddentitle'] = $temp['nickname'];
            $result[$i]['hiddentel'] = $tel;
            $result[$i]['is_report'] = $temp['status']==1?"已报备":"报备";
        }
        $arr['list'] = $result;
        $arr['search_reminds'] = '搜索姓名、手机号码';
        $arr['havenextpage'] = $havenextpage;
        $arr['pagecount'] = $all_pages;
        $arr['totalrows'] = $all_rows;
        return $arr;
    }


    /**
     * 用户转发调用方法 在ld_cloud_users表记录转发次数+1
     * param $cloud_id ld_cloud_user的id
     * @return string
     */
    public function share()
    {
        global $adb;
        $cloud_id = $_REQUEST['my_cloudid'];
        $sql = "update ld_cloud_users set share=share+1 where id=?";
        $result = $adb->pquery($sql,[$cloud_id]);
        // 返回受影响行数
        return $adb->getAffectedRowCount($result);
    }

    /**
     * 客户报备
     */
    public function report()
    {
        global $adb;
        //客户来源 电子名片下拉框值 如果不存在则新建一个下拉框值
        //BUG0052725  81miskfbcrm通用问题：电子名片中报备客户到CRM识别的客户来源是电话来访,应该是电子名片 zxm20220614
        $leadsource_sql = "insert into ld_picklist_values (listid,listvalue,sequence) 
select 
	(select listid from ld_picklist_set where listname='leadsource' limit 1),
	'电子名片',
	(select max(sequence)+1 
	from ld_picklist_set
	left join ld_picklist_values on ld_picklist_set.listid=ld_picklist_values.listid where listname='leadsource' )
from dual where not EXISTS( 
	select ld_picklist_values.* from ld_picklist_set
	left join ld_picklist_values on ld_picklist_set.listid=ld_picklist_values.listid
	where listname='leadsource' and listvalue='电子名片'
);";
        $adb->pquery($leadsource_sql);
        //ld_account公司名称accountname 所属行业industry  report_type:报备类型（直接报备，关注客户）客户编号account_no   云用户id my_cloudid
        //ld_contactdetails联系人名称 lastname  手机号phone 邮箱email 推广类型关注客户or直接报备 来源：推广人的cloud_users昵称
        //ld_contactscf 微信号wx
        // 生成订单编号
        require_once (globalStatic::$root_directory."Register/RegOp.php");
        $focus_accounts = CRMEntity::getInstance("Accounts");
        $_REQUEST['leadsource'] = '电子名片';
        $_REQUEST['account_no'] = $focus_accounts->Library("SystemCode")->setModuleSeqNumber("increment","Accounts");
        // 生成客户信息数据 accountname industry account_no
        setObjectValuesFromRequest($focus_accounts);
        $focus_accounts->mode='create';
        $focus_accounts->save("Accounts");
        // 生成联系人数据
        $focus_contact = CRMEntity::getInstance("Contacts");
        setObjectValuesFromRequest($focus_contact);
        $focus_contact->mode='create';
        $focus_contact->save("Contacts");

        $accountid = $focus_accounts->id;
        $contactid = $focus_contact->id;
        // 更新表account的report_type与cloud_users_id smownerid(取值crm_user_id)
        // 查询crm_user_id--作为负责人
        $crm_user_sql = "select crm_user_id from ld_cloud_users where id=?";
        $crm_user_res = $adb->pquery($crm_user_sql,array($_REQUEST['my_cloudid']));
        $crm_user_id = $adb->query_result($crm_user_res,0,"crm_user_id");
        $account_sql = "update ld_account set report_type=?,cloud_users_id=? where accountid=?";
        $report_type = $_REQUEST['report_type'];
        $cloud_users_id = $report_type==1?$_REQUEST['cloud_users_id']:$_REQUEST['my_cloudid'];
        $account_res = $adb->pquery($account_sql,[$report_type,$cloud_users_id,$accountid]);

        // 更新表contactdetails的accountid,设置成为首要联系人
        $contact_sql = "update ld_contactdetails set accountid=?,reference=1 where contactid=?";
        $contact_res = $adb->pquery($contact_sql,[$accountid,$contactid]);
        // 更新表ld_cloud_users的报备状态status
        $cloud_sql = "update ld_cloud_users set status=1 where id=?";
        $cloud_res = $adb->pquery($cloud_sql,[$_REQUEST['cloud_users_id']]);
        return ['res'=>[$adb->getAffectedRowCount($account_res),$adb->getAffectedRowCount($contact_res)]];
    }

    /**
     * 获取我的报备客户信息列表
     */
    public function getMyAccount()
    {
        global $adb;
        $usid = $_REQUEST['usid'];
        $cloud_id = $_REQUEST['my_cloudid'];
        $page = $_REQUEST['page'];
        $num = 10;
        $start = $page*$num;
        // 组合条件
        $where = " where a.smownerid=?";
        $param_arr[]=$usid;
        if($cloud_id > 0){
            $where .= " and (CASE
               WHEN a.report_type = 2
                    THEN a.cloud_users_id=?
               ELSE cloud.cloud_id=?
             END)";
            $param_arr[]=$cloud_id;
            $param_arr[]=$cloud_id;
        }
        if(isset($_REQUEST['keywords'])&&!empty($_REQUEST['keywords'])){
            $keywords = $_REQUEST['keywords'];
            $where .= " and (locate(trim(?),a.accountname)>0 or locate(trim(?),a.industry)>0 or locate(trim(?),s.wx)>0 or locate(trim(?),c.mobile)>0 or locate(trim(?),c.email)>0)";
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
        }

        $sql = " select a.accountname,a.industry,c.lastname,c.mobile,c.email,s.wx,a.report_type,a.cloud_users_id from ld_cloud_users as cloud left join ld_account as a on cloud.id=a.cloud_users_id left join ld_contactdetails as c on a.accountid=c.accountid left join ld_contactscf as s on s.contactid=c.contactid $where order by a.accountid desc limit $start,$num ";
        $report_res = $adb->pquery($sql,$param_arr);
        $rows = $adb->num_rows($report_res);
        if($rows > 0) {
            $list = [];
            for ($i = 0; $i < $rows; $i++) {

                $list[$i]['title'] = "客户名称：".$adb->query_result($report_res, $i, "accountname");
                $list[$i]['field'] = [];
                array_push($list[$i]['field'],"所属行业：".$adb->query_result($report_res, $i, "industry"));
                array_push($list[$i]['field'],"联系人姓名：".$adb->query_result($report_res, $i, "lastname"));
                array_push($list[$i]['field'],"联系人微信：".$adb->query_result($report_res, $i, "wx"));
                array_push($list[$i]['field'],"联系人手机：".$adb->query_result($report_res, $i, "mobile"));
                array_push($list[$i]['field'],"邮箱：".$adb->query_result($report_res, $i, "email"));
                $report_type = $adb->query_result($report_res, $i, "report_type");
                $report_type = self::getReportTypeName($report_type);
                array_push($list[$i]['field'],"状态：".$report_type);


            }
            $arr['list'] = $list;
        }else{
            $arr['list'] = [];
        }
        // 计算总条数
        $count_sql = "select count(1) as `rows` from ld_cloud_users as cloud left join ld_account as a on cloud.id=a.cloud_users_id left join ld_contactdetails as c on a.accountid=c.accountid left join ld_contactscf as s on s.contactid=c.contactid $where";
        $count_res = $adb->pquery($count_sql,$param_arr);
        $total_rows = $adb->query_result($count_res,0,"rows");
        $all_pages = ceil($total_rows/$num);
        $havenextpage = ($page+1)<$all_pages?"yes":"no";
        $arr['search_reminds'] = '搜索客户名称、行业、姓名、联系方式等';
        $arr['havenextpage'] = $havenextpage;
        $arr['pagecount'] = $all_pages;
        $arr['totalrows'] = $total_rows;
        return $arr;
    }

    /**
     * 我的客户的订单
     */
    public function getMyCloudOrder()
    {
        global $adb;
        $usid = $_REQUEST['usid'];
        $cloud_id = $_REQUEST['my_cloudid'];
        $page = $_REQUEST['page'];
        $num = 10;
        $start = $page*$num;
        // 组合条件
        $where = " where b.smownerid=?";
        $param_arr[]=$usid;

        if($cloud_id > 0){
            $where .= " and (CASE
               WHEN b.report_type = 2
                    THEN b.cloud_users_id=?
               ELSE a.cloud_id=?
             END)";
            $param_arr[]=$cloud_id;
            $param_arr[]=$cloud_id;
        }

        if(isset($_REQUEST['keywords'])&&!empty($_REQUEST['keywords'])){
            $keywords = $_REQUEST['keywords'];
            $where .= " and (locate(trim(?),b.accountname)>0 or locate(trim(?),d.salesorder_no)>0 or locate(trim(?),f.lastname)>0 or locate(trim(?),p.productname)>0)";
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
            $param_arr[]=$keywords;
        }
        $count_field = " count(1) as counts,sum(g.tax_amount) as total ";
        $detail_field = " d.salesorderid,
                        d.signed_data,
                        admin.last_name AS admin_name,
                        b.account_no,
                        b.accountname,
                        b.cloud_users_id,
                        f.lastname AS contact_name,
                        d.salesorder_no,
                        d.total,
                        p.productname,
                        g.quantity,
                        g.taxprice,
                        g.tax_amount ";
        $tables = " FROM ld_cloud_users a
                LEFT JOIN ld_account b ON b.cloud_users_id=a.id
                INNER JOIN ld_salesorder d ON d.accountid=b.accountid
                LEFT JOIN ld_salesordercf e ON e.salesorderid=d.salesorderid
                LEFT JOIN ld_users admin ON admin.id=b.smownerid
                LEFT JOIN ld_contactdetails f ON f.contactid=d.contactid
                LEFT JOIN ld_salesorderdetail g ON g.id=d.salesorderid
                LEFT JOIN ld_products p ON p.productid=g.productid ";
        $detail_sql = "SELECT $detail_field $tables $where order by d.salesorderid desc limit $start,$num";
        $count_sql = "SELECT $count_field $tables $where";
        $detail_res = $adb->pquery($detail_sql,$param_arr);
        $detail_rows = $adb->num_rows($detail_res);
        $count_res = $adb->pquery($count_sql,$param_arr);
        if($detail_rows > 0) {
            $list = [];
            for ($i = 0; $i < $detail_rows; $i++) {
                $list[$i]['title'] = "订单编号：".$adb->query_result($detail_res, $i, "salesorder_no");
                $list[$i]['field'] = [];

                array_push($list[$i]['field'],"客户名称：".$adb->query_result($detail_res, $i, "accountname"));
                array_push($list[$i]['field'],"签约日期：".$adb->query_result($detail_res, $i, "signed_data"));
                array_push($list[$i]['field'],"销售负责人：".$adb->query_result($detail_res, $i, "admin_name"));
                array_push($list[$i]['field'],"联系人姓名：".$adb->query_result($detail_res, $i, "contact_name"));
                array_push($list[$i]['field'],"产品名称：".$adb->query_result($detail_res, $i, "productname"));
                array_push($list[$i]['field'],"产品数量：".$adb->query_result($detail_res, $i, "quantity"));
                array_push($list[$i]['field'],"含税单价：".$adb->query_result($detail_res, $i, "taxprice"));
                array_push($list[$i]['field'],"合计：".$adb->query_result($detail_res, $i, "tax_amount"));
                $list[$i]['hidden_salesorderid'] = $adb->query_result($detail_res, $i, "salesorderid");
            }
            $arr['list'] = $list;
        }
        else{
            $arr['list'] = [];
        }
        // 计算总条数
        $total_rows = $adb->query_result($count_res,0,"counts");
        $all_pages = ceil($total_rows/$num);
        $havenextpage = ($page+1)<$all_pages?"yes":"no";
        $arr['search_reminds'] = '搜索订单编号、客户名称、联系人姓名、产品名称等';
        $arr['havenextpage'] = $havenextpage;
        $arr['pagecount'] = $all_pages;
        $total['count'] = $total_rows;
        $total['amount'] = $adb->query_result($count_res,0,"total");
        $arr['total'] = $total;
        $arr['totalrows'] = $total_rows;
        $arr['totalamounts'] = empty($arr['totalamounts'] )?0:$arr['totalamounts'];
        return $arr;
    }
    public function aboutLingdang()
    {
        $res = [
            "title"=>"关于灵当CRM",
            "list"=>[
                "灵当的含义是“灵活配置、口碑响当当”，作为企业微信推荐服务商，灵当CRM支持微信消息驱动，全面对接个人微信、企业微信、钉钉和云之家移动端，可随时随地移动办公。",
                "上海灵当成立于2008年，专注于CRM软件 12 年。灵当CRM是个性化CRM领导者，为客户提供私有部署最佳方案，致力于为各行业的企业提供专业、可配置的一体化行业解决方案。",
                "联系电话：400-888-5110",
                "网址：http://www.51mis.com"
            ],
            "url"=>"https://wework.qpic.cn/wwpic/276290_E7o8zoYrT36IpiY_1604909840/0",
            "url_title"=>"扫码加我企业微信"
        ];
        return $res;
    }
    /**
     * crm人员登录
     */
    public function crmLogin()
    {
        global $adb;
        if(!empty($_REQUEST['username'])) {
            $user_name = $_REQUEST['username'];
            $pwd = $_REQUEST['pwd'];
            $user_obj = new Users();
            $user_obj->column_fields['user_name'] = $user_name;
            $crypt_type = 'MD5';
            $encrypted_password = $user_obj->encrypt_password($pwd, $crypt_type);
            $sql = "SELECT id,last_name,user_name from $user_obj->table_name where deleted = 0  and status = 'Active' and user_name=? and user_password=?";
            $result = $adb->pquery($sql,[$user_name, $encrypted_password]);
            $nums = $adb->num_rows($result);
            if ($nums == 1) {

            }else{
                return ["msg"=>"账号或者密码错误"];
            }
        }
    }
}