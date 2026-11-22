<?php
/**
editor:gyq_70 reason:有赞微商城  2018/6/27 18:23
 */
function sync_express_youzan(){
    global $adb;
    $sql='SELECT account from ld_version order by id limit 1';
    $result=$adb->pquery($sql,array());
    $nums = $adb->num_rows($result);
    if($nums > 0) {
        $account = $adb->query_result($result, 0, 'account');
        if($account=='youzan'){
            require_once globalStatic::$root_directory. 'expansion/youzan/lib/static_const_youzan.php';
            require_once globalStatic::$root_directory. 'expansion/youzan/lib/EventFromModel.php';
            require_once globalStatic::$root_directory. 'expansion/youzan/lib/YZHttpClient.php';
            require_once globalStatic::$root_directory. 'expansion/youzan/lib/YZTokenClient.php';
            $obj_model = new EventFromModel();

            $rowcnt = $_REQUEST['rowcnt'];
            $product_detail_arr = array();
            $order_id_arr = array();
            $product_id_arr = array();
            //按订单拆分商品分录信息
            for($i=1;$i<=$rowcnt;$i++){
                if(empty($_REQUEST['selectSourceModuleid'.$i])){
                    $entitytypeid = $_REQUEST['entitytypeid'.$i];
                }else{
                    $entitytypeid = $_REQUEST['selectSourceModuleid'.$i];
                }
                $entitytype=$_REQUEST['entitytype'.$i];
                
                $productid = $_REQUEST['hdnProductId'.$i];
                $logistics_company = $_REQUEST['logistics_company'.$i];
                $logistics_number = $_REQUEST['logistics_number'.$i];
                if(!empty($logistics_company)&&!empty($logistics_number)){
                    $order_id_arr[$entitytypeid] = $entitytypeid;
                    $product_id_arr[$productid] = $productid;
                    $product_detail_arr[$entitytypeid][$i]['productid'] = $productid;
                    $product_detail_arr[$entitytypeid][$i]['logistics_company'] = $logistics_company;
                    $product_detail_arr[$entitytypeid][$i]['out_sid'] = $logistics_number;
                }
            }
            if(empty($product_detail_arr)){
                return false;
            }
            //获取271个物流公司的有赞编号
            $express_list_arr = $obj_model->get_express_list();
            if(empty($express_list_arr)){
                return false;
            }
            //获取产品有赞ID
            $product_cable_arr = array();
            $sql='select port_id,port_id2,crm_id from ld_port_cable where crm_id in('.implode(',',$product_id_arr).')';
            $result=$adb->pquery($sql,array());
            $nums = $adb->num_rows($result);
            if($nums > 0){
               for($i=0;$i<$nums;$i++){
                   $crm_id = $adb->query_result($result,$i,'crm_id');
                   $port_id = $adb->query_result($result,$i,'port_id');
                   $port_id2 = $adb->query_result($result,$i,'port_id2');
                   $product_cable_arr[$crm_id] = $port_id.'_'.$port_id2;
               }
            }
            //获取订单有赞编号
            $order_cable_arr = array();
            $sql='select youzan_tid,salesorderid from ld_salesorder where salesorderid in('.implode(',',$order_id_arr).')';
            $result=$adb->pquery($sql,array());
            $nums = $adb->num_rows($result);
            if($nums > 0){
                for($i=0;$i<$nums;$i++){
                    $salesorderid = $adb->query_result($result,$i,'salesorderid');
                    $youzan_tid = $adb->query_result($result,$i,'youzan_tid');
                    $order_cable_arr[$salesorderid] = $youzan_tid;
                }
            }
            if(empty($order_cable_arr) || empty($product_cable_arr)){
                return false;
            }
            //根据有赞订单编号获取商品交易明细编号
            foreach ($product_detail_arr as $orderid=>$content){
                $order_tid =  $order_cable_arr[$orderid];
                $order_oid_arr = $obj_model->get_order_oid($order_tid);

                foreach ($content as $key=>$value){
                    $item_id = $product_cable_arr[$value['productid']];
                    $oid = $order_oid_arr[$item_id];
                    $product_detail_arr[$orderid][$key]['tid'] = $order_tid;
                    $product_detail_arr[$orderid][$key]['oids'] = $oid;
                    $product_detail_arr[$orderid][$key]['out_stype'] = $express_list_arr[$value['logistics_company']];
                }
            }
            $sourcefocus=CRMEntity::getInstance($entitytype);
            $sourcedetail=$sourcefocus->Detail_table;
            //调用订单接口
            foreach ($product_detail_arr as $orderid=>$content){
                foreach ($content as $key=>$value){
                    $obj_model->do_sure($value);
                }

                $output_status = true;//合同订单出库状态
                //获取合同订单所有产品
                $sql = " select productid,quantity from $sourcedetail where id=? ";
                $result = $adb->pquery($sql,array($orderid));
                $nums = $adb->num_rows($result);
                $product_order = array();
                if($nums > 0){
                    for($i=0;$i<$nums;$i++){
                        $productid = $adb->query_result($result,$i,'productid');
                        $product_order[$productid] = $adb->query_result($result,$i,'quantity');
                    }
                }else{
                    $output_status = false;
                }
                //获得已出库产品
                $sql = 'select productid,quantity from ld_outboundorderdetail
                inner join ld_outbounder where entitytype=? and entitytypeid=?';
                $result = $adb->pquery($sql,array('SalesOrder',$orderid));
                $nums = $adb->num_rows($result);
                $product_invoice = array();
                if($nums > 0){
                    for($i=0;$i<$nums;$i++){
                        $productid = $adb->query_result($result,$i,'productid');
                        $product_invoice[$productid] = $adb->query_result($result,$i,'quantity');
                    }
                }
                //判断产品是否都出库了
                $half_output_status = false;
                foreach ($product_order as $key=>$value){
                    if(!array_key_exists($key,$product_invoice)){
                        $output_status = false;
                    }else{
                        $half_output_status = true;
                    }
                }
                if($output_status){
                    $sql = 'update ld_salesorder set youzan_output_status=\'已出库\' where salesorderid=?';
                    $result = $adb->pquery($sql,array($orderid));
                }elseif($half_output_status){
                    $sql = 'update ld_salesorder set youzan_output_status=\'部分出库\' where salesorderid=?';
                    $result = $adb->pquery($sql,array($orderid));
                }
            }
        }
    }
}