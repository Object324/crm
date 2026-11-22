<?php
/**
 * Created by PhpStorm.
 * User: gyq161215
 * Date: 2016/12/15 0015
 * Time: 下午 2:16
 */

$purpose = $_REQUEST['purpose'];
$purpose_module = $_REQUEST['purpose_module'];
$record = $_REQUEST['record'];
$frommodule = $_REQUEST['frommodule'];
require_once globalStatic::$root_directory.'WeiXinApp/modules/Users/infoExpansionFuction.php';
switch($purpose){
    case 'get_entityname':
        $return['entityname']=getModuleHref($purpose_module,$record);
        break;
    case 'get_inventoryPrice':
        $return = get_inventoryPrice($frommodule);
        break;
}
ConvertTojsonString(1,$return,'');
//D:\wamp\www\ldcrm\WeiXinApp\modules\Products\InventoryPrice.php