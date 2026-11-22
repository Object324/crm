/**
 * 列表按钮点击事件
 * @author Tujt 2015-05-28
 */
function listviewbuttons_click(obj, module, setype) {

    EmptyProgressObjs();
    var url = '';
    var is_bool = 1;
    if ('Accounts' == module) {//客户特别字段
        switch (setype) {
            case 'transfer'://转换公海
               cls_PublicAccount.mass_transfer();
                break;
			case 'convertpublic'://公海-全部-转为公海客户
               cls_PublicAccount.mass_transfer();
                break;
            case 'convertnormal'://公海-全部-转为普通客户
                cls_PublicAccount.mass_transfer();
                break;
            case 'massrelease'://公海-公海已分配-批量释放
                massrelease();
                break;
            case 'massallocate'://公海-公海未分配-批量分配
            case 'higndistribution':
                massDeskAllocatetaccount(obj);
                break;
            case 'averagehigndistribution':
                massDeskHighAvgAllocatetaccount(obj);
                break;
            case 'seniorHigndistribution':// 公海分配，可选是否同时分配相关信息
            case 'seniorAverageHigndistribution':// 公海平均分配
                getJsScript('include/js/SeniorAllocateShare.js', function () {
                    var seniorAllocateShare = new SeniorAllocateShare(module, setype);
                    seniorAllocateShare.getPopup();
                });
                break;
            case 'massget'://公海-公海未分配-批量领取
                massAllocate(3);
                break;
            case 'noallocateconvertnormal'://公海-公海未分配-转普通
                cls_PublicAccount.mass_transfer();
                break;
            case 'public_ordinary'://客户-新建-普通用户
                createNormal_Account();
                break;
            case 'public_notallocated'://客户-新建-公海未分配
                createpublic_notallocated();
                break;
            case 'public_allocated'://客户-新建-公海已分配
                createpublic_Allocated();

                break;
            case 'averageDistribution'://客户-分配-平均分配
                averageDistribution(obj, module, 'averageDistribution');
                break;

            case 'autocall'://批量外呼
                getJsScript('include/js/automaticcalling.js', function () {
                    automaticcalling(obj, '4');
                });
                break;
			case 'accountset'://客户参数设置
                getJsScript('include/js/cls_publicpool_set.js', function () {
                    var publicpool_setobj = new cls_publicpool_set(module);
                    publicpool_setobj.CreatePopup();
                    publicpool_setobj.refresh_after_save = 'yes';
                });
                //cls_PublicAccount.set_account_public();
				break;
            case 'autoDistribution'://圣拉维 客户-分配-自动分配
                cls_autoDistribution.autoDistribution_pop(obj, module, 'autoDistribution');
                break;
            default:
                is_bool = 0;
        }
        if (1 == is_bool) return false;
    }
    else if ('Documents' == module) {//知识管理
        switch (setype) {
            case 'Move'://移动
                List_CheckBox_Ids.getIds(module);

                if (List_CheckBox_Ids.num_rows > 0) {
                    fnvshobj(obj, 'movefolderlist');
                } else {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
                    return false;
                }
                break;
            case 'Addfolder'://添加文件夹
                fnvshobj(obj, 'orgLay');
                break;
            case 'Viewemptyfolder'://查看空文件夹
                fnvshobj(obj, 'emptyfolder');
                break;
            case 'Addtemplate'://添加模板
                var url = 'pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=showDocTemplateindex';
                redirect(url, 1);
                break;
            default:
                is_bool = 0;
        }
        if (1 == is_bool) return false;
    }
    else if('Leads' == module){
        //ZXM 2021-0527 销售线索
        switch (setype) {
            case 'transfer'://转换公海
            case 'convertpublic'://公海-全部-转为公海客户
            case 'convertnormal'://公海-全部-转为普通客户
            case 'noallocateconvertnormal'://公海-公海未分配-转普通
                cls_PublicLeads.mass_transfer();
                break;
            case 'massrelease'://公海-公海已分配-批量释放
                cls_PublicLeads.massrelease();
                break;
            case 'higndistribution':
                cls_PublicLeads.massDeskAllocatetaccount(obj);
                break;
            case 'averagehigndistribution':
                cls_PublicLeads.massDeskHighAvgAllocatetaccount(obj);
                break;
            case 'massget'://公海-公海未分配-批量领取
                cls_PublicLeads.massAllocate(3);
                break;
            case 'public_ordinary'://客户-新建-普通用户
                createNormal_Leads();
                break;
            case 'public_notallocated'://客户-新建-公海未分配
                createpublic_notallocated();
                break;
            case 'public_allocated'://客户-新建-公海已分配
                createpublic_Allocated();

                break;
            case 'averageDistribution'://客户-分配-平均分配
                averageDistribution(obj, module, 'averageDistribution');
                break;

            case 'accountset'://客户参数设置
                cls_PublicLeads.set_leads_public();
                break;
            default:
                is_bool = 0;
        }
        if (1 == is_bool) return false;
    }
    //判断按钮类型调用不同的方法
    switch (setype) {
        case 'RoleProfile':
            setProfile(obj, 0);
            break;
        case 'ProjectXbxImport':
            window.location.href = "index.php?module=Project&action=XBXImportXls&step=1&return_module=Project&xlsStep=First&return_action=index&parenttab=Sales";
            break;
        case 'GroupSetUser':
            Op_UserGroup.setGroupUser();
            break;
        case 'leadsnoallocateconvertnormal'://销售线索转公海
            PublicLeadsObj.mass_transfer();
            break;
        case 'leadsaccountset':
            getJsScript('include/js/cls_publicpool_set.js', function () {
                var publicpool_setobj = new cls_publicpool_set(module);
                publicpool_setobj.CreatePopup();
                publicpool_setobj.refresh_after_save = 'yes';
            });
            //PublicLeadsObj.set_account_public();
            break;
        case 'leadsaverageDistribution':
            getJsScript('include/js/modules/Leads/Leads.js', function () {
                var PublicLeadsObj = new cls_PublicLeads();
                PublicLeadsObj.averageDistribution(obj, module, 'averageDistribution');
            });
            break;
        case 'leadsmassget':
            PublicLeadsObj.massAllocate(3);
            break;
		case 'tongbu':	//runze
            get_ButtonSalePrice();
            break;
        case 'leadsmassrelease':
            PublicLeadsObj.massrelease();
            break;
        case 'massrelease':
            if(module=='CollectionSlip'){//wym 240312 释放收款认领单 XUQIU20240218-01 新增预制表单：收款认领单
                release_collectionslip();
            }
            break;
        case 'leadsaveragehigndistribution':
            PublicLeadsObj.massDeskHighAvgAllocatetaccount(obj);
            break;
        case 'leadsmassallocate':
        case 'leadshigndistribution':
            PublicLeadsObj.massDeskAllocatetaccount(3);
            break;
        case 'DataScope':
            //设置当前字段所在为黄色
            user_pagetype = "list";
            var selectids = ld("#allselectedboxes").val();
            if (selectids == "") {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
                return false;
            }
            ShowSetUeryScop(selectids);
            break;
        case 'allowedituserfield'://设置允许成员自行编辑的字段
            setAllowEdituserfield.getInstance().setPopuplayer();
            break;
        case 'ModuleDetailCreate':
        case "moduledetailCreate":
            //用户新增
            var url = 'module=' + module + '&action=EditView&return_action=DetailView&Create=true';
            //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
            url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
            redirect(url);
            break;
        case 'CreateDebuction':
        case 'CreateCashBill':
        case 'basicBudget':
        case 'salesGoalBudget':
        case 'salesAchievementBudget':
        case 'textArticles':
        case 'imageArticles':
        case 'linkArticles':
        case 'PDFArticles':
        case 'Create'://创建
            var popupobj = CrmPopup.getPopupObj("last");
            obj.disabled = true;
            var objparams = new CreatePagePopup.params();
            objparams.params['isduplicate'] = 'no';
            if (popupobj != undefined && popupobj.type == "listpage") {
                objparams.params['refreshpage'] = 'no';
                objparams.params['button'] = obj;
            }
            objparams.params['createdtype'] = 'create';
            if(setype=='CreateDebuction'){
                //创建预收单
                objparams.params['cashbilltype'] = 'debuction';
                CreatePagePopup.showpage(module, "&cashbilltype=debuction", objparams);
            }
            else if(setype=='CreateCashBill'){
                objparams.params['cashbilltype'] = 'cashbill';
                CreatePagePopup.showpage(module, "&cashbilltype=cashbill", objparams);
            }
            else{
				if(module == 'Accounts'){
					var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();
					//0017486: 客户-列表界面：当序时簿“新建”功能下拉按钮选项设为“公海未分配”、“公海已分配”时，客户列表界面“新建”按钮应该控制不允许点击
					var lasturl = "&pool_id="+pool_id;
					if(ld("#"+popupobj.divid+" [name=buttontype]").val() != undefined){
						var acc_popupobj = CrmPopup.getPopupObj("last");
						var publicaccounttype = ld("#"+acc_popupobj.divid+" [name=publicaccounttype]").val();
						//chj 2021/1/18 44321: （http://xiaoshou360.com/xs/yinbo [^]）客户问题（李鑫华），公海参数配置中“*公海成员客户序时簿“新建”功能下拉选项”仅设置“公海未分配”保存后，全部页签中默认新建的是“公海未分配”客户（需要补丁）
						//if(publicaccounttype != 'ALLACCOUNT' && publicaccounttype != 'DEFAULTALLACCOUNT' && publicaccounttype != 'COMMONACCOUNT'){
                        if(publicaccounttype == 'PUBLICALLOCATE' || publicaccounttype == 'NOALLOCATE'){
							if(ld("#"+popupobj.divid+" [name=buttontype]").val() == 'NOALLOCATE'){
								lasturl += '&publicaccount=1';
							}
                            else if(ld("#"+popupobj.divid+" [name=buttontype]").val() == 'PUBLICALLOCATE'){
								lasturl += '&publicaccount=2';
							}
						}
                        else{
							lasturl += '&publicaccount=0';
						}
					}
                    CreatePagePopup.showpage(module, lasturl , objparams);
				}
				else if(module == 'ExpenseBudget'){
                    if(setype=='Create'){
                        setype = 'basicBudget';
                    }
                    //创建预算单
                    objparams.params['budgetType'] = setype;
                    CreatePagePopup.showpage(module, "&budgetType="+setype, objparams);
                }
                else if(module == 'Articles'){
                    if(setype=='Create'){
                        setype = 'textArticles';
                    }
                    //创建预算单
                    objparams.params['articlesType'] = setype;
                    CreatePagePopup.showpage(module, "&articlesType="+setype, objparams);
                }
				else{
					CreatePagePopup.showpage(module, "", objparams);
				}
			}
            break;
        case "reCalculationBudget":
            //列表页的重算预算金额 费用预算单
            ExpenseBudgetObj.reCalculationBudget();
            break;
        case 'rate_recalculate'://派息单利息重算
            fun_Dividend.getInstance().Recalculate('list', 0);
            break;
        case 'Search'://搜索
            basicsearchPopup();
            break;
        /*editor:gyq_07 reason:批量分配共用修改创建人方法 date : 2016 3 14*/
        case 'Allocate'://分配
        case 'distribution'://公海分配
            ChangeCreator(obj, module, 'Allocate', 'list','');
            break;
        case 'Share'://共享
            //Eidtor:gyq_66 Reason:序时簿共享优化 Date:2018/5/7 0007 下午 5:56
            getJsScript('include/js/Share.js', function () {
                Share.getInstance().getPopup(module, '')
            });
            //SetModuleShares(module,'');
            break;
		case 'ModuleTreeSettings'://树结构设置
            getJsScript('include/js/cls_ModuleTree.js', function () {
                var moduletree = new cls_ModuleTree(module);
				moduletree.show();
            });
            break;
        case 's_dividend':
            massDividend(obj, 'mass', '', 0);//批量派息
            break;
        case 'averageDistribution'://分配-平均分配
            averageDistribution(obj, module, 'averageDistribution');
            break;
        case 'seniorAllocate':// 高级分配，可选是否同时分配相关信息
        case 'seniorAverageAllocate':// 分配-平均分配，可选是否同时分配相关信息
        case 'seniorShare':// 高级共享，可选是否同时共享相关信息
            getJsScript('include/js/SeniorAllocateShare.js', function () {
                var seniorAllocateShare = new SeniorAllocateShare(module, setype);
                seniorAllocateShare.getPopup();
            });
            break;
        case 'Delete'://删除
            massDelete(module);
            break;
        case 'submitapprove'://批量提交
            approve_batchsubmit(module);
            break;
        case 'batchapprove'://批量审批
            getJsScript('include/js/modules/Approve/Approve.js', function () {
                approve_batchapproved(obj);
            });
            break;
        case 'resubmitapprove'://重新提交  审批中心的已驳回和我提交的使用批量提交逻辑。
            // approve_resubmitapproved(obj);
            approve_batchsubmit(module);
            break;
        //Eidtor:gyq_65 Reason:客户、服务收费、联系人合并功能 Date:2018/3/22 0022 下午 3:17
        case 'RecordMerge':
            getJsScript('include/js/Merge.js', function () {
                var mergeobj = new List_Merge(module);
                mergeobj.getPopup(obj);
            });
            break;
        case 'BatchBackFilling'://更多-批量回填
            getJsScript('include/js/tianyancha.js', function () {
                tianyancha_batchbackfill(module);
            });
            break;
        case 'mass_edit'://更多-批量编辑
            getJsScript('include/js/massedit.js', function () {
                getJsScript('include/js/modules/Products/multifile.js', function () {
                    mass_edit(obj, 'massedit', module, '', '1');
                });
            });
            break;
        case 's_mail'://群发邮件
            show_SMS('Email', module);
            break;
        case 's_sms'://群发短信
            show_SMS('SMS', module);
            break;
        case 's_sms_voice'://群发语音短信
            show_SMS('SMS_VOICE', module);
            break;
		 case 'list_viewtotal'://点击查看全部合计
            listviewTotal(module);
            break;
        case 'Import'://导入
            listviewImport(obj, module);
            break;
        case 'ImportImage'://导入图片 产品
            getJsScript('include/js/cls_importImage.js', function () {
                var importImageobj = new cls_importImage(module);
                importImageobj.showPopup();
            });
            break;
        case 'Export'://导出
			obj.account = '';
            listviewExport(obj, module);
            break;
		case 'Export_haochen':	//浩辰特殊开发
			haochen_listviewExport(obj, module);
            break;
        case 'Findduplicates'://查重
            getJsScript('include/js/search.js', function () {
                getJsScript('include/js/Merge.js', function () {
                    showmergeDup(obj, module);
                });
            });
            break;
		case 'Recalculation_latandlong'://重算经纬度
			getJsScript('include/js/modules/Accounts/Reset_latandlong.js',function(){
        		var cls_reset_latandlong = new Reset_latandlong(module);
                cls_reset_latandlong.view();
        	});
            break;
        case 'Settings'://页面设置
            url = 'module=Settings&action=LayoutBlockList&parenttab=Settings&formodule=' + module;
            redirect(url, 1);
            break;
        case 'Advance'://销售机会-推进
            Advance(obj, module);
            break;
        case 'sms_settings'://短信设置
            sendDividendOrderSms(module);
            break;
        /*gyq*/
        case 'ChangeCreator'://变更创建人
            ChangeCreator(obj, module, 'ChangeCreator', 'list','');
            break;
        case 'mark'://提醒-设为已读
            markSign(module, 1);
            break;
        case 'unmark'://提醒-设为未读
            markSign(module, 0);
            break;
        case 'SMS1'://合同订单-短信1
            SMSSendSalesOrderGroup(obj, 1);
            break;
        case 'SMS2'://合同订单-短信2
            SMSSendSalesOrderGroup(obj, 2);
            break;
        case 'SMS3'://合同订单-短信3
            SMSSendSalesOrderGroup(obj, 3);
            break;
        case 'Updatestate'://更改审批状态
            //updateStateApprove(obj,module);
            updateState(obj, module);
            break;
		case 'specialfield_edit'://更改模块字段值
			getJsScript('include/js/SpecialField_Edit.js', function () {
                SpecialField_Edit(obj,module);
            });
            break;
        case 'movegroup'://服务收费-移动分组
            setServiceChargeGroup(module, 'Move');
            break;
        case 'mass_checks'://批量审核
            mass_checks(module);
            break;
        case 'howTosendpayment'://付款计划-如何创建付款计划
            HowToReturn(obj, 'howTosendpayment');
            break;
        case 'massSendCashBill'://付款计划-批量付款
            getJsScript('include/js/massedit.js', function () {
                mass_edit(obj, 'massSendCashBill', module, '', 'massSendCashBill');
            });
            break;
        case 'howTopayment'://回款计划-如何创建回款计划
            HowToReturn(obj, 'howTopayment');
            break;
        case 'howToservicereturn'://服务回访单-如何创建服务回访单
            HowToReturn(obj, 'howToservicereturn');
            break;
        case 'howToquoteschange'://报价变更单-如何创建报价变更单
            HowToReturn(obj, 'howToquoteschange');
            break;
        case 'howTobudgetchange'://预算变更单-如何创建预算变更单
            HowToReturn(obj, 'howTobudgetchange');
            break;
        case 'HowToMainTran'://如何维护部门和用户
            HowToReturn(obj, 'howtomaintain');
            break;
        case 'howTodevidend'://派息单-如何创建派息单
            HowToReturn(obj, 'howTodevidend');
            break;
        case 'howToCashBack'://销售退款单-如何退款
            HowToReturn(obj, 'howToCashBack');
            break;
        case 'howToPurchaseCashBack'://采购退款单-如何退款
            HowToReturn(obj, 'howToPurchaseCashBack');
            break;
        case 'fund_accured'://管理/业绩费计提(基金)
            getJsScript('include/trade/Jijin/Accured.js', function () {
                Fund_Accured.getInstance(module, obj).Pop();
            });
            break;
        case 'massCashBill'://回款计划-批量收款
            getJsScript('include/js/massedit.js', function () {
                mass_edit(obj, 'massCashBill', module, '', 'massCashBill');
            });
            break;
        case 'howToPurchaseReturn'://采购退货单-如何退货
            HowToReturn(obj, 'howToPurchaseReturn');
            break;
        case 'salesbackhowtogoods'://销售退货单-如何退货
            HowToReturn(obj, 'howToReturn');
            break;
        case 'deleteall'://提醒:删除所有
            deleteAll('Reminds');
            break;
        /* editor:gyq_09 reason: 新增批量派息规则设置 date:2016 4 1  */
        case 'dividend_rules'://提醒:删除所有
            getJsScript('include/js/modules/Products/ProductsDividendRules.js', function () {
                Products_dividendRules.getInstance().Buttons_dividendRules(obj, module);
            });
            break;
        case 'MergeCreate'://合并创建
            if (module == 'Quotes') {
                MergeCreate('SalesOrder');
            }
            break;
        case 'bw_helpdesk':
            bw_sync('listbtn');
            break;
        case 'INACTIVATING'://银行账户禁用
            Inactivating();
            break;
        case 'ResetListWidth':
            ResetListWidth(module);
            break;
        case 'Settlement':
            Settlement();
            break;
        case 'price_strategy':
            //editor:gyq_84 reason:产品增加价格策略 2018/10/22 15:20
            getJsScript('include/js/modules/Products/price_strategy.js', function () {
                price_strategy.getInstance().get_setting_windows(obj, module, '');
            });
            break;
        case 'evaluate':
            //editor:gyq_127 reason:服务小程序增加评价  2019/6/24 16:25
            getJsScript('include/js/modules/HelpDesk/evaluate.js', function () {
                evaluate.getInstance().get_setting_windows(obj, module);
            });
            break;
            // 附件批量下载
        case 'DownloadSelected':
            DownLoadAllAttachment(module,setype);
            break;
        //朗捷特殊功能 报关订单Excel格式的报关单草单导出
        case 'ExportCustomsOrder':
        case 'ExportCheckTemplate':
            List_CheckBox_Ids.getIds(module);
            var selectidstring = List_CheckBox_Ids.ids;
            ExportCustomsOrder(module,selectidstring,setype);
            break;
        case 'ExportCustomsOrderEmail':
            List_CheckBox_Ids.getIds(module);
            var selectidstring = List_CheckBox_Ids.ids;
            exportCustomsOrderEmail(module,selectidstring,setype);
            break;
        case 'LangJieLocalAssign'://郎捷配送任务单
            LangJieLocalAssign();
            break;
        case 'UserLoginControl'://用户界面“登录控制""
            var userobj=cls_Users.getInstance();
            userobj.setLoginControlPopup();
            break;
        case 'UnlockUserAccount'://用户界面'解锁账号';
            var userobj=cls_Users.getInstance();
            userobj.UnLockAccountPopup();
            break;
        case 'leadspulicset':
            PublicLeadsObj.set_account_public();
            break;
        case 'discontinued':
            discontinued();
            break;
        case 'Batchonshelves':
            Batchoperateshelves(module,'Batchon');
            break;
        case 'Batchoffshelves':
            Batchoperateshelves(module,'Batchoff');
            break;
        case 'Shopsettings':
            url = 'index.php?pageto_module=ShopSettings&pageto_action=index&pageto_menufile=InterfaceSettings&menufile=InterfaceSettings';
            window.open(url);
            break;
        //中孚 商机和合同加上收入计划确认金额和时间统计
        case'Revenueplan':
            getJsScript('include/js/Revenueplan.js', function () {
                Revenueplan(module);
            });
            break;
        case 'Datadupcheck'://数据查重
            look_check_repeat.pagetype = 'listview';
            look_check_repeat(obj, module);
            break;
        case 'ContinuousDialing':  //连续拨号  灵当录音盒
            if (YiweiTools.getInstance().isconnect === false) {
                audioRemindsMsg("","","","","","请检查设备是否连接成功");
                return false;
            }
            getJsScript('include/js/modules/Users/AutoDial.js', function () {
                var cls_AutoDial = new AutoDial(module);
                cls_AutoDial.InitAutoDial();
            });
            break;
        case 'Approvalsettings':
            url = 'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&menufile=MultiApproveList&pageto_menufile=MultiApproveList&formodule='+module;
            window.open(url);
            break;
        case 'ElectronicSignature': //电子签章  访问后台，创建连接
            CreateConsoleLoginUrl(module);
            break;
        case 'Businessquerysettings':
            url = 'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&menufile=BusinessInformation&pageto_menufile=BusinessInformation';
            window.open(url);
            break;
        case 'addtocart':
            getJsScript('include/js/modules/Products/shopcart.js',function(){
                mass_addtocart();
            });
            break;
        case 'opencart':
            getJsScript('include/js/modules/Products/shopcart.js',function(){
                opencart();
            });
            break;
        case 'receive':
            if(module=='WorkSheet') {
                receive_worksheet();//领取工单
            }
            else if (module=='CollectionSlip') {
                receive_collectionslip();//领取收款认领单
            }
            break;
        case 'AddressbookSync'://ls 2021-12-15 【1002160】企业微信通讯录及部门同步
            cls_Users.getInstance().AddressbookSync();
            break;
        case 'OffiaccountUser'://zxm 20220722 同步微信公众号用户
            cls_Users.getInstance().OffiaccountUser();
            break;
        case 'sign_recalculate':
            sign_recalculate_list();
            break;
        case 'BaxterImport'://百特导入
            listviewBaxterImport.getInstance().baxterImport();
            break;
        case 'Update_addresss'://咨询认证行业crm重算地址
            getJsScript('include/js/ListViewMap.js',function(){
                var listViewMap = new ListViewMap();
                ListViewMap.getInstance().updateAddress(obj, module);
            });
            break;
        case 'CF54massget'://中司证书模块领取
            getJsScript('include/js/modules/CustomForm54/CustomForm54.js',function(){
                var customform54 = new CustomForm54();
                customform54.receiveCertificate(obj, module, 'Receive', 'list','');
            });
            break;
        case 'ExportDevicecode':// 设备模块导出设备码
            getJsScript('include/js/modules/Equipment/Equipment.js',function(){
                var equipmentObj = new cls_Equipment(module);
                equipmentObj.exportDevicecode('listview');
            });
            break;
    }
}

/**
 * 重置模块列表宽度设置
 * @param    2017-03-13
 * @returns module:当前模块
 * @author Chj
 */
function ResetListWidth(module) {
    if (document.getElementById('viewname') != undefined && !empty(module)) {
        var viewname = document.getElementById('viewname').value;
        if (!empty(viewname)) {
            var ustring = 'module=Users&action=UsersAjax&file=ResetListWidth&viewname=' + viewname;
            RequestAjax(ustring + '&frommodule=' + module, function (rest) {
                if (empty(rest)){
					DelProgressObjs();
					return false;
				}
                if (rest.indexOf('success')>=0 ) {
                    // RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", arrJsPopLabel['ResetSuccess']);
                    MessagePopup.TipOne_success(arrJsPopLabel['ResetSuccess']);
                    var popupobj = CrmPopup.getPopupObj("last");
                    ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind().bind("click", function () {
                        if (document.forms['massdelete'].pagenum != undefined) {
                            gstart = "&start=" + document.forms['massdelete'].pagenum.value;
                        } else {
                            gstart = "&start=" + document.forms['massdelete'].pagenum[0].value;
                        }
                        getListViewEntries_js(module, gstart);//刷新页面
                    });
                    ld("#" + popupobj.divid + " .ld-fonticon-close").unbind().bind("click", function () { //BUG0069603 xxy 2023-7-18 序时簿列表，点击“恢复预设列宽”，弹出窗口点击“x”，没有恢复预设列宽
                        if (document.forms['massdelete'].pagenum != undefined) { //不绑点击事件会导致重置后不刷新页面就无法再次拖动列宽，所以再绑一个点击事件
                            gstart = "&start=" + document.forms['massdelete'].pagenum.value;
                        } else {
                            gstart = "&start=" + document.forms['massdelete'].pagenum[0].value;
                        }
                        getListViewEntries_js(module, gstart);//刷新页面
                    });
					DelProgressObjs();
                } else {
                    RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", arrJsPopLabel['ResetFailed']);
					DelProgressObjs();
                }
                return false;
            });
        }
    }
    //审批中心
    if (module == 'Approve') {
        var fromapprovemodule = document.getElementById('fromapprovemodule').value;
        var approvestatus = document.getElementById('approvestatus').value;
        if (!empty(fromapprovemodule) && !empty(approvestatus)) {
            var ustring = 'module=Users&action=UsersAjax&file=ResetListWidth&approvestatus=' + approvestatus + '&fromapprovemodule=' + fromapprovemodule;
            RequestAjax(ustring + '&frommodule=' + module, function (rest) {
                if (empty(rest)) return false;
                if (rest.indexOf('success')>=0) {
                    // RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['ResetSuccess']);
                    MessagePopup.TipOne_success(arrJsPopLabel['ResetSuccess']);
                    var popupobj = CrmPopup.getPopupObj("last");
                    ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind().bind("click", function () {
                        if (document.forms['massdelete'].pagenum != undefined) {
                            gstart = "&start=" + document.forms['massdelete'].pagenum.value;
                        } else {
                            gstart = "&start=" + document.forms['massdelete'].pagenum[0].value;
                        }
                        getListViewEntries_js(module, gstart);//刷新页面
                    });
					DelProgressObjs();
                } else {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['ResetFailed']);
					DelProgressObjs();
                }
                return false;
            });
        }
    }
}

function massDelete(module) {
    var searchurl = $('search_url').value;
    var viewid = getviewId();
    var idstring = "";
    List_CheckBox_Ids.getIds(module);
    var select_options = List_CheckBox_Ids.ids;
    idstring = select_options;
    count = List_CheckBox_Ids.num_rows;
    var excludedRecords = $('excludedRecords').value;
    var numOfRows = List_CheckBox_Ids.num_rows;

    if (count <= 0) {
        MessagePopup.TipOne_warning();
        return false;
    }


    var confirm_status = true;

    var url = "&excludedRecords=" + excludedRecords;
    var alert_str = arrJsPopLabel['SUREWANTDELETETHEDELECTED'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDIT'];
    if (module == "CashBill" || module == "SendCashBill" || module == "Attachment" || module == 'OutboundOrder' || module == 'Stock') {
        alert_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETION'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDIT'];
    } else if (module == "Accounts") {
        alert_str = arrJsPopLabel['REMOVEWILLDELETEOTHER'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDIT'];
    } else if (module == "Vendors") {
        alert_str = arrJsPopLabel['DELETESUPPLIERSWILLDELETEPURCHASEORDERS'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDIT'];
    }
    if (parseInt(count) > parseInt(getMaxMassOperationLimit())) {
        alert_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count), getMaxMassOperationLimit(), '');
    }

    var searchScope = "";
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    else if (module == "Reminds")
        searchScope = "SmOwner_Search_All";

    RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", alert_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
        //wym 231226 BUG0077819 批量删除，转圈的加载效果去掉
       //ld('#rptContentLoading').show();
        if (module == 'Reminds') {
            vn = getObj('viewname').value;
            url += '&viewname=' + vn;
        }
        var customtype = "";
        if (document.massdelete.publicaccounttype != undefined) {
            customtype = document.massdelete.publicaccounttype.value;
        }
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   url += '&isshowModuleListTree=yes';
    	}

        var ajax = '';
        ajax = "&ajax=true";
    // @edit:liushuai,2021-03-08,reason:【ID1001390】批量删除增加显示进度条
        var intervalrow = 8;
        if (numOfRows > 100){
            intervalrow = Math.ceil(numOfRows / 10); //向上取整
        }
        //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
        if(intervalrow >20){
            intervalrow = 20;
        }
        startMassDelete(module, viewid, idstring, searchurl, url, searchScope, customtype, ajax, numOfRows, 0, intervalrow);

    });
}






function startMassDelete(module, viewid, idstring, searchurl, url, searchScope, customtype, ajax, numOfRows, startrow, intervalrow) {
    var endrow = startrow+intervalrow;
    if (endrow > numOfRows){
        endrow = numOfRows;
    }
    var surl = "&startrow="+startrow+"&endrow="+endrow;
    var urlstring = "module=Users&action=massdelete&return_module=" + module + "&viewname=" + viewid + "&idlist=" + idstring + searchurl + url + "&SearchScope=" + searchScope + "&accounttype=" + customtype + ajax + "&mass_del_totalrows=" + numOfRows + surl;
    //wym 231226 BUG0077819 批量删除，转圈的加载效果去掉
    ldAjaxHtmlNoProgress('index.php?',urlstring,function (data) {
        DelProgressObjs();
        var restobj = eval('(' + data+ ')') ? eval('(' + data + ')') : JSON.parse(data);

        //批量删除进度条
        var tmppopupobjobj;
        if(startrow==0)
        {
            tmppopupobjobj=ProgressPopup.load(restobj.title.value,"","",500,'Users',"","","","");
            tmppopupobjobj.show();
        }
        else{
            tmppopupobjobj=CrmPopup.getPopupObj('last');
        }
        var maxrows=parseInt(restobj.maxrows);
        var percent=parseInt(((startrow+intervalrow)/maxrows*100));

        tmppopupobjobj.setPercentWidth(percent);
        tmppopupobjobj.setTotalNum(restobj.selectrows);
        tmppopupobjobj.setCurNum(startrow);
        if(maxrows!=restobj.selectrows)
        {
            tmppopupobjobj.setValidataNum(maxrows);
        }
        if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
        {
            startMassDelete(module, viewid, idstring, searchurl, url, searchScope, customtype, ajax, numOfRows, startrow + intervalrow, intervalrow);
            return false;
        }
        else{
            tmppopupobjobj.CancelEvent();
        }


        //如果是提醒模块，更新提醒数量

        if (module == 'Reminds' && restobj.reminds_num != undefined && !empty(restobj.reminds_num.value)) {
            /*var remdmindscount = document.getElementById("headerremindscount").innerHTML;
            remdmindscount = remdmindscount.replace(/[^0-9]/ig, "");

            remdmindscount = parseInt(remdmindscount) - parseInt(restobj.reminds_num.value);
            if (remdmindscount <= 0) {
                remdmindscount = '';
                if (ld('#reminds_popup_expansion .remind-notread-count') != undefined) {
                    ld('#reminds_popup_expansion .remind-notread-count').hide();
                }
            } else {
                if (ld('#reminds_popup_expansion .remind-notread-count') != undefined) {
                    ld('#reminds_popup_expansion .remind-notread-count').html(remdmindscount);
                }
                remdmindscount = '(' + remdmindscount + ')';
            }
            if (remdmindscount != '(NaN)') {
                document.getElementById("headerremindscount").innerHTML = remdmindscount;
            }*/
            //edit:can 2020-10-30 43064: （https://61mis.com/kfbtest [^]）消息中心->未读页签：删除消息单据后，界面没有立即更新，单据仍显示在界面，右上角的消息条数也没有更新（需要补丁）
            getRemindsCount();
        }
        resultRemindsMsg(restobj.title.value, "LdPopWidth600px", "", "yes", "", restobj.log.value);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            fninvshnew('mass_delete');
            puyoungJS_DialogBox.unblock();
            if ($('basicsearchcolumns') != undefined)
                $('basicsearchcolumns').innerHTML = '';
            if ($('allselectedboxes') != undefined)
                $('allselectedboxes').value = '';
            if ($('excludedRecords') != undefined)
                $('excludedRecords').value = '';
            ActivityReminderCallback();
            //UpdateProjectInfo(idstring);//项目计划删除时，反写项目中已完成项目计划字段。
            getListViewEntries_js(module, restobj.start.value);//刷新页面
        });
        return false;
    })

}

/**
 * 批量提交，显示选择审批流程界面
 * @param String module 模块名
 * @returns 将选中的数据批量提交
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-25
 */
var approve_subbtn_val = '';

function approve_batchsubmit(module) {
    var returnmodules = module;
    if (module == 'ServiceCharge') {
        //19646: 服务收费管理>列表：勾选单据，提交审批，弹出提示信息。点击提示信息的链接字段，结果：页面跳转到的是客户模块。
        //module='Accounts';
        returnmodules = 'ServiceCharge';
    }
    //approvemodule 审批模块
    var approvemodule = module;
    if (module == 'Approve') {
        if (ld('#fromapprovemodule') != undefined) {
            approvemodule = ld('#fromapprovemodule').val();
        }
    }
    var popupobj=CrmPopup.getPopupObj('last');
    
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();// document.getElementById('allselectedboxes').value;
 
    var selectlen = 0;
    if (selectid != 'all') {//非全选状态，依次获取选中的单据ID

        var selectobj = document.getElementsByName("selected_id");
        var selectobjlen = selectobj.length;
        selectid = '';
        for (var i = 0; i < selectobjlen; i++) {
            if (selectobj[i].checked) {//获取选中的ID
                selectid += selectobj[i].value + ',';
                selectlen++;
            }
        }
        if (selectid == '') {//请至少选择一条记录
            MessagePopup.TipOne_warning();
            return false;
        }
        //}
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    
    //if(selectlen > 500)//超过500条，提示客户
    //if(!confirm(arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'])) return false;
    var urlstring = 'index.php?module=Approve&action=ApproveAjax&file=SubmitApprove&save=false&fld_module=' + approvemodule + '&selectid=' + selectid + "&selectlen="+selectlen;
    //超过500条，给出提示
    if (selectlen > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
        //创建提示弹出层
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);

        //确定事件
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            fninvshnew('approveSubmit_reminder');
            approveSubmit(module, returnmodules, urlstring, selectid, selectlen);
        });
    } else {
      
        approveSubmit(module, returnmodules, urlstring, selectid, selectlen);
    }
}
function save_submitapprove(){
	var popupobj=CrmPopup.getPopupObj("last");
	var approvevalue = ld("#"+popupobj.divid+" [name=approvevalue]").val();
	var nextstepapprover = ld("#"+popupobj.divid+" [name=userid_0]").val();
   
	var module = ld("#"+popupobj.divid+" [name=fld_module]").val();
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    if(prevpopupobj!=undefined&&prevpopupobj.type==Listpagepopupobj.type)
    {
        //列表界面的批量提交
        record=popupobj.selectid;
    }
    else
    	var record = ld("#"+popupobj.divid+" [name=idstring]").val();
        
    var submitapprove_text = ld("#"+popupobj.divid+" [id=submit_description]").val();//提交意见是否为空
    var submitlabel = ld("#"+popupobj.divid+" [name=submitremarkrequire]");//提交意见是否必填
    if(ld.trim(submitapprove_text)=="" && ld(submitlabel).css("display")=="inline")
    {
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
        return false;
    }
	var selectlen = ld("#"+popupobj.divid+" [name=selectlen]").val();
    //duan 2022-3-31 判断当前审批步骤是否允许审批人为为空
    var allow_emptyapprover = ld("#"+popupobj.divid+" [name=allow_emptyapprover_0]").val();
	if (empty(nextstepapprover)&&allow_emptyapprover!='yes') {
		issubmit = 1;
		RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NONEXTAPPROVER']);
		return false;
	}
    ld("#"+popupobj.divid+' [name=action]').val('ApproveAjax');

// @edit:liushuai,2021-03-03,reason:【ID1001390】批量提交审批增加显示进度条
    var formdata=ld("#"+popupobj.divid+' [name=frmsubmitapprove]').serialize();
    var intervalrow = 8; //默认 8 数据量太大  请求次数过多  会导致执行起来过久
    if (selectlen > 100){
        intervalrow = Math.ceil(selectlen / 10); //向上取整
    }
    //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
    if(intervalrow >20){
        intervalrow = 20;
    }
    start_save_submitapprove(popupobj, module, approvevalue, record, selectlen, nextstepapprover, formdata, 0, intervalrow);

}
// @edit:liushuai,2021-03-03,reason:【ID1001390】批量提交审批增加显示进度条
function start_save_submitapprove(popupobj, module, approvevalue, record, selectlen, nextstepapprover, formdata, startrow, intervalrow){
    // var popupobj=CrmPopup.getPopupObj("last");

    var endrow = startrow+intervalrow;
    if (endrow > selectlen){  //最后一个请求
        endrow = selectlen;
    }
    var urlstring = 'index.php?file=SubmitApprove';
    urlstring += '&fld_module=' + module + '&approvevalue=' + approvevalue;
    urlstring += '&selectid=' + record + '&batchsubmit=1&save=true&selectlen=' + selectlen;
    urlstring+='&stepapproveuserid='+nextstepapprover;

    urlstring+="&startrow="+startrow+"&endrow="+endrow;
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   urlstring += '&isshowModuleListTree=yes';
	}

    if (module == 'Approve') {
        if (ld('#fromapprovemodule') != undefined) {
            urlstring += '&fromapprovemodule=' + ld('#fromapprovemodule').val();
        }
        if (ld('#approvestatus') != undefined) {
            urlstring += '&approvestatus=' + ld('#approvestatus').val();
        }
    }
	//48413: （https://xx.dongmaoguoji.cn/crm [^] ）（东贸）进入大巴车档案全选所有档案，点击更多批量审批。会把其他客户/渠道档案的数据提交上去。显示10000多条
	if(pageto_action != undefined && pageto_action == 'LinkModuleCustom'){
		var prevpopupobj=CrmPopup.getPopupObj('lastprev');
		urlstring += '&cvid='+ld("#"+prevpopupobj.divid+" [name=selectcustomview_"+module+"]").val();
	}

    ldAjax(urlstring,formdata,function(data){
        if(data.code == 1){
            ld('#rptContentLoading').hide();

            var tmppopupobjobj;
            if (startrow == 0) {
                tmppopupobjobj = ProgressPopup.load(data.result.title, "", "", 500, module, "", "", "", "");
                tmppopupobjobj.show();
            } else {
                tmppopupobjobj = CrmPopup.getPopupObj('last');
            }
            var maxrows = parseInt(data.result.maxrows);
            var percent = parseInt(((startrow + intervalrow) / maxrows * 100));

            tmppopupobjobj.setPercentWidth(percent);
            tmppopupobjobj.setTotalNum(data.result.selectrows);
            tmppopupobjobj.setCurNum(startrow);
            if (maxrows != data.result.selectrows) {
                tmppopupobjobj.setValidataNum(maxrows);
            }
            // console.log(startrow + intervalrow);console.log(data.result.maxrows);
            if (parseInt(startrow + intervalrow) < parseInt(data.result.maxrows)) {
                start_save_submitapprove(popupobj, module, approvevalue, record, selectlen, nextstepapprover, formdata, startrow + intervalrow, intervalrow);
                return false;
            } else {
                tmppopupobjobj.CancelEvent();
            }

            popupobj.CancelEvent();
            var crmPopupobj=CrmPopup.load("","","","600",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,cancel_submitapprove,"","600",module,"",data.result.oktext,"","","");
            crmPopupobj.show(data.result.content);
            crmPopupobj.setScrollDivMaxHeight();
            crmPopupobj.center();
            //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
            ModelDataBindobj.setButtonName='batchsubmit';
            ModelDataBindobj.setpropertyname='approvesavebutton';
        }
        DelProgressObjs();
    })
}

function cancel_submitapprove(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
	var tmparra=new Array();
	var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
	//服务单保存后刷新服务单的历史记录(查看界面)
	var refreshlistmodules = new Array(popupobj.module);
	tmpobj.eachrefreshlistbyModules(refreshlistmodules);
}
//提交审批
function approveSubmit(module, returnmodules, urlstring, selectid, selectlen) {
	ldAjax(urlstring,"",function(data){
		if(data.code == 1){
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
			crmPopupobj.prevshow();
			crmPopupobj.setParams(data.result.title,save_submitapprove,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.selectid=selectid;
            getJsScript('include/js/modules/Approve/Approve.js',function(){});
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            DelProgressObjs();
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
                //通讯录(pc端企业微信要绑定)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
            }
		}
        else{
			if(data.msg == 'NO' || data.msg == 'nopermit'){
				 var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
				RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                DelProgressObjs();
				return false;
			}
		}
        DelProgressObjs();
	})
	return false;
}

function clone(obj) {
    // Handle the 3 simple types, and null or undefined
    if (null == obj || "object" != typeof obj) return obj;

    // Handle Date
    if (obj instanceof Date) {
        var copy = new Date();
        copy.setTime(obj.getTime());
        return copy;
    }

    // Handle Array
    if (obj instanceof Array) {
        var copy = [];
        var len = obj.length;
        for (var i = 0; i < len; ++i) {
            copy[i] = clone(obj[i]);
        }
        return copy;
    }

    // Handle Object
    if (obj instanceof Object) {
        var copy = {};
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
        }
        return copy;
    }
}

/**
 * 更改审批状态
 * @project PROT195 审批管理改进
 * @author Tujt 2015-04-09
 */
function updateStateApprove(obj, module) {
    //获取所需要推进的单据ID
    var select_id = '';
    var savefilter = '';
    var selectlen = 0;
    if (ld('input[name=selected_id]').length > 0) {//列表
        select_id = document.getElementById('allselectedboxes').value;
        if ('all' == select_id) {
            //获取全选数量
            selectlen = document.getElementById('numOfRows').value;
            if (selectlen > 500)//超过500条，提示客户
                if (!confirm(arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'])) return false;
            savefilter += '&selectlen=' + selectlen;
        } else if (0 == ld('input[name=selected_id]:checked').length) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['PLEASESELECTONEENTITY']);
            return false;
        }
    } else {//详情页
        select_id = document.DetailView.record.value;
    }
    savefilter += '&select_id=' + select_id;
    //弹出销售机会推进层
    var divid = 'update_state_approve_show';
    var isinit = 0;
    if (0 == ld('#' + divid).length) {//当层未创建时，创建层
        var divObj = document.createElement("div");
        divObj.setAttribute('id', divid);
        divObj.className = 'D_pop_box LdPopWidth400px';
        divObj.style.position = "absolute";
        divObj.style.zIndex = "10001";
        divObj.style.top = "120px";
        divObj.style.left = "350px";
        divObj.style.display = "none";
        divObj.style.backgroundColor = "#ffffff";
        document.body.appendChild(divObj);
    } else {
        isinit = 1;
    }
    if (1 == isinit) {//已经加载过
        if (empty(ld('#' + divid).html())) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NOPROCESSPLEASESETPROCESS']);
            return false;
        } else {
            ld('#' + divid + ' form[name=frmsubmitapprove]').find('[name=approvevalue]').get(0).selectedIndex = 0;
            fnvshobj(obj, divid);
        }
        return false;
    }
    //获取审批状态
    var urlstring = 'module=Approve&action=ApproveAjax&file=UpdateApprove&save=false&fld_module=' + module;
    RequestAjax(urlstring, function (rest) {
        if (empty(rest) || rest.indexOf('###NO###') > -1) {//没有可用的审批流程
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NOPROCESSPLEASESETPROCESS']);
			DelProgressObjs();
            return false;
        }
        var results = rest.split("###SUCCESS###");
        ld('#' + divid + '').html(results[1]);
        fnvshobj(obj, divid);
        //绑定关闭事件
        ld('#' + divid + ' .D_pop_tit .D_ptitc').on('click', function () {
            ld('#' + divid + ' .D_pbtn .E_pbtncancel').click();
            return false;
        });
        
        ld('#' + divid + ' .D_pbtn .D_pbtncancel').on('click', function () {
            fninvshnew(divid);
        });
        //绑定保存事件
        var savebtn = ld('#' + divid + ' .D_pbtn .D_pbtnok').get(0);
        var issubmit = 1;//防止重复点击
        savebtn.onclick = function () {
            if (1 != issubmit) return false;
            issubmit = 2;
            savefilter = '';
            var mode = '';
            if (ld('input[name=selected_id]').length > 0) {//列表
                select_id = document.getElementById('allselectedboxes').value;
                if ('all' == select_id) {
                    //获取全选数量
                    selectlen = document.getElementById('numOfRows').value;
                    if (selectlen > 500)//超过500条，提示客户
                        if (!confirm(arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'])) return false;
                    savefilter += '&selectlen=' + selectlen;
                } else if (0 == ld('input[name=selected_id]:checked').length) {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['PLEASESELECTONEENTITY']);
                    return false;
                }
                mode = 'list';
            } else {//详情页
                select_id = document.DetailView.record.value;
                mode = 'detail';
            }
            savefilter += '&mode=' + mode;
            savefilter += '&select_id=' + select_id;
            var approvevalue = ld('#' + divid + ' form[name=frmsubmitapprove]').find('[name=approvevalue]').val();
            var urlstring = 'module=Approve&action=ApproveAjax&file=SubmitApprove&save=true';
            urlstring += '&fld_module=' + module + '&approvevalue=' + approvevalue + '&updatestate=1';
            urlstring += savefilter;
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", urlstring);
            RequestAjax(urlstring, function (rest) {//批量提交保存
                issubmit = 1;
                ld('#' + divid + ' .D_pbtn .D_pbtncancel').click();
                if (rest == '') {
					DelProgressObjs();
                    return false;
                }
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if ('list' == mode) {//列表，静态刷新
                    ld('#current_page_boxes').val('');//清空所选单据checkbox
                    ld('#allselectedboxes').val('');//清空选择全部参数
                    getListViewEntries_js(module, 'start=' + restobj.start.value);//刷新页面
					DelProgressObjs();
                } else {//详情页，刷新当前页
					DelProgressObjs();
                    location.reload();
                }
            });
        }
		DelProgressObjs();
    });
}

/**
 * 更改状态
 * @project  更改状态
 * @author andrew 2015-06-26
 */
function updateState(obj, module) {
    //获取所需要更改状态的单据ID
    var select_id = '';
    var savefilter = '';
    var selectlen = 0;
    if (document.getElementById('excludedRecords') != undefined) {
        var excludedRecords = document.getElementById('excludedRecords').value;
    }
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        var searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var viewid = getviewId();
	var popupobj= CrmPopup.getPopupObj("last");
    if (popupobj.type == 'listpage') {//列表
        select_id = document.getElementById('allselectedboxes').value;
        if ('all' == select_id) {
            //获取全选数量
            selectlen = document.getElementById('numOfRows').value;
            if (selectlen > 500)//超过500条，提示客户
                if (!confirm(arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'])) return false;
            savefilter += '&selectlen=' + selectlen;
        } else if (0 == ld('input[name=selected_id]:checked').length) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
    }
    else {//详情页
        select_id = popupobj.record;
    }
    savefilter += '&select_id=' + select_id;
    
    var divid = 'update_state_approve_show';
    var isinit = 0;
    
    if (0 == ld('#' + divid).length) {//当层未创建时，创建层
        //20230426 fengxh  BUG0065252 选择“更改订单状态”弹出层改为可拖动
        var popupobj=CrmPopup.getPopupObj("last");
        var crmpopuObj = CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
        crmpopuObj.prevshow();
    } else {
        isinit = 1;
    }
    //获取审批流程
    var urlstring = 'module=Users&action=UsersAjax&file=changeState&save=false&fld_module=' + module;
    RequestAjax(urlstring, function (rest) {
        var data = JSON.parse(rest);
        if (data.code == -1) {//没有可用的审批流程
            crmpopuObj.CancelEvent();
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['Statelistisempty']);
			DelProgressObjs();
            return false;
        }

        //20230426 fengxh  BUG0065252 选择“更改订单状态”弹出层改为可拖动
        crmpopuObj.setParams(data.result.title,'',"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
        CrmPopup.setPopupobjHtmlContent_scroll(crmpopuObj,data.result.content);//后端传递数据到前端接收
        
        var issubmit = 1;//防止重复点击
        ld('#' + crmpopuObj.divid + ' .E_pbtnok').on('click', function () {
            if (1 != issubmit) return false;
            issubmit = 2;
            savefilter = '';
            var mode = '';
           if (popupobj.type == 'listpage') {//列表
                select_id = document.getElementById('allselectedboxes').value;
                if ('all' == select_id) {
                    //获取全选数量
                    selectlen = document.getElementById('numOfRows').value;
                    if (selectlen > 500)//超过500条，提示客户
                        if (!confirm(arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'])) return false;
                    savefilter += '&selectlen=' + selectlen;
                } else if (0 == ld('input[name=selected_id]:checked').length) {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
                    return false;
                }
                mode = 'list';
            } else {//详情页
                select_id = popupobj.record;
                //zkt 20220105 BUG0060440合同订单查看详情界面，点击相关信息任意模块后，再点击更改合同状态点击确定按钮，界面一直显示加载中
                if(popupobj.type == 'relatelistpage'){
                    select_id = popupobj.detailpage_record;
                }
                mode = 'detail';
            }
            
            savefilter += '&mode=' + mode;
            savefilter += '&select_id=' + select_id;
            savefilter += "&viewname=" + viewid + "&SearchScope=" + searchScope + '&excludedRecords=' + excludedRecords;
            var statusname = ld('#' + crmpopuObj.divid + ' form[name=changestatus]').find('[name=statusname]').val();
            var urlstring = 'module=Users&action=UsersAjax&file=changeState&save=true';
            urlstring += '&fld_module=' + module + '&statusname=' + statusname;
            urlstring += savefilter;
            RequestAjax(urlstring, function (rest) {//批量更改状态保存
                issubmit = 1;
                crmpopuObj.CancelEvent();
                if (rest == '') {
					DelProgressObjs();
                    return false;
                }
                
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                getJsScript('include/js/ldcrm.base.js', function () {
                    var popupobj=CrmPopup.getPopupObj('last');
                    if ('listpage' == popupobj.type){
                        resultRemindsMsg(restobj.title.value, "LdPopWidth600px", module, "yes", "", restobj.log.value);
                        var remindcrmpopuObj = CrmPopup.getPopupObj('last');
                        ld('#' + remindcrmpopuObj.divid + ' .E_pbtnok').on('click', function (){
                            // remindcrmpopuObj.CancelEvent();
                            puyoungJS_DialogBox.unblock();
                            var tmparra=new Array();
                            var popupobj=CrmPopup.getPopupObj('last');
                       
                            var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                            var refreshmodules=[];
                            refreshmodules.push(popupobj.module);
                            tmpobj.eachrefreshlistbyModules(refreshmodules);
                        });
                        DelProgressObjs();
                    }
                    else {
                        if(restobj.code==1){
                            var popupobj=CrmPopup.getPopupObj('last');
                            var tmparra=new Array();
                            var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                            var refreshmodules=[];
                            refreshmodules.push(popupobj.module);
                            tmpobj.eachrefreshlistbyModules(refreshmodules);
                            tmpobj.eachrefreshDetailViewByModules(refreshmodules);
                        }
                        else{
                           audioRemindsMsg("","",module,"","",restobj.msg);
            			}
                        DelProgressObjs();
                    }
                    return false;
                });
            });
        });
    });
}
/**
 更新操作
 edit:cdw
 date:20131120
 reason:客户序时簿界面群发短信功能改进
 判断有没有选择客户并且弹出弹出框
 **/
function show_SMS(type, module) {
    var idstring = '';
    var select_options = document.getElementById('allselectedboxes').value;
    if (select_options == 'all') {
        document.getElementById('idlist').value = idstring;
        allids = select_options;
    } else {
        var x = select_options.split(";");
        var count = x.length;
        select_options = select_options.slice(0, (select_options.length - 1));
        if (count > 1) {
            idstring = select_options.replace(/;/g, ',')
            document.getElementById('idlist').value = idstring;
        }
        else {
            MessagePopup.TipOne_warning();
            return false;
        }
        var allids = document.getElementById('idlist').value;
    }
    //消息类型  SMS文字短信   SMS_VOICE语音电话
    if (type == 'SMS'||type == 'SMS_VOICE') {
        ld('#rptContentLoading').show();
        var surl = "module=" + module + "&action="+module+"Ajax&file=sendSMSField&parenttab=Parent Accounts&ReportHeader=dbheader&allids=" + allids;
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   surl += '&isshowModuleListTree=yes';
    	}
        ldAjax('index.php?' + surl,{"SMStype":type},function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();
                var crmPopupobj = CrmPopup.load(data.result.title, chosebox_select_btn, "", "LdPopWidth600px", module, '', data.result.oktext, "", data.result.canceltext);
                crmPopupobj.Okfun.funname = 'chosebox_select_btn';
                crmPopupobj.show(data.result.content);
                DelProgressObjs();
            }
        })
    }
    else {
        if (module == 'ServiceCharge') module = 'Accounts';
        //url="module="+module+"&action=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids;
        //alert(url);
        ld('#rptContentLoading').show();
        var posturl = "module=" + module + "&action="+module+"Ajax&file=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids=" + allids;
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   posturl += '&isshowModuleListTree=yes';
    	}
        ldAjaxHtml('index.php',posturl,function (response) {
            var tmparr = [];
            if (module == 'Accounts'){
                tmparr.push('Accounts');
            }else {
                tmparr.push('Contact');
            }
            ld('#rptContentLoading').hide();
            var popupobj = CrmPopup.load(arrJsPopLabel['PLEASESELECTEMAIL'], chosebox_select_btn_email, "", "LdPopWidth600px", module, '', arrJsPopLabel['SAVE'], tmparr, arrJsPopLabel['CANCEL']);
            var results = response.split('&#&#&#');
            popupobj.show(results[1]);

        });



    }
}

/**
 * 导入事件判断
 * @author Tujt 2015-05-28
 */
function listviewImport(obj, module) {
    var url = '';
    if(listviewImport.importstart=='yes')
        return ;
    
    listviewImport.importstart='yes';
    
   cls_XlsImportNew.getInstance(module).firstimport();
    return false;
   
}
listviewImport.importstart='no';


//显示隐藏注意事项
function showCautions() {
    var flagclass = ld('#importstep1 .pop_item_content').find('.pop_info').hasClass('hidden');
    if (flagclass) {
        ld('#importstep1 .pop_item_content').find('.pop_info').removeClass('hidden');
    } else {
        ld('#importstep1 .pop_item_content').find('.pop_info').addClass('hidden');
    }
}

//下一步、上一步
function next_import(step, type) {
    if (type == 'next') {
        ld('#importstep' + (step - 1)).hide();
        ld('#step' + (step - 1) + '_foot').hide();
        ld('#importstep' + step).show();
        ld('#step' + step + '_foot').show();
    } else {
        ld('#importstep' + (step - 1)).hide();
        ld('#step' + (step - 1) + '_foot').hide();
        ld('#importstep' + (step - 2)).show();
        ld('#step' + (step - 2) + '_foot').show();
    }
}
/*
*edit: chj
*date: 2020/9/14
*reason: 点击查看全部合计
*/
function listviewTotal(module){
	var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=ListViewTotal";
	//审批中心
	var popupobj = CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
	if(module == 'Approve'){
		var approvestatus = ld("#" + divid + " [name=approvestatus]").val();
		var fromapprovemodule = ld("#" + divid + " [name=fromapprovemodule]").val();
		var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&getTotalHtml=yes&file=HrefListView&approvestatus="+approvestatus+"&fromapprovemodule="+fromapprovemodule;
	}
    //chj 2020/11/9 42929: (61mis.com/kfbcrm)项目管理-项目进度；以项目进度模块为例，进行筛选后的单据列表，查看全部合计，显示的是全部单据的合计，而不是筛选后的全部合计；项目管理中的费率设定；财务管理-收款计划，付款计划，出纳提现单，出纳存现单，银行账户；和产品管理
    var param_url = '';
    var search_url = ld("#" + divid + " [name=search_url]").val();
    if(search_url != ''&&search_url != undefined){
        param_url += search_url;
    }
    // ljj 20231122 BUG0075916 kfbcrm-工单管理-选择源单（销售订单）-弹出层中点击全部合计，列表后半部分显示空白 (操作列显示出来了)
    if (popupobj.type == 'selectsearchdetail'){
        surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=Popup"
        surl += '&isselectsearchdetail=yes';
        var frommodule = CrmPopup.findHtmlobj(popupobj.divid,'frommodule').val();
        surl += '&frommodule='+frommodule;
        surl += '&gettotal=total';
        //ljj 20240628 选择源单增加不允许重复
        surl+=fun_setCrmPopupWindow.getSelectTypeSettingsUrl(popupobj.selectmodule);
        //20231213 BUG0077154 选择源单”全部合计“没有根据数据范围控制
        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
        var form =ld("#"+prevpopupobj.divid+" [name=EditView]");
        if (form.length == 0){
            form =ld("#"+prevpopupobj.divid+" [name=QcEditView]");
        }
        if(popupobj.module == 'Stock' || popupobj.module == 'PurchaseInvoice' || popupobj.module == 'SendCashBill' || popupobj.module == 'SendPayment' || popupobj.module == 'PurchaseInquiryOrder'){
            var vender_id=form.find('[name=vendor_id]').val();
            if(!empty(vender_id)){
                surl += '&vendorid='+vender_id;
            }
        }else{
            var account_id=form.find('[name=account_id]').val();
            if(!empty(account_id)){
                surl += '&accountid='+account_id;
            }
        }
        var popuptype = CrmPopup.findHtmlobj(divid,'popup_type').val();
        surl += '&popuptype='+popuptype;
        var param_url='';
        var search_fld_val= CrmPopup.findHtmlobj(divid,'search_field').val();
        var search_txt_val=CrmPopup.findHtmlobj(divid,'search_text').val();
        if(popupobj.searchtype=='Basic')
        {
            if(search_txt_val != '')
                param_url += '&query=true&search_field='+encodeURIComponent(search_fld_val)+'&searchtype=BasicSearch&search_text='+encodeURIComponent(search_txt_val);
            //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
			if(search_fld_val=='all'){
                var optionvalues = ld("select[name=search_field]").find(' option').map(function() {
                    if(ld(this).val()!='all'){
                        return ld(this).val();
                    }
                }).get();
                var search_fld_val_arr=JSON.stringify(optionvalues);
                param_url += '&search_field_arr='+search_fld_val_arr;
            }
        }
        else if(popupobj.searchtype=='Advanced')
        {
            var advft_criteria = popupobj.advft_criteria;;
            var advft_criteria_groups = popupobj.advft_criteria_groups;;
            //edit:can 20210513 045884: （http://corp.mdmedical.com.cn/index.php [^] ）（美迪医疗内镜维修）新建合同订单，点击选择源单为“验收单”，然后使用高级查找“源单类型”为“发票”，查出的结果点击下一页会出

            param_url += '&query=true&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';

            param_url += 'searchtype=advance';
        }
        var createEditPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        if(createEditPopupobj!=undefined)
        {
            //edit:can 20200825 42506: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），群发邮件，选择【联系人】接收人email弹出层界面，搜索“销售负责人”关键字，点击【立即查找】点不动（需要补丁）

            var  requestvalues="";
            var  sensitiverequestfield="";
            var requestvaluearr = getPageValueByCrmPopupFields(createEditPopupobj);
            requestvalues = requestvaluearr['requestvalue'];
            sensitiverequestfield = requestvaluearr['sensitiverequestfield'];

            param_url+="&requestvalues="+encodeURIComponent(requestvalues);
            param_url+="&sensitiverequestfield="+encodeURIComponent(sensitiverequestfield);
        }
        var search_fld_val= CrmPopup.findHtmlobj(divid,'search_field').val();
        var search_txt_val=CrmPopup.findHtmlobj(divid,'search_text').val();
        if(popupobj.searchtype=='Basic')
        {
            if(search_txt_val != '')
                param_url += '&query=true&search_field='+encodeURIComponent(search_fld_val)+'&searchtype=BasicSearch&search_text='+encodeURIComponent(search_txt_val);
            //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
			if(search_fld_val=='all'){
                var optionvalues = ld("select[name=search_field]").find(' option').map(function() {
                    if(ld(this).val()!='all'){
                        return ld(this).val();
                    }
                }).get();
                var search_fld_val_arr=JSON.stringify(optionvalues);
                param_url += '&search_field_arr='+search_fld_val_arr;
            }
        }
        else if(popupobj.searchtype=='Advanced')
        {
            var advft_criteria = popupobj.advft_criteria;;
            var advft_criteria_groups = popupobj.advft_criteria_groups;;
            //edit:can 20210513 045884: （http://corp.mdmedical.com.cn/index.php [^] ）（美迪医疗内镜维修）新建合同订单，点击选择源单为“验收单”，然后使用高级查找“源单类型”为“发票”，查出的结果点击下一页会出

            param_url+= '&query=true&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';

            param_url += 'searchtype=advance';
        }

    }else {
        var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
            surl += '&ajaxtype=ld_linkmodulecustom';
        }
    }
	//chj 2021/3/23 45099: （61mis.com/kfbcrm）OA表单-加班单；加班单列表处，点击全部合计时长为120；回到加班单的链接模块“加班单_已批准”后，点击全部合计也显示“120”，实际时长“38”；
	if(ld("#" + divid + " [name=viewname]").val() != undefined){
		surl += '&viewname='+ld("#" + divid + " [name=viewname]").val();
	}
    //zkt 20230307 BUG0062490  	入库单、出库单---当选择任意一个仓库---点击查看全部合计---计算的是全部仓库的合计，而不是当前选择的仓库
    if (module == 'Stock' || module == 'OutboundOrder' || module == 'InventoryQuery' || module == 'InventoryAccount') {
            // var wareid = document.getElementById("wareid").value;
            var wareid = ld("#" + divid + " #wareid").val();
            surl+='&wareid='+wareid;
     }
    //duan 20240729 BUG20240726-16  收款认领单统计合计时加上页签条件
    if (module == 'Stock' || module == 'OutboundOrder' || module == 'InventoryQuery' || module == 'InventoryAccount') {
        // var wareid = document.getElementById("wareid").value;
        var wareid = ld("#" + divid + " #wareid").val();
        surl+='&wareid='+wareid;
    }
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   surl += '&isshowModuleListTree=yes';
	}
	//alert(surl);
	ldAjax(surl,param_url,function(data){
		if(data.code==1){
			
			ld('#'+divid+" [tag=all_total_row]").html(data.result.content);
            DelProgressObjs();
		}
	})
}
/**
 * 导出事件判断
 * @author Tujt 2015-05-28
 */
function listviewExport(obj, module) {

    var that = this;
    List_CheckBox_Ids.getIds(module);
    var count = List_CheckBox_Ids.num_rows;
    this.listcount = 0;
    that.eachexportcount = 50;
	if(obj.account == ''){
		var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", module, "", 'none', "", "");
		crmPopupobj.prevshow();
		var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=ExportRecordFirst";
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(surl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();

                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth600px", module, "", "", "", "");
                crmPopupobj.show(data.result.content);
                ld("#"+crmPopupobj.divid+" [name=search_type]").unbind("change").bind("change",function(){
                    var rows= parseInt(ld("#numOfRows").val());
                    if(ld(this).val()=='includesearch')//导出搜索结果
                    {
                        if(rows>2000)
                        {
                            ld("#"+crmPopupobj.divid+" [name=exportformat]").val('exportcsv');
                        }
                        else
                        {
                            ld("#"+crmPopupobj.divid+" [name=exportformat]").val('exportexcel');
                        }
                    }
                    else
                    {
                        ld("#"+crmPopupobj.divid+" [name=exportformat]").val('exportexcel');
                    }

                });
                //BUG0065064 yujun 2023-6-7 在供应商联系人中,如果未选中了行,那么下拉框显示根据搜索结果导出
                if(count > 0)
                    ld("#"+crmPopupobj.divid+" [name=search_type]").val('selecteddata');
                else ld("#"+crmPopupobj.divid+" [name=search_type]").val('includesearch');

                ld("#"+crmPopupobj.divid+" [name=search_type]").change();
                ld("#exportfirst_btnok").unbind("click").bind("click", function () {
                    that.createExportProgress();
                });
                ld("#"+crmPopupobj.divid+" [name=export_style_setting]").unbind("click").bind("click", function () {
                    that.settingExportstyle();
                });
                ld("#"+crmPopupobj.divid+" [name=search_type]").unbind('change').bind('change', function(){
                    if(count<1 && ld("#"+crmPopupobj.divid+" [name=search_type]").val() == 'selecteddata'){
                        var content = arrJsPopLabel['NONSELECTEDRECORDSNUMS'];
                        ld("#"+crmPopupobj.divid+" [name=search_type]").val('includesearch');
                        MessagePopup.TipOne_warning(content);
                    }
                })
            }
        });
	}
	this.settingExportstyle = function(){
	   var popupobj = CrmPopup.getPopupObj('last');
	   var module = popupobj.module;
       var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", module, "", 'none', "", "");
       crmPopupobj.prevshow();
	   var surl = 'index.php?module=Users&action=UsersAjax&file=ExportStyleSettings&mode=edit&frommodule='+module;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(surl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();

                crmPopupobj.setParams(data.result.title, that.settingExportstyleSave, "", "LdPopWidth600px", module, "", data.result.oktext, "", data.result.canceltext);
                crmPopupobj.show(data.result.content);

            }
        });
        
	}
    this.settingExportstyleSave = function(){
       var popupobj = CrmPopup.getPopupObj('last');
	   var module = popupobj.module;
       //获取设置的值
       var exportstyle_defaultobj = ld('#'+popupobj.divid).find(' [name=export_style]');
       var exportstyle_default = ld(exportstyle_defaultobj).val();
       var surl = 'index.php?module=Users&action=UsersAjax&file=ExportStyleSettings&mode=save&frommodule='+module+'&exportstyle_default='+exportstyle_default;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(surl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();
                popupobj.CancelEvent();

                var prevpopupobj = CrmPopup.getPopupObj('last');
                var exportstyleobj = ld('#'+prevpopupobj.divid).find(' select[name=export_style]');
                ld(exportstyleobj).val(exportstyle_default);

            }
        });
    }
    this.createExportProgress = function () {
        that.exportajax = '';
        var popupobj = CrmPopup.getPopupObj('last');
        var exportformatvalue = ld("#" + popupobj.divid + " [name=exportformat]").val();
        this.exportformatvalue = exportformatvalue;
        this.search_type = ld("#" + popupobj.divid + " [name=search_type]").val();
        this.export_style = ld("#" + popupobj.divid + " [name=export_style]").val();
        //ls 2021-11-16 48734: （http://www.jnccgroup.com:8585/crm/ [^]）（客户问题-徐东）客户档案》数据分类“导出使用”，在该数据分类下操作导出客户数据，结果导出的字段内容是“全部”页签的（客户模块的viewname，没有做缓存session处理（其实被注释），所以需要前端传过去）
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        this.viewname = ld("#" + prevpopupobj.divid + " [name=viewname]").val();
        //zkt 20240910 BUG20240910-09 工作汇报 -移动端- 1、钉钉可以收到提交人周报点评消息，钉钉收不到回复/点评消息（钉钉其他审批、分配等消息可以收到）
        this.searchfrom = prevpopupobj.type;
        var searchfrom=this.searchfrom;

        popupobj.CancelEvent();
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", module, "", 'none', "", "");
        crmPopupobj.prevshow();

        List_CheckBox_Ids.getIds(module);
        var select_options = List_CheckBox_Ids.ids;
        this.selectidstring = select_options;
        this.selectcount = List_CheckBox_Ids.num_rows;

        var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=Export" + module + "&getprogress=yes";
        surl += '&exportformat=' + exportformatvalue + "&search_type=" + this.search_type + "&export_style="+this.export_style+"&idstring=" + this.selectidstring + "&viewname=" + this.viewname;
         if (module == 'Stock' || module == 'OutboundOrder' || module == 'InventoryQuery' || module == 'InventoryAccount') {
                var wareid = document.getElementById("wareid").value;
                surl+='&wareid='+wareid;
         }
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   surl += '&isshowModuleListTree=yes';
    	}
        var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
            surl += '&ajaxtype=ld_linkmodulecustom';
            this.ajaxtype = 'ld_linkmodulecustom';
        }
        if(module == 'Users'){
            var listpopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
            if(listpopupobj.user_type){
                surl += '&user_type='+listpopupobj.user_type;
            }
        }
        surl += '&searchfrom='+searchfrom;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(surl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth600px", module, "", "", "", "");
                crmPopupobj.show(data.result.content);

                document.getElementById(crmPopupobj.divid + "_imgclose").onclick = function () {
                    crmPopupobj.CancelEvent();

                    if (that.exportajax != '') {

                        that.exportajax.abort();
                    }

                }
                that.listcount = data.result.listcount;
                that.detailcount = data.result.detailcount;
                that.writefilelabel = data.result.writefilelabel;
                if (that.detailcount > 2000 && that.detailcount < 5000) {
                    that.eachexportcount = 100;
                }
                else if (that.detailcount >= 5000) {
                    that.eachexportcount = 200;
                }
                else {
                    that.eachexportcount = 50;
                }
                //ld("#dvctimedescription").html(data.result.timedescription);
                that.startexport(data.result.endexportrow, data.result.endexportrow + that.eachexportcount);

            }
        });

        //exportfirst_btnok
    }
    this.startexport = function (startexportrow, endexportrow) {

        var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=Export" + module + "&startexportrow=" + startexportrow + "&endexportrow=" + endexportrow;
        surl += '&exportformat=' + that.exportformatvalue + "&search_type=" + this.search_type + "&export_style="+this.export_style+ "&idstring=" + this.selectidstring + "&viewname=" + this.viewname;
        surl += '&searchfrom='+this.searchfrom;
        //zkt 20220512 51631（http://47.116.130.205:85/crm/index.php）(客户问题-黄祖峰)用树结构搜索导出成交客户，结果导出来很多其他类型的
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   surl += '&isshowModuleListTree=yes';
    	}
        if (this.ajaxtype == 'ld_linkmodulecustom'){
            surl += '&ajaxtype=ld_linkmodulecustom';
        }
		
        var width = parseInt(startexportrow / that.listcount * 100);

        if (width >= 100) {
            width = 100;
        }
        ld("#dvExportprogress").css("width", width + "%");

        if (parseInt(startexportrow, 10) >= parseInt(that.listcount, 10)) {
            // that.startwritefile();
            that.exportresulthtml();
            return false;
        }
        
        this.exportajax = ldAjaxNoProgress(surl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();
                if (parseInt(data.result.endexportrow, 10) >= parseInt(that.listcount, 10)) {
                    ld("#dvExportprogress").css("width", "100%");
                    //that.startwritefile();
                    that.exportresulthtml();
                    return false;
                }
                for (var i = 0; i < 2000; i++) {

                }
                ld("#dvctimedescription").html(data.result.timedescription);

                that.startexport(data.result.endexportrow, parseInt(data.result.endexportrow, 10) + parseInt(that.eachexportcount, 10));

            }
        });
    }
    that.exportresulthtml = function () {
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
        var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=ExportResult";
        surl += "&exportformat=" + that.exportformatvalue;
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", module, "", 'none', "", "");
        crmPopupobj.prevshow();
        ldAjax(surl,'',function (data) {
            DelProgressObjs();
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth600px", module, "", "", "", "");
                crmPopupobj.show(data.result.content);
            }
        });
    }
    that.startwritefile = function () {


        var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=WriteExportFile";
        ldAjax(surl,'',function (data) {
            if (data.code == 1) {
            }
            DelProgressObjs();
        });
    }

    return false;

    switch (module) {
        case 'InventoryLedger'://库存台账
            exportInventoryLedger();
            break;
        default://默认
            selectedRecords(module, '');
            break;
    }
}

/**
 *edit:kevin
 *date:2013-07-05
 *reason:4387
 */
function markSign(module, val) {
    var searchurl = $('search_url').value;
    var viewid = getviewId();
    var idstring = "";
    var obj = document.getElementsByName('folderidVal');
    var select_options = $('allselectedboxes').value;
    var excludedRecords = $('excludedRecords').value;
    var numOfRows = $('numOfRows').value;
    if (select_options == 'all') {
        document.getElementById('idlist').value = select_options;
        idstring = select_options;
        var skiprecords = excludedRecords.split(";");
        var count = skiprecords.length;
        if (count > 1) {
            count = numOfRows - count + 1;
        } else {
            count = numOfRows;
        }
    } else {
        var x = select_options.split(";");
        count = x.length;
        if (count > 1) {
            document.getElementById('idlist').value = select_options;
            idstring = select_options;
        } else {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
        //we have to decrese the count value by 1 because when we split with semicolon we will get one extra count
        count = count - 1;
    }
    if (ld.trim(count) == '') {
        count = 0;
    }
    //37061: （1.6）消息已读界面>查找>查找条件为【审批】：将查找出来的单据全部勾选上设为未读，提示“您选择了60条记录，批量操作只对前2000条记录生效，是否继续?”勾选的单据没有超过两千条不应该有该提示的
    if (parseInt(count, 10) > parseInt(getMaxMassOperationLimit(), 10)) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', count, getMaxMassOperationLimit(), '');
        MessagePopup.TipTwo_warning(confirm_str);
        var popupobj = CrmPopup.getPopupObj('last');
        ld('#'+popupobj.divid + ' [tagclick=msgConfirm]').unbind('click').bind('click',function (event) {
            if (module == 'Reminds') {
                vn = getObj('viewname').value;
                url += '&viewname=' + vn;

                //修改提醒数量
                var remdmindscount = ld('#noticebar .redFont').html();
                //wyt 220829 BUG0055698进入提醒页面后，再点击右上角的消息，没法弹出页面 BUG0055675提醒页面选择消息，然后点击设为已读之后，提醒页面的数量能够对应，但是最新的一条消息的内容不回应
                if (remdmindscount == '') {
                    remdmindscount = '0';
                }else
                    remdmindscount = remdmindscount.replace(/\D/g, '');

                if (val == 0) {
                    remdmindscount = parseInt(parseInt(remdmindscount) + parseInt(count));
                }
                else if (val == '') {
                    remdmindscount += 1;
                }
                else {
                    remdmindscount = parseInt(parseInt(remdmindscount) - parseInt(count));
                }
                if (remdmindscount <= 0) {
                    remdmindscount = '';
                    ld('#noticeHeader .noticeHeaderContent').remove();
                    ld('#noticebar a').children('b').remove();
                }
                else {
                    remdmindscount = remdmindscount;
                    ld('#noticebar a').append('<b></b>');
                    ld('#noticeHeader').html('<div class="noticeHeaderContent"></div>');
                }
                ld('#noticebar .redFont').html('('+remdmindscount+')');
            }

            ld('#rptContentLoading').show();
            var url = "&excludedRecords=" + excludedRecords;
            var urlstring = "module=Reminds&action=RemindsAjax&file=SignMark&return_module=" + module + "&" + gstart + "&viewname=" + viewid + "&idlist=" + idstring + searchurl + url + '&sign_value=' + val;
            //alert("module=Reminds&action=SignMark&return_module="+module+"&"+gstart+"&viewname="+viewid+"&idlist="+idstring+searchurl+url+'&sign_value='+val);
            ldAjaxHtml('index.php?',urlstring,function (response){
                ld('#rptContentLoading').hide();
                if (empty(response)) return false;
                var restobj = eval('(' + response + ')') ? eval('(' + response + ')') : JSON.parse(response);
                resultRemindsMsg(restobj.title.value, "LdPopWidth600px", module, "yes", "", restobj.log.value);
                //点击确定
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    fninvshnew('RemindsConvert');
                    puyoungJS_DialogBox.unblock();
                    $('basicsearchcolumns').innerHTML = '';
                    $('allselectedboxes').value = '';
                    $('excludedRecords').value = '';
                    ActivityReminderCallback();
                    getRemindsCount();
                    getListViewEntries_js('Reminds', 'start=' + restobj.start.value);//刷新页面
                });
                //修改提醒数量后，加载弹出框
                if (remdmindscount > 0) {
                    setRemindReadenHeaderSecond();
                }
            })
        })
    } else {
        if (module == 'Reminds') {
            vn = getObj('viewname').value;
            url += '&viewname=' + vn;

            //修改提醒数量
            var remdmindscount = ld('#noticebar .redFont').html();
            //wyt 220829 BUG0055698进入提醒页面后，再点击右上角的消息，没法弹出页面 BUG0055675提醒页面选择消息，然后点击设为已读之后，提醒页面的数量能够对应，但是最新的一条消息的内容不回应
            if (remdmindscount == '') {
                remdmindscount = '0';
            }else
                remdmindscount = remdmindscount.replace(/\D/g, '');

            if (val == 0) {
                remdmindscount = parseInt(parseInt(remdmindscount) + parseInt(count));
            }
            else if (val == '') {
                remdmindscount += 1;
            }
            else {
                remdmindscount = parseInt(parseInt(remdmindscount) - parseInt(count));
            }
            if (remdmindscount <= 0) {
                remdmindscount = '';
                ld('#noticeHeader .noticeHeaderContent').remove();
                ld('#noticebar a').children('b').remove();
            }
            else {
                remdmindscount = remdmindscount;
                ld('#noticebar a').append('<b></b>');
                ld('#noticeHeader').html('<div class="noticeHeaderContent"></div>');
            }
            ld('#noticebar .redFont').html('('+remdmindscount+')');
        }

        ld('#rptContentLoading').show();
        var url = "&excludedRecords=" + excludedRecords;
        var urlstring = "module=Reminds&action=RemindsAjax&file=SignMark&return_module=" + module + "&" + gstart + "&viewname=" + viewid + "&idlist=" + idstring + searchurl + url + '&sign_value=' + val;
        //alert("module=Reminds&action=SignMark&return_module="+module+"&"+gstart+"&viewname="+viewid+"&idlist="+idstring+searchurl+url+'&sign_value='+val);
        ldAjaxHtml('index.php?',urlstring,function (response){
            ld('#rptContentLoading').hide();
            if (empty(response)) return false;
            var restobj = eval('(' + response + ')') ? eval('(' + response + ')') : JSON.parse(response);
            resultRemindsMsg(restobj.title.value, "LdPopWidth600px", module, "yes", "", restobj.log.value);
            //点击确定
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                fninvshnew('RemindsConvert');
                puyoungJS_DialogBox.unblock();
                $('basicsearchcolumns').innerHTML = '';
                $('allselectedboxes').value = '';
                $('excludedRecords').value = '';
                ActivityReminderCallback();
                getRemindsCount();
                getListViewEntries_js('Reminds', 'start=' + restobj.start.value);//刷新页面
            });
            //修改提醒数量后，加载弹出框
            if (remdmindscount > 0) {
                setRemindReadenHeaderSecond();
            }
        })
    }
}
//date:2021-9-3 edit:duan reason:未读消息数量为0后弹出层不消失
function setRemindReadenHeaderSecond(remindsid, pagenum, current_page = 0, is_last = 0){
    remindsid = remindsid||"";
    pagenum = pagenum||"";
    if(pagenum != '1'){
        var surlsecond = "index.php?module=Reminds&action=RemindsAjax&file=SetRemindReaden&getRemindsContent=yes&page_tag=&remindsid="+remindsid+"&pagenum=";
        //edit:xll 2023/05/04 BUG0065801 kfbcrm-右上角消息，点击推迟后应留在当页
        //current_page当前页码，默认为0即无需停留在当前页面
        surlsecond += "&current_page=" + current_page + "&is_last=" + is_last;
        surlsecond= cls_encryptyurl.Puyoung_Encryptyurlhavephp(surlsecond,'');
        ld.ajax({
            url: surlsecond,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,
            timeout: 5000,
            success:function(data){
                if(data.code == 1){
                    ld('#noticeHeader .noticeHeaderContent').html(data.result.content);
                    ld('#headerremindscount').html('('+data.result.remindscount+')');
                }
            }
        });
    }else{
        ld('#noticeHeader .noticeHeaderContent').remove();
        ld('#noticebar a').children('b').remove();
    }
}

function mass_checks(module) {
    var searchurl = $('search_url').value;
    var viewid = getviewId();
    var idstring = "";

    var select_options = $('allselectedboxes').value;
    var excludedRecords = $('excludedRecords').value;
    var numOfRows = $('numOfRows').value;
    if (select_options == 'all') {
        document.getElementById('idlist').value = select_options;
        idstring = select_options;
        var skiprecords = excludedRecords.split(";");
        var count = skiprecords.length;
        if (count > 1) {
            count = numOfRows - count + 1;
        } else {
            count = numOfRows;
        }
    } else {
        var x = select_options.split(";");
        count = x.length;

        if (count > 1) {
            document.getElementById('idlist').value = select_options;
            idstring = select_options;
        } else {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
        //we have to decrese the count value by 1 because when we split with semicolon we will get one extra count
        count = count - 1;
    }

    if (count > getMaxMassOperationLimit()) {
        //var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
        //if(confirm(confirm_str)) var confirm_status = true;
        //else return false;
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', count, getMaxMassOperationLimit(), '');
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);

        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            var confirm_status = true;
            confirm_mass_checks(module, viewid, idstring, count, searchurl, excludedRecords, confirm_status);
        });
    }
    else {
        confirm_status = false;//0025728: 收/付款单：全选当前界面所有单据批量审核，多出了一个弹出层
        confirm_mass_checks(module, viewid, idstring, count, searchurl, excludedRecords, confirm_status);
    }


}

//确认收付款单审核
function confirm_mass_checks(module, viewid, idstring, count, searchurl, excludedRecords, confirm_status) {
    var url = "&excludedRecords=" + excludedRecords;
    alert_str = arrJsPopLabel['Todeterminetheselected'] + ' ' + count + ' ' + arrJsPopLabel['Recordscheckoutits'];
    var searchScope = "";
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    else if (module == "Reminds")
        searchScope = "SmOwner_Search_All";
    if (module.toLocaleLowerCase() == "cashbill") {
        alert_str = arrJsPopLabel['Todeterminetheselected'] + ' ' + count + ' ' + arrJsPopLabel['Recordscheckoutits'];
        $("status").style.display = "block";
        masscheckCashBill(alert_str, module, gstart, viewid, idstring + searchurl + url, searchScope, confirm_status);
    }
    else if (module.toLocaleLowerCase() == "sendcashbill") {
        alert_str = arrJsPopLabel['Todeterminetheselected'] + ' ' + count + ' ' + arrJsPopLabel['Recordscheckoutits'];
        $("status").style.display = "block";
        masscheckSendCashBill(alert_str, module, gstart, viewid, idstring + searchurl + url, searchScope, confirm_status);
    }
}

//列表提示信息,例如:如何退货
function HowToReturn(obj, div) {
    //BUG0065617 徐心玥 2023-4-28 重新获取title和content利用crmpopup显示弹框实现弹框可拖拽
    var title = ld('#' + div + ' .ld-titlename').html();
    var content = ld('#' + div + ' .ld-public-content-small').prop("outerHTML");//获取元素本身的HTML
    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", "Settings", "", "", "", "");
    crmPopupobj.prevshow();
    crmPopupobj.setParams(title, msgConfirm, "", "LdPopWidth600px", "Settings", "", arrJsPopLabel['LBL_CLOSE'], "", "", "");
    crmPopupobj.show(content);
    // 设置内容最大高度
    crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
}
function getListViewEntries_jss(module, url) {

    /*editor:gyq_86 reason:库存报表 2018/11/26 18:48 */
    if (module === 'report_cangku') {
        callOftenUseReportSearch(null, 'BasicSearch', 'page', url);
        return false;
        //editor:gyq_20181212 库存台账分页特殊处理
    } else if (module === 'InventoryLedger') {
        redirect_record('page', url);
        return false;
    }
    var popupobj = CrmPopup.getPopupObj("last");
    if (popupobj.type == 'selectsearchdetail') {
        fun_setCrmPopupWindow.getListViewEntries_js(module, url);

        return false;
    }
	//chj 2020/12/7 43457: （61mis.com/kfbcrm）工具-回收站-联系人（需要补丁）；回收站中，联系人模块有多条单据，右上角点击下一页>没有反应，输入页数，点击GO也没反应
	if(module == 'RecycleBin'){
		Recyle_getListViewEntries_js(module, url);
        return false;
	}
    if (popupobj.headname == 'Findduplicates'){
        return false;
    }
    /*
    20140307
    andrw
    审批中已审批翻页跳转到未审批的bug
    */
    //url = escape(url);
    if (module == 'Approve') {
        if (ld('#fromapprovemodule') != undefined) {
            url += '&fromapprovemodule=' + ld('#fromapprovemodule').val();
        }
        if (ld('#approvestatus') != undefined) {
            url += '&approvestatus=' + ld('#approvestatus').val();
        }
    }
    // 2024-09-11 xxy 消息中心样式修改
    if(module == 'Reminds'){
        var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        url += '&remindscategoryid=' + listpage_popupobj.remindscategoryid;
    }
    //if(module!='Documents'){
    var excludedRecords = $('excludedRecords').value;
    var all_selected = $("allselectedboxes").value;
    var count = $('numOfRows').value;


    var select_options = document.getElementsByName('selected_id');
    var x = select_options.length;
    var viewid = getviewId();
    var hrefUrl;
    //   var viewScope=document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").selectedIndex].value;
    var wareid = 0;
    var idstring = "";

    xx = 0;
    for (i = 0; i < x; i++) {
        if (select_options[i].checked) {
            idstring = select_options[i].value + ";" + idstring
            xx++
        }
    }

    if (typeof $('search_url') != 'undefined' && $('search_url').value != '')
        var urlstring = $('search_url').value;
    else
        urlstring = '';

    var searchScope = '';
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    gstart = url;
    var customtype = '';
    if (document.massdelete!=undefined&&document.massdelete.publicaccounttype != undefined) {
        customtype = document.massdelete.publicaccounttype.value;
    }
    //"name": "cxh", "sex": "man"

    if (document.getElementById('wareid') != undefined && document.getElementById('wareid').value > 0) {
        wareid = document.getElementById('wareid').value;
    }
    if (module == 'BankCash' || module == 'Stock' || module == 'Checks' || module == 'OutboundOrder' || module == 'Prdtnums' || module == 'InventoryAccount' || module == 'InventoryQuery') {
        hrefUrl = "module=" + module + "&action=" + module + "Ajax&file=ListView&ajax=true&start=1&allselobjs=" + all_selected + "&selobjs=" + idstring + "&" + url + urlstring + "&viewname=" + viewid + "&SearchScope=" + searchScope ;//
        //	if(module='InventoryQuery')
        //{
        strOtherSearch = '[{"fieldname":"wareid","searchvalue":"' + wareid + '","condition":"and","fieldmodule":"' + module + '"}]';
        // }
        hrefUrl += "&wareid=" + wareid;
        hrefUrl += "&addSpecialSearchCondition=" + strOtherSearch;

    }
    else {

        //27227: 单据>列表：分配负责人后，列表没有刷新，负责人还是显示为原来的负责人。预期结果：应该刷新界面，显示新的负责人。
        url = String(url);


        hrefUrl = "module=" + module + "&action=" + module + "Ajax&file=ListView&ajax=true&allselobjs=" + all_selected + "&selobjs=" + idstring + "&" + url + urlstring + "&viewname=" + viewid + "&SearchScope=" + searchScope + "&pagepublicaccounttype=" + customtype;
        if (url.toLowerCase().indexOf('sorder') <= 0) {
            //27068: 客户>列表：点击“最晚服务到期日”列头排序，结果：只有第一页排序了，第二页没有排序。
            hrefUrl += "&listoperationtype=page";//点击分页按钮
        }
    }

    if (module == "Users") {
        //ls 2022-05-16 (https://81mis.com/kfbcrm/index.php) 成员管理》测试1》任意点击某一成员进入详情，然后再返回序时簿界面，再点击“停用”或“启用”或者“下一页”，序时簿所显示的内容变为所有成员
        if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
            popupobj.groupobj.initGroup();
        }
        hrefUrl += "&groupid=" + Op_UserGroup.curr_group_obj.record;

        var listPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
        if(listPopupobj.user_type){
            hrefUrl += '&user_type='+listPopupobj.user_type;
        }
    }
    //获取平铺查找的显示状态
    if(ld("#tiledSearch")!=undefined){
        if(ld("#tiledSearch").css('display')!=undefined&&ld("#tiledSearch").css('display')=='none'){
            hrefUrl += '&tiledSearchdisplay=none';
        }
    }
    //分页
    var noAlertOfSalestage = ld('#noAlertOfSalestage').val();
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   hrefUrl += '&isshowModuleListTree=yes';
	}
    var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
        hrefUrl += '&ajaxtype=ld_linkmodulecustom';
    }
    
    if(noAlertOfSalestage=='yes'){
        //zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
        hrefUrl += '&sales_stage='+ ld('#stage_name_input').val() +'&oldcustomer_marketing='+ld('#oldcustomer_name_input').val() +'&fromtype=salesfunnel' ;
        hrefUrl += '&advance_stage='+ ld('#stage_name_input').val();
        //BUG0065204	zxm20230420 去掉search_type=advance 序时簿列表界面，使用字段搜索，点击进度漏斗，进入其中一个阶段，点击分页组件，数据条数改变
        //let urlstring = getUrlString('Advanced');
        //if(urlstring==false){
            //urlstring = '';
        //}
        let SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
		//chj 2021/11/26 48928: （http://xiaoshou360.com/xs/hzshuiyou/ [^] ）（客户问题-税友）销售机会中销售漏斗显示的数量和实际的不符合，点进每一块漏斗中，翻页，数量又会变成正确的数量
       //BUG0065204	zxm20230420 去掉search_type=advance 序时簿列表界面，使用字段搜索，点击进度漏斗，进入其中一个阶段，点击分页组件，数据条数改变
        hrefUrl += urlstring+'&query=true&SearchScope='+SmOwnerSearchScope;
        var listview_page = new ListView_Page(module, hrefUrl, popupobj.divid+'_scroll');
    }else{
        var listview_page = new ListView_Page(module, hrefUrl, "ListViewContents");
    }

    //edit: xll 2023/07/31 BUG0063767 标签查找，选中标签，点击下一页，标签内容被隐藏
    var ListTagViewObj = ld('#listtag_div');
    var TagListObj = ListTagViewObj.find('[name=moduletag_list]');
    if(TagListObj.length > 0 && TagListObj.is(':visible'))
        listview_page.ShowTag = 'yes';

    listview_page.callback_fun = function () {
        //var popupobj=CrmPopup.getPopupObj('last');
        //BUG0069148 自动查重合并，选择数据点击合并，合并后返回序时簿列表界面，右侧表头字段设置按钮点击无效
        var popupobj = CrmPopup.getlastPopupObjByPageType('listpage');
        //zkt 20221202 BUG0059426kfbcrm  消息中心---点开一条未读消息---关闭后----显示页面就缩小了
        if(module == 'Reminds'&&noAlertOfSalestage!='yes'){
            popupobj = CrmPopup.getlastPopupObjByPageType('listpage');
        }
        if (!empty(popupobj.listresizeobj)) {
            popupobj.listresizeobj.setReiszeTable_Init(module, 'ajax');
        }
		ld('#allselectedboxes').val('');
        setContentHeight(module);//计算内容高度
        //if (module == 'Accounts') {
            IsFrameElement();
        //}
    }
    listview_page.page();


}
//@edit:liujiajun,2023-07-12,reason:BUG0069181:  列表界面点击行选中复选框-列表单选框
function check_objects_parent_td(obj){
    var parent_td=ld(obj).find("input")[0];
    var e = window.event;
    if(e.target !=  parent_td){
        ld(parent_td).prop('checked',!ld(parent_td).prop('checked'));
    }
    check_object(parent_td);
}

check_objects.popupobj = null;
function check_objects(sel_id, groupParentElementId) {
    var skip = '';
    var selected = '';
    //0023354: 市场活动明细界面 > 相关信息-客户：逐个勾选本页全部单据前的□，列表头的□没有被勾选中
    var currentModule;

    var popupobj = CrmPopup.getPopupObj('last');
    if(check_objects.popupobj && check_objects.popupobj != undefined && check_objects.popupobj.type){
        if(check_objects.popupobj.divid == popupobj.divid){

        }
        else{
            ld("#RLreturn_module").val('');
            ld("#allselectedboxes").val('');
            ld("#excludedRecords").val('');
            ld("#numOfRows").val(0);
            check_objects.popupobj = popupobj;
        }
    }
    else{
        check_objects.popupobj = popupobj;
    }


    var RLreturn_module_obj = ld("#RLreturn_module");
    var allselectedboxes_obj = ld("#allselectedboxes");
    var excludedRecords_obj = ld("#excludedRecords");
    if (RLreturn_module_obj.length>0) {
        currentModule = RLreturn_module_obj.val();
    }
    if (currentModule != undefined && currentModule == 'Campaigns') {
        var all_state = true;
        var groupElements = document.getElementsByName("selected_id");

        if (typeof(groupElements) == 'undefined') return;

        for (var i = 0; i < groupElements.length; i++) {
            var state = groupElements[i].checked;
            if (state == false) {
                all_state = false;
                break;
            }
        }
        if (getObj("Campaigns_Accounts_selectCurrentPageRec")) {
            getObj("Campaigns_Accounts_selectCurrentPageRec").checked = all_state;
        }
    }

    if(allselectedboxes_obj.length>0){
        selected = trim(allselectedboxes_obj.val());
    }
    if (excludedRecords_obj.length>0) {
        skip = excludedRecords_obj.val();
    }



    var select_global = new Array();
    select_global = selected.split(";");
    var box_value = sel_id.checked;
    var id = sel_id.value;
    var duplicate = select_global.indexOf(id);
    var size = select_global.length - 1;
    var result = "";

    if (box_value == true) {
        ld('#' + sel_id.value).addClass('tb-checkbox-selected');
        /*if($('curmodule') != undefined && $('curmodule').value == 'Documents' && $('selectedboxes_'+groupParentElementId).value == 'all'){
			$('excludedRecords_'+groupParentElementId).value = skip.replace(skip.match(id+";"),'');
			$('selectedboxes_'+groupParentElementId).value = 'all';
		} else*/
        //全选后  取消单据excludedRecords
        if (allselectedboxes_obj.val() == 'all') {
            excludedRecords_obj.val(skip.replace(skip.match(id + ";"), ''));
            allselectedboxes_obj.val('all');
        } else {
            if (duplicate == "-1") {
                select_global[size] = id;

                /*	if($('curmodule') != undefined && $('curmodule').value == 'Documents') {

                         $('selectedboxes_'+groupParentElementId).value +=id+";";
    			} else {*/
                if(allselectedboxes_obj.length>0){
                    allselectedboxes_obj.get(0).value += id + ";";
                }
                //}
            }

        }

        default_togglestate(sel_id.name, groupParentElementId);

        /*
        *edit:diony
        *time:2014-08-07
        *reason:列表选中变色
        */
        //原方法：获取ListView_Page.content_tableid（被重新赋值，导致切换模块时显示错位）
		//修改为通过this对象获取上级table元素
        var tabobj = Tools.getParentobjByChild(ld(sel_id),'table');
        if (tabobj.length>0) {

            var table = tabobj.get(0);    //获取js对象
            var trs = table.getElementsByTagName('tr');
            var trselobj = sel_id.parentNode || sel_id.parentElement;
            while (trselobj.tagName != 'TR') {
                trselobj = trselobj.parentNode || trselobj.parentElement;
            }
            var trselid = trselobj.id;
            var rowReacord = trselid.split(",");
            for (var i = 0; i < trs.length; i++) {
                var rowTrs = trs[i].id.split(",");
                if (rowTrs[0] == rowReacord[0]) {
                    //document.getElementById(trs[i].id).className = "lvtColDataHover";    //lvtColData
                    if (sel_id.checked) {
                        //ld("tr[id^="+rowTrs[0]+"]").attr('class','lvtColDataSelected');
                        // document.getElementById(trs[i].id).className = "lvtColDataSelected";
                        ld('[id="'+trs[i].id+'"]').addClass("lvtColDataSelected");
                    }
                    else {
                        //ld("tr[id^="+rowTrs[0]+"]").attr('class','lvtColDataHover');
                        //document.getElementById(trs[i].id).className = "lvtColDataHover";
                    }
                }
            }
        }
        else {
            var rows = "row_" + sel_id.value;
            ld("tr[id^=" + rows + "]").attr('class', 'lvtColDataSelected');
            //if( document.getElementById(rows) != undefined){
            //	document.getElementById(rows).className = "lvtColDataSelected";
            //	}
        }
    }
    else {
        ld('#' + sel_id.value).removeClass('tb-checkbox-selected');
        ld('#selectCurrentPageRec').removeClass('tb-checkbox-selected');
        /*if($('curmodule') != undefined && $('curmodule').value == 'Documents' && $('selectedboxes_'+groupParentElementId).value == 'all'){
			$('excludedRecords_'+groupParentElementId).value = id+";"+skip;
			$('selectedboxes_'+groupParentElementId).value = 'all';
		} else*/
        if (allselectedboxes_obj.val() == 'all') {
            excludedRecords_obj.val(id + ";" + skip);
            allselectedboxes_obj.val('all');
        } else {
            if (duplicate != "-1")
                select_global.splice(duplicate, 1);

            size = select_global.length - 1;
            var i = 0;
            for (i = size; i >= 0; i--) {
                if (trim(select_global[i]) != '')
                    result = select_global[i] + ";" + result;
            }

            default_togglestate(sel_id.name, groupParentElementId);

            allselectedboxes_obj.val(result);
            //}
        }
        /*if($('curmodule') != undefined && $('curmodule').value == 'Documents'){
			$('currentPageRec_'+groupParentElementId).checked = false;
		} else {*/
        if (ld('#selectCurrentPageRec').length>0) {
            ld('#selectCurrentPageRec').get(0).checked = false;
        }
        //}
        /*
        *edit:diony
        *time:2014-08-07
        *reason:列表选中变色
        */
		//原方法：获取ListView_Page.content_tableid（被重新赋值，导致切换模块时显示错位）
		//修改为通过this对象获取上级table元素
        var tabobj = Tools.getParentobjByChild(ld(sel_id),'table');
        if (tabobj.length>0) {
            var table = tabobj.get(0);
            var trs = table.getElementsByTagName('tr');
            var trselobj = sel_id.parentNode || sel_id.parentElement;
            while (trselobj.tagName != 'TR') {
                trselobj = trselobj.parentNode || trselobj.parentElement;
            }
            var trselid = trselobj.id;
            var rowReacord = trselid.split(",");
            for (var i = 0; i < trs.length; i++) {
                var rowTrs = trs[i].id.split(",");
                if (rowTrs[0] == rowReacord[0]) {
                    //document.getElementById(trs[i].id).className = "lvtColDataHover";    //lvtColData
                    if (sel_id.checked) {
                        //ld("tr[id^="+trs[i].id+"]").attr('class','lvtColDataSelected');
                        // document.getElementById(trs[i].id).className = "lvtColDataSelected";
                    }
                    else {
                        //ld("tr[id^="+trs[i].id+"]").attr('class','lvtColDataHover');
                        //document.getElementById(trs[i].id).className = "lvtColDataHover";
                        ld('[id="'+trs[i].id+'"]').removeClass("lvtColDataSelected");
                    }
                }
            }
        }
        else {
            var rows = "row_" + sel_id.value;
            ld("tr[id^=" + rows + "]").attr('class', 'lvtColDataHover');
            //if( document.getElementById(rows) != undefined){
            //	document.getElementById(rows).className = "lvtColDataHover";
            //}
        }
    }
    if(ld('#ld_listviewabtnrely')){

        List_CheckBox_Ids.getIds(module);
        var rows_num = List_CheckBox_Ids.num_rows;
        if(ld('#ld_listviewabtnrely').find('.ld_listviewchosenum .chosenum')){
            ld('#ld_listviewabtnrely').find('.ld_listviewchosenum .chosenum').html(rows_num);
        }

        if(popupobj.type && popupobj.type == 'listpage'){
            if(rows_num > 0){
                ld('#ld_listviewabtnrely').css('top','0px').css('opacity','1').css('z-index','1');
            }else{
                ld('#ld_listviewabtnrely').css('top','-50px').css('opacity','0').css('z-index','-1');
                toggleSelectAll_Records();
            }
        }
    }
    //edit:can reason:16147: 银行初始化>序时簿,关于提示信息中的单据数量与提交的数量不符的问题
    //注释了一下代码
    /*
    var allselectedboxes = $("allselectedboxes").value;

	var str = [];
	var allselectedboxesarr = allselectedboxes.split(';');
	for(var i = 0,len = allselectedboxesarr.length;i < len;i++){

		!RegExp(allselectedboxesarr[i],"g").test(str.join(";")) && (str.push(allselectedboxesarr[i]));
	}

	if(!empty(str))
		$("allselectedboxes").value = str.join(";")+';';
	else
		$("allselectedboxes").value = '';*/

}

function update_selected_checkbox() {
    var cur = document.getElementById('current_page_boxes').value;
    var tocheck = document.getElementById('allselectedboxes').value;
    var cursplit = new Array();
    cursplit = cur.split(";");

    var selsplit = new Array();
    selsplit = tocheck.split(";");

    //	var n=selsplit.length;
    var selectCurrentPageRecCheckValue = true;
    for (var j = 0; j < cursplit.length; j++) {
        if (selsplit.indexOf(cursplit[j]) != "-1") {
            document.getElementById(cursplit[j]).checked = 'true';
        }
        else {
            selectCurrentPageRecCheckValue = false;
        }
    }
    if (selectCurrentPageRecCheckValue && cursplit.length > 0) {
        document.getElementById('selectCurrentPageRec').checked = 'true';
    }
}

function showDefaultCustomViews(selectView, module, parenttab, viewid, otherurl='') {
    var wareid = 0;

    /*
    edit:chj
    date:2013-11-26
    reson:出入库  仓库检索后，数据分类没有根据仓库条件检索
    */
    if (module == 'Stock' || module == 'OutboundOrder' || module == 'InventoryQuery' || module == 'InventoryAccount') {
        var wareid = document.getElementById("wareid").value;
    }

    ld("#createCategory").parent().find("li[tag=firstnode]").css("background-color", "");
    ld("#createCategory").parent().find("li[tag=firstnode]").find("a").css("color", "#555");

    if (document.getElementById("SmOwnerSearchScope") != null)
        var searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    else
        var searchScope = '';

    var viewName = encodeURIComponent(viewid);
    if (module == 'Accounts'||module == 'Leads')
        var customtype = document.massdelete.publicaccounttype.value;
    if (module == 'WorkReportList')
        var workreport_logtype = ld('#workreport_logtype').val();

    var divid = 'pagecontent1';
    //分页
    var popupobj = CrmPopup.getPopupObj('last');
    if (module == 'Calendar' && popupobj != undefined && popupobj.pagetype == 'calendarview'){//日程管理 日历视图 查询分类
        ld('#'+popupobj.divid).find('[name=viewname]').val(viewid);
        if (typeof calendar != 'undefined'){
            popupobj.clearHighSearch = 'yes';
            calendar.refetchEvents();
        }
        return false;
    }
    else if (module == "Users") {
        divid = 'pagecontent1';
        Op_UserGroup.listparams['CustomViewObj'] = selectView;
        Op_UserGroup.listparams['viewid'] = viewid;
        var liobj = ld("#ListViewContents [viewid=" + viewid + "]");
        var parentul = liobj.parent();
        parentul.find("li").each(function () {
            if (ld(this).attr("viewid") == viewid) {
                ld(this).addClass("currdataClass");
            }
            else {
                ld(this).removeClass("currdataClass");
            }

        });
        var listPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
        var user_type = 'crm';
        if(listPopupobj.user_type){
            user_type = listPopupobj.user_type;
        }
        //35223: 单据列表：基本查找，录入查找内容并查找后。切换数据分类时，应该清空基本查找和高级查找的查找内容。
        var listpageurl = "module=" + module + "&action=" + module + "Ajax&file=ListView&start=1&viewname=" + viewName + "&switchview=" + viewName + "&query_session=0&parenttab=" + parenttab + "&SearchScope=" + searchScope + "&groupid=" + Op_UserGroup.curr_group_obj.record+"&user_type="+user_type;
    }
    else if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
        var listpageurl = "module=" + module + "&action=" + module + "Ajax&file=ListView&isshowModuleListTree=yes&start=1&viewname=" + viewName + "&switchview=" + viewName + "&query_session=0&parenttab=" + parenttab + "&SearchScope=" + searchScope + "&accounttype=" + customtype + "&waretype=" + wareid + "&wareid=" + wareid;
    }
    else{
        var listpageurl = "module=" + module + "&action=" + module + "Ajax&file=ListView&start=1&viewname=" + viewName + "&switchview=" + viewName + "&query_session=0&parenttab=" + parenttab + "&SearchScope=" + searchScope + "&accounttype=" + customtype + "&waretype=" + wareid + "&wareid=" + wareid + "&workreport_logtype=" + workreport_logtype;
    }
    listpageurl += otherurl;
    var listview_page = new ListView_Page(module, listpageurl, divid);



    listview_page.callback_fun = function () {
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.listresizeobj == undefined){
            popupobj=CrmPopup.getPopupObj('lastprev');
        }
         popupobj.listresizeobj.setReiszeTable_Init(module, 'ajax');
        setContentHeight(module);//计算内容高度
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.searchtype = "";

        if (module == 'Accounts') {
            IsFrameElement();
        }

        
   
    }
    listview_page.page();
    var iskanbanshow=ld('#iskanbanshow').val();
    if (iskanbanshow == 'yes'){
        ld('[name=customview_oplist_div]').find('li').removeClass();
        ld(selectView).addClass('activecustomview');
        var customlabel = ld(selectView).data('customlabel');
        ld('#showCustomlist_new').find('[name=showCustomlist_viewname]').html(customlabel);
        ld('#shujufenlei_new_optionlistbg').css('display','none');
        ld('#showCustomlist_new').unbind('mouseover').bind('mouseover',function (event) {
            ld('#shujufenlei_new_optionlistbg').css('display','');
        });
        ld('#showCustomlist_new').unbind('mouseleave').bind('mouseleave',function (event) {
            ld('#shujufenlei_new_optionlistbg').css('display','none');
        });
    }
}

/*
popup数据分类
BY LD Can
20140214
*/
function showDefaultCustomViewPopups(selectView, module, parenttab, viewid, noewviewid) {
    var popupobj = CrmPopup.getPopupObj("last");
    
    var divid = popupobj.divid;
    //window.event? window.event.cancelBubble = true : e.stopPropagation();
    var frommodule = '';
    if (viewid == '') 
        viewid = CrmPopup.findHtmlobj(divid, 'viewname').val();
    //edit: cyb date:2016-08-11 reason:关联选择客户服务单弹出窗口数据分类报错；
    if (document.getElementById('srcmodule') != undefined && document.getElementById('srcmodule').value != '') {
        frommodule = document.getElementById("srcmodule").value;
    }
    if (document.getElementById('frommodule') != undefined && document.getElementById('frommodule').value != '') {
        frommodule = document.getElementById("frommodule").value;
    }
    if (document.getElementById("popupfrommodule") != undefined && document.getElementById("popupfrommodule").value != '')
        frommodule = document.getElementById("popupfrommodule").value;

    var popuptype = document.getElementById("popup_type").value;
    var popupform = document.getElementById("popupform").value;
     CrmPopup.findHtmlobj(divid,'selectcustomview_'+module).val(viewid);
    CrmPopup.findHtmlobj(divid, 'viewname').val(viewid);
    var viewName = encodeURIComponent(viewid);
    //  var urlstring = fun_setCrmPopupWindow._popup_url.replace("searchvalue","chenghuangjian");
    // urlstring+="viewname="+viewName+"&SearchScope=SmOwner_Search_All&ajax=true&page_popup=yes&start=1&forfield=related_to";

    var urlstring = "module=" + module + "&action=" + module + "Ajax&file=Popup&ajax=true&page_popup=yes&start=1&forfield=related_to&viewname=" + viewName + "&parenttab=" + parenttab + "&SearchScope=SmOwner_Search_All" + "&form=" + popupform + "&popuptype=" + popuptype;

    if (frommodule != '') {
        urlstring = urlstring + "&frommodule=" + frommodule
    }

    if (document.getElementById('returnmodule') != undefined) {

        urlstring = urlstring + "&return_module=" + document.getElementById('returnmodule').value;
    }
    if (document.getElementById("popupselect") != undefined && document.getElementById("popupselect").value != '') {
        urlstring = urlstring + '&select=' + document.getElementById("popupselect").value;
    }
    /*
    *@edit:andy
    *@reason:0008559: 联系人：录入“上级联系人”时，结果只能录入与客户名称关联的联系人。
    *@data:20140505
    *@others:NONE;
    */
    if (module != 'Contacts') {
        if (document.getElementById('account_id') != undefined && trim(document.getElementById('account_id').value) != '') {
            urlstring = urlstring + '&accountid=' + trim(document.getElementById('account_id').value);
        }
    }
    if (document.getElementById('vendor_id') != undefined && trim(document.getElementById('vendor_id').value) != '') {
        urlstring = urlstring + '&vendorid=' + trim(document.getElementById('vendor_id').value);
    }
    if (document.getElementById("wareid") != undefined && trim(document.getElementById("wareid").value) != '') {
        urlstring = urlstring + "&waretype=" + trim(document.getElementById("wareid").value);
    }
    if (module == 'Products') {
        urlstring = urlstring + '&curr_row=' + document.getElementById('curr_row').value;
    }
    if (document.getElementById('listval') != undefined)//28015: pc端新建出库单，保存后在编辑出库单，在加一个该客户名称下的，源单（合同订单）选择其他的数据分类后，之前保存的源单就被替换掉了，就只有刚刚选的源单了
        urlstring += '&listval=' + document.getElementById('listval').value;
    //32415: 销售发票明细界面：选择源单-服务合同/合同订单：选择数据分类，结果无法选中
    ld("#showCustomlist [name=cmb_span_optiontext_selectcustomview_" + module + "]").val(selectView.innerHTML);
    var createEditPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);

    // @edit:liushuai,2020-09-25,reason:0042757: （http://xiaoshou360.com/KH/hutongle [^]）施明程客户问题，营销>群发短信>选择“客户”：点击“+”选择客户，“数据分类”选择“潜在客户”一直“转圈”(上一弹框非新增编辑界面)
    var  requestvalues="";
    var sensitiverequestfield = '';
    if (createEditPopupobj !== undefined) {
        var requestvaluearr = getPageValueByCrmPopupFields(createEditPopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
    }
	//zkt 20240703 BUG20240702-08  标准产品设置了共享规则（倍络得只能看物料归属是倍络得，达立可以看物料归属是倍络得和达立的），数据范围调整了个人，标准产品模块查不到但是在销售订单还是能选到权限外的产品：linjingqi是倍络得的不应该看到1开头的达立的产品 
    if(typeof popupobj.fieldname!= 'undefined' && !empty(popupobj.fieldname))
        urlstring += "&fieldname="+popupobj.fieldname;
    if(typeof popupobj.selectrelationfrom!= 'undefined' && !empty(popupobj.selectrelationfrom))
        urlstring += "&selectrelationfrom="+popupobj.selectrelationfrom;
         
   urlstring+="&requestvalues="+encodeURIComponent(requestvalues);
   urlstring+="&sensitiverequestfield="+sensitiverequestfield;
    if(!empty(popupobj.extral_url)){
        urlstring+=popupobj.extral_url;
    }
   //zkt 模块树结构显示增加条件，获取树结构点击条件——选择产品界面
    if((ld("#"+divid+" [name=isshowPopupModuleListTree]")!=undefined&&ld("#"+divid+" [name=isshowPopupModuleListTree]").val()=='yes'))
     {
        urlstring += '&isshowModuleListTree=yes';
     }

    //ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
    if (popupobj.popuptype == 'AccountsChart'){
        urlstring += popupobj.relationshipChartobj.AccountsChartUrl;
    }
    ldAjaxHtml('index.php',urlstring,function (ajaxhtml){
        DelProgressObjs();
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        CrmPopup.findHtmlobj(divid, 'ListViewContents').html(ajaxhtml);
        ld(".Category ul li.currdataClass").attr('class', 'divView');
        var basicsearchcolumns = CrmPopup.findHtmlobj(divid, 'basicsearchcolumns').html();
        CrmPopup.findHtmlobj(divid, 'basicsearchcolumns_real').html(basicsearchcolumns);
        CrmPopup.findHtmlobj(divid, 'basicsearchcolumns').html('');
        ld('#' + viewid + 'popup').parent().attr('class', 'currdataClass');
        //wym 231215 BUG0076884 选择产品-树结构选择一个分类，勾选产品后切换树结构分类，列表下侧出现空白部分
        if(ld('#'+popupobj.divid+'_fullscreen')){
            var pop_switchtotype = ld('#'+popupobj.divid+'_fullscreen').attr('switchtotype');
            if(pop_switchtotype=='recovery'){
                popupobj.Fullscreencallback('fullscreen');
            }else{
                popupobj.Fullscreencallback('recovery');
            }
        }else{
            //wym 选择源单弹出层会自适应宽度，与全屏功能冲突
            popupobj.setSelectPopupListSize();
        }
        popupobj.center();
        CrmPopup.findHtmlobj(divid, 'search_text').val('');
        // getJsScript('include/js/resizetable.js', function () {
        var listresizeobj=new List_ResizeTable(popupobj);
        popupobj.listresizeobj=listresizeobj;
        ld("input[name=cmb_span_optiontext_selectcustomview_" + module + "]").val(selectView.innerHTML);//群发短信-》选择客户-》选择数据分类后赋值
        listresizeobj.setPopupResizeTable_Init(module, 'Ajax');
        //});
        ////下面是关闭数据分类下拉框
        CrmPopup.findHtmlobj(divid, 'dv_chzn_selectcustomview_' + module).attr('class', 'chzn-container chzn-container-single');
        CrmPopup.findHtmlobj(divid, 'cmb_a_selectcustomview_' + module).attr('class', 'chzn-single');
        CrmPopup.findHtmlobj(divid, 'dv_drop_selectcustomview_' + module).css('left', '-9000px');
        fun_setCrmPopupWindow.setCheckBoxEvent(popupobj);//设置checkbox事件
        fun_setCrmPopupWindow.setCheckBoxPropselected(popupobj);//记住上次选中产品或原单
        //duan 20230407 增加特殊回调事件,用于重新绑定选择按钮事件
        fun_setCrmPopupWindow.OtherReturnFun(popupobj);
        // ljj 20231102 XUQIU1001640 选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
        if(popupobj.module != 'Products' && empty(popupobj.isMultiple)) {
            getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
                var PopupProductListDoubleClick = new PopupProductListDoubleClicks(popupobj);
                PopupProductListDoubleClick.setProductListDoubleClickEvent();
            });
        }
    });
}

function MergeCreate(module) {

    if (ld('input[name=selected_id]').length > 0) {
        if (0 == ld('input[name=selected_id]:checked').length) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
          var objparams=new CreatePagePopup.params();
            objparams.params['refreshpage']='no';
        var merval = ld('#allselectedboxes').val();
        if (merval == 'all') {
            var viewname = ld('#viewname').val();
            var SearchScope = ld('#SmOwnerSearchScope').val();
           var tmpurl='&merge=yes&select_id=' + merval + '&viewname=' + viewname + '&SearchScope=' + SearchScope;

    
        } else {
            var tmpurl='&merge=yes&select_id=' + merval;
        }
        CreatePagePopup.showpage("SalesOrder",tmpurl,objparams);
    }

}
//列表 推进漏斗
function AdvanceStageHighcharts(module){
    EmptyProgressObjs();
    ld(' .list-item span').removeClass('cur');
    //ld(' .list-item span i.funnel-btn').parent().addClass('cur');

    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=ListViewAdvanceStageCharts';
    var params = '';//参数  这个参数要传到点击事件中  穿透的时候直接用这个参数

    // alert(searchtype_btn);
    // if(!empty(searchtype_btn)){
    //     surl += '&'+getUrlString(searchtype_btn);
    //     surl += "&query=true&ajax=true&search=true";
    // }
    //基本、高级查询条件
    //zxm BUG0069763 kfbcrm，“销售机会”模块，看板试图，点击进度漏斗，没有反应
    if (typeof ld('#search_url') != 'undefined' && ld('#search_url').val() != '' && ld('#search_url').val() != undefined){
        surl += ld('#search_url').val();
        params += ld('#search_url').val();
    }
    //BUG0062681 zxm 20230309 kfbcrm 出库单---切换不同仓库---点击销售漏斗---统计的数据一直是全部仓库
    if(module=='Stock'||module=='OutboundOrder'){
        surl += "&wareid="+ld('#wareid').val();
        params += "&wareid="+ld('#wareid').val();
    }
    //zxm BUG0063845  序时簿列表界面，选择树结构设置中的一个状态后，进度漏斗统计的数据没有跟随变化
    var isshowModuleListTree = ld('#isshowModuleListTree').val();
    surl += '&isshowModuleListTree='+isshowModuleListTree;
    params += '&isshowModuleListTree='+isshowModuleListTree;
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
    ldAjaxNoProgress(surl,"",function(data) {
        crmPopupobj.prevshow();
        if (data.code == 1) {
            var stage_data = data.result.stage_values;
            crmPopupobj.setParams(data.result.title, '', "", "LdPopWidth1100px", module, "", '', "", '', "");
            var _content = '<div id="advance_stage_charts_div" style="overflow-y: auto; overflow-x:hidden;width:100%;height:420px;margin: 20px auto;"></div>';
            crmPopupobj.show(_content);

            // @edit:liushuai,2021-04-13,reason:【ID1001430】单据序时簿列表界面，进度漏斗增加级联字段【上级字段】
            if (!empty(data.result.list)){  //有上级字段才显示
                var select_content = '<span class="E_ptita" style="margin-left: 50px;">'+data.result.prev_advance_fieldlabel+' </span><select class="commonSelectPop width150" style="margin-top: 17px;margin-left: 10px;" name="select_stage_value" onchange="AdvanceStageHighchartsBySelect(\''+module+'\',\''+surl+'\');">\n';
                //select_content += "<option value=''></option>";//BUG20240906-49 改成默认选择第一个选项 空选项去掉
                ld.each(data.result.list,function(index,info){
                    select_content +=  "<option value='"+index+"'>"+info+"</option>\n";
                });
                select_content += '</select>';
                ld("#" + crmPopupobj.divid + "_head").children(":first").after(select_content);
                ld("#" + crmPopupobj.divid + "_head .E_pop_tit_Second_Right").css('width','100px');
                ld("#" + crmPopupobj.divid + "_head .E_pop_tit_Second_Right").css('float','right');
            }
            //zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
            let noAlertOfSalestage = '<input id="noAlertOfSalestage" value="yes" type="hidden">';
            ld("#" + crmPopupobj.divid + "_head").children(":first").after(noAlertOfSalestage);
            StageHighcharts(stage_data,module,data.result.title,params);
        }
        DelProgressObjs();
    });
}

function StageHighcharts(stage_data,module,popuptitle,paramsstr) {
//zxm 2021-0309 highcharts改成echarts
    var myChart = echarts.init(document.getElementById('advance_stage_charts_div'),echartTheme);
    myChart.clear();
    var charReportdata = [];//内容
    var legend_data = [];
    // if (stage_data['count'] == undefined) {
    //wyt_220706_XUQIU1000477_销售机会漏斗表 旁边显示各阶段的百分占比
    if (empty(stage_data.title)) {
        audioRemindsMsg("","","","","",arrJsPopLabel['MISSCASCADEFIELD']);
    }else{
        for (var i = 0; i < stage_data['count'].length; i++) {
            var temp = {};
            temp.name = stage_data['title'][i] + ':' + stage_data['count'][i] + '('+ stage_data['totalcount'][i] +')' ;
            legend_data[i] = temp['name'];
            //temp.value = (1 - 0.2 * i) * 100;
            //漏斗宽度限制
            var widthnum;
            if(stage_data['count'].length<=5){
                widthnum = 5;
            }else if(stage_data['count'].length>10){
                widthnum = 10;
            }else{
                widthnum = stage_data['count'].length;
            }

            temp.value = (10-10/stage_data['count'].length*i)* widthnum;
            charReportdata[i] = temp;
        }
    }
    var grid = {
        left: '3%',
        right: '4%',
        bottom: '15%',
        top: '5%',
        containLabel: true
    };
    var option = {
        grid: grid,
        series: [
            {
                type:'funnel',
                left: '5%',
                top: 0,
                bottom: 10,
                width: '90%',
                min: 0,
                max: 100,
                minSize: '0',
                maxSize: '100%',
                sort: 'descending',
                gap: 0,
                label: {
                    show: true,
                    position: 'inside'
                },
                labelLine: {
                    length: 10,
                    lineStyle: {
                        width: 1,
                        type: 'solid'
                    }
                },
                itemStyle: {
                    borderColor: '#fff',
                    borderWidth: 1
                },
                emphasis: {
                    label: {
                        fontSize: 15
                    }
                },
                data: charReportdata
            }
        ]
    };
    myChart.setOption(option);
    myChart.off('click').on('click', function (params) {
        showPotentialsStageListData(stage_data['title'][params.dataIndex],1,'',module,stage_data['title'][params.dataIndex],popuptitle,paramsstr);
    });
}
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
function showPotentialsStageListData(stage_name,start,oldcustomer_name,module,advance_stage,popuptitle,paramsstr){
	var popupobj = CrmPopup.getPopupObj('lastprev');
	//var viewid=ld("#"+popupobj.divid+' [name=selectcustomview_'+module+']').val();
    var url2 = "index.php?module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start="+start+"&query=true&searchtype=advance&listoperationtype=page";

    // if(!empty(searchtype_btn)){
    //     url2 += '&'+getUrlString(searchtype_btn);
    //     url2 += "&query=true&ajax=true&search=true";
    // }
    //基本、高级查询条件
    if (typeof ld('#search_url') != 'undefined' && ld('#search_url').val() != ''){
        url2 += ld('#search_url').val();
    }
    //zxm 20240605 漏斗穿透 带查询分类条件
    var viewname = ld('#viewname').val();
    url2 += '&viewname='+viewname;
    url2 += '&keyviewname='+viewname;
    if(module == 'Accounts'||module == 'Leads') {
        var customtype = '';
        if (document.massdelete != undefined && document.massdelete.publicaccounttype != undefined) {
            customtype = document.massdelete.publicaccounttype.value;
        }
        url2 += '&pagepublicaccounttype=' + customtype;
        var pool_id = ld("#" + popupobj.divid + " [name=pool_id]").val();
        url2 += '&pool_id=' + pool_id;
    }
    //BUG0062681 zxm 20230309 kfbcrm 出库单---切换不同仓库---点击销售漏斗---统计的数据一直是全部仓库
    if(module=='Stock'||module=='OutboundOrder'){
        url2 += "&wareid="+ld('#wareid').val();
    }
    url2 += '&fromtype=salesfunnel';
    if(stage_name!=''&&stage_name!=undefined){
        if(module=='Potentials'){
            url2 += '&sales_stage='+stage_name;
        }
        url2 += '&advance_stage='+advance_stage;
    }
    if(oldcustomer_name!=''&&oldcustomer_name!=undefined&&module=='Potentials'){
        url2 += '&oldcustomer_marketing='+oldcustomer_name;
    }
    var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
    url2 += '&SearchScope='+SmOwnerSearchScope;
    //级联字段
    var select_stage_value = ld('select[name="select_stage_value"]').val();
    if(select_stage_value!=''&&select_stage_value!=undefined){
        url2 += '&select_stage_value='+select_stage_value;
    }
    //zxm BUG0063845  序时簿列表界面，选择树结构设置中的一个状态后，进度漏斗统计的数据没有跟随变化
    var isshowModuleListTree = ld('#isshowModuleListTree').val();
    url2 += '&isshowModuleListTree='+isshowModuleListTree;
    var Popupobj = CrmPopup.load(popuptitle,'',"","LdPopWidth1400px", module, "", "", "", '');
    Popupobj.isShowFullscreen='yes';
    this.penetratePopupObj = Popupobj;
    ldAjaxHtml(url2,paramsstr,function(data){
        Popupobj.setParams(popuptitle,'','', "LdPopWidth1400px",module,"" ,'',"", '');
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        data = data.replace("&#&#&#&#&#&#",'');
        //main_grid_top  Statistics
        Popupobj.pagetype = 'advance_stage_chuantou';
        //分页块
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data);
        //默认全屏
        Popupobj.switchFullscreen();
        ld("#"+Popupobj.divid+' #resize_header_tableid').css('width',ld("#"+Popupobj.divid).width()+'px');
        ld("#"+Popupobj.divid+' #resize_content_tableid').css('width',ld("#"+Popupobj.divid).width()+'px');
        Popupobj.center();
        Popupobj.refreshurl=url2;
        Popupobj.refresh='yes';
        Popupobj.ajaxtype='html';
        Popupobj.splitstr="&#&#&#&#&#&#";
        Popupobj.ajaxparam=[];
        Popupobj.stage_name=stage_name;
        Popupobj.oldcustomer_name=oldcustomer_name;
        Popupobj.htmlDivid="#"+Popupobj.divid+"_scroll";
        var listresizeobj=new List_ResizeTable(Popupobj);
        Popupobj.listresizeobj=listresizeobj;
        Popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
        Popupobj.ajaxcallback=function(Popupobj){
            var  divid = Popupobj.divid;
            var stage_name_input = '<input id="stage_name_input" value="'+Popupobj.stage_name+'" type="hidden">';
            ld("#" + divid + "_head").children(":first").after(stage_name_input);
            var oldcustomer_name_input = '<input id="oldcustomer_name_input" value="'+Popupobj.oldcustomer_name+'" type="hidden">';
            ld("#" + divid + "_head").children(":first").after(oldcustomer_name_input);
            var PageDiv0 = ld('#'+divid+' .PageDiv0')[0];
            // hzx 翻页样式优化
            ld('#'+divid+' .main_grid_top').empty().removeClass('main_grid_top').addClass('main_grid_salestage').css('height','0px');
            //ld('#'+divid+' .PageDiv0').css('float','left');//zxm 20220113 靠右
            ld('#'+divid+' .Statistics').remove();
            var maxwidth=document.body.clientWidth;
            //zxm 	BUG0065511	20230505 图表长度超过屏幕宽度
            ld('#'+divid).css('left',0);
            ld('#'+divid).find('.dvpopupsroll').css('max-width',maxwidth+'px').css('overflow-x','auto');
            Popupobj.center();
            //zkt 20231101 BUG0073797 kfbcrm-销售机会-销售漏斗-穿透弹出层中拖动修改列宽，拖动的是弹出层的宽度
            ld("#" +divid).css("width",ld("#" + divid).css("width"));
            //var windowHeight = CrmPopup.getClientHeight();
            //ld("#" +divid).find('#resize_content_table_divid').css('height', (windowHeight - 160) + 'px').css('max-height', (windowHeight - 200) + 'px');
            //ld("#" +divid).find('.dvpopupsroll').css('height', (windowHeight - 60) + 'px').css('max-height', (windowHeight - 60) + 'px');
        }
        Popupobj.ajaxcallback(Popupobj);
        Popupobj.Fullscreencallback=function (switchtotype) {
            if(switchtotype == 'fullscreen'){
                var popHeight =ld("#"+Popupobj.divid).outerHeight(true);
                var popheadHeight =ld("#"+Popupobj.divid+'_head').outerHeight(true);
                var tableheadHeight =ld("#"+Popupobj.divid+' #resize_header_table_divid').outerHeight(true);
                var pageHeight =ld("#"+Popupobj.divid+' #listviewpagination').outerHeight(true);
                var contentheight = parseInt(popHeight)-parseInt(tableheadHeight)-parseInt(pageHeight)-parseInt(popheadHeight)-1;
                ld("#"+Popupobj.divid+' #resize_content_table_divid').css('height',contentheight+'px');
            }else{
                ld("#"+Popupobj.divid+' #resize_content_table_divid').css('height','300px');
            }
        }
        Popupobj.Fullscreencallback('fullscreen');
    });
}

// @edit:liushuai,2021-04-13,reason:【ID1001430】单据序时簿列表界面，进度漏斗增加级联字段【上级字段】
function AdvanceStageHighchartsBySelect(module,surl) {
    var crmPopupobj = CrmPopup.getPopupObj("last");
    var select_stage_value = ld("#" + crmPopupobj.divid + " [name=select_stage_value]").val();
    surl += "&select_stage_value="+select_stage_value;
    ldAjax(surl,'',function(data){
        if (data.code == 1) {
            var stage_data = data.result.stage_values;
            StageHighcharts(stage_data,module,data.result.title,'');
        }
        DelProgressObjs();
    });
}

/**
 * @edit:dong
 * @data:2020/09/14
 * @reason:【单据序时簿列表和单据查看详情界面更多中增加【下载全部附件】功能】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001001089
 * @description: 附件批量下载
 */
function DownLoadAllAttachment(module,setype,records){
    getAllAttachmentZip(module,setype,records)
}

function getAllAttachmentZip(module,setype,records){
    var that =this;
    this.module = module;
    if(records == undefined || records==''){
        this.select_options = $('allselectedboxes').value;
        List_CheckBox_Ids.getIds(this.module)
        if(this.select_options == 'all'){
            this.selectidstring='all';
        }else{
            this.selectidstring =List_CheckBox_Ids.ids;
        }
    }else{
        this.selectidstring = records;
    }
    this.setype = setype;
    this.createFileAjax ='';
    this.eachExportNum = 1; //每次导出数量
    this.times =1; //第几次导出
    this.selectcount=0;

    this.init = function () {
        if(!that.alertRemindsMsg()){
            return false
        }else{
            that.createExportProgress();
        }
    }
    this.alertRemindsMsg= function () {
        // list_view和detail_view 的selectidstirng 不一样， list 以;结尾  detail的只有单个数字没有符号
        if(that.selectidstring != ''){
            if(that.selectidstring.slice(-1) == ';'){
                that.selectcount = that.selectidstring.slice(0,-1).split(';').length;
            }else{
                that.selectcount = that.selectidstring.split(';').length;
            }
        }
        if(that.selectcount == 0){
            MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEENTITY']);
            // getJsScript('include/js/MsgPopup.js', function () {
            //     RemindsMsg("","LdPopWidth400px",module,"","",arrJsPopLabel['PLEASESELECTONEENTITY']);
            // });
            return  false;
        }else{
            return  true;
        }
    }
    this.createExportProgress = function () {
        var createUrl ='index.php?module='+module+'&action='+module+'Ajax&file=ExportAllAttachment&search_type='+that.select_options+'&idstring='+that.selectidstring+'&setype='+that.setype+'&times=0&eachExportNum=0&getprogress=yes';
        ldAjaxNoProgress(createUrl,'',function (data) {
            if (data.code == 1) {
                ld('#rptContentLoading').hide();
                var crmPopupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth600px", module, "", '', "", "");
                crmPopupobj.show(data.result.content);
                ld("#"+crmPopupobj.divid+" #dvctimedescription").html(data.result.timedescription);
                //点击关闭 停止ajax
                document.getElementById(crmPopupobj.divid + "_imgclose").onclick = function () {
                    crmPopupobj.CancelEvent();
                    that.stop();
                    if (that.createFileAjax != '') {
                        that.createFileAjax.abort();
                    }
                }
                that.createZipFile(data.result);
            }else if(data.code == -1){ //暂不支持选择全部单据
                getJsScript('include/js/MsgPopup.js', function () {
                    RemindsMsg('',"LdPopWidth400px",'','yes','',data.result.error);
                });
            }else if(data.code == -2){ //所选单据没有附件
                getJsScript('include/js/MsgPopup.js', function () {
                    RemindsMsg('',"LdPopWidth400px",'','yes','',data.result.error);
                });
            }else if(data.code == 0){ //没有操作权限 //没有附件查看权限
                RemindsMsg("","LdPopWidth400px",that.module,"","",data.result.error);
            }
        });
    }
    this.createZipFile = function(result){
        var createUrl ='index.php?module='+module+'&action='+module+'Ajax&file=ExportAllAttachment&search_type='+that.select_options+'&idstring='+that.selectidstring+'&setype='+that.setype+'&times='+that.times+'&eachExportNum='+that.eachExportNum+'&getprogress=yes';
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   createUrl += '&isshowModuleListTree=yes';
    	}
        that.createFileAjax = ldAjaxNoProgress(createUrl,{attachments:JSON.stringify(result.attachments),listcounts:JSON.stringify(result.listcounts),log:JSON.stringify(result.log),failNum:JSON.stringify(result.failNum),successNum:JSON.stringify(result.successNum),tableCode:JSON.stringify(result.tableCode),zipName:JSON.stringify(result.zipName)},function (data) {
            if(data.code ==1){
                var width = (that.times*that.eachExportNum)/that.selectcount*100;
                if(width >100){
                    width=100;
                }
                ld("#dvctimedescription").html(data.result.timedescription);
                ld("#dvExportprogress").css("width", width+'%');
                if(data.result.complete =='yes'){
                    // 关闭进度条弹出层
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    // 弹窗显示压缩结果
                    that.showLogAndDown(data.result);
                }else{
                    that.times++
                    that.createZipFile(data.result);
                }
            }
        });

    }
    this.showLogAndDown = function (restobj) {
        // 压缩文件不存在，不下载
        if(restobj.zipfileStatus =='yes'){
            var downLoadUrl = 'index.php?module=uploads&frommodule='+that.module+'&action=downloadLocalFile&pathfile='+restobj.zipfile;
            //zkt 20231013 XUQIU1001341 SQL注入
            downLoadUrl= cls_encryptyurl.Puyoung_Encryptyurl(downLoadUrl,'');
            window.location.href=downLoadUrl;
        }
        resultRemindsMsg(restobj.downLogTitle, "LdPopWidth600px", "", "yes", "yes", restobj.log);
        //附件批量下载后刷新列表页
        var tmparra=new Array();
        var tmpobj= new AfterUpdatePrevPopupObjContent(that.module,getEmptyValueInfo(),tmparra);
        var refreshmodules=[];
        refreshmodules.push(that.module);
        tmpobj.eachrefreshlistbyModules(refreshmodules);
		var  popupobj = CrmPopup.getPopupObj("last");
		if(ld("#"+popupobj.divid+ ' [tag=reference_list]') != undefined){
			ld("#"+popupobj.divid+ ' [tag=reference_list]').unbind("click").bind("click",function(event){
				DetailViewReferenceLinkClick(ld(this),event);
			});
		}
    }

    this.stop=function(){
        var url ='index.php?module='+module+'&action='+module+'Ajax&file=ExportAllAttachment&search_type=stop';
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,'',function (data) {

        });
    }

    this.init();
}
// end 附件批量下载