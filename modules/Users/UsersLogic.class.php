<?php
class UsersLogic extends BaseLogic
{ 
    /**
	 * ���ù������������б�����ӿͻ���������б�
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
	   global $current_user;
	    $module = self::$module;
        $is_edit = 'no';
        if('yes' == isPermitted($module, 'EditView', '')){//判断编辑权限
            $is_edit = 'yes';
        }
        //批量编辑
        $this->list_buttons['More']['list']['mass_edit']['label'] = getFixedLabel('MASSEDIT');
        $this->list_buttons['More']['list']['mass_edit']['permit'] = $is_edit;

		$focus = CRMEntity::getInstance('Users');
		$authtype =  $focus->getVersionKehu001();
       	if('yes' == isPermitted($module, 'Import', '')){//�жϵ���Ȩ��
			$is_import = 'yes';$more_idx = 1;
		}
		if('yes' == isPermitted($module, 'Export', '')){//�жϵ���Ȩ��
			$is_report = 'yes';$more_idx = 1;
		}
		if($authtype == 'yes'){
			$is_import = 'no';
			$this->list_buttons['Create']['permit'] = 'no';
		}

		if($this->controller->user_type != 'prm'){
            //����
            $this->list_buttons['More']['list']['Import']['label'] = getFixedLabel('IMPORT');
            $this->list_buttons['More']['list']['Import']['permit'] = $is_import;
        }


		//����
		$this->list_buttons['More']['list']['Export']['label'] = getFixedLabel('EXPORT');
		$this->list_buttons['More']['list']['Export']['permit'] = $is_report;
       
		$this->list_buttons['More']['list']['ResetListWidth']['label'] = getFixedLabel('ResetListWidth');
		$this->list_buttons['More']['list']['ResetListWidth']['permit'] = 'yes';
        //38806: pc端>成员管理列表界面>更多：“设置允许成员自行编辑的字段”按钮与恢复预设列宽按钮位置调换一下。
         if(is_admin($current_user))
        {
            //设置允许成员自行编辑的字段
            $this->list_buttons['More']['list']['allowedituserfield']['label']=getFixedLabel('ALLOWEDITUSERFIELD');
            $this->list_buttons['More']['list']['allowedituserfield']['permit'] = 'yes';
        }

	}
    
    /**
	 * ��ʼ��ģ�������ť
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
		global $current_user,$adb;
		$module = self::$module;
        
       	$fieldObj = Field::getInstance($module,$adb);
		$focus = CRMEntity::getInstance('Users');
		$authtype =  $focus->getVersionKehu001();
		if($authtype == 'yes'){
			//���ά�����ź��û�
			$this->list_buttons['HowToMainTran']['label'] = getFixedLabel('howtomaintrandepartanduser');
			$this->list_buttons['HowToMainTran']['permit'] = isPermitted($module, 'HowToMainTran', '');
			$this->list_buttons['HowToMainTran']['icon'] = 'icon-homeimg icon-ask';
            $this->list_buttons['HowToMainTran']['btnkey'] = 'HowToMainTran';
		}
		//����
		//$this->list_buttons['moduledetailCreate']['label'] = getFixedLabel('CREATE');
//		$this->list_buttons['moduledetailCreate']['permit'] = isPermitted($module, 'Create', '');
//		$this->list_buttons['moduledetailCreate']['icon'] = 'icon-plus';
//        $this->list_buttons['moduledetailCreate']['btnkey'] = 'moduledetailCreate';
        $this->list_buttons['Create']['label'] = getFixedLabel('CREATE');
        $this->list_buttons['Create']['permit'] = isPermitted($module, 'Create', '');
        $this->list_buttons['Create']['icon'] = 'icon-plus';
        $this->list_buttons['Create']['btnkey'] = 'Create';

        //ls 2021-12-15 【1002160】企业微信通讯录及部门同步
        if ($focus->getAddressbookSync()) {
            $this->list_buttons['AddressbookSync']['label'] = getFixedLabel('Synchronizeaddressbook');
            $this->list_buttons['AddressbookSync']['permit'] = isPermitted($module, 'Create', '');
            $this->list_buttons['AddressbookSync']['icon'] = 'icon-rangelist';
            $this->list_buttons['AddressbookSync']['btnkey'] = 'AddressbookSync';
        }



        //部门设置

        $this->list_buttons['GroupSetUser']['label'] = getFixedLabel('groupsetup');
        $this->list_buttons['GroupSetUser']['permit'] = isPermitted($module, 'Create', '');
        $this->list_buttons['GroupSetUser']['icon'] = 'icon-set';
        $this->list_buttons['GroupSetUser']['btnkey'] = 'GroupSetUser';

//        数据范围
        // @edit:dong @date:2020/07/20 @reason: 修复权限 成员管理->允许设置成员的角色和数据权限  列表页的按钮显示和隐藏
//        if (isPermitted("Users", "AllowSetRoleDataProfile") != 'no') {//BUG0063751 ls 20230607 角色权限“数据范围”控制，无需跟“允许设置成员的角色和数据权限”关联
            $this->list_buttons['DataScope']['label'] = getFixedLabel('DATARANGE');
            $this->list_buttons['DataScope']['permit'] = isPermitted($module, 'DataScope', '');
            $this->list_buttons['DataScope']['icon'] = 'icon-rangelist';
            $this->list_buttons['DataScope']['btnkey'] = 'DataScope';
//        }
        $deploy_value=323;
        $deploy_arr=getSys_deploy($deploy_value);//设置系统登陆时密码连续输错时间限制
        $timelimitvalue=$deploy_arr['deploy_value'];
        if (is_admin($current_user)) {
            $this->list_buttons['UserLoginControl']['label'] = getFixedLabel('LoginControl');
            $this->list_buttons['UserLoginControl']['permit'] = 'yes';
            $this->list_buttons['UserLoginControl']['icon'] = 'icon-rangelist';
            $this->list_buttons['UserLoginControl']['btnkey'] = 'UserLoginControl';
        }
        if (is_admin($current_user)) {
            $deploy_type=322;
            $deploy_arr=getSys_deploy($deploy_type);//设置系统登陆时密码连续输错次数
            $time=$deploy_arr['deploy_value'];
            //
            $deploy_type2=323;
            $deploy_arr2=getSys_deploy($deploy_type2);//限制登录时间
            $time2=$deploy_arr2['deploy_value'];
            //          
            
            $sql="select last_name,user_name,ld_users.id,wx_userid from ld_users inner join (
            select userid from ld_loginerror group by userid having count(*)>=$time) as tmp 
            on tmp.userid=ld_users.id limit 1  ";
            $result=$adb->pquery($sql,array()); 
            //edit:zkt 20210604 0045514: （https://61mis.com/kfbcrm [^]）成员管理界面，若“登陆控制”界面设置连续输错密码3次不限制登陆时长后，解锁账号按钮应该不显示           
            if(!empty($time2)&&$adb->num_rows($result)>0)
            {
                $this->list_buttons['UnlockUserAccount']['label'] = getFixedLabel('UnlockUserAccount');
                $this->list_buttons['UnlockUserAccount']['permit'] = 'yes';
                $this->list_buttons['UnlockUserAccount']['icon'] = 'icon-rangelist';
                $this->list_buttons['UnlockUserAccount']['btnkey'] = 'UnlockUserAccount';
            }
        }
        /*
		//分享
		$this->list_buttons['Share']['label'] = getFixedLabel('SHARE');
		$this->list_buttons['Share']['permit'] = isPermitted($module, 'Share', '');
		$this->list_buttons['Share']['icon'] = 'icon-user';
        */
        //zxm 20220722 同步公众号用户的接口按钮  20221013  oem的保留 其他的去掉这个按钮
        $sql = "select id,switch,para_content,para_one,para_two,para_three,usertype from ld_wx_config where name=?";
        $result = $adb->pquery($sql,array('wechat_miniprogram_setting'));
        $config_num = $adb->num_rows($result);
        if($config_num > 0) {
            $para_content = $adb->query_result($result, 0, 'para_content');
            $para_content = Zend_Json::decode($para_content);
            //zxm 20221013没有设置过小程序提醒参数，或者设置使用的小程序AppID是“wx608d4c0ec205411f”，则升级后默认为“使用灵当CRM小程序和微信公众号”
            if (empty($para_content) || $para_content['mini_appid'] == "wx608d4c0ec205411f" || $para_content['msgsend_type'] == 'msgsend_typeld') {

            } else {
                $this->list_buttons['OffiaccountUser']['permit'] = 'yes';
                $this->list_buttons['OffiaccountUser']['label'] = getFixedLabel('OffiaccountUserSync');//'同步公众号用户';//OffiaccountUserSync.php
                $this->list_buttons['OffiaccountUser']['icon'] = 'icon-rangelist';
                $this->list_buttons['OffiaccountUser']['btnkey'] = 'OffiaccountUser';
            }
        }

		$is_set = 'no';
		if(is_admin($current_user)){//ֻ�й���Ա�Ż���ʾҳ������
			$is_set = 'yes';
		}
		
		$this->list_buttons['More']['label'] = '···';
		$this->list_buttons['More']['permit'] = 'yes';
		$this->list_buttons['More']['icon'] = 'icon-more';
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['Edit']['label'] = getFixedLabel('EDIT');
        $btn['useractivate']['label'] = getFixedLabel('INACTIVATE').'/'.getFixedLabel('ACTIVATE');
        $btn['copy']['label'] = getFixedLabel('COPY');
        $btn['delete']['label'] = getFixedLabel('DELETE');
        return $btn;
    }
    	/**
	 * ��ʼ���б�ť�����
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
    //if(!empty($this->listview_link)) return true;
    $this->listview_link=array();
    global $adb;
    $module=self::$module;
    //�༭
    $this->listview_link['Edit']['label'] = getFixedLabel('EDIT');

    $this->listview_link['Edit']['permit'] = isPermitted(self::$module,'EditView',"");
    $type = 'redirect';


    $this->listview_link['Edit']['click'] = 'check_edit_click(this,\''.self::$module.'\',\'%d\')';
    $r_m = self::$module;$r_a = 'ListView';$r_r = 0;$related = 0;

    //ɾ��
    if($record!="1")//��������Ա��ϵͳԤ֧���˺�admin
    {
      if($adb->query_result($result,$idx,'status')=='Active')
      {
        $this->listview_link['useractivate']['label'] = getFixedLabel('INACTIVATE');
        $this->listview_link['useractivate']['permit'] = isPermitted($module,'UserStop','');
        $this->listview_link['useractivate']['click'] = "setStatus(this,".$record.",'Active')";
      }
      else
      {
        $this->listview_link['useractivate']['label'] = getFixedLabel('ACTIVATE');
        $this->listview_link['useractivate']['permit'] = isPermitted($module,'UserActivate','');

        $this->listview_link['useractivate']['click'] = "setStatus(this,".$record.",'ACTIVATE')";
      }
    }
        //ls 2021-12-15 【1002160】企业微信通讯录及部门同步(是否显示复制按钮)
        $permit_copy = isPermitted($module,'Copy','');
        if ($permit_copy == 'yes') {
            $focus = CRMEntity::getInstance('Users');
            $tmp_result = $adb->pquery("select wx_userid from ld_users where id = ?",array($record));
            $wx_userid = $adb->query_result($tmp_result,0,'wx_userid');

            if ($focus->getVersionKehu001() == 'yes' && !empty($wx_userid)) {
                $permit_copy = 'no';
            }
        }

        $this->listview_link['copy']['label'] = getFixedLabel('COPY');
        $this->listview_link['copy']['permit'] = $permit_copy;
        $this->listview_link['copy']['href'] = "javascript:CopyUsers($record);";

    if($record!="1")//��������Ա��ϵͳԤ֧���˺�admin
    {
      $this->listview_link['delete']['label'] = getFixedLabel('DELETE');
      $this->listview_link['delete']['permit'] = isPermitted($module,'Delete','');
      $this->listview_link['delete']['click'] = "deleteUser(this,".$record.",2,1,'Settings')";
    }

    $this->listview_link['Edit']['type'] = 'moduledetailredirect';
    $this->listview_link['Edit']['result']['module'] = $r_m;
    $this->listview_link['Edit']['result']['action'] = $r_a;
    $this->listview_link['Edit']['result']['record'] = $r_r;
    $this->listview_link['Edit']['related'] = $related;
	}
    	/**
	 * ��ȡ�б�����а�ť
	 * @author Tujt 2015-06-26
	 */
	public function getListViewLink($result,$recordId,$start,$idx) {	
		global $adb;
		$record = $this->getRecordInfo($recordId);
		$this->setListViewLink($result,$record,$start,$idx);
        $this->resetListViewLink();//按钮排序,并修改按钮显示状态
		$focus = CRMEntity::getInstance('Users');
		$authtype =  $focus->getVersionKehu001();
		$query = 'select `status` from ld_users where id = ?';
		$result = $adb->pquery($query,array($record));
		$status = $adb->query_result($result,0,0);
		$actionLinkInfo = '&nbsp;';
		if(!empty($this->listview_link)){
			foreach($this->listview_link as $key=>$link){
				if('yes' != $link['permit']) continue;
				if($authtype == 'yes'){
					if($status == 'Active'||$status==''){
						if($key == 'delete')continue;
					}
					if($key == 'useractivate' || $key == 'copy')continue;
				}
        $class = '';
        if($key == 'delete')
        {
          $class = ' redFont';
        }
                //�����Ϣrelatedid                
                $relatedid = (isset($_REQUEST['relatedid'])?$_REQUEST['relatedid']:'');
				$tag = (isset($link['tag'])?$link['tag']:'');
				$type = (isset($link['type'])?$link['type']:'');
				$r_m = (isset($link['result']['module'])?$link['result']['module']:'');
				$r_a = (isset($link['result']['action'])?$link['result']['action']:'');
				$r_r = (isset($link['result']['record'])?$link['result']['record']:'');
                if(array_key_exists("href",$link))
                {
                    $strhtml= sprintf('<a class="Anu3_a'.$class.'" 
							href="'.$link['href'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" style="white-space:nowrap;">
							'.$link['label'].'</a>',$record);
                }
                else
				$strhtml= sprintf('<a class="Anu3_a'.$class.'" href="javascript:void(0);" 
							onclick="'.$link['click'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" style="white-space:nowrap;">
							'.$link['label'].'</a>',$record);
                            
                $actionLinkInfo.=$strhtml;
                $this->list_buttom_name[$record][]= trim($link['label']);
                $this->list_button_html[$record][$key]=$strhtml;
			}
		}
        
        $record_html_btn[$record]=$actionLinkInfo;
        
	    return $actionLinkInfo;
	}
    
    
    
    	/**
	 * ��ȡ����ҳ��ť����
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		global $adb,$current_user;
		$module = self::$module;
        
       	$fieldObj = Field::getInstance($module,$adb);
	    $moduleFields = $fieldObj->getModuleFields();      
        $field_creator = $moduleFields['smcreatorid'];
      
       	//�����б�
		//$this->detail_buttons['Back']['label'] = getFixedLabel('BACKTOLIST');
		//$this->detail_buttons['Back']['permit'] = 'yes';//�����б�ť����ҪȨ�޿���(edi;can)
		//$this->detail_buttons['Back']['icon'] = 'icon-return';
	    //����
       
       //$this->detail_buttons['Create']['label'] = getFixedLabel('CREATE');
   	//	$this->detail_buttons['Create']['permit'] = isPermitted(self::$module,'Create');
   	//	$this->detail_buttons['Create']['icon'] = 'icon-plus';

		//�༭
		$this->detail_buttons['Edit']['label'] = getFixedLabel('EDIT');
		$this->detail_buttons['Edit']['permit'] = isPermitted(self::$module,'EditView',$this->controller->id);
		$this->detail_buttons['Edit']['icon'] = 'icon-pen';
       
	
	
	
		$is_set = 'no';
		if(is_admin($current_user)){
			$is_set = 'yes';
		}
        //ҳ�����ã�ֻ�й���Ա�Ż���ʾҳ������
		$this->detail_buttons['Settings']['label'] = getFixedLabel('LBL_PAGE_SET');
		$this->detail_buttons['Settings']['permit'] = $is_set;
		$this->detail_buttons['Settings']['icon'] = 'icon-set';
		//editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/26 14:41
        $regop=RegOp::getInstance();
		$servicehelp=$regop->getservicehelp_interface();
        $sql = 'select para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        if($nums > 0) {
            $coid = $adb->query_result($result, 0, 'para_three');
        }
        /*230801 wym BUG0068433 成员管理查看详情界面，和右上角个人头像下拉选项中，去掉“订单小程序”操作按钮（包括后台设置和注册系统去掉“订单小程序”设置菜单栏和接口授权，“商城”在注册系统增加了另外的接口授权）
		if(method_exists($regop,'getorder_smallinterface')){
            $orderhelp=$regop->getorder_smallinterface();//0是没有 1是有
            //editor:gyq_108 reason:订单小程序  2019/4/17 10:28
            if($orderhelp!=0 && $coid > 0) {
                $this->detail_buttons['SELFORDERQRCODE']['label'] = getFixedLabel('SELFSERVICEQRCODEORDER');
                $this->detail_buttons['SELFORDERQRCODE']['permit'] = 'yes';
                $this->detail_buttons['SELFORDERQRCODE']['icon'] = 'icon-selfserviceqrcode';
            }
        }*/
        //$servicehelp = 1;
        if($servicehelp!=0 && $coid > 0){
            $this->detail_buttons['SELFSERVICEQRCODE']['label'] = getFixedLabel('SELFSERVICEQRCODE');
            $this->detail_buttons['SELFSERVICEQRCODE']['permit'] = 'yes';
            $this->detail_buttons['SELFSERVICEQRCODE']['icon'] = 'icon-selfserviceqrcode';
        }
        //wym 商城小程序 原本判断用户是否授权商城小程序，现只判断商城模块是否开启
        if(vtlib_isModuleactive('ShopSettings')){
            $this->detail_buttons['SELFSHOPQRCODE']['label'] = getFixedLabel('SELFSHOPQRCODE');
            $this->detail_buttons['SELFSHOPQRCODE']['permit'] = 'yes';
            $this->detail_buttons['SELFSHOPQRCODE']['icon'] = '';
        }
        //edit：zxm 2020-0917 名片小程序按钮
       // if($servicehelp!=0 && $coid > 0){
        //添加是否显示电子名片按钮的判断  2021-0220 zxm
        $deploy_sql = "select * from ld_systems_deploy where deploy_type=270";
        $deploy_res = $adb->pquery($deploy_sql);
        $deploy_value = $adb->query_result($deploy_res,0,'deploy_value');
        if($deploy_value==0) {
            $this->detail_buttons['CARDQRCODE']['label'] = getFixedLabel('CARDQRCODE');
            $this->detail_buttons['CARDQRCODE']['permit'] = 'yes';
            $this->detail_buttons['CARDQRCODE']['icon'] = 'icon-selfserviceqrcode';
        }
		$version_info = getVersionInfo();
		//东贸 拓展码
		if($version_info['account'] == 'dongmao'){
			$this->detail_buttons['TUOZHANCODE']['label'] = '拓展码';
            $this->detail_buttons['TUOZHANCODE']['permit'] = 'yes';
            $this->detail_buttons['TUOZHANCODE']['icon'] = 'icon-selfserviceqrcode';
		}
       // }
		//���ఴť
		$this->detail_buttons['More']['label'] = getFixedLabel('MORE');
		$this->detail_buttons['More']['permit'] = 'yes';
		$this->detail_buttons['More']['icon'] = 'icon-more';

		$focus = CRMEntity::getInstance('Users');
		$authtype =  $focus->getVersionKehu001();
		if($authtype == 'yes'){
			$this->detail_buttons['Create']['permit'] = 'no';
		}
	}
	/**
	 * ��ȡ����ҳ���ఴť�����б����
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		global $current_user,$adb;
		$iscopy = 'no';$isshare = 'no';$isdelete = 'no';$is_set = 'no';$more_idx = 0;
		/*
		if('yes' == isPermitted(self::$module,'Copy')){
			$iscopy = 'yes';$more_idx = 1;

            $focus = CRMEntity::getInstance('Users');
            $tmp_result = $adb->pquery("select wx_userid from ld_users where id = ?",array($this->controller->id));
            $wx_userid = $adb->query_result($tmp_result,0,'wx_userid');
            if ($focus->getAddressbookSync() && !empty($wx_userid)) {
                $iscopy = 'no';
            }
		}
		*/
        
        
	
        
		if(is_admin($current_user)){
			$is_set = 'yes';$more_idx = 1;
		}
		if(isset($this->approvebtn['delete']) && 1 == $this->approvebtn['delete']){//�����У�������ɾ��
			$isdelete = 'no';//������ɾ��
		}else if('yes' == isPermitted(self::$module,'Delete',$this->controller->id)){
			$isdelete = 'yes';$more_idx = 1;//����ɾ��
		}
       // dump($this->controller->id);
		
		$focus = CRMEntity::getInstance('Users');
		$authtype =  $focus->getVersionKehu001();
		if($authtype == 'yes'){
			$query = 'select `status` from ld_users where id = ?';
			$result = $adb->pquery($query,array($this->controller->id));
			$status = $adb->query_result($result,0,0);
			if($status == 'Active'){
				$this->detail_buttons['More']['permit'] = 'no';
			}else{
				$isdelete = 'yes';
			}
			$iscopy = 'no';
		}
        if($this->controller->column_fields['user_name'] == 'admin'||$this->controller->id==1){
			$isdelete = 'no';
		}
		
		//����
		$this->detail_buttons['More']['list']['Copy']['label'] = getFixedLabel('COPY');
		$this->detail_buttons['More']['list']['Copy']['permit'] = $iscopy;
	
		//ɾ��
		$this->detail_buttons['More']['list']['Delete']['label'] = getFixedLabel('DELETE');
		$this->detail_buttons['More']['list']['Delete']['permit'] = $isdelete;
        
        
        
		
		if(0 == $more_idx) $this->detail_buttons['More']['permit'] = 'no';
	}
    
   	public function getDetailViewButton() {
   	    global $current_user;
	    $this->detail_buttons =parent::getDetailViewButton();
       
		 if($this->controller->id==$current_user->id)
         {
            $this->detail_buttons['Edit']['permit']='yes';
         }
        
		return $this->detail_buttons;//返回列表按钮结果集
	}
}


?>