<?php
global $adb,$current_user;
/* editor:gyq_09 reason:派息规则 date:2016 3 31 */

require_once('modules/DividendOrder/cls_Dividend_rules.php');

$Rules = DividendRules::getInstance('');

$Rules->autoEnter();

?>