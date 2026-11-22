<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class AccountsLogic extends BaseLogic {
    public $publicmoduletype;
	public $receivebtn;
    /**
	 * 调用公共更多下拉列表，并添加客户相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
	   global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;
		$is_email = 'no';
		$is_sms = 'no';
		$more_idx = 0;$btn = array();
		//群发邮件
		if('yes' == isPermitted('MassEmails', 'index', '') && vtlib_isModuleActive('MassEmails')){
			$is_email = 'yes';$more_idx = 1;
		}
		//群发短信
		if('yes' == isPermitted('MassSMS', 'index', '') && vtlib_isModuleActive('MassSMS')){
			$is_sms = 'yes';
			$more_idx = 1;
		}


		$btn['s_mail']['label'] = getFixedLabel('BULKMAIL');
		$btn['s_mail']['permit'] = $is_email;
		$btn['s_sms']['label'] = getFixedLabel('BULKSMS');
		$btn['s_sms']['permit'] = $is_sms;
        //群发语音 阳光创信 2021-0908 zxm
        $version = getVersionTradeInfo();
        if($version['account']=='ygchuangxin'){
            $btn['s_sms_voice']['label'] = '群发语音';
            $btn['s_sms_voice']['permit'] = $is_sms;
        }
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);

        //editor:gyq_72 reason:查重合并样式修改 date:20180705
		 //自动查重合并
        $dup_and_merge_permit = 'no';
		if('yes' == isPermitted($module, 'dup_and_merge','')){
			$dup_and_merge_permit = 'yes';$more_idx = 1;
		}
		$btn = array();
		$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		$btn['Findduplicates']['permit'] = $dup_and_merge_permit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);
		//重算经纬度
		$recalculation_latandlong = 'no';
		if('yes' == isPermitted($module, 'EditView','')){
			$recalculation_latandlong = 'yes';$more_idx = 1;
		}
		$btn = array();
		$btn['Recalculation_latandlong']['label'] = getFixedLabel('Recalculatethelatitudeandlongitude');
		$btn['Recalculation_latandlong']['permit'] = $recalculation_latandlong;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,7);
        //Eidtor:gyq_65 Reason:原查重合并改为合并 Date:2018/3/22 0022 下午 3:02
        //editor:gyq 20180809  0034795: （1.6登录）非管理员登录：设置成员没有“合并”权限时序时簿列表界面更多中应不显示“合并”按钮（客户模块测试）
        $merge_permit = 'no';
        if('yes' == isPermitted($module, 'Merge','')){
            $merge_permit = 'yes';$more_idx = 1;
        }
        $btn = array();
        $btn['RecordMerge']['label'] = getFixedLabel('Merge');
        $btn['RecordMerge']['permit'] = $merge_permit;
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,8);
        
        //批量回填
        $backfill_permit = 'no';
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($module);
        if($businessinformationobj->IsEnableBatchbackfill() && isPermitted($module, 'BatchBackFilling','')=='yes'){
            $backfill_permit = 'yes';
        }
		// dump(isPermitted($module, 'BatchBackFilling',''));
        $btn = array();
        $btn['BatchBackFilling']['label'] = getFixedLabel('BatchBackFilling');
        $btn['BatchBackFilling']['permit'] = $backfill_permit;
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,9);

		//判断更多按钮是否显示
		if(('no' == $this->list_buttons['More']['permit'] && 1 == $more_idx)
        ||$this->list_buttons['submitapprove']['permit']=='yes'){//批量提交按钮被放入更多按钮中
			$this->list_buttons['More']['permit'] = 'yes';
		}
        $tmp_more_list_buttons=array();
        foreach($this->list_buttons['More']['list'] as $btname=>$content)
        {
			if($btname == 'ResetListWidth'){
				if(is_admin($current_user))
				{
					//当前用户是管理员时，默认显示 公海参数设置 按钮
					$tmp_more_list_buttons['accountset']=array("label"=>getFixedLabel('LBL_ACCOUNT_SET'),  'permit' => 'yes');
				}
			}
            $tmp_more_list_buttons[$btname]=$content;
           
            if($btname=='mass_edit')
            {
                $tmp_more_list_buttons['submitapprove']=$this->list_buttons['submitapprove'];
                unset($this->list_buttons['submitapprove']);
            }

			if($btname=='Share')// 是否需要同步共享相关信息
            {
                $sys61=getSys_deploy(61);
				if($sys61['deploy_value'] == 'part'){
					$tmp_more_list_buttons['Share']['btnkey'] = 'seniorShare';
				}
            }
            
        }
		$this->list_buttons['More']['list']=$tmp_more_list_buttons;
        //获取该模块所有的列表操作按钮,setlistbutton用来获取公海部分各个页签的特殊按钮
        if($this->setlistbutton == 'yes'){
            // $this->list_buttons['transfer']['label'] =getFixedLabel('Transfer'); //BUG0069553 xxy 2023-7-20 客户-列表操作按钮设置-有两个变更公海 
            $this->list_buttons['massrelease']['label'] =getFixedLabel('BATCHRELEASE');//批量释放
            $this->list_buttons['massget']['label'] =getFixedLabel('RECEIVE');//批量领取
            $this->list_buttons['noallocateconvertnormal']['label'] =getFixedLabel('Transfer');
        }
	}

	/**
	 * 公海按钮合并
	 * @author Tujt 2015-05-28
	 */
	public function setPublicAccountBtn($public_account,$accounttype,$pool_id) {
		global $adb,$current_user;
	    if(isSearchCRMVersion()=='yes')
        {
            return $this->list_buttons;
        }
		$btn = array();
        $module = self::$module;
		$administrators_arr = array();
		$userids_arr = array();
		$cur_userid = $current_user->id;
		$allow_user_permit = 'no';	//允许“公海分配”的成员
        crm_load_class_file('cls_publicpool_profile','include/utils');
        $pool_profileobj = new cls_publicpool_profile($module,$cur_userid,$pool_id);

		if(empty($pool_id)){
			if($accounttype=='ALLACCOUNT' || $accounttype=='DEFAULTALLACCOUNT')
			{
				//更多-转为公海客户
				//$btn['convertpublic']['label'] =getFixedLabel('CONVERTEDHIGHSEASCUST');
				//$btn['convertpublic']['permit'] = 'yes';
				////更多-转为普通客户
				//$btn['convertnormal']['label'] =getFixedLabel('TURNORDINARY');
				//$btn['convertnormal']['permit'] = 'yes';
				//转换公海
				$transfer_permit = 'no';
				if(!empty($public_account['public_account_pool'])){
					foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
						if(!empty($pool_info['administrators'])){
							$admins = explode(',',$pool_info['administrators']);
							$transfer_users_arr = explode(',',$pool_info['transfer_users']);
							if(in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_arr)){
								$transfer_permit = 'yes';
								break;
							}
						}
					}
				}
				$btn['transfer']['label'] =getFixedLabel('Transfer');
				$btn['transfer']['permit'] = $transfer_permit;
			}
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,3);
			$this->list_buttons['More']['permit'] = 'yes';

		}else{
			$administrators_arr = !empty($public_account['public_account_pool'][$pool_id]['administrators'])?explode(',',$public_account['public_account_pool'][$pool_id]['administrators']):[];
			$allow_users_arr = !empty($public_account['public_account_pool'][$pool_id]['allow_users'])?explode(',',$public_account['public_account_pool'][$pool_id]['allow_users']):[];
			$transfer_users_arr = !empty($public_account['public_account_pool'][$pool_id]['transfer_users'])?explode(',',$public_account['public_account_pool'][$pool_id]['transfer_users']):[];//已舍弃不用了
			$userids_arr = !empty($public_account['public_account_pool'][$pool_id]['userids'])?explode(',',$public_account['public_account_pool'][$pool_id]['userids']):[];
			$usertype = $public_account['public_account_pool'][$pool_id]['usertype'];
			//更多-批量释放
			if($accounttype=='PUBLICALLOCATE' && ($public_account['public_account_pool'][$pool_id]['releasetype'] != 'no'  || in_array($current_user->id,$administrators_arr)) )
			{
			    if(in_array($current_user->id,$administrators_arr)){
			        $permit = $pool_profileobj->check_poolbtn_permit('release');
                }else{
                    $permit = 'yes';
                }

				$btn['massrelease']['label'] =getFixedLabel('BATCHRELEASE');
				$btn['massrelease']['permit'] = $permit;
			}
			if(!empty($userids_arr) && in_array($current_user->id,$allow_users_arr)){
				$allow_user_permit = 'yes';	
			}
			//$pool_id = 1;
			//更多-批量领取
			if(!empty($public_account['public_account_pool'][$pool_id])){
				if($accounttype=='NOALLOCATE' && ($public_account['public_account_pool'][$pool_id]['allowget'] == 'no' || in_array($current_user->id,$administrators_arr))){
					$btn['massget']['label'] =getFixedLabel('RECEIVE');
					$btn['massget']['permit'] = 'yes';
				}
			}
			//更多-转换公海
			//if($accounttype=='NOALLOCATE'||$accounttype=='PUBLICALLOCATE'){
				$noallocateconvertnormal_permit = 'no';
				if(in_array($current_user->id,$administrators_arr) || in_array($current_user->id,$transfer_users_arr)){
					$noallocateconvertnormal_permit = 'yes';
				}else{
					//允许公海成员将已分配或领取的公海客户转移到其他公海
					if($accounttype=='PUBLICALLOCATE'){
						$allow_trasnfer_others = $public_account['public_account_pool'][$pool_id]['allow_trasnfer_others'];
						//获取当前用户有权限看到的公海池
						$public_account_pool = [];
						if(!empty($public_account['public_account_pool'])){
							foreach($public_account['public_account_pool'] as $key_pool_id => $pool_info){
								if(!empty($pool_info['administrators'])){
									$admins = explode(',',$pool_info['administrators']);
									if(in_array($current_user->id,$admins)){
										$public_account_pool[$key_pool_id] = $pool_info['pool_name'];
									}
									//公海客户“公海已分配”页签：可选公海仅显示当前用户是“公海管理员”或“公海成员”的公海池
									$userids = explode(',',$pool_info['userids']);
									if(in_array($current_user->id,$userids)){
										$public_account_pool[$key_pool_id] = $pool_info['pool_name'];
									}
								}
							}
						}
//                        @edit:liushuai,2021-07-15,reason: 0046940:客户管理-客户；公海参数没有勾选“允许公海成员将已分配或领取的公海客户转移到其他公海”默认公海-公海已分配列表处，公海成员在更多选项中，不应该显示转换公海按钮
						if(sizeOf($public_account_pool) >= 1 && in_array($current_user->id,$userids_arr) && $allow_trasnfer_others == 'yes'){
						    //公海已分配客户转换公海：1、公海成员 2、有其他公海池的权限 3、当前公海参数设置了允许转其它公海
							$noallocateconvertnormal_permit = 'yes';
						}
					} elseif (in_array($current_user->id,$userids_arr) && $accounttype != 'NOALLOCATE'){
					    //公海成员，未分配页签不显示，全部页签显示
                        $noallocateconvertnormal_permit = 'yes';
                    }
				}
				$btn['noallocateconvertnormal']['label'] =getFixedLabel('Transfer');
				$btn['noallocateconvertnormal']['permit'] = $noallocateconvertnormal_permit;
			//}
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,4);
			$this->list_buttons['More']['permit'] = 'yes';

			//公海成员客户序时簿“新建”功能下拉选项
			if($this->controller->getaccount_administrator() == 'yes' || in_array($current_user->id,$administrators_arr) || in_array($current_user->id,$userids_arr)){
				if($accounttype != 'COMMONACCOUNT' && $accounttype != 'DEFAULTALLACCOUNT' && $accounttype != 'ALLACCOUNT'){
					//普通客户
					$btn['public_ordinary']['label'] = getFixedLabel('COMMONACCOUNT');
					$btn['public_ordinary']['permit'] = 'yes';
					//公海未分配
					$btn['public_notallocated']['label'] = getFixedLabel('LBL_NOALLOCATE');
					$btn['public_notallocated']['permit'] = 'yes';
					//公海已分配
					$btn['public_allocated']['label'] = getFixedLabel('LBL_PUBLICALLOCATE');
					$btn['public_allocated']['permit'] = 'yes';

					$buttontype_array = empty($public_account['public_account_pool'][$pool_id]['create_buttons'])?[]:explode(',',$public_account['public_account_pool'][$pool_id]['create_buttons']);
					$create_commonaccount = $public_account['is_commonaccount_create'];	//是否允许创建普通客户
					if($create_commonaccount == 'yes' && $public_account['status'] == 'yes'){
						$this->list_buttons['Create']['list']['public_ordinary'] = $btn['public_ordinary'];
						$this->list_buttons['Create']['list']['btnkey'] = 'public_ordinary';
					}
					if(!empty($buttontype_array)){
						foreach($buttontype_array as $btntype){
							if($btntype == 'NOALLOCATE'){	//公海未分配
								$this->list_buttons['Create']['list']['public_notallocated'] = $btn['public_notallocated'];
								$this->list_buttons['Create']['list']['btnkey'] = 'public_notallocated';

							}else if($btntype == 'PUBLICALLOCATE'){	//公海已分配
								//33797:客户模块：设置公海客户数量上限参数后，新建公海客户数量超出上限数量参数点击保存时，没有弹出新建客户数量已超出上限数量提示信息
                                $createkey='public_notallocated';
								$this->list_buttons['Create']['list']['public_allocated'] = $btn['public_allocated'];
								$this->list_buttons['Create']['list']['btnkey'] = 'public_notallocated';
							}
						}


                        $this->list_buttons['Create']['btnkey']=array_keys($this->list_buttons['Create']['list'])[0];
					}
//                    @edit:liushuai,2021-07-19,reason:【ID1001466】公海参数配置“公海成员客户序时簿“新建”功能下拉选项”去掉必填项控制
                    if ($public_account['status'] == 'yes' && $create_commonaccount == 'no' && empty($buttontype_array)) {
                        unset($this->list_buttons['Create']);
                    }
				}
			}
			//公海分配、公海平均分配
			if($accounttype=='NOALLOCATE'){
                $Allocatepermit = $pool_profileobj->check_poolbtn_permit('Allocate');

				$Allocate = 'massallocate';
				$Allocatelabel = getFixedLabel('ALLOCATE');
				foreach($this->list_buttons as $key=>$content){
					if($key=='Allocate')
					{
							$buttons[$Allocate]['label'] = $Allocatelabel;
							$buttons[$Allocate]['permit'] = $Allocatepermit;
							$buttons[$Allocate]['icon'] = 'icon-user';
							$buttons[$Allocate]['btnkey'] = $Allocate;
					}
					else
					{
						$buttons[$key]=$this->list_buttons[$key];
					}
				}
				$this->list_buttons=$buttons;
				$highAllocateBtn=array();
				$sys61=getSys_deploy(61);
				if($sys61['deploy_value'] == 'part'){
					$highAllocateBtnkey = 'seniorHigndistribution';
					$avghighAllocateBtnkey = 'seniorAverageHigndistribution';
				}else{
					$highAllocateBtnkey = 'higndistribution';
					$avghighAllocateBtnkey = 'averagehigndistribution';
				}
				//公海分配
				$highAllocateBtn[$highAllocateBtnkey]['label'] = getFixedLabel('ALLOCATE');
				$highAllocateBtn[$highAllocateBtnkey]['permit'] = $Allocatepermit;
				$highAllocateBtn[$highAllocateBtnkey]['btnkey'] = $highAllocateBtnkey;
				//公海平均分配
				$highAllocateBtn[$avghighAllocateBtnkey]['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
				$highAllocateBtn[$avghighAllocateBtnkey]['permit'] = $Allocatepermit;
				$highAllocateBtn[$avghighAllocateBtnkey]['btnkey'] = $avghighAllocateBtnkey;
				$this->list_buttons['massallocate']['list'] = $highAllocateBtn;
			}
		}	
		return $this->list_buttons;
	}
	/**
	 * 公海按钮合并
	 * @author Tujt 2015-06-03
	 */
	public function setPublicDetailBtn($publicaccount_btn) {
	   if(isSearchCRMVersion()=='yes')
       {
        return '';//查询版
       }
		//获取第一个元素
		$btn = array();
		foreach($publicaccount_btn as $key=>$label){
			$btn[$key]['label'] = $label;
			$btn[$key]['permit'] = 'yes';
		}
		$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,1);
		$isMore = 0;
		foreach($this->detail_buttons['More']['list'] as $actionname => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$isMore = 1;
				break;
			}
		}
		if(1 == $isMore)
			$this->detail_buttons['More']['permit'] = 'yes';
		else 
			$this->detail_buttons['More']['permit'] = 'no';
		return $this->detail_buttons;
	}
	/**
	 * 调用公共基础按钮，并给新建按钮添加下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
	   global $current_user;
		parent::getListBasicBtn();//调用父类方法
		$module = self::$module;$btn = array();
        $version_info = getVersionInfo();

        $allocateBtn=array();
		$sys61=getSys_deploy(61);
        //分配
		if($sys61['deploy_value'] == 'part'){
			$allocateBtnkey = 'seniorAllocate';
		}else{
			$allocateBtnkey = 'distribution';
		}
		$allocateBtn[$allocateBtnkey]['label'] = getFixedLabel('ALLOCATE');
		$allocateBtn[$allocateBtnkey]['permit'] = 'yes';
		$allocateBtn[$allocateBtnkey]['btnkey'] = $allocateBtnkey;
        $regobj=RegOp::getInstance();
        if($regobj->GetVersionNo()==58)
        {
            $allocateBtn="";
        }
        else
       	{
			//平均分配
			if($sys61['deploy_value'] == 'part'){
				$avgallocateBtnkey = 'seniorAverageAllocate';
			}else{
				$avgallocateBtnkey = 'averageDistribution';
			}
			$allocateBtn[$avgallocateBtnkey]['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
			$allocateBtn[$avgallocateBtnkey]['permit'] = 'yes';
			$allocateBtn[$avgallocateBtnkey]['btnkey'] = $avgallocateBtnkey;
           	if ($version_info['account'] == 'shenglawei') {
               //自动分配
               $allocateBtn['autoDistribution']['label'] = getFixedLabel('AUTODISTRIBUTION');
               $allocateBtn['autoDistribution']['permit'] = 'yes';
               $allocateBtn['autoDistribution']['btnkey'] = 'autoDistribution';
           	}
       	}
        $this->list_buttons['Allocate']['list'] = $allocateBtn;
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='submitapprove')
            {
           	    $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
        		$tmp_list_buttons['Datadupcheck']['permit'] = isPermitted('Accounts','accountdatadup');
        		$tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
        }
        $this->list_buttons=$tmp_list_buttons;
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();//调用父类方法

		//客户资料审批完成后是否允许进行编辑 
		if(!empty($this->controller->id)){
			global $adb,$current_user;
			$query = 'select approvestatus,publicaccount,pool_id,completed,smownerid from ld_account where accountid = ?';
			$result = $adb->pquery($query,array($this->controller->id));
			$approvestatus = $adb->query_result($result,0,0);
			$publicaccount = $adb->query_result($result,0,'publicaccount');
            $completed = $adb->query_result($result,0,'completed');
            $pool_id = $adb->query_result($result,0,'pool_id');
            $smownerid = $adb->query_result($result,0,'smownerid');

            crm_load_class_file('cls_publicpool_profile','include/utils');
            $pool_profileobj = new cls_publicpool_profile('Accounts',$current_user->id,$pool_id);

            //edit:can 20210923 48052: （http://112.25.149.14:888/crm [^] ）(苏州磐力风机制造有限公司)客户（测试）在审批通过之后依旧可以编辑，审批流程设置了审批通过之后不允许编辑
			/*if($approvestatus == constant('D_A_S_APPROVED')){
				$deployarray=getSys_deploy(16);
				if($deployarray['deploy_value'] == 0){
					$this->detail_buttons['Edit']['permit'] = 'yes';
				}
			}*/
			//如果是普通客户，并且公海参数允许创建普通客户为‘否’ 则隐藏复制按钮
			if(empty($publicaccount)){
				crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
				$cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
				$public_account = $cls_PublicAccounts->getPublicAccount();
				if($public_account['status'] == 'yes' && $public_account['is_commonaccount_create'] == 'no'){
					$this->detail_buttons['Copy']['permit'] = 'no';
				}
			}
            else{
				// 2024-10-09 xxy 详情页按钮增加排序，需要先列出所有公海按钮
				$this->detail_buttons['accountdelay']['label'] = getFixedLabel('ACCOUNTDELAY');//延期
				$this->detail_buttons['accountdelay']['permit'] = 'no';
				$this->detail_buttons['accountrelease']['label'] = getFixedLabel('RELEASE');//释放
				$this->detail_buttons['accountrelease']['permit'] = 'no';
				$this->detail_buttons['receive']['label'] = getFixedLabel('RECEIVE');//领取
				$this->detail_buttons['receive']['permit'] = 'no';
                //zkt 20240123 XUQIU20240112-05 公海未分配客户详情页增加领取，加到分配后面位于第三个公海已分配客户详情页增加延期和释放，先加到最后面
                //公海已分配、公海未分配显示按钮，领取、释放、延期，$publicaccount=2公海已分配，$publicaccount=1公海已分配，
                $public_account_pool = $this->controller->getpublicaccountpool();
                $adminaccount = $public_account_pool[$pool_id]['administrators'];	//公海管理员
                $cur_poolinfo = $public_account_pool[$pool_id];
                if(!empty($adminaccount)) $splitadmin = explode(',',$adminaccount);
                if(!empty($public_account_pool)){
                    switch($publicaccount){
                        case '3'://公海已分配
                        case '2'://公海已分配
                            unset($this->detail_buttons['accountdelay']);
                            unset($this->detail_buttons['accountrelease']);
                            $btn = array();
                            //延期按钮权限判断
                            if(in_array($current_user->id,$splitadmin) && $completed != '已完成'){
                                $this->detail_buttons['accountdelay']['label'] = getFixedLabel('ACCOUNTDELAY');//延期
                                $this->detail_buttons['accountdelay']['permit'] = $pool_profileobj->check_poolbtn_permit('delay');
                            }
                            //释放按钮权限判断
                            if(in_array($current_user->id,$splitadmin)){
                                $release_premit = $pool_profileobj->check_poolbtn_permit('release');
                            }else{
                                if($cur_poolinfo['releasetype'] == 'unlimit'){
                                    $release_premit = 'yes';
                                }else if($cur_poolinfo['releasetype'] == 'self' && $current_user->id == $smownerid){
                                    $release_premit = 'yes';
                                }else{
                                    $release_premit = 'no';
                                }
                            }
                            $this->detail_buttons['accountrelease']['label'] = getFixedLabel('RELEASE');//释放
                            $this->detail_buttons['accountrelease']['permit'] = $release_premit;
                            break;
                        case '1'://公海未分配
                            //添加领取按钮
                            $btn = $this->getReceiveBtn($public_account_pool,$pool_id);
                            if(!empty($btn)){
                                unset($this->detail_buttons['receive']);
                                if(count($this->detail_buttons)>=2){
                                    $this->detail_buttons = f_array_insert($this->detail_buttons,$btn,2);
                                }
                                else{
                                    $this->detail_buttons['receive'] = $btn['receive'];
                                }
                            }
                            break;
                    }
                }
            }
		}
		$btnkeys = array_keys($this->detail_buttons);
		if(in_array('Allocate',$btnkeys) || in_array('Share',$btnkeys) || in_array('massallocate',$btnkeys)){
			$sys61=getSys_deploy(61);
			foreach ($btnkeys as $index => &$btnkey) {
				if($sys61['deploy_value'] == 'part'){
					if($btnkey=='Allocate'){
						$btnkey = 'seniorAllocate';
					}
					if($btnkey=='massallocate'){
						$btnkey = 'seniorHigndistribution';
					}
					if($btnkey=='Share'){
						$btnkey = 'seniorShare';
					}
				}
			}
			$this->detail_buttons = array_combine($btnkeys,$this->detail_buttons);
		}

	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();

		$btnkeys = array_keys($this->detail_buttons['More']['list']);
		if(in_array('Share',$btnkeys)){
			foreach ($btnkeys as $index => &$btnkey) {
				$sys61=getSys_deploy(61);
				if($sys61['deploy_value'] == 'part'){
					if($btnkey=='Share'){
						$btnkey = 'seniorShare';
						break;
					}
				}
			}
			$this->detail_buttons['More']['list'] = array_combine($btnkeys,$this->detail_buttons['More']['list']);
		}
	}
	/**
	 * 获取客户当前公海客户类型
	 * @author Tujt 2015-06-29
	 */
	public function getPublicAccountType() {
	    global $current_user;
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
		$public_account = $cls_PublicAccounts->getPublicAccount();
//        ls 2021-09-06  【ID1001938】销售线索和客户模块，多公海“全部”页签增加默认值显示
        if($public_account['status'] == 'yes') {
            if($public_account['showpublicmodule'] == 'yes'){
                $publicmoduletype = $this->get_publicmoduletype();
            }
            $list_tab_obj = cls_module_list_tab::getInstance('Accounts');
            $accounttype = $list_tab_obj->get_defualt_tab($publicmoduletype);
        }else{
            $accounttype='ALLACCOUNT';
        }
		/*if($public_account['status'] == 'yes' && $public_account['show_publicaccount_tab'] == 'yes'){
			$accounttype='ALLACCOUNT';//显示并且默认 “全部（含所有公海）”页签 
		}else{
			$accounttype='DEFAULTALLACCOUNT';//全部（含指定公海）
		}*/

		if(isset($_REQUEST['pagepublicaccounttype'])){
			$accounttype = $_REQUEST['pagepublicaccounttype'];
		}elseif(isset($_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'])){//登录crm后首页关键视图组件getKeyMetrics() 有给session赋值的动作导致设置的默认值不生效，所以调用该方法之前清除session
			$accounttype = $_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'];
		}

        if($accounttype == 'COMMONACCOUNT' && $public_account['status'] == 'yes' && $public_account['show_commonaccount_tab'] == 'no'){
            $accounttype = 'ALLACCOUNT';
        }

        if ($accounttype == 'NOALLOCATE' && $public_account['status'] == 'yes') {
            $public_account_info = $cls_PublicAccounts->getPublicAccountConfig();
            if(!empty($_REQUEST['pool_id'])) {
                $current_public_account_pool = $public_account_info['public_account_pool'][$_REQUEST['pool_id']];
            }else if(!empty($_SESSION['lvsAccount']["Accounts"]['pool_id'])){
                $current_public_account_pool = $public_account_info['public_account_pool'][$_SESSION['lvsAccount']["Accounts"]['pool_id']];
            }else{
                $current_public_account_pool = current($public_account_info['public_account_pool']);
//              ls 2021-09-18  0048009: （81mis.com/kfbcrm）客户管理》客户，非公海成员yhaic，在客户列表处，显示有很多个“全部”数据分类(数据分类getCvlistByUser()缺少默认公海池pool_id)
                $_SESSION['lvsAccount']["Accounts"]['pool_id'] = key($public_account_info['public_account_pool']);
            }
            //基本查询 回跳转到全部含公海页面 edit:can 20220228 
            /*$allowget = $current_public_account_pool['allowget'];// allowget为no，表示没有打钩，允许领取公海未分配客户
            $administrators_arr = explode(',',$current_public_account_pool['administrators']);
            if ($allowget == 'yes' && !in_array($current_user->id,$administrators_arr)) {
                $accounttype = 'ALLACCOUNT';
            }*/
            
        }

		if($accounttype == 'ALLACCOUNT' && $public_account['status'] == 'yes' && $public_account['show_publicaccount_tab'] == 'no'){
			$accounttype = 'DEFAULTALLACCOUNT';
		}
		return $_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'] = $accounttype;
	}
    public function getallListViewLink() {
        $btn =array();
        $seastatus = $this->controller->getaccountstatus();
        if('yes' == $seastatus){
            $btn['allpublictaccount']['label'] = getFixedLabel('Transfer');//转换公海
            $btn['accountdelay']['label'] = getFixedLabel('ACCOUNTDELAY');//延期
            $btn['accountrelease']['label'] = getFixedLabel('RELEASE');
            $btn['highseas']['label'] = getFixedLabel('ALLOCATE');//分配
            $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
        }
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        if(vtlib_isModuleActive('ContactRecords')){
            $btn['followup']['label'] = getFixedLabel('FOLLOWUP');//跟进
        }
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		global $current_user;
		$btn = array();
		unset($this->listview_link['followup']);
		//跟进
		$btn['followup']['label'] = getFixedLabel('FOLLOWUP');//跟进
		$btn['followup']['permit'] = isPermitted('ContactRecords','Create');//是否有联系记录的创建权限
		global $related_left_record;
		if(empty($related_left_record)) $related_left_record = 0;
		$btn['followup']['click'] = 'CreateContactRecordsByAccounts(this,\''.$related_left_record.'\',\'%d\',\'Accounts\',\'index\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['followup']);
        }
        $cur_userid = $current_user->id;
		$btn = array();
        $query = 'select completed,pool_id,smownerid from ld_account where accountid = ? and deleted = 0 limit 1';
		$res = $this->db->pquery($query,array($record));
		if($this->db->num_rows($res) >= 1){
			$completed = $this->db->query_result($res,0,'completed');
			$pool_id = $this->db->query_result($res,0,'pool_id');
			$smownerid = $this->db->query_result($res,0,'smownerid');
		}

        crm_load_class_file('cls_publicpool_profile','include/utils');
        $pool_profileobj = new cls_publicpool_profile('Accounts',$current_user->id,$pool_id);
        
		//开启公海客户，并且不是相关信息
		if('yes' == $this->controller->getaccountstatus() && 0 == $this->listview_link['edit']['related']){
			$accounttype = $this->getPublicAccountType();
			$public_account_pool = $this->controller->getpublicaccountpool();
			$cur_poolinfo = $public_account_pool[$pool_id];
			$adminaccount = $cur_poolinfo['administrators'];	//公海管理员
			$usersaccount = $cur_poolinfo['userids'];	//公海普通用户
 
            $allow_users = $cur_poolinfo['allow_users'];
			$allowget = $cur_poolinfo['allowget'];	// 不允许领取公海未分配客户，只能由公海管理员分配
			$splitadmin = [];
			$splituser = [];
			$allow_users_arr = [];
			if(!empty($adminaccount)) $splitadmin = explode(',',$adminaccount);
			if(!empty($usersaccount)) $splituser = explode(',',$usersaccount);
			if(!empty($allow_users)) $allow_users_arr = explode(',',$allow_users);
			$publicaccount = $this->db->query_result($result,$idx,'publicaccount');//状态;
			switch($accounttype){
			    case 'ALLACCOUNT'://全部(含公海)
			    case 'DEFAULTALLACCOUNT'://全部(含公海)
			    case 'COMMONACCOUNT'://全部(不含公海)
					//塞可，工单序时簿界面，操作列中的转普通、转公海按钮隐藏
					$version_info = getVersionInfo();
					if($version_info['account'] != 'saic'){
						/*if(0 == $publicaccount){//转公海
                        //公海/非公海管理成员增加将客户转公海功能  
                        	if(is_admin($current_user) || ((!empty($splitadmin) && in_array($current_user->id,$splitadmin))
                            ||(!empty($splituser) && in_array($current_user->id,$splituser))))
                            {
    							$btn['allpublictaccount']['label'] = getFixedLabel('TURNHIGHSEAS');//转公海
    							$btn['allpublictaccount']['click'] = 'convertaccount(\''.$start.'\',%d,1)';
								$btn['allpublictaccount']['permit'] = 'yes';
                            }
						}else{
							if(is_admin($current_user) || ((!empty($splitadmin) && in_array($current_user->id,$splitadmin))) || ((!empty($splitadmin) && in_array($current_user->id,$splitadmin))))
                            {
                                
    							$btn['allpublictaccount']['label'] = getFixedLabel('TURNORDINARY');//转普通
    							$btn['allpublictaccount']['click'] = 'convertaccount(\''.$start.'\',%d,0)';
								$btn['allpublictaccount']['permit'] = 'yes';
							}
						}*/
//                        @edit:liushuai,2021-07-09,reason:【ID1001735】公海成员，普通销售线索和普通客户增加“转公海”功能(公海成员显示“转换公海”操作按钮,若没有编辑权限则不显示，若客户是公海未分配客户也不显示，
//                      但是如果客户是公海已分配客户，并且该客户“所属公海”的参数设置勾选了“允许公海成员将已分配或领取的公海客户移客户到其他公海”时，也显示“转换公海”按钮)
						$cls_PublicAccounts = cls_PublicAccounts::getInstance($this->controller->module_name);
                        if($cls_PublicAccounts->isHavePublicPage()=='yes')
                            if($pool_id == 0){
                                $transfer_permit = 'yes';
                            }else if(in_array($current_user->id,$splitadmin)){
                                //公海管理员允许转换公海和转换普通成员
                                $transfer_permit = $pool_profileobj->check_poolbtn_permit('turnhighseas');
                                if($transfer_permit == 'no'){
                                    $transfer_permit = $pool_profileobj->check_poolbtn_permit('transfercustomer');
                                }
                            }else if(($publicaccount > 1 && in_array($current_user->id,$splituser) && $cur_poolinfo['allow_trasnfer_others'] == 'yes')) {
                                //普通成员允许转换公海客户到其他公海
                                $transfer_permit = 'no';
                            }else{
                                $transfer_permit = 'no';
                            }

                            if($transfer_permit == 'yes'){//普通客户转公海 / 公海已分配客户且勾选了允许转公海时
    							$btn['allpublictaccount']['label'] = getFixedLabel('Transfer');//转换公海
    							$btn['allpublictaccount']['click'] = 'cls_PublicAccount.account_transfer(%d)';
    							$btn['allpublictaccount']['permit'] = $this->listview_link['edit']['permit'];
    						}
 

						if(isSearchCRMVersion()=='yes')
						{
							unset($btn['allpublictaccount']);
						}
						unset($this->listview_link['allpublictaccount']);
						$this->listview_link = f_array_insert($this->listview_link,$btn);
					}
			        break;
			    case 'PUBLICALLOCATE'://公海已分配
			        unset($this->listview_link['edit']);//删除编辑按钮
					global $haveDelayButton;
					if($completed != '已完成'){
						$btn['accountdelay']['label'] = getFixedLabel('ACCOUNTDELAY');//延期
						$btn['accountdelay']['click'] = 'DeskDelayaccount(\''.$start.'\',%d,this,\'delayaccount\')';
						$btn['accountdelay']['permit'] = $pool_profileobj->check_poolbtn_permit('delay');
					}
					//公海管理员要判断释放权限
					if(in_array($current_user->id,$splitadmin)){
					    $release_permit = $pool_profileobj->check_poolbtn_permit('delay');
                    }else{
					    //普通成员要根据释放权限设置
                        if($cur_poolinfo['releasetype'] == 'unlimit'){
                            $release_permit = 'yes';
                        }else if($cur_poolinfo['releasetype'] == 'self' && $cur_userid == $smownerid ){
                            $release_permit = 'yes';
                        }else{
                            $release_permit = 'no';
                        }
                    }
					$btn['accountrelease']['label'] = getFixedLabel('RELEASE');//释放
					$btn['accountrelease']['click'] = 'Releaseaccount(\''.$start.'\',%d)';
					$btn['accountrelease']['permit'] = $release_permit;

					unset($this->listview_link['accountdelay']);
					unset($this->listview_link['accountrelease']);
					$this->listview_link = f_array_insert($this->listview_link,$btn);
			        break;
				case 'NOALLOCATE'://公海未分配
					unset($this->listview_link['edit']);//删除编辑按钮
                    //ls 2021-07-23 0047107: (81mis.com/kfbcrm/)客户-默认公海参数设置里把LJX设为能公海分配的成员，但在LJX账号里没看到公海分配按钮
					if(in_array($current_user->id,$splitadmin) || (in_array($current_user->id,$splituser) && in_array($current_user->id,$allow_users_arr))){
						$btn['highseas']['label'] = getFixedLabel('ALLOCATE');//分配
						$sys61=getSys_deploy(61);
						if($sys61['deploy_value'] == 'part'){
							$btn['highseas']['click'] = 'SeniorAllocateShare.getInstance(\'Accounts\',\'seniorHigndistribution\').getPopup(%d)';
						}else{
							$btn['highseas']['click'] = 'DeskAllocatetaccount(this,\''.$start.'\',%d,\'massallocate\')';
						}
						$btn['highseas']['permit'] = 'yes';
					}
				 $tmpbtn_arr=   $this->getReceiveBtn($public_account_pool,$pool_id);
                    $btn['receive']=$tmpbtn_arr['receive'];
                    
				unset($this->listview_link['highseas']);
				unset($this->listview_link['receive']);
                if(isSearchCRMVersion()=='yes')
                {
                    unset($btn['allpublictaccount']);
                }
				$this->listview_link = f_array_insert($this->listview_link,$btn);
             
				   break;
			}
		}
          
	}
    
    
    public function getReceiveBtn($public_account_pool,$pool_id)
    {
        global $current_user;
        
    	$adminaccount = $public_account_pool[$pool_id]['administrators'];	//公海管理员
		$usersaccount = $public_account_pool[$pool_id]['userids'];	//公海普通用户

        $allow_users = $public_account_pool[$pool_id]['allow_users'];
		$allowget = $public_account_pool[$pool_id]['allowget'];	// 不允许领取公海未分配客户，只能由公海管理员分配
        
    	if(!empty($adminaccount)) $splitadmin = explode(',',$adminaccount);
    	if(!empty($usersaccount)) $splituser = explode(',',$usersaccount);
    	if(!empty($allow_users)) $allow_users_arr = explode(',',$allow_users);
         if($allowget == 'yes'){
    		if(in_array($current_user->id,$splitadmin)){
    			$btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
    			$btn['receive']['click'] = 'Allocatetaccount(\''.$start.'\',%d,3)';
    			$btn['receive']['permit'] = 'yes';
    		}
       }else{
    		if(in_array($current_user->id,$splitadmin) || in_array($current_user->id,$splituser)){
    			$btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
    			$btn['receive']['click'] = 'Allocatetaccount(\''.$start.'\',%d,3)';
    			$btn['receive']['permit'] = 'yes';
    		}
       }
       
       return $btn;
    }
}
?>