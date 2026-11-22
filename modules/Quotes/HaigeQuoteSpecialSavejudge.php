<?php
global $adb,$languageTy;
//海格报价单保存判断
$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'haige' && $_REQUEST['module'] == 'Quotes'||(isset($_REQUEST['record'])))
{
    $haigesaveinfo = haigesave_judgment();
    if($haigesaveinfo['permit'] == 'no')
    {
        $nosavehtml['content'] = '<div style="margin: 10px;">'.$haigesaveinfo['remindinfo'].'</div>';
        ConvertTojsonString("-1",$nosavehtml,"success");
    }
}
//特殊物料清单判断
$arr = array();
if(isset($_REQUEST['rowcnt'])&&$VersionInfo['account'] == 'haige'&& $_REQUEST['module'] == 'Quotes')
{
    $repaceableflag = true;
    $repacehtml = '<table class="ControlTable1 listEntries fir-center listSettingData" width="100%" cellspacing="1" cellpadding="0" border="0">
                    <tbody><tr style="background-color: #f0f0f0;"><th>行号</td><td>'.getFixedLabel('Currentmodel').'</td><td>'.getFixedLabel('Alternativemodels').'</td><td>'.getFixedLabel('DESCRIPTION').'</td></tr>';
    $rowcnt = (int)$_REQUEST['rowcnt'];
    $row = 0 ;
    for($i=1;$i<=$rowcnt;$i++)
    {
        $productname = $_REQUEST['productname'.$i];
        $hdnProductId = $_REQUEST['hdnProductId'.$i];
        $sql = 'select customform46_no,sales_input,replace_mode,description from ld_customform46 where deleted=0 and sales_input=?';
        $result = $adb->pquery($sql,array($productname));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $repaceableflag = false;
            $replace_mode = $adb->query_result($result,0,'replace_mode');
            $description = $adb->query_result($result,0,'description');
            if($row%2 == 0)
                $repacehtml .= '<tr class="lvtColData">';
            else
                $repacehtml .= '<tr class="lvtColDataBj">';
            $repacehtml .='<td>'.$i.'</td><td>'.$productname.'</td><td>'.$replace_mode.'</td><td>'.$description.'</td></tr>';
            $row ++;
        }
    }
    $repacehtml .= '</tbody></table>';
    
    if($repaceableflag == false){
        $arr['title'] = getFixedLabel('SPECIALMATERIALWARNINGINFO');
        $arr['oktext'] = getFixedLabel('CONFIRMED');
        $arr['canceltext'] = getFixedLabel('CANCEL');
        $arr['repacehtml'] = $repacehtml;
    }
}
ConvertTojsonString(1,$arr,'');

//海格保存时判断
//1、新增保存（1.0版本）报价单时，增加验证规则：如果已存在对应“特价申请编号”1.0版本的报价单，则不允许保存并给出提示信息
    //potentialid = $_REQUEST['potential_id']数量大于0
//2、“特价申请编号”符合条件时：
    //判断字段是否为空，海格的特殊判断，增加判断标准面价、数量为0 ，若存在为0信息，不可保存并返回单据信息
    //数量不为为0时判断存在出库记录单据的订单数量（产品）不小于已发货数量
function haigesave_judgment()
{
    global $adb,$languageType;
    $haigesaveinfo = array('permit'=>'yes','remindinfo'=>'');
    $permint = 'yes';
    $remindinfo = '';
    //新增判断特价申请编号
    if(isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes') &&!isset($_REQUEST['isDuplicate']))
    {
        $potential_id = $_REQUEST['potential_id'];  //特价单编号
        $sql = 'select quoteid from ld_quotes where potentialid = ?;';
        $result = $adb->pquery($sql,array($potential_id));
        $rows = $adb->num_rows($result);
        if($rows > 0)
        {
            $permint='no';
            $remindinfo = '此报价编号已有1.0版本的报价单，请使用复制功能。';   //此报价编号已有1.0版本的报价单，请使用复制功能。
        }
        if($permint=='no'){
            $haigesaveinfo['permit'] = $permint;
            $haigesaveinfo['remindinfo'] = $remindinfo;
            return $haigesaveinfo;
        }
    }
    //复制编辑获取报价单对应的出货记录
    if(isset($_REQUEST['record'])&&!empty($_REQUEST['record']))
    {
        $quotesid = trim($_REQUEST['record']);
        crm_load_function_file('CheckProductDetail','modules/Quotes','Haigequotefunction');
        $deal_info=CheckProductDetail($quotesid);
    }
    
    //判断标准面价金额是否为空及数量是否满足条件
    $rowid = 1;
    $rowcnt = $_REQUEST['rowcnt'];
    do{
        if(!empty($_REQUEST['hdnProductId'.$rowid]) && $_REQUEST['hidden_rowid_'.$rowid] == 0){
            $infos = '';$discount_percent_flag = true;$agent_discount_flag=true;
            $standardprice = $_REQUEST['standardprice'.$rowid]; //标准面价
            $quantity = $_REQUEST['quantity'.$rowid];   //数量
            if(isset($_REQUEST['discount_percent'.$rowid]))
            {
                $discount_percent = $_REQUEST['discount_percent'.$rowid];   //折扣
            }
            else{
                $discount_percent_flag = false;
            }
            if(isset($_REQUEST['agent_discount'.$rowid])){
                $agent_discount = $_REQUEST['agent_discount'.$rowid];   //经销商折扣
            }
            else{
                $agent_discount_flag = false;
            }
            
            
            if($standardprice == 0 || $standardprice == ''){
                $permint = 'no';
                $infos .= '标准面价';
            }
            if($quantity == 0 || $quantity == ''){
                $permint = 'no';
                if(empty($infos)){
                    $infos .= '数量';
                }
                else{
                    $infos .= '、数量';
                }
                
            }
            if(($discount_percent_flag)&&($discount_percent == 0 || $discount_percent == '')){
                $permint = 'no';
                if(empty($infos)){
                    $infos .= '折扣';
                }
                else{
                    $infos .= '、折扣';
                }
                
            }
            if(($agent_discount_flag)&&($agent_discount == 0 || $agent_discount == '')){
                $permint = 'no';
                if(empty($infos)){
                    $infos .= '经销商折扣';
                }
                else{
                    $infos .= '、经销商折扣';
                }
                
            }
            if(!empty($infos)){
                $infos = $infos.'不能为0;';
            }
            if($quantity >= 0&&isset($deal_info)&&!empty($deal_info))
            {
                //复制、编辑，数量不为0时判断存在出库记录单据的订单数量（产品）不小于已发货数量
                $hdnProductId = $_REQUEST['hdnProductId'.$rowid];
                if(array_key_exists($hdnProductId,$deal_info)){
                    if($quantity<$deal_info[$hdnProductId]){
                        $permint = 'no';
                        $infos.= '数量不能小于已发货数量;';
                    }
                    unset($deal_info[$hdnProductId]);
                }
            }
            if(!empty($infos)){
                $remindinfo .= '第'.$rowid.'行'.$infos.'<br>';
            }
        
        }
        $rowid++;
        
    }while($rowid<=$rowcnt);
    //zkt 20230515 产品已有发货记录不能删除
    if(!empty($deal_info)){
        foreach($deal_info as $tmpproductid=>$tmpquantity){
            $sql = 'select productname from ld_products where productid = ?;';
            $result = $adb->pquery($sql,array($tmpproductid));
            $rows = $adb->num_rows($result);
            if($rows > 0)
            {
                $permint = 'no';
                $productname = $adb->query_result($result,0,'productname');
                $remindinfo .= '产品'.$productname.'已有发货记录不可删除<br>';
            }
        }
    }
    
    $haigesaveinfo['permit'] = $permint;
    $haigesaveinfo['remindinfo'] = $remindinfo;
    
    return $haigesaveinfo;
}


?>
