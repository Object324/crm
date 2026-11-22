<?php



class CustomForm72 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm72']='CustomForm72';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm72';
	var $table_name = "ld_customform72";
	var $table_index= 'customform72id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform72','ld_customform72scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform72'=>'customform72id','ld_customform72scf'=>'customform72id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform72scf', 'customform72id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform72'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform72_no';
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('CustomForm72',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm72');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
    public function after_save()
    {
//        return ; // TODO............ 注释

        global $adb,$current_user;
//        ls 240301 XUQIU20240221-01 【百特】APD维修追踪记录 API接口调用(同步报价和发票附件、APD维修状态同步至YTX)
        $account_version = getVersionInfo();
        if($account_version['account']=='baxter'){
            require_once(globalStatic::$root_directory . "baxter/Baxter.php");
            $baxterobj = new Baxter();
            $this->baxterobj = $baxterobj;
//            一、同步报价和发票附件
            $this->syncFileBaxter();

//           二、 APD维修状态同步至YTX。
            /*if ($this->mode=="edit") {//编辑时仅当维修状态变更时，保存后触发接口调用
                if ($this->column_fields['cf_9274'] == $this->before_save_infos[0]['cf_9274']) {
                    return ;
                }
            }*/

            //开始拼接接口参数
            $userId = $baxterobj->getCustomForm24($this->column_fields['customform24_id'],'customform24_no');
//            $serviceCode = $this->column_fields['customform72_no'];
            $troubleNo = $baxterobj->getCustomForm71($this->column_fields['customform71_id'],'customform71_no');
            $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($this->column_fields['cf_9355']));



            $smcreatorid = $this->column_fields['smcreatorid'];
            if (empty($smcreatorid)) {//新建单据时没有值
                $smcreatorid = $current_user->id;
            }
            $lastname = $baxterobj->getLastname($smcreatorid);

            //240919 XUQIU20240918-05 百特云透析接口调整
            $expressList = [];
            if (!empty($this->column_fields['cf_9277'])) {
                $expressList[] = [   //取故障机
                    "orderType" => 1,//订单类型 1取故障机、2寄故障机、3取周转机、4 周转机回仓、5寄周转机
                    "deviceType" => 1,//设备类型 1故障机 2周转机
                    "expressNo" => $this->column_fields['cf_9277']?:'',//快递单号
                    "sendPhone" => $this->column_fields['sj_phone']?:'',//寄件人手机号
                    "expressTime" => $this->column_fields['cf_9359']?:'',//快递时间
                ];
            }
            if (!empty($this->column_fields['cf_9282'])) {
                $expressList[] = [   //寄故障机
                    "orderType" => 2,
                    "deviceType" => 1,
                    "expressNo" => $this->column_fields['cf_9282']?:'',
                    "sendPhone" => $this->column_fields['cf_9649']?:'',
                    "expressTime" => $this->column_fields['cf_9363']?:'',
                ];
            }
            if (!empty($this->column_fields['cf_9290'])) {
                $expressList[] = [   //取周转机
                    "orderType" => 3,
                    "deviceType" => 2,
                    "expressNo" => $this->column_fields['cf_9290']?:'',
                    "sendPhone" => $this->column_fields['cf_9648']?:'',
                    "expressTime" => $this->column_fields['cf_9645']?:'',
                ];
            }
            if (!empty($this->column_fields['cf_9340'])) {
                $expressList[] = [   //周转机回仓
                    "orderType" => 4,
                    "deviceType" => 2,
                    "expressNo" => $this->column_fields['cf_9340']?:'',
                    "sendPhone" => $this->column_fields['cf_9650']?:'',
                    "expressTime" => $this->column_fields['cf_9646']?:'',
                ];
            }
            if (!empty($this->column_fields['cf_9285'])) {
                $expressList[] = [   //寄周转机
                    "orderType" => 5,
                    "deviceType" => 2,
                    "expressNo" => $this->column_fields['cf_9285']?:'',
                    "sendPhone" => $this->column_fields['cf_9288']?:'',
                    "expressTime" => $this->column_fields['cf_9366']?:'',
                ];
            }
            if (!empty($this->column_fields['cf_9662'])) {
                $expressList[] = [   //寄周转机
                    "orderType" => 6,
                    "deviceType" => 0,
                    "expressNo" => $this->column_fields['cf_9662']?:'',
                    "sendPhone" => $this->column_fields['cf_9664']?:'',
                    "expressTime" => $this->column_fields['cf_9663']?:'',
                ];
            }

            $postdata = array(
                "userId" => $userId,
                "serviceCode" => $serviceCode,
                "troubleNo" => $troubleNo,
                "serviceStatus" => $this->column_fields['cf_9274']?:'',//维修状态 维修进度字段：cf_9274
                "serviceCreateName" => $lastname,
                "IsNeed" => $this->column_fields['cf_9271'] == '是'?1:2,//cf_9271  是否需要周转机 1是 2否
                "tempNo" => $baxterobj->getCustomForm73No($this->column_fields['customform73_id']),//周转机序列号
                "tempHead" => $baxterobj->getCustomForm76($this->column_fields['customform76_id'],'cf_9342'),//周转机负责人 获取ld_customform76scf.cf_9342
//                "expressList" => $expressList
                /*"sendExpressNo" => !empty($this->column_fields['cf_9285'])?$this->column_fields['cf_9285']:'',//cf_9285  周转机寄出快递单号
                "takeExpressNo" => $this->column_fields['cf_9277']?:'',//cf_9277  取故障机快递单号
                "sendPhone" => $this->column_fields['cf_9288']?:'',
                "takePhone" => $this->column_fields['sj_phone']?:'',*/
            );
            if (!empty($expressList)){
                $postdata["expressList"]=$expressList ;
            }
            $APDRepairInfo = $baxterobj->APDRepairApi($postdata);


        }

    }
    public function syncFileBaxter()
    {
        global $adb;
        $record = $this->id;

        $sql = "select ld_seattachmentsrel.crmid,ld_seattachmentsrel.attachmentcolumnname,ld_seattachmentsrel.attachmentsid,ld_attachments.name,path,newfile_name,ld_attachments.storage_location,
            ld_attachments.cloud_path,ld_crmentity.setype from ld_seattachmentsrel
            inner join ld_crmentity on ld_seattachmentsrel.attachmentsid=ld_crmentity.crmid  
            inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.crmid=?";

        $result = $adb->pquery($sql, array($record));
        if ($adb->num_rows($result) > 0) {

            //2、调用云透析附件接口
            $userId = $this->baxterobj->getCustomForm24($this->column_fields['customform24_id'],'customform24_no');
//            $serviceCode = $this->column_fields['customform72_no'];
            $troubleNo = $this->baxterobj->getCustomForm71($this->column_fields['customform71_id'],'customform71_no');
            $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($this->column_fields['cf_9355']));

            $invoice_file_arr = $repair_file_arr = [];//发票附件的aws_key的集合
            for ($i = 0; $i < $adb->num_rows($result); $i++) {

                $attachmentcolumnname = $adb->query_result($result, $i, 'attachmentcolumnname');
                $path = decode_html($adb->query_result($result, $i, 'path'));
                $name = decode_html($adb->query_result($result, $i, 'name'));//原始文件名称
                $newfile_name = decode_html($adb->query_result($result, $i, 'newfile_name'));
                $storage_location = decode_html($adb->query_result($result, $i, 'storage_location'));
                if ($storage_location == 'awsserver') {
                    //现逻辑(保存单据已经上传过)
                    $aws_key = $path.$newfile_name;
                }else{
                    continue;
                }

//                接口传参变了，之前的接口每一个附件调用一次，现在多个附件一次性调接口传，更符合逻辑，涉及调整syncFileBaxter()

                if (!empty($aws_key)) {
                    if ($attachmentcolumnname == 'cf_9333' && $this->column_fields['cf_9276'] == '1') {//发票指令开启时，调附件接口；发票附件接口增加传参参数
                        $invoice_file_arr[] = array(
                            "file"=>$aws_key,//S3文件Key值
                            "fileName"=>$name,//文件原始名
                        );
                    }
                    elseif ($attachmentcolumnname == 'cf_9653' && $this->column_fields['cf_9654'] == '1') {//新增维修报告附件类型,指令开启时，调附件接口
                        $repair_file_arr[] = array(
                            "file"=>$aws_key,//S3文件Key值
                            "fileName"=>$name,//文件原始名
                        );
                    }
                    elseif ($attachmentcolumnname == 'filename' && $this->column_fields['cf_9294'] == '1') {//报价指令开启时
                        $postdata = array(
                            "userId" => $userId,
                            "serviceCode" => $serviceCode,
                            "fileList" => [array(
                                "file"=>$aws_key,//S3文件Key值
                                "fileName"=>$name,//文件原始名
                            )],
                            "type" => 2,////文件类型 1发票附件 2报价单附件 3维修报告附件
                        );

                        $this->baxterobj->syncFileApi($postdata);

                        $this->syncAPDQuoteApi($aws_key);
                    }
                }

            }

            //接口传参变了，之前的接口每一个附件调用一次，现在多个附件一次性调接口传
            //发票附件
            if (count($invoice_file_arr)>0) {
                $cf_9293 = $this->column_fields['cf_9293'];
                if ($cf_9293 == '微信') {
                    $noticeType = 1;
                } elseif ($cf_9293 == '短信') {
                    $noticeType = 2;
                } elseif ($cf_9293 == '短信+微信') {
                    $noticeType = 3;
                }

                $postdata = array(
                    "userId" => $userId,
                    "serviceCode" => $serviceCode,
                    "fileList" => $invoice_file_arr,
                    "type" => 1,//文件类型 1发票附件 2报价单附件 3维修报告附件
                    "invoiceTime" => date("Y-m-d",strtotime($this->column_fields['cf_9364'])),//开票时间（年月日）
                    "invoiceAmount" => round($this->column_fields['cf_9365'],2),//开票金额
                    "userPhone" => trim($this->column_fields['cf_9280']),
                    "noticeType" => $noticeType,
                );

                $response = $this->baxterobj->syncFileApi($postdata);
                //反写发票附件接口返回结果
                $result_fp = '';
                if (isset($response['data']['sendPhoneResult'])) {
                    $sendPhoneResult = $response['data']['sendPhoneResult'];
                    //发送结果 1 发送短信消息成功 2 发送短信消息失败
                    $result_fp .= "短信发送结果：";
                    $result_fp .=  ($sendPhoneResult == '1')?'发送短信消息成功。':(($sendPhoneResult == '2')?'发送短信消息失败。':"无。");
                }
                if (isset($response['data']['sendMessageResult'])) {
                    $sendMessageResult = $response['data']['sendMessageResult'];
                    //发送结果 0 用户未关注公众号 1 发送模板消息成功 2 发送模板消息失败 3 患者不存在
                    $result_fp .= "微信发送结果：";
                    $result_fp .=  ($sendMessageResult == '0')?'用户未关注公众号。':(($sendMessageResult == '1')?'发送模板消息成功。':(($sendMessageResult == '2')?'发送模板消息失败。':(($sendMessageResult == '3')?'患者不存在。':'无。')));
                }

                $adb->pquery("update ld_customform72 inner join ld_customform72scf on ld_customform72.customform72id = ld_customform72scf.customform72id set ld_customform72.result_fp=?,ld_customform72scf.cf_9276 = ? where ld_customform72.customform72id = ?",array($result_fp,'0',$this->id));
            }

            //维修报告附件
            if (count($repair_file_arr)>0) {
                $cf_9659 = $this->column_fields['cf_9659'];
                if ($cf_9659 == '微信') {
                    $noticeType = 1;
                } elseif ($cf_9659 == '短信') {
                    $noticeType = 2;
                } elseif ($cf_9659 == '短信+微信') {
                    $noticeType = 3;
                }

                $postdata = array(
                    "userId" => $userId,
                    "serviceCode" => $serviceCode,
                    "fileList" => $repair_file_arr,
                    "type" => 3,//文件类型 1发票附件 2报价单附件 3维修报告附件
                    "userPhone" => trim($this->column_fields['cf_9658']),
                    "noticeType" => $noticeType,
                    "apdSerialNo"=> $troubleNo,
                    "completionTime"=>date('Y-m-d H:i:s')
                );

                $response = $this->baxterobj->syncFileApi($postdata);

                $result = '';
                if (isset($response['data']['sendPhoneResult'])) {
                    $sendPhoneResult = $response['data']['sendPhoneResult'];
                    //发送结果 1 发送短信消息成功 2 发送短信消息失败
                    $result .= "短信发送结果：";
                    $result .=  ($sendPhoneResult == '1')?'发送短信消息成功。':(($sendPhoneResult == '2')?'发送短信消息失败。':"无。");
                }
                if (isset($response['data']['sendMessageResult'])) {
                    $sendMessageResult = $response['data']['sendMessageResult'];
                    //发送结果 0 用户未关注公众号 1 发送模板消息成功 2 发送模板消息失败 3 患者不存在
                    $result .= "微信发送结果：";
                    $result .=  ($sendMessageResult == '0')?'用户未关注公众号。':(($sendMessageResult == '1')?'发送模板消息成功。':(($sendMessageResult == '2')?'发送模板消息失败。':(($sendMessageResult == '3')?'患者不存在。':'无。')));
                }

                $adb->pquery("update ld_customform72 inner join ld_customform72scf on ld_customform72.customform72id = ld_customform72scf.customform72id set ld_customform72scf.cf_9660=?,ld_customform72scf.cf_9654 = ? where ld_customform72.customform72id = ?",array($result,'0',$this->id));

            }

            unset($invoice_file_arr);
            unset($repair_file_arr);
            unset($response);
            unset($postdata);

        }


    }

    //报价指令(前端改后台)
    public function syncAPDQuoteApi($aws_key)
    {
        global $adb;
        //开始拼接接口参数
        //报价指令开启时，调用接口 并反写结果
        if ($this->column_fields['cf_9294'] == '1') {
            $customform24_id = $this->column_fields['customform24_id'];//关联微信病人模块
            $userId = $this->baxterobj->getCustomForm24($customform24_id,'customform24_no');
            $userName = $userPhone = '';

            $cf_9352 = $this->column_fields['cf_9352'];
            if ($cf_9352 == '微信消息') {//cf_9352 消息收费途径
                $noticeType = 1;
                $userName = $this->baxterobj->getCustomForm24($customform24_id,"cf_6043");
                $userPhone = $this->baxterobj->getCustomForm24($customform24_id,"cf_6107");
            } elseif ($cf_9352 == '手机短信') {
                $noticeType = 2;
                $userName = trim($this->column_fields['cf_9264']);
                $userPhone = trim($this->column_fields['cf_9353']);
            }

            $troubleNo = $this->baxterobj->getCustomForm71($this->column_fields['customform71_id'],'customform71_no');
            $serviceCode = $troubleNo.'-'.date('YmdHis',strtotime($this->column_fields['cf_9355']));
            $serviceCost = round($this->column_fields['cf_9296'], 2);//维修费用,保留2维小数
            $tradeNo = trim($this->column_fields['cf_9272']);

            $postdata = array(
                "userId" => $userId,
                "userName" => $userName,
                "userPhone" => $userPhone,
                "serviceCode" => $serviceCode,
                "troubleNo" => $troubleNo,
                "serviceCost" => $serviceCost,
                "noticeType" => $noticeType,//报价通知类型 1 公众号 2短信
                "offerFile" => $aws_key,
                "tradeNo" => $tradeNo,
            );


            $response = $this->baxterobj->APDQuoteApi($postdata);
            //sendResult: 发送结果 0 用户未关注公众号 1 发送模板消息成功 2 发送模板消息失败 3 患者不存在 4 发送短信消息成功 5 发送短信消息失败
            $sendResult_arr = ["用户未关注公众号","发送模板消息成功","发送模板消息失败","患者不存在","发送短信消息成功","发送短信消息失败"];
            if (isset($response['data']['sendResult']) && !empty($sendResult_arr[$response['data']['sendResult']])) {
                $msg = $sendResult_arr[$response['data']['sendResult']];
            }else{
                $msg = "报价接口错误";
            }

            //更新接口结果
            $sql = "update ld_customform72scf set cf_9295 = ?,cf_9294 = '0' where customform72id = ?;";
            $adb->pquery($sql,array($msg,$this->id));

        }

    }

	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	
 

}
CustomForm72::require_file();
?>