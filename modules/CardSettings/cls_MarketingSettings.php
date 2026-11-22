<?php

class cls_MarketingSettings
{
    function __construct()
    {
    }

    public function getMarketingInfo(){
        global $adb;

        $sql = "select * from ld_card_marketing order by sequence";
        $result = $adb->pquery($sql, array());
        $num_rows = $adb->num_rows($result);
        $data = [];
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $data[] = array(
                    "id" => $adb->query_result($result, $i, 'id'),
                    "btn_image" => $adb->query_result($result, $i, 'btn_image'),
                    "btn_name" => $adb->query_result($result, $i, 'btn_name'),
                    "btn_label" => $adb->query_result($result, $i, 'btn_label'),
                    "link_url" => $adb->query_result($result, $i, 'link_url'),
                    "sequence" => $adb->query_result($result, $i, 'sequence'),
                    "presence" => $adb->query_result($result, $i, 'presence'),
                );
            }
        }


        return $data;
    }

    //行操作
    public function marketingOperate($mode,$id){
        global $adb;
        $sql = "select * from ld_card_marketing where id = $id";
        $result = $adb->pquery($sql, array());
        if ($adb->num_rows($result) > 0) {
            if ($mode == 'inactivate') {//停用
                $adb->pquery("update ld_card_marketing set presence = ? where id = ?", array('no',$id));
            } elseif ($mode == 'activate') {//启用
                $adb->pquery("update ld_card_marketing set presence = ? where id = ?", array('yes',$id));
            } elseif ($mode == 'moveup') {//上移
                $sequence = $adb->query_result($result,0,'sequence');
                $adb->pquery('update ld_card_marketing set sequence = sequence+1 where sequence=?',array($sequence-1));
                $adb->pquery('update ld_card_marketing set sequence = sequence-1 where id=?',array($id));

//                $adb->query("set @i=0;");//重新排序
//                $adb->query("update ld_card_marketing set sequence=(@i:=@i+1) order by sequence asc;");
            } elseif ($mode == 'movedown') {//下移
                $sequence = $adb->query_result($result,0,'sequence');
                $adb->pquery('update ld_card_marketing set sequence = sequence-1 where sequence=?',array($sequence+1));
                $adb->pquery('update ld_card_marketing set sequence = sequence+1 where id=?',array($id));
            } /*elseif ($mode == 'delete') {//删除
                $adb->pquery("delete from ld_card_marketing where id = ?", array($id));
            }*/

        }


        return true;
    }





}

?>