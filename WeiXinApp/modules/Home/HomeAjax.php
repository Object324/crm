<?php
/*********************************************************************************
 **{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/


//	include('modules/Home/HomeBlock.php');
if(isset($_REQUEST['file']))
{
    //edit: xll 1000113 2023/05/15 首页，“审批状态”查询条件设置查询状态后，增加记住状态功能（宋清华）
    $_REQUEST['module'] = 'Home';
    $moduleFilepath = globalStatic::$root_directory.'modules/'.$_REQUEST['module'].'/'.$_REQUEST['file'].'.php';

    if(file_exists($moduleFilepath) !== false) {
        require_once($moduleFilepath);

    }
    //include('modules/Home/'.$_REQUEST['file'].'.php');
}
?>