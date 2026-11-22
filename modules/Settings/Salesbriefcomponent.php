<?php
/***************************************************
**更新操作
**edit:xtx
**date:2022-8-11
**reason:工作汇报中报表组件显示、隐藏或排序编辑
***************************************************/

require_once('include/CustomFieldUtil.php');
require_once 'modules/PickList/PickListUtils.php';
global $adb,$current_user,$languageType;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty;
$subMode = $_REQUEST['sub_mode'];


//简报组件编辑框部分
if($subMode=='SetBriefComponent' && $_REQUEST['ajax'] == 'true')
{
    $sql = "select type,presence,sequence from ld_workreport_showset  where  belongtype ='component' order by sequence";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    
    if($num_rows>0) {
        $selected_component_arr=array();
        $tobeselected_component_arr=array();
        for($i = 0; $i < $num_rows; $i++){
            $selected_component_type= $adb->query_result($result,$i,'type');
            $selected_component_sequence= $adb->query_result($result,$i,'sequence');
            $selected_component_presence= $adb->query_result($result,$i,'presence');
            $selected_componentlabel= getComponentlabel($selected_component_type);
            if($selected_component_presence=="yes"){    
                $selected_component_arr[$selected_component_sequence]=array('label'=>$selected_componentlabel,'type'=>$selected_component_type) ;
            }else{
                $tobeselected_component_arr[$selected_component_sequence]=array('label'=>$selected_componentlabel,'type'=>$selected_component_type) ;
            }
        }
    }
    
   
    $smarty->assign("related_component_selected",$selected_component_arr);
    $smarty->assign("related_component",$tobeselected_component_arr);
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['title']=getFixedLabel('Jobbriefing');
    $str=$smarty->fetch('Settings/SetBriefComponents.tpl');
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
    
    //简报组件保存部分
}elseif($subMode=='savebriefcomponent' && $_REQUEST['ajax'] == 'true'){
    $tobeselected_component_str =trim($_REQUEST['AssmablyColumnsString'],';');
    $selected_component_str = trim($_REQUEST['selectedAssmablyColumnsString'],';');
    $selected_component_arr=explode(';',$selected_component_str);
    $tobeselected_component_arr=explode(';',$tobeselected_component_str);
    if(!empty($selected_component_arr)){
        foreach($selected_component_arr as $selectedkey=>$selected_value){
            //获取已选组件的顺序
            $selected_sequence=$selectedkey+1;
            $sql ="update ld_workreport_showset set presence = 'yes' ,sequence=? where type =? and belongtype = 'component'";
            $adb->pquery($sql,array($selected_sequence,$selected_value));               
        }
    }
    if(!empty($tobeselected_component_arr)){
        foreach($tobeselected_component_arr as $tobeselected_value){
            $query ="update ld_workreport_showset set presence = 'no' where type =? and belongtype = 'component'";
            $adb->pquery($query,array($tobeselected_value));
        }
    }
   
   //获取已显示的简报组件的相关信息
    $sql = "select type,presence,sequence from ld_workreport_showset  where presence = 'yes' and belongtype ='component' order by sequence";
    $selected_result = $adb->pquery($sql,array());
    $row_num = $adb->num_rows($selected_result);
    
    if($row_num>0) {
        $component_arr=array();
        for($i = 0; $i < $row_num; $i++){
            $component_type= $adb->query_result($selected_result,$i,'type');
            $component_sequence= $adb->query_result($selected_result,$i,'sequence');
            
            $array_bfcomponent=array();
            $array_bfcomponent['sequence']=$component_sequence;
            $array_bfcomponent['component_strtolower']=strtolower($component_type);
            //各个模块对应的组件名
            $briefinglabel= getComponentlabel($component_type);
            
            $array_bfcomponent['componentlabel']=$briefinglabel;
            //收款金额、签到报表的计量单位不一样；
            if ($component_type=='CashBill'){
                $array_bfcomponent['componentunit']='元';
             }elseif($component_type=='Singin'){
                $array_bfcomponent['componentunit']='次';
             }else{
                $array_bfcomponent['componentunit']='个';
             }
            $component_arr[$component_type]=$array_bfcomponent;
        }
    } 
    $smarty->assign("BFCOMPONENT",$component_arr);
    $string=$smarty->fetch('Home/Briefcomponent.tpl');
    $array['content']=$string;
    ConvertTojsonString(1,$array,"success");
    exit();   
}
//各个模块对应的可修改简报组件名
function getComponentlabel($bfcomponenttype){
    global $current_user,$languageType;
    if($languageType == 'en'&&$bfcomponenttype!="CashBill"&&$bfcomponenttype!="Singin"){
        $bfcomponentlabel= getFixedLabel('NEW') . ' ' . getTranstab($bfcomponenttype);
    }elseif($languageType == 'zh'&&$bfcomponenttype!="CashBill"&&$bfcomponenttype!="Singin"){
        $bfcomponentlabel= getFixedLabel('NEW') .  getTranstab($bfcomponenttype);
    }elseif($bfcomponenttype=='CashBill'){
        $bfcomponentlabel=getFixedLabel('CollectionAmount');
    }elseif($bfcomponenttype=='Singin'){
        $bfcomponentlabel=getFixedLabel('signin1');
    }
    return $bfcomponentlabel;
}
?>