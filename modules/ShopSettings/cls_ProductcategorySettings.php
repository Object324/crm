<?php

class cls_ProductcategorsySettings
{
    function __construct()
    {
    }

    //获取所有产品类别信息
    public function getAllProductcategory(){
        global $adb;
        $arr = array();
        //先删除已经被删除的产品类别
        $this->deleteProductcategory();
        $query = "SELECT keyid,max(sequence) as max_seq FROM ld_shop_othersettings where type='productcategory'";
        $result = $adb->pquery($query,array());
        $keyid=$adb->query_result($result,0,'keyid');
        if(empty($keyid)){
            //如果数据表为空(第一次进入时),插入所有的产品类别,默认显示
            $this->addProductcategory('show');
        }else{
            //如果数据表有值,插入新增加的产品类别,默认不显示,顺序在已有产品类别之后
            $max_seq=$adb->query_result($result,0,'max_seq');
            $this->addProductcategory('hide',$max_seq);
        }

        //更新完ld_shop_othersettings的数据后(与最新的产品类别保持一致),获取该表中的数据
        $query_last = "SELECT entityid,entityname,display,sequence FROM ld_shop_othersettings where type='productcategory' order by sequence";
        $result_last = $adb->pquery($query_last,array());
        $rows=$adb->num_rows($result_last);
        if($rows>0){
            for($i=0;$i<$rows;$i++){
                $entityid=$adb->query_result($result_last,$i,'entityid');
                $entityname=$adb->query_result($result_last,$i,'entityname');
                $display=$adb->query_result($result_last,$i,'display');
                $sequence=$adb->query_result($result_last,$i,'sequence');
                $list['productname']=$entityname;
                $list['display']=$display;
                $list['sequence']=$sequence;
                $arr[$entityid]=$list;
            }
        }
        return $arr;
    }
    
    //删除ld_shop_othersettings表中已被删除的产品类别
    public function deleteProductcategory(){
        global $adb;
        $query = "SELECT keyid FROM ld_shop_othersettings
        LEFT JOIN (
            SELECT ld_picklist_values.id,ld_picklist_values.listvalue,ld_picklist_values.sequence FROM ld_picklist_values
            INNER JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
            LEFT JOIN ld_shop_othersettings ON ld_shop_othersettings.entityid = ld_picklist_values.id
            WHERE listname = 'productcategory' AND relatetable = 'ld_field' ORDER BY sequence
        ) AS picklist ON picklist.id = ld_shop_othersettings.entityid
        WHERE type = 'productcategory' AND picklist.id is NULL";
        $result = $adb->pquery($query,array());
        $rows=$adb->num_rows($result);
        if($rows>=1){
            for($i=0;$i<$rows;$i++)
            {
                $keyid=$adb->query_result($result,$i);
                $query_delete = "delete from ld_shop_othersettings where keyid=? and type = 'productcategory'";
                $adb->pquery($query_delete,array($keyid));
            }
        }
    }
    
    //插入ld_shop_othersettings表中未添加的产品类别
    public function addProductcategory($display,$seq=''){
        global $adb;
        //wym 240228 BUG20240227-25 商城设置，产品类别设置的选项值显示错误（原本没做更新下拉框值）
        $query = "SELECT ld_picklist_values.id,ld_picklist_values.listvalue,ld_picklist_values.sequence,ld_shop_othersettings.entityid FROM ld_picklist_values
        INNER JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
        LEFT JOIN ld_shop_othersettings ON ld_shop_othersettings.entityid = ld_picklist_values.id
        WHERE listname = 'productcategory' AND relatetable = 'ld_field' AND (ld_shop_othersettings.entityid IS NULL OR ld_shop_othersettings.entityname != ld_picklist_values.listvalue) ORDER BY sequence";
        $result = $adb->pquery($query,array());
        $rows=$adb->num_rows($result);
        if($rows>=1){
            for($i=0;$i<$rows;$i++)
            {
                $listid=$adb->query_result($result,$i,'id');
                $listvalue=$adb->query_result($result,$i,'listvalue');
                $entityid=$adb->query_result($result,$i,'entityid');
                if($entityid){//entityid不为空，这条数据已经插入商城表，需要更新数据的entityname
                    $query_update = "update ld_shop_othersettings set entityname=? where entityid=?";
                    $adb->pquery($query_update,array($listvalue,$entityid));
                }else{//entityid为空，这条数据还没插入商城表，需要插入
                    if(empty($seq)){
                        $sequence=$adb->query_result($result,$i,'sequence');
                    }else{
                        $seq++;
                        $sequence=$seq;
                    }
                    $query_insert = "insert into ld_shop_othersettings(entityid,entityname,display,sequence,type) values(?,?,?,?,'productcategory')";
                    $adb->pquery($query_insert,array($listid,$listvalue,$display,$sequence));
                }
            }
        }
    }

    public function getProductcateById($productid){
        global $adb;
        $list = array();
        $query = "SELECT entityid,entityname,display,sequence FROM ld_shop_othersettings where entityid=? type='productcategory' order by sequence";
        $result = $adb->pquery($query,array($productid));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $entityid=$adb->query_result($result,0,'entityid');
            $entityname=$adb->query_result($result,0,'entityname');
            $display=$adb->query_result($result,0,'display');
            $sequence=$adb->query_result($result,0,'sequence');
            $list['productid']=$entityid;
            $list['productname']=$entityname;
            $list['display']=$display;
            $list['sequence']=$sequence;
        }
        return $list;
    }
}

?>