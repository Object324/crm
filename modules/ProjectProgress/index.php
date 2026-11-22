<?php

global $currentModule;

checkFileAccessForInclusion("modules/$currentModule/ListView.php");
include_once("modules/$currentModule/ListView.php");

?>