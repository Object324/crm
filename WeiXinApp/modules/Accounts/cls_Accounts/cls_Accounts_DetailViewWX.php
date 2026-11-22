<?php
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');

class cls_Accounts_DetailViewWX extends cls_DetailViewWX
{

    //名片新增时给字段添加默认值
    protected function setDefaultValue($focus)
    {
        global $current_user;
        crm_load_class_file('cls_MyCRMcrypt',"Register");
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        if(!empty($_REQUEST['cardserverId']) && !empty($_REQUEST['camcard'])){
            require_once(globalStatic::$root_directory.'expansion/camcard/cls_camcard.php');
            $camobj = new cls_camcard();
            $fieldComparison = $camobj->createViewDefaultValues($_REQUEST['camcard'],$_REQUEST['cardserverId']);
            if(!empty($fieldComparison)) {
                foreach ($focus->column_fields as $fieldname => $val) {
                    if (!empty($fieldComparison[$fieldname])) {
                        $defaultvalue = $fieldComparison[$fieldname];
                        $focus->column_fields[$fieldname] = $defaultvalue;
                    }
                }
            }
         }
         //editor:gyq_143 reason:销售线索升级为客户弹出层；  2019/9/10 13:56 ID1000604
        //代码参考自modules\Accounts\EditView.php
        $upgradefrommodule = $_REQUEST['upgradefrommodule'];
        $upgradefromid = $_REQUEST['upgradefromid'];
        $upgradestatus = $_REQUEST['upgradestatus'];
        if(!empty($upgradefrommodule) && $upgradefromid>0)
        {
            //销售线索升级
            $upgradefocus=CRMEntity::getInstance($upgradefrommodule);
            $upgradefocus->retrieve_entity_info($upgradefromid,$upgradefrommodule);
            crm_load_class_file('cls_MappingFields','modules/Leads');
            $cls_MappingFields = new cls_MappingFields($upgradefrommodule);
            //获取升级设置对应字段
            $mappingfields_info = $cls_MappingFields->getMappingFields('Accounts');
            foreach($upgradefocus->column_fields as $upgradefieldname=>$upgradevalue)
            {
                $upgradecolumnname=$upgradefocus->fieldobj->getFieldInfoBykeyValue('fieldname',$upgradefieldname,'columnname');
                $upgradefieldinfo= $mappingfields_info[$upgradecolumnname];
                //销售线索映射字段优化
                $mapped_columnname = $upgradefieldinfo['mapped_columnname'];
                if(!empty($mapped_columnname)){
                    if($mapped_columnname == 'curuser'){
                        $upgradevalue = $current_user->id;
                    }else{
                        $mapped_fieldname = $upgradefocus->fieldobj->getFieldInfoBykeyValue('columnname',$mapped_columnname,'fieldname');
                        $userid = $upgradefocus->column_fields[$mapped_fieldname];
                        if($userid>0){
                            $upgradevalue = $userid;
                        }
                    }
                }
                
                $after_upgradecolumn=$upgradefieldinfo['mapping_columnname'];//客户界面字段
                $after_upgradefieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$after_upgradecolumn,'fieldname');
                if(!empty($after_upgradefieldname))
                {
                    $focus->column_fields[$after_upgradefieldname]=$upgradevalue;
                }
            }
            //销售线索升级到客户时，根据映射关系带出附件
            $before_fieldjsondata=getAllFile_imageInfo($upgradefromid,$upgradefrommodule);
            if(sizeof($before_fieldjsondata)>0){
            	foreach($before_fieldjsondata as $tmp_column => $tmp_file_arr){
            		$upgradefieldinfo= $mappingfields_info[$tmp_column];
            		$mapping_columnname = $upgradefieldinfo['mapping_columnname'];
            		if(!empty($mapping_columnname)){
            			$tmp_mobile_fileinfo = array();
                        $uploadAttList = array();
            			foreach($tmp_file_arr as $tmp_fileinfo){
            				$tmp_arr = array();
            				$name = $tmp_fileinfo['file_name'];
            				$path= $tmp_fileinfo['file_path'];
            				$storage_location=$tmp_fileinfo['storage_location'];
            				$cloud_path=$tmp_fileinfo['cloud_path'];
            				$newfile_name=$tmp_fileinfo['newfile_name'];
                            
                            //edit: xll 2023/03/23 XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                            $isEncrypt = $tmp_fileinfo['isEncrypt'];
                            $path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($path) : $path;
                            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;
                            $name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($name) : $name;
                            
            				if($storage_location=='cos'){
            					$httppath=$cloud_path;
            				} else{
            					$httppath=$path.$newfile_name;
            				}
            				$tmp_arr = array('id'=>$tmp_fileinfo['fileid'],'path'=>$path,'storage_location'=>$storage_location,
                                'httppath'=>$httppath,'cloud_path'=>$httppath,'name'=>$name,'newfile_name'=>$newfile_name,'type'=>$tmp_fileinfo['file_type'],
                                'size'=>$tmp_fileinfo['file_size'],'ext'=>cls_StaticCommonFun::getExtName($name),
                                'imagefromtype'=>$tmp_fileinfo['imagefromtype']);
                            
                            //增加移动端已上传文件记录
                            $tmp_uploadAttList = $tmp_arr;
                            $tmp_uploadAttList['filename'] = $tmp_arr['name'];
                            $tmp_uploadAttList['filepath'] = $tmp_arr['path'];
                            $tmp_uploadAttList['filesize'] = $tmp_arr['size'];
                            $tmp_uploadAttList['filetype'] = $tmp_arr['type'];
                            $tmp_uploadAttList['filesuffixes'] = $tmp_arr['ext'];    
                            
            				$tmp_mobile_fileinfo[] = $tmp_arr;
                            $uploadAttList[] = $tmp_uploadAttList;
            			}
            			if(isset($fieldjsondata[$mapping_columnname])&& is_array($fieldjsondata[$mapping_columnname])){
            				$orgin_fileinfo = $fieldjsondata[$mapping_columnname];
            				$new_fileinfo = array_merge($tmp_mobile_fileinfo,$orgin_fileinfo);
            				$fieldjsondata[$mapping_columnname] = array_values($new_fileinfo);
                            
                            $orgin_UploadAttList = $AllUploadAttList[$mapping_columnname];
            				$new_UploadAttList = array_merge($uploadAttList,$orgin_UploadAttList);
                            $AllUploadAttList[$mapping_columnname] = $new_UploadAttList;
            			} else{
            				$fieldjsondata[$mapping_columnname] =  $tmp_mobile_fileinfo;
                            $AllUploadAttList[$mapping_columnname] = $uploadAttList;
            			}
            		}
            	}
                $this->upgrade_fieldjsondata = $fieldjsondata;
                $this->AllUploadAttList = $AllUploadAttList;
            }
            
            
            
            $this->jsonArr['upgrade']['upgradefrommodule'] = $upgradefrommodule;
            $this->jsonArr['upgrade']['upgradefromid'] = $upgradefromid;
            $this->jsonArr['upgrade']['upgradestatus'] = $upgradestatus;//wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
            if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']!=''){
                $this->jsonArr['upgrade']['upgradetomodule'] = $_REQUEST['upgradetomodule'];
            }
            $this->jsonArr['remind_before_create'] = str_replace('{$Accounts.Accounts}',getTranstab('Accounts'),getFixedLabel('afteroperationthisrecord')) ;
        }
    }

    public function init_detailButton()
    {
        //查询版本
        if(isSearchCRMVersion()=='yes')
        {
             $this->jsonArr['list2']=array();
             return ;
        }
        global $current_user,$adb;
        $init_button = parent::init_detailButton(); // TODO: Change the autogenerated stub
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts('Accounts');
		$public_account = $cls_PublicAccounts->getPublicAccountConfig();
		$sql = 'select publicaccount,pool_id,completed from ld_account where accountid=?';
        $result = $adb->pquery($sql,array($this->record));
        $publicaccount = $adb->query_result($result,0,0);
		$pool_id = $adb->query_result($result,0,1);
		$completed = $adb->query_result($result,0,2);
		$this->jsonArr['pool_id'] = $pool_id;
		if($public_account['status'] == 'yes'){
			//获取当前用户有权限看到的公海池
			$public_account_pool = [];
			$commonaccount = 'no';
			if(!empty($public_account['public_account_pool'])){
				foreach($public_account['public_account_pool'] as $temp_pool_id => $pool_info){
					if(!empty($pool_info['administrators'])){
						$admins = explode(',',$pool_info['administrators']);
						if(in_array($current_user->id,$admins)){
							$public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
						}
						//公海客户“公海已分配”页签：可选公海仅显示当前用户是“公海管理员”或“公海成员”的公海池
//						if($publicaccount > 1){ //去掉条件后，公海成员将普通客户转公海时才显示当前用户是“公海管理员”或“公海成员”的公海池
							$userids = explode(',',$pool_info['userids']);
							if(in_array($current_user->id,$userids)){
								$public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
							}
//						}
					}
				}
			}
			//公海未分配、公海已分配 。 过滤当前公海池
			if($publicaccount >= 1 && !empty($pool_id)){
				$commonaccount = 'yes';
				//公海客户“公海已分配”页签：如果当前用户不是“公海管理员”，只是“公海成员”，则不显示选项“转移出公海（转为普通客户）”
				if($publicaccount >= 1){
					$admins = explode(',',$public_account['public_account_pool'][$pool_id]['administrators']);
					if(sizeOf($admins) >= 1 && !in_array($current_user->id,$admins)){
						$commonaccount = 'no';
					}
				}
				unset($public_account_pool[$pool_id]);
			}
			if(!empty($pool_id)){
				$adminaccount = $public_account['public_account_pool'][$pool_id]['administrators'];
				$usersaccount = $public_account['public_account_pool'][$pool_id]['userids'];
				$splitadmin = explode(",", $adminaccount);
				$splituser = explode(',', $usersaccount);
				if (in_array($current_user->id, $splitadmin)) {
					//0033144: 客户>公海已分配客户：若“公海目标”为“已达成”， 则不显示“延期”按钮
					if(($publicaccount==2||$publicaccount==3)&&$completed!='已完成') $this->jsonArr['list2'][] = 'delay';
				}
				if ((in_array($current_user->id, $splitadmin) || in_array($current_user->id, $splituser))) {
					//公海未分配客户
					$getprofile = $public_account['public_account_pool'][$pool_id]['allowget'];
					if ($publicaccount == 1) {
						if ($getprofile == 'no') {
							$this->jsonArr['list2'][] = 'receive';
						}
					}
				}
				//公海已分配客户
				if($publicaccount==2 || $publicaccount==3){
					$this->jsonArr['list2'][] = 'release';
				}
			}

			

			$transfer_permit = 'no';	//转公海按钮
			if(!empty($public_account['public_account_pool'])){
				foreach($public_account['public_account_pool'] as $key_pool_id => $pool_info){
					if($key_pool_id != $pool_id && $publicaccount >= 1)continue;
					$admins = explode(',',$pool_info['administrators']);
					$userids = explode(',',$pool_info['userids']);
					if($publicaccount == 0 && (in_array($current_user->id,$admins) || in_array($current_user->id,$userids))){	//如果该客户是“普通客户”，则仅当用户是“公海管理员”时显示按钮(需求变更：公海成员也可转公海)
						$transfer_permit = 'yes';
						break;
					}else if($publicaccount == 1 && in_array($current_user->id,$admins)){	//如果该客户是“公海未分配客户”，则仅当用户是“公海管理员”时显示按钮
						$transfer_permit = 'yes';
						break;
					}else if(($publicaccount == 2 || $publicaccount == 3) && (in_array($current_user->id,$admins) || (in_array($current_user->id,$userids) && $pool_info['allow_trasnfer_others'] == 'yes'))){	//如果该客户是“公海已分配客户”，并且当前用户是“公海管理员”时显示按钮
						//当前用户只是“公海用户”且该客户“所属公海”的参数设置勾选了“允许公海成员将已分配或领取的公海客户移客户到其他公海”时，也显示“转换公海”按钮
						$transfer_permit = 'yes';
						break;
					}
				}
			}
//            @edit:liushuai,2021-07-16,reason:0046956: （企业微信移动端-kfbcrm）在客户列表，客户单据admin000236，该单据共享给成员xia，但成员没有单据编辑权限，可以操作转公海，提示成功；但实际没有转换公海成功
			if($transfer_permit == 'yes' && !empty($public_account_pool) && isPermitted($this->module,"EditView",$_REQUEST['record']) == 'yes'){
				$this->jsonArr['list2'][] = 'commontopublic';//转公海
				foreach($public_account_pool as $pool_id => $pool_name){
					$all_pool[] = array(
						'label' => 	$pool_name,
						'value' => $pool_id,
                        'selected' => $public_account['public_account_pool'][$pool_id]['default_pool']?:'no',
					);
				}
				$this->jsonArr['public_account_pool'] = $all_pool;//公海池
				
			}

			if($commonaccount == 'yes'){
				$this->jsonArr['list2'][] = 'publictocommon';//转普通
			}
		}
		
       // $getprofile = getAccount_Set('getprofile');//公海未分配客户不允许领取（只能由公海管理员分配）
       // $adminaccount = getAccount_Set("adminaccount");
        //$usersaccount = getAccount_Set('usersaccount');
        //$status = getAccount_Set('status');
        //$splitadmin = explode(",", $adminaccount);
        //$splituser = explode(',', $usersaccount);
        //0033443: 当是否公海字段被隐藏，领取按钮也消失了。
        //$publicaccount = $this->focus->column_fields['publicaccount']; 
        
        //editor:gyq_20180813 0034784: （珞落计划企业微信登录）非公海管理员登录公海已分配单据详情界面：更多操作中应不显示“延期”按钮
        
       /* if ($status == 0 && ($current_user->is_admin == "on" || in_array($current_user->id, $splitadmin) || in_array($current_user->id, $splituser))) {
            //公海未分配客户
            if ($publicaccount == 1) {
                if ($getprofile == 1) {
                    $this->jsonArr['list2'][] = 'receive';
                }
            }
            //公海已分配客户
            if($publicaccount==2 || $publicaccount==3){
                $this->jsonArr['list2'][] = 'release';
            }
            //管理员拥有普通和公海转换 延期的权限
            
                if($publicaccount==0)
                {
                    //公海/非公海管理成员增加将客户转公海功能 
                    if($current_user->is_admin == "on" || in_array($current_user->id, $splitadmin)||in_array($current_user->id, $splituser)){
                    $this->jsonArr['list2'][] = 'commontopublic';//转公海
                    }
                } 
                $normalconvertbuttonprofile=getAccount_set('normalconvertbuttonprofile');//增加公海已分配客户转普通权限
                if($publicaccount>=2&&$normalconvertbuttonprofile=='yes'&&(!is_admin($current_user)&& !in_array($current_user->id, $splitadmin)))
                {
                    
                }
                else
                      $this->jsonArr['list2'][] = 'publictocommon';//转普通

        }*/
        $this->jsonArr['list2'] = array_values(array_unique($this->jsonArr['list2']));
        $this->jsonArr['publicaccount'] = $publicaccount+1;
    }

    //首要联系人
    public function get_DetailView_Extra($focus)
    {
        global $adb;
        crm_load_class_file('Detail_Edit_View','include/utils');
        $focus->column_fields['contact_id']=Detail_Edit_View::getAccountPrimaryContactInfo($focus);//gyq_26 关系信息新增

        $this->get_trends_permit();//判断动态模块是否显示

//        @edit:liushuai,2021-07-20,reason:【ID1001139】客户和联系人相关信息中的“会话存档”模块增加可隐藏功能
        $have_wechatsession = 'no';
//        ls 2021-08-04 47227: 移动端（https://81mis.com/kfbcrm [^]） 客户管理-客户 客户详情，横栏相关信息中不显示“会话存档”。 但登录企业微信移动端，进入客户列表，打开 客户详情界面，横栏处仍显示“会话”页签（非管理员，且角色权限无会话存档时）
        if(vtlib_isModuleActive($this->module) && isPermitted('WechatSession','index') == 'yes'){
            $relatedListResult = $adb->pquery('SELECT presence FROM ld_relatedlists WHERE tabid=? AND related_tabid=?', array(getTabid($this->module), getTabid("WechatSession")));
            if($adb->num_rows($relatedListResult) >0){
                $presence = $adb->query_result($relatedListResult,0,'presence');
                if($presence != 1) {
                    $have_wechatsession = 'yes';
                }
            }
        }
        $this->jsonArr['defaultSetting']['wechatsession'] = $have_wechatsession;
    }
    //0035048: 微信端：设置公海客户上限后，点击新建【公海已分配】按钮时应该就判断公海客户上限，而不是保存时判断（需要补丁文件
    protected function get_CreateView()
    {
        global $current_user;
        
      
        //0035048: 微信端：设置公海客户上限后，点击新建【公海已分配】按钮时应该就判断公海客户上限，而不是保存时判断（需要补丁文件
        if ($_REQUEST['publicaccount'] == 3){
			$_REQUEST['allocatetype'] = 2;
           //edit:can 20210513 045858: 奥德（暂无外网）服务器迁移后，销售员杨凯的已分配客户拥有上限是50，但是名下显示的实际公海已分配里有80+（详情见附件）
            $_REQUEST['userid'] = $current_user->id;
            $_REQUEST['maxaccount']=1;
            $allocate = cls_Instance::get_commonAction_Instance('Accounts','AllocateAccount',1);
            //$allocate->setParams(2,$_REQUEST['assigned_user_id'],1);
            
            $allocate->init_count();
            $allocate->judgeCount();
        } elseif ($_REQUEST['publicaccount'] == 1) {
            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(移动端普通客户新建)
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
            $limit_count = $this->focus->getCommonAccountLimitCount($current_user->id);
            if($limit_count<9999999999)
            {
                $haved_count = $this->focus->getSmowerNumForCommonAccount($current_user->id);
                if ($limit_count <= $haved_count) {
                    $errormsg = $public_account['status']=='yes'?getFixedLabel('CreateReacheMaximumError1'):getFixedLabel('CreateReacheMaximumError');
                    ConvertTojsonString(-1,[],$errormsg);
                }
            }
        }


        //客户查重权限判断，新增界面客户名称旁边有搜索功能 editor:gyq_20180906 	0035158: （珞落计划企业微信登录）客户模块：当前操作员没有“客户查重”权限时，客户新增界面也应该没有“查重”权限
        if (isPermitted($this->module,'accountdatadup')=='yes'){
            $list_buttons['Datadupcheck'] = 'yes';
        }
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($this->module);
        if($businessinformationobj->IsEnableBusiness()){
            $list_buttons['GetTianYanSearchInfo'] = 'yes';
        }
        //工商查询列表
        if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            $list_buttons['GetTianYanSearchInfoVague'] = 'yes';
        }
        $this->jsonArr['list2'] = $list_buttons;
        
        $jsondata = parent::get_CreateView();
        
        if(!empty($this->upgrade_fieldjsondata)&&sizeof($this->upgrade_fieldjsondata)){
            //duan 20221125 将销售线索的附件字段映射到客户的附件字段上
            $block_list = $jsondata['list'];
            foreach($block_list as $tmp_blockid => $block_info){
                $all_fieldinfo = $block_info['fieldinfo'];
                foreach($all_fieldinfo as $tmp_fieldid => $fieldinfo){
                    if($fieldinfo['bigtype'] == 'fileattachment'){
                        $columnname = $fieldinfo['columnname'];
                        if(isset($this->upgrade_fieldjsondata[$columnname])){
                            $upgrad_fileinfo = $this->upgrade_fieldjsondata[$columnname];
                            $fieldinfo['text'] = $upgrad_fileinfo;
                            $fieldinfo['value'] = $upgrad_fileinfo;
                            $uploadAttList = $this->AllUploadAttList[$columnname];
                            if($fieldinfo['type'] == '69' ){
                                $fieldinfo['uploadImgList_upgrade'] = $uploadAttList;
                            }else if($fieldinfo['type'] == '1109'){
                                $fieldinfo['uploadAttList_upgrade'] = $uploadAttList;
                            }
                            $block_list[$tmp_blockid]['fieldinfo'][$tmp_fieldid] = $fieldinfo;
                        }    
                    }
                }
            }
            $jsondata['list'] = $block_list;
        }
        return $jsondata;
    }
    //判断移动端动态模块是否启用
    protected function get_trends_permit()
    {
        global $adb;
        $tabid = getTabid($this->module);
        $sql = "SELECT presence from ld_relatedlists where tabid=? and related_tabid=?";
        $result = $adb ->pquery($sql,array($tabid,-16));
        $numrows = $adb->num_rows($result);
        $tmp_permit = 'no';
        if($numrows >0){
            $presence = $adb->query_result($result,0,'presence');
            if($presence==0) {
                $tmp_permit = 'yes';
            }
        }
        $version = getVersionTradeInfo();
        $old_version = 'V8.4.3.4';
        $current_version = $version['current_version'];
        if($current_version<$old_version)
            $tmp_permit = 'yes';
        $this->jsonArr['defaultSetting']['trends_permit']=$tmp_permit;
        return ;
    }

    protected function set_DetailView(){
        parent::set_DetailView();
        $focus = $this->focus;
        //zkt 20231024 BUG0073893 客户管理--工商查询功能应与角色的编辑权限挂钩，没有编辑权限应不显示工商查询按钮
        if (isPermitted($this->module,'EditView',$focus->id)=='yes'){
            //明细增加工商查询
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($this->module);
            $GetTianYanSearchInfo = 'no';
            //工商查询
            if($businessinformationobj->IsEnableBusiness()){
                $GetTianYanSearchInfo = 'yes';
            }
        }
        if ($this->action == 'DetailView') {
            $this->jsonArr['GetTianYanSearchInfo'] = $GetTianYanSearchInfo;
        }
        elseif ($this->action == 'EditView'){
            if (isPermitted($this->module,'accountdatadup')=='yes'){
                $this->jsonArr['list2']['Datadupcheck'] = 'yes';
            }
            $this->jsonArr['list2']['GetTianYanSearchInfo'] = $GetTianYanSearchInfo;
        }
    }
}
?>