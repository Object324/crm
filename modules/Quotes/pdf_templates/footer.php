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


$desc=explode("\n",$description);
$cond=explode("\n",$conditions);
$num=230;

/* **************** Begin Description ****************** */
$descBlock=array("10",$top,"53", $num);
$pdf->addDescBlock($description, $app_strings["Description"], $descBlock);

/* ************** End Description *********************** */



/* **************** Begin Terms ****************** */
$termBlock=array("107",$top,"53", $num);
$pdf->addDescBlock($conditions, $app_strings["Terms & Conditions"], $termBlock);

/* ************** End Terms *********************** */


?>