<?php
crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
$obj=cls_DuplicateColumn::getInstance($_REQUEST['modulename']);

/* 查重第一个序时簿弹框 */

if($_REQUEST['action_type'] == 'datadup_load'){
    if(isset($_REQUEST['search_content'])&&mb_strlen($_REQUEST['search_content'])<2&&$_REQUEST['search']=='true'&&$_REQUEST['fromtype']!='settings'){
        ConvertTojsonString(-2,array(),getFixedLabel('SearchByAtLeast2char'));
    }
    $obj->displayTpl();
    /* 显示列设置弹框 */
}elseif($_REQUEST['action_type'] == 'selectdialog'){
    if(!empty($_REQUEST['fieldids']) && !empty($_REQUEST['searchfieldids'])){
        $obj->saveDuplicateColumnDisplayFromFile($_REQUEST['fieldids']);
        $obj->saveDuplicateColumnSearchFromFile($_REQUEST['searchfieldids']);
        $arr['SearchLabel'] = $obj->getSearchLabel();
        ConvertTojsonString(1,$arr,"success");
    }else{
        $obj->displaySelectTpl();
    }
}



?>