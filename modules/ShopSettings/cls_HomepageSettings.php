<?php

class cls_HomepageSettings
{
    function __construct()
    {
    }

    //保存专题（新增、修改专题名、排序）
    public function saveTopic($topicLists){
        global $adb;
        foreach ($topicLists as $key=>$topicList) {
            $topicid = $topicList["topicid"];
            $topic_name = $topicList["topic_name"];
//            $old_topic_name = $topicList["old_topic_name"];
            $presence = $topicList["presence"];
            if (!empty($topicid)) {//修改  由于需要修改排序，故全部更新,否则用专题原值和现值判断可以减少查询
                $sql = 'update ld_shop_homepagetopic set topic_name = ?,sequence = ?,presence = ? where topicid = ?';
                $adb->pquery($sql,array($topic_name,$key,$presence,$topicid));
            }else{//新增
                $sql = 'insert into ld_shop_homepagetopic(topic_name,sequence,presence) values(?,?,?)';
                $adb->pquery($sql,array($topic_name,$key,$presence));
            }

        }

        return true;
    }

    /*
     * $type  all:包括未启用的专题列表 ，默认只返回启用的专题
     * */
    public function getTopicLists($type='')
    {
        global $adb;
        if (strtolower($type) == 'all') {
            $sql = 'select * from ld_shop_homepagetopic where deleted = 0 order by sequence';
        }else{
            $sql = 'select * from ld_shop_homepagetopic where deleted = 0 and presence="yes" order by sequence';
        }
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
        $data = [];
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $data[] = array(
                    "topicid"=>$adb->query_result($result,$i,'topicid'),
                    "topic_name"=>$adb->query_result($result,$i,'topic_name'),
                    "sequence"=>$adb->query_result($result,$i,'sequence'),
                    "presence"=>$adb->query_result($result,$i,'presence'),
                );
            }
        }

        return $data;
    }

//    删除专题及关联产品
    public function deleteTopic($topicid)
    {
        global $adb;
        if (empty($topicid)) {
            return false;
        }

        $sql = 'delete from ld_shop_homepagetopic where topicid = ?';//直接删除，deleted废弃
        $adb->pquery($sql,array($topicid));

        $sql = 'delete from ld_shop_homepagetopic_products where topicid = ?';
        $adb->pquery($sql,array($topicid));

        return true;
    }

    //选择产品后，保存产品id到专题下（一对多）
    public function addProductsToTopic($topicid, $productid_arr)
    {
        global $adb;
        foreach ($productid_arr as $key=>$productid) {

            $tmpsql = 'select * from ld_shop_homepagetopic_products where topicid = ? and productid=?';
            $tmp_result = $adb->pquery($tmpsql,array($topicid, $productid));
            if ($adb->num_rows($tmp_result) > 0) {//topicid和productid有联合约束，省略查询判断也可以
                continue;
            }else{//新增
                $sql = 'insert into ld_shop_homepagetopic_products(topicid,productid) values(?,?)';
                $adb->pquery($sql,array($topicid,$productid));

            }

        }

        $adb->query("set @i=0;");
        $adb->query("update ld_shop_homepagetopic_products set sequence=(@i:=@i+1) where topicid = $topicid order by id asc;");

        return true;
    }

    //专题产品列表
    public function getTopicProductLists()
    {
        global $adb;
        $topicid = $_REQUEST['topicid'];
        if (empty($topicid)) {
            $tmpsql = 'select topicid from ld_shop_homepagetopic where deleted = 0 and presence="yes" order by sequence limit 1';//默认第一个
            $tmpresult = $adb->pquery($tmpsql,array());
            $topicid = $adb->query_result($tmpresult,0,'topicid');
        }

        $sql = 'select IFNULL(pp.productstatus,\''.PULLOFF_SHELF.'\') as productstatus,tp.*,p.productname,ifnull(p.imagename,\'\') as imagename,p.productsheet,p.unit_price,p.costprice from ld_shop_homepagetopic_products as tp INNER JOIN ld_products as p on p.productid = tp.productid LEFT JOIN ld_shop_productproperty as pp ON pp.productid=tp.productid where tp.topicid=? order by tp.sequence limit 20';

        $result = $adb->pquery($sql,array($topicid));
        $num_rows = $adb->num_rows($result);

        require_once('modules/Products/Products.php');
        $focus = new Products();
        $data = [];
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $entity_id = $adb->query_result($result,$i,'productid');

                /*
                 * 合同订单选产品 show_type为 SHOW_POPUP   显示图片可以直接使用img标签。
                 * [rawvalue] => 28794
                   [value] => storage/2020/September/22/Products_dog_886580cu1.jpg
                   [parent_module] =>
                *
                * show_type为 SHOW_LISTVIEW
                * [rawvalue] => 28794
                  [value] => Array
                  (
                      [0] => storage/2020/September/22/Products_dog_886580cu1.jpg
                  )
                  [parent_module] =>
                */
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",'imagename');//重新使用productid查询图片路径，故上面列表的sql查询其实没用，ld_products表的imagename始终为空

                $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'Products',SHOW_LISTVIEW);
                $showfieldvalueobj->setadbResult($result);
                $showfieldvalueobj->setLine_index($i);
                $showfieldvalueobj->setRecorId($entity_id);
                $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,'','');

                if ($showvalue['value'][0] != "" && strlen($showvalue['value'][0]) > 10) {
                    $imagename = getImageListViewHtml($showvalue, '', $entity_id);
                } else {
                    $imagename = "";
                }

                $data[] = array(
                    "id"=>$adb->query_result($result,$i,'id'),
                    "topicid"=>$topicid,
                    "productid"=>$entity_id,
                    "sequence"=>$adb->query_result($result,$i,'sequence'),
                    "productstatus"=>$adb->query_result($result,$i,'productstatus'),
                    "productname"=>$adb->query_result($result,$i,'productname'),
                    "imagename"=>$imagename,
                    "productsheet"=>$adb->query_result($result,$i,'productsheet'),
                    "unit_price"=>number_format($adb->query_result($result,$i,'unit_price'),2),
                    "costprice"=>number_format($adb->query_result($result,$i,'costprice'),2),
                );
            }
        }

        return $data;
    }

    //删除专题下的产品关联关系(取消产品)
    public function deleteTopicProduct($id_arr)
    {
        global $adb;
        foreach ($id_arr as $id) {
            $sql = 'delete from ld_shop_homepagetopic_products where id = ?';
            $adb->pquery($sql,array($id));
        }
        return true;
    }

    //专题产品拖动后重新排序
    public function setTopicProductSequence($id_arr)
    {
        global $adb;
        $sequence = 1;
        foreach ($id_arr as $id) {
            $sql = 'update ld_shop_homepagetopic_products set sequence=? where id = ?';
            $adb->pquery($sql,array($sequence,$id));
            $sequence++;
        }
        return true;
    }

}

?>