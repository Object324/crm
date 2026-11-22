<?php
/**
 * Created by PhpStorm.
 * User: gyqD:\wamp\www\ldcrm\modules\Users\eventToApiWX.php
 * Date: 2017/12/14 0021
 * Time: 下午 5:36
 */
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
include_once(globalStatic::$root_directory . 'WeiXinApp/lib/EventToApiModel.php');
$o_event_api = new EventToApiModel();
switch ($_REQUEST['method']) {
    case 'uninstall_crm':
        $o_event_api->uninstallInCRM();
        break;
}






