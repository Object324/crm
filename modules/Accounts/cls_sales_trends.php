<?php
class cls_sales_trends
{
	public $record;
    public $module;
    public $modules;
    public $focus;
    public $tabid;
    public $datetime_array = [];
    public $data;
    public $obj_getrelateInfo;
    public function __construct($record,$module)
    {
		global $adb;
		$this->record = $record;
		$this->module = $module;
		$fieldobj=Field::getInstance($module,$adb);
		$this->modules = $fieldobj->getModuleFields();
		$this->focus = CRMEntity::getInstance($module);
		$this->tabid = getTabid($module);
        //预准备时间控制：详细做法待确定  2021-7-15
        //$tmp_time = strtotime("2021-06-01");
        //$tmp_time_2 = strtotime("2021-08-01");
        //$this->start_date = date("Y-m-d",$tmp_time);
        //$this->end_date = date("Y-m-d",$tmp_time_2);
    }

	public function getList(){
	   //内容控制预准备:详细做法待确定 2021-7-15
       //list_info = array('create','smowner','share','public','relate','singin');
       //foreach($list_info as $value)
       //   swtich($value){}
        global $current_user;
		$languageType= getLanguageType($current_user);
		$this->getCreateAccounsLog();//单据创建记录
		$this->getSmowneridLog(); //单据负责人变更记录
		$this->getModuleTabshareLog(); //单据共享记录
        $this->getphonecalledlog();//打电话记录
		$this->getModulePublicAccount(); //公海操作记录
		$this->getRelatedListLog();//相关信息创建记录
		$this->getSinginLog(); //签到记录
		$data = array();  
		if(!empty($this->datetime_array)){
			rsort($this->datetime_array);
			foreach($this->datetime_array as $dates){
				$s_date = $dates['datetime'];
				$new_data[$s_date] = $this->data[$s_date];
			}
			$weekarray_zh=array("日","一","二","三","四","五","六");
            $weekarray_en=array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
			foreach($new_data as $date => $arr){
                $num = sizeof($arr);
                for($tmp_i=0;$tmp_i<$num;$tmp_i++){//按时间重新排序
                    $tmp_maxindex = 0;
                    for($tmp_j=0;$tmp_j<$num-$tmp_i;$tmp_j++){
                        if(strtotime($arr[$tmp_j]['datetime'])-strtotime($arr[$tmp_maxindex]['datetime'])<0){
                            $tmp_maxindex =$tmp_j; 
                        }
                    }
                    $tmp_arr = $arr[$num-$tmp_i-1];
                    $arr[$num-$tmp_i-1] = $arr[$tmp_maxindex];
                    $arr[$tmp_maxindex] = $tmp_arr;
                }
                if($languageType=='zh')
				    $week_num = "星期".$weekarray_zh[date("w",strtotime($date))];
                else
                    $week_num = $weekarray_en[date("w",strtotime($date))];
				$data[] = array(
					'title' => $date . '　　　' . $week_num,
					'list' => $arr
				);
			}
		}
		return $data;
	}
//	private function setDatetimeForSeconds($createdtime){
//		$secord = date("H:i:s",strtotime($createdtime));
//		$parsed = date_parse($secord);
//		$seconds = $parsed['hour'] * 3600 + $parsed['minute'] * 60 + $parsed['second'];
//		return $seconds;
//	}
	private function setDatetimeArray($date){
		$this->datetime_array[strtotime($date)] = array(
			'datetime' => $date,
			'times' =>strtotime($date),
		);
	}
	//新增客户
	private function getCreateAccounsLog(){
		global $adb;
		$entityarray = getEntitynameInfo(getTabid($this->module));
		$link_tabname = $entityarray['tablename'];
		$link_tabfieldname = $entityarray['fieldname'];
		$tablename = $this->focus->table_name;
		$tableindex = $this->focus->table_index;
		$tablename_cf = $this->focus->customFieldTable[0];
		$tablename_cf_index = $this->focus->customFieldTable[1];
		$query = "select $link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from $tablename 
		left join $tablename_cf on $tablename_cf.$tablename_cf_index = $tablename.$tableindex 
		where $tablename.$tableindex = ?";
        //$query .= " and $tablename.createdtime between '".$this->start_date."'and'".$this->end_date."'";
		$result = $adb->pquery($query,array($this->record));
		$smcreatorid = $adb->query_result($result,0,'smcreatorid');
		$createdtime = $adb->query_result($result,0,'createdtime');
		$date = date("Y-m-d",strtotime($createdtime));
		$this->setDatetimeArray($date);
		//$seconds  = $this->setDatetimeForSeconds($createdtime);
		$this->data[$date][] = array(
			'title' => getFixedLabel('NEW') . getTransTab($this->module),
			'time' => date("H:i",strtotime($createdtime)),
			'lastname' => getUserFullName($smcreatorid),
			'link' => $adb->query_result($result,0,$link_tabfieldname),
			'datetime' => $createdtime,
		);
	}
	
	//分配负责人变更历史
	private function getSmowneridLog(){
		global $adb,$current_user;
		$languageType= getLanguageType($current_user);
        //服务收费管理模块添加服务收费人
		$query = "select ld_modtracker_basic.changedon,prevalue,postvalue,whodid,ld_tranlabel.fieldlabel from ld_modtracker_basic 
			LEFT JOIN ld_modtracker_detail on ld_modtracker_detail.id = ld_modtracker_basic.id
			LEFT JOIN ld_tab on ld_tab.`name` = ld_modtracker_basic.module
			INNER JOIN ld_field on ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ld_tab.tabid and ld_field.tabid = ?
			LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
			and ld_tranlabel.trantable = 'ld_field' and ld_tranlabel.languagetype = ?
			where (ld_modtracker_detail.fieldname = 'assigned_user_id' or ld_modtracker_detail.fieldname = 'servicecasher') and crmid = ?";
		//$query .= " and ld_modtracker_basic.changedon between '".$this->start_date."'and'".$this->end_date."'";
        if(empty($languageType))$languageType = 'zh';
		$result = $adb->pquery($query,array($this->tabid,$languageType,$this->record));
        $num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$whodid = $adb->query_result($result,$i,'whodid');
				$postvalue = $adb->query_result($result,$i,'postvalue');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				$datetime = $adb->query_result($result,$i,'changedon');
				$date = date("Y-m-d",strtotime($datetime));
				$this->setDatetimeArray($date);
				//$seconds  = $this->setDatetimeForSeconds($datetime);
				$this->data[$date][] = array(
					'title'=> getFixedLabel('ALLOCATE') .$fieldlabel . getFixedLabel('to1') .getUserFullName($postvalue),
					'lastname' => getUserFullName($whodid),
					'time' =>date("H:i",strtotime($datetime)),
					'datetime' => $datetime,
				);
			}
		}
	}

	//单据共享记录
	private function getModuleTabshareLog(){
		global $adb;
		$query = 'select viewuserid,Shareuserid,createdtime from ld_tabshare where crmid = ?';
        //$query .= " and createdtime between '".$this->start_date."'and'".$this->end_date."'";
		$result = $adb->pquery($query,array($this->record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$viewuserid = $adb->query_result($result,$i,'viewuserid');
				$viewusername[] = getUserFullName($viewuserid);
				$shareuserid = $adb->query_result($result,$i,'shareuserid');
				$createdtime = $adb->query_result($result,$i,'createdtime');

                $date = date("Y-m-d",strtotime($createdtime));
                $this->setDatetimeArray($date);
                //$seconds  = $this->setDatetimeForSeconds($createdtime);
                $this->data[$date][] = array(
                    'title'=> getFixedLabel('SHARE') .getFixedLabel('to1') .implode('、',$viewusername),
                    'lastname' => getUserFullName($shareuserid),
                    'time' => date("H:i",strtotime($createdtime)),
                    'datetime' => $createdtime,
                );
				
			}

		}
	}
    
    //hjz 打电话记录
    private function getphonecalledlog(){
        global $adb;
        $record = $this->record;
        $module = $this->module;

        $query = 'SELECT ld_module_calledlog.*,ld_contactdetails.lastname FROM ld_module_calledlog INNER JOIN ld_contactdetails ON ld_module_calledlog.record = ld_contactdetails.contactid
            WHERE ld_module_calledlog.modulename = "Contacts" AND ld_contactdetails.accountid = ?';
        $result =$adb->pquery($query,array($record));
        $num_rows = $adb->num_rows($result);
    	if($num_rows >= 1){
            for($i = 0; $i < $num_rows; $i++){
                $modulename = $adb->query_result($result,$i,'modulename');
    			$phonenum = $adb->query_result($result,$i,'phonenum');
                $calleduserid = $adb->query_result($result,$i,'calleduserid');
    			$calledtime = $adb->query_result($result,$i,'calledtime');
                $lastname = $adb->query_result($result,$i,'lastname');
                $date = date("Y-m-d",strtotime($calledtime));
                $this->setDatetimeArray($date);
                $this->data[$date][] = array(
                    'title'=> getFixedLabel('Dial') .getFixedLabel('Phone') .getFixedLabel('to1')  .$lastname .'：' .$phonenum,
    				'lastname' => getUserFullName($calleduserid),
    				'time' => date("H:i",strtotime($calledtime)),
    				'datetime' => $calledtime,
                );
    		}
    	}
        
        $query = 'select ld_module_calledlog.*,ld_account.accountname from ld_module_calledlog INNER JOIN ld_account on ld_module_calledlog.record = ld_account.accountid where ld_module_calledlog.modulename="Accounts" and ld_account.accountid = ?';
        $result =$adb->pquery($query,array($record));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            for($i = 0; $i < $num_rows; $i++){
                $modulename = $adb->query_result($result,$i,'modulename');
                $accountname = $adb->query_result($result,$i,'accountname');
        		$phonenum = $adb->query_result($result,$i,'phonenum');
                $calleduserid = $adb->query_result($result,$i,'calleduserid');
        		$calledtime = $adb->query_result($result,$i,'calledtime');
                $date = date("Y-m-d",strtotime($calledtime));
                $this->setDatetimeArray($date);
                $this->data[$date][] = array(
                    'title'=> getFixedLabel('Dial') .getFixedLabel('Phone') .getFixedLabel('to1')  .$accountname .'：'.$phonenum,
        			'lastname' => getUserFullName($calleduserid),
        			'time' => date("H:i",strtotime($calledtime)),
        			'datetime' => $calledtime,
                );
            }
        }

    }
	
	//转公海/转普通/领取/公海负责人变更历史
	private function getModulePublicAccount(){
		global $adb;
		$query = "select ld_users.wx_userid,ld_users.last_name,ld_logpublicaccount.username,ld_logpublicaccount.operation,ld_logpublicaccount.opdate,ld_logpublicaccount.userid from ld_logpublicaccount left join ld_users ON ld_users.id = ld_logpublicaccount.userid where (operation like '%TOBETHEHIGHSEASCUSTOMTERS%' or operation like '%TOBETHEORDINARYCUSTOMERS%' or operation like '%GETMYPUBLICACCOUNT%' or operation like '%ALLOCATEPUBLICACCOUNTGIVEN%' or operation like '%TORELEASETHECUSTOMERTOTHEHIGNSEAS%' or operation like '%DELAYPUBLICACCOUNTDAYS%') and ld_logpublicaccount.accountid = ?";
		//$query .= " and opdate between '".$this->start_date."'and'".$this->end_date."'";
        $result = $adb->pquery($query,array($this->record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$loguserid=$adb->query_result($result, $i, "userid");
	            $userobj=new Users();
	            if(!empty($loguserid)){
	                $userobj->last_name= $adb->query_result($result, $i, "last_name");
	            }
	            else{
	                $userobj->last_name= $adb->query_result($result, $i, "username");
	            }
	            $userobj->wx_userid= $adb->query_result($result, $i, "wx_userid");
				$username = getUserlastName($userobj);
				$operation = $adb->query_result($result,$i,'operation');
				$opdate = $adb->query_result($result,$i,'opdate');
				if($operation == 'GETMYPUBLICACCOUNT'){	//领取
					$title = getFixedLabel('RECEIVE') . getFixedLabel('PUBLICCUSTOMER') . getTransTab('Accounts');
				}else if(strpos($operation,'ALLOCATEPUBLICACCOUNTGIVEN') !== false){	//公海分配
					$fieldinfo = $this->modules['assigned_user_id'];
					if(!empty($fieldinfo)){
						$label = $fieldinfo->fieldLableKey;
					}
					$operation_arr = explode('$###$',$operation);
					$title = htmlspecialchars_decode(getFixedLabel('LBL_DISTRIBUT_HIGHSEAS') .$label . getFixedLabel('to1') .$operation_arr[1]);
				}else if(strpos($operation,'TORELEASETHECUSTOMERTOTHEHIGNSEAS') !== false){	//公海分配释放
					$title = htmlspecialchars_decode(getFixedLabel('RELEASE') .getFixedLabel('PUBLICCUSTOMER') . getTransTab('Accounts'));
				}else if(strpos($operation,'DELAYPUBLICACCOUNTDAYS') !== false){	//公海分配 延期
					$title = htmlspecialchars_decode(getFixedLabel('ACCOUNTDELAY') .getFixedLabel('PUBLICCUSTOMER') . getTransTab('Accounts'));
				}else{	//转公海，转普通
					$title = htmlspecialchars_decode(getFixedLabel($operation));
				}
				$date = date("Y-m-d",strtotime($opdate));
				$this->setDatetimeArray($date);
				//$seconds  = $this->setDatetimeForSeconds($opdate);
				$this->data[$date][] = array(
					'title'=> $title,
					'lastname' => $username,
					'time' => date("H:i",strtotime($opdate)),
					'datetime' => $opdate,
				);
			}
		}
	}
	//相关信息
	private function getRelatedListLog(){
		global $adb,$current_user;
        if($this->tabid==102){
            $this->module='Accounts';
            $this->tabid=6;
        }
		$relation_ids = $this->getRelatedListRelationId();
		crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
		crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
        crm_load_class_file('cls_getRelatedInfo','include/ListView/RelatedListView');
		foreach($relation_ids as $relation_module => $relation_id){
			$relationInfo = getRelatedListInfoById($relation_id,$this->module);
            $type=strtolower($relationInfo['type']);
            $name=$relationInfo['functionName'];
            
            if($name=='get_balanceofaccount')
            {
                continue;
            }
            if($type=='datacategory_template_js'||$type=='datacategory_templatelink')//自定义报表
            {
                continue;
            }
            
            if($relationInfo['related_coltable']=='')
			{
			continue;
			}
            if(isPermitted($relation_module)=='no'&&$current_user->accountallview==0)
            {
                //edit:can 2020-11-25 043414: （https://61mis.com/kfbcrm [^]）将一个成员的权限设置成：只有客户模块的查看权限；在企业微信-客户管理-客户详情界面，动态中会显示成员没有权限查看的其他模块的信息，比如说新建的跟进记录。
                continue;
            }
			$cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($this->module,$relationInfo,$this->record);
		//	$relatedListData=$cls_getRelatedInfoobj->getRelateCount();
		//	if($relatedListData['relcount'] > 0){
			if(file_exists('include/ListView/RelatedListView/cls_'.$relationInfo['type'].'.php')){
				crm_load_class_file('cls_'.$relationInfo['type'],'include/ListView/RelatedListView');
				$classname='cls_'.$relationInfo['type'];
				$this->obj_getrelateInfo=new $classname($this->module,$relationInfo,$this->record);
			}else{
				$this->obj_getrelateInfo=new cls_getRelatedInfo($this->module,$relationInfo,$this->record);
			}
			$obj = $relatedListData=$this->obj_getrelateInfo->getDataCategory_sqlObj();
            $page_list_query= $obj->getQuery(4);
           // $arr[]=$relation_module.'<br>'.$page_list_query;

		//	if(!empty($page_list_query) && !empty($relation_module)){
			$relationmodule_focus = CRMEntity::getInstance($relation_module);
			$entityarray = getEntitynameInfo(getTabid($relation_module));
			$link_tabname = $entityarray['tablename'];
			$link_tabfieldname = $entityarray['fieldname'];
			$tablename = $relationmodule_focus->table_name;
			$tableindex = $relationmodule_focus->table_index;
			$querys = explode('FROM',$page_list_query);
           
            $record=$this->record;
            if($relation_module == 'ContactRecords')
                $query = "select $tablename.content,$tablename.$tableindex,$link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from ( $tablename
                   inner join  ld_account on ld_account.accountid=$tablename.accountid and $tablename.accountid=$record )
                    inner join ($page_list_query) as tmp on tmp.$tableindex = $tablename.$tableindex
                    where $tablename.deleted=0
                   order by $tablename.modifiedtime desc , $tablename.createdtime desc ";
            else if($relation_module=='Attachment')
                $query = "select $tablename.$tableindex,$link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from ( $tablename
                   inner join  ld_account on ld_account.accountid=$tablename.related_to
                   and $tablename.related_to=$record and $tablename.reltab='Accounts' )
                    inner join ($page_list_query) as tmp on tmp.$tableindex = $tablename.$tableindex
                     where $tablename.deleted=0
                   order by $tablename.modifiedtime desc , $tablename.createdtime desc ";
            else if($relation_module=='Products')
                $query = "select $tablename.$tableindex,$link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from ( $tablename
                   INNER JOIN ld_seproductsrel ON ld_products.productid = ld_seproductsrel.productid
                   inner join  ld_account on ld_account.accountid=ld_seproductsrel.crmid
                   and ld_seproductsrel.crmid=$record )
                    inner join ($page_list_query) as tmp on tmp.$tableindex = $tablename.$tableindex
                     where $tablename.deleted=0
                   order by $tablename.modifiedtime desc , $tablename.createdtime desc ";
            else if($relation_module=='Campaigns')
                $query = "select $tablename.$tableindex,$link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from ( $tablename
                   INNER JOIN ld_campaignaccountrel ON ld_campaignaccountrel.campaignid = ld_campaign.campaignid
                   inner join  ld_account on ld_account.accountid=ld_campaignaccountrel.accountid
                   and ld_campaignaccountrel.accountid=$record )
                    inner join ($page_list_query) as tmp on tmp.$tableindex = $tablename.$tableindex
                     where $tablename.deleted=0
                   order by $tablename.modifiedtime desc , $tablename.createdtime desc ";

            else
                $query = "select $tablename.$tableindex,$link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from ( $tablename
                   inner join  ld_account on ld_account.accountid=$tablename.accountid and $tablename.accountid=$record )
                    inner join ($page_list_query) as tmp on tmp.$tableindex = $tablename.$tableindex
                     where $tablename.deleted=0
                   order by $tablename.modifiedtime desc , $tablename.createdtime desc ";
            //$query .= " and $tablename.createdtime between '".$this->start_date."'and'".$this->end_date."'";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);

			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$smcreatorid = $adb->query_result($result,$i,'smcreatorid');
					$createdtime = $adb->query_result($result,$i,'createdtime');
					$date = date("Y-m-d",strtotime($createdtime));
					$this->setDatetimeArray($date);
					//$seconds  = $this->setDatetimeForSeconds($createdtime);
                    $tmp_arr = array(
						'title' => getFixedLabel('NEW') . getTransTab($relation_module),
						'time' =>date("H:i",strtotime($createdtime)),
						'lastname' => getUserFullName($smcreatorid),
						'link' => $adb->query_result($result,$i,$link_tabfieldname),
						'secid' => $adb->query_result($result,$i,$tableindex),
						'relatemodule' => $relation_module,
						'modulename' => getTransTab($relation_module),
						'datetime' => $createdtime,
					);
                    if($relation_module == 'ContactRecords'){
						$tmp_arr['content'] = $adb->query_result($result,$i,'content');
					}
					$this->data[$date][] = $tmp_arr;
				}
			}

				//}
		//	}
		}
	}
	private function getRelatedListRelationId(){
	   //根据单据相关模块控制
		global $adb,$weixin_user;
		$query = 'select relation_id,label from ld_relatedlists
         inner join ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
         where ld_relatedlists.tabid = ? and related_tabid > 0 and related_tabid <> ? and related_tabid <> 10 ';
        if(empty($weixin_user))//判断pc端或移动端
            $query .='and ld_relatedlists.presence <> 1 and ld_tab.presence in(0,2) and ld_relatedlists.dynamicstatus="yes" ORDER BY ld_relatedlists.sequence';
        else
            $query .='and ld_relatedlists.wx_presence <> 1 and ld_tab.presence in(0,2) and ld_relatedlists.dynamicstatus="yes" ORDER BY ld_relatedlists.wx_sequence';
		$result = $adb->pquery($query,array($this->tabid,$this->tabid));
        $num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$label = $adb->query_result($result,$i,'label');
				$relation_id[$label] = $adb->query_result($result,$i,'relation_id');
			}
		}
		return $relation_id;
	}

	//获取签到记录
	private function getSinginLog(){
		global $adb;
        $ScopOfAuthority = ScopOfAuthority::getInstance($adb,'Singin');
        $userdaterang_sql=$ScopOfAuthority->getSmOwnerSearchSql();
        //0047187:签到时同时创建新客户时，签到记录里只有record,没有accountid
		$query = 'select createdtime,userid,address,distince,content,id,signid from ld_singin where (accountid = ? or (record = ? and tabid = ?)) ';
        $query.=$userdaterang_sql;
        //$query .= " and createdtime between '".$this->start_date."'and'".$this->end_date."'";
		$result = $adb->pquery($query,array($this->record,$this->record,$this->tabid));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$list = array();
				$createdtime = $adb->query_result($result,$i,'createdtime');
				$userid = $adb->query_result($result,$i,'userid');
				$newsignid = $adb->query_result($result,$i,'signid');
				$address = getFixedLabel('SIGNIN') .'：'. $adb->query_result($result,$i,'address');
				$distince = getFixedLabel('ERRORDISTANCE') .'：'. $adb->query_result($result,$i,'distince');
				$content = getFixedLabel('DESCRIPTION') .'：'. $adb->query_result($result,$i,'content');
				$id = $adb->query_result($result,$i,'id');
				$list[] = $address;
				$list[] = $distince;
				$list[] = $content;
				$date = date("Y-m-d",strtotime($createdtime));
				$this->setDatetimeArray($date);
				//$seconds  = $this->setDatetimeForSeconds($createdtime);
				$this->data[$date][] =array(
					'time' => date("H:i",strtotime($createdtime)),
					'lastname' => getUserFullName($userid),
					'list' => $list,
					'datetime' => $createdtime,
					'type' => 'signin',
					'img_list' => $this->getSinginImagesLog($newsignid),
				);
			}
		}
		return $data;
	}
	
	//获取签到的图片信息
	private function getSinginImagesLog($newsignid){
		global $adb;
		//$query = 'select CONCAT(path,filename) as img,id,cloud_path,storage_location from ld_attachmentsforsign where signid = ?';
		$query = '
SELECT CONCAT(path,newfile_name) as img,ld_attachments.attachmentsid,storage_location,cloud_path from ld_attachments 
            INNER JOIN ld_seattachmentsrel on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.attachmentcolumnname = "imagename" and ld_seattachmentsrel.crmid =?';
		$result = $adb->pquery($query,array($newsignid));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
                $storage_location = $adb->query_result($result,$i,'storage_location');
                if($storage_location =='cos'){
                    $img_path = $adb->query_result($result,$i,'cloud_path');
                }else{
                    $img_path = $adb->query_result($result,$i,'img');
                }
                $data[] =array(
                	'img' => $img_path,
                    'storage_location' => $storage_location
                );
			}
		}
		return $data;
	}
}

?>