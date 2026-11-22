<?php

class cls_PhoneSettings
{
    function __construct()
    {
    }
    //获取所有客服电话信息
    public function getAllPhoneinfos(){
        global $adb;
        $list = array();
        $query = "select * from ld_shop_phones order by phoneseq asc";
        $result = $adb->pquery($query,array());
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $phoneid=$adb->query_result($result,$i,'phoneid');
            $name=$adb->query_result($result,$i,'name');
            $status=$adb->query_result($result,$i,'status');
            $phone=$adb->query_result($result,$i,"phone");
            $phoneseq=$adb->query_result($result,$i,'phoneseq');
            $list[]=array('phoneid'=>$phoneid,'name'=>$name,'status'=>$status,'phone'=>$phone,'phoneseq'=>$phoneseq);
        }
        return $list;
    }
    
    //通过phoneid获取客服信息
    public function getPhoneinfoById($phoneid){
        global $adb;
        $list = array();
        $query = "select * from ld_shop_phones where phoneid = ?";
        $result = $adb->pquery($query,array($phoneid));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $phoneid=$adb->query_result($result,$i,'phoneid');
            $name=$adb->query_result($result,$i,'name');
            $status=$adb->query_result($result,$i,'status');
            $phone=$adb->query_result($result,$i,"phone");
            $phoneseq=$adb->query_result($result,$i,'phoneseq');
            $list=array('phoneid'=>$phoneid,'name'=>$name,'status'=>$status,'phone'=>$phone,'phoneseq'=>$phoneseq);
        }
        return $list;
    }
}

?>