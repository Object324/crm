<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zxm 2021-0120【微信端：产品编码、选择产品、产品列表搜索增加扫码功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000730
if(isset($_REQUEST['file']) && ($_REQUEST['file'] !=''))
{
    if(file_exists('modules/Products/'.$_REQUEST['file'].'.php')) {
        checkFileAccessForInclusion('modules/Products/'.$_REQUEST['file'].'.php');
        require_once('modules/Products/'.$_REQUEST['file'].'.php');
    }else{
        require_once('modules/lingdang/'.$_REQUEST['file'].'.php');
    }
}else{
    require_once('include/Ajax/CommonAjax.php');
}
