<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	class cls_duizhang_kingdee{
		
		public function __construct()
		{
			$this->erp_dbname = 'AIS20200215141204';
			$this->erp_dbuser = 'sa';
			$this->erp_dbpswd = 'langjie@123';
			$this->erp_dbhost = '127.0.0.1';
			$con_erp_db = $this->setConnentErpDb();
			$this->db = $con_erp_db['sqlcon'];
			//$this->db = $this->db->conn;
			//$result=$SqlCon->Query_result($query);
			//$num_rows = $SqlCon->num_rows($result);
			//$row=$SqlCon->fetch_all($result,$i);
		}

		public function save($data){
			/*echo 123;
			echo '<pre>';
			print_r($data);
			echo '</pre>';
			die;*/
			if(!empty($_REQUEST['baoguan_leixing']) && ($_REQUEST['baoguan_leixing'] == 'account' || $_REQUEST['baoguan_leixing'] == 'vendor')){
				if(!empty($data)){
					$accountorvendor_array = array();
					foreach($data['list'] as $info){
						if(!empty($info['accountorvendor'])){
							$accountorvendor_array[$info['accountorvendor']] = $info;
						}
					}
					foreach($data['total'] as $accountname => $info){
						//if($accountname != '天津力神电池股份有限公司')continue;
						if(!empty($info['weishui_amount_tax0']) && !empty($info['hanshui_amount_tax0'])){
							if($_REQUEST['baoguan_leixing'] == 'account')
								$this->insertICSale($accountorvendor_array[$accountname],$info['weishui_amount_tax0'],$info['hanshui_amount_tax0'],0,$data['billids']);
							else
								$this->insertICPurchase($accountorvendor_array[$accountname],$info['weishui_amount_tax0'],$info['hanshui_amount_tax0'],0,$data['billids']);
						}						
						if(!empty($info['weishui_amount_tax6']) && !empty($info['hanshui_amount_tax6'])){
							if($_REQUEST['baoguan_leixing'] == 'account')
								$this->insertICSale($accountorvendor_array[$accountname],$info['weishui_amount_tax6'],$info['hanshui_amount_tax6'],6,$data['billids']);
							else
								$this->insertICPurchase($accountorvendor_array[$accountname],$info['weishui_amount_tax6'],$info['hanshui_amount_tax6'],6,$data['billids']);
						}
						if(!empty($info['weishui_amount_tax9']) && !empty($info['hanshui_amount_tax9'])){
							if($_REQUEST['baoguan_leixing'] == 'account')
								$this->insertICSale($accountorvendor_array[$accountname],$info['weishui_amount_tax9'],$info['hanshui_amount_tax9'],9,$data['billids']);
							else
								$this->insertICPurchase($accountorvendor_array[$accountname],$info['weishui_amount_tax9'],$info['hanshui_amount_tax9'],9,$data['billids']);
						}
						if(!empty($info['weishui_amount_tax1']) && !empty($info['hanshui_amount_tax1'])){
							if($_REQUEST['baoguan_leixing'] == 'account')
								$this->insertICSale($accountorvendor_array[$accountname],$info['weishui_amount_tax1'],$info['hanshui_amount_tax1'],0,$data['billids']);
							else
								$this->insertICPurchase($accountorvendor_array[$accountname],$info['weishui_amount_tax1'],$info['hanshui_amount_tax1'],0,$data['billids']);
						}
					}
				}
			}
			//die;
		}
		//获取单据的最大ID
		public function getLastInsertId($db_tablename){
			$query = "select max(finterid) as finterid from ".$db_tablename."";
			$result=$this->db->Query_result($query);
			$row = $this->db->fetch_one($result);
			return $row['finterid'] + 1;
		}
		
		//获取单据的最大的编号
		public function getMaxFbillNO($db_tablename){
			$query = "select max(FBillNo) as FBillNo from ".$db_tablename."";
			$result=$this->db->Query_result($query);
			$row = $this->db->fetch_one($result);
			$rows = explode('XSPP',$row['FBillNo']);
			$num = (int)$rows[1] + 1;
			$number = 1000000+$num;
			$str_number = 'XSPP'.ltrim($number,'1');
			return array('id'=>$num,'number'=>$str_number);
		}
		//获取单据的最大的编号
		public function getMaxFbillNOIC($db_tablename){
			$query = "select max(FBillNo) as FBillNo from ".$db_tablename."";
			$result=$this->db->Query_result($query);
			$row = $this->db->fetch_one($result);
			$rows = explode('CGPP',$row['FBillNo']);
			$num = (int)$rows[1] + 1;
			$number = 1000000+$num;
			$str_number = 'CGPP'.ltrim($number,'1');
			return array('id'=>$num,'number'=>$str_number);
		}
		
		public function getAccountUser($accountname){
			global $adb;
			$query = 'select last_name from ld_account LEFT JOIN ld_users on ld_users.id = ld_account.smownerid where accountname = ? and ld_account.deleted = 0';
			$result = $adb->pquery($query,array($accountname));
			$last_name = $adb->query_result($result,0,0);
			return $last_name;
			//return '所属客服人员：' . $last_name;
			
		}
		
		public function getVendorUser($vendorname){
			global $adb;
			$query = 'select last_name from ld_vendor LEFT JOIN ld_users on ld_users.id = ld_vendor.smownerid where vendorname = ? and ld_vendor.deleted = 0';
			$result = $adb->pquery($query,array($vendorname));
			$last_name = $adb->query_result($result,0,0);
			return $last_name;
			//return '所属管理人员：' . $last_name;
			
		}
		
		//获取业务员在金蝶中对应的ID
		public function getErpUser($last_name){
			$query = "select FItemID from t_Emp where fname = '".$this->convert2gbk($last_name)."'";
			$result=$this->db->Query_result($query);
			$row = $this->db->fetch_one($result);
			return $row['FItemID'];
		}
		//根据业务员的id获取对应的部门
		public function getDepartmentId($FItemID){
			$query = "select FDepartmentID from t_Emp where FItemID = $FItemID";
			$result=$this->db->Query_result($query);
			$row = $this->db->fetch_one($result);
			return $row['FDepartmentID'];
		}
		public function insertICSale2($data,$weishui_amount,$hanshui_amount,$shui,$billids){
			$hanshui_amount = str_replace(',', '', $hanshui_amount);
			$weishui_amount = str_replace(',', '', $weishui_amount);
			if($hanshui_amount >0 || $weishui_amount > 0){
				echo $weishui_amount . '==='.$hanshui_amount . '<br>';
			}
				
		}
		//销售普通发票
		public function insertICSale($data,$weishui_amount,$hanshui_amount,$shui,$billids){
			global $current_user;
			$hanshui_amount = str_replace(',', '', $hanshui_amount);
			$weishui_amount = str_replace(',', '', $weishui_amount);
			if($hanshui_amount >0 || $weishui_amount > 0){
				$finterid = $this->getLastInsertId('ICSale');
				$fbillno_array = $this->getMaxFbillNO('ICSale');
				$fbillno = $fbillno_array['number'];
				$max_billno_id = $fbillno_array['id'];
				$fcustid = $this->getOrgId($data['accountorvendor']);
				//$smower_name = $this->getAccountUser($data['accountorvendor']);
				$smower_name = $current_user->last_name; 
				//echo $smower_name;die;
				
				$fempid = $this->getErpUser($smower_name);
				$FDeptID = 0;
				if(!empty($fempid)){
					$FDeptID = $this->getDepartmentId($fempid);
				}
				//echo $fempid .'===';die;
				if(empty($fempid))$fempid = 0;
				$fote = '';
				$date = date('Y-m-d');
				$date_array = explode('-',$date);
				if($shui == 6){
					$FItemID = 301;
				}else if($shui == 9){
					$FItemID = 302;
				}else{
					$FItemID = 303;
				}
				if(empty($weishui_amount))$weishui_amount = 0;
				$chajia = $hanshui_amount - $weishui_amount;
				$query = "INSERT INTO ICSale(FInterID,FBillNo,FItemClassID,FCustID,FClassTypeID,FDate,FFincDate,FCurrencyID,FAdjustExchangeRate,FExchangeRate,FYtdIntRate,FTaxNum,
				FSaleStyle,FCussentAcctID,FSettleID,FNote,FCompactNo,FTaskID,FResourceID,FBudgetAmountFor,FOrderID,FFreeItem3,FROB,FTranType,FFreeItem4,FArApStatus,FAdjustAmount,
				FYear,FDeptID,FPeriod,FEmpID,FSubSystemID,FBillerID,FCheckerID,FAddress,FAccount,FHookerID,FBank,FCheckAmountFor,FCheckAmount,FRemainAmountFor,
				FRemainAmount,FCheckDate,FSysStatus) Values($finterid,'".$fbillno."',1,$fcustid,1000000,'".$date."','".$date."',1,1,1,0,'',101,1018,0,'".$this->convert2gbk($fote)."','',0,0,0,0,'',
				'1','601','',0,0,".$date_array[0].",$FDeptID,".$date_array[1].",$fempid,'1',16399,0,'','',0,'',0,0,0,0,NULL,2)";
				
				$this->db->Query_result($query);

				$query = "INSERT INTO t_RP_Plan_Ar(FEntryID,FInterID,fdate,FAmountFor,FOrgID,FAmount,FRemainAmount,FRemainAmountFor,FRP) Values(1,$finterid,'".$date."',$hanshui_amount,$fcustid,$hanshui_amount,$hanshui_amount,$hanshui_amount,1)";
				$this->db->Query_result($query);

				$query = "INSERT INTO ICSaleEntry(FItemID,FEntryID,FInterID,FAuxPropID,FUnitID,FAuxQty,FQuantityPayApply_Commit,FQuantityReceive_Commit,FSecUnitID,FsecCoefficient,FSecQty,FAuxTaxPrice,FAuxPrice,
				FDiscountRate,FSourceInterId,fauxpricediscount,FAmtDiscount,FStdAmtDiscount,FAmount,FPrice,FTaxPrice,FStdAmount,FContractEntryID,FEntryID_SRC,FTaxRate,FOrderEntryID,FOrderInterID,FTaxAmount,FFreeItem3,
				FFreeItem4,FStdTaxAmount,FAmountIncludeTax,FStdAmountIncludeTax,FNote,FBatchNo,FQty,FClassID_SRC,FSourceBillNo,FContractBillNo,FLinkCheckAmountFor,FOrderBillNo,FCheckAmountFor,FLinkCheckAmount,FCheckAmount,
				FRemainAmountFor,FLinkCheckQty,FRemainAmount,FCheckQty,FRemainQty,FAmountFor_Commit,FAmount_Commit,FInvLinkCheckAmount,FInvLinkCheckAmountFor,FInvLinkCheckQty,FInvoiceAmount,FInvoiceAmountFor,FInvoiceQty,
				FSourceTranType,FOnLineOrderNo) Values($FItemID,1,$finterid,0,300,1,0,0,0,0,0,$hanshui_amount,$weishui_amount,0,0,$hanshui_amount,0,0,$hanshui_amount,$weishui_amount,$hanshui_amount,$hanshui_amount,
				0,0,".$shui.",0,0,$chajia,'','',$chajia,$weishui_amount,$weishui_amount,'','',1,0,'','',0,'',0,0,0,$hanshui_amount,0,$hanshui_amount,0,1,0,0,0,0,0,0,0,0,'','')";
				//echo $query;die;
				$this->db->Query_result($query);

				$query = "INSERT INTO t_RP_Contact (FYear,FPeriod,FRP,FType,FDate,FFincDate,FNumber,FCustomer,FDepartment,FEmployee,FCurrencyID,FExchangeRate,FAmount,FAmountFor,FRemainAmount,FRemainAmountFor,
				FInvoiceID,FRPDate,FContractNo,FInterestRate,FItemClassID,FExplanation,FPreparer) 
				VALUES (".$date_array[0].",".$date_array[1].",1,3,'".$date."','".$date."','".$fbillno."',$fcustid,0,0,1,1,$$hanshui_amount,$$hanshui_amount,$$hanshui_amount,$$hanshui_amount,$finterid,'$date','',0,1,'',16399)";
				$this->db->Query_result($query);
				
				$query = "Update icmaxnum set Fmaxnum=".$finterid." where Ftablename='ICSale'";
				$this->db->Query_result($query);

				$query = "update IC_MaxNum set FFlag=1  where FTableName='ICSale' and FFlag=0";
				$this->db->Query_result($query);
				
				$query = "update t_BillCodeRule set FProjectVal = $max_billno_id + 1 where FBillTypeID = 1000000 and FClassIndex = 2";
				$this->db->Query_result($query);
				global $adb;
				$update = 'update ld_customform18 set kis_id = ? where customform18id in('.implode(',',$billids).') and deleted = 0';
				$adb->pquery($update,array($finterid));
			}
			
		}
		
		//采购普通发票
		public function insertICPurchase($data,$weishui_amount,$hanshui_amount,$shui,$billids){
			//$weishui_amount = 100;
			//$hanshui_amount = 100;
			$hanshui_amount = str_replace(',', '', $hanshui_amount);
			$weishui_amount = str_replace(',', '', $weishui_amount);
			if($hanshui_amount >0 || $weishui_amount > 0){
				global $current_user;
				$finterid = $this->getLastInsertId('ICPurchase');
				$fbillno_array = $this->getMaxFbillNOIC('ICPurchase');
				$fbillno = $fbillno_array['number'];
				$max_billno_id = $fbillno_array['id'];
				$FSupplyID = $this->getSupperId($data['accountorvendor']);
				
				//$FSupplyID = 359;
				//$smower_name = $this->getVendorUser($data['accountorvendor']);
				$smower_name = $current_user->last_name; 
				$fempid = $this->getErpUser($smower_name);
				if(empty($fempid))$fempid = 0;
				$FDeptID = 0;
				if(!empty($fempid)){
					$FDeptID = $this->getDepartmentId($fempid);
				}
				
				$fote = '';
				$date = date('Y-m-d');
				$date_array = explode('-',$date);
				$FItemID = 306;
				if(empty($weishui_amount))$weishui_amount = 0;
				$chajia = $hanshui_amount - $weishui_amount;
				$query = "INSERT INTO ICPurchase(FInterID,FBillNo,FItemClassID,FSupplyID,FClassTypeID,FDate,FFincDate,FCurrencyID,FAdjustExchangeRate,FExchangeRate,FYtdIntRate,FCussentAcctID,FPOStyle,FResourceID,
				FTaskID,FBudgetAmountFor,FOrderID,FNote,FCompactNo,FTotalExpenseFor,FTotalExpense,FOffsetTaxFor,FOffsetTax,FTotalCostFor,FFreeItem3,FROB,FTranType,FFreeItem4,FTotalCost,FArApStatus,FDeptID,FAdjustAmount,
				FEmpID,FYear,FBillerID,FPeriod,FBillerName,FSubSystemID,FCheckerID,FHookerID,FAddress,FTaxNum,FAccount,FCheckAmountFor,FCheckAmount,FRemainAmountFor,FRemainAmount,FCheckDate,FBank,FSysStatus) 
				Values($finterid,'".$fbillno."',8,$FSupplyID,1000003,'".$date."','".$date."',1,1,1,0,1086,252,0,0,0,0,'".$this->convert2gbk($fote)."','',0,0,0,0,$hanshui_amount,'','1','603',
				'',$hanshui_amount,0,$FDeptID,0,$fempid,".$date_array[0].",16399,".$date_array[1].",'','1',0,0,'','','',0,0,0,0,NULL,'',2)";
				//echo $query;die;
				$this->db->Query_result($query);

				$query = "INSERT INTO t_RP_Plan_Ap(FEntryID,FInterID,fdate,FAmountFor,FOrgID,FAmount,FRemainAmount,FRemainAmountFor,FRP) 
				Values(1,$finterid,'".$date."',$hanshui_amount,0,$hanshui_amount,$hanshui_amount,$hanshui_amount,0)";
				$this->db->Query_result($query);

				$query = "INSERT INTO ICPurchaseEntry(FItemID,FEntryID,FInterID,FAuxPropID,FUnitID,FAuxQty,FQuantityPayApply_Commit,FQuantityReceive_Commit,FSecUnitID,FsecCoefficient,FSecQty,FAuxPrice,FAuxTaxPrice,FDiscountRate,
				fauxpricediscount,FSourceInterId,FAmtDiscount,FStdAmtDiscount,FAmount,FStdAmount,FPrice,FQty,FTaxPrice,FTaxRate,FContractEntryID,FOrderInterID,FOrderEntryID,FEntryID_SRC,FTaxAmount,FFreeItem3,FFreeItem4,FStdTaxAmount,
				FAmountIncludeTax,FStdAmountIncludeTax,FAddCostFor,FAddCost,FNote,FLinkCheckAmountFor,FPayApplyAmountFor,FBatchNo,FLinkCheckAmount,FClassID_SRC,FPayApplyAmount,FLinkCheckQty,FSourceBillNo,FCheckAmountFor,FCheckAmount,
				FRemainAmountFor,FRemainAmount,FCheckQty,FOrderType,FRemainQty,FContractBillNo,FOrderBillNo,FAmountFor_Commit,FAmount_Commit,FInvLinkCheckAmount,FInvLinkCheckAmountFor,FInvLinkCheckQty,FInvoiceAmount,FInvoiceAmountFor,
				FInvoiceQty,FSourceTranType) Values($FItemID,1,$finterid,0,300,1,0,0,0,0,0,$hanshui_amount,$hanshui_amount,0,$hanshui_amount,0,0,0,$hanshui_amount,$hanshui_amount,$hanshui_amount,1,$hanshui_amount,
				0,0,0,0,0,0,'','',0,$hanshui_amount,$hanshui_amount,0,0,'',0,0,'',0,0,0,0,'',0,0,$hanshui_amount,$hanshui_amount,0,0,1,'','',0,0,0,0,0,0,0,0,'')";
				$this->db->Query_result($query);

				$query = "INSERT INTO t_RP_Contact (FYear,FPeriod,FRP,FType,FDate,FFincDate,FNumber,FCustomer,FDepartment,FEmployee,FCurrencyID,FExchangeRate,FAmount,FAmountFor,FRemainAmount,FRemainAmountFor,FInvoiceID,FRPDate,
				FContractNo,FInterestRate,FItemClassID,FExplanation,FPreparer) VALUES (".$date_array[0].",".$date_array[1].",0,4,'".$date."','".$date."','".$fbillno."',$FSupplyID,0,0,1,1,$hanshui_amount,$hanshui_amount,
				$hanshui_amount,$hanshui_amount,$finterid,'".$date."','',0,8,'',16399)";
				$this->db->Query_result($query);
				$query = "Update icmaxnum set Fmaxnum=".$finterid." where Ftablename='ICPurchase'";
				$this->db->Query_result($query);

				$query = "update IC_MaxNum set FFlag=1  where FTableName='ICPurchase' and FFlag=0";
				$this->db->Query_result($query);
				
				$query = "update t_BillCodeRule set FProjectVal = $max_billno_id + 1 where FBillTypeID = 1000003 and FClassIndex = 2";
				$this->db->Query_result($query);
				
				global $adb;
				$update = 'update ld_customform19 set kis_id = ? where customform19id in('.implode(',',$billids).') and deleted = 0';
				$adb->pquery($update,array($finterid));
				//exit(1111);
			}
		}

		public function convert2gbk($string) 
		{ 
			$encode = mb_detect_encoding($string, array("ASCII",'UTF-8',"GB2312","GBK",'BIG5'));
			if($encode == 'EUC-CN' || $encode == 'CP936')
				return $string;
			else
				return iconv("utf-8","gbk",decode_html($string)); 
		}

		public function convert2utf8($string) 
		{ 
			$encode = mb_detect_encoding($string, array("ASCII",'UTF-8',"GB2312","GBK",'BIG5'),true);
			if($encode == 'UTF-8')
				return $string;
			else
				return iconv("gbk","utf-8",decode_html($string)); 
		}
		
		public function getfirstchar($s0){   
			$fchar = ord($s0{0});
			if($fchar >= ord("A") and $fchar <= ord("z") )return strtoupper($s0{0});
			$s1 = iconv("UTF-8","gb2312", $s0);
			$s2 = iconv("gb2312","UTF-8", $s1);
			if($s2 == $s0){$s = $s1;}else{$s = $s0;}
			$asc = ord($s{0}) * 256 + ord($s{1}) - 65536;
			if($asc >= -20319 and $asc <= -20284) return "A";
			if($asc >= -20283 and $asc <= -19776) return "B";
			if($asc >= -19775 and $asc <= -19219) return "C";
			if($asc >= -19218 and $asc <= -18711) return "D";
			if($asc >= -18710 and $asc <= -18527) return "E";
			if($asc >= -18526 and $asc <= -18240) return "F";
			if($asc >= -18239 and $asc <= -17923) return "G";
			if($asc >= -17922 and $asc <= -17418) return "H";
			if($asc >= -17922 and $asc <= -17418) return "I";
			if($asc >= -17417 and $asc <= -16475) return "J";
			if($asc >= -16474 and $asc <= -16213) return "K";
			if($asc >= -16212 and $asc <= -15641) return "L";
			if($asc >= -15640 and $asc <= -15166) return "M";
			if($asc >= -15165 and $asc <= -14923) return "N";
			if($asc >= -14922 and $asc <= -14915) return "O";
			if($asc >= -14914 and $asc <= -14631) return "P";
			if($asc >= -14630 and $asc <= -14150) return "Q";
			if($asc >= -14149 and $asc <= -14091) return "R";
			if($asc >= -14090 and $asc <= -13319) return "S";
			if($asc >= -13318 and $asc <= -12839) return "T";
			if($asc >= -12838 and $asc <= -12557) return "W";
			if($asc >= -12556 and $asc <= -11848) return "X";
			if($asc >= -11847 and $asc <= -11056) return "Y";
			if($asc >= -11055 and $asc <= -10247) return "Z";
			return NULL;
			//return $s0;
		}
		public function pinyin_long($zh){  //获取整条字符串所有汉字拼音首字母
			$ret = "";
			$s1 = iconv("UTF-8","gb2312", $zh);
			$s2 = iconv("gb2312","UTF-8", $s1);
			if($s2 == $zh){$zh = $s1;}
			for($i = 0; $i < strlen($zh); $i++){
				$s1 = substr($zh,$i,1);
				$p = ord($s1);
				if($p > 160){
					$s2 = substr($zh,$i++,2);
					$ret .= $this->getfirstchar($s2);
				}else{
					$ret .= $s1;
				}
			}
			return $ret;
		}

		//客户
		public function getOrgId($accountname){
			global $adb;
			//$accountname = '上海铃铛2';
			$acc_name = $accountname;
			$accountname = $this->convert2gbk($accountname);
			$query = 'SELECT fitemid FROM t_Item where FName = \''.$accountname.'\' and FItemClassID = 1 and FDeleted = 0';
			$result=$this->db->Query_result($query);
			$num_rows = $this->db->num_rows($result);
			
			if($num_rows >= 1){
				$row=$this->db->fetch_all($result,0);
				return $row['fitemid'];
			}else{
				$uuid = $this->getGuid();
				$query = 'select account_no from ld_account where accountname = ? and deleted = 0';
				$result = $adb->pquery($query,array($acc_name));
				$account_no = $adb->query_result($result,0,0);
				$query = 'SELECT fitemid FROM t_Item where FNumber = \''.$account_no.'\' and FItemClassID = 1 and FDeleted = 0';
				$result=$this->db->Query_result($query);
				$num_rows = $this->db->num_rows($result);
				if($num_rows >= 1){
					$row=$this->db->fetch_all($result,0);
					$query = "update t_Item set FName = '".$accountname."' where fitemid = " . $row['fitemid'];
					$this->db->Query_result($query);
					$query = "update t_Organization set FName = '".$accountname."' where fitemid = " . $row['fitemid'];
					$this->db->Query_result($query);
					return $row['fitemid'];
				}else{
					//$account_no = 'ACC2';
					$insert_item = "INSERT INTO t_Item (FItemClassID,FParentID,FLevel,FName,FNumber,FShortNumber,FFullNumber,FDetail,UUID,FDeleted) values 
					(1,0,1,'".$accountname."','".$account_no."','".$account_no."','".$account_no."',1,$uuid,0)";
					//echo $insert_item;die;
					$this->db->Query_result($insert_item);
					$select_item = "select FItemID from t_Item where FName = '".$accountname."' and FNumber = '".$account_no."' and FItemClassID = 1";
					$result=$this->db->Query_result($select_item);
					$row = $this->db->fetch_one($result);
					$FItemID = $row['FItemID'];
					$fhelpcode = $this->pinyin_long($acc_name);
					$insert_org = "INSERT INTO t_Organization (FHelpCode,FShortName,FAddress,FStatus,FRegionID,FTrade,FContact,FPhone,FMobilePhone,FFax,FPostalCode,FEmail,FBank,FAccount,FTaxNum,FIsCreditMgr,FSaleMode,FValueAddRate,FCity,FProvince,FCountry,
					FHomePage,Fcorperate,FCarryingAOS,FTypeID,FSaleID,FStockIDKeep,FCoSupplierID,FCyID,FSetID,FARAccountID,FPreAcctID,FOtherARAcctID,FPayTaxAcctID,FAPAccountID,FPreAPAcctID,FOtherAPAcctID,FfavorPolicy,Fdepartment,Femployee,
					FlastTradeAmount,FlastRPAmount,FmaxDealAmount,FminForeReceiveRate,FminReserverate,FdebtLevel,FPayCondition,FDistrict,FClass,FCompanyName,FTaxpayerID,FRegisteredAddress,FInvPhone,FInvBank,FInvBankAccount,FShortNumber,
					FNumber,FName,FParentID,FItemID) 
					VALUES ('".$fhelpcode."',NULL,NULL,1072,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1057,16,'0','0',NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,0,0,0,0,1,1,0,0,'0',0,NULL,NULL,
					NULL,NULL,NULL,NULL,'".$account_no."','".$account_no."','".$accountname."',0,$FItemID)";
					$this->db->Query_result($insert_org);
					return $FItemID;
				}
			}
		}
	
		//供应商
		public function getSupperId($vendorname){
			global $adb;
			$ven_name = $vendorname;
			$vendorname = $this->convert2gbk($vendorname);
			$query = 'SELECT fitemid FROM t_Item where FName = \''.$vendorname.'\' and FItemClassID = 8 and FDeleted = 0';
			$result=$this->db->Query_result($query);
			$num_rows = $this->db->num_rows($result);
			
			if($num_rows >= 1){
				$row=$this->db->fetch_all($result,0);
				return $row['fitemid'];
			}else{
				$uuid = $this->getGuid();
				$query = 'select vendor_no from ld_vendor where vendorname = ? and deleted = 0';
				$result = $adb->pquery($query,array($ven_name));
				$vendor_no = $adb->query_result($result,0,0);
				$query = 'SELECT fitemid FROM t_Item where FNumber = \''.$vendor_no.'\' and FItemClassID = 8 and FDeleted = 0';
				$result=$this->db->Query_result($query);
				$num_rows = $this->db->num_rows($result);
				if($num_rows >= 1){
					$row=$this->db->fetch_all($result,0);
					$query = "update t_Item set FName = '".$vendorname."' where fitemid = " . $row['fitemid'];
					$this->db->Query_result($query);
					$query = "update t_Supplier set FName = '".$vendorname."' where fitemid = " . $row['fitemid'];
					$this->db->Query_result($query);
					return $row['fitemid'];
				}else{
					$insert_item = "INSERT INTO t_Item (FItemClassID,FParentID,FLevel,FName,FNumber,FShortNumber,FFullNumber,FDetail,UUID,FDeleted) values 
					(8,0,1,'".$vendorname."','".$vendor_no."','".$vendor_no."','".$vendor_no."',1,$uuid,0)";
					$this->db->Query_result($insert_item);
					$select_item = "select FItemID from t_Item where FName = '".$vendorname."' and FNumber = '".$vendor_no."' and FItemClassID = 8";
					$result=$this->db->Query_result($select_item);
					$row = $this->db->fetch_one($result);
					$FItemID = $row['FItemID'];
					$fhelpcode = $this->pinyin_long($vendorname);
					$insert_org = "INSERT INTO t_Supplier (FHelpCode,FShortName,FAddress,FStatus,FRegionID,FTrade,FContact,FPhone,FMobilePhone,FFax,FPostalCode,FEmail,FBank,FAccount,FTaxNum,FValueAddRate,FCountry,FProvince,Fcorperate,FDiscount,FTypeID,
					FStockIDAssignee,FBr,FRegmark,FLicence,FCyID,FSetID,FAPAccountID,FPreAcctID,FOtherAPAcctID,FPayTaxAcctID,FARAccountID,FPreARAcctID,FOtherARAcctID,FfavorPolicy,Fdepartment,Femployee,FlastTradeAmount,FlastRPAmount,
					FmaxDealAmount,FminForeReceiveRate,FCreditDays,FShortNumber,FNumber,FName,FParentID,FItemID) VALUES ('".$fhelpcode."',NULL,NULL,1072,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,16,NULL,NULL,
					NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,0,0,0,0,NULL,0,0,0,0,0,1,0,'".$vendor_no."','".$vendor_no."','".$vendorname."',0,$FItemID)";
					$this->db->Query_result($insert_org);
					
					return $FItemID;
				}
			}
		}
		
		public function getGuid(){
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
	
		public function setConnentErpDb(){
			crm_load_class_file('cls_odbc','include');
			$SqlCon = new cls_odbc($this->erp_dbname,$this->erp_dbuser,$this->erp_dbpswd,$this->erp_dbhost,'DIRODBC');
			if(empty($SqlCon->error_log)){
				$conResult = 1;
			}
			$result = array(
				'sqlcon' => $SqlCon,
				'conResult' => $conResult,
			);
			return $result;
		}
	}

?>