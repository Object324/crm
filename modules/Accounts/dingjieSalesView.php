<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT159 新帆项目：鼎捷订单接口
 * @author Tujt 2015-01-06
 */
include './user_privileges/dingjie.inc.php';// 配置文件
include './mssql/SqlServer.php';
//Sql Server登录信息
$user = $conf['db']['user'];
$pwd = $conf['db']['pwd'];
$hostname = $conf['db']['host'];
$databasename = $conf['db']['db'];
//链接Sql Server数据库
$sqlcon = new SqlServer($user,$pwd,$databasename,$hostname);
$conResult = $sqlcon->Connect();
if(isset($_REQUEST['mode']) && 'edit' == $_REQUEST['mode']){//Ajax执行
	$updatefld = Input('updatefld');
	$updateval = Input('updateval');
	$fldkey = Input('fldkey');
	$fldval = Input('fldval');
	$accountname = Input('accountname');
	$fldval = convert2gbk($fldval);
	$salestype = Input('salestype');
	$accountname = convert2gbk($accountname);
	switch($updatefld){
	    case 'COPTD.UDF59'://产品、特殊成本
			$query = 'update COPTD set UDF59 = \''.$updateval.'\' where TD002 = \''.$fldval.'\' and TD001 = \''.$salestype.'\' and TD003 = \''.$_REQUEST['prodid'].'\' ';
	        break;
	    case 'COPTD.UDF58'://产品、特殊税率
	        $query = 'update COPTD set UDF58 = \''.$updateval.'\' where TD002 = \''.$fldval.'\' and TD001 = \''.$salestype.'\' and TD003 = \''.$_REQUEST['prodid'].'\' ';
	        break;
		case 'UDF57'://合同订单、杂费金额
	        $query = 'update COPTC set COPTC.UDF57 = \''.$updateval.'\' 
						from COPTC LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001 
						 where
						'.$fldkey.' = \''.$fldval.'\' and (
							COPMA.MA002 = \''.$accountname.'\' 
							or COPMA.MA003 = \''.$accountname.'\'
						);';
	        break;
		case 'UDF58'://合同订单、佣金金额
			$query = 'update COPTC set COPTC.UDF58 = \''.$updateval.'\' 
						from COPTC LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001 
						 where
						'.$fldkey.' = \''.$fldval.'\' and (
							COPMA.MA002 = \''.$accountname.'\' 
							or COPMA.MA003 = \''.$accountname.'\'
						);';
	        break;
		case 'tssl'://修改特殊税率
		    if('2201' == $salestype){//修改税率字段
				$query = 'update COPTD set TD037 = \''.$updateval.'\' where TD002 = \''.$fldval.'\' and TD001 = \''.$salestype.'\' and TD003 = \''.$_REQUEST['prodid'].'\' ';
			}else{//修改特殊税率字段
				$query = 'update COPTD set UDF58 = \''.$updateval.'\' where TD002 = \''.$fldval.'\' and TD001 = \''.$salestype.'\' and TD003 = \''.$_REQUEST['prodid'].'\' ';
			}
		    break;
	}
	$sqlcon->Query_result($query);die;
}
$fldkey = Input('fldkey');
$fldval = Input('fldval');
$salestype = Input('salestype');
$accountname = Input('accountname');
$urlfilter = 'fldkey='.$fldkey.'&fldval='.$fldval.'&accountname='.$accountname.'&salestype='.$salestype;
$fldval = convert2gbk($fldval);
$accountname = convert2gbk($accountname);
$query = 'SELECT COPTC.TC001 AS salestype,
			CMSMQ.MQ002 AS typename,
			COPTC.TC002,COPTC.TC002 AS salesorder_no,		
			CONVERT(VARCHAR,CAST(COPTC.TC003 AS DATETIME),23) AS salesdate,
			COPMA.MA001 AS account_no,
			COPMA.MA002 AS accountname,
			CMSME.ME001 AS group_no,
			CMSME.ME002 AS groupname,
			CMSMV.MV001 AS smownername,
			CMSMV.MV002 AS username,
			COPTC.TC027 AS approved,
			COPTC.TC040 AS approveby,
			COPTC.TC029 AS salesamount,
			COPTC.TC030 AS salestaxamount,
			COPTC.TC031 AS totalnum,
			COPTC.TCI03 AS salescurramount,
			COPTC.TCI04 AS salescurrtaxamount,
			CONVERT(VARCHAR,CAST(COPTC.TC039 AS DATETIME),23) AS TC039,
			CONVERT(VARCHAR,CAST(COPTC.TCI01 AS DATETIME),23) AS TCI01,
			CONVERT(VARCHAR,CAST(COPTC.TCI02 AS DATETIME),23) AS TCI02,
			COPTC.TC077,COPTC.TC007,COPTC.TC008,COPTC.TC009,COPTC.TC014,

			COPTC.TC012,COPTC.TC013,COPTC.TC016,COPTC.TC028,COPTC.TC070,
			COPTC.TC045,COPTC.TC068,COPTC.TC069,COPTC.TC071,
			COPTC.UDF57,COPTC.UDF58
		FROM COPTC 
			LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001 
			LEFT JOIN CMSMQ ON COPTC.TC001=CMSMQ.MQ001 
			LEFT JOIN CMSME ON COPTC.TC005=CMSME.ME001 
			LEFT JOIN CMSMV ON COPTC.TC006=CMSMV.MV001 
		WHERE '.$fldkey.' = \''.$fldval.'\' 
		and (COPMA.MA002 = \''.$accountname.'\' or COPMA.MA003 = \''.$accountname.'\') ';
$result = $sqlcon->Query_result($query);
$rows = $sqlcon->num_rows($result);
if(1 == $rows){
	$salesobj = $sqlcon->fetch_object($result);
}else{
	echo '###NO###';exit();
}
require_once('./Smarty_setup.php');
$smarty = new lingdangCRM_Smarty;
//基本信息
$detailarray = array(
	'salestype'=>'订单类别',
	'salesorder_no'=>'订单单号',
	'TC039'=>'单据日期',
	//'account_no'=>'客户编号',
	'accountname'=>'客户名称',
	'salesdate'=>'订单日期',
	'approveby'=>'审核者',
	'TCI01'=>'交货日期',
	'TCI02'=>'安装调试完成日期',
	'TC077'=>'项目编号'
);
//标签切换
$transaction = array(
	'交易信息(一)'=>array(
		'username'=>array('label'=>'业务人员','uitype'=>'string','mode'=>'view'),
		'group_no'=>array('label'=>'部门编号','uitype'=>'string','mode'=>'view'),
		'TC007'=>array('label'=>'出货工厂','uitype'=>'string','mode'=>'view'),
		'TC008'=>array('label'=>'交易币种','uitype'=>'string','mode'=>'view'),
		'TC009'=>array('label'=>'汇率','uitype'=>'amount','mode'=>'view'),
		'TC014'=>array('label'=>'付款条件','uitype'=>'string','mode'=>'view'),
		//''=>'是否传送',
		//''=>'是否存在附件',
		'TC012'=>array('label'=>'客户单号','uitype'=>'string','mode'=>'view'),
		'TC013'=>array('label'=>'价格说明','uitype'=>'string','mode'=>'view'),
		'TC016'=>array('label'=>'税种','uitype'=>'TaxType','mode'=>'view'),
		'TC028'=>array('label'=>'打印次数','uitype'=>'string','mode'=>'view'),
		'TC070'=>array('label'=>'超限放行','uitype'=>'string','mode'=>'view'),
		'TC045'=>array('label'=>'订金比率','uitype'=>'amount','mode'=>'view'),
		'TC068'=>array('label'=>'已开票金额','uitype'=>'string','mode'=>'view'),
		'TC069'=>array('label'=>'已开票税额','uitype'=>'string','mode'=>'view'),
		'TC071'=>array('label'=>'合同类型','uitype'=>'ContractType','mode'=>'view')
	),
	'交易信息(二)'=>array(
		'groupname'=>array('label'=>'部门名称','uitype'=>'string','mode'=>'view')
	),
	'费用信息'=>array(
		'UDF57'=>array('label'=>'杂费金额','uitype'=>'amount','mode'=>'edit'),
		'UDF58'=>array('label'=>'佣金金额','uitype'=>'amount','mode'=>'edit')
	)
);
$transactioncount = array('费用信息'=>'2');
$smarty->assign('TRANSACTIONCOUNT',$transactioncount);
//产品信息
$tssl = '(case COPTC.TC001 when \'2201\' then COPTD.TD037 else COPTD.UDF58 end) as tssl';
$productarray = array(
	'COPTD.TD003'=>array('fld'=>'TD003','head'=>'序号','uitype'=>'string','mode'=>'view'),
	'COPTD.TD004'=>array('fld'=>'TD004','head'=>'品号','uitype'=>'string','mode'=>'view'),
	'COPTD.TD005'=>array('fld'=>'TD005','head'=>'品名','uitype'=>'string','mode'=>'view'),
	'COPTD.TD013'=>array('fld'=>'TD013','head'=>'预交货日','uitype'=>'date','mode'=>'view'),
	'COPTD.TD006'=>array('fld'=>'TD006','head'=>'规格','uitype'=>'string','mode'=>'view'),
	'COPTD.TD007'=>array('fld'=>'TD007','head'=>'仓库编号','uitype'=>'string','mode'=>'view'),
	'CMSMC.MC002'=>array('fld'=>'MC002','head'=>'仓库名称','uitype'=>'string','mode'=>'view'),
	'COPTD.TD008'=>array('fld'=>'TD008','head'=>'订单数量','uitype'=>'number','mode'=>'view'),
	'COPTD.TD009'=>array('fld'=>'TD009','head'=>'已交数量','uitype'=>'number','mode'=>'view'),
	'COPTD.TD024'=>array('fld'=>'TD024','head'=>'赠品量','uitype'=>'number','mode'=>'view'),
	'COPTD.TD025'=>array('fld'=>'TD025','head'=>'赠品已交量','uitype'=>'number','mode'=>'view'),
	'COPTD.TD058'=>array('fld'=>'TD058','head'=>'借出未销数量','uitype'=>'number','mode'=>'view'),
	'COPTD.TD011'=>array('fld'=>'TD011','head'=>'单价','uitype'=>'amount','mode'=>'view'),
	//'COPTD.TD037'=>array('fld'=>'TD037','head'=>'税率','uitype'=>'amount','mode'=>'view'),
	'COPTD.TD038'=>array('fld'=>'TD038','head'=>'税前金额','uitype'=>'amount','mode'=>'view'),
	'COPTD.TD039'=>array('fld'=>'TD039','head'=>'税额','uitype'=>'amount','mode'=>'view'),
	'COPTD.TD026'=>array('fld'=>'TD026','head'=>'折扣率','uitype'=>'amount','mode'=>'view'),
	'COPTD.TD012'=>array('fld'=>'TD012','head'=>'金额','uitype'=>'amount','mode'=>'view'),
	'COPTD.UDF59'=>array('fld'=>'UDF59','head'=>'特殊成本','uitype'=>'amount','mode'=>'edit'),
	//'COPTD.UDF58'=>array('fld'=>'UDF58','head'=>'特殊税率','uitype'=>'amount','mode'=>'edit'),

	$tssl=>array('fld'=>'tssl','head'=>'税率','uitype'=>'amount','mode'=>'edit'),

	'COPTD.UDF01'=>array('fld'=>'UDF01','head'=>'包装方式','uitype'=>'string','mode'=>'view'),
	'COPTD.UDF02'=>array('fld'=>'UDF02','head'=>'序列号','uitype'=>'string','mode'=>'view'),
	'COPTD.UDF03'=>array('fld'=>'UDF03','head'=>'客户LOGO','uitype'=>'string','mode'=>'view'),
	'COPTD.UDF04'=>array('fld'=>'UDF04','head'=>'打标方式','uitype'=>'string','mode'=>'view'),
);
//权限控制 tujt 2015-06-30
global $current_user,$adb;
$query = 'SELECT dingjie_permit FROM ld_users where id = '.$current_user->id.' limit 1;';
$result = $adb->query($query);
$rows = $adb->num_rows($result);
$dingjie_permit = 0;
if(1 == $rows){
	$dingjie_permit = $adb->query_result($result,0,'dingjie_permit');
}
if(0 == $dingjie_permit){//没有权限
	$productarray['COPTD.UDF59']['mode'] = 'view';//特殊成本
	$productarray[$tssl]['mode'] = 'view';//税率
}
$productarraykey = array_keys($productarray);
$query = 'select '.join(',',$productarraykey).' 
			from COPTD
				LEFT JOIN COPTC ON COPTC.TC001 = COPTD.TD001 AND COPTC.TC002=COPTD.TD002
				LEFT JOIN CMSMC ON COPTD.TD007 = CMSMC.MC001
			WHERE COPTD.TD002 = \''.$fldval.'\' AND COPTD.TD001 = \''.$salestype.'\' ';
$result = $sqlcon->Query_result($query);
$rows = $sqlcon->num_rows($result);
$productobj = array();
if($rows > 0){
	for($i=0;$i<$rows;++ $i){
	    $productobj[] = $sqlcon->fetch_object($result);
	}
}
$smarty->assign('SALESOBJ',$salesobj);
$smarty->assign('DETAILARRAY',$detailarray);
$smarty->assign('TRANSACTION',$transaction);
$smarty->assign('TRANSACTIONKEYS',array_keys($transaction));
$smarty->assign('PRODUCTOBJ',$productobj);
$smarty->assign('display_index',$_REQUEST['display_index']);
$smarty->assign('PRODUCTARRAY',$productarray);
$smarty->assign('FLDVAL',$fldval);
$smarty->assign('COLUMN',3);
$smarty->assign('LBL_EDIT','编辑');
$smarty->assign('LBL_SAVE','保存');
$smarty->assign('LBL_CANCEL','取消');
$smarty->assign('URLFILTER',$urlfilter);

echo "###SUCCESS###";
$smarty->display('DetailView/dingjieSalesView.tpl');
/**
 * 从sql server取出来的数据，需要转一下码
 * @project PROT159 新帆项目：鼎捷订单接口
 * @author Tujt 2015-01-06
 */
function setItemCode($item,$uitype='') {
	if(empty($item)) return '';
	$item = iconv('GBK','UTF-8',$item);
	if(!empty($uitype)){
		switch($uitype){
			case 'number':
				$item = setNumberFormat($item);
				break;
			case 'amount':
				$item = setNumberFormat($item);
				break;
			case 'rate':
				$item = $item*100;$item .= '%';
				break;
			case 'date':
			    $item = date('Y-m-d',strtotime($item));
			    break;
			case 'TaxType':
			    if(!empty($item)){
					$taxtypearr = array('1'=>'内含','2'=>'外加','3'=>'零税率','4'=>'免税','5'=>'不计税');
					$item = $taxtypearr[$item];
				}
			    break;
			case 'ContractType':
			    if(!empty($item)){
					$contracttypearr = array('0'=>'无','1'=>'数量合同','2'=>'价值合同','3'=>'标准合同');
					$item = $contracttypearr[$item];
				}
			    break;
		}
	}
    return $item;
}
exit();
?>