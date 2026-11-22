<?php
	crm_load_class_file('ScopOfAuthority','include/ScopOfAuthority');
	/*
	*edit: chj
	*date: 2020/9/21
	*reason: 对账单报表字段权限： 去除共享数据
	*/
	Class cls_langjie_duizhang_Scop extends ScopOfAuthority{
		
		public function __construct($adb,$module){
			parent::__construct($adb,$module);
		}
		
		
		public function getModuleListViewQuery() {
			global $related_header;
			$userids= $this->getCurUserScopeId();
			if(!empty($related_header) || (!empty($_REQUEST['related_module']) && !empty($_REQUEST['related_id']))){//相关信息 APP
				//当前用户为管理员或者拥有用户全景权限，则允许查看所有数据
				if($this->userobj->is_admin == 'on' || ($this->userobj->accountallview == 1 && $related_header != 'Campaigns')){
					return '';
				}
				if($related_header=='Campaigns'&&($this->userobj->is_admin == 'on' || $this->userobj->campaignsview == 1))
				{
					return ' ';
				}
			}
			//0029072: 即时库存查询：普通用户，新增出入库单保存后，即时库存查询模块仓库中没有产品库存记录
			if($this->module=='InventoryQuery')return '';
			//获取模块的负责人，服务收费-服务收费人
			$smownerid = $this->fieldobj->getWhereSmowner();
			if(empty($smownerid[0]))
				$smownerid[0] = 'smownerid';
			if($this->module=='Reminds')	//提醒列表页面关联recieverid而不是smownerid
				$crmtablename = $this->focus->table_name .'.recieverid';
			else if($this->module=='BankAccountSet')
				$crmtablename = 'ld_bankaccountset.smownerid';
			else{
				$crmtablename = $this->focus->table_name .'.'.$smownerid[0]['columnname'];
			}
			if ($this->userobj->is_admin != 'on' && ($this->moduleShareRules[$this->tabid] == SHARE_PRIVATE || $this->moduleShareRules[$this->tabid] == '')){
				if($this->getUserModuleScoperType() == SCOPE_PERSON){	//授权范围：个人
					$query[] = " $crmtablename = " . $this->userid;
				}
				else if($this->getUserModuleScoperType() == SCOPE_ALL){	//如果业务单据授权范围为全部

					//$userall = getCurSmOwnerSearchScope($this->module);
					//$userscope = $userall['UserCombo'];//获取授权范围
					//$userscopeid = array_keys($userscope);
					$userscope = get_user_array(FALSE, "", '');
					$userscopeid = array_keys($userscope);
					$query[] = "$crmtablename in (".implode(',',$userscopeid).")";
				}
				else if($this->getUserModuleScoperType() == SCOPE_HIGER_USER || $this->getUserModuleScoperType() == SCOPE_HIGHER_GROUP){	//授权范围：高级
					$userscope = $this->getUserModuleScopeHigher();//获取授权范围
					//$userscopeid = array_keys($userscope);
					$userscopeid = $userscope;
					$userscopeid[]=$this->userobj->id;
					if(!empty($userscopeid))
						$query[] = "$crmtablename in (".implode(',',$userscopeid).")";
				}
				//允许查看自己创建的数据
				//if($this->userobj->access['creator'] == 1){
				 
				 if($this->modulescolist[$this->module]['viewselfbills']==1){
					$query[] = $this->focus->table_name . ".smcreatorid = $this->userid"; 
				}
			}
			if($this->module == 'PublicAnnouncement'){
				//0017419: 公告-列表界面：系统管理员新增公告，接收人选择：芳小芳，结果芳小芳用户无法看到
				//22251: （非管理员用户登录）公告序时簿界面：查看范围选择“全部”的时候，没有显示该用户能查看的全部单据
				if($this->userobj->is_admin != 'on'){
					$query[] .=' ld_receipts.userid = ' . $this->userobj->id ;
					$query[] .=' ld_publicannouncement.smownerid= ' . $this->userobj->id ;
				}
			}
			$this->scope_sql = $query;
			if(count($query) >= 1){
				$query[] = 'k.smownerid = ' . $this->userobj->id;
				//$query[] = "k.smownerid IN (".implode(',',$userscopeid).")";
				//echo ' and (' .implode(' or ',$query)  . ')<br>';
				return ' and (' .implode(' or ',$query)  . ')';
			}else
				return '';
		}
	}
?>