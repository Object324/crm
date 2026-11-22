<?php
class cls_ApproveFunctions{
    public $adb;
    public function __construct()
    {
        global $adb;
        $this->adb = $adb;
    }

    /**
     * 待办页面数据
     * 待审批数据 没有待审批数据则返回返回【待审批0】，【已审批】，【我提交的】的数组
     * 销售助手数据
     */
    public function getApproveNums()
    {
        crm_load_class_file('cls_Approve_CountListViewWX','WeiXinApp/modules/Approve/cls_Approve');
        $cls_Approve_CountListView = new cls_Approve_CountListViewWX($this->approve_status);
        $approve_info = $cls_Approve_CountListView->getapprovelist();
        if(!empty($approve_info)){
            foreach($approve_info as &$v){
                $v['label'] = getTranstab($v['module']);
            }
            $list['approveData'] = $approve_info;
        }else{
            //判断1方法的list为空 则返回【待审批0】，【已审批】，【我提交的】的数据
            $list['approveData'] = [];
            $list['approveNoData'] = [
                ['image'=>'waiting2023/approve_1.png','label'=>getFixedLabel('Pending_approval'),'module'=>"all",'num'=>0],
                ['image'=>'waiting2023/approve_2.png','label'=>getFixedLabel('Approved'),'module'=>"all",'num'=>0],
                ['image'=>'waiting2023/approve_3.png','label'=>getFixedLabel('isubmitted'),'module'=>"all",'num'=>0],
                ['image'=>'waiting2023/approve_3.png','label'=>getFixedLabel('ApproveRejected'),'module'=>"all",'num'=>0],
            ];
        }
        $getXiaoshouZhushou = $this->getXiaoshouZhushou();
        $list['salesAssistant'] = $getXiaoshouZhushou['res'];

        //关键视图
        $isKeyViewOpen = $getXiaoshouZhushou['isKeyViewOpen'];
        if($isKeyViewOpen == 'yes'){
            include_once(globalStatic::$root_directory.'modules/CustomView/ListViewTop.php');
            $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
            $_REQUEST['report_name'] = "keyViews";
            $keyViews = getKeyMetrics('','SmOwner_Search_All','','yes');
            foreach($keyViews as &$v){
                $v['name'] = getTranstab($v['module']).'-'.$v['name'];
            }
            $list['keyViews'] = $keyViews;
        }else{
            $list['keyViews']  = [];
        }
        //移动端添加翻译
        $list['arrFixedLabel'] = $this->getApproveFixedlabel();
        // 消息中心——未读消息条数
        require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');

        $remindscount = static_Reminds::getRemindsCount();
        if($remindscount == 0)
            $remindscount = -1;
        $list['remindscount'] = $remindscount;
        ConvertTojsonString(1,$list,'success');
    }

    /**
     * @param string $isInternalCall 是否是前端接口请求 还是php内部请求 默认是前端接口请求 不需要传值 默认”“
     * @return array
     * @throws Exception
     * 获取销售助手页面参数
     * 区块1 是否显示销售助手 yes|no
     * 区块2 5条数据
     */
    public function getXiaoshouZhushouSet($isInternalCall="")
    {
        $sql = "select deploy_value,deploy_type,description,is_open,`name`,`module` from ld_appsystem where deploy_type in(4,5,6) order by sequence asc";
        $res = $this->adb->pquery($sql);
        $list = [];
        $whetherShow = [];
        $keyViews = [];
        $nums = $this->adb->num_rows($res);
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $deploy_type = $this->adb->query_result($res,$i,'deploy_type');
                if($deploy_type == 4){
                    $whetherShow['is_open'] = $this->adb->query_result($res,$i,'is_open');
                    $whetherShow['label'] = $this->adb->query_result($res,$i,'description');
                    $whetherShow['label'] = getFixedLabel('DISPLAYSALESASSISTANT');
                    $whetherShow['deploy_type'] = $deploy_type;
                }else if($deploy_type == 6){
                    $keyViews['is_open'] = $this->adb->query_result($res,$i,'is_open');
                    $keyViews['label'] = $this->adb->query_result($res,$i,'description');
                    $keyViews['label'] = getFixedLabel('DISPLAYKEYVIEW');
                    $keyViews['deploy_type'] = $deploy_type;
                }else{
                    $name = $this->adb->query_result($res,$i,'name');
                    //如果生日字段隐藏或者模块未开或者模块权限未开 则联系人这一条不显示
                    if($name == "Contacts"){
                        $focus = CRMEntity::getInstance($name);
                        $fieldobj = $focus->fieldobj->getFieldInfoobjBykey("columnname","birthday");
                        if(!$fieldobj || !vtlib_isModuleActive($name)||isPermitted($name,'index')!='yes') {
                            continue;
                        }
                    }else{
                        if(!vtlib_isModuleActive($name)||isPermitted($name,'index')!='yes') {
                            continue;
                        }
                    }
                    $list[$i]['name'] = $name;
                    $list[$i]['is_open'] = $this->adb->query_result($res,$i,'is_open');
                    $list[$i]['deploy_value'] = $deploy_value = $this->adb->query_result($res,$i,'deploy_value');
                    $list[$i]['description'] = $this->adb->query_result($res,$i,'description');
                    $list[$i]['module'] = $this->adb->query_result($res,$i,'module');
                    $list[$i]['deploy_type'] = $deploy_type;
                    switch ($name) {
                        case "Accounts":
                            $label_str = getFixedLabel('NOTFOLLOWEDUPACCOUNT');
                            break;
                        case "Potentials":
                            $label_str = getFixedLabel('CLOSEPOTENTAILS');
                            break;
                        case "PaymentPlan":
                            $label_str = getFixedLabel('COLLECTIONPAYMENTPLAN');
                            break;
                        case "ServiceContracts":
                            $label_str = getFixedLabel('EXPIRINGSERVICECONTRACTS');
                            break;
                        case "Contacts":
                            $label_str = getFixedLabel('BIRTHDAYSCONTACTS');
                            break;
                    }
                    $label_arr = explode('%d',$label_str);
                    if(sizeof($label_arr) > 1){
                        $list[$i]['label1'] = $label_arr[0];
                        $list[$i]['label2'] = $label_arr[1];
                    }else{
                        $list[$i]['label1'] = $label_arr[0];
                        $list[$i]['label2'] = '';
                    }
                    $list[$i]['label3'] = sprintf($label_str,$deploy_value);
                }
            }
        }
        $list = array_values($list);
        if($isInternalCall=="yes"){
            return ['list'=>$list,'whetherShow'=>$whetherShow,'keyViews'=>$keyViews];
        }else{
            $label_arr=array(
                'CLOSEASSISTANTSHOWAPPROVE',//关闭销售助手后待办界面直接显示审批单据
                'STAYDOSETTING',//待办设置
                'CANNOTBELESSTHANONE',//不能小于
                'WARMPROMPT',//温馨提示
                'LOADING',//加载中...
            );
            $fixedlabel_arr = TransFieldlabel($label_arr,'no');

            ConvertTojsonString(1,array('list'=>$list,'whetherShow'=>$whetherShow,'keyViews'=>$keyViews,'arrFixedLabel'=>$fixedlabel_arr),'success');
        }

    }

    /**
     * 设置操作
     * name  销售助手-名称
     * is_open 要更新的开启或者关闭值 yes|no
     * deploy_value 天数值
     * deploy_type 4|5   4代表是否开启销售助手 5 待变销售助手开启之后下的5个指标
     */
    public function setXiaoshouZhushou()
    {
        $name = $_REQUEST['name'];
        $is_open = $_REQUEST['is_open'];
        $deploy_value = $_REQUEST['deploy_value'];
        $deploy_type = $_REQUEST['deploy_type'];
        if($deploy_type==4||$deploy_type==6){
            //编辑开启关闭
            $sql = "update ld_appsystem set is_open=? where deploy_type=?";
            $res = $this->adb->pquery($sql,[$is_open,$deploy_type]);
        }else if($deploy_type==5){
            //编辑天数  开启关闭
            $sql = "update ld_appsystem set is_open=? ,deploy_value=? where deploy_type=? and `name`=?";
            $res = $this->adb->pquery($sql,[$is_open,$deploy_value,$deploy_type,$name]);
        }
        $effect_num = $this->adb->getAffectedRowCount($res);
        ConvertTojsonString($effect_num>0?1:-1,['effect_num'=>$effect_num],$effect_num>0?'success':'fail');

    }

    /**
     *获取销售助手数据
     * 当deploy_type=4 代表是否开启销售助手 为yes时候 才查询下属5个指标的开启关闭数据
     */
    public function getXiaoshouZhushou()
    {
        //salesData
        $XiaoshouZhushouSet = $this->getXiaoshouZhushouSet("yes");
        $is_open = $XiaoshouZhushouSet['whetherShow']['is_open'];
        $isKeyViewOpen = $XiaoshouZhushouSet['keyViews']['is_open'];
        $XiaoshouZhushouSet = $XiaoshouZhushouSet['list'];
        $res = [];
        $_REQUEST['is_list'] = "yes";
        //销售助手开启 才显示五条数据
        if($is_open=="yes") {
            foreach ($XiaoshouZhushouSet as $v) {
                if ($v['is_open'] != 'yes') {
                    continue;
                }
                $days = $v['deploy_value'];
                $this->getXiaoshouZhushouCond($days,$v['name']);
                $mobj = cls_Instance::get_moduleAction_Instance($v['name'], 'ListView');
                $count_sql = $mobj->get_page_query(null, "yes");
                $count_res = $this->adb->pquery($count_sql);
                $v['value'] = $this->adb->num_rows($count_res);
                $v['value'] = empty($v['value']) ? 0 : $v['value'];
                $res[] = $v;
            }
        }
        return ['res'=>$res,'isKeyViewOpen'=>$isKeyViewOpen];
    }

    /**
     * @param $days
     * @param $salesassistant_name
     * 销售助手5个指标的查询条件拼接 Accounts Potentials PaymentPlan Contacts都是简单字符串拼接条件
     * ServiceContracts因联表查询  用到了高级查询条件拼接
     */
    public function getXiaoshouZhushouCond($days,$salesassistant_name)
    {
        switch ($salesassistant_name) {
            case "Accounts":
                $last_day = date('Y-m-d H:i:s', strtotime("-$days days"));//超过7天没有跟进的客户
                $timecond = ["<", $last_day];
                $_REQUEST['lastcontactdate'] = " (ld_account.lastcontactdate is null or ld_account.lastcontactdate" . $timecond[0] . "'" . $timecond[1] . "')";
                break;
            case "Potentials":
                $current_day = date('Y-m-d');
                $last_day = date('Y-m-d', strtotime("+$days days"));//预计30天内成交的销售机会
                $_REQUEST['closingdate'] = " ld_potential.closingdate is not null and ld_potential.closingdate between '" . $current_day . "' and '" . $last_day . "'";
                break;
            case "PaymentPlan":
                //7天内需要收款的回款计划 ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D
                $current_day = date('Y-m-d');
                $last_day = date('Y-m-d', strtotime("+$days days"));
                $_REQUEST['plandate'] = " ld_paymentplan.plandate is not null and ld_paymentplan.paymentstatus<>'已收' and ld_paymentplan.plandate between '" . $current_day . "' and '" . $last_day . "'";
                break;
            case "ServiceContracts":
                //4）30天内将到期的服务合同（模块未开启，则该值隐藏不显示）
                //ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:products_服务到期日:D
                $current_day = date('Y-m-d');
                $last_day = date('Y-m-d', strtotime("+$days days"));
//                $_REQUEST['servicecontracts_end_date'] = " (ld_servicecontractsdetail.servicecontracts_end_date is not null and ld_servicecontractsdetail.servicecontracts_end_date between '" . $current_day . "' and '" . $last_day . "')";
                $_REQUEST['servicecontracts_end_date_bw'] = "$current_day,$last_day";
                $_REQUEST['report_name'] = "SalesAssistant";
                $_REQUEST['salesassistant_name'] = "ServiceContracts";
                break;
            case "Contacts":
                //最近7天将要过生日的联系人（生日字段隐藏，则该区块不显示，模块未开启，则该值隐藏不显示）  ceshihshhs
                //ld_contactdetails:birthday:birthday:Contacts_生日:D
                $days = $days-1;
                $year = date('Y');
                $next_year = $year+1;
                $_REQUEST['birthday'] = " (concat($year,DATE_FORMAT(ld_contactdetails.birthday,'-%m-%d')) >= DATE_FORMAT(now(),'%Y-%m-%d')  and concat($year,DATE_FORMAT(ld_contactdetails.birthday,'-%m-%d')) <= DATE_FORMAT(date_add(now(),  INTERVAL $days DAY),'%Y-%m-%d') or concat($next_year,DATE_FORMAT(ld_contactdetails.birthday,'-%m-%d')) >= DATE_FORMAT(now(),'%Y-%m-%d')  and concat($next_year,DATE_FORMAT(ld_contactdetails.birthday,'-%m-%d')) <= DATE_FORMAT(date_add(now(),  INTERVAL $days DAY),'%Y-%m-%d')) ";
                break;
        }
    }
    public function getXiaoshouZhushouHighSearch()
    {
        $salesassistant_name = $_REQUEST['salesassistant_name'];
        $sql = "select deploy_value from ld_appsystem where name=? and deploy_type=5";
        $res = $this->adb->pquery($sql,[$salesassistant_name]);
        $days = $this->adb->query_result($res,0,'deploy_value');
        $this->getXiaoshouZhushouCond($days,$salesassistant_name);
    }

    public function getApproveFixedlabel(){
        $approve_label_arr=array(
            'APPROVALITEMS',//审批事项
            'SALESASSISTANT',//销售助手
            'CRITICALVIEW',//关键视图
            'Pending1',//待审批
            'Approved',//已批准
            'isubmitted1',//我提交的
            'ApproveRejected',//被驳回的
            'NODATATOBEAPPROVED',//没有待审批数据
            'NOMOREDATATOBEAPPROVED',//没有更多待审批数据
            'NOAPPROVEDDATA',//没有已批准数据
            'NOMOREAPPROVEDDATA',//没有更多已批准数据
            'NODATASUBMITTEDBYME',//没有我提交的数据
            'NOMOREDATASUBMITTEDBYME',//没有更多我提交的数据
            'NOREJECTEDDATA',//没有被驳回的数据
            'NOMOREREJECTEDDATA',//没有更多被驳回的数据
            'APPROVAL',//审批
            'SEARCHNEW',//搜索
            'APPWORKBENCH',//工作台
            'APPFUNCTION',//功能
            'staydo',//待办
            'OFTENUSEREPORTWORD',//报表
            'APPSETTINGS',//设置
            'SET',//设置
            'nodata',//没有数据
            'NOMOREDATA',//没有更多数据
            'RemindsCenter',//消息中心
            'LBL_UNREADEN',//未读
            'LBL_READEN',//已读
            'LBL_SENDED',//我发送的
            'SetAllAsRead',//全部已读
        );
        $approve_fixedlabel_arr = TransFieldlabel($approve_label_arr);
        return $approve_fixedlabel_arr;
    }
}
?>
