<?php
global   $theme, $currentModule, $current_user,$site_URL,$adb,$languageType;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
$topicid = $_REQUEST['topicid'];
$focus->mode = 'create';

$topic_array = [];
if ($topicid>0){
    $focus->mode = 'edit';
    $topic_array = ldcrm_json_decode($_REQUEST['topic_json']);
}

//新建题目后进行编辑操作
$data = [];

//编辑问题
if(!empty($_REQUEST['topic_json']) && $focus->mode == 'edit'){

    if(!empty($topic_array)){
        $data['topicid'] = $topic_array['topicid'];
        $data['topic_type'] = $topic_array['topic_type'];
        $data['topic_name'] = unicodeDecode($topic_array['topic_name']);
        $data['description'] = $topic_array['topic_description'];
        $data['required'] = $topic_array['required'];
        foreach($topic_array['topic_option_array'] as $key => $val){
            $data['topic_info'][] = $val;
        }
        if($data['topic_type'] == 'SelectBill'){
            $data['topic_referencemodule'] = $topic_array['topic_other_info']['referencemodule'];
            $data['topic_APPROVEDEMAND'] = $topic_array['topic_other_info']['approvedemand'];
            $data['topic_MaxRowsShow'] = $topic_array['topic_other_info']['maxrowsshow'];
            $data['topic_fieldonly'] = $topic_array['topic_other_info']['fieldonly'];
            $data['topic_advance_demand'] = ldcrm_json_encode($topic_array['topic_other_info']['advance_demand']);
            $data['topic_advance_demand_groups'] = ldcrm_json_encode($topic_array['topic_other_info']['advance_demand_groups']);
            $sql = 'select ld_tab.name,ld_tranlabel.fieldlabel from ld_tab inner join ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid 
                    where ld_tab.presence in(0,2) and ld_tranlabel.trantable="ld_tab" and languagetype=?  and ld_tab.name= ?';
            $result=$adb->pquery($sql,array($languageType,$data['topic_referencemodule']));
            if($adb->num_rows($result)>0){
                $data['referencemodule'] = array('name'=>$data['topic_referencemodule'],'label'=>$adb->query_result($result,0,'fieldlabel'));
            }
        }

    }
}
$referencemodules=[];
$canselectmodules=[];
$topic_json_array = !empty($_REQUEST['topic_json_array'])?ldcrm_json_decode($_REQUEST['topic_json_array']):[];
if(count($topic_json_array)>0){
    for($i = 0;$i<count($topic_json_array);$i++){
        if($topic_json_array[$i][1] == 'SelectBill'){
            $referencemodules[] = $topic_json_array[$i]['topic_other_info']['referencemodule'];
        }
    }
}
$sql='select ld_tab.name,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab inner join ld_field  on ld_field.tabid=ld_tab.tabid 

inner join ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid 
 where ld_tab.presence in(0,2) and ld_tranlabel.trantable="ld_tab" and languagetype=?  and ld_field.columnname="smownerid" group by ld_tab.tabid   order by tabsequence asc ';

$result=$adb->pquery($sql,array($languageType));
$rows=$adb->num_rows($result);
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');
    if(in_array($name,$referencemodules))
    {
        continue;
    }
    $canselectmodules[]=array('name'=>$name,'label'=>$adb->query_result($result,$i,'fieldlabel'));
}
$smarty->assign('BLOCKID',$_REQUEST['blockid']);
$smarty->assign('TOPIC_ID',$_REQUEST['topicid']);
$smarty->assign('TOPIC_JSON',$_REQUEST['topic_json']);
$smarty->assign('ROWINDEX',$_REQUEST['rowindex']);
$smarty->assign('DATA_LEN', !empty($data['topic_info'])?sizeOf($data['topic_info']):0);
$smarty->assign('DATA',$data);
$smarty->assign('STATUS',$focus->mode);
$smarty->assign('CANSELECTMODULS',$canselectmodules);
$str=$smarty->fetch("modules/Questionnaire/addQuestionTopic.tpl");
$_REQUEST['diony']='diony';
$arr['title'] = getTranstab($currentModule);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

function unicodeDecode($name){
    $json = '{"str":"'.$name.'"}';
    $arr = json_decode($json,true);
    if(empty($arr)) return '';
    return $arr['str'];
}

?>