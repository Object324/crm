<?php
	
	crm_load_class_file('cls_Report_Sql','modules/Customreport');
	//金蝶凭证类
	Class cls_SaveVoucher{
		
		private $conSql;
		private $operation;

		public function __construct($voucherdate, $singleuserid,$mer_type,$startdate,$enddate){
			//默认凭证字
			$this->vouchergroup_fname = '付';
			//费用凭证类型
			$this->FInternalInd = '';
			//制单人
			$this->singleuserid = $singleuserid;
			//业务日期、凭证日期
			$this->voucherdate = $voucherdate;
			//凭证日期 - 年
			$this->voucherdate_year = date('Y',strtotime($voucherdate));
			//凭证日期 - 月
			$this->voucherdate_month = date('m',strtotime($voucherdate));
			//费用MER类型
			if(strtolower($mer_type) == 'indirect'){
				$this->mertype = 'MER INDIRECT';
			}else{
				$this->mertype = 'MER DIRECT';
			}
			$this->mer_type = $mer_type;
			//开始日期
			$this->startdate = $startdate;
			//结束日期
			$this->enddate = $enddate;
			//核算项目编码字段
			$this->T_ITemdetail_field = 'F3001';
			$this->conSqlserver();
			//贷方科目
			$this->lender_no = '2171.99';
		}
		
		//保存插入
		public function save($mode=''){
			//凭证字
			$VchGroup = $this->getVoucherGroupId();
			//凭证号
			$VchNum = $this->getVoucherNumber($VchGroup);
			//序列号
			$FSerialNum = $this->getVoucherSerialNum();
			//获取汇总表信息
			$VouchEntry = $this->getVouchEntry();
			//获取汇总表明细信息
			$voucherdetails = $this->getVoucherDetails();
			//获取UUID
			$uuid = $this->getGuid();
			if(empty($mode)){
				$mode = 'create';
			}
			$this->operation = $mode;
			if(!empty($VouchEntry)){
				$date_time = date('Y-m-d H:i:s');
				if($mode == 'update'){
					//删除原先凭证数据
					$query = 'SELECT FVoucherID FROM t_Voucher WHERE FYear=\''.$this->voucherdate_year.'\' AND FPeriod=\''.$this->voucherdate_month.'\' AND FGroupID=\''.$VchGroup.'\' 
					AND FExplanation = \''.$this->mertype.'\'';
					$result = $this->conSql->Query_result($query);
					$count = 1;
					while ($row = $this->conSql->fetch_all($result,$count)){
						$row=$this->conSql->fetch_all($result,$count);
						$data[] =  iconv("gb2312","UTF-8",$row['FVoucherID']);
						$count++;
					}
					foreach($data as $voucherid){
						$query = 'delete from t_voucher where fvoucherid = \''.$voucherid.'\'';
						$this->conSql->query($query);
						$query = 'delete from t_VoucherEntry where fvoucherid = \''.$voucherid.'\'';
						$this->conSql->query($query);
					}
				}
				foreach($VouchEntry as $expenseid => $VouchInfo){
					//FParameter : FYGL_ExpenseApply|FVoucherID,FVchBillNo#
					//凭证列表
					$insert_query = 'insert into t_voucher(
						FDate,FYear,FPeriod,FGroupID,FNumber,FReference,FExplanation,FAttachments,FEntryCount,FDebitTotal,FCreditTotal,
						FInternalInd,FChecked,FPosted,FPreparerID,FCheckerID,FPosterID,FCashierID,FHandler,FOwnerGroupID,FObjectName,
						FParameter,FSerialNum,FTranType,FTransDate,FFrameWorkID,FApproveID,FFootNote,UUID)
							values 
						( \''.$this->voucherdate.'\',\''.$this->voucherdate_year.'\',\''.$this->voucherdate_month.'\',\''.$VchGroup.'\',\''.$VchNum.'\',NULL,\''.$this->mertype.'\',0,\''.$VouchInfo['FEntryCount'].'\',\''.$VouchInfo['VchAmount'].'\',\''.$VouchInfo['VchAmount'].'\' ,
						\''.$this->FInternalInd.'\',0,0,\''.$this->singleuserid.'\',-1,-1,-1,NULL,0,NULL,
						NULL,\''.$FSerialNum.'\',0,\''.$date_time.'\',-1,-1,\'\','.$uuid.')';
					$this->conSql->query($insert_query);
					//获取最新插入的凭证ID,t_voucher  
					$query = 'SELECT FVoucherID FROM t_Voucher WHERE FYear=\''.$this->voucherdate_year.'\' AND FPeriod=\''.$this->voucherdate_month.'\' AND FGroupID=\''.$VchGroup.'\' AND FNumber=\''.$VchNum.'\'';
					$result = $this->conSql->Query_result($query);
					$row=$this->conSql->fetch_row($result);
					$FvoucherID = $row[0];
					$FDetailID = 0;
					//得到核算项目T_Item.FItemID
					if(!empty($VouchInfo['po_no'])){
						$query = 'SELECT FItemID FROM dbo.t_Item WHERE FName=\''.$VouchInfo['po_no'].'\'';
						$result = $this->conSql->Query_result($query);
						$row=$this->conSql->fetch_row($result);
						$FItemID = $row[0];
						if($FItemID > 0){
							//获取借方核算项目内码 T_ItemDetail.FDetailID
							$query = 'SELECT FDetailID FROM T_ITemdetail where '.$this->T_ITemdetail_field.' = \''.$FItemID.'\'';
							$result = $this->conSql->Query_result($query);
							$row=$this->conSql->fetch_row($result);
							$FDetailID = $row[0];
						}
					}
					//FAccountID 科目代码 (借方)
					for($i = 0; $i < $VouchInfo['FEntryCount']; $i++){
						$insert_detail_query = 'insert into t_VoucherEntry(FvoucherID,FEntryID,FExplanation,FAccountID,FDetailID,FCurrencyID,FExchangeRate,FDC,FAmountFor,FAmount,FQuantity,FMeasureUnitID,FUnitPrice,
						FInternalInd,FAccountID2,FSettleTypeID,FSettleNo,FTransNo,FCashFlowItem,FTaskID,FResourceID,FExchangeRateType,FSideEntryID)
							values
						(\''.$FvoucherID.'\','.$i.',\''.$this->mertype.'\',\''.$voucherdetails[$expenseid][$i]['code'].'\',\''.$FDetailID.'\',1,\'1.0\',1,\''.$voucherdetails[$expenseid][$i]['VchAmount'].'\',\''.$voucherdetails[$expenseid][$i]['VchAmount'].'\',0,0,0,
						NULL,0,0,NULL,NULL,0,0,0,1,'.$i.')';
						$this->conSql->query($insert_detail_query);
					}
					//贷方
					if($VouchInfo['FEntryCount'] >= 1){
						$lender_code = $this->getAccountNumber($this->lender_no);
						$insert_detail_query = 'insert into t_VoucherEntry(FvoucherID,FEntryID,FExplanation,FAccountID,FDetailID,FCurrencyID,FExchangeRate,FDC,FAmountFor,FAmount,FQuantity,FMeasureUnitID,FUnitPrice,
							FInternalInd,FAccountID2,FSettleTypeID,FSettleNo,FTransNo,FCashFlowItem,FTaskID,FResourceID,FExchangeRateType,FSideEntryID)
								values
							(\''.$FvoucherID.'\','.$i.',\''.$this->mertype.'\',\''.$lender_code.'\',\''.$FDetailID.'\',1,\'1.0\',0,\''.$VouchInfo['VchAmount'].'\',\''.$VouchInfo['VchAmount'].'\',0,0,0,
							NULL,0,0,NULL,NULL,0,0,0,1,'.$i.')';
						$this->conSql->query($insert_detail_query);
					}
					$VchNum++;
				}
				
				//保存凭证日志
				$this->saveVoucherLog();
			}
		}
		
		//获取汇总表信息
		private function getVouchEntry(){
			global $adb;
			if('Direct' == $this->mer_type){
				$query = cls_Report_Sql::getDriectProjectSummaryReport();
				$result = $adb->pquery($query,array($this->startdate,$this->enddate));
			}else{
				$query = cls_Report_Sql::getInDriectProjectSummaryReport();
				$result = $adb->pquery($query,array($this->startdate,$this->enddate,$this->startdate,$this->enddate));
			}
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				if('Direct' == $this->mer_type){
					$key = $adb->query_result($result,$i,'po_no');
				}else{
					$key = $adb->query_result($result,$i,'expenseid');
				}
				$data[$key]['FEntryCount'] = $adb->query_result($result,$i,'cnt');
				$data[$key]['VchAmount'] = $adb->query_result($result,$i,'rmb_tota');
				$data[$key]['po_no'] = $adb->query_result($result,$i,'po_no');
			}
			return $data;
		}
		
		//获取汇总表明细信息
		private function getVoucherDetails(){
			global $adb;
			$code = '';
			if('Direct' == $this->mer_type){
				$query = cls_Report_Sql::getDirectReportDetail();
				$result = $adb->pquery($query,array($this->startdate,$this->enddate));
				
			}else{
				$query = cls_Report_Sql::getInDirectReportDetail();
				$result = $adb->pquery($query,array($this->startdate,$this->enddate,$this->startdate,$this->enddate));
			}
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				if('Direct' == $this->mer_type){
					$key = $adb->query_result($result,$i,'po_no');
				}else{
					$key = $adb->query_result($result,$i,'expenseid');
				}
				$subjectcode = $adb->query_result($result,$i,'subjectcode');
				if($i == 0){
					$code = $this->getAccountNumber($subjectcode);
				}
				$expense_data[$key][$i]['code'] = $code;
				$expense_data[$key][$i]['VchAmount'] = $adb->query_result($result,$i,'rmb_tota');
			}
			foreach($expense_data as $key => $infos){
				$data[$key] = array_values($infos);
			}
			return $data;
		}

		//获取科目代码id
		private function getAccountNumber($subjectcode){
			$query = 'select faccountid from t_account where fnumber =  \''.$subjectcode.'\'';
			$result = $this->conSql->Query_result($query);
			$row=$this->conSql->fetch_row($result);
			return $row[0];
		}
		//获取凭证字
		private function getVoucherGroupId(){
			if(!empty($this->vouchergroup_fname)){
				$query = 'SELECT  t1.FGroupID  FROM t_VoucherGroup t1 WHERE t1.FGroupID <> 0 And t1.FDeleted = 0 And FName = \''.$this->vouchergroup_fname.'\'';
				$result = $this->conSql->Query_result($query);
				$row=$this->conSql->fetch_row($result);
				return $row[0];
			}
		}

		//获取凭证号
		private function getVoucherNumber($VchGroup){
			//如果每个月只能同步一次凭证的话，可以写成1
			$query = 'Select FNumber From (select FNumber,FYear,FPeriod,FGroupID from t_Voucher Union all select FNumber,FYear,FPeriod,FGroupID from t_VoucherBlankout) a 
			Where FYear=\''.$this->voucherdate_year.'\' AND FPeriod=\''.$this->voucherdate_month.'\' and FGroupID =\''.$VchGroup.'\' Order By FNumber desc';
			$result = $this->conSql->Query_result($query);
			$data=$this->conSql->fetch_row($result);
			if(empty($data[0])){
				return 1;
			}else{
				return $data[0]+1;
			}
		}

		//获取序列号
		private function getVoucherSerialNum(){
			$query = 'SELECT MAX(FSerialNum) FROM (select * from t_Voucher union all select * from t_VoucherBlankout union all select * from t_VoucherAdjust) v Where FYear=\''.$this->voucherdate_year.'\'';
			$result = $this->conSql->Query_result($query);
			$data=$this->conSql->fetch_row($result);
			if(empty($data[0])){
				return 1;
			}else{
				return $data[0];
			}
		}

		//获取sqlserver连接对象
		private function conSqlserver(){
			$sa=getDatainterface('sa');	//获取DB用户名
			$pwd=getDatainterface('pwd');//获取DB密码
			$hostname=getDatainterface('hostname');//获取服务器IP地址
			$databasename=getDatainterface('databasename');//获取DB name
			$con = conSqlserver($hostname,$sa,$pwd,$databasename);
			if($con['conResult'] == 1){
				$this->conSql = $con['sqlcon'];
			}
		}

		//生成GUID
		function getGuid(){
			if (function_exists('com_create_guid')){
				$uuid = com_create_guid();
				$uuid=str_replace("{","'",$uuid);
				$uuid=str_replace("}","'",$uuid);
				return $uuid;
			}else{
				mt_srand((double)microtime()*10000);//optional for php 4.2.0 and up.
				$charid = strtoupper(md5(uniqid(rand(), true)));
				$hyphen = chr(45);// "-"
				$uuid = chr(123)// "{"
						.substr($charid, 0, 8).$hyphen
						.substr($charid, 8, 4).$hyphen
						.substr($charid,12, 4).$hyphen
						.substr($charid,16, 4).$hyphen
						.substr($charid,20,12)
						.chr(125);// "}"
				$uuid=str_replace("{","'",$uuid);
				$uuid=str_replace("}","'",$uuid);
				return $uuid;
			}
		}
		
		//生成凭证日志
		private function saveVoucherLog(){
			global $adb,$current_user;
			if(!empty($this->voucherdate) && !empty($this->singleuserid)){
				$query = 'INSERT INTO ld_voucher_log(voucher_date,voucher_type,createdtime,voucher_userid,userid,startdate,enddate,operation)VALUES(?,?,?,?,?,?,?,?)';
				$adb->pquery($query,array($this->voucherdate,$this->mer_type,date('Y-m-d h:i:s'),$this->singleuserid,$current_user->id,$this->startdate,$this->enddate,$this->operation));
			}
		}
	}


?>