<?php
if(isset($_REQUEST['file']) && ($_REQUEST['file'] !=''))
{
    if(file_exists('modules/ShoppingMall/'.$_REQUEST['file'].'.php')) {
        checkFileAccessForInclusion('modules/ShoppingMall/'.$_REQUEST['file'].'.php');
        require_once('modules/ShoppingMall/'.$_REQUEST['file'].'.php');
    }else{
        require_once('modules/lingdang/'.$_REQUEST['file'].'.php');
    }
}else{
    require_once('include/Ajax/CommonAjax.php');
}
?>