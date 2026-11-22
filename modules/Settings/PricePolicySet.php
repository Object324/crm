<?php

global $current_user,$adb,$languageType;
$smarty = new lingdangCRM_Smarty;
$content = $smarty->fetch('Settings/PricePolicy/PricePolicySet.tpl');
ConvertTojsonString(1,[
    'content' => $content
],'success');
?>
