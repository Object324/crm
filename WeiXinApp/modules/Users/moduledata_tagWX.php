<?php
global $current_user,$adb;
$module = $_REQUEST['from_module'];
$record = $_REQUEST['record'];
$type = $_REQUEST['type'];
$_REQUEST['action']='DetailView';
crm_load_class_file('cls_moduledata_tag','include/utils');
$cls_moduledata_tag = new cls_moduledata_tag($module,$record);
if(isset($_REQUEST['tagid'])&&!empty($_REQUEST['tagid'])){
    $tag_ids = $_REQUEST['tagid'];
}else{
    Callback_part($module);
}
switch($type){
    case 'add':
    $id_list = explode(',',$tag_ids);
    foreach($id_list as $id){
        $cls_moduledata_tag->add_moduledata_tagWX($id);
    }
    break;
    
    case 'delete':
    $id_list = explode(',',$tag_ids);
    foreach($id_list as $id){
        $cls_moduledata_tag->delete_moduledata_tagWX($id);
    }
    break;
}
Callback_part($module);

function Callback_part($module)
{
   /*crm_load_class_file('cls_Instance','WeiXinApp/WeiXin_common');
    $mobj = cls_Instance::get_moduleAction_Instance($module,'DetailView');
    $details = $mobj->set_DetailView();
    $blocks = $mobj->jsonArr['list'];
    foreach($blocks as $value){
        if($value['fieldinfo'][0]['fieldname']=='tag'){
            ConvertTojsonString(1,array('list'=>array($value)),'success');
        }
    }*/
    
    
    
    crm_load_class_file('DetailView_301', 'include/fields/DetailView');
    $focus=CRMEntity::getInstance($module);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("uitype",301);
    $col_fields=[];
    $col_fields['record_id']=$_REQUEST['record'];
    $focus->id=$_REQUEST['record'];
    $moduledata_tag = DetailView_301::get_uitype_301($focus, $fieldinfo, $col_fields, $tabid);
	$label_fld[] = $moduledata_tag[0];
	$label_fld[] = $moduledata_tag[1];
	$label_fld['secid'] = $moduledata_tag[2];
    $label_fld['choosedArr'] = $moduledata_tag[3]; 
    $label_fld['options'] = $moduledata_tag[4];
    $label_fld['option'] = $moduledata_tag[5];
    $arr['list'][0]=array("blocklabel"=>"biao",'display_status'=>1);
    $arr['list'][0]["fieldinfo"][0]=array('fieldname'=>"tag",'typeofdata'=>'V~O','fieldlabel'=>'标签','uitype'=>301);
    $arr['list'][0]["fieldinfo"][0]=$label_fld;
   // $arr['list'][0]['uitype']=301;
    ConvertTojsonString(1,$arr,'success');
}
?>