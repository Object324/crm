<?php

global $currentModule;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
global $adb;
$image_path="storage/CardSettings/TopicBlockSettings/";
$smarty->assign("IMAGE_PATH",$image_path);

crm_load_class_file('cls_TopicBlockSettings',"modules/CardSettings");
$topicblockobj = new cls_TopicBlockSettings();

$type = $_REQUEST['type'];//首页专题设置的某一个功能
$mode = $_REQUEST['mode'];//该功能的操作类型 create、edit、delete、read
switch (strtolower($type)) {
    case 'topicset'://专题设置:启用停用专题
        if ($mode == 'gettopic') {
            $data = $topicblockobj->getTopicLists("all");//包含未启用的专题
            $smarty->assign("TopicLists", $data);

            $arr['title'] = '设置专题名称';
            $arr['oktext'] = getFixedLabel("SAVE");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $arr['content'] = $smarty->fetch("modules/CardSettings/topicSet.tpl");
            $arr['topiclists'] = $data;
            ConvertTojsonString(1, $arr, 'success');
        }
        else if ($mode == 'savetopic') {//保存专题
            $topicLists = ldcrm_json_decode($_REQUEST['topiclists']);
            $result = $topicblockobj->saveTopic($topicLists);
            ConvertTojsonString(1, array(), 'success');
        }
        break;
    case 'inputset'://专题信息设置
        $inputname = $_REQUEST['inputname'];
        $inputvalue = $_REQUEST['inputvalue'];
        if ($mode == 'title') {//保存专题
            $result = $topicblockobj->saveTitleinfo($_REQUEST['topicid'],$inputname,$inputvalue);
            ConvertTojsonString(1, array(), 'success');
        }
        else if($mode == 'block') {
            $result = $topicblockobj->saveBlockinfo($_REQUEST['blockid'],$inputname,$inputvalue);
            ConvertTojsonString(1, array(), 'success');
        }
        break;
    case 'titleimage':
        if($mode == 'add'){
            $result = $topicblockobj->addTitleimage($_REQUEST['topicid']);
            ConvertTojsonString(1, array(), 'success');
        }
        else if ($mode == 'delete'){
            $result = $topicblockobj->deleteTitleimage($_REQUEST['titleimageid']);
            ConvertTojsonString(1, array(), 'success');
        }
        
        break;
    case 'addblock'://添加区块
        if($mode == 'getaddblock'){
            $data= $topicblockobj->getTopicTitleinfo($_REQUEST['topicid']);
            $smarty->assign("Topicinfo", $data);
            
            

            $arr['title'] = '添加专题区块';
            $arr['oktext'] = getFixedLabel("SAVE");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $arr['topicid'] = $_REQUEST['topicid'];
            $arr['content'] = $smarty->fetch("modules/CardSettings/TopicBlockAddpop.tpl");
            ConvertTojsonString(1, $arr, 'success');
        }
        else if( $mode == 'getdefaulticon')
        {
            $defaulticondata = $topicblockobj->getTopicblockdefaulticon($_REQUEST['topicid']);
            $smarty->assign("defaulticon", $defaulticondata);
            $arr['title'] = '选择默认图标';
            $arr['oktext'] = getFixedLabel("CONFIRMED");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $arr['topicid'] = $_REQUEST['topicid'];
            $arr['content'] = $smarty->fetch("modules/CardSettings/TopicBlockSelectIconpop.tpl");
            ConvertTojsonString(1, $arr, 'success');
        }
        else if($mode == 'saveblock') {
            $topicid = $_REQUEST['topicid'];
            $blockname = $_REQUEST['blockname'];
            $blockcontent = $_REQUEST['blockcontent'];
            if(isset($_REQUEST['defaultIcon'])&&$_REQUEST['defaultIcon']=='true'){
                $result = $topicblockobj->Addblockdefault($topicid,$blockname,$blockcontent);//添加区块对应的专题信息,使用系统图标
            }
            else{
                $result = $topicblockobj->Addblock($topicid,$blockname,$blockcontent);//添加区块对应的专题信息
            }
            
            ConvertTojsonString(1, array(), 'success');
            
        }
        break;
    case 'blockoperate'://区块操作
        if($mode == 'inactivate'||$mode == 'activate'){
            $result= $topicblockobj->operateTopicBlock($_REQUEST['blockid'],$mode);
            ConvertTojsonString(1, array(), 'success');
        }
        else if($mode == 'delete'){
            $result= $topicblockobj->deleteTopicBlock($_REQUEST['blockid']);
            ConvertTojsonString(1, array(), 'success');
        }
        else if($mode == 'changeimage'){
            $result= $topicblockobj->changeimageTopicBlock($_REQUEST['blockid']);
            ConvertTojsonString(1, array(), 'success');
        }
        break;
    default:
        break;
}
$topicid = 0;
if(isset($_REQUEST['topicid'])){
    $topicid = $_REQUEST['topicid'];
}
else{
    $tmpsql = 'select id from ld_card_specialtopicblock where topicpresence="yes" and type = "topic" limit 1';//默认第一个
    $tmpresult = $adb->pquery($tmpsql,array());
    if($adb->num_rows($tmpresult)>0){
        $topicid = $adb->query_result($tmpresult,0,'id');
    }
}
$topicTitleinfo = $topicblockobj->getTopicTitleinfo($topicid);
$smarty->assign("TopicTitleinfo", $topicTitleinfo);
$titleimagelists = $topicblockobj->getTopicTitleimagelists($topicid);
$smarty->assign("Titleimagelists", $titleimagelists);
$topicBlockLists = $topicblockobj->getTopicBlockLists($topicid);
$smarty->assign("TopicBlockLists", $topicBlockLists);
if($_REQUEST['ajax']=='yes')
{
    //右侧专题下产品列表（table）页
    $arr["content"] = $smarty->fetch("modules/CardSettings/MultiTopicBlock.tpl");
    ConvertTojsonString(1,$arr,'success');
}else{
    //右侧整个页面
    $topicLists = $topicblockobj->getTopicLists();
    $smarty->assign("TopicLists", $topicLists);
    $arr["content"] = $smarty->fetch("modules/CardSettings/TopicBlockSettings.tpl");
    ConvertTojsonString(1,$arr,'success');
}

?>