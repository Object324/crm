<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-04-30
 */
// 部门操作方法类
class staticAccounts {
	/**
	 * 获取所选择用户对应的电话号码
	 * @project 汉天呼叫中心批量外呼
	 * @author Tujt 2015-04-30
	 */
	public static function getAccountPhone($input) {
		global $adb,$current_user;
        if(!$adb)
        {
            $adb = PearDatabase::getInstance();
        }
		$tabid = getTabid('Accounts');//获取客户tabid
		//获取对应的外呼电话字段（呼叫中心参数中设置）
		$languageType= getLanguageType($current_user);
		$query = 'SELECT tablename,columnname,ld_tranlabel.`fieldlabel`
					FROM ld_field 
						LEFT JOIN ld_tranlabel ON ld_tranlabel.`relateid` = ld_field.`fieldid`
				WHERE ld_field.tabid = ? AND ld_field.uitype IN (11,1101) 
				AND ld_field.presence <> 1 AND ld_field.callchecked = 1 AND ld_tranlabel.`languagetype` = ? AND ld_tranlabel.`trantable` = ?;';
		$result = $adb->pquery($query,array($tabid,$languageType,'ld_field'));
		$rows = $adb->num_rows($result);
		$entity = array();
		if($rows > 0){//获取对应的电话字段
			$selectfld = '';$wherefld = '(';
			$tablearr = array();
			//客户、联系人模块翻译
			$modulelabel = array('ld_account'=>getTranstab('Accounts'),
								'ld_accountscf'=>getTranstab('Accounts'),
								'ld_contactdetails'=>getTranstab('Contacts'),
								'ld_contactscf'=>getTranstab('Contacts'));
			$header = array();
			for($i=0;$i<$rows;++ $i){
				$tablename = $adb->query_result($result,$i,'tablename');
				$columnname = $adb->query_result($result,$i,'columnname');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				$tablename = strtolower($tablename);
				//组装字段翻译数组
				$header[$tablename][$columnname]['label'] = $modulelabel[$tablename].'('.$fieldlabel.')';
				//组装成数组，循环获取值的时候调用
				$tablearr[$i]['tablename'] = $tablename;
				$tablearr[$i]['columnname'] = $columnname;
				//组装成查询的字段和where非空语句
			    $tabfld = $tablename.'.'.$columnname;
				$selectfld .= $tabfld.',';
				$wherefld .= ' ('.$tabfld.' is not null and '.$tabfld.' != \'\') or';
			}
			//查询出客户的id、名字、主要联系人等
			$selectfld .= 'ld_account.accountid,ld_account.accountname,
							ld_contactdetails.contactid,ld_contactdetails.lastname';
			$wherefld = trim($wherefld,'or');
			$wherefld .= ')';
			$accountid = trim($input['accountid'],',');
			//组装成查询query
			$query = 'SELECT '.$selectfld.' FROM ld_account 
						left join ld_accountscf 
							on ld_accountscf.accountid = ld_account.accountid
						left JOIN ld_contactdetails 
							ON ld_contactdetails.`accountid` = ld_account.`accountid` 
							AND ld_contactdetails.reference = 1 
						left join ld_contactscf 
							on ld_contactscf.contactid = ld_contactdetails.contactid 
						WHERE ld_account.deleted = 0 and '.$wherefld.' and 
							ld_account.`accountid` in ('.$accountid.');';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			if($rows > 0){
				$accountarr = array();$record = array();
				for($i=0;$i<$rows;++ $i){
					//获取当前客户对应的名称、关联联系人等
				    $accountid = $adb->query_result($result,$i,'accountid');
					$accountname = $adb->query_result($result,$i,'accountname');
					$contactid = $adb->query_result($result,$i,'contactid');
					$lastname = $adb->query_result($result,$i,'lastname');
					$accountarr[$accountid]['accountname'] = $accountname;
					$accountarr[$accountid]['contactid'] = $contactid;
					$accountarr[$accountid]['lastname'] = $lastname;
					$phone_idx = 0;//电话数量，如果大于1，可能需要弹出列表供用户选择
					foreach($tablearr as $table){
						$phone = $adb->query_result($result,$i,$table['columnname']);
						if(!empty($phone)){//判断非空
							$accountarr[$accountid]['call'][$table['tablename']][$table['columnname']] = $phone;
							$phone_idx ++;
						}else{
							$accountarr[$accountid]['call'][$table['tablename']][$table['columnname']] = '';
						}
					}
					$accountarr[$accountid]['idx'] = $phone_idx;
					$record[] = $accountid;//有电话号码的客户ID
				}
				$entity = array('header'=>$header,'phone'=>$accountarr,
								'modulelabel'=>$modulelabel,'record'=>$record);
			}
		}
		//获取客户模块的当前页数
		$fld_module = 'Accounts';$start = 1;$publicaccounttype = '';
		if(isset($_SESSION['lvs'.$fld_module][$fld_module]['pagepublicaccounttype']))
			$publicaccounttype  = $_SESSION['lvs'.$fld_module][$fld_module]['pagepublicaccounttype'];
		if(isset($_SESSION['lvs'][$fld_module.'_'.$publicaccounttype]['viewname'])){
			$viewid = $_SESSION['lvs'][$fld_module.'_'.$publicaccounttype]['viewname'];
			$start = $_SESSION['lvs'][$fld_module][$viewid]['start'];
		}
		$entity['start'] = $start;
	    return $entity;
	}

	/**
	 * 自动回收到期公海客户
	 * @author Tujt 2015-05-27
	 */
	public function updatePublicAccount($input) {
	    global $adb,$current_user;
        set_time_limit(0);
       
		$time = time();
        if(!$adb)
        {
            $adb = PearDatabase::getInstance();
            
        }
       
		$now_date = date('Y-m-d');
		$now_time = date('Y-m-d H:i:s');
      
		$query = 'select accountid,accountname,id,ld_account.pool_id 
					from ld_account 
						left JOIN ld_users on ld_account.smownerid = ld_users.id 
					where ld_account.deleted = 0 and ld_account.publicaccount > 0
						and protectdate < \''.$now_date.'\' and IFNULL(completed,"") != "已完成"';
      
		$adminaccountquery = 'select adminaccount from ld_account_set';
		//$adminresult = $adb->pquery($adminquery);
		$user = array();
        
		$adminaccountresult = $adb->query($adminaccountquery);
		if($adb->num_rows($adminaccountresult) > 0){
			$userid = explode(',',$adb->query_result($adminaccountresult,0,'adminaccount'));    
			foreach($userid as $id){
				$user[] = $id;
			}
		}
        
		$result = $adb->query($query);
		$num_rows = $adb->num_rows($result);
        //放到这儿，是防止公海客户数据量大的情况下，多人同时登陆获取相同的客户id
    $query = 'update ld_account set protectdate=null,publicaccount=1,allocatedate=null 
					where protectdate < \''.$now_date.'\' and IFNULL(completed,"") != "已完成"';
      
      
	   $adb->query($query);
		if($num_rows){                
			for($i=0;$i<$num_rows;$i++){
				$accountid = $adb->query_result($result,$i,'accountid');
				$pool_id = $adb->query_result($result,$i,'pool_id');
				//公海操作日志
				$query = 'insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) value';
				//system
				
				$queryvalue ='(\'系统\',\'AUTORECYLESEAACCOUNTS\',\''.$now_time.'\','.$accountid.','.$pool_id.')';
				$adb->query($query.$queryvalue);
				/*
				andrew
				20140826
				ld_crmentity修改
				*/               
				$crmid = $adb->getUniqueID('ld_crmentity');
				$sql = 'insert into ld_crmentity(crmid,setype) value(?,?)';
                $str=getFixedLabel('AUTORECYLESEAACCOUNTS');
				$adb->pquery($sql,array($crmid,'Reminds'));
                $receiverid=$adb->query_result($result,$i,'id');
				$sql = "insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,
                reltab,smcreatorid,smownerid,modifiedby,description,createdtime,modifiedtime) 
                value($crmid,'$str','$now_time',$receiverid,'未读',$accountid,'Accounts',$receiverid,$receiverid,$current_user->id,'','$now_time','$now_time')";
			    
                    
                $adb->pquery($sql,array());                    
				 
              
			}
             
      
     
          
		//	$adb->query($query.$queryvalue);
	   }
        
       
	 
	}
	/**
	 * 获取联系人选择客户时回传字段值
	 * @author Tujt 2015-07-23
	 */
	public static function getAccountToContactInfo($input) {
		global $adb;
	    $accountid = $input['accountid'];
		$query = 'select bill_country,bill_state,bill_city,bill_code,bill_street 
					from ld_account where accountid = ? ';
		$result = $result = $adb->pquery($query,array($accountid));
		$rows = $adb->num_rows($result);
		$accountinfo = array();
		if($rows == 1){
			$accountinfo['bill_country'] = $adb->query_result($result,0,'bill_country');
			$accountinfo['bill_state'] = $adb->query_result($result,0,'bill_state');
			$accountinfo['bill_city'] = $adb->query_result($result,0,'bill_city');
			$accountinfo['bill_code'] = $adb->query_result($result,0,'bill_code');
			$accountinfo['bill_street'] = $adb->query_result($result,0,'bill_street');
		}
		return $accountinfo;
	}
}
?>