<?php
/**
 * Smarty plugin
 * @package Smarty
 * @subpackage plugins
 */

/**
 * Get seconds and microseconds
 * @return double
 */
 /* 修改编码格式:统一编码：UTF-8*/
function smarty_core_get_microtime($params, &$smarty)
{
    $mtime = microtime();
    $mtime = explode(" ", $mtime);
    $mtime = (double)($mtime[1]) + (double)($mtime[0]);
    return ($mtime);
}


/* vim: set expandtab: */

?>
