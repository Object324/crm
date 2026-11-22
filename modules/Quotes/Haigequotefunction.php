<?php

//通过报价单id获取所有的出货产品记录
function CheckProductDetail($quotesid){
    global $adb;
    $id_arr = array();
    $id = $quotesid;
    do{
        $id_arr[] = $id;
        $sql = 'select copyid from ld_quotes where quoteid = ?';
        $result = $adb->pquery($sql,array($id));
        $id = $adb->query_result($result,0,'copyid');
    }while(!empty($id)&&$id!=0);
    if(sizeof($id_arr)>0){
        $id_str = implode(',',$id_arr);
    }else{
        $id_str = $id_arr[0];
    }
    
    $sql = "SELECT ld_salesorderdetail.productid,ld_salesorderdetail.quantity from ld_quotesdetail 
            INNER JOIN ld_salesorderdetail on ld_quotesdetail.lineitem_id  = ld_salesorderdetail.parent_lineitem_id
            INNER JOIN ld_salesorder on ld_salesorderdetail.id  = ld_salesorder.salesorderid
            where ld_quotesdetail.id IN ($id_str) and ld_salesorder.deleted = 0";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $deal_info=array();
    if($num_rows>0){
        //所有已经成交的产品记录
        
        for($i=0;$i<$num_rows;$i++){
            $productid = $adb->query_result($result,$i,'productid');
            $quantity = $adb->query_result($result,$i,'quantity');
            if(array_key_exists($productid,$deal_info)){
                $deal_info[$productid] += $quantity;
            }else{
                $deal_info[$productid] = $quantity;
            }
        }
        
    }
    return $deal_info;
}

//判断新加产品的产品组是否已存在
function CheckProductGroup($quoteid,$productid){
    global $adb;
    $focus = CRMEntity::getInstance($_REQUEST['module']);
    $arr = array();
    $columnname_arr = array('discount_percent','agent_discount');
    $sql = 'select quote_version from ld_quotes where quoteid = ?';
    $result = $adb->pquery($sql,array($quoteid));
    $cur_version = $adb->query_result($result,0,'quote_version');
    //1.0的版本允许报价单编辑折扣
    if($cur_version==''||$cur_version=='1.0'){
        $arr['allowedit']='yes';
        return $arr;
    }
    //获取对应产品组的折扣最小值
    $discount_sql = 'SELECT min(ld_quotesdetail.discount_percent) as discount_percent ,min(ld_quotesdetail.agent_discount) as agent_discount from ld_quotesdetail 
                		INNER JOIN ld_products on ld_products.productid = ld_quotesdetail.productid
                		where ld_quotesdetail.id = ? and ld_products.productgroup_name in (
                		select productgroup_name from ld_products where productid = ?)';
    $result = $adb->pquery($discount_sql,array($quoteid,$productid));
    $num_rows = $adb->num_rows($result);
    
    if($num_rows>0){
        foreach($columnname_arr as $columnname){
            $discount = $adb->query_result($result,0,$columnname);
            //设置小数位
            $typedata = $focus->detailfieldobj->getFieldInfoBykeyValue('columnname',$columnname,'typeofdata');
            $type_arr = explode(',',$typedata);
            if(sizeof($type_arr)>1){
                $demical = $type_arr[1];
                $discount = number_format($discount,$demical);
            }
            $arr[$columnname]=$discount;
        }
        $allowedit = 'no';
    }else{
        $allowedit = 'yes';
    }
    $arr['allowedit']=$allowedit;
    return $arr;
}

//获取报价单使用状态
function haige_getAvailableStatusByquoteid($quoteid)
{
    global $adb;
    $return_status = 'yse';
    $haigesql = 'select available_status from ld_quotes where quoteid=?';
    $haigeresult = $adb->pquery($haigesql,array($quoteid));
    $haigenum_rows = $adb->num_rows($haigeresult);
    if($haigenum_rows>0)
    {
        $haigeavailable_status = $adb->query_result($haigeresult,0,'available_status');
    }
    if($haigeavailable_status == '不可用'){
        $return_status= 'nouse';
    }
    else if($haigeavailable_status == '失效'){
        $return_status= 'no';
    }
    return $return_status;
    
}

//根据报价单编号获取地址信息
function getShippingAddressByid($quoteid)
{
    global $adb;
    $sql = 'select cf_3023,cf_3024,cf_3025,cf_3026,cf_3027 
            from ld_quotescf where quoteid = ?';
    $result = $adb->pquery($sql,array($quoteid));
    $num_rows = $adb->num_rows($result);
    $shippingaddressarr = array();
    if($num_rows>0)
    {
        $shipping_address1 = $adb->query_result($result,0,'cf_3023');
        $shipping_address2 = $adb->query_result($result,0,'cf_3024');
        $shipping_address3 = $adb->query_result($result,0,'cf_3025');
        $shipping_address4 = $adb->query_result($result,0,'cf_3026');
        $shipping_address5 = $adb->query_result($result,0,'cf_3027');
        $shippingaddressarr = array('cf_3023'=>$shipping_address1,
                                     'cf_3024'=>$shipping_address2,
                                     'cf_3025'=>$shipping_address3,
                                     'cf_3026'=>$shipping_address4,
                                     'cf_3027'=>$shipping_address5);
    }
    //过滤空地址
    if(count($shippingaddressarr)>0){
        foreach($shippingaddressarr as $key => $value)
        {
            if(empty($value)){
                unset($shippingaddressarr[$key]);
            }
        }
    }
    return $shippingaddressarr;
}

//根据报价单编号获取此报价单前一版本的地址信息，若为1.0版本则返回空数组
function getprequoteid($quoteid)
{
    global $adb;
    $shippingaddressarr = array();
    $sql = 'select copyid from ld_quotes where ld_quotes.quoteid = ?';
    $result = $adb->pquery($sql,array($quoteid));
    $copyid = $adb->query_result($result,0,'copyid');
    $prequoteid = $quoteid;
    if($copyid>0)
    {
        $prequoteid =$copyid;
    }
    return $prequoteid;
}


//根据报价单编号判断是否需要创建地址确认单
function isMultipleAddressByid($quoteid)
{
    global $adb;
    $shippingaddressarr = getShippingAddressByid($quoteid);
    $sql = 'select copyid from ld_quotes where ld_quotes.quoteid = ?';
    $result = $adb->pquery($sql,array($quoteid));
    $copyid = $adb->query_result($result,0,'copyid');
    $diffarr = array();
    if($copyid==0)
    {
        //1.0版本的报价单数量大于1,才需要创建地址确认单
        if(count($shippingaddressarr)>1){
            $diffarr = $shippingaddressarr;
        }
    }
    else{
        //非1.0版本的报价单，以下情况创建地址确认单：
        //1、若前一版本地址为空，当前版本地址数量大于2；
        //2、若前一版本地址不为空，与前一版本地址存在差异即创建地址确认单
        $preshippingaddressarr = getShippingAddressByid($copyid);
        if(empty($preshippingaddressarr)){
            if(count($shippingaddressarr)>2){
                //获取当前版本地址信息数组与前一版本地址信息数组的差异
                $diffarr = $shippingaddressarr;
            }
        }
        else{
            //获取当前版本地址信息数组与前一版本地址信息数组的差异
            $diffarr = array_diff_assoc($shippingaddressarr,$preshippingaddressarr);
        }
    }
    if(count($diffarr)>0){
        return true;
    }
    else{
        return false;
    }
}

//海格特殊开发-最终优化清单审核完成后向供应商的首要联系人的邮箱发送带附件的邮件
//附件内容为报价单的产品，数量,已下单数量以及可下单数量，标题为报价单号以及报价单名称
function HaigeSendProductlist($module,$record){
    include(globalStatic::$root_directory."include/PHPMailer/src/PHPMailer.php");
    include(globalStatic::$root_directory."include/PHPMailer/src/SMTP.php");
    global $adb;
    //用于记录邮件发送状态
    $history_sql = 'insert into ld_quotes_mailhistory(quoteid,accountid,fromemail,toemail,conditions,sendtime) values(?,?,?,?,?,?)';
    $sendtime = date('Y-m-d H:i:s');
    //读取系统邮件服务器信息
    $frommailinfo = array();
    $sql="select * from ld_systems where server_type = ?";
    $result = $adb->pquery($sql, array('email'));
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        $server = $adb->query_result($result,0,'server'); //SMTP服务器地址
        $fromemail = $adb->query_result($result,0,'server_username');//邮箱地址
        $password = $adb->query_result($result,0,'server_password');//密码（授权码）
        $smtp_ssl=$adb->query_result($result,0,'smtp_ssl');//ssl端口设置
        $smtp_auth=$adb->query_result($result,0,'smtp_auth');//发送服务是否需要验证
    }else{
        //保存发送失败原因
        $conditions = '未设置系统邮件服务器信息（系统设置-接口设置-邮件服务器设置为空）';
        $adb->pquery($history_sql,array($record,"","","",$conditions,$sendtime));
        return false;
    }
    
    //读取报价单相关单据信息
    $sql = "SELECT ld_quotes.quote_no,ld_potential.potentialname,ld_potential.potential_no,
        	   ld_account.accountname,ld_account.accountid,ld_quotes.quotetype,ld_quotes.quotestage
            FROM ld_quotes INNER JOIN ld_potential ON ld_quotes.potentialid = ld_potential.potentialid
            INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid
            where  ld_quotes.quoteid = ? and ld_account.deleted = 0 and ld_potential.deleted = 0";
    $result = $adb->pquery($sql,array($record));
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        $quote_no = $adb->query_result($result,0,'quote_no');//单据流水号
        $quotetype = $adb->query_result($result,0,'quotetype');//报价单类型
        $quotestage = $adb->query_result($result,0,'quotestage');//报价单阶段
        $potentialname = $adb->query_result($result,0,'potentialname');//项目名称
        $potential_no = $adb->query_result($result,0,'potential_no');//特价申请单号
        $accountname = $adb->query_result($result,0,'accountname');//经销商名称
        $accountid = $adb->query_result($result,0,'accountid');//经销商名称
        if($accountid>0){
            //经销商首要联系人信息
            $contact_sql = "select firstname,lastname,email from ld_contactdetails where accountid = ? and reference = 1 and deleted = 0";
            $contact_result = $adb->pquery($contact_sql,array($accountid));
            $num_rows = $adb->num_rows($contact_result);
            if($num_rows>0){
                $email = $adb->query_result($contact_result,0,'email');//经销商首要联系人邮箱
                if(empty($email)||$email==""){
                    $conditions = '首要联系人邮箱信息为空';
                }
            }else{
                $conditions = '缺少经销商的首要联系人信息';
            }
        }else{
            $conditions = '报价单对应的经销商信息不存在';
        }
    }else{
        $conditions = '报价单对应的经销商信息不存在';
    }
    //保存发送失败原因
    if(isset($conditions) && $conditions!=""){
        $adb->pquery($history_sql,array($record,$accountid,$fromemail,$email,$conditions,$sendtime));
        return false;
    }
    //临时文件存储路径
    $pathname='storage/'.$quote_no.'_'.$potentialname.'.xls';
    //生成产品信息excel
    setProductsExcel($module,$record,$pathname);
    // 实例化PHPMailer核心类
    $mail = new PHPMailer();
    // 使用smtp鉴权方式发送邮件
    $mail->isSMTP();
    
    //SMTP服务器是否需要验证
    if($smtp_auth=='true'){
        $mail->SMTPAuth = true;
    }else{
       $mail->SMTPAuth = false;  
    }
    
    // 链接qq域名邮箱的服务器地址
    $smtpserver=$server;
    $mail->Host =$server;
    // 设置使用ssl加密方式登录鉴权
    //$mail->SMTPSecure = 'ssl';
    // 设置ssl连接smtp服务器的远程服务器端口号
    if($smtp_ssl =='no'){
        $mail->SMTPSecure = 'none';
        $mail->Port = 25;
    }else{
        $mail->SMTPSecure='SSL';
        $mail->Port = 465;
    }
    // 设置发送的邮件的编码
    $mail->CharSet = 'UTF-8';
    // 设置发件人昵称 显示在收件人邮件的发件人邮箱地址前的发件人姓名
    $mail->FromName =$fromemail;
    // smtp登录的账号
    $mail->Username = $fromemail;
    // smtp登录的密码 使用生成的授权码
    $mail->Password = $password;
    // 设置发件人邮箱地址 同登录账号
    $mail->From = $fromemail;
    // 邮件正文是否为html编码 注意此处是一个方法
    $mail->isHTML(false);
    //设置经销商首要联系人邮箱
    $mail->addAddress($email);
    // 添加该邮件的主题
    $content  = '['.$quotestage.']'.$quotetype.'['.$quote_no.']('.$potential_no.'+'.$accountname.'  '.$potentialname.')已经审批!';
    $mail->Subject = $content;
    // 添加邮件正文
    $mail->Body = $content;
    //为该邮件添加附件
    $mail->addAttachment($pathname);
    // 发送邮件 返回状态
    $status = $mail->send();
    //通过返回值判断邮件服务器是否可用
    if(!$status){
        $conditions = '调用邮件服务器失败（可能原因:SMTP服务器地址错误、邮箱密码错误、ssl设置端口错误）';
    }else{
        $conditions = '发送成功';
    }
    //保存邮件发送记录
    $adb->pquery($history_sql,array($record,$accountid,$fromemail,$email,$conditions,$sendtime));
    //发送邮件后，删除临时文件
    @unlink($pathname);
}
//生成产品数量清单excel
function setProductsExcel($module,$record,$filename){
    include(globalStatic::$root_directory."PHPExcel/PHPExcel.php");
    include(globalStatic::$root_directory."PHPExcel/PHPExcel/IOFactory.php");
    include(globalStatic::$root_directory."PHPExcel/PHPExcel/Cell.php");
    global $adb;
    $focus = CRMEntity::getInstance($module);
    $detail_tablename = $focus->Detail_table;
    //产品名称、数量、已下单数量、可下单数量
    $columnname_arr = array('productname','quantity','haveordercount','remainquantity');
    $columnname_sqlarr = array('productname','quantity','haveordercount','(quantity-haveordercount) as remainquantity');
    $columnname_sqlstr = implode(',',$columnname_sqlarr);
    $sql = 'select '.$columnname_sqlstr.' from '.$detail_tablename.' INNER JOIN ld_products on ld_products.productid = ld_quotesdetail.productid where id = ?';
    $result = $adb->pquery($sql,array($record));
    $num_rows = $adb->num_rows($result);
    //读取报价单所有产品信息
    if($num_rows>0){
        $productinfo_arr = array();
        for($i=0;$i<$num_rows;$i++){
            $tmp_arr = array();
            foreach($columnname_arr as $key=>$columnname){
                $tmp_value = $adb->query_result($result,$i,$columnname);
                if($key>0 && $key<4 && is_numeric($tmp_value)){ //去除数量的小数位
                    $tmp_value = round($tmp_value);
                }
                $tmp_arr[$columnname] = $tmp_value;
            }
            $productinfo_arr[] = $tmp_arr;
        }
    }
    //数据表列头（字段名称）
    $fieldlabel_arr = array();
    foreach($columnname_arr as $columnname){
        if($columnname == 'remainquantity'){
            $fieldlabel_arr[]='未下单数量';
        }else{
            $fieldlabel_arr[]=$focus->detailfieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel');    
        }
    }
    //excel操作类
    $objPHPExcel = new PHPExcel();
    $objPHPExcel->setActiveSheetIndex(0);
    $activesheet=$objPHPExcel->getActiveSheet();
    $activesheet->setTitle('报价单产品数量清单');
    $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel,'Excel5');
    //行标题
    foreach($fieldlabel_arr as $key=>$fieldlabel){
        $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($fieldlabel));
    } 
    //产品信息 
    foreach($productinfo_arr as $key=>$arr){
        foreach($columnname_arr as $key2=>$columnname){
           $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+2), trim($arr[$columnname]),PHPExcel_Cell_DataType::TYPE_STRING);
        }
    }
    $objWriter->save($filename);
}

?>