<?php
global $currentModule;
crm_load_class_file('cls_HomepageSettings',"modules/ShopSettings");
$homepageobj = new cls_HomepageSettings();

$type = $_REQUEST['type'];//首页专题设置的某一个功能
$mode = $_REQUEST['mode'];//该功能的操作类型 create、edit、delete、read
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;




switch (strtolower($type)) {
    case 'topicset'://专题设置相关，新增、修改、调序、删除、启用停用专题等
        if ($mode == 'gettopic') {
            $data = $homepageobj->getTopicLists("all");//包含未启用的专题
            $smarty->assign("TopicLists", $data);

            $arr['title'] = '设置专题名称';
            $arr['oktext'] = getFixedLabel("SAVE");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $arr['content'] = $smarty->fetch("modules/ShopSettings/topicSet.tpl");
            $arr['topiclists'] = $data;
            ConvertTojsonString(1, $arr, 'success');
        }
        elseif ($mode == 'deletetopic') {//删除专题
            $topicid = $_REQUEST['topicid'];
            $result = $homepageobj->deleteTopic($topicid);
            if ($result) {
                ConvertTojsonString(1, array(), 'success');
            }else{
                ConvertTojsonString(-1, array(), 'fail');
            }
        }
        elseif ($mode == 'savetopic') {//保存专题（包括新增专题、删除专题、启用停用专题）
            $topicLists = ldcrm_json_decode($_REQUEST['topiclists']);
            $result = $homepageobj->saveTopic($topicLists);
            ConvertTojsonString(1, array(), 'success');
        }
        break;
    case 'topicproductset'://专题产品相关选择产品、取消产品
        $idlist = vtlib_purify($_REQUEST['idlist']);
        $topicid = vtlib_purify($_REQUEST['topicid']);
        if ($mode == 'add') {//选择产品后添加产品到DB,最多20条。
            $idlist = rtrim($idlist,';');
            $productid_arr = explode(";",$idlist);
            if (count($productid_arr) > 0 && $topicid > 0) {
                $result = $homepageobj->addProductsToTopic($topicid, $productid_arr);
            }
            ConvertTojsonString(1, array(), 'success');

        }
        elseif ($mode == 'delete') {
            $idlist = rtrim($idlist,';');
            $id_arr = explode(";",$idlist);
            if (count($id_arr) > 0) {
                $result = $homepageobj->deleteTopicProduct($id_arr);//删除专题下的产品关联关系
            }
            ConvertTojsonString(1, array(), 'success');
        }
        elseif ($mode == 'sequence') {//拖动行后重新排序
            $idlist = rtrim($idlist,';');
            $id_arr = explode(";",$idlist);
            if (count($id_arr) > 0) {
                $result = $homepageobj->setTopicProductSequence($id_arr);
            }
            ConvertTojsonString(1, array(), 'success');
        }
        break;
    default:
        break;
}

$topicProductsLists = $homepageobj->getTopicProductLists();
$smarty->assign("TopicProductsLists", $topicProductsLists);
if($_REQUEST['ajax']=='yes')
{
    //右侧专题下产品列表（table）页
    $arr["content"] = $smarty->fetch("modules/ShopSettings/MultiTopicLists.tpl");
    ConvertTojsonString(1,$arr,'success');
}else{
    //右侧整个页面
    $topicLists = $homepageobj->getTopicLists();
    $smarty->assign("TopicLists", $topicLists);
    $arr["content"] = $smarty->fetch("modules/ShopSettings/HomepageSettings.tpl");
    ConvertTojsonString(1,$arr,'success');
}





?>