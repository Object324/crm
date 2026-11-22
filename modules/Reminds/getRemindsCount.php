<?php
require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');
ob_clean();
ob_flush();
echo static_Reminds::getRemindsCount();
exit();
?>