<?php


class cls_strategy{
    //价格策略设置界面保存
    public function save_setting(){
        global $adb,$current_user;
        $para1 = $_REQUEST['para1'];//固定基数
        $para2 = $_REQUEST['para2'];//固定增量
        $para3 = $_REQUEST['para3'];//阶梯增量
        $type = $_REQUEST['type'];
        $reocrd = $_REQUEST['reocrd'];
        $sysdeploy = getSys_deploy(49);//单据明细中数量小数位数
        $lengthdecamount = $sysdeploy['deploy_value'];
        $sysdeploy = getSys_deploy(93);//设置单据分录明细中单价字段小数位数
        $lengthdecprice= $sysdeploy['deploy_value'];
        //清除表中旧数据
        $delele_sql = 'delete from ld_productstrategy where productid=?';
        $adb->pquery($delele_sql,array($reocrd));
        //策略类型为“无”
        if($type==0){
            $update_sql = 'update ld_products set havepricestrategy=\'no\' where productid=?';
            $adb->pquery($update_sql,array($reocrd));
            return false;
        }else{
            $update_sql = 'update ld_products set havepricestrategy=\'yes\' where productid=?';
            $adb->pquery($update_sql,array($reocrd));
        }

        $insert_sql = 'insert into ld_productstrategy (productid, count_from, count_to, type, userid,money)
                        value (?,?,?,?,?,?)';
        //公共类型“固定基数”
        foreach ($para1 as $key=>$value){
            $adb->pquery($insert_sql,array($reocrd,$value[0],$value[1],1,$current_user->id,$value[2]));
        }
        //策略类型为“固定基数+固定增量”
        if ($type==2){
            $adb->pquery($insert_sql,array($reocrd,$para2[0],$para2[0],2,$current_user->id,$para2[1]));
        }elseif ($type==3){
        //策略类型为“固定基数+阶梯增量”
            foreach ($para3 as $key=>$value){
                $adb->pquery($insert_sql,array($reocrd,$value[0],$value[1],3,$current_user->id,$value[2]));
            }
        }
    }
    //获取策略设置界面
    public function get_setting_windows($r_record){
        global $adb;

        $sql  = 'select  count_from, count_to, type,money from ld_productstrategy where productid=? order by id asc';
        $result = $adb->pquery($sql,array($r_record));
        $num_rows = $adb->num_rows($result);
        $arr2 = array();

        $sysdeploy = getSys_deploy(49);//单据明细中数量小数位数
        $lengthdecamount = $sysdeploy['deploy_value'];
        $sysdeploy = getSys_deploy(93);//设置单据分录明细中单价字段小数位数
        $lengthdecprice= $sysdeploy['deploy_value'];

        for($i=0;$i<$num_rows;$i++){
            $arr = array();
            $type = $adb->query_result($result,$i,'type');
            $count_from = $adb->query_result($result,$i,'count_from');
            $count_to = $adb->query_result($result,$i,'count_to');
            $money = $adb->query_result($result,$i,'money');
            //格式化内容
            if($type==1){
                $arr[0] = setNumberFormatEmptySeperator($count_from,$lengthdecamount);
                $arr[1] = setNumberFormatEmptySeperator($count_to,$lengthdecamount);
                $arr[2] = $money;
            }elseif ($type==2){
                $arr[0] = 1;
                $arr[1] = 1;
                $arr[2] = setNumberFormatEmptySeperator($money,$lengthdecprice);;
            }elseif ($type==3){
                $arr[0] = setNumberFormatEmptySeperator($count_from,$lengthdecamount);
                $arr[1] = setNumberFormatEmptySeperator($count_to,$lengthdecamount);
                $arr[2] =setNumberFormatEmptySeperator($money,$lengthdecprice);
            }
            $arr2[$type][] = $arr;
        }
        //type 价格策略类型  3=>固定基数+阶梯增量  2=>固定基数+固定增量  1=>固定基数   0=>未设置价格策略
        if(isset($arr2[3])){
            $type = 3;
        }elseif (isset($arr2[2])){
            $type = 2;
        }elseif (isset($arr2[1])){
            $type = 1;
        }else{
            $type = 0;
        }
        $arr3['rows'] = $arr2;
        $arr3['rownums'] = $num_rows;
        $arr3['type'] = $type;
        return $arr3;
    }
    
 
    
    public function getstrategyByProductId($arrproduct)
    {
       
      
       
        if(is_array($arrproduct)&&$arrproduct[0]>0)
        {
            $productids=implode(",",$arrproduct);
        }
        else if(empty($arrproduct))
        {
      
            return array('info'=>array(),'maxfixedbase'=>array(),'productids'=>array(-1));
        }
        else
        {
            $productids=$arrproduct;
        }
        $deploy_values=getSys_deploy(49);
        $lenthdecimal=$deploy_values['deploy_value'];
        
        global $adb;
        //排序方式很重要
        $sql='select * from ld_productstrategy where productid in( '.$productids.') 
             order by productid, type asc, count_from asc ';
        $result=$adb->pquery($sql,array());
        $rows=$adb->num_rows($result);
        if($rows<=0)
        {
            return array('info'=>array(),'maxfixedbase'=>array(),'productids'=>array());
        }
        $prevproductid=$adb->query_result($result,0,'productid');
        $prevtype=$adb->query_result($result,0,'type');
        $productids=array();
        for($i=0;$i<$rows;$i++)
        {
            $productid=$adb->query_result($result,$i,'productid');
            $type=$adb->query_result($result,$i,'type');
            $count_from=number_format($adb->query_result($result,$i,'count_from'),$lenthdecimal,".","");
            $count_to=number_format($adb->query_result($result,$i,'count_to'),$lenthdecimal,".","");
            $money=$adb->query_result($result,$i,'money');
            
            $strategyarr[$productid][]=array("productid"=>$productid
                    ,'count_from'=>$count_from,'count_to'=>$count_to
                    ,'type'=>$type,'money'=>$money);
                    
                 
                  
            if($prevtype!=$type||$prevproductid!=$productid)
            {
                if($prevtype==1)
                {
                    $maxfixedbase[]=array('productid'=>$prevproductid,'count_to'=>number_format($adb->query_result($result,$i-1,'count_to'),$lenthdecimal,".",""));//固定基数;//固定基数
                }
            }
            if(!in_array($productid,$productids))
                    $productids[]=$productid;
            $prevtype=$type;
            $prevproductid=$productid;
           
            
            
        }
    
        if($type==1)
        {
             $maxfixedbase[]=array('productid'=>$productid,'count_to'=>$count_to);//固定基数
        }
     
        
        $tmp=array("info"=>$strategyarr,'maxfixedbase'=>$maxfixedbase,'productids'=>$productids);
       
        return $tmp;
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

?>