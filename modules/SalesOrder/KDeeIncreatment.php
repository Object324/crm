<?php
header("Content-Type:text/html;charset=UTF-8");
date_default_timezone_set('Asia/Shanghai');

$filehandle=fopen('user_privileges/settaobao.txt','r');
$autoget=fgets($filehandle);
$eqpos=stripos($autoget,'=');
$autoget=substr($autoget,$eqpos+1);
$automiss=fgets($filehandle);
$eqpos=stripos($automiss,'=');
$automiss=substr($automiss,$eqpos+1);
$missinterval=fgets($filehandle);
$eqpos=stripos($missinterval,'=');
$missinterval=substr($missinterval,$eqpos+1);
fclose($filehandle);

$missinterval=24;

$start_date = date("Y-m-d H:i:s");
$start_date = date("Y-m-d H:i:s",strtotime("$start_date -$missinterval hours"));
$enddate=date("Y-m-d H:i:s");

$file_handle=fopen('modules/SalesOrder/Kincreament.txt','w+');
fwrite($file_handle,$enddate);
fclose($file_handle);



require_once("include/taobao/OrderAPI.php");
require_once('include/taobao/OrderInfo.php');

$orderapi=new OrderAPI();
$totalresp=array();


$resp=$orderapi->trades_sold_increatement($start_date,$enddate,1,1);

$sizecount=ceil($resp['total_results'][0]/100);

if($sizecount*100<$resp['total_results'][0])
{
   $sizecount+=1;
}

for($j=0;$j<=$sizecount;$j++)
{
    $resp=$orderapi->trades_sold_increatement($start_date,$enddate,$j+1,100);
  
   $totalresp[]=$resp;
   if(sizeof($resp)<=0&&!array_key_exists('trades',$resp))
    {
        
        break;
   }

    for($i=0;$i<sizeof($resp['trades']['trade']);$i++)
    {
         $orderinfo=new OrderInfo();
    
         $orderinfo->setAccount_name(trim($resp['trades']['trade'][$i]['buyer_nick']));//买家淘宝账号
         //因为联系人没有区域，所以要判断接受人地址是否包含区域
         if(strpos($resp['trades']['trade'][$i]['receiver_address'],$resp['trades']['trade'][$i]['receiver_district'])===false)
            $orderinfo->setOrder_address(trim($resp['trades']['trade'][$i]['receiver_district'].$resp['trades']['trade'][$i]['receiver_address']));//接受人地址
         else
            $orderinfo->setOrder_address(trim($resp['trades']['trade'][$i]['receiver_address']));//接受人地址
            
         $orderinfo->setOrder_contactName(trim($resp['trades']['trade'][$i]['receiver_name']));//接收人姓名
         if(array_key_exists('consign_time',$resp['trades']['trade'][$i]))
                $orderinfo->setOrder_duedate(trim($resp['trades']['trade'][$i]['consign_time']));//发货日期consign_time
         $orderinfo->setOrder_CreatedTime(trim($resp['trades']['trade'][$i]['created']));//订单提交时间(创建时间)
         $orderinfo->setOrder_signdate(trim($resp['trades']['trade'][$i]['pay_time']));//付款时间(签约日期)
         $orderinfo->setOrder_phone(trim($resp['trades']['trade'][$i]['receiver_phone']));//接受人电话
         $orderinfo->setOrder_mobile(trim($resp['trades']['trade'][$i]['receiver_mobile']));//接受人手机
         $orderinfo->setProvince(trim($resp['trades']['trade'][$i]['receiver_state']));//省份
         $orderinfo->setCity(trim($resp['trades']['trade'][$i]['receiver_city']));//城市
         $orderinfo->setDistrict(trim($resp['trades']['trade'][$i]['receiver_district']));//区域
         $orderinfo->setOrder_total($resp['trades']['trade'][$i]['payment']);//订单合计金额（包含运费和折扣）
         $orderinfo->setOrder_no(trim($resp['trades']['trade'][$i]['tid']));//订单编号
      
         $orderinfo->setAccount_address($resp['trades']['trade'][$i]['buyer_area']);//买家所在IP地址
          if(!empty($resp['trades']['trade'][$i]['buyer_message']))//买家备注
         {
            $orderinfo->setBuyer_description($resp['trades']['trade'][$i]['buyer_message']);
            
         }

        $orderinfo->setSell_nick($resp['trades']['trade'][$i]['seller_nick']);//卖家淘宝账号（昵称)
            
        $status="";
         switch(trim($resp['trades']['trade'][$i]['status']))
         {
            case 'TRADE_FINISHED':
                 $status='已审批';
                 $orderinfo->setTaobao_OrderStatus('交易成功');
                break;
            case 'WAIT_BUYER_PAY':
            case 'TRADE_WAIT_BUYER_PAY':
                $status='已创建';
                $orderinfo->setTaobao_OrderStatus('等待买家付款');
                break;
            case 'TRADE_SELLER_SEND_GOODS':
                $status='已付款';
                $orderinfo->setTaobao_OrderStatus('买家已付款');
                break;
            case 'WAIT_BUYER_CONFIRM_GOODS':
            case 'TRADE_WAIT_BUYER_CONFIRM_GOODS':
                $status='已发货';
                $orderinfo->setTaobao_OrderStatus('等待买家确认收货,即:卖家已发货');
                break;
            case 'TRADE_CLOSED':
                 $status='已作废';
                 $orderinfo->setTaobao_OrderStatus('付款以后用户退款成功，交易自动关闭');
                 break;
            case 'TRADE_MANUAL_CLOSED':
            case 'TRADE_CLOSED_BY_TAOBAO':
                $status='已作废';
                 $orderinfo->setTaobao_OrderStatus('付款以前，卖家或买家主动关闭交易');
                
                break;
         }
         $orderinfo->setOrder_status($status);
         $description='';
       if($status=='已付款'||$status=='已发货')
         {
          
            $orderdetails=$orderapi->trade_fullinfo_get($resp['trades']['trade'][$i]['tid']);//获取订单详情
            if($orderdetails['trade']['seller_memo']!='')//卖家备注
            {
                $orderinfo->setSale_Description($orderdetails['trade']['seller_memo']);
            }
          
            if(array_key_exists('promotion_details',$orderdetails['trade']))
            {
                 $orderinfo->setPromotion_desc($orderdetails['trade']['promotion_details']);
            }
         }
          $orderinfo->setPost_fee(trim($resp['trades']['trade'][$i]['post_fee']));
        
        
         if(!is_array($resp['trades']['trade'][$i]['orders']['order'][0]))
         {
            
            $resp['trades']['trade'][$i]['orders']['order']=array($resp['trades']['trade'][$i]['orders']['order']);
         }
         $orderinfo->setOrderDetails($resp['trades']['trade'][$i]['orders']);
        $orderinfo->save();

        // $orderinfo->set_productname()
    }
 }
  

?>