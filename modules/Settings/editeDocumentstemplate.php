<?php
global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit('sorry ');
}
require_once (globalStatic::$root_directory."modules/Documents/editeDocumentstemplate.php");


?>