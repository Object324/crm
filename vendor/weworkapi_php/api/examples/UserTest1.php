<?php /*
 * Copyright (C) 2017 All rights reserved.
 *   
 * @File UserTest.php
 * @Brief 
 * @Author abelzhu, abelzhu@tencent.com
 * @Version 1.0
 * @Date 2017-12-26
 *
 */
 
include_once("../src/CorpAPI.class.php");
include_once("../src/ServiceCorpAPI.class.php");
include_once("../src/ServiceProviderAPI.class.php");


$config = require('./config.php');
// 需启用 "管理工具" -> "通讯录同步", 并使用该处的secret, 才能通过API管理通讯录
//
//$api = new CorpAPI($config['CORP_ID'], $config['CONTACT_SYNC_SECRET']);
$api = new CorpAPI('wwa6d3e38251b2d832', 'ZBZ58qezHthcvNMVmcGmttaq8B2oGS7_eec9BmDcU8A');


try { 
    //
    /*$user = new User();
    {
        $user->userid = "userid";
        $user->name = "name";
        $user->mobile = "131488888888";
        $user->email = "sbzhu@ipp.cas.cn";
        $user->department = array(1); 

        $ExtattrList = new ExtattrList();
        $ExtattrList->attrs = array(new ExtattrItem("s_a_2", "aaa"), new ExtattrItem("s_a_3", "bbb"));
        $user->extattr = $ExtattrList;
    } 
    $api->UserCreate($user);*/

    //
    /*$user = $api->UserGet("userid");
    var_dump($user);*/

    //
    /*$user->mobile = "1219887219873";
    $api->UserUpdate($user); */

    //获取部门成员 只获取本部门
    echo "获取部门成员（只获取本部门）\r\n";
    $userList = $api->userSimpleList(1, 0);
    var_dump($userList);
    echo "\r\n";
    echo "获取部门成员（递归获取）\r\n";
    $userList = $api->userSimpleList(1, 1);
    var_dump($userList);
    echo "\r\n";

    //获取部门成员详情
    $userList = $api->UserList(1, 0);
    echo "获取部门成员详情（只获取本部门）\r\n";
    var_dump($userList);
    echo "\r\n";
    $userList = $api->UserList(1, 1);
    echo "获取部门成员详情（递归获取）\r\n";
    var_dump($userList);
    echo "\r\n";

    //获取全量组织架构
    echo "获取全量组织架构\r\n";
    $departmentList = $api->DepartmentList();
    var_dump($departmentList);
    echo "\r\n";

    //
    /*$openId = null;
    $api->UserId2OpenId("ZhuShengBen", $openId);
    echo "openid: $openId\n";

    //
    $userId = null;
    $api->openId2UserId($openId, $userId);
    echo "userid: $userId\n";

    //
    $api->UserAuthSuccess("userid");

    //
    $api->UserBatchDelete(array("userid", "aaa"));

    //
    $api->UserDelete("userid"); */
} catch (Exception $e) { 
    echo $e->getMessage() . "\n";
//    $api->UserDelete("userid");
}
