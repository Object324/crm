<?php
//XUQIU1001905 liushuai 20230920 企微会话存档组织架构显示第二版
global $adb;
$_REQUEST['diony'] = 'yes';

$operationtype = trim($_REQUEST['operationtype']);
switch ($operationtype) {
    case 'checksyncnstatus':
        //接口获取组织架构信息比较慢，防止多人同时进入模块调用接口
        require_once(globalStatic::$root_directory.'/modules/WechatSession/WechatSession.php');
        $focus = new WechatSession();
        if (isset($focus->wxconfig['version']) && $focus->wxconfig['version'] == 'v2') {
            $result = $adb->pquery("select syncstatus from ld_wechat_config where id=1",array());
            $syncstatus = $adb->query_result($result, 0, 0);
            if ($syncstatus == 'start') {
                ConvertTojsonString(-1, [], '正在准备数据，请稍后刷新!');
            }
        }
        break;
    case 'clearapicache':
        //invalid_userid_list  无效的成员列表字段不要清空，当接口返回值invalid_userid_list为空时再清空
        $adb->pquery("update ld_wechat_config set syncstatus=null,permit_user_list=null,departmentlist=null,userlist=null,userinfo=null where id=1",array());
        break;
    case 'editmemberpop':
        //XUQIU1002135 ls 20231103 会话存档离职成员信息显示
        //显示编辑姓名的弹窗
        $lastname = '';
        $convertuserid = trim($_REQUEST['convertuserid']);
        $query = "select lastname from ld_wechatuserid where convertuserid=? limit 1";
        $result = $adb->pquery($query, array($convertuserid));
        if ($adb->num_rows($result)> 0) {
            $lastname = $adb->query_result($result,0,0);
        }

        $arr['lastname'] = $lastname;
        $arr['title'] = getFixedLabel("EDIT").getFixedLabel("Name");
        $arr['oktext'] = getFixedLabel("CONFIRMED");
        $arr['canceltext'] = getFixedLabel("CANCEL");
        $arr['content'] = "<div style='padding: 10px 10px;'><font color='red'>* </font>".getFixedLabel("Name")."<input name='memberlastname' type='text' value='".$lastname."' tag='".getFixedLabel("Name")."' style='border:1px solid #dbdbdb;border-radius: 4px;line-height: 25px;margin-left: 15px;'></div>";

        break;
    case 'savememberlastname':
        //保存备注的离职员工姓名
        $convertuserid = trim($_REQUEST['convertuserid']);
        $lastname = trim($_REQUEST['lastname']);
        if(!empty($convertuserid) && !empty($lastname)){
            $adb->pquery("update ld_wechatuserid set lastname=? where convertuserid=?",array($lastname,$convertuserid));
        }

        break;
    default:
        break;
}

ConvertTojsonString(1, $arr, 'success');
?>
