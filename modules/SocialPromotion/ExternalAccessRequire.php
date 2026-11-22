<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/7/14 11:24
 * Description: 表单推广 有些请求不需要登录 需要包含本文件
 */
$root_dir=dirname( dirname(dirname(__FILE__)));
$root_dir.=DIRECTORY_SEPARATOR;
$root_directory=$root_dir;
include($root_dir.'includefile.php');
require_once($root_dir.'Register/RegOp.php');
require_once ($root_dir.'data/CRMEntity.php');
require_once ($root_dir.'include/utils/CommonFun.php');