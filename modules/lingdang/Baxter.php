<?php
//ls XUQIU1001284 【百特】拜访记录模块，新增编辑时，【邀请手机号】cf_6314字段旁边增加一个发送按钮，使用阿里的短信接口来发送短信
//百特的特殊需求开发，需要特殊处理的，都可以写在这里！！！
//require_once(globalStatic::$root_directory . 'Smarty_setup.php');
global $adb,$current_user,$currentModule;

$version_info = getVersionInfo();
$_REQUEST['diony'] = 'yes';
if ($version_info['account'] != 'baxter') {
    ConvertTojsonString(-1,array(),"警告！百特中国专用，请立即退出！");
}
//$smarty = new lingdangCRM_Smarty();
$mode = $_REQUEST['mode'];
$operationtype = $_REQUEST['operationtype'];

switch ($mode) {
    //根据泛微工号获取用户表id
    case 'sendsms':
        $mobile = $_REQUEST['mobile'];
        $cf_6305 = $_REQUEST['cf_6305'];
        $contactdate = $_REQUEST['contactdate'];

        /*//    20230728 BUG0070271
            百特阿里云短信调整
        模板code：SMS_462195040
        传值变量：code
        传值：病人编号+联系时间（cf_6305+contactdate）
        格式：080384920230728092043
        */
        if (empty($cf_6305)) {
            ConvertTojsonString(-1,[],"病人编号不能为空！");
        }else{
            $cf_6305 = substr($cf_6305,3);
        }
        if (empty($contactdate)) {
            $contactdate = date("YmdHis");
        }else{
            $contactdate = date("YmdHis",strtotime($contactdate));
        }

        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();

        $templateCode = 'SMS_462195040';//百特发送短信的模板code
        $templateParam = json_encode(array("code"=>$cf_6305.$contactdate));
        $arr = $cls_Send_MassSms->send($mobile,'','','',$templateCode,$templateParam,'');



        if (!empty($arr) && $arr['smsresult'] === 1) {
            ConvertTojsonString(1,$arr,"发送成功！");
        }else{
            ConvertTojsonString(-1,$arr,$arr['errormsg']);
        }
        break;
    case 'expressorder'://快递下单
        //api/ytx/miniprogram/apd/device/expressOrder
        if (isset($_REQUEST['columnname']) && !empty($_REQUEST['columnname'])) {
            require_once(globalStatic::$root_directory . "baxter/Baxter.php");
            $baxterobj = new Baxter();

            $columnname = $_REQUEST['columnname'];

            /*{
            "userId":"",
            "orderType":"", // 订单类型 1取故障机、2寄故障机、3取周转机
            "cargo": [{
                "name":"", // 物品名称
                "count": 1, // 物品个数
                "weight": 1 // 物品重量
            }],
            "contactInfoList": [{
                "contact":"", // 联系人
                "contactType":"", //地址类型：1寄件方信息 2到件方信息
                "mobile":"", // 手机号
                "province":"", // 省份
                "city":"", // 城市
                "county":"", // 县/区
                "address":"" //详细地址
            }]
            }*/
//            $orderTypeArr = array("cf_9275"=>1,"cf_9279"=>2,"cf_9287"=>3,"cf_9354"=>4);//订单类型 1取故障机、2寄故障机、3取周转机、4周转机回仓
            $orderTypeZhArr = array("cf_9275"=>"取故障机","cf_9279"=>"寄故障机","cf_9287"=>"取周转机","cf_9354"=>"周转机回仓","cf_9337"=>"寄周转机");//订单类型 1取故障机、2寄故障机、3取周转机、4周转机回仓
//            $orderType = $orderTypeArr[$columnname];

            if ($columnname == 'cf_9275') {
                $orderType = 1;//订单类型: 1取故障机、2寄故障机、3取周转机、4周转机回仓、5寄周转机
                $deviceType = 1;//设备类型：1故障机 2周转机
                $kh_contactType = "1";//地址类型：1寄件方信息 2到件方信息
                $sh_contactType = "2";//地址类型：1寄件方信息 2到件方信息
            } elseif ($columnname == 'cf_9279') {
                $orderType = 2;
                $deviceType = 1;
                $kh_contactType = "2";
                $sh_contactType = "1";
            } elseif ($columnname == 'cf_9287') {
                $orderType = 3;
                $deviceType = 2;
                $kh_contactType = "1";
                $sh_contactType = "2";
            }elseif ($columnname == 'cf_9354') {
                $orderType = 4;
                $deviceType = 2;
                $ck_contactType = "2";//仓库地址为到件方
                $sh_contactType = "1";
            }elseif ($columnname == 'cf_9337') {
                $orderType = 5;
                $deviceType = 2;
                $kh_contactType = "2";
                $sh_contactType = "1";
            }

            //客户信息 即 报修人信息
            $kh_info = array(
                "contact"=>$_REQUEST['createName'], // 联系人
                "contactType"=>$kh_contactType, //地址类型：1寄件方信息 2到件方信息
                "mobile"=>$_REQUEST['mobile'], // 手机号
                "province"=>$_REQUEST['province'], // 省份
                "city"=>$_REQUEST['city'], // 城市
                "county"=>$_REQUEST['county'], // 县/区
                "address"=>$_REQUEST['address'] //详细地址
            );

            //上海维修中心地址信息
            $ShRepairInfo = $baxterobj->getShRepairInfo();
            $sh_info = array(
                "contact" => $ShRepairInfo['contact'], // 联系人
                "contactType" => $sh_contactType, //地址类型：1寄件方信息 2到件方信息
                "mobile" => $ShRepairInfo['mobile'], // 手机号
                "province" => $ShRepairInfo['province'], // 省份
                "city" => $ShRepairInfo['city'], // 城市
                "county" => $ShRepairInfo['county'], // 县/区
                "address" => $ShRepairInfo['address'] //详细地址
            );

            $contactInfoList = array($kh_info, $sh_info);

            //回仓地址处理
            if ($columnname == 'cf_9354') {
                $warehouseInfo = $baxterobj->getWarehouseInfo($_REQUEST['customform75_id']);
                $ck_info = array(
                    "contact" => $warehouseInfo['contact'], // 联系人
                    "contactType" => $ck_contactType, //地址类型：1寄件方信息 2到件方信息
                    "mobile" => $warehouseInfo['mobile'], // 手机号
                    "province" => $warehouseInfo['province'], // 省份
                    "city" => $warehouseInfo['city'], // 城市
                    "county" => $warehouseInfo['county'], // 县/区
                    "address" => $warehouseInfo['address'] //详细地址
                );
                $contactInfoList = array($ck_info, $sh_info);
            }
            //周转机寄出地址處理
            elseif ($columnname == 'cf_9337') {
                $warehouseInfo = $baxterobj->getWarehouseInfo($_REQUEST['customform75_id2']);
                $ck_info = array(
                    "contact" => $warehouseInfo['contact'], // 联系人
                    "contactType" => $sh_contactType, //地址类型：1寄件方信息 2到件方信息
                    "mobile" => $warehouseInfo['mobile'], // 手机号
                    "province" => $warehouseInfo['province'], // 省份
                    "city" => $warehouseInfo['city'], // 城市
                    "county" => $warehouseInfo['county'], // 县/区
                    "address" => $warehouseInfo['address'] //详细地址
                );
                $contactInfoList = array($kh_info, $ck_info);
            }



            //开始拼接接口参数
            $customform24_id = $_REQUEST['customform24_id'];
            $userId = $baxterobj->getCustomForm24($customform24_id,'customform24_no');;
//            $serviceCode = $_REQUEST['serviceCode'];
            $troubleNo = $baxterobj->getCustomForm71($_REQUEST['customform71_id'],'customform71_no');
            $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($_REQUEST['cf_9355']));

            $postdata = array(
                "userId" => $userId,
                "serviceCode" => $serviceCode,
                "deviceType" => $deviceType,
                "orderType" => $orderType,
                "createName" => "百特技术服务中心",//下单人姓名
                "cargo" => [  //托寄物信息
                    [
                        "name" => '腹膜透析机',//货物名称
                        "count" => 1,//货物数量
                        "weight" => 15//货物重量
                    ],
                ],
                "contactInfoList" => $contactInfoList,
            );

            //开始下单
            $body = json_encode($postdata,JSON_UNESCAPED_UNICODE);

            //开始调用接口
            $lastid = $baxterobj->insertApiLog($baxterobj->express_url,$body,date('Y-m-d H:i:s'),$orderTypeZhArr[$columnname]);
            $response = $baxterobj->CurlPost($baxterobj->express_url,$body);
            $baxterobj->updateApiLog($response,date('Y-m-d H:i:s'),$lastid);

            $response = json_decode($response,true);
            if ($response['status'] == '1') {
                ConvertTojsonString(1,$response['data'],$response['msg']);

            }else{
                ConvertTojsonString(-1,$response,$response['msg']);
            }

        }

        break;
    case 'quote_abandon'://报价指令
        require_once(globalStatic::$root_directory . "baxter/Baxter.php");
        $baxterobj = new Baxter();

        //开始拼接接口参数
        $customform24_id = $_REQUEST['customform24_id'];//关联微信病人模块
        $userId = $baxterobj->getCustomForm24($customform24_id,'customform24_no');
        $userName = $userPhone = '';
        if ($_REQUEST['cf_9352'] == '微信消息') {//cf_9352 消息收费途径
            $noticeType = 1;
            $userName = $baxterobj->getCustomForm24($customform24_id,"cf_6043");
            $userPhone = $baxterobj->getCustomForm24($customform24_id,"cf_6107");
        } elseif ($_REQUEST['cf_9352'] == '手机短信') {
            $noticeType = 2;
            $userName = trim($_REQUEST['cf_9264']);
            $userPhone = trim($_REQUEST['cf_9353']);
        }

        $troubleNo = $baxterobj->getCustomForm71($_REQUEST['customform71_id'],'customform71_no');
//        $serviceCode = $_REQUEST['serviceCode'];
        $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($_REQUEST['cf_9355']));
        $serviceCost = round($_REQUEST['serviceCost'], 2);//维修费用,保留2维小数

        $postdata = array(
            "userId" => $userId,
            "userName" => $userName,
            "userPhone" => $userPhone,
            "serviceCode" => $serviceCode,
            "troubleNo" => $troubleNo,
            "serviceCost" => $serviceCost,
            "noticeType" => $noticeType,//报价通知类型 1 公众号 2短信
        );


        $response = $baxterobj->APDQuoteApi($postdata);
        //sendResult: 发送结果 0 用户未关注公众号 1 发送模板消息成功 2 发送模板消息失败 3 患者不存在 4 发送短信消息成功 5 发送短信消息失败
        $sendResult_arr = ["用户未关注公众号","发送模板消息成功","发送模板消息失败","患者不存在","发送短信消息成功","发送短信消息失败"];
        if (isset($response['data']['sendResult']) && !empty($sendResult_arr[$response['data']['sendResult']])) {
            $msg = $sendResult_arr[$response['data']['sendResult']];
        }else{
            $msg = "报价接口错误";
        }
        if ($response['status'] == '1') {
            ConvertTojsonString(1,$response,$msg);
        }else{
            ConvertTojsonString(-1,$response,$msg);
        }

        break;
    case 'agreementSign'://二手机
        require_once(globalStatic::$root_directory . "baxter/Baxter.php");
        $baxterobj = new Baxter();

        //开始拼接接口参数
        $apdSerialNo = $baxterobj->getCustomForm71($_REQUEST['customform71_id'],'customform71_no');
        $docketCode = $apdSerialNo.'-'.date('YmdHis',strtotime($_REQUEST['cf_9356']));

        $postdata = array(
            "userName" => $_REQUEST['userName'],
            "userPhone" => $_REQUEST['userPhone'],
            "apdSerialNo" => $apdSerialNo,
            "docketCode" => $docketCode,//二手机单据号
//            "noticeType" => 2,//报价通知类型 1 公众号 2短信
        );


        $response = $baxterobj->agreementSignApi($postdata);
        $response['current_time'] = date("Y-m-d H:i:s");
        if ($response['status'] == '1') {
            ConvertTojsonString(1,$response,$response['msg']);

        }else{
            ConvertTojsonString(-1,$response,$response['msg']);
        }

        break;
    case 'cancel_expressorder'://取消快递下单
        //api/ytx/miniprogram/apd/device/expressOrder
        if (isset($_REQUEST['columnname']) && !empty($_REQUEST['columnname'])) {
            require_once(globalStatic::$root_directory . "baxter/Baxter.php");
            $baxterobj = new Baxter();

            $columnname = $_REQUEST['columnname'];
            $express_no = $_REQUEST['express_no'];

//            $orderTypeZhArr = array("cf_9275"=>"取故障机","cf_9279"=>"寄故障机","cf_9287"=>"取周转机","cf_9354"=>"周转机回仓","cf_9337"=>"寄周转机");//订单类型 1取故障机、2寄故障机、3取周转机、4周转机回仓、5寄周转机
            $orderTypeZhArr = array("cf_9376"=>"周转机寄出快递取消指令","cf_9377"=>"取故障机快递取消指令","cf_9378"=>"故障机寄回快递取消指令","cf_9379"=>"周转机取回快递取消指令","cf_9380"=>"周转机分派快递取消指令");

            if ($columnname == 'cf_9376') {//周转机寄出快递取消指令
                $orderType = 5;
            } elseif ($columnname == 'cf_9377') {//取故障机快递取消指令
                $orderType = 1;
            } elseif ($columnname == 'cf_9378') {//故障机寄回快递取消指令
                $orderType = 2;
            } elseif ($columnname == 'cf_9379') {//周转机取回快递取消指令
                $orderType = 3;
            } elseif ($columnname == 'cf_9380') {//周转机分派快递取消指令
                $orderType = 4;
            }

            //开始拼接接口参数
            $troubleNo = $baxterobj->getCustomForm71($_REQUEST['customform71_id'],'customform71_no');
            $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($_REQUEST['cf_9355']));

            $postdata = array(
                "serviceCode" => $serviceCode,//维修编号
                "expressNo" => $express_no,//快递单号
                "orderType" => $orderType,
            );

            //开始下单
            $body = json_encode($postdata,JSON_UNESCAPED_UNICODE);

            //开始调用接口
            $lastid = $baxterobj->insertApiLog($baxterobj->cancelexpress_url,$body,date('Y-m-d H:i:s'),$orderTypeZhArr[$columnname]);
            $response = $baxterobj->CurlPost($baxterobj->cancelexpress_url,$body);
            $baxterobj->updateApiLog($response,date('Y-m-d H:i:s'),$lastid);

            $response = json_decode($response,true);
            if ($response['status'] == '1') {
                ConvertTojsonString(1,$response,$response['msg']);

            }else{
                ConvertTojsonString(-1,$response,$response['msg']);
            }

        }

        break;
}
ConvertTojsonString(-1,[],"无效参数");


?>