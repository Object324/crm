<?php
require_once(globalStatic::$root_directory . '/appCommon/appCommon.php');
class AddressbookSync
{
    public $corpid = null;
    public $secret = null;
    public function __construct()
    {
        global $adb;
//        $result = $adb->pquery("select * from ld_wx_config where `name` = 'wxselfbuiltapp_setting' and para_content <> ''",array());
//        if($adb->num_rows($result) >= 1){
            //自建应用
            $corpid_result = $adb->pquery("select para_content from ld_wx_config where name = 'addressbook_setting_corpid'",array());
            $this->corpid = trim($adb->query_result($corpid_result,0,'para_content'));
//        }else{
            /*//第三方安装
            include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
            $wx_authinfo = doCorpInfo("get_auth_info",array());
            $wx_authinfo = ldcrm_json_decode($wx_authinfo);

            //$corpid = "wwa6d3e38251b2d832";
            //$secret = "ZBZ58qezHthcvNMVmcGmttaq8B2oGS7_eec9BmDcU8A";
            $this->corpid = $wx_authinfo['crm']['auth_corp_info']['corpid'];*/
//        }

        $secret_result = $adb->pquery("select para_content from ld_wx_config where switch = 'open' and  IFNULL(para_content,'') <> '' and name = 'addressbook_setting'",array());
        if($adb->num_rows($secret_result) > 0){
            $this->secret = $adb->query_result($secret_result,0,'para_content');
        }
    }

    public function get_addressbookinfo()
    {
        if (empty($_SESSION['AddressbookSync'])) {
            global $adb;

            $_SESSION['AddressbookSync']['DepartmentList']['status'] = false;
//            $_SESSION['AddressbookSync']['UserList']['status'] = false;

            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            //include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/ServiceCorpAPI.class.php");
            //include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/ServiceProviderAPI.class.php");
            // 实例化 API 类   之后直接调用相关方法，不必先获取access_token,接口会自动处理
            $api = new CorpAPI($this->corpid, $this->secret);
            $departmentList = $api->DepartmentList();//获取全量组织架构    //按照创建顺序返回，即循环插入(更新)的时候肯定是先插入(更新)父部门，再子部门，故更新depth、parentgroup的时候不用考虑异常情况
            $departmentList = json_decode(json_encode($departmentList),true);
            $_SESSION['AddressbookSync']['DepartmentList']['list'] = $departmentList;
//            file_put_contents(globalStatic::$root_directory."wxaddressbook/liushuai.txt",date('Y-m-d H:i:s')."departmentList:\r\n".json_encode($departmentList,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
            //1、查看当前已使用用户数
            require_once (globalStatic::$root_directory."Register/RegOp.php");
            $reg=RegOp::getInstance();
            $testFile=$reg->isExistFile();//判断注册文件是否存在
            if($testFile==1)
            {
                $regCount=$reg->GetUserCount();//许可总数，超过的员工默认为离职状态
                $_SESSION['AddressbookSync']['UserList']['regCount'] = $regCount;

                $result=$adb->pquery("select 1 from ld_users where status='Active'");
                $usedCount = $adb->num_rows($result);
                $_SESSION['AddressbookSync']['UserList']['usedCount'] = $usedCount;
            }
            else{
                unset($_SESSION['AddressbookSync']);
                ConvertTojsonString(-1, array(), 'success');//可以忽略
            }

            //1、获取部门成员详情（递归获取） ,departmentId为1,即为全量获取
            $userList = $api->UserList(1, 1);
            $userList = json_decode(json_encode($userList),true);
            $userid_name_list = array();//企业微信通讯录中所有的成员名称集合
            if (!empty($userList)) {
                foreach ($userList as $key=>$user) {
                    if ($user['status'] != 1) {//未邀请成功的、已禁用的、退出企业的成员不同步
                        unset($userList[$key]);
                        continue;
                    }
                }

                foreach ($userList as $user) {
                    $wx_userid = $user['userid'];
                    $last_name = $user['name'];
                    $userid_name_list[$wx_userid] = $last_name;
                }
            }
//            file_put_contents(globalStatic::$root_directory."wxaddressbook/liushuai.txt",date('Y-m-d H:i:s')."userList:\r\n".json_encode($userList,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
            $_SESSION['AddressbookSync']['UserList']['list'] = $userList;
            $_SESSION['AddressbookSync']['UserList']['userid_name_list'] = $userid_name_list;//array(wx_userid=>last_name)


            /*//2、查询部门信息
            $groupInfo = [];
            $result = $adb->pquery("select groupid,parentgroup,depth from ld_groups",array());//父部门depth、parentgroup
            for($i = 0; $i<$adb->num_rows($result); $i++){
                $groupid = $adb->query_result($result,$i,'groupid');
                $parentgroup = $adb->query_result($result,$i,'parentgroup');
                $depth = $adb->query_result($result,$i,'depth');
                $parentgroup = explode('::',$parentgroup);
                if ($depth > 0) {
                    unset($parentgroup[0]);
                }
                $parentgroup = implode(',',$parentgroup);
                $groupInfo[$groupid] = $parentgroup;
            }
            $_SESSION['AddressbookSync']['UserList']['groupInfo'] = $groupInfo;//array(groupid=>parentgroup)*/

        }

    }
}
?>