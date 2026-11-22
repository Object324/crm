<?php
//公共的 CRM小程序  1000159	提醒
//小程序增加消息提醒功能，关注公众号，接收提醒
class cls_reminds_offiaccount
{
    const DOMGMAO_AFFIACCOUNT_CN = 'CRM公众号';//公众号
    const DOMGMAO_AFFIACCOUNT_EN = 'CRMoffiaccount';//公众号
    public $appid;//公众号appid 我们自己的 wx70bee1ea15cf5889
    public $appsecret;//公众号appsecret  我们自己的 d6db480411ae09f25c9c80b5b61f6ad4
    public $miniprogram_appid;//客户小程序  我们自己的 wx608d4c0ec205411f
    public $miniprogram_secret;//客户小程序app secret 27897d4e7540c5bb8e37964f291fbde2
    public $OffiaccountMessageObj;
    public $corporate_account;//企业号
    public $msgtype = 'ld';//发送公众号消息的方式 ld灵当软件 oem:oem小程序

    public function __construct()
    {
        //查询
        global $adb;
        $sql = " select para_content,para_one from ld_wx_config where name='wechat_miniprogram_setting'";
        $res = $adb->pquery($sql);
        $para_content = $adb->query_result($res,0,'para_content');
        $this->corporate_account = $adb->query_result($res,0,'para_one');//企业号
        $para_content = Zend_Json::decode($para_content);
        //zxm 20221013没有设置过小程序提醒参数，或者设置使用的小程序AppID是“wx608d4c0ec205411f”，则升级后默认为“使用灵当CRM小程序和微信公众号”
        if(empty($para_content)||$para_content['mini_appid']=="wx608d4c0ec205411f"||$para_content['msgsend_type']=='msgsend_typeld'){
            require_once globalStatic::$root_directory.'include/weixinMsg/MsgConfig.php';
            $ldappidsecret = MsgConfig::$ldappidsecret;
            $this->appid = $ldappidsecret['offiaccount_appid'];//灵当公众号appid
            $this->appsecret = $ldappidsecret['offiaccount_secret'];//灵当公众号app secret
            $this->miniprogram_appid = $ldappidsecret['mini_appid'];//灵当小程序appid
            $this->miniprogram_secret = $ldappidsecret['mini_secret'];//灵当小程序 app secret
            $this->msgtype = 'ld';
        }else{
            $this->appid = $para_content['offiaccount_appid'];//公众号appid
            $this->appsecret = $para_content['offiaccount_secret'];//公众号app secret
            $this->miniprogram_appid = $para_content['mini_appid'];//小程序appid
            $this->miniprogram_secret = $para_content['mini_secret'];//小程序 app secret
            $this->msgtype = 'oem';
        }
        include_once(globalStatic::$root_directory . 'include/weixinMsg/cls_OffiaccountMessage.php');
        $this->OffiaccountMessageObj = new cls_OffiaccountMessage(
            $this->appid,
            $this->appsecret,
            self::DOMGMAO_AFFIACCOUNT_EN,
            self::DOMGMAO_AFFIACCOUNT_CN,
            self::DOMGMAO_AFFIACCOUNT_EN
        );
    }

    /**
     * @param $remindsidArr  ld_reminds表主键id  多个为数组
     * @param $rRemindType
     * @param $rOtherParam  其他参数 例如客户模块的话 客户编号  合同模块的话 合同编号
     * @return void
     * @throws Exception
     * 发送小程序对应公众号的消息
     */
    public function sendAllTypeRemindsImmediately($remindsidArr,$rRemindType,$rOtherParam,$rworkreport='')
    {
        //remindtype==massallocate，批量分配 related_to参数是ld_reminds表的parentid
        //remindtype='',单个分配，related_to参数是对应模块单据id

        if($rRemindType=='allocate'||$rRemindType=='massallocate'){
            $templatetype = 'allocate';//分配 Allocate
        }else if($rRemindType=='Approve'){
            $templatetype = 'approve';//审批
        }else if($rRemindType=='jiaofu'){
            $templatetype='jiaofu';//“交付提醒”、“产品服务到期提醒”、“收付款计划到期提醒”
        }else if($rRemindType=='other'){
            $templatetype='other';//’其他
        }else{
            return;
        }
        global $adb,$current_user;
        if (is_array($remindsidArr)) {
            $remindsidArr = implode(',',$remindsidArr);
        }
        if(empty($remindsidArr)){
            return;
        }
        //zkt 20220922 BUG0056846合同订单-交付日期提醒，公众号提醒发送了两条一样的消息
        $select_sql = "select
r.content,
r.recieverid,r.related_to,r.reltab,r.remindsid,r.remindstype,
b.open_id,a.wechatuserid,c.last_name
from
ld_reminds r
left join ld_users c on c.id=r.recieverid
left join (select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>'') a on a.userid=c.id
left join (select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>'') b on a.unionid=b.unionid
where r.remindsid in ( ".$remindsidArr.")   and r.push_to_offiaccount = 2 and c.push_wx_reminds = 1 and ifnull(c.wx_openid,'')<>'' and  ifnull(b.open_id,'')<>'' " ;

        //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版） 工作汇报回复没有pc端提醒
if(!empty($rworkreport)){
    if($rworkreport=='reply'){
        $select_sql="SELECT Q.content,w.smcreatorid as recieverid,w.workreport_no,w.entitytype,w.workreportid as related_to,Q.relatedto ,Q.id as remindsid,'CooperativeWork' as reltab,b.open_id,a.wechatuserid,c.last_name
from ld_workreport_remind Q
left join ld_workreport w on Q.relatedto=w.workreportid
left join ld_users c on c.id=w.smcreatorid
left join (select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>'') a on a.userid=c.id
left join (select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>'') b on a.unionid=b.unionid
where Q.id = '$remindsidArr' and Q.userid <> '$current_user->id'
and Q.push_to_offiaccount = 2 and c.push_wx_reminds = 1 and ifnull(c.wx_openid,'')<>'' and  ifnull(b.open_id,'')<>''  ";
    }else if($rworkreport=='comment'){
        $select_sql="SELECT
    Q.content,
    w.smcreatorid as recieverid,w.workreport_no,w.entitytype,
    w.workreportid as related_to,
    Q.relatedto ,Q.id as remindsid,'CooperativeWork' as reltab,
    b.open_id,a.wechatuserid,c.last_name
from ld_workreport_remind Q
left join ld_workreply y on y.workreplyid=Q.relatedto
left join ld_workreport w on y.workreportid=w.workreportid
left join ld_users c on c.id=w.smcreatorid
left join (select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>'') a on a.userid=c.id
left join (select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>'') b on a.unionid=b.unionid
where Q.id = '$remindsidArr'  and Q.userid <> '$current_user->id'
and Q.push_to_offiaccount = 2 and c.push_wx_reminds = 1 and ifnull(c.wx_openid,'')<>'' and  ifnull(b.open_id,'')<>''  ";
    }
    else if($rworkreport=='praise'){
        $select_sql="SELECT
    Q.content,
    w.smcreatorid as recieverid,w.workreport_no,w.entitytype,
    w.workreportid as related_to,
    Q.relatedto ,Q.id as remindsid,'CooperativeWork' as reltab,
    b.open_id,a.wechatuserid,c.last_name
from ld_workreport_remind Q
left join ld_praise p on p.praiseid=Q.relatedto
left join ld_workreport w on p.workreportid=w.workreportid
left join ld_users c on c.id=w.smcreatorid
left join (select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>'') a on a.userid=c.id
left join (select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>'') b on a.unionid=b.unionid
where Q.id = '$remindsidArr' and Q.userid <> '$current_user->id'
and Q.push_to_offiaccount = 2 and c.push_wx_reminds = 1 and ifnull(c.wx_openid,'')<>''  and  ifnull(b.open_id,'')<>''  ";
    }else if($rworkreport=='copyin'){
        $select_sql="SELECT
    Q.content,
    w2u.userid as recieverid,w.workreport_no,w.entitytype,
    w.workreportid as related_to,
    Q.relatedto ,Q.id as remindsid,'CooperativeWork' as reltab,
    b.open_id,a.wechatuserid,c.last_name
from ld_workreport_remind Q
left join ld_workreport w on w.workreportid=Q.relatedto
left join ld_workreport2user w2u on w.workreportid=w2u.workreportid
left join ld_users c on c.id=w2u.userid
left join (select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>'') a on a.userid=c.id
left join (select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>'') b on a.unionid=b.unionid
where Q.id = '$remindsidArr' 
    and Q.push_to_offiaccount = 2
    and c.push_wx_reminds = 1  and ifnull(c.wx_openid,'')<>'' 
  and  ifnull(b.open_id,'')<>''  group by Q.id,w2u.userid ";
    } //User_type=1 or w2u.User_type=5
}
        $result = $adb->pquery($select_sql);
        $nums = $adb->num_rows($result);

        $sendmsg = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                //$content = html_entity_decode( $adb->query_result($result,$i,'content'));//内容
                //$content = str_replace('<br>',' ', $content);//内容

                $content = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($adb->query_result($result,$i,'content'))));
                $content = strip_tags(str_replace('"', '\"', $content),'<br>');
                $content = str_replace('<br>',' ', $content);//内容
                $content = str_replace('<br/>',' ', $content);//内容

                $recieverid = $adb->query_result($result,$i,'recieverid');//接收人id  ld_users的id
                $related_to = $adb->query_result($result,$i,'related_to');//单据id  比如客户id
                $reltab = $adb->query_result($result,$i,'reltab');//模块名称 比如Accounts

                $remindsid = $adb->query_result($result,$i,'remindsid');//ld_reminds表的主键id
                $open_id = $adb->query_result($result,$i,'open_id');
                $wechatuserid  = $adb->query_result($result,$i,'wechatuserid');
                $last_name  = $adb->query_result($result,$i,'last_name');
                if(!empty($rworkreport)){
                    $entitytype = $adb->query_result($result,$i,'entitytype');//工作汇报的类型
                }
                else{
                    $remindstype = $adb->query_result($result,$i,'remindstype');//ld_reminds表的remindtype
                }
                if($rRemindType=='massallocate'){
                    //批量分配
                    $table_code = _array_column($rOtherParam,'table_code');
                    $table_code = implode(',',$table_code);

                    $list_link_field = _array_column($rOtherParam,'subject');
                    $list_link_field = implode(',',$list_link_field);
                    //批量分配的单据id
                    //second_action=mass_remind&second_para=$recieverid
                    //zkt 20230330 BUG0063743  微信小程序（81kfbcrm企业号），点击收款计划共享消息提醒内容后，单据列表界面显示空白（收款计划编号：GP104） 
                    $listtype =  'list';
                    $fromterminal =  'xiaochengxu';//来源终端
                    $MsgPage = "pages/detailview/detailview?modulename=".$reltab.'&recordID='.$related_to.'&listType='.$listtype.'&fromterminal='.$fromterminal.'&getcode=yes';
                    if(strpos($remindstype,'mass')!==false){
                        $MsgPage = "pages/listview/listview?module=".$reltab.'&getcode=yes&second_action=mass_remind&second_para='.$remindsid;
                    }
                }else if($reltab=='CooperativeWork'){
                    if(!vtlib_isModuleActive($reltab)){
                        //zxm 20240412 模块未激活 消息应该不提醒 BUG20240412-16	工作汇报--现在模块关闭后，提醒的参数会消失，但是不会关闭相应的提醒，提醒应随着模块的关闭一起关闭
                        continue;
                    }
                    $fromterminal =  'xiaochengxu';//来源终端
                    $table_code = $adb->query_result($result,$i,'workreport_no');//工作汇报单据编号
                    $list_link_field = $rOtherParam[$related_to]['subject'];
                    //工作汇报 详情页
                    //url='detailview/detailview?curid=&worktype=;
                    $MsgPage = 'pages/componentwork/work/detailview/detailview?curid='.$related_to.'&worktype='.$entitytype.'&fromterminal='.$fromterminal.'&getcode=yes';
                    if(empty($related_to)){
                        $MsgPage = 'pages/componentwork/work/work?module=CooperativeWork';
                    }
                }else {
                    //分配  审批
                    $listtype =  'list';
                    $fromterminal =  'xiaochengxu';//来源终端
                    if($rRemindType=='Approve'){
                        //审批
                        $listtype =  'approvelist';
                    }
                    $table_code = $rOtherParam[$related_to]['table_code'];
                    $list_link_field = $rOtherParam[$related_to]['subject'];
                    if(empty($related_to))
                    {
                        //edit:can BUG20241021-03
                        if($remindstype=='AccountsBEFOREREMIND')
                        {

                            $table_code='公海回收';
                        }
                        $MsgPage = "pages/listview/listview?module=".$reltab.'&getcode=yes&second_action=mass_remind&second_para='.$remindsid;
                      //  $MsgPage = "pages/detailview/detailview?modulename=".$reltab.'&recordID='.$related_to.'&listType='.$listtype.'&fromterminal='.$fromterminal.'&getcode=yes';
                    }
                    else
                        $MsgPage = "pages/detailview/detailview?modulename=".$reltab.'&recordID='.$related_to.'&listType='.$listtype.'&fromterminal='.$fromterminal.'&getcode=yes';
                }
                $corporate_account = '&corporate_account='.$this->corporate_account;//企业号
                $MsgPage .= $corporate_account;
                $data = array(

                    'content' => $content,
                    'table_code' => $table_code,//编号
                    'record' => $list_link_field,//超链接字段
                    'modulename' => getTranstab($reltab),
                    'username' => $current_user->last_name,
                    'time' => date('Y-m-d H:i:s',time()),
                    'remark' => "点击前往小程序查看详情",
                );
                //zkt 20230329 BUG0063744 微信小程序（81kfbcrm企业号），收款计划到期催收提醒消息，业务负责人显示空白（收款计划编号：GP102） 
                if($templatetype == 'jiaofu'&&isset($rOtherParam[$related_to]['smownername'])){
                    $data['username'] = $rOtherParam[$related_to]['smownername'];
                }
                //zxm 20230629 模板中的审批人不应当是当前用户 c传过来当前审批人的ID  逗号分隔的
                if($rRemindType=='Approve'){
                    $nextstepapproveby = $rOtherParam[$related_to]['nextstepapproveby'];
                    $tmp_namefield = 'last_name';
                    if(isKehu001ServerPc()=='yes'){
                        $tmp_namefield = 'real_name';
                    }
                    $user_sql = " select group_concat($tmp_namefield) as user_name from ld_users where find_in_set(id,'$nextstepapproveby') ";
                    $user_res = $adb->pquery($user_sql,array());
                    $user_nums = $adb->num_rows($user_res);
                    if($user_nums>0){
                        $tempvalue = $adb->query_result($user_res,0,0);
                        $tempvalue = trim($tempvalue,',');
                        $data['username'] = $tempvalue;
                    }
                }
                $tradeInfo = getVersionTradeInfo();
                if($tradeInfo['account']=='yihailan'){
                    //$data['username']=str_replace('-','',$data['username']);//新的模板  这个字段要求5个汉字
                    $data['username'] = $this->match_chinese($data['username']);
                    $data['username']= mb_substr($data['username'],0,5);//新的模板  这个字段要求5个汉字
                }
                //截取内容长度 由于公众号规定  所有value的总长度不能超过200字，按照utf8字符个数
                //zxm 20231113 由于公众号规定 content长度最多20个字
                //$contentAll = $list_link_field.getTranstab($reltab).$current_user->last_name.date('Y-m-d H:i:s',time())."点击前往小程序查看详情";
                //$contentLength = 200-strlen($contentAll)-3;
                $contentLength = 17;
                $data['content'] = mb_substr($data['content'],0,$contentLength);
                $data['content'] = $data['content'].'...';
                if($data['username']=='')
                {
                    $swomnerlastname = getUserFullName($recieverid);
                    $data['username']=$swomnerlastname;
                }


                $sendmsg[$i] = $this->send($templatetype,$open_id,$MsgPage,$data,$wechatuserid,$reltab,$related_to,'miniprogram',$wechatuserid);
                $this->sendDueDateReminds($remindsid,$rworkreport);
            }
        }
        return json_encode($sendmsg);
    }
//wyt 220805 XUQIU1000508 小程序增加消息提醒功能，关注公众号，接收提醒（第三版）
    public function sendDueDateReminds($ids,$rworkreport=''){
        global $adb;
        if($rworkreport=='reply'||$rworkreport=='comment'||$rworkreport=='praise'||$rworkreport=='copyin'){
            $sql = 'update ld_workreport_remind set push_to_offiaccount=? ,push_time_offiaccount=? where id =?';
        }else{
            $sql = 'update ld_reminds set push_to_offiaccount=? ,push_time_offiaccount=? where remindsid =?';
        }
        $adb->pquery($sql, array(3, date("Y-m-d H:i:s"),$ids));

    }

    //获取能够使用的模板列表以及对应参数
    //参数为空则返回整个数组
    public function getTemplateInfo($templateName = null)
    {
        $tradeInfo = getVersionTradeInfo();
        //灵当软件 模板消息 模板
        $templateIds = array(
            'allocate'=>'V07Mhn0InA0ChAwPm6H9EqgVkOswFZt01_eF7x6UFxk',
            'approve'=>'fBpwmMBnJyP2y_VW8JqSEGyADOFQMnz8zoW-6TTD7KM',
            'jiaofu'=>'aFCczWRLxEKnYdY8On6EYBFr5yEFlDcAGzPbosq1oxs',
            'other'=>'n3Qh55SP7S9aT2LJ3eM2iqCIarHURBvL9x6iSe81qfA'
        );
        //七涛
        if($tradeInfo['account']=='jinan_lingdang'){
            $templateIds = array(
                'allocate'=>'_V0Uo-RCjVz0-Pp0qKbkNu5zdV_3BBgan-XhanVt7-c',
                'approve'=>'lV1vQN-8UNLcqE5PG1t92hLBQ40GMsjbHIG_I3ITXoc',
                'jiaofu'=>'',
            );
        }
        //郭惠宇 客户 北京齐力
        if($tradeInfo['account']=='bjqili'){
            $templateIds = array(
                'allocate'=>'_K2UXKz00RcmOdbTpsAKQAEDE9LZBzJL8dPXIsEmeLc',//业务分配提醒
                'approve'=>'qKbXFxDQsdgxpv7ANF8H9PPzU_40Hvjw8ySt5aUJouA',//业务审批提醒
                'jiaofu'=>'H2fXeXWT9vpDAQ8HfBag7eUuFxYtrkJq4X-pAjYHzZs',//业务交付提醒
            );
        }
        //张航天客户 客户 中天火箭
        if($tradeInfo['account']=='zthj'){
            $templateIds = array(
                'allocate'=>'8rOxTSSnByxyczr7xZW2P5IR9oCX0hfF7zrG2f8ya1Y',//业务分配提醒
                'approve'=>'Siy0h5RluZfORTBZ-WuVFldn6gWb-B2VCAt-K3QbBhs',//业务审批提醒
                'jiaofu'=>'oKcju5rJAZdP8CoxjYBfJIedLIrwzWfZ85kUdFHO_KA',//业务交付提醒
            );
        }
        //陈钦帅客户 客户 新特新材料
        if($tradeInfo['account']=='zhongde'){
            $templateIds = array(
                'allocate'=>'L_AVhJEWYq0222X93TcQISqWBHf4i7bFVcpFw5MbHGk',//业务分配提醒
                'approve'=>'s0KNOdG9zXZOMzN84gVrhD_mNYCoV-Wyemykz2nuV7g',//业务审批提醒
                'jiaofu'=>'nn7FFZizb36u1dtE0yCaumxfSVI99dHgm9R39YENne8',//业务交付提醒
            );
        }
        ////郭惠宇客户--这个客户是OEM小程序使用客户自有公众号发送消息  需要使用新类目发送消息.老的历史模板不可搜索了
        if($tradeInfo['account']=='yihailan'){
            //zxm 20231117 kfbcrm做测试 做完测试这个判断需要放开
            $templateIds = array(
                'newreminds'=>'6VIIexcm8Ba-FwwwO44t1j5luEPIg3BL_CiJYsLzT1s',
            );
        }
        $templateList = [
            //1.分配
            'allocate' => [
                'name' => '业务分配提醒',
                'template_id' => $templateIds['allocate'],
                'data' => [
                    "first" => [
                        "value" => "邱小光将潘露露的客户分配给您，请及时关注！客户：湖北灵当有限公司",//消息简介
                        "color" => "#173177"
                    ],
                    "keyword1" => [
                        "value" => "EmptyModuleNo",//业务编号
                        "color" => "#173177"
                    ],
                    "keyword2" => [
                        "value" => "客户",//业务名称
                        "color" => "#173177"
                    ],
                    "keyword3" => [
                        "value" => "无人员信息",//分配人
                        "color" => "#173177"
                    ],
                    "keyword4" => [
                        "value" => "2022-07-25 10:00:00",//分配时间
                        "color" => "#173177"
                    ],
                    "remark" => [
                        "value" => "点击前往小程序查看详情",
                        "color" => "#173177"
                    ],
                ],
                'var' => [
                    "first" => 'content',
                    "keyword1" => 'record',
                    "keyword2" => 'modulename',
                    "keyword3" => 'username',
                    "keyword4" => 'time',
                    "remark" => 'remark'
                ]
            ],
            //2.审批
            'approve' => [
                'name' => '业务审批提醒',
                'template_id' => $templateIds['approve'],
                'data' => [
                    "first" => [
                        "value" => "您提交的单据已通过审批！",//消息简介
                        "color" => "#173177"
                    ],
                    "keyword1" => [
                        "value" => "EmptyModuleNo",//业务编号
                        "color" => "#173177"
                    ],
                    "keyword2" => [
                        "value" => "客户",//业务名称
                        "color" => "#173177"
                    ],
                    "keyword3" => [
                        "value" => "无人员信息",//审批人
                        "color" => "#173177"
                    ],
                    "keyword4" => [
                        "value" => "2022-07-25 10:00:00",//审批时间
                        "color" => "#173177"
                    ],
                    "remark" => [
                        "value" => "点击前往小程序查看详情",
                        "color" => "#173177"
                    ],
                ],
                'var' => [
                    "first" => 'content',
                    "keyword1" => 'record',
                    "keyword2" => 'modulename',
                    "keyword3" => 'username',
                    "keyword4" => 'time',
                    "remark" => 'remark'
                ]
            ],
            //3.业务交付提醒
            'jiaofu' => [
                'name' => '业务交付提醒',
                'template_id' => $templateIds['jiaofu'],
                'data' => [
                    "first" => [
                        "value" => "您的合同订单将于2022-08-05前交付，请及时关注！",//消息简介
                        "color" => "#173177"
                    ],
                    "keyword1" => [
                        "value" => "EmptyModuleNo",//业务编号
                        "color" => "#173177"
                    ],
                    "keyword2" => [
                        "value" => "客户",//业务名称
                        "color" => "#173177"
                    ],
                    "keyword3" => [
                        "value" => "无人员信息",//业务负责人
                        "color" => "#173177"
                    ],
                    "keyword4" => [
                        "value" => "2022-07-25 10:00:00",//计划交付时间
                        "color" => "#173177"
                    ],
                    "remark" => [
                        "value" => "点击前往小程序查看详情",
                        "color" => "#173177"
                    ],
                ],
                'var' => [
                    "first" => 'content',
                    "keyword1" => 'record',
                    "keyword2" => 'modulename',
                    "keyword3" => 'username',
                    "keyword4" => 'time',
                    "remark" => 'remark'
                ]
            ],
            //4.其他
            'other' => [
                'name' => '业务处理结果通知',
                'template_id' => $templateIds['other'],
                'data' => [
                    "first" => [
                        "value" => "重要活动通知：本周六上午10点将于静安灵当酒店举行公司周年庆活动，欢迎各位莅临！",//消息简介
                        "color" => "#173177"
                    ],
                    "keyword1" => [
                        "value" => "公告",//服务类型--模块名称
                        "color" => "#173177"
                    ],
                    "keyword2" => [
                        "value" => "2018-03-07 16:40:38",//办理时间
                        "color" => "#173177"
                    ],
                    "keyword3" => [
                        "value" => "已发送成功",//服务状态
                        "color" => "#173177"
                    ],
                    "remark" => [
                        "value" => "点击前往小程序查看详情",
                        "color" => "#173177"
                    ],
                ],
                'var' => [
                    "first" => 'content',
                    "keyword1" => 'record',
                    "keyword2" => 'time',
                    "keyword3" => 'modulename',
                    "remark" => 'remark'
                ]
            ],
            //5 这个是新的类目变更之后的模板 适用所有提醒类型
            'newreminds' =>[
                'name' => '系统流程审批提醒',
                'template_id' => $templateIds['newreminds'],
                'data' => [
                    "thing14" => [
                        "value" => "无效模块名称",//其实是模块名称//申请项目
                    ],
                    "character_string5" => [
                        "value" => "EmptyModuleNo",//其实是单据编号//业务单号
                    ],
                    "time13" => [
                        "value" => "2018-03-07 16:40:38",//处理时间
                    ],
                    "thing1" => [
                        "value" => "分配",//在这里告诉用户是分配还是审批还是别的什么提醒/流程名称
                    ],
                    "phrase3" => [
                        "value" => "无人员信息",//申请人/分配人/单据负责人
                    ],
                ],
                'var' => [
                    "thing14" => 'modulename',//模块名称
                    "character_string5" => 'table_code',//单据编号
                    "time13" => 'time',//时间
                    "thing1" => 'content',//提醒内容--20字内
                    "phrase3" => 'username'//申请人/分配人/单据负责人
                ]
            ]
        ];
        //郭惠宇客户--这个客户是OEM小程序使用客户自有公众号发送消息  需要使用新类目发送消息.老的历史模板不可搜索了
        if($tradeInfo['account']=='yihailan'){
            //zxm 20231117 kfbcrm做测试 做完测试这个判断需要放开
            return $templateList['newreminds'];
        }
        if (isset($templateList[$templateName]) && !empty($templateList[$templateName])) {
            return $templateList[$templateName];
        }
        return $templateList;
    }

    //微信公众号 接口 获取模板id的方法--todo--
    public function getTemplateId($templateName = null){
        $access_token = $this->OffiaccountMessageObj->getAccessToken();

        $template_id_short_arr = [
            'allocate'=>'OPENTM418556727',//分配、共享
            'approve'=>'OPENTM418557985',//审批
            'jiaofu'=>'OPENTM418595591',//交付
            'other'=>'OPENTM414875757'//其他 业务处理结果通知
        ];
        $url = 'https://api.weixin.qq.com/cgi-bin/template/api_add_template?access_token='.$access_token;
        $param = ["template_id_short"=>$template_id_short_arr[$templateName]];
        $param = json_encode($param);
        $arr = json_decode($this->OffiaccountMessageObj->curlPost($url,$param),true);
        return $arr['template_id'];
    }

    /**
     * @param string $templateName //模板名称
     * @param $open_id
     * @param $page //跳转页面
     * @param $data //模板内容
     * @param $wechatuserid //微信用户表ID
     * @param $modulename //模块名称
     * @param $record //模板单据ID
     * @param $pageType //消息跳转类型   miniprogram小程序  offiaccount公众号
     * @param $accountid //客户ID
     * @return bool|string
     */
    public function send($templateName, $open_id, $page = '', $data='', $wechatuserid='', $modulename='', $record=0, $pageType='', $accountid=0)
    {
        $template_info = $this->getTemplateInfo($templateName);
        $template_id = $template_info['template_id'];
        $appid = $this->miniprogram_appid;//跳转小程序的appid 东茂的小程序  先写死

        $dataInfo = $template_info['data'];
        $varInfo = $template_info['var'];
        $title = $template_info['name'];
        foreach ($dataInfo as $k => &$v) {
            $varname = $varInfo[$k];
            if(!empty($data[$varname]))
                $v['value'] = $data[$varname];
        }

        $sendmsg = $this->OffiaccountMessageObj->send($template_id, $page, $dataInfo, $open_id, $appid, $pageType);//发送订阅消息
        $sendmsg_arr = Zend_Json::decode($sendmsg);

        $errcode = $sendmsg_arr['errcode'];
        //duan 20230831 微信公众号消息错误检测重发
        if(empty($sendmsg) || $errcode==41001){
            $sendmsg = $this->OffiaccountMessageObj->send($template_id, $page, $dataInfo, $open_id, $appid, $pageType);//发送订阅消息
            $sendmsg_arr = Zend_Json::decode($sendmsg);
            $errcode = $sendmsg_arr['errcode'];
        }
        $errcode = $errcode == 0 ? 'success' : 'error';
        $insert_arr[] = [
            $template_id,
            $page,
            json_encode($dataInfo, JSON_UNESCAPED_UNICODE),
            $wechatuserid,
            $modulename,
            $record,
            date('Y-m-d H:i:s', time()),
            date('Y-m-d H:i:s', time()),
            $sendmsg,
            $errcode,
            $open_id,
            self::DOMGMAO_AFFIACCOUNT_CN,
            self::DOMGMAO_AFFIACCOUNT_EN,
            $accountid,
            $title
        ];
        if (!empty($insert_arr)) {
            //数组参数顺序template_id,pageurl,content,wechatuserid,modulename,record,createdtime,sendtime,sendmessage,sendstatus,open_id,userfrom,userfromvalue,title
            $this->OffiaccountMessageObj->saveMsgForUser($insert_arr);
        }
        return $sendmsg;
    }
    //所有中英文符号
    public function match_chinese($chars,$encoding='utf8')
    {
        $pattern =($encoding=='utf8')?'/[\x{4e00}-\x{9fa5}]/u':'/[\x80-\xFF]/';
        preg_match_all($pattern,$chars,$result);
        $temp =join('',$result[0]);
        return $temp;
    }
    //所有的数字和字母
    public function match_character($chars){
        $pattern = '/^[a-zA-Z0-9]+$/';
        preg_match_all($pattern,$chars,$result);
        $temp =join('',$result[0]);
        return $temp;
    }
}