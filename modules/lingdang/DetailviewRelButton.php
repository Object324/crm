<?php
global $currentModule;
$_REQUEST['diony']='yes';
/**
 * edit: xll 2023/05/11
 * XUQIU1001386 单据明细界面，相关信息模块中的“新建”操作按钮异步加载---解决速度慢的问题
 * 将相关信息栏新建按钮放到这里获取
 * */
$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($currentModule);
if($_REQUEST['getRelated_listButton'] == 'yes'){
    $relatedid = $_REQUEST['relatedid'];
    $rel_button = Detail_Edit_View::setForeachRelatedLists_Button($is_rel_list,$relatedid);
    $type = $_REQUEST['type'];//dump($is_rel_list[$relatedid]);
    if($type == 'list'){
        $button_content = ' <ul class="detail-relation-second">
                                <li>' .
                                    $rel_button .
                                '</li>
                            </ul>';
    }else{
        $button_content = '<ul class="detail-relation-moresecond">
                                <li>' .
                                    $rel_button .
                                '</li>
                            </ul>';
    }
    ConvertTojsonString(1,$button_content,'success');
}
?>