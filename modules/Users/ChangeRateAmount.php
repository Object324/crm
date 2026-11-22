<?php
    global $current_user,$adb,$PlatformMC,$languageType;
	$currency_id = $_REQUEST['currency_id'];//选择后的币种ID
	//更改银行账户
	if(isset($_REQUEST['currency_id']) && 
	isset($_REQUEST['ChangeBank']) && $_REQUEST['ChangeBank'] == true)
	{
	   crm_load_class_file('BankAccountSet','modules/BankAccountSet');
		$result=BankAccountSet::getBackAccount($currency_id);
		$rowCount = $adb->num_rows($result);
		for($i = 0; $i<$rowCount; $i++)
		{
			$bankid = $adb->query_result($result,$i,'bankaccountsetid');
			$bankname = $adb->query_result($result,$i,'accountname');
			$bankAccount[$i]=$bankid . '&'.$bankname;
		}
		echo '###SUCCESS###' . implode(',',$bankAccount);
		exit;
	}
    $before_currency_id =  $_REQUEST['before_currency_id']; //选择前的币种ID
    //获取币种汇率
    if(isset($_REQUEST['getCurrencyCate']) && $_REQUEST['getCurrencyCate'] == true)
    {
        //获取后币种的汇率);
		$currencyobj=Currency::getInstance($adb,$currency_id);
		$currencyRate['rate'] = $currencyobj->getCurrencyRate();
        //获取前币种的汇率
		$currencyobj= new Currency($adb,$before_currency_id);
		$beforecurrencyRate['rate'] = $currencyobj->getCurrencyRate();
        echo '###SUCCESS###' . $beforecurrencyRate['rate'] . '|' . $currencyRate['rate'];
        exit;
    }
    //获取所有金额字段 和 币种汇率
    if(isset($_REQUEST['currency_id']) && isset($_REQUEST['return_module']))
    {
        $module = $_REQUEST['return_module'];
       
        $focus =CRMEntity::getInstance($module);
        
  		$moduleFields =$focus->fieldobj->getModuleFields();
        //判断当前模块是否存在币种字段 currency_id
        if(isset($moduleFields['currency_id']))
        {
            $tabid = getTabid($module); 
            //获取当前模块下的所有金额字段
            $query = 'select fieldname from ld_field where  tabid = ? and presence in(0,2) and uitype in (71,72)';
            $result = $adb->pquery($query,array($tabid));
            $num_rows = $adb->num_rows($result);
           //获取后币种的汇率
			$currencyobj=Currency::getInstance($adb,$currency_id);
            $currencyRate['rate'] =$currencyobj->getCurrencyRate();
            //获取前币种的汇率
			$currencyobj=new Currency($adb,$before_currency_id);
            $beforecurrencyRate['rate'] =$currencyobj->getCurrencyRate();
            if($num_rows > 0)
            {
                for($i = 0; $i < $num_rows; $i++)
                {
                    $fieldname[$i] = $adb->query_result($result,$i,'fieldname');
                }
            }
            //根据选择后的币种，获取币种对应账户
             crm_load_class_file('BankAccountSet','modules/BankAccountSet');
            $result=BankAccountSet::getBackAccount($currency_id);
            $rowCount = $adb->num_rows($result);
            for($i = 0; $i<$rowCount; $i++)
            {
                $bankid = $adb->query_result($result,$i,'bankaccountsetid');
                $bankname = $adb->query_result($result,$i,'accountname');
                $bankAccount[$i]=$bankid . '&'.$bankname;
                //editor:gyq data:201705015 reason:适配微信返回值格式
                $option[$i]['text'] = $bankname;
                $option[$i]['value'] = $bankid;
            }
			/*
			*edit: chj
			*date: 2020/8/27
			*reason: 换算率字段，默认根据单据的币种带出对应的换算率
			*/
            crm_load_class_file('ProductToolFields','include/ProductDetails');
			$conversion_rate_field = array();
            //BUG0056671收/付款单->页面设置，不带产品分录明细，选择源单切换单据头的币种时，本次收款金额没有换算
			$ProductToolFields = new ProductToolFields($module);
            if(isset($_REQUEST['sourcemodule'])){
                $ProductToolFields->setsourceModulesqlwhere($_REQUEST['sourcemodule']);
            }
			$moduleFieldInfo = $ProductToolFields->getModuleProductToolField($tabid, $languageType);
			if(!empty($moduleFieldInfo)){
				foreach ($moduleFieldInfo as $productToolField) {
				    //zkt 20230217 BUG0061644移动端 收款单-切换币种没有反应
				    if(is_array($productToolField))$productToolField = $productToolField[0];
					if($productToolField->getUIType() == 99){
						$conversion_rate_field[] = $productToolField->getColumnName();
					}
				}
			}
            if(!is_array($bankAccount))
            {
                $bankAccount=[];
            }
            if(!is_array($fieldname))
                $fieldname=[];
            if(!is_array($conversion_rate_field))
                $conversion_rate_field=[];


            $conversion_rate = array($beforecurrencyRate['rate'],$currencyRate['rate'],
            implode(',',$fieldname),implode('#,#',$bankAccount),implode(',',$conversion_rate_field));
            if(!empty($PlatformMC)&&$PlatformMC['type']=='weixin'){
                $conversion_rate_json =  array('fieldname'=>implode(',',$fieldname),'before_rate'=>$beforecurrencyRate['rate'],
                    'current_rate'=>$currencyRate['rate'],'option'=>$option);
                ConvertTojsonString(1,$conversion_rate_json,'');
            }else{
                echo '###SUCCESS###' . join('|',$conversion_rate);
                exit;
            }

        }
    }
    if(!empty($PlatformMC)&&$PlatformMC['type']=='weixin'){
        ConvertTojsonString(1,array(),'');
    }else{
        echo '###error###';
        exit;
    }

?>