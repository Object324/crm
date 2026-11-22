<?php
crm_load_class_file('cls_getRelatedInfo','include/ListView/RelatedListView');
class cls_getRelatedInfoWX extends cls_getRelatedInfo
{
    public function getRelateCount()
    {
        global $adb;

        $obj=$this->getDataCategory_sqlObj();
        //editor:gyq_20191225 reason:0039014: （kfbcrm）移动端，销售机会详情界面，点击【相关】页签，界面加载不出来
        if(!is_object($obj)){
            return array('relcount'=>0,'record'=>'');
        }
        $sql = $obj->getQueryRowCountSql();
        //$rowcount = $obj->getQueryRowCount();

        $tablename=$obj->relatedFocus->table_name;
        $tableindex=$obj->relatedFocus->table_index;
        $sql .= ' order by '.$tablename.'.createdtime desc ';

        $result = $adb->pquery($sql,array());
        $rowcount = $adb->num_rows($result);

        $records = '';
        //editor:gyq_20190816 reason:增加>0 判断避免报错
        if($rowcount>0){
            for($i=0;$i<$rowcount;$i++){
                $records .= $adb->query_result($result,$i,0).',';
            }
            $records = trim($records,',');

            $record = $adb->query_result($result,0,0);
        }
        //相关信息增加合计
        if(array_key_exists('hdnGrandTotal',$obj->querygeneratorobj->moduleobj->column_fields)&&$rowcount>0){
            //editor:gyq_20190820 reason:$tablename中，不一定存在conversion_rate字段
            $totalsql = "select sum(total)/ifnull(conversion_rate,1.000) as total from $tablename where $tableindex in ($records)";
            $totalresult = $adb->pquery($totalsql,array());
            $totalrowcount = $adb->num_rows($totalresult);
            if($totalrowcount > 0){
                $total = $adb->query_result($totalresult,0,0);
                return array('relcount'=>$rowcount,'record'=>$record,'total'=>$total);
            }else{
                $totalsql = "select sum(total) as total from $tablename where $tableindex in ($records)";
                $totalresult = $adb->pquery($totalsql,array());
                $totalrowcount = $adb->num_rows($totalresult);
                if($totalrowcount > 0) {
                    $total = $adb->query_result($totalresult, 0, 0);
                    return array('relcount' => $rowcount, 'record' => $record, 'total' => $total);
                }else{
                    return  array('relcount'=>$rowcount,'record'=>$record);
                }

            }
        }
        return array('relcount'=>$rowcount,'record'=>$record);
    }
}
?>