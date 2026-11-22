<?php
    global $current_user,$adb;
    $currency_id = $_REQUEST['currency_id'];//选择后的币种ID
    $before_currency_id =  $_REQUEST['before_currency_id']; //选择前的币种ID
    //获取币种汇率
    if(isset($_REQUEST['getCurrencyCate']) && $_REQUEST['getCurrencyCate'] == true)
    {
        //获取后币种的汇率);
		$currencyobj=Currency::getInstance($adb,$currency_id);
		$currencyRate['rate'] = $currencyobj->getCurrencyRate();
        //获取前币种的汇率
		$currencyobj=Currency::getInstance($adb,$before_currency_id);
		$beforecurrencyRate['rate'] = $currencyobj->getCurrencyRate();
        echo '###SUCCESS###' . $beforecurrencyRate['rate'] . '|' . $currencyRate['rate'];
        exit;
    }
    //获取所有金额字段 和 币种汇率
    if(isset($_REQUEST['currency_id']) && isset($_REQUEST['return_module']))
    {
        $module = $_REQUEST['return_module'];
        require_once("modules/$module/$module.php");
        $focus = new $module();
        $queryGenerator = new QueryGenerator($module, $current_user,'');
        $meta = $queryGenerator->getMeta($queryGenerator->getModule());
  		$moduleFields = $meta->getModuleFields();
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
			$currencyobj=Currency::getInstance($adb,$before_currency_id);
            $beforecurrencyRate['rate'] =$currencyobj->getCurrencyRate();
            if($num_rows > 0)
            {
                for($i = 0; $i < $num_rows; $i++)
                {
                    $fieldname[$i] = $adb->query_result($result,$i,'fieldname');
                }
            }
            //根据选择后的币种，获取币种对应账户
            
            $result=BankAccountSet::getBackAccount($currency_id);
            $rowCount = $adb->num_rows($result);
            for($i = 0; $i<$rowCount; $i++)
            {
                $bankid = $adb->query_result($result,$i,'bankaccountsetid');
                $bankname = $adb->query_result($result,$i,'accountname');
                $bankAccount[$i]=$bankid . '&'.$bankname;
            }
            $conversion_rate = array($beforecurrencyRate['rate'],$currencyRate['rate'],
            implode(',',$fieldname),implode(',',$bankAccount));
            echo '###SUCCESS###' . join('|',$conversion_rate);
            exit;
        }
    }
    echo '###error###';
    exit;

?>