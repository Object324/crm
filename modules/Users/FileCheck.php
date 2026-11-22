<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
require_once('include/utils/utils.php');
require_once('Smarty_setup.php');
require_once("include/ListView/ListViewSession.php");

global $app_strings;
global $list_max_entries_per_page_new;
global $currentModule, $current_user;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//$_REQUEST['passUrl'] = 'http://101.132.177.72/recordings/2018-10-25/2018-10-25-12-50-29-4862_18101810122_57505573.mp3';
if(isset($_REQUEST['type']) && $_REQUEST['type'] != '')
{   
    if(isset($_REQUEST['passUrl']) && $_REQUEST['passUrl'] != '')
    {
        $passUrl = $_REQUEST['passUrl'];
        if(file_exists($passUrl))
        {
            echo '#########:#';
            echo 'yes';//存在
        }
        else
        {
            if(file_exists_curl($passUrl)){
                echo '#########:#';
                echo 'yes';//存在
            }else{
                echo '#########:#';
                echo 'no';//不存在
            }
        }
    }
}

exit();

function file_exists_curl($url)
{
    $ch = curl_init();
    curl_setopt($ch, curlopt_url,$url);
    curl_setopt($ch, curlopt_nobody, 1); // 不下载
    curl_setopt($ch, curlopt_failonerror, 1);
    curl_setopt($ch, curlopt_returntransfer, 1);

    if(curl_exec($ch)!==false)
        return true;
    else
        return false;
}

?>