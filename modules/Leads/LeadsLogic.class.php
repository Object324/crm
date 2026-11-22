<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class LeadsLogic extends BaseLogic {
    public $publicmoduletype;

    /**
	 * 调用公共更多下拉列表，并添加客户相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
	   global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;$is_email = 'no';$is_sms = 'no';
		$more_idx = 0;$btn = array();

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
					$tmp_more_list_buttons['leadsaccountset']=array("label"=>getFixedLabel('LBL_ACCOUNT_SET'),  'permit' => 'yes');
				}
			}
            $tmp_more_list_buttons[$btname]=$content;
            if($btname == 'ChangeCreator'){
                //自动查重合并
                $dup_and_merge_permit = 'no';
                if('yes' == isPermitted($module, 'dup_and_merge','')){
                    $dup_and_merge_permit = 'yes';
                }
                $btn = array();
                $btn['label'] = getFixedLabel('CHECKMERGE');
                $btn['permit'] = $dup_and_merge_permit;
                $tmp_more_list_buttons['Findduplicates']=$btn;
                //合并
                $btn = array();
                $merge_permit = 'no';
                if('yes' == isPermitted($module, 'Merge','')){
                    $merge_permit = 'yes';
                }
                $btn['label'] = getFixedLabel('Merge');
                $btn['permit'] = $merge_permit;
                $tmp_more_list_buttons['RecordMerge']=$btn;
            }
            if($btname=='mass_edit')
            {
                $tmp_more_list_buttons['submitapprove']=$this->list_buttons['submitapprove'];
                unset($this->list_buttons['submitapprove']);
            }
        }
        if(empty($tmp_more_list_buttons['ChangeCreator'])){
            if(empty($tmp_more_list_buttons['Findduplicates'])){
                //自动查重合并
                $dup_and_merge_permit = 'no';
                if('yes' == isPermitted($module, 'dup_and_merge','')){
                    $dup_and_merge_permit = 'yes';
                }
                $btn = array();
                $btn['label'] = getFixedLabel('CHECKMERGE');
                $btn['permit'] = $dup_and_merge_permit;
                $tmp_more_list_buttons['Findduplicates']=$btn;
            }
            if(empty($tmp_more_list_buttons['RecordMerge'])) {
                //合并
                $btn = array();
                $merge_permit = 'no';
                if ('yes' == isPermitted($module, 'Merge', '')) {
                    $merge_permit = 'yes';
                }
                $btn['label'] = getFixedLabel('Merge');
                $btn['permit'] = $merge_permit;
                $tmp_more_list_buttons['RecordMerge'] = $btn;
            }
        }
		$this->list_buttons['More']['list']=$tmp_more_list_buttons;


        if($this->setlistbutton == 'yes'){
            $this->list_buttons['transfer']['label'] =getFixedLabel('Transfer');
            $this->list_buttons['leadsmassrelease']['label'] =getFixedLabel('BATCHRELEASE');//批量释放
            $this->list_buttons['leadsmassget']['label'] =getFixedLabel('RECEIVE');  //批量领取
            $this->list_buttons['leadsnoallocateconvertnormal']['label'] =getFixedLabel('Transfer');
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
		$administrators_arr = array();
		$userids_arr = array();
		$allow_user_permit = 'no';	//允许“公海分配”的成员 
		if(empty($pool_id)){
			if($accounttype=='ALLACCOUNT' || $accounttype=='DEFAULTALLACCOUNT')
			{
				
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
			$administrators_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['administrators']);
			$allow_users_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['allow_users']);
			$transfer_users_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['transfer_users']);
			$userids_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['userids']);
			$usertype = $public_account['public_account_pool'][$pool_id]['usertype'];
			//更多-批量释放
            $cur_userid = $current_user->id;
            crm_load_class_file('cls_publicpool_profile','include/utils');
            $pool_profileobj = new cls_publicpool_profile('Leads',$cur_userid,$pool_id);

            if($accounttype=='PUBLICALLOCATE' && ($public_account['public_account_pool'][$pool_id]['releasetype'] != 'no'  || in_array($cur_userid,$administrators_arr)) )
            {
                if(in_array($current_user->id,$administrators_arr)){
                    $permit = $pool_profileobj->check_poolbtn_permit('release');
                }else{
                    $permit = 'yes';
                }
				$btn['leadsmassrelease']['label'] =getFixedLabel('BATCHRELEASE');
				$btn['leadsmassrelease']['permit'] = 'yes';
			}
			if(!empty($userids_arr) && in_array($current_user->id,$allow_users_arr)){
				$allow_user_permit = 'yes';	
			}
			//$pool_id = 1;
			//更多-批量领取
			if(!empty($public_account['public_account_pool'][$pool_id])){
				if($accounttype=='NOALLOCATE' && ($public_account['public_account_pool'][$pool_id]['allowget'] == 'no' || in_array($current_user->id,$administrators_arr))){
					$btn['leadsmassget']['label'] =getFixedLabel('RECEIVE');
					$btn['leadsmassget']['permit'] = 'yes';
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
                        if(in_array($current_user->id,$userids_arr) && $allow_trasnfer_others == 'yes'){
                            $noallocateconvertnormal_permit = 'yes';
                        }
					} elseif (in_array($current_user->id,$userids_arr) && $accounttype != 'NOALLOCATE'){
                        //公海成员，未分配页签不显示，全部页签显示
                        $noallocateconvertnormal_permit = 'yes';
                    }
				}
				$btn['leadsnoallocateconvertnormal']['label'] =getFixedLabel('Transfer');
				$btn['leadsnoallocateconvertnormal']['permit'] = $noallocateconvertnormal_permit;
			//}
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);//转换公海在批量编辑前面
			$this->list_buttons['More']['permit'] = 'yes';

			//公海成员客户序时簿“新建”功能下拉选项
			if($this->controller->getaccount_administrator() == 'yes' || in_array($current_user->id,$administrators_arr) || in_array($current_user->id,$userids_arr)){
				if($accounttype != 'COMMONACCOUNT' && $accounttype != 'DEFAULTALLACCOUNT' && $accounttype != 'ALLACCOUNT'){
					//普通客户
					$btn['public_ordinary']['label'] = getFixedLabel('AddNormalLeads');
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
                                //BUG20240126-37 ls 240130 关闭了普通线索和公海已分配,直接点新建按钮保存后为普通线索
                                $this->list_buttons['Create']['btnkey']='public_notallocated';
								$this->list_buttons['Create']['list']['public_notallocated'] = $btn['public_notallocated'];
								$this->list_buttons['Create']['list']['btnkey'] = 'public_notallocated';
							}else if($btntype == 'PUBLICALLOCATE'){	//公海已分配
								//33797:客户模块：设置公海客户数量上限参数后，新建公海客户数量超出上限数量参数点击保存时，没有弹出新建客户数量已超出上限数量提示信息
								$this->list_buttons['Create']['btnkey']='public_allocated';
								$this->list_buttons['Create']['list']['public_allocated'] = $btn['public_allocated'];
								$this->list_buttons['Create']['list']['btnkey'] = 'public_notallocated';
							}
						}
					}
//                    @edit:liushuai,2021-07-19,reason:【ID1001466】公海参数配置“公海成员客户序时簿“新建”功能下拉选项”去掉必填项控制
                    if ($public_account['status'] == 'yes' && $create_commonaccount == 'no' && empty($buttontype_array)) {
                        unset($this->list_buttons['Create']);
                    }
				}
			}
			//公海分配、公海平均分配
			if($accounttype=='NOALLOCATE'){
				/*
			    if(in_array($current_user->id,$administrators_arr) || $allow_user_permit == 'yes'){
					$Allocatepermit = 'yes';
				}else{
					$Allocatepermit='no';
				}
				*/
                $Allocatepermit = $pool_profileobj->check_poolbtn_permit('Allocate');

				$Allocate = 'leadsmassallocate';
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
				//公海分配
				$highAllocateBtn['leadshigndistribution']['label'] = getFixedLabel('ALLOCATE');
				$highAllocateBtn['leadshigndistribution']['permit'] = $Allocatepermit;
				$highAllocateBtn['leadshigndistribution']['btnkey'] = 'leadshigndistribution';
				//公海平均分配
				$highAllocateBtn['leadsaveragehigndistribution']['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
				$highAllocateBtn['leadsaveragehigndistribution']['permit'] = $Allocatepermit;
				$highAllocateBtn['leadsaveragehigndistribution']['btnkey'] = 'leadsaveragehigndistribution';
				$this->list_buttons['leadsmassallocate']['list'] = $highAllocateBtn;
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
        $allocateBtn=array();
        //分配
        $allocateBtn['distribution']['label'] = getFixedLabel('ALLOCATE');
        $allocateBtn['distribution']['permit'] = 'yes';
        $allocateBtn['distribution']['btnkey'] = 'distribution';
        $regobj=RegOp::getInstance();
        if($regobj->GetVersionNo()==58)
        {
            $allocateBtn="";
        }
        else
       {
             //平均分配
            $allocateBtn['leadsaverageDistribution']['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
            $allocateBtn['leadsaverageDistribution']['permit'] = 'yes';
            $allocateBtn['leadsaverageDistribution']['btnkey'] = 'leadsaverageDistribution';
       }
        $this->list_buttons['Allocate']['list'] = $allocateBtn;
        $tmp_list_buttons=array();
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Delete')
            {
                //查重
                $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
                $tmp_list_buttons['Datadupcheck']['permit'] = isPermitted($module,'accountdatadup');
                $tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
        }

        $this->list_buttons=$tmp_list_buttons;
       
	}
 
    //zl XUQIU1001207 销售线索升级隐藏编辑和推进按钮
    public function getEditViewBtn()
    {
        global $adb;
        $buttons = parent::getEditViewBtn();//调用父类方法
        if(!empty($this->controller->id)){
            $query = 'select upgradeaccountid,status from ld_leads where leadsid = ?';
            $result = $adb->pquery($query,array($this->controller->id));
            $upgradeaccountid = $adb->query_result($result,0,'upgradeaccountid');
            if(!empty($upgradeaccountid)){
                $buttons['permit'] = 'no';
                $this->edit_errorreason=array('reason'=>'','description'=>"已升级不可编辑");
            }
        }
        return $buttons;
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
			$query = 'select approvestatus,publicaccount,upgradeaccountid,status,pool_id,completed,smownerid from ld_leads where leadsid = ?';
			$result = $adb->pquery($query,array($this->controller->id));
			$approvestatus = $adb->query_result($result,0,0);
			$publicaccount = $adb->query_result($result,0,'publicaccount');
            $upgradeaccountid = $adb->query_result($result,0,'upgradeaccountid');
            $pool_id = $adb->query_result($result,0,'pool_id');
            $completed = $adb->query_result($result,0,'completed');
            $smownerid = $adb->query_result($result,0,'smownerid');

            crm_load_class_file('cls_publicpool_profile','include/utils');
            $pool_profileobj = new cls_publicpool_profile('Leads',$current_user->id,$pool_id);

			if($approvestatus == constant('D_A_S_APPROVED')){
				$deployarray=getSys_deploy(16);
				if($deployarray['deploy_value'] == 0){
					$this->detail_buttons['Edit']['permit'] = 'yes';
				}
			}
            //zl XUQIU1001207 销售线索升级隐藏编辑和推进按钮
            if(!empty($upgradeaccountid)){
                $this->detail_buttons['Edit']['permit'] = 'no';
                $this->detail_buttons['Advance']['permit'] = 'no';
            }
			//如果是普通客户，并且公海参数允许创建普通客户为‘否’ 则隐藏复制按钮
			if(empty($publicaccount)){
				crm_load_class_file('cls_PublicLeads', 'modules/Leads');
				$cls_PublicAccounts = new cls_PublicLeads('Leads');
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
                $allowget = $public_account_pool[$pool_id]['allowget'];	// 不允许领取公海未分配客户，只能由公海管理员分配

                $splitadmin = [];
                $splituser = [];
                if(!empty($adminaccount)) $splitadmin = explode(',',$adminaccount);
                if(!empty($usersaccount)) $splituser = explode(',',$usersaccount);
                if(!empty($public_account_pool)){
                    switch($publicaccount){
                        case '3'://公海已分配
                        case '2'://公海已分配
                            unset($this->detail_buttons['accountdelay']);
                            unset($this->detail_buttons['accountrelease']);
                            if(in_array($current_user->id,$splitadmin) && $completed != '已完成'){
                                $this->detail_buttons['accountdelay']['label'] = getFixedLabel('ACCOUNTDELAY');//延期
                                $this->detail_buttons['accountdelay']['permit'] = $pool_profileobj->check_poolbtn_permit('delay');
                            }
                            //释放按钮权限判断
                            if(in_array($current_user->id,$splitadmin)){
                                $release_premit = $pool_profileobj->check_poolbtn_permit('release');
                            }else{
                                if($public_account_pool[$pool_id]['releasetype'] == 'unlimit'){
                                    $release_premit = 'yes';
                                }else if($public_account_pool[$pool_id]['releasetype'] == 'self' && $current_user->id == $smownerid){
                                    $release_premit = 'yes';
                                }else{
                                    $release_premit = 'no';
                                }
                            }
                            $this->detail_buttons['accountrelease']['label'] = getFixedLabel('RELEASE');//延期
                            $this->detail_buttons['accountrelease']['permit'] = $release_premit;
                            break;
                        case '1'://公海未分配
                            //添加领取按钮
                            $btn = array();
                            if($allowget == 'yes'){
                                if(in_array($current_user->id,$splitadmin)){
                                    $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
                                    $btn['receive']['permit'] = 'yes';
                                }
                            }else{
                                if(in_array($current_user->id,$splitadmin) || in_array($current_user->id,$splituser)){
                                    $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
                                    $btn['receive']['permit'] = 'yes';
                                }
                            }
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
		
	}
	/**
	 * 获取客户当前公海客户类型
	 * @author Tujt 2015-06-29
	 */
	public function getPublicAccountType() {
        global $current_user;
		crm_load_class_file('cls_PublicLeads', 'modules/Leads');
		$cls_PublicAccounts = new cls_PublicLeads('Leads');
		$public_account = $cls_PublicAccounts->getPublicAccount();
//        ls 2021-09-06  【ID1001938】销售线索和客户模块，多公海“全部”页签增加默认值显示
        if($public_account['status'] == 'yes') {
            if($public_account['showpublicmodule'] == 'yes'){
                $publicmoduletype = $this->get_publicmoduletype();
            }
            $list_tab_obj = cls_module_list_tab::getInstance('Leads');
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
		}elseif(isset($_SESSION['lvsAccount']['Leads']['pagepublicaccounttype'])){
			$accounttype = $_SESSION['lvsAccount']['Leads']['pagepublicaccounttype'];
		}

        if($accounttype == 'COMMONACCOUNT' && $public_account['status'] == 'yes' && $public_account['show_commonaccount_tab'] == 'no'){
            $accounttype = 'ALLACCOUNT';
        }

        if ($accounttype == 'NOALLOCATE' && $public_account['status'] == 'yes') {
            $public_account_info = $cls_PublicAccounts->getPublicAccountConfig();
            if(!empty($_REQUEST['pool_id'])) {
                $current_public_account_pool = $public_account_info['public_account_pool'][$_REQUEST['pool_id']];
            }else if(!empty($_SESSION['lvsAccount']["Leads"]['pool_id'])){
                $current_public_account_pool = $public_account_info['public_account_pool'][$_SESSION['lvsAccount']["Leads"]['pool_id']];
            }else{
                $current_public_account_pool = current($public_account_info['public_account_pool']);
                $_SESSION['lvsAccount']["Leads"]['pool_id'] = key($public_account_info['public_account_pool']);
            }
            //zkt 20220530 52307（亿海蓝）http://124.70.16.104:85/crm/,销售线索-公海管理。在公海未分配页签，使用查询条件，点击查询后，页签会自动跳转到全部（含公海页签），详细见附件视频
            /*$allowget = $current_public_account_pool['allowget'];// allowget为no，表示没有打钩，允许领取公海未分配客户
            $administrators_arr = explode(',',$current_public_account_pool['administrators']);
            if ($allowget == 'yes' && !in_array($current_user->id,$administrators_arr)) {
                $accounttype = 'ALLACCOUNT';
            }*/
        }

		if($accounttype == 'ALLACCOUNT' && $public_account['status'] == 'yes' && $public_account['show_publicaccount_tab'] == 'no'){
			$accounttype = 'DEFAULTALLACCOUNT';
		}
		return $_SESSION['lvsAccount']['Leads']['pagepublicaccounttype'] = $accounttype;
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
            $btn['Follow']['label'] = getFixedLabel('FOLLOWUP');//跟进
        }
        if(isPermitted('Leads','Advance','') == 'yes') {
            $btn['Advance']['label'] = getFixedLabel('ADVANCE');
        }
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		global $current_user;
        global $adb;
        $sql='select upgradeaccountid from ld_leads where leadsid=?  ';
        $result=$adb->pquery($sql,array($record));
        $upgradeaccountid = $adb->query_result($result,0,'upgradeaccountid');
		//hjz 销售线索列表界面增加跟进按钮
		parent::setListViewLink($result,$record,$start,$idx) ;

        //zl XUQIU1001207 销售线索升级后操作列没有编辑
        if($upgradeaccountid !== '0'){
            $this->listview_link['edit']['permit'] = 'no';
        }
        $this->listview_link['Follow']['label'] = getFixedLabel('FOLLOWUP');
        $this->listview_link['Follow']['permit'] = isPermitted('ContactRecords','Create');;
        $this->listview_link['Follow']['click'] = 'CreateContactRecordsByAccounts(this,\''.$related_left_record.'\',\'%d\',\'Leads\',\'index\')';
        $this->listview_link['Follow']['type'] = 'redirect';
        $this->listview_link['Follow']['result'] = array(
            'module' => $related_left_mod,
            'action' => 'ListView',
            'record' => $related_left_record
        );
        $this->listview_link['Follow']['related'] = 2;
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['Follow']);
        }
        //推进
        if(isPermitted('Leads','Advance','') == 'yes'){
            $this->listview_link['Advance']['label'] = getFixedLabel('ADVANCE');
            $this->listview_link['Advance']['permit'] = 'yes';
            $this->listview_link['Advance']['click'] = 'check_advance_click(this,\''.self::$module.'\',\'%d\',\'list\')';
            $this->listview_link['Advance']['type'] = 'redirect';
            $this->listview_link['Advance']['result'] = array(
                'module' => $related_left_mod,
                'action' => 'ListView',
                'record' => $related_left_record
            );
            $this->listview_link['Advance']['related'] = 1;

            //zl XUQIU1001207 销售线索升级后操作列没有推进
            if($upgradeaccountid !== '0')
            {
                $this->listview_link['Advance']['permit'] = 'no';
            }

        }

        $btn = array();
        $query = 'select completed,pool_id,smownerid from ld_leads where leadsid = ? and deleted = 0 limit 1';
		$res = $this->db->pquery($query,array($record));
		if($this->db->num_rows($res) >= 1){
			$completed = $this->db->query_result($res,0,'completed');
			$pool_id = $this->db->query_result($res,0,'pool_id');
			$smownerid = $this->db->query_result($res,0,'smownerid');
		}
        crm_load_class_file('cls_publicpool_profile','include/utils');
        $pool_profileobj = new cls_publicpool_profile('Leads',$current_user->id,$pool_id);

		//开启公海客户，并且不是相关信息
		if('yes' == $this->controller->getaccountstatus() && 0 == $this->listview_link['edit']['related']){
			$accounttype = $this->getPublicAccountType();
			$public_account_pool = $this->controller->getpublicaccountpool();
			$adminaccount = $public_account_pool[$pool_id]['administrators'];	//公海管理员
			$usersaccount = $public_account_pool[$pool_id]['userids'];	//公海普通用户
            $allow_users = $public_account_pool[$pool_id]['allow_users'];
			$allowget = $public_account_pool[$pool_id]['allowget'];	// 不允许领取公海未分配客户，只能由公海管理员分配

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
//                        @edit:liushuai,2021-07-09,reason:【ID1001735】公海成员，普通销售线索和普通客户增加“转公海”功能(公海成员显示“转换公海”操作按钮,若没有编辑权限则不显示，可参考客户模块)
                        if($pool_id == 0){
                            $transfer_permit = 'yes';
                        }else if(in_array($current_user->id,$splitadmin)){
                            //公海管理员允许转换公海和转换普通成员
                            $transfer_permit = $pool_profileobj->check_poolbtn_permit('turnhighseas');
                            if($transfer_permit == 'no'){
                                $transfer_permit = $pool_profileobj->check_poolbtn_permit('transfercustomer');
                            }
                        }else if(($publicaccount > 1 && in_array($current_user->id,$splituser) && $public_account_pool[$pool_id]['allow_trasnfer_others'] == 'yes')) {
                            //普通成员允许转换公海客户到其他公海
                            $transfer_permit = 'no';
                        }else{
                            $transfer_permit = 'no';
                        }

                        if($transfer_permit == 'yes'){
                            $btn['allpublictaccount']['label'] = getFixedLabel('Transfer');//转换公海
                            $btn['allpublictaccount']['click'] = 'PublicLeadsObj.account_transfer(%d)';
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
						$btn['accountdelay']['click'] = 'PublicLeadsObj.DeskDelayaccount(\''.$start.'\',%d,this,\'delayaccount\')';
						$btn['accountdelay']['permit'] = $pool_profileobj->check_poolbtn_permit('delay');
					}
                    //公海管理员要判断释放权限
                    if(in_array($current_user->id,$splitadmin)){
                        $release_permit = $pool_profileobj->check_poolbtn_permit('delay');
                    }else{
                        //普通成员要根据释放权限设置
                        if($public_account_pool[$pool_id]['releasetype'] == 'unlimit'){
                            $release_permit = 'yes';
                        }else if($public_account_pool[$pool_id]['releasetype'] == 'self' && $current_user->id == $smownerid ){
                            $release_permit = 'yes';
                        }else{
                            $release_permit = 'no';
                        }
                    }
					$btn['accountrelease']['label'] = getFixedLabel('RELEASE');//释放
					$btn['accountrelease']['click'] = 'PublicLeadsObj.Releaseaccount(\''.$start.'\',%d)';
					$btn['accountrelease']['permit'] = $release_permit;
					unset($this->listview_link['accountdelay']);
					unset($this->listview_link['accountrelease']);
					$this->listview_link = f_array_insert($this->listview_link,$btn);
			        break;
				case 'NOALLOCATE'://公海未分配
					unset($this->listview_link['edit']);//删除编辑按钮
					if(in_array($current_user->id,$splitadmin) || (in_array($current_user->id,$splituser) && in_array($current_user->id,$allow_users_arr))){
						$btn['highseas']['label'] = getFixedLabel('ALLOCATE');//分配
						$btn['highseas']['click'] = 'PublicLeadsObj.DeskAllocatetaccount(this,\''.$start.'\',%d,\'massallocate\')';
						$btn['highseas']['permit'] = 'yes';
					}
				   if($allowget == 'yes'){
						if(in_array($current_user->id,$splitadmin)){
							$btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
							$btn['receive']['click'] = 'PublicLeadsObj.Allocatetaccount(\''.$start.'\',%d,3)';
							$btn['receive']['permit'] = 'yes';
						}
				   }else{
						if(in_array($current_user->id,$splitadmin) || in_array($current_user->id,$splituser)){
							$btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
							$btn['receive']['click'] = 'PublicLeadsObj.Allocatetaccount(\''.$start.'\',%d,3)';
							$btn['receive']['permit'] = 'yes';
						}
				   }
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
}
?>