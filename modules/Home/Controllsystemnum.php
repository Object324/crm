<?php

/**
 * @author andy
 * @reason 系统编号改进
 * @date 20140729
 * @verson v5.6
 */

include('include/SystemCode/SystemCode.php');

if($_REQUEST['ajax'] == 'true' && $_REQUEST['type'] == '1')
{
    echo '###SUCCESS###';
     $systemcode=new SystemCode();
     
    echo $systemcode->getModuleSeqNumRecordd($_REQUEST['mode'],$_REQUEST['fldname'],$_REQUEST['optionvalue'],$_REQUEST['fieldvalue']);
    echo 
    exit();
}


unset($adb);
?>