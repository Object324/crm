<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
$group_focus = new Group();
$isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:'checkbox';
$profileArray = getAllUserlevel();
$treehtml .= $group_focus->setTreeList($profileArray,$isbox,'','level');

$arr = [];
$arr['content'] = $treehtml;
$arr['groupuser'] = $groupuser;
$arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';
$arr['listdata'] = [array('label'=>getFixedLabel('LBL_PROFILES'),'value'=>'group','list'=>$profileArray['level'],'group_parent_key'=>'level')];
ConvertTojsonString(1,$arr,"success");


//获取所有的职位级别，并且按树形结构数组结构储存
function getAllUserlevel(){
    crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
//职位级别
    global $adb;

    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $valuearr = $objpinklist->getPickListValues('userlevel',"",array(),"id");
    if(!empty($valuearr)){
        $levelArray['level']['name']='所有职位';
        foreach($valuearr as $pick_id => $pick_val){
            $levelArray['level']['children']['level_'.$pick_id]['name'] = $pick_val;
        }

        return $levelArray;
    }
    return '';
}
?>