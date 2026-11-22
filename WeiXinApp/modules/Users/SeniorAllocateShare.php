<?php

$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$arrFixedLabel = array(
    'CONFIRMED',//确定
    'CANCEL',//取消
    'ALLSELECT',//全选
    'RESET',//重置
    'choose',//已选
    'ASSIGNSUCCEEDED',//分配成功
    'SHARINGSUCCEEDED',//共享成功
    'HIGHSEASASSIGNSUCCEEDED',//公海分配成功
    'PleaseSelectOneRelatedModule',//请至少选择一个相关信息模块
    'SELECTONECOLLEAGUE',//请至少选择一个同事
);
$arr['arrFixedLabel'] = TransFieldlabel($arrFixedLabel);

include(globalStatic::$root_directory.'modules/Users/SeniorAllocateShare.php');

?>