<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

crm_load_class_file('cls_ListViewShareUserWX','WeiXinApp/list');
$recordid = $_REQUEST['recordid'];
$mobj = new cls_ListViewShareUserWX($_REQUEST['recordid']);
$sharecontent = $mobj->get_listdetail('','');
$sharebutton = isPermitted(getSalesEntityType($recordid),'Share',$recordid);
$list_buttons = array();
if($sharebutton=='yes') $list_buttons = array(1);
$sharelist = $sharecontent;
$sharelist['list2']['create_html'] = $list_buttons;
//列表页面
$label_arr=array(
    'LBL_NOALLOCATE',//公海未分配
    'LBL_PUBLICALLOCATE',//公海已分配
    'ALL',//全部
    'TOBEALLOCATED',//待分配
    'BEURGED',//已催单
    'INPROCESS',//处理中
    'zhang',//张
    'EXPANDINVENTORYDETAILS',//展开库存详情
    'nodata',//没有数据
    'NOMOREDATA',//没有更多数据
    'NOTMPDATA',//没有%s数据
    'NOMORETMPDATA',//没有更多%s数据
    'MYSCHEDULE',//我的日程
    'OTHERSCHEDULE',//他人日程
    'CUSTOMIZESEARCH',//高级查找
    'PLEASESELECTSTARTDATE',//请选择开始日期
    'PLEASESELECTENDDATE',//请选择结束日期
    'TO',//至
    'pleaseenter',//请输入
    'NOADVANCEDSEARCHCONDITIONS',//暂无高级查找条件，请%s前往设置
    'RESET',//重置
    'LBL_PLEASE_SELECT',//请选择
    'SEARCHNEW',//搜索
    'NEW',//新增
    'TOTALOF',//共
    'RECORDNUMS',//条记录
    'Paymentplan',//收款
    'CHECK',//查重
    'Highseaspool',//公海池
    'CREATEBUSINESSCARD',//拍名片
    'ENTERPRISEWECHATCUSTOMERS',//企业微信客户
    'CreateDebuction',//预收
    'NORMAL',//普通
    'SEARCHFORVISITORS',//搜索拜访对象、地址、人员、签到时间、误差
    'ONEPICTUREBUSINESSCARD',//创建名片时只能上传1张图片
    'UPLOADFAILED',//上传失败
    'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
    'CONFIGURECUSTOMERCONTACTPARAMETERS',//企业微信后台没有配置客户联系参数
    'STOWINVENTORYDETAILS',//收起库存详情
    'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
    'RECORDSINTOTAL',//共%d条记录
    'UPLOADING',//上传中
    'UPLOADSUCCEEDED',//上传成功
    'Quickly_create',//快速创建
    'SHARE',//共享
    'PLEASESELECTATLEASTONEITEM',//请至少选择一项
    'FORMATERROR',//格式错误
);
$fixedlabel_arr = TransFieldlabel($label_arr);
$fixedlabel_arr = CombineLabelSolution('%s','NOADVANCEDSEARCHCONDITIONS',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
$fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);


//列表内容
$label_arr=array(
    'RELATIONAL',//关联
    'TOBEALLOCATED',//待分配
    'BEURGED',//已催单
    'INPROCESS',//处理中
    'CLOSEDBILL',//已结单
    'MORE',//更多
    'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
    'DISCUSSIONGROUP',//讨论组
    'ALLOCATE',//分配
    'NOOPERATIONPERMISSIONS',//没有更多操作权限
    'EDIT',//编辑
    'SHARE',//共享
    'RECEIVE',//领取
    'SUREYOUWANTCOLLECT',//确定要领取？
    'URGE',//催单
    'CLOSEBILL',//结单
    'REOPEN',//重新打开
    'SUBMITAPPROVAL',//提交审批
    'RETRACEMENT',//回撤
    'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
    'COPY',//复制
    'DELETE',//删除
    'SuccessDeleted',//删除成功！
    'SUREWANTDELETE',//确定要删除吗？
    'SUCCESSFULLYRECEIVED',//领取成功
    'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
    'RETREATSUCCEEDED',//回撤成功
    'SURETOASSOCIATE',//确定要关联吗？
    'NONUMBERTODIAL',//没有可拨打号码
    'CREATETMPQUICKLY',//是否快速创建%s？
    'QTY',
    'MAOHAO'
);
$fixedlabel_content_arr = TransFieldlabel($label_arr);
$fixedlabel_content_arr = CombineLabelSolution('%s','CREATETMPQUICKLY',$fixedlabel_content_arr);
$sharelist['arrFixedLabel_content']=$fixedlabel_content_arr;
$sharelist['arrFixedLabel']=$fixedlabel_arr;

ConvertTojsonString(1,$sharelist,'success');
?>