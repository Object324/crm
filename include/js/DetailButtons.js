/**
 * 按钮事件
 * @author Tujt 2015-06-03
 */
function detailbuttons_click(obj,module,setype,record){   
	var url = '';var tag = ld(obj).attr('tag');
    
    if(setype=='More') return false;
    EmptyProgressObjs();
	if('Accounts' == module){//客户特别字段
		var is_bool = 1;
		switch (setype){
		    case 'turnhighseas'://转公海
				detailconvertaccount(record,1);
				break;
			case 'turnordinary'://转普通
				detailconvertaccount(record,0);
				break;
			case 'massallocate'://公海-公海未分配-批量分配
				massDeskAllocatetaccountDetails(obj,record);
				break;
			case 'public_ordinary'://客户-新建-普通用户
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=0';
				redirect(url);
				break;
			case 'public_notallocated'://客户-新建-公海未分配
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=1';
				redirect(url);
				break;
			case 'public_allocated'://客户-新建-公海已分配
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=2';
				redirect(url);
				break;
			case 'receive'://客户-公海未分配-领取
				AllocatetaccountDetails(record,'3');
				break;
			case 'accountrelease'://客户-公海已分配-释放
				Releaseaccount('1',record);
				break;
			case 'accountdelay'://客户-公海已分配-延期
				DeskDelayaccount('1',record,obj,'delayaccount');
				break;
			default:
				is_bool = 0;
		}
		if(1 == is_bool) return false;
	}else if('Leads' == module){
		var is_bool = 1;
		switch (setype){
			case 'turnhighseas'://转公海
			case 'turnordinary'://转普通
				//getJsScript('include/js/modules/Leads/Leads.js',function(){
				
					PublicLeadsObj.account_transfer(record);
			//	});
				break;
			case 'massallocate'://公海-公海未分配-批量分配
			//	getJsScript('include/js/modules/Leads/Leads.js',function(){
					
					PublicLeadsObj.massDeskAllocatetaccountDetails(obj,record);
			//	});
				break;
			case 'public_ordinary'://客户-新建-普通用户
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=0';
				redirect(url);
				break;
			case 'public_notallocated'://客户-新建-公海未分配
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=1';
				redirect(url);
				break;
			case 'public_allocated'://客户-新建-公海已分配
				url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=2';
				redirect(url);
				break;
			case 'receive'://销售线索-公海未分配-领取
				PublicLeadsObj.AllocatetaccountDetails(record,'3');
				break;
			case 'accountrelease'://销售线索-公海已分配-释放
				PublicLeadsObj.Releaseaccount('1',record);
				break;
			case 'accountdelay'://销售线索-公海已分配-延期
				PublicLeadsObj.DeskDelayaccount('1',record,obj,'delayaccount');
				break;
			default:
				is_bool = 0;
		}
		if(1 == is_bool) return false;
	}
  
    switch (setype){
		case "reCalculationBudget":
			//详情页页的重算预算金额 费用预算单
			ExpenseBudgetObj.reCalculationBudgetDetail(record);
			break;
       	case 'Print':
        PrintPopup.showpopup();
        break;
        //朗捷特殊功能 报关订单->发送邮件->自动邮件主题+Excel格式的报关单草单
		case 'ExportCustomsOrderEmail':
			exportCustomsOrderEmail(module,record,setype);
			break;
        case 'Back'://返回列表
            var result_aprove_type=getUrlParam('result_aprove');
			//if(ld('#result_aprove').val() == 1||ld('#result_aprove').val()==2){//审批中心点击进来，返回审批中心
            if(result_aprove_type==1 || result_aprove_type==2|| result_aprove_type==4){//Liver 2017-02-09 审批中心点击进来，返回审批中心
				url = 'module=Approve&action=ListView&fromapprovemodule='+module+'&fromcalenar='+fromcalendar+"&approvestatus="+(parseInt(result_aprove_type)-1);
				redirect(url);
			}else{//返回列表
               var pagefrom=getUrlParam('pagefrom');
               if(pagefrom=='quicksearch')
               {
                	url = 'module='+module+'&action=UnifiedSearch&quick_query_session=1&fromcalenar='+fromcalendar;
               }
               if(fromcalendar=='yes')
               {
                	url = 'module='+module+'&action=index&quick_query_session=1&fromcalenar='+fromcalendar;
               }
               else
               {
                	url = 'module='+module+'&action=ListView&query_session=1&fromcalenar='+fromcalendar;
               }
			
				redirect(url);
			}
			break;
		case 'zf_Changecf_2444':
            var tmpobj=new   Changezh_cf_2444();//edit:can 2020-08-27 中孚修改发货单的签回
            tmpobj.showpopup();
            break;
		case 'DownloadSelected': //// @edit:dong @date:2020/09/16 @reason: 下载全部附件
			DownLoadAllAttachment(module,setype,record)
			break;
		case 'Create'://创建
		  
            CreatePagePopup.showpage(module,"",new CreatePagePopup.params());
			//redirect(url);
			break;
        case 'moduledetailEdit':
        	//明细界面编辑按钮
            url = 'module=' + module + '&action=EditView&return_action=DetailView&return_id=' + record + '&record=' + record;
            // PC端+微信端：模块单据提交审批后，系统应该做实时判断
            ld.ajax({
                url: 'index.php?module=Users&action=UsersAjax&file=callStaticMethod&static=puyoung&method=checkEditInfo&fld_module=' + module + "&record=" + record,
                type: 'POST',
                data: {"namename": "uname", "namenameage": 18},
                async: true,//
                timeout: 10000,
                success: function (rest) {
                    var  restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.check === 'SUCCESS') {
                        //editor:gyq_161 reason:带分录模块弹出层   2019/11/20 16:59
                       /* var Popupobj = PageRecordPopup.loadobj("", "", "", "LdPopWidth950px", module, "", "", "", "", record);
                        Popupobj.prevshow();
                        let redirectUrl = '&return_action=DetailView&return_id=' + record ;
                        PageRecordPopup.showpage(module, record, redirectUrl);*/
                        
                        //用户查看界面的编辑
                        redirect(url);
                    }
                    else {
                        // RemindsMsg("", "LdPopWidth400px", module, "yes", "", restobj.check);
						MessagePopup.TipOne_warning(restobj.check);
                        return false;
                    }
                },
            });
            break;
		case 'Edit'://编辑
         var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
         Popupobj.prevshow();
         PageRecordPopup.params['refreshpage']='no';
         PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);
		//	url = 'module='+module+'&action=EditView&return_action=DetailView&return_id='+record+'&record='+record;
			//redirect(url);
			break;
        case 'Close'://关闭
           closeclick_update(obj,module,record,'DetailView');
            break;
        /*
        * editor:gyq_07
        * reason:重新绑定分配事件，调用修改创建人方法
        * date  : 2016 3 11
        * */
		case 'Allocate'://分配
            //getJsScript('include/js/ListViewButton.js',function(){
                ChangeCreator(obj,module,'Allocate','detail',record);
          //  });
			//detail_mass_edit(obj,'smowneredit',module,'','smowner');
			break;
		case 'approve'://审批
			approveBlocks(record,module,obj,'ApproveBlocks');
			break;
        case 'expediting'://催审
			approveExpediting(record,module,obj);
			break;
		case 'submit'://提交审批
			submitapprove(obj,'SubmitApprove',module,record);
			break;
         case 'approve_retrace'://回撤
            approveretraceOperation();
            break;
		/* editor:gyq_09 reason:派息按钮事件  date:2016 4 5*/
		case 'dividend_rules':
            getJsScript('include/js/modules/Products/ProductsDividendRules.js',function(){
				Products_dividendRules.getInstance().Buttons_dividendRules(obj,module,record);
			});
			break;
		case 'cancel'://反审批
			cancelApproved(record,module,obj,'cancelApproved','1');
			break;
		case 'add_moduledata_tag':
			getJsScript('include/js/moduledata_tag.js',function(){
				moduledata_tag.add(module,record);
			});
			break;
        case 'moduledetailCopy':
            url = 'module='+module+'&action=EditView&return_action=DetailView&isDuplicate=true&record='+record;
            redirect(url);
            break;
		case 'Copy'://复制
			//url = 'module='+module+'&action=EditView&return_action=DetailView&isDuplicate=true&record='+record;
            var objparams=new CreatePagePopup.params();
            //edit:can 2021-01-12 044219: （61mis.com/kfbcrm）OA表单-常用审批单-详情-复制；复制常用审批单保存后，没有自动打开新保存的单据
            objparams.params['isduplicate']='yes';
			objparams.params['copyid']=record;
            CreatePagePopup.showpage(module,"&record="+record+"&isDuplicate=true",objparams);
			//redirect(url);
			break;
		case 'MenuStyle':	//菜单风格
			var urlstring = 'index.php?module=Users&action=UsersAjax&file=setMenuStype';//wym XUQIU1002004 放开权限，所有人都可以设置，文件从setting移动到了users下
			var crmPopupobj_home=CrmPopup.load("","","","LdPopWidth600px",'Home',"","","","");
			crmPopupobj_home.prevshow();
			ldAjax(urlstring,"",function(data){
				if(data.code == 1){
					crmPopupobj_home.setParams(data.result.title,saveMenuStyleColpick,"","LdPopWidth450px","Home","",data.result.oktext,"",data.result.canceltext,"");  
					crmPopupobj_home.show(data.result.content);
					ld('#'+crmPopupobj_home.divid+' div[name^=menustyle_]').unbind('click').bind('click',function(){
						ld('#'+crmPopupobj_home.divid+' [name^=menustyle_].checkMenuStyle').removeClass('checkMenuStyle');
						ld(this).addClass('checkMenuStyle');
					});
					ld('#'+crmPopupobj_home.divid+' div[name^=menubackground_]').unbind('click').bind('click',function(){
						ld('#'+crmPopupobj_home.divid+' [name^=menubackground_].checkMenuStyle').removeClass('checkMenuStyle');
						ld(this).addClass('checkMenuStyle');
					});
					crmPopupobj_home.center();
					//恢复默认：默认深色
					ld("#"+crmPopupobj_home.divid+" [name=defaultcolpick_menuback],[name=defaultcolpick_menuhover]").unbind('click').on('click',function(){
						var css_type = ld(this).attr('tag');
						var _color = '';
						if(css_type == 'menuback'){	//背景色 18223d FFFFFF 2e68db
							_color = '#2e68db';
						}else if(css_type == 'menuhover'){	//选中色 2490f8 F3F3FC 2a83e8
							_color = '#2a83e8';	
						}
						if(css_type=='menuback'){
							var colorPreviewobj = ld("#"+crmPopupobj_home.divid+" #colorPreview");
							colorPreviewobj.css('background-color',_color);
						}
						if(CrmPopup.findHtmlobj(crmPopupobj_home.divid,'input_'+css_type).val() != undefined){
							CrmPopup.findHtmlobj(crmPopupobj_home.divid,'input_'+css_type).val(_color);
						}
						if(CrmPopup.findHtmlobj(crmPopupobj_home.divid,'div_'+css_type).val() != undefined){
							CrmPopup.findHtmlobj(crmPopupobj_home.divid,'div_'+css_type).css('background',_color);
						}
						//wym 240507 BUG20240507-32 头像右上角->皮肤定制->自定义，点击恢复默认，下方的预览图片也应该自动选中（否则保存后，界面会误认为没有生效）
						ld('#'+crmPopupobj_home.divid+' [name^=menustyle_].checkMenuStyle').removeClass('checkMenuStyle');
						ld("#" + crmPopupobj_home.divid + " [name=menustyle_custom]").addClass('checkMenuStyle');
					})

					//切换字体，默认勾选自定义预览框 wym 240507 BUG20240507-32（否则保存后，界面会误认为没有生效）
					ld("#"+crmPopupobj_home.divid+" [name=input_menufont]").unbind('change').on('change',function(){
						ld('#'+crmPopupobj_home.divid+' [name^=menustyle_].checkMenuStyle').removeClass('checkMenuStyle');
						ld("#" + crmPopupobj_home.divid + " [name=menustyle_custom]").addClass('checkMenuStyle');
					})

					//选择背景色弹出层
					ld("#"+crmPopupobj_home.divid+" [name=div_menuback],[name=div_menuhover]").unbind('click').on('click',function(){
						var colpick_num = 1;
						var css_type = ld(this).attr('tag');
						getJsScript('include/js/colpick/colpick.js',function(){
							getJsScript('include/js/colpick/plugin.js',function(){
								ld('#rptContentLoading').show();
								var surl='module=Users&action=UsersAjax&file=SelectColppick&css_type='+css_type;
								var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
								var _css_type = CrmPopup.findHtmlobj(crmPopupobj_home.divid,'input_'+css_type).val();
								crmPopupobj.prevshow();
								ld.ajax({
									url: 'index.php?'+surl,
									type: 'POST',
									data:'',
									dataType:'json',
									async: true,//
									timeout: 5000,
									success: function(data)
									{
										
										if(data.code==1)
										{
											//approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
											//EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
											ld('#rptContentLoading').hide();
											crmPopupobj.setParams(data.result.title,'',"","LdPopWidth350px",'Settings',"",'',"",'');  
											crmPopupobj.show(data.result.content);
											var divid = crmPopupobj.divid;
											CrmPopup.findHtmlobj(divid,'picker').colpick({
												color:_css_type,

												flat:true,

												layout:'RGB',

												submitText:'确认',

												onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
													var _color = '#'+hex;
													CrmPopup.findHtmlobj(crmPopupobj_home.divid,'input_'+css_type).val(_color);
													CrmPopup.findHtmlobj(crmPopupobj_home.divid,'div_'+css_type).css('background',_color);
													//wym XUQIU1002004 预览框
													if(css_type=='menuback'){
														var colorPreviewobj = ld("#"+crmPopupobj_home.divid+" #colorPreview");
														colorPreviewobj.css('background-color',_color);
													}
													//wym BUG20240407-34 自定义选中颜色后自动勾选预览框设置成自定义颜色
													ld('#' + crmPopupobj_home.divid + ' [name^=menustyle_].checkMenuStyle').removeClass('checkMenuStyle');
													ld("#" + crmPopupobj_home.divid + " [name=menustyle_custom]").addClass('checkMenuStyle');
													crmPopupobj.CancelEvent();
												}

											});
											var windowWidth = document.documentElement.clientWidth;   

											var windowHeight = document.documentElement.clientHeight;
											if(colpick_num == 1)
												var popupHeight = ld('#'+divid).height()-126;
											else{
												var popupHeight = ld('#'+divid).height();   
											}
											colpick_num++;
											var popupWidth = ld('#'+divid).width();   

											ld('#'+divid).css({   
											"position": "fixed",   
											"top": (windowHeight-popupHeight)/2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
											"left": (windowWidth-popupWidth)/2   
											});

										}
									}
								});
							});
						})
					})

					//增加页签 如果设置的是自定义外观，页签保持在自定义页面
					var StuffNavBarList = [];
					var NavBarSelKey=0;
					StuffNavBarList[0] = { label:arrJsPopLabel['presetappearance'], selected: 'yes' , id:'preset_appearance'};
					StuffNavBarList[1] = { label:arrJsPopLabel['presetbackground'], selected: 'no' , id:'preset_background'};
					StuffNavBarList[2] = { label:arrJsPopLabel['customappearance'], selected: 'no' , id:'custom_appearance'};
					if(data.result.menustyle=='custom'){
						NavBarSelKey=2;
						StuffNavBarList[0] = { label:arrJsPopLabel['presetappearance'], selected: 'no' , id:'preset_appearance'};
						StuffNavBarList[2] = { label:arrJsPopLabel['customappearance'], selected: 'yes' , id:'custom_appearance'};
					}
					var LayoutObj = ld('#'+crmPopupobj_home.divid +' .salestarget-tab');
					AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
					ld_NavBar.ShowNavBar(LayoutObj.get(0),StuffNavBarList,{
						NavBarSelKey : NavBarSelKey,
						NavBarItemWidth: '160px',
						OnClick : function(evt){
							var menusettingobj = ld("#"+crmPopupobj_home.divid+" .settingPopTable");
							ld.each(menusettingobj,function(){
								var tmpmenusetting=ld(this).data('setting');
								if(tmpmenusetting==evt.NavBarItem.id){
									ld(this).css('display','');
								}else{
									ld(this).css('display','none');
								}
							});
						},
					});

					//颜色预览添加keyup事件
					ld('#'+crmPopupobj_home.divid+' #colorPicker').unbind('keyup').bind('keyup',function(){
						var precolor=ld(this).val();
						var colorPreviewobj = ld("#"+crmPopupobj_home.divid+" #colorPreview");
						colorPreviewobj.css('background-color',precolor);
					});
				}
			});
			break;
        //服务小程序
        case 'SELFSERVICEQRCODE':
            //防止点击太快，出现多个弹窗
            if(ld(obj).attr('repeat')=='yes'){
                return false;
            }
            ld(obj).attr('repeat','yes');
            //editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/26 16:32
            ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record},function(response){
				var res_obj = eval('(' + response + ')');
                 //随机数
				var number =  Math.floor((Math.random() * 10000) + 1);
				//去除response字符串中空格
                var filename = res_obj.result.filename;
				var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
				var tmp_msg = res_obj.msg;
				var tmp_button = '';
				var tmp_width = '90%';
				var tmp_style = '';
                if(res_obj.code==-1){
				 	if(res_obj.result.role=='admin'){
						tmp_width = '70%';
						tmp_button = '<div class="wxsettingbg"><tr><td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'service\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td></tr></div>';
                    }else{
						tmp_style = 'style="justify-content: center;"';
						// tmp_button = '<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>';
                    }
                    //RemindsMsg("","LdPopWidth400px","","yes","",tmp_msg);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : 'warmprompt',
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "重试",
						CancelText : '',
						ContentText : tmp_msg,
						setTime : 0,
					};
					Messageobj.createcontenthtml = function(){
						this.content_alert = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
							+'<div class="ld-msgDlg-Boxtop">'
							+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
							+'</div>'
							+'<div class="ld-msgDlg-Boxbottom bgF2F3F8" '+tmp_style+'>'
							+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width:'+tmp_width+';">'+tmp_msg
							+'</div>'
							+tmp_button
							+'</div>'
							+'</div>'
							+'</div>';
					}
					Messageobj.CommonRemindsMsg(data_arr);
					var popupobj = CrmPopup.getPopupObj("last");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").removeAttr("onclick");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
						ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record},function(response){
							var res_obj = eval('(' + response + ')');
							//随机数
							var number =  Math.floor((Math.random() * 10000) + 1);
							//去除response字符串中空格
							var filename = res_obj.result.filename;
							var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
							var tmp_msg = res_obj.msg;
							var tmp_button = '';
							var tmp_width = '90%';
							var tmp_style = '';
							if(res_obj.code==-1){
								if(res_obj.result.role=='admin'){	
									tmp_width = '70%';
									tmp_button = '<div class="wxsettingbg"><tr><td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'service\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td></tr></div>';
								}else{
									tmp_style = 'style="justify-content: center;"';
									// tmp_button = '<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>';
								}
								var content = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
									+'<div class="ld-msgDlg-Boxtop">'
									+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
									+'</div>'
									+'<div class="ld-msgDlg-Boxbottom bgF2F3F8" '+tmp_style+'>'
									+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: '+tmp_width+';">'+tmp_msg
									+'</div>'
									+tmp_button
									+'</div>'
									+'</div>'
									+'</div>';
								ld("#" + popupobj.divid + ' .pop_remind_content').html(content);
							}else{
								popupobj.CancelEvent();
								var confirm_str ='<table class="settingPopTable lasttdbordernon pad10 wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
								//当用户角色为管理员时可以看到小程序设置
								if(res_obj.result.role=='admin'){
									confirm_str +='<tr>'
										+'<td style="text-align:right"><div class="wxsettingbg successwxshopway"><a target="_blank" onclick="window.open(\'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=SelfServiceConfig&menufile=SelfServiceConfig&page_addurl=service\')" title="'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'</a></div></td>'
										+'</tr>';
								}
								confirm_str +='<tr>'
									+'<td class="ctextalign">'
									+'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 140px;padding: 0 10px 10px 10px;">'
									+'<p style="width: center;height:25px;line-height: 25px;">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
									+'</div></td>'
									+'</tr>';
								confirm_str += "</table>";
								var Messageobj  = MessagePopup.load('','','','','','');
								var data_arr = {
									headtitle : arrJsPopLabel['SELFSERVICEQRCODE'],
									headicon : 'tips',
									tipsicon : "warning",
									Okfun : '',
									Cancelfun : '',
									cssWidth : "LdPopWidth400px",
									module : '',
									OkText : "yes",
									CancelText : 'yes',
									ContentText : confirm_str,
									setTime : 0,
								};
								Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
								Messageobj.CommonRemindsMsg(data_arr);
								ld('.qui_dialog_body').hide();
								ld('.ww_dialog_foot').hide();
								//延迟500毫秒显示弹出框内容
								setTimeout(() => {
									ld('.pop_remind_content').html(confirm_str);
								}, 500);
								ld(obj).attr('repeat','no');
							}
						});

					});
                    ld(obj).attr('repeat','no');
                    return false;
                }else {
					var confirm_str ='<table class="settingPopTable lasttdbordernon pad10 wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
					//当用户角色为管理员时可以看到小程序设置
					if(res_obj.result.role=='admin'){
						confirm_str +='<tr>'
									+'<td style="text-align:right"><div class="wxsettingbg successwxshopway"><a target="_blank" onclick="window.open(\'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=SelfServiceConfig&menufile=SelfServiceConfig&page_addurl=service\')" title="'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'</a></div></td>'
									+'</tr>';
					}
					confirm_str +='<tr>'
								+'<td class="ctextalign">'
								+'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 140px;padding: 0 10px 10px 10px;">'
								+'<p style="width: center;height:25px;line-height: 25px;">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
								+'</div></td>'
								+'</tr>';
                    confirm_str += "</table>";
                    //RemindsMsg(arrJsPopLabel['SELFSERVICEQRCODE'],"LdPopWidth400px",'',"yes","yes",confirm_str);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : arrJsPopLabel['SELFSERVICEQRCODE'],
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "yes",
						CancelText : 'yes',
						ContentText : confirm_str,
						setTime : 0,
					};
					Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
					Messageobj.CommonRemindsMsg(data_arr);
                    ld('.qui_dialog_body').hide();
                    ld('.ww_dialog_foot').hide();
                    //延迟500毫秒显示弹出框内容
                    setTimeout(() => {
                        ld('.pop_remind_content').html(confirm_str);
                    }, 500);
                    ld(obj).attr('repeat','no');
                }
            });
            break;
        //商城小程序
		case 'SELFSHOPQRCODE':
			//防止点击太快，出现多个弹窗
			if(ld(obj).attr('repeat')=='yes'){
				return false;
			}
			ld(obj).attr('repeat','yes');
			ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record,selftype:'shop'},function(response){
				var res_obj = eval('(' + response + ')');
				if(res_obj.code==-1){
					if(res_obj.result.isPermitted=='yes'){
						tmp_msg = res_obj.msg;
						tmp_button = '<td style="text-align:right"><a target="_blank" style="padding-left: 5px;" onclick="window.open(\'index.php?pageto_module=ShopSettings&pageto_action=index&pageto_menufile=InterfaceSettings\')" title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</a></td>';
					}else{
						tmp_msg = res_obj.msg;
						tmp_button = '<td style="text-align:right"><title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</td>';
					}
					//RemindsMsg("","LdPopWidth450px","","yes","",tmp_msg);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : 'warmprompt',
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "重试",
						CancelText : '',
						ContentText : tmp_msg,
						setTime : 0,
					};
					Messageobj.createcontenthtml = function(){
						this.content_alert = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
							+'<div class="ld-msgDlg-Boxtop">'
							+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
							+'</div>'
							+'<div class="ld-msgDlg-Boxbottom bgF2F3F8">'
							+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: 70%;">'+tmp_msg
							+'</div>'
							+'<div class="wxsettingbg">'
							+'<tr>'
							+tmp_button
							+'</tr>'
							+'</div>'
							+'</div>'
							+'</div>'
							+'</div>';
					}
					Messageobj.CommonRemindsMsg(data_arr);
					var popupobj = CrmPopup.getPopupObj("last");
					//给商城小程序重试按钮重新绑定事件
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").removeAttr("onclick");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
						ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record,selftype:'shop'},function(response){
							var res_obj = eval('(' + response + ')');
							if(res_obj.code==-1){
								if(res_obj.result.isPermitted=='yes'){
									tmp_msg = res_obj.msg;
									tmp_button = '<td style="text-align:right"><a target="_blank" onclick="window.open(\'index.php?pageto_module=ShopSettings&pageto_action=index&pageto_menufile=InterfaceSettings\')" title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</a></td>';
								}else{
									tmp_msg = res_obj.msg;
									tmp_button = '<td style="text-align:right"><title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</td>';
								}
								var content = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
									+'<div class="ld-msgDlg-Boxtop">'
									+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
									+'</div>'
									+'<div class="ld-msgDlg-Boxbottom bgF2F3F8">'
									+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: 70%;">'+tmp_msg
									+'</div>'
									+'<div class="wxsettingbg">'
									+'<tr>'
									+tmp_button
									+'</tr>'
									+'</div>'
									+'</div>'
									+'</div>'
									+'</div>';
								ld("#" + popupobj.divid + ' .pop_remind_content').html(content);
							}else{//重试按钮点击成功生成二维码
								popupobj.CancelEvent();
								var number =  Math.floor((Math.random() * 10000) + 1);//随机数
								var filename = res_obj.result.filename;//去除response字符串中空格
								var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
								var confirm_str = '<table class="settingPopTable lasttdbordernon pad10" border="0" cellpadding="0" cellspacing="0" width="100%">';
								//当用户模块权限，以及模块打开的情况下
								if(res_obj.result.isPermitted=='yes'){
									confirm_str +='<tr>'
										+'<td style="text-align:right"><a target="_blank" onclick="window.open(\'index.php?pageto_module=ShopSettings&pageto_action=index&pageto_menufile=InterfaceSettings\')" title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</a></td>'
										+'</tr>';
								}
								confirm_str +='<tr>'
									+'<td class="ctextalign">'
									+'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 180px;padding: 0 10px 10px 10px;">'
									+'<p style="width: center;height:25px ">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
									+'</div></td>'
									+'</tr>';
								confirm_str += "</table>";
								var Messageobj  = MessagePopup.load('','','','','','');
								var data_arr = {
									headtitle : arrJsPopLabel['SELFSHOPQRCODE']+" - "+res_obj.result.username,
									headicon : 'tips',
									tipsicon : "warning",
									Okfun : '',
									Cancelfun : '',
									cssWidth : "LdPopWidth400px",
									module : '',
									OkText : "yes",
									CancelText : 'yes',
									ContentText : confirm_str,
									setTime : 0,
								};
								Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
								Messageobj.CommonRemindsMsg(data_arr);
								ld('.qui_dialog_body').hide();
								ld('.ww_dialog_foot').hide();
								//延迟500毫秒显示弹出框内容
								setTimeout(() => {
									ld('.pop_remind_content').html(confirm_str);
								}, 500);
								ld(obj).attr('repeat','no');
							}
						});

					});
					ld(obj).attr('repeat','no');
					return false;
				}else {
					var number =  Math.floor((Math.random() * 10000) + 1);//随机数
					var filename = res_obj.result.filename;//去除response字符串中空格
					var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
					var confirm_str = '<table class="settingPopTable lasttdbordernon pad10 wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
					//当用户模块权限，以及模块打开的情况下
					if(res_obj.result.isPermitted=='yes'){
						confirm_str +='<tr>'
							        +'<td style="text-align:right"><div class="wxsettingbg successway"><a target="_blank" onclick="window.open(\'index.php?pageto_module=ShopSettings&pageto_action=index&pageto_menufile=InterfaceSettings\')" title="'+res_obj.result.modulename+'">'+res_obj.result.modulename+'</a></div></td>'
							        +'</tr>';
					}
					 confirm_str +='<tr>'
						 		 +'<td class="ctextalign">'
						         +'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 140px;padding: 0 10px 10px 10px;">'
						         +'<p style="width: center;height:25px;line-height: 25px; ">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
						         +'</div></td>'
						         +'</tr>';
					 confirm_str += "</table>";
					//新弹窗界面必须有提示icon，单纯把icon隐藏界面不好看，所以只能用以前的方法
					/*var Messageobj  = MessagePopup.load('','','','','','');
					var pop_data_arr = {
						headtitle : arrJsPopLabel['SELFSHOPQRCODE']+" - "+record,
						headicon : '',
						tipsicon : '',
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : 'yes',
						CancelText : 'yes',
						ContentText : confirm_str,
						setTime : 0,
					};
					Messageobj.CommonRemindsMsg(pop_data_arr);
					ld('.ld-msgDlg-top-icon').hide();*/
					//RemindsMsg(arrJsPopLabel['SELFSHOPQRCODE']+" - "+res_obj.result.username,"LdPopWidth400px",'',"yes","yes",confirm_str);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : arrJsPopLabel['SELFSHOPQRCODE']+" - "+res_obj.result.username,
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "yes",
						CancelText : 'yes',
						ContentText : confirm_str,
						setTime : 0,
					};
					Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
					Messageobj.CommonRemindsMsg(data_arr);
					ld('.qui_dialog_body').hide();
					ld('.ww_dialog_foot').hide();
					//延迟500毫秒显示弹出框内容
					//BUG0071334 先缩短延迟时间,试试效果
					setTimeout(() => {
						ld('.pop_remind_content').html(confirm_str);
					}, 200);
					ld(obj).attr('repeat','no');
				}
			});
			break;
		case 'TUOZHANCODE':	//东贸：拓展码
			var confirm_str = '<table id="card_qrcode_content" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">';
			var surl = "index.php?module=Users&action=UsersAjax&file=mini_get_qrcode_dongmao&record="+record;
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					var crmPopupobj_home=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
					crmPopupobj_home.prevshow();
					//去除response字符串中空格
					var filename = data.result.filename;
					confirm_str += '<tr>'
						+ '<td class="ctextalign" colspan="4"><div style="margin:20px;">';
					var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
					confirm_str += '<img src="./' + fieldname + '" style="width: 180px;padding: 0 10px 10px 10px;">';
					confirm_str += '<p style="text-align: center;">' + arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN'] + '</p>'
						+ '</div></td>'
						+ '</tr>';
					confirm_str += "</table>";
                    crmPopupobj_home.setParams('拓展码',"","","LdPopWidth400px","Users","","","","","");
                    crmPopupobj_home.show(confirm_str);
                    crmPopupobj_home.center();
				}
			});
			break;
		//电子名片
		case 'CARDQRCODE':
        getJsScript("include/js/modules/Settings/OrganizationConfig.js",function(){
            //防止点击太快出现多个弹框
            if(ld(obj).attr('repeat')=='yes'){
                return false;
            }
            ld(obj).attr('repeat','yes');
           	var confirm_str = '<table id="card_qrcode_content" class="settingPopTable lasttdbordernon wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
			ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record,selftype:'card'},function(response){
				var res_obj = eval('(' + response + ')');
				var current_user_id = res_obj.result.current_user_id
				var tmp_msg = '';
				var tmp_button = '';
				var tmp_width = '90%';
				var tmp_style = '';
				if(res_obj.code==-1){
					tmp_msg = res_obj.msg;
					if(res_obj.result.role=='admin'){
						tmp_width = '70%';
						tmp_button = '<div class="wxsettingbg"><tr><td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'service\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td></tr></div>';
                    }else{
						tmp_style = 'style="justify-content: center;"';
                    }
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : 'warmprompt',
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "重试",
						CancelText : '',
						ContentText : tmp_msg,
						setTime : 0,
					};
					Messageobj.createcontenthtml = function(){
						this.content_alert = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
							+'<div class="ld-msgDlg-Boxtop">'
							+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
							+'</div>'
							+'<div class="ld-msgDlg-Boxbottom bgF2F3F8" '+tmp_style+'>'
							+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: '+tmp_width+';">'+tmp_msg+'</div>'
							+tmp_button
							+'</div>'
							+'</div>'
							+'</div>';
					};
					Messageobj.CommonRemindsMsg(data_arr);
					var popupobj = CrmPopup.getPopupObj("last");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").removeAttr("onclick");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
						ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',record:record},function(response){
							popupobj.CancelEvent();
							detailbutton_click('','Users','CARDQRCODE',current_user_id);return false;
						});

					});
                    ld(obj).attr('repeat','no');
                    return false;
				}else {
					//随机数
					var number =  Math.floor((Math.random() * 10000) + 1);
					//zkt 0046681: PC端->右上角用户信息->电子名片->提示设置界面点击“确定”或者“取消”按钮界面都一直转圈出错
                    //原来load位置有误
				    var crmPopupobj_home=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
                    crmPopupobj_home.prevshow();
					//去除response字符串中空格
					var filename = res_obj.result.filename;
					confirm_str += '<tr>'
						+ '<td class="ctextalign" colspan="4"><div style="margin:20px;">';
					var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
					confirm_str += '<img src="./storage/weixinqrcode/' + fieldname + '?a='+number+'" style="width: 180px;height:170px;padding: 0 10px 10px 10px;">';
					confirm_str += '<p style="text-align: center;margin-top: 5px;">' + arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN'] + '</p>'
						+ '</div></td>'
						+ '</tr>';
                    //当用户角色为管理员时可以看到电子名片有关公司简介等信息及其设置
                    if(res_obj.result.role=='admin'){
                        confirm_str +='<tr>'
						+'<td align="right" style="font-size: 14px;width: 25%;">'+arrJsPopLabel['ABOUTUS']+'</td>'
						+'<td align="left"><i class="ld-fonticon ld-fonticon-edit" href="javascript:;" onclick="OrganizationConfig.aboutusedit()" title="'+arrJsPopLabel['Configure']+'"></i></td>'
						+'<td align="right" style="font-size: 14px;width: 25%;">'+arrJsPopLabel['PRODUCTINTRODUCTION']+'</td>'
						+'<td align="left"><i class="ld-fonticon ld-fonticon-edit" href="javascript:;" onclick="OrganizationConfig.productview()" title="'+arrJsPopLabel['Configure']+'"></i></td>'
						+'</tr>';
						/*confirm_str +='<tr>'
							+'<td><a href="index.php?pageto_module=CardSettings&pageto_action=index&pageto_menufile=CardInfoSettings" target="_blank" style="display: block; text-align: center;" title="'+arrJsPopLabel['CardSettings']+'">'+arrJsPopLabel['CardSettings']+'</a></td>'
							+'</tr>';*/
                    }
					confirm_str += "</table>";
                    crmPopupobj_home.setParams(arrJsPopLabel['CARDQRCODE'],"","","LdPopWidth400px","Users","",arrJsPopLabel['CONFIRMED'],"",arrJsPopLabel['CANCEL'],"");
                    //延迟500毫秒显示弹出层内容
                    setTimeout(() => {
                        crmPopupobj_home.show(confirm_str);
                    }, 500);
                    crmPopupobj_home.center();
                    ld(obj).attr('repeat','no');
				}
			});
        });
		break;
		case 'SELFORDERQRCODE':
        //防止点击太快，重复打开弹窗
            if(ld(obj).attr('repeat')=='yes'){
                return false;
            }
            ld(obj).attr('repeat','yes');
            //editor:gyq_108 reason:订单小程序  2019/4/17 10:18
            ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',
				module:'Users',action : 'UsersAjax',record:record,selftype:'order'},function(response){
            	var res_obj = eval('(' + response + ')');
                //随机数
				var number =  Math.floor((Math.random() * 10000) + 1);
                //去除response字符串中空格
                var filename = res_obj.result.filename;
				var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
                if(res_obj.code==-1){
					 if(res_obj.result.role=='admin'){
                        tmp_msg = res_obj.msg+'<tr>'
                                +'<td style="text-align:right"><a href="javascript:void();" onclick="edit_miniprogrambytype(\'order\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td>'
                                +'</tr>';
                    }else{
                        tmp_msg = res_obj.msg+'<tr>'
                                +'<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>'
                                +'</tr>';

                    }
                    RemindsMsg("","LdPopWidth400px","","yes","",tmp_msg);
                    ld(obj).attr('repeat','no');
                    return false;
                }else {
                    var confirm_str ='<table class="settingPopTable lasttdbordernon pad10" border="0" cellpadding="0" cellspacing="0" width="100%">'
                        +'<tr>'
                        +'<td class="ctextalign">'
                        +'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 180px;padding: 0 10px 10px 10px;">'
                        +'<p style="width: center;height:25px">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
                       	+ '</div></td>'
    					+ '</tr>';
                    //当用户角色为管理员时可以看到订单小程序设置
                    if(res_obj.result.role=='admin'){
                            confirm_str +='<tr>'
                            +'<td style="text-align:right"><a target="_blank" onclick="window.open(\'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=SelfServiceConfig&menufile=SelfServiceConfig&page_addurl=order\')" title="'+arrJsPopLabel['LBL_ORDER_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBL_ORDER_MINI_SETTINGS1']+'</a></td>'
                            +'</tr>';
                            }
                    confirm_str += "</table>";
                    //editor:gyq_20190424 reason:Label错误->SELFSERVICEQRCODEORDER
                    RemindsMsg(arrJsPopLabel['SELFSERVICEQRCODEORDER'],"LdPopWidth400px",'',"yes","yes",confirm_str);
                    ld('.qui_dialog_body').hide();
                    ld('.ww_dialog_foot').hide();
                    //延迟500毫秒显示弹出框内容
                    setTimeout(() => {
                        ld('.pop_remind_content').html(confirm_str);
                    }, 500);
                    ld(obj).attr('repeat','no');
                }     
            });
            break;
        case 'WECHATQRCODE':
        //防止点击太快，出现多个弹窗
            if(ld(obj).attr('repeat')=='yes'){
                return false;
            }
            ld(obj).attr('repeat','yes');
        	//微信小程序
			ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',
				module:'Users',action : 'UsersAjax',record:record,selftype:'weixin'},function(response){
            	var res_obj = eval('(' + response + ')');
                //随机数
				var number =  Math.floor((Math.random() * 10000) + 1);
                //去除response字符串中空格
                var filename = res_obj.result.filename;
                var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
				var tmp_msg = '';
				var tmp_button = '';
				var tmp_width = '90%';
				var tmp_style = '';
                if(res_obj.code==-1){
					tmp_msg = res_obj.msg;
                    if(res_obj.result.role=='admin'){
						tmp_width = '70%';
                        tmp_button = '<div class="wxsettingbg"><tr><td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'weixin\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td></tr></div>';
                    }else{
						tmp_style = 'style="justify-content: center;"';
						// tmp_button = '<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>';
                    }
	                    //RemindsMsg("","LdPopWidth400px","","yes","",tmp_msg);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : 'warmprompt',
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "重试",
						CancelText : '',
						ContentText : tmp_msg,
						setTime : 0,
					};
					Messageobj.createcontenthtml = function(){
						this.content_alert = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
							+'<div class="ld-msgDlg-Boxtop">'
							+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
							+'</div>'
							+'<div class="ld-msgDlg-Boxbottom bgF2F3F8" '+tmp_style+'>'
							+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: '+tmp_width+';">'+tmp_msg
							+'</div>'
							+tmp_button
							+'</div>'
							+'</div>'
							+'</div>';
					}
					Messageobj.CommonRemindsMsg(data_arr);
					var popupobj = CrmPopup.getPopupObj("last");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").removeAttr("onclick");
					ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
						ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',
							module:'Users',action : 'UsersAjax',record:record,selftype:'weixin'},function(response){
							var res_obj = eval('(' + response + ')');
							//随机数
							var number =  Math.floor((Math.random() * 10000) + 1);
							//去除response字符串中空格
							var filename = res_obj.result.filename;
							var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
							var tmp_msg = '';
							var tmp_button = '';
							var tmp_width = '90%';
							var tmp_style = '';
							if(res_obj.code==-1){
								tmp_msg = res_obj.msg;
								if(res_obj.result.role=='admin'){
									tmp_width = '70%';
									tmp_button = '<div class="wxsettingbg"><tr></tr><td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'weixin\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td></tr></div>';
								}else{
									tmp_style = 'style="justify-content: center;"';
									// tmp_button = '<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>';
								}
								var content = '<div class="qui_dialog_body ld-dialog-Boxbody ld-wechat-miniprogram" style="background-color: #fff;">'
									+'<div class="ld-msgDlg-Boxtop">'
									+'<div class="ld-commonImg ld-noqrcode-alertimg ld-msgDlg-top-icon"></div>'
									+'</div>'
									+'<div class="ld-msgDlg-Boxbottom bgF2F3F8" '+tmp_style+'>'
									+'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px;width: '+tmp_width+';">'+tmp_msg
									+'</div>'
									+tmp_button
									+'</div>'
									+'</div>'
									+'</div>';
								ld("#" + popupobj.divid + ' .pop_remind_content').html(content);
							}else{
								popupobj.CancelEvent();
								var confirm_str ='<table class="settingPopTable lasttdbordernon pad10 wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
								//当用户角色为管理员时可以看到微信小程序设置
								if(res_obj.result.role=='admin'){
									confirm_str +='<tr>'
										+'<td style="text-align:right"><div class="wxsettingbg successway"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'weixin\')" title="'+arrJsPopLabel['LBI_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBI_MINI_SETTINGS1']+'</a></div></td>'
										+'</tr>';
								}
								confirm_str +='<tr>'
									+'<td class="ctextalign">'
									+'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 140px;padding: 0 10px 10px 10px;">'
									+'<p style="width: center;height:25px;line-height: 25px;">' +arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
									+'</div></td>'
									+'</tr>';
								confirm_str += "</table>";
								//RemindsMsg(arrJsPopLabel['WECHATAPPLETHEADER1'],"LdPopWidth400px",'',"yes","yes",confirm_str);
								var Messageobj  = MessagePopup.load('','','','','','');
								var data_arr = {
									headtitle : arrJsPopLabel['WECHATAPPLETHEADER1'],
									headicon : 'tips',
									tipsicon : "warning",
									Okfun : '',
									Cancelfun : '',
									cssWidth : "LdPopWidth400px",
									module : '',
									OkText : "yes",
									CancelText : 'yes',
									ContentText : confirm_str,
									setTime : 0,
								};
								Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
								Messageobj.CommonRemindsMsg(data_arr);
								ld('.qui_dialog_body').hide();
								ld('.ww_dialog_foot').hide();
								//延迟500毫秒显示弹出框内容
								setTimeout(() => {
									ld('.pop_remind_content').html(confirm_str);
								}, 500);
								ld(obj).attr('repeat','no');
							}
						});

					});
                    ld(obj).attr('repeat','no');
                    return false;
                }else {
                	var confirm_str ='<table class="settingPopTable lasttdbordernon pad10 wxprogram" border="0" cellpadding="0" cellspacing="0" width="100%">';
					//当用户角色为管理员时可以看到微信小程序设置
					if(res_obj.result.role=='admin'){
						confirm_str +='<tr>'
							+'<td style="text-align:right"><div class="wxsettingbg successway"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'weixin\')" title="'+arrJsPopLabel['LBI_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBI_MINI_SETTINGS1']+'</a></div></td>'
							+'</tr>';
					}
                    confirm_str +='<tr>'
                        +'<td class="ctextalign" style="padding-bottom: 0">'
                        +'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 140px;padding: 0 10px 10px 10px;">'
                        +'<p style="width: center;height:25px;line-height: 25px;">' +arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
                       	+'</div></td>'
                        +'</tr>';
                    confirm_str += "</table>";
					confirm_str += '<p style="text-align: center;height:25px;line-height: 25px;font-size: 16px;margin-bottom: 20px">' +res_obj.result.para_one_str+ '</p>';
                    //RemindsMsg(arrJsPopLabel['WECHATAPPLETHEADER1'],"LdPopWidth400px",'',"yes","yes",confirm_str);
					var Messageobj  = MessagePopup.load('','','','','','');
					var data_arr = {
						headtitle : arrJsPopLabel['WECHATAPPLETHEADER1'],
						headicon : 'tips',
						tipsicon : "warning",
						Okfun : '',
						Cancelfun : '',
						cssWidth : "LdPopWidth400px",
						module : '',
						OkText : "yes",
						CancelText : 'yes',
						ContentText : confirm_str,
						setTime : 0,
					};
					Messageobj.HeadIcon_change('ld-CRMmin-programIcon');
					Messageobj.CommonRemindsMsg(data_arr);
                    ld('.qui_dialog_body').hide();
                    ld('.ww_dialog_foot').hide();
                    //延迟500毫秒显示弹出框内容
                    setTimeout(() => {
                        ld('.pop_remind_content').html(confirm_str);
                    }, 500);
                    ld(obj).attr('repeat','no');
                } 
            });
            break;
		case 'ProductQrCode':
			//zxm 2021-0120【微信端：产品编码、选择产品、产品列表搜索增加扫码功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000730
			ld.post("index.php",{ajax:true,file:'ProductQrCode',module:'Products',action : 'ProductsAjax',record:record},function(response){
				var res_obj = eval('(' + response + ')');
				if(res_obj.code==-1){
					MessagePopup.TipOne_warning(res_obj.msg)
				}else {
					//去除response字符串中空格
					var popupobj = CrmPopup.load(arrJsPopLabel['PRODUCTQRCODE'],"","","LdPopWidth600px","Products","","","","");
					var qrcode = res_obj.result.qrcode;
					var barcode = res_obj.result.barcode;
					qrcode = qrcode.replace(/(^\s*)|(\s*$)/g, "");
					barcode = barcode.replace(/(^\s*)|(\s*$)/g, "");
					var confirm_str = '<table id="card_qrcode_content" class="ld-pop-container" border="0" cellpadding="0" cellspacing="0" width="100%">';
					confirm_str += '<tr>'
						+ '<div style="margin:0 80px;"><td class="ctextalign">';
					confirm_str += '<img src="' + barcode + '" style="width: 276px;padding: 0 8px 0 0;">';
					confirm_str += '<img src="' + qrcode + '" style="width: 276px;padding: 0 0 0 8px;">';
					confirm_str += '<p style="text-align: center;">' + arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN'] + '</p>'
						+ '</div></td>'
						+ '</tr>';
					confirm_str += "</table>";
					popupobj.show(confirm_str);
					var windowheight = CrmPopup.getClientHeight();
					var top = (windowheight-300)/2;
					ld('#'+popupobj.divid).css('top',top);
				}
			});
			break;
		case 'GeneratePaymentCode':
			//生成付款码
			//detailbutton_click(this,'WorkSheet','GeneratePaymentCode','299');return false;
			ld('#rptContentLoading').show();
			//XUQIU1001280 zxm 20230423 威奥轨道-小程序增加扫码付款功能
			var createtype = ld(obj).data('type');
			var tmpwidth = "600px";
			var GeneratePaymentCodeurl = "index.php?module="+module+"&action="+module+"Ajax&file=GeneratePaymentCode&frommodule="+module+"&record="+record+"&createtype="+createtype;
			ldAjaxNoProgress(GeneratePaymentCodeurl,{},function(ajaxdata) {
				var res = ajaxdata.result;
				if(ajaxdata.code==1) {
					if (createtype == 'reGeneratePaymentCode') {
						var popupobj = CrmPopup.getPopupObj("last");
						popupobj.show(res.content);
						ld('.E_pbtn').hide();
						ld('.msgDlg_left').hide();
					} else {
						var Popupobj = CrmPopup.load(res.title, '', "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
						Popupobj.setParams(res.title, '', '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
						Popupobj.createScrollDiv();//创建滚动条
						Popupobj.prevshow();
						Popupobj.setHeadTitle(res.title);
						Popupobj.show(res.content);
						ld('.E_pbtn').hide();
						ld('.msgDlg_left').hide();
					}

				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",ajaxdata.msg);
				}
				ld('#rptContentLoading').hide();
			});
			break;
		case 'AccountSelfserviceQRcode'://生成客户专属服务小程序码
			//防止点击太快，出现多个弹窗
            if(ld(obj).attr('repeat')=='yes'){
                return false;
            }
            ld(obj).attr('repeat','yes');
			var accountid = record;
            //editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/26 16:32
            ldAjaxHtmlNoProgress("index.php",{ajax:true,file:'mini_get_qrcode',module:'Users',action : 'UsersAjax',accountid:accountid,isaccountqrcode:'yes'},function(response){
				var res_obj = eval('(' + response + ')');
                 //随机数
				var number =  Math.floor((Math.random() * 10000) + 1);
				//去除response字符串中空格
                var filename = res_obj.result.filename;
				var fieldname = filename.replace(/(^\s*)|(\s*$)/g, "");
                if(res_obj.code==-1){
				 	if(res_obj.result.role=='admin'){
                        tmp_msg = res_obj.msg+'<tr>'
                                +'<td style="text-align:right"><a href="javascript:void();" onclick=" edit_miniprogrambytype(\'service\')" title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</a></td>'
                                +'</tr>';
                    }else{
                        tmp_msg = res_obj.msg+'<tr>'
                                +'<td style="text-align:right"><title="'+arrJsPopLabel['set_the_applet1']+'">'+arrJsPopLabel['set_the_applet1']+'</td>'
                                +'</tr>';
                    }
                    RemindsMsg("","LdPopWidth400px","","yes","",tmp_msg);
                    ld(obj).attr('repeat','no');
                    return false;
                }else {
                    var confirm_str ='<table class="settingPopTable lasttdbordernon pad10" border="0" cellpadding="0" cellspacing="0" width="100%">'
                        +'<tr>'
                        +'<td class="ctextalign">'
                        +'<img src="./storage/weixinqrcode/'+fieldname+'?a='+number+'" style="width: 180px;padding: 0 10px 10px 10px;">'
                        +'<p style="width: center;height:25px ">'+arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN']+'</p>'
                        +'</div></td>'
                        +'</tr>';
                     //当用户角色为管理员时可以看到小程序设置
                    if(res_obj.result.role=='admin'){
                            confirm_str +='<tr>'
                            +'<td style="text-align:right"><a target="_blank" onclick="window.open(\'index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=SelfServiceConfig&menufile=SelfServiceConfig&page_addurl=service\')" title="'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'">'+arrJsPopLabel['LBL_SERVICE_MINI_SETTINGS1']+'</a></td>'
                            +'</tr>';
                            }
                    confirm_str += "</table>";
                    RemindsMsg(arrJsPopLabel['SELFSERVICEQRCODE'],"LdPopWidth400px",'',"yes","yes",confirm_str);
                    ld('.qui_dialog_body').hide();
                    ld('.ww_dialog_foot').hide();
                    //延迟500毫秒显示弹出框内容
                    setTimeout(() => {
                        ld('.pop_remind_content').html(confirm_str);
                    }, 500);
                    ld(obj).attr('repeat','no');
                }
            });
			break;
		case 'Share'://共享
			//Eidtor:gyq_66 Reason:序时簿共享优化 Date:2018/5/8 0008 上午 11:51
			getJsScript('include/js/Share.js',function(){
				Share.getInstance().getPopup(module,record)
			});
			//SetModuleShare(module,record);
			break;
		case 'devidend_btn'://派息
        	massDividend(obj,'DetailView',record,0);
			
			break;
		case 'abtidevidend_btn'://反派息
			massDividend(obj,'DetailView',record,1);
			break;
		case 'Haochen_VoidOrder'://作废
			Haochen_VoidOrder(obj,record);
			break;
		case 'Delete'://删除
                var isDelete='no';

            
        //18641: 服务收费管理>列表/明细：系统参数：有关联单据时是否允许删除客户设置为否。结果：删除客户成功。      
            if(module=="Users"){
                deleteUser(obj,record);
            }else{
                var confirm_str=arrJsPopLabel['SUREWANTDELETE'];
				if(module=="CashBill" || module=="SendCashBill" || module=="Attachment" || module == 'OutboundOrder' || module == 'Stock'){
					confirm_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
				}
				validatasave.CheckAllowSavePhpRule(module,record,'&application=delete').then(result => {
					var con = result;
					if(!con)return '';
					
					RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
					//确认事件
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
						$("status").style.display = "block";
						var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=callStaticMethod&static=puyoung&method=checkDelInfo&fld_module='+module+"&record="+record;
						ldAjaxNoProgresssync(tmpurlsting,{"namename": "uname", "namenameage": 18},function(restobj) {
							$("status").style.display = "none";

							if(restobj.check!='SUCCESS')
							{

								RemindsMsg("","LdPopWidth400px",module,"yes","",restobj.check);
								ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
									var tmparra={};
									var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
									var tmpmodules=[module];//先这样吧有问题再修改（理论上应该有后台返回，例如删除出库，可能要更新合同订单列表的已出库数量）
									tmpobj.eachrefreshlistbyModules(tmpmodules);
									//zkt 20221027 XUQIU1000463 灵当CRM详细需求-PC端_移动端：相关信息-联系人列表增加“联系人图谱”
									tmpobj.eachrefreshModuleMapViewByModules(tmpmodules);
								});
								return false;

							}
							else
							{
								isDelete='yes';
							}
						});
						if(isDelete=='no')
						{
							return false;
						}
						if('Accounts' == module||'ServiceCharge'==module){
							deleteAccount(module,record);
						}else{
							url = 'module='+module+'&action=Delete&return_action=ListView&record='+record;
							url += '&return_module='+module;

							if('Products' == module){
								deleteProducts(module,record);
							}else{
								RequestAjax(url,function(rest){
									//liushuai  20230829 XUQIU1001827 工作流程定制，增加“删除”触发点
									if(rest.indexOf("##YES##")<0){
										var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
										if(restobj.code == -1){
											RemindsMsg("","LdPopWidth400px","","yes","",restobj.msg);
										}else if (restobj.code == 1) {
											workflowSyncPop(restobj.result);

											var popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
											var prevpopupobj =CrmPopup.getPopupObj('lastprev');
											if(prevpopupobj.pagetype =='detailview_modulepage'||prevpopupobj.pagetype =='advancepopup'){
												if(!empty(prevpopupobj.AdvanceStageobj)){
													prevpopupobj.AdvanceStageobj.RefreshTaskAfterDelete(prevpopupobj,popupobj);
												}
											}

											popupobj.CancelEvent();//关闭查看界面

											if(prevpopupobj.divid == 'pagecontent1' && ld('#'+prevpopupobj.divid).find('div[id^=global_list_]').length>0){
												UnifiedSearchClick(ld('#'+prevpopupobj.divid).find('.topsec-btn:visible')[0]);//xxy 2023-12-6 全局搜索中进入单据详情删除单据，页面未刷新
											}
											var tmparra={};
											var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
											var tmpmodules=[module];//先这样吧有问题再修改（理论上应该有后台返回，例如删除出库，可能要更新合同订单列表的已出库数量）
											tmpobj.eachrefreshlistbyModules(tmpmodules);
										}else{
											RemindsMsg("", "LdPopWidth400px", "", "yes", "", restobj.log.value);
										}

									}else{//返回值是 ##YES## 时

										var popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
										var prevpopupobj =CrmPopup.getPopupObj('lastprev');
										if(prevpopupobj.pagetype =='detailview_modulepage'||prevpopupobj.pagetype =='advancepopup'){
											if(!empty(prevpopupobj.AdvanceStageobj)){
												prevpopupobj.AdvanceStageobj.RefreshTaskAfterDelete(prevpopupobj,popupobj);
											}
										}

										popupobj.CancelEvent();//关闭查看界面
										
										if(prevpopupobj.divid == 'pagecontent1' && ld('#'+prevpopupobj.divid).find('div[id^=global_list_]').length>0){
											UnifiedSearchClick(ld('#'+prevpopupobj.divid).find('.topsec-btn:visible')[0]);//xxy 2023-12-6 全局搜索中进入单据详情删除单据，页面未刷新
										}
										var tmparra={};
										var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
										var tmpmodules=[module];//先这样吧有问题再修改（理论上应该有后台返回，例如删除出库，可能要更新合同订单列表的已出库数量）
										tmpobj.eachrefreshlistbyModules(tmpmodules);
									}

									DelProgressObjs();

								});
							}

						}
					});
				});
            }			
			break;
		case 'Settings'://页面设置
        //32398: 单据明细界面，点击【页面设置】，有时候浏览器会拦截，导致页面没有弹出，如图。
			//url = 'index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule='+module;
			//redirect(url,1);
            //ld("a[tag='DetailView_Page_Setting'").attr("href",url);
          //  
            //obj.click();
            
			break;
		case 'Updatestate'://原更改状态，现在改为更改状态
			getJsScript('include/js/ListViewButton.js',function(){
				//updateStateApprove(obj,module);
                updateState(obj,module);
			});
			break;
		case 'specialfield_edit'://增加类似“订单状态”的字段，不受审批控制可以随时修改编辑
			getJsScript('include/js/SpecialField_Edit.js', function () {
                SpecialField_Detail_Edit(record,module,'');
            });
            break;
		case 'paymentplancreate'://创建回款计划
			NewPaymentPlan(obj,'CreatePaymentplan',record,0,'no','no');
			break;
        case 'dividendcreate'://创建派息单
			getJsScript('include/js/modules/DividendOrder/NewDividendOrder.js',function(){
				NewDividendOrder(obj,'CreateDividendOrder',record);
			});
            break;
        case 'jijin_reward_accured'://业绩报酬计提
		       getJsScript('include/js/trade/Jijin/Accured.js',function(){
                    Fund_Accured.cur_obj=null;
                    Fund_Accured.getInstance('FundReward',obj).Pop()
                                
                });
            
            break;
        case 'jijin_management_accured'://管理费
		       getJsScript('include/js/trade/Jijin/Accured.js',function(){ 
		           Fund_Accured.cur_obj=null;
                    Fund_Accured.getInstance('Management',obj).Pop()
                                
                });
            
            break;
        case 'jijin_management_commission_accured'://管理费佣金
		       getJsScript('include/js/trade/Jijin/Accured.js',function(){    
                    Fund_Accured.cur_obj=null;
                    Fund_Accured.getInstance('Mcommission',obj).Pop()
                                
                });
            
            break;
         case 'jijin_reward_commission_accured'://业绩报酬佣金
		       getJsScript('include/trade/Jijin/Accured.js',function(){   
		              Fund_Accured.cur_obj=null;
                    Fund_Accured.getInstance('FundRewardCommission',obj).Pop()
                                
                });
            
            break;
		case 'createPaymentid'://创建回款预测
			NewReceivablesforecast(obj,'Createreceivablesforecast',record,1,1);
			break;
		case 'Advance'://推进
		case 'AdvanceComplete':
		
			getJsScript('include/js/AdvanceStage.js',function(){
				AdvanceStage.refershtype = 'detail';
				if(setype == 'Advance')
					AdvanceStage.show(record,module);
				else{
					AdvanceStage.Complete(record,module);
				}
			});
			/*if(module == 'Leads'){
				getJsScript('include/js/modules/Leads/Leads.js',function(){
					check_advance_click(obj,module,record,'detail');
				});
			}else{
				getJsScript('include/js/ListViewButton.js',function(){
					Advance(obj,module);
				});
			}*/
			break;
		/*gyq_07*/
   		case 'ChangeCreator'://变更负责人
			getJsScript('include/js/ListViewButton.js',function(){
				ChangeCreator(obj,module,'ChangeCreator','detail',record);
			});
			break;
		case 'instockroomOperation'://入库确认、出库确认
			instockroomOperation(record);
			break;
		case 'retracementOperation'://退货入库回撤、退货出库回撤
			if(tag == '')tag = 0;
           
			retracementOperation(obj,record,tag)
			break;
		case 'instockroomEndOperation'://结束退货
			instockroomEndOperation(obj,record,tag);
			break;
		case 'set_bank_checks'://银行初始化-确定
			set_bank_checks_presence(record,2);
			break;
		case 'PotentialsShare'://银行初始化-账户设置
			PotentialsShare(obj,record);
			break;
			//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 14:07
		/*case 'checkcashbill_1'://未审核，审核
			checkcashbill(record,1,1);
			break;
		case 'checkcashbill_2'://已审核，反审核
			checkcashbill(record,2,1);
			break;*/
		case 'set_stock_presence_1'://审核
			if(tag == '')tag = 1;
			set_stock_presence(record,1,tag);
			break;
		case 'set_stock_presence_2'://反审核
			if(tag == '')tag = 1;
			set_stock_presence(record,2,tag);
			break;
		case 'submit_warehousetransfer'://审核 - 反审核
        //33544: 库间调拨明细界面>点击审核按钮：没有反应。
             //var tag= ld(obj).find("a").attr('tag');
			// zxm 20221129 盘点单的tag放到div上了
			var tagarr = tag.split('-');
			submit_warehousetransfer(tagarr[0],tagarr[1],record,tagarr[2]);
			break;
		case 'set_checks_presence'://盘点
        //033694: 盘点明细界面：点击“确认盘点”、“撤销盘点”按钮没有反应，按钮功能失效
         //var tag= ld(obj).find("a").attr('tag');
		//zxm 20221129 盘点单的tag放到div上了
			var tagarr = tag.split('-');
			set_checks_presence(record,tagarr[1],tagarr[1]);
			break;
		case 'newsendpayment'://创建付款计划
			NewSendPayment(obj,'CreateSendPayment',record,tag,'no');
			break;
        
		case 'synchronousinventory'://数据接口，同步库存
			fnvshobj(obj,'synchronousInventoryDiv');
			break;
        case 'oahistory'://考勤统计
        //34829: 加班单、请假单查看明细界面-更多-考勤统计：勾选/反选复选框“只统计已审批通过的单据 ”时应该触发重算
        //     objoa=new JSOA(module,record);
        //     objoa.showAttencePop(obj);
			//0041733: （https://61mis.com/kfbcrm/ [^]）加班单、请假单单据查看详情界面，点击更多中的“考勤统计”，界面变暗（弹出层样式已改好）
			objoa=new JSOA(module,record); //创建对象为ajax请求准备参数
			showAttencePop(module, record);
            break;
        case 'price_strategy':
            //editor:gyq_84 reason:产品增加价格策略 2018/10/22 15:20
            getJsScript('include/js/modules/Products/price_strategy.js',function(){
                price_strategy.getInstance().get_setting_windows(obj,module,record);
            });
            break;
        case 'addtocart':
            getJsScript('include/js/modules/Products/shopcart.js',function(){
                addtocarts(record);
            });
            break;
		case 'InitiateSigning'://ls 2021-09-16 【ID1001956】增加“电子签章”功能（发起签署）
			// getJsScript('include/js/modules/SalesOrder/SalesOrder.js',function(){
				commonInitiateSigning(obj,record,module);
			break;
		case 'PreviewContract':
			// getJsScript('include/js/modules/SalesOrder/SalesOrder.js',function(){
			// getJsScript('include/js/ListViewButton.js',function(){
				PreviewContract(obj,record,module);
			// });
			break;
		case 'InitiateSigningQys':
			commonInitiateSigningQys(obj,record,module);
			break;
		case 'PreviewContractQys':
			PreviewContractQys(obj,record,module);
			break;
		case 'InitiateSigningSaasQys':
			CreateFlowSaasQysObj.CreateDraftHtml(obj,record,module);
			break;
		case 'PreviewContractSaasQys':
			CreateFlowSaasQysObj.PreviewContract(obj,record,module);
			break;
		case 'DownloadContractSaasQys':
			CreateFlowSaasQysObj.DownloadContract(obj,record,module);
			break;
		case 'InitiateSigningFdd':
			CreateFlowFddObj.CreateUploadFileHtml(obj,record,module);
			break;
		case 'PreviewContractFdd':
			CreateFlowFddObj.PreviewContract(obj,record,module);
			break;

        case 'Urged'://工单管理-催单
			WorkSheetAble(module,record,'urged');
			break;
        case 'Ended'://工单管理-结单
			WorkSheetAble(module,record,'ended');
			break;
        case 'Reopen'://工单管理-结单
            WorkSheetAble(module,record,'reopen');
			break;
        case 'Solution'://工单管理-解决方案
            WorkSheetSolution(module,record);
			break;
		case 'baxterCreatePdfAndXml':
			baxterCreatePdfAndXml.getInstance().createPdfAndXml();
			break;
		case 'HeaderSetting'://顶部导航栏定制
			// getJsScript('include/js/leftmenu.js',function () {
				var getheadersetobj= new headerSetting(module,record);
				getheadersetobj.getHeaderSetting();
			// });
			break;
		case 'Renew'://服务合同 续签
			renewContracts(module,record,'');
			break;
		case 'seniorAllocate':// 高级分配，可选是否同时分配相关信息
        case 'seniorShare':// 高级共享，可选是否同时共享相关信息
        case 'seniorHigndistribution':// 公海分配
            getJsScript('include/js/SeniorAllocateShare.js', function () {
                var seniorAllocateShare = new SeniorAllocateShare(module, setype, 'detail');
                seniorAllocateShare.getPopup(record);
            });
            break;
		case 'ExportDevicecode':// 设备模块导出设备码
            getJsScript('include/js/modules/Equipment/Equipment.js',function(){
                var equipmentObj = new cls_Equipment(module);
                equipmentObj.exportDevicecode('detailview',record);
            });
            break;
		case 'DecryptColumn'://解密
			DecryptColumn.getInstance().Decrypt('detail', module, record);
			break;

    }
}
/**
 * edit：chj
 * date:2014-9-9  ChangeCreator
 * reason:客户服务单、项目、项目任务详细界面添加 分配按钮
 * description:0011039: 建议：在“客户服务单”、“项目”、“项目任务”明细查看界面，增加一个【分配】按钮，可以实现分配功能。
 * */
function detail_mass_edit(obj,divid,module,parenttab,smowner)
{
    var idstring = document.DetailView.record.value + ';';
    var url="&ajax=true&return_action=DetailView";
	if(typeof(parenttab) == 'undefined') parenttab = '';
	$("status").style.display="inline";
    //alert("module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module+'Ajax')+"&parenttab="+encodeURIComponent(parenttab)
           // +"&file=MassEdit&mode=ajax&idstring="+idstring+"&smowner="+smowner+url);
    /*gyq_07*/

	ldAjaxHtmlNoProgress('index.php?',"module="+module+"&action="+module+'Ajax'+"&file=MassEdit&mode=ajax&idstring="+idstring+"&smowner="+smowner+url,function(response) {
		$("status").style.display="none";
		var result = response;

		if(url!='')
		{
			if(result.indexOf('###APPROVE###')>-1)
			{
				var str=result.split('###APPROVE###');
				RemindsMsg("","LdPopWidth400px","","yes","",str[1]);
				puyoungJS_DialogBox.unblock();
				return true;
			}
		}
		var result=response.split(('###SUCCESS###'));

		$("smowneredit_form_div").update(result[1]);
		$("massedit_form")["massedit_recordids"].value = idstring;
		$("massedit_form")["massedit_module"].value = module;

		fnvshobj(obj, divid);
		BatchOperation(divid,module,idstring,'DetailView');
	});

    //mass_edit_formload(idstring,module,parenttab,smowner,obj,divid);
}

/*
edit:chj
date:2015-4-24
reason:批量操作 ： 显示操作日志信息
*/
function BatchOperation(divid,module,idstr,acitonname)
{
	//获取保存按钮，重新绑定点击事件
	// divid: smowneredit(分配)
	var obj ='';
	var updateDiv='';
	var idstring = '';
	var isModule='';
	if(divid == 'smowneredit')
		updateDiv = 'div_share';
	obj = document.getElementById(divid);
	var getinput = obj.getElementsByTagName('input');
	var inputlen = getinput.length;var submitobj;var cancelobj;
	for(var i=0; i<inputlen; i++){
		if('D_pbtnok' == getinput[i].className){
			submitobj = getinput[i];//保存按钮对象
		}else if('D_pbtncancel' == getinput[i].className){
			cancelobj = getinput[i];//取消按钮对象
		}
	}
	if(idstr == 'all'){
		idstring = $("massedit_form")["massedit_recordids"].value;
	}else{
		idstring = idstr;
	}
	if(submitobj){
		var issubmit = 1;
		submitobj.onclick = function(){//给保存按钮绑定点击事件
			if(issubmit != 1) return false;issubmit = 2;//防止重复点击
			if(divid == 'smowneredit'){
				if(module != 'Accounts' && module != 'Potentials'){
					isModule = 'Users'
				}else{
					isModule = module;
				}
                if(document.getElementById('assigned_user_id') != undefined&&document.getElementById('assigned_user_id') != null){
                    var assigned_user_id = document.getElementById('assigned_user_id').value;   
                }
                if(document.getElementById(module+'assigned_user_id') != undefined&&document.getElementById(module+'assigned_user_id') != null){
                    var assigned_user_id = document.getElementById(module+'assigned_user_id').value;
                }
				if(document.getElementById('servicecasher') != undefined&&document.getElementById('servicecasher') != null){
                    var assigned_user_id = document.getElementById('servicecasher').value;
                }
                if(module=='Products'&&document.getElementById('prosmownerid') != undefined&&document.getElementById('prosmownerid') != null){
                     var assigned_user_id = document.getElementById('prosmownerid').value;  
                }
				var urlstring = 'module='+isModule+'&action='+isModule+'Ajax&file=SmownerEditSave';
				urlstring += '&from_module='+module+'&massedit_recordids='+idstring+'&assigned_user_id='+assigned_user_id;
                urlstring+="&mass_allocate_totalrows="+document.getElementById("mass_allocate_totalrows").value;
			}
			RequestAjax(urlstring,function(rest){//批量提交保存
                if(rest.indexOf('###SMSERROR..')>-1)
                {
                    //14815: 客户>序时簿,关于分配负责人的问题,edit:can
                    var results=rest.split("###SMSERROR..");
                  
                    RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel[results[1]]);
					DelProgressObjs();
                    window.location.reload();
                }
				if(rest == '') return false;
               //详情页分配完刷新界面
				if(acitonname == 'DetailView'){
					fninvshnew(divid);
					DelProgressObjs();
					window.location.reload();
					return false;
				}
              
              
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				var submitlog = '<div style="width:96%;max-height:200px;overflow-y:auto;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;">';
				submitlog += restobj.log.value;//批量提交日志
				submitlog += '</div>';
               
				sethtml(document.getElementById(updateDiv),submitlog);
				//approve_subbtn_val = submitobj.value;
				var inputs = submitobj.parentNode.getElementsByTagName('input');
				//inputs[1].value = restobj.download.value;
				submitobj.style.display = 'none';//隐藏提交按钮
				cancelobj.className="D_pbtnok";
				cancelobj.value = arrJsPopLabel['CONFIRME'];//取消按钮名字重命名
				cancelobj.onclick = function(){//原取消按钮onclick事件
					fninvshnew(divid);puyoungJS_DialogBox.unblock();
                    //清空选择记录
                    
                    if(document.getElementById('allselectedboxes') != undefined){
                        document.getElementById('allselectedboxes').value='';   
                    }
                    if(document.getElementById('selectedboxes') != undefined){
                        document.getElementById('selectedboxes').value='';   
                    }
					getListViewEntries_js(module,'start='+restobj.start.value);//刷新页面
				}
				DelProgressObjs();
			});
		}
	}
}



//提交审批 保存
function Detail_save_submitapprove(){
	
    var validata=Detail_save_submitapprove.validata();
    if(!validata)
        return false;
    var popupobj=CrmPopup.getPopupObj("last");

    var stepapproveuserid=ld("#"+popupobj.divid+" [name=userid_0]").val();
	var module = ld("#"+popupobj.divid+" [name=fld_module]").val();
	var record = ld("#"+popupobj.divid+" [name=idstring]").val();
    
    var isnewapprove = ld("#"+popupobj.divid+" [name=isnewapprove]").val();
    var submitapprove_text = ld("#"+popupobj.divid+" [id=submit_description]").val();//提交意见是否为空
    var submitlabelobj = ld("#"+popupobj.divid+" [name=submitremarkrequire]");//提交意见是否必填
	/* duan 20240919 提交审批时的审批意见必填移动到Detail_save_submitapprove.validata 方法里
    if(ld.trim(submitapprove_text)=="" && ld(submitlabelobj).css("display")=="inline")
    {
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
        return false;
    }
	 */
    //duan 2022-3-31 判断当前审批步骤是否允许审批人为为空
    var allow_emptyapprover = ld("#"+popupobj.divid+" [name=allow_emptyapprover_0]").val();
	if((!empty(stepapproveuserid) && stepapproveuserid != 'null') || allow_emptyapprover=='yes'){
	
	    ld("#"+popupobj.divid+"_btnok").attr('disabled',"disabled");
		var approvevalue = ld("#"+popupobj.divid+" [name=approvevalue]").val();
		var urlstring = 'index.php?file=SubmitApprove';
	//	urlstring += '&fld_module='+module+'&approvevalue='+approvevalue;
		//urlstring += '&idstring='+record+"&stepapproveuserid="+stepapproveuserid;
        ld("#"+popupobj.divid+' [name=action]').val('ApproveAjax');
        var formdata=ld("#"+popupobj.divid+' [name=frmsubmitapprove]').serialize();
        
		ldAjaxNoProgresssync(urlstring,formdata,function(data){
			if(data.code == 1){
			 //edit:can 2020-09-03 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
            
            	ModelDataBindobj.setButtonName='submitapprove';
            	ModelDataBindobj.setpropertyname='approvesavebutton';
				popupobj.CancelEvent();

				workflowCallApiPop(data.result);//工作流API弹

				var tmparra=new Array();
				tmparra.push(record);
                var valuefinfo=[];
                 valuefinfo['valueinfo']={'result':''};
				var tmpobj= new AfterUpdatePrevPopupObjContent(module,valuefinfo,tmparra);
				var prevpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
				if(!empty(prevpopupobj)){
					DetailViewRelation.showpage_moduledetail(prevpopupobj);
				}
				//tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);
                
                var refreshlistmodules=[popupobj.module];
                tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				DelProgressObjs();

				var surl = 'index.php?module=Approve&action=ApproveAjax&file=SubmitApprove&fld_module=' + module + '&record=' + record + '&pushtype=dingtalk';
				ldAjax(surl,'',function (data) {
					if (data.code == 1) {
						if (data.result.res == 1) {
							var confirm_str = arrJsPopLabel['dingtalk_webhook_approve_success'];
							// audioRemindsMsg("", "", "", "", "", confirm_str);
							MessagePopup.TipZero_success(confirm_str);
							return false;
						} //else  2  没有启用不通知
					} else {
						var confirm_str = arrJsPopLabel['dingtalk_webhook_approve_fail'];
						// audioRemindsMsg("", "", "", "", "", confirm_str);
						// return false;
						// RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
						MessagePopup.TipZero_warning(confirm_str);
					}
				})
			// @edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（合同订单和自定义11-45模块提交审批时）
				/*
				var modulearr = new Array();//生成11-45之间的的数组
				for(var i=11;i<=45;i++){
					modulearr.push(i);
				}
				//@edit:liushuai,2020-08-21,reason:【ID1001020】合同订单单个提交 钉钉群消息推送提醒, 批量提交不提醒
				if (module == 'SalesOrder' || (module.indexOf("CustomForm") != -1 && ld.inArray(module.replace("CustomForm",''),modulearr))) {  //可以加此判断，也可以不加，后台会有判断
					var surl = 'index.php?module=Approve&action=ApproveAjax&file=SubmitApprove&fld_module=' + module + '&record=' + record + '&pushtype=dingtalk';
					ld.ajax({
						url: surl,
						type: 'POST',
						data: '',
						dataType: 'json',
						async: true,//
						timeout: 30000,
						success: function (data) {

							if (data.code == 1) {

								if (data.result.res == 1) {
									var confirm_str = arrJsPopLabel['dingtalk_webhook_approve_success'];
									audioRemindsMsg("", "", "", "", "", confirm_str);
									return false;
								} //else  2  没有启用不通知
							} else {
								var confirm_str = arrJsPopLabel['dingtalk_webhook_approve_fail'];
								// audioRemindsMsg("", "", "", "", "", confirm_str);
								// return false;
								RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
							}

						}
					})
				}
				 */

			}else if(data.code=='-3'){
				//duan 20230724 保存并提交审批时,修改错误提示方式,避免跟保存的收款计划弹出层冲突
				DelProgressObjs();
				popupobj.CancelEvent();
				ld("#"+popupobj.divid+"_btnok").removeAttr("disabled");
				setTimeout(function (){
					audioRemindsMsg("","LdPopWidth400px","","yes","",data.msg);
				},50);
			}
			else{
		      	 ld("#"+popupobj.divid+"_btnok").removeAttr("disabled");
		      	 RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
				//ls 2021-09-17 0047882:（客户问题-需要补丁）合同订单-新增；复制/新增单据，选择保存并提交审批流程“合同订单审批条件”，出现不满足条件提示时，会新增一条单据但是页面不会关闭
				//点击确认
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype).CancelEvent();//关闭新增/编辑/复制界面
				});
                DelProgressObjs();
			}
		})
		return true;
	}else{
		popupobj.CancelEvent();
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['NONEXTAPPROVER']);
		return false;
	}
}
Detail_save_submitapprove.validata=function(){
    
    var popupobj=CrmPopup.getPopupObj("last");
	var nextstepapprover = ld("#"+popupobj.divid+" [name=userid_name_0]").val();
    var stepapproveuserid=ld("#"+popupobj.divid+" [name=userid_0]").val();
	var module = ld("#"+popupobj.divid+" [name=fld_module]").val();
	var record = ld("#"+popupobj.divid+" [name=idstring]").val();
    var concurrentidStepCount=ld("#"+popupobj.divid+" [name=concurrentidStepCount]").val();
	var approvevalue = ld("#"+popupobj.divid).find(" [name=approvevalue]").val();

    if(concurrentidStepCount<=0)
    {
        concurrentidStepCount=1;
    }
	//xxy 2023-12-15 判断审批流程不能为空，-1为无默认流程显示为空生效时的approveid
	if(approvevalue == -1){
		MessagePopup.TipZero_warning(arrJsPopLabel['APPROVALNOTEMPTY']);
		var selectobj = ld("#" + popupobj.divid).find('a[name=cmb_a_approvevalue]');
		// var currentobj = selectobj.offset().top;
		var popup_scrollobj = ld("#" + that.divid).find('.dvpopupsroll');
		popup_scrollobj.scrollTop(popup_scrollobj.prop('scrollHeight'));
		
		selectobj.addClass('border_red1');
		setTimeout(() => {
			selectobj.removeClass('border_red1');
		}, 2000);
		return '';
	}
    for(var i=0;i<concurrentidStepCount;i++)
    {
        //duan 2022-3-30 判断并发步骤是否允许审批人为为空
        var allow_emptyapprover = ld("#"+popupobj.divid+" [name=allow_emptyapprover_"+i+"]").val();
        if(allow_emptyapprover !='yes' && (ld("#"+popupobj.divid+" [name=userid_"+i+"]").val()==0||ld("#"+popupobj.divid+" [name=userid_"+i+"]").val()==''))
        {
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['NONEXTAPPROVER']); 
            return false;
        }
         
    }
	//duan 20240919 提交审批的判断都移动到validata 里，用于保存之前调用
	// 提交审批时审批意见必填判断
	var submitapprove_text = ld("#"+popupobj.divid+" [id=submit_description]").val();//提交意见是否为空
	var submitlabelobj = ld("#"+popupobj.divid+" [name=submitremarkrequire]");//提交意见是否必填
	if(ld.trim(submitapprove_text)=="" && ld(submitlabelobj).css("display")=="inline")
	{
		RemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['SUBMITREMARKREQUIRE']);
		return false;
	}
	//审批人不能为空判断
	var allow_emptyapprover = ld("#"+popupobj.divid+" [name=allow_emptyapprover_0]").val();
	if((!empty(stepapproveuserid) && stepapproveuserid != 'null') || allow_emptyapprover=='yes'){
	}else{
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['NONEXTAPPROVER']);
		return false;
	}

    return true;
}
Detail_save_submitapprove.funname='Detail_save_submitapprove';

//提交审批
function submitapprove(obj,divid,module,record){
   
    var returnmodule=module;
    if(module=='ServiceCharge'){
        module='Accounts';
        returnmodule='ServiceCharge';
    }

	//@edit:liushuai,2020-09-14,reason:【ID1001100】需求变更,提交审批时判断，选择外币时是否选择发货方。
	var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
	if(account_version == 'yiwen' && module == 'SalesOrder'){
    	   var rowobjs=ld("#"+popupobj.divid+" .ProductTab").find("tr[detaildeleted=no]");
           
           var prev_cur = CrmPopup.getHtmlobjval(divid,'prev_selected_currency_id');
           ld.each(rowobjs,function(){
                 var i=ld(this).attr("rowindex");
                 
                 var shipper=ld.trim(ld(this).find(" [name=productdetails_input_sf16430]").text());
                 if(parseInt(prev_cur) == 1){ //人民币
    
    			}else{// 外币
    				if(empty(shipper)){
    					RemindsMsg("","LdPopWidth400px","","yes","","第"+i+"行请选择发货方");
    					return false;
    				}
    			}
           })

	}
    validatasave.CheckAllowSavePhpRule(module,record,'&application=submit').then(result => {
		var con = result;
		if(!con)return '';

		var surl = "index.php?module=Approve&action=ApproveAjax&file=SubmitApprove&save=false&fld_module="+module+"&record="+record+'&returnmodule='+returnmodule;
		ldAjax(surl,"",function(data){
			if(data.code == 1){
				var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",module,"","","","");
				crmPopupobj.prevshow();
				crmPopupobj.setParams(data.result.title,Detail_save_submitapprove,"","LdPopWidth650px",module,"",data.result.oktext,"",data.result.canceltext,"");  
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
							//通讯录(pc端企业微信)
							
							cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
				}
				
			}else{
				if(data.msg == 'NO'){
					//您没有适用的审批流程，请联系管理员检查并设置审批流程！
					var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				}else if(data.msg == 'nopermit'){
					var confirm_str = arrJsPopLabel['DOCUMENTNOPROCESSPLEASESETPROCESS'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				}
			}
			DelProgressObjs();
		})
			return false;
	})
}
/**
edit:kevin
date:2013-09-10
reason:审批
*/
function approveBlocks(record,module,obj,divid){
    var returnmodule=module;
    if(module=='ServiceCharge'){
        module='Accounts';
        returnmodule='ServiceCharge';
    }
    //duan 20230718 审批必填字段改为在审批界面中显示
	getApproveBlocks(record,module,obj,divid);
    /*
    var url = 'index.php?module=Approve&action=ApproveAjax&file=ApproveStep';
	url += '&fld_module='+module+'&record='+record+'&returnmodule='+returnmodule+"&getApproveStepField=yes";
	ldAjaxNoProgress(url,"",function(data){
		if(data.code == 1){
			getApproveBlocks(record,module,obj,divid);
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
			//确定事件
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
				var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
				 Popupobj.prevshow();
				 PageRecordPopup.params['refreshpage']='no';
				  var tmpurl = '&cur_module_step='+data.result.stepid;
				  //alert(tmpurl);
				 PageRecordPopup.showpage(module,record,tmpurl,PageRecordPopup.params);
			});
		}
	})
     */
}
//审批
function getApproveBlocks(record,module,obj,divid){
	var returnmodule=module;
    if(module=='ServiceCharge'){
        module='Accounts';
        returnmodule='ServiceCharge';
    }
	var url = 'index.php?module=Approve&action=ApproveAjax&file=ApproveStep';
	url += '&fld_module='+module+'&record='+record+'&returnmodule='+returnmodule;
	ldAjax(url,"",function(data){
		if(data.code == 1){
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",module,"","","","");
			crmPopupobj.prevshow();
			crmPopupobj.createScrollDiv = function () {
				//var maxheight=this.getMaxHeight();
				crmPopupobj.scrolldiv = '<div class="dvpopupsroll ld-public-content-small" style="max-height:1200px;width: 100%;overflow-y:auto;">';
			}
			crmPopupobj.setParams(data.result.title,saveApproveLog,"","LdPopWidth650px",module,"",data.result.oktext,"",data.result.canceltext,"");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			crmPopupobj.pagetype = 'approvepopup';
			crmPopupobj.columnfields_value = data.result.columnfields_value;
			crmPopupobj.record = record;

			var nextstepobj=ld("#"+crmPopupobj.divid+" select[name=nextstep_0]");
            if(ld(nextstepobj).length>0)//edit:can 20210806 47198: （https://81mis.com/kfbcrm [^]）审批中心—待处理—派工单—PROT28 使用的审评流程—出工 一级审批“1”选择三级审批“5”的时候审批人应该是李洋
                ApproveStepChange(ld(nextstepobj).get(0));
            
            //zkt 0050406: （https://81mis.com/kfbcrm/index.php [^]）合同订单》SO32，审批人yhaic，审批单据时，选择审批人的样式没有更新；‘审批步骤是并发审批加签’
            var approvetype = ld("#"+crmPopupobj.divid+" [name=approvestatus]");
            var countersigner = ld("#"+crmPopupobj.divid+" [name=countersigner]").val();
			var approvetypelen = approvetype.length;
			for(var i=0; i<approvetypelen; i++){
				approvetype[i].onclick = function(){//给审批状态绑定点击事件
					var approvestatustype = 0;
					for(var i=0; i<approvetypelen; i++){//获取当前审批状态
						if(approvetype[i].checked){
							approvestatustype = approvetype[i].value;
						}
					}
                    if(countersigner != 'yes'){
                        ld("#"+crmPopupobj.divid+' tr[tag=tr_process').css("display",'none');
                    }
                     
                     if(approvestatustype == 1||approvestatustype == 6){
                        ld("#"+crmPopupobj.divid+' [name=procecess_table_'+approvestatustype+']').css("display","");
                     }
                     //zkt 20220707 BUG0053698（http://crm.airmaster.com.cn/crm）合同订单，审批流程中，当下一步审批步骤是并发审批，且成员较多时，审批界面不是垂直居中显示，有部分遮挡，需要往上拖动之后才能继续下一步。
                     //界面居中显示
                     var tmppopupobj = CrmPopup.getPopupObj("last");
                     tmppopupobj.center();
                     
				}
                //初始化审批状态触发点击事件
                if(approvetype[i].checked){
					approvetype[i].click();
				}
			}
            
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
              //通讯录(pc端企业微信要绑定)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);


            //duan 20230717 控制审批界面的可编辑字段显示
			var tmp_result = data.result;
			getJsScript('include/js/modules/Approve/cls_approve_mandatoryfield.js',function(){
				cls_approve_mandatoryfield.resetfield(crmPopupobj,tmp_result);
				cls_approve_mandatoryfield.setChangeEvent(crmPopupobj,record);
			})

			if (data.result.approve_fieldname_arr != undefined) {
				getJsScript('include/js/modules/Approve/cls_approvestep_change.js', function () {
					crmPopupobj.approvestep_changeobj = new cls_approvestep_change(crmPopupobj,data.result.approve_fieldname_arr);
					crmPopupobj.approvestep_changeobj.set_user_fieldname_arr(data.result.user_fieldname_arr);
				});
			}

		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",data.msg); 
		}
        DelProgressObjs();
	})
}
//催审
function approveExpediting(record,module,obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var url = 'index.php?module=Approve&action=ApproveAjax&file=ApproveExpediting';
    url += '&record='+record+'&frommodule='+module;
    ldAjax(url,"",function(data){
		if(data.code == 1){
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",module,"","","","");
			crmPopupobj.prevshow();
			crmPopupobj.setParams(data.result.title,saveExpediting,"","LdPopWidth650px",module,"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
            crmPopupobj.remindlogids = data.result.remindlogids
            
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",data.msg); 
		}
        DelProgressObjs();
	})
}
//发送催审
function saveExpediting(){
    var popupobj = CrmPopup.getPopupObj('last');
    var module = popupobj.module;
    var reminders = ld("#"+popupobj.divid+" input[name=expeditingreminder]").val();
    var record = ld("#"+popupobj.divid+" input[name=expeditingreocrd]").val();
    //提醒内容不能为空
    if(ld("#"+popupobj.divid+" [name=description]")==undefined||ld("#"+popupobj.divid+" [name=description]").val()=='')
    {
        var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];//提醒内容不能为空！
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    var remindlogids = ld("#"+popupobj.divid+" [name=remindlogids]").val();
    var remindconten = ld("#"+popupobj.divid+" [name=description]").val();
    var url = 'index.php?module=Approve&action=ApproveAjax&file=ApproveExpediting&mode=save';
    url += '&reminders='+reminders+'&record='+record+'&frommodule='+module+'&remindconten='+remindconten+'&remindlogids='+remindlogids;
    ldAjax(url,"",function(data){
		if(data.code == 1){
            var tmparra=new Array();
            //zkt 20211201 0049051: （81mis.com/kfbcrm/index.php）自定义表单07》单据详情，使用催审功能，点击发送时，界面一直转圈
			tmparra.push(record);
			var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
			//催审保存后刷新查看界面
			tmpobj.eachrefreshDetailViewByModules(module);
            tmpobj.eachrefreshlistbyModules(module);
            
            popupobj.CancelEvent();
		}else{
            popupobj.CancelEvent();
			RemindsMsg("","LdPopWidth400px","","yes","",data.msg); 
		}
        DelProgressObjs();
	})
}
/**
 * 反审批操作，弹出反审批弹出层，并绑定反审批弹出层点击事件
 * @param Integer record 数据ID
 * @param String module 模块名
 * @param Object obj Event对象
 * @param String divid 反审批弹出层ID
 * @param Integer iscancel 1、审批中反审批，2、审批后反审批
 * @returns 获取并弹出反审批弹出层
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-30
 */
var isinitcancelapprove = 1;
function save_cancelApproved(){
	var popupobj=CrmPopup.getPopupObj("last");
	var inputs = document.frmcancelapprove;
	var approvetype = document.getElementsByName('cancelapprovetype');
	//	approvetype[0].value = 0;
	var approvetypelen = approvetype.length;
	var cancelapprovetype = 0;
	//当前审批流程删除时，直接使用新审批流程
	/*if(results[0] == 'Delete'){
		cancelapprovetype = 2;
	}else{*/
		for(var i=0; i<approvetypelen; i++){
			if(approvetype[i].checked){
				cancelapprovetype = approvetype[i].value;
			}
		}	
	//}
    var stepapproveuserid=ld("#approveuserid").val();
	var description = inputs.description.value;
    var requiretext = ld("#"+popupobj.divid+" [name=requiretext]").val();
    if(ld.trim(description)=="" && requiretext=="yes")//判断审批意见是否必填且为空
    {
        audioRemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['APPROVEREMARKREQUIRE']);
        return false;
    } 
    ld("#"+popupobj.divid+" [name=action]").val('ApproveAjax');
	var urlstring = 'index.php?file=getCancelApprove';
	urlstring += '&canceltype='+cancelapprovetype+'&setype=cancel';//&description='+description+"&stepapproveuserid="+stepapproveuserid;
    var urgent='no';
    //edit:can 2021082447616: （81mis.com/kfbcrm）合同订单-单据SO260，管理员操作反审批，使用新的审批流程流转时，选择加急审批流没有显示对应‘加急’选项
    if(cancelapprovetype==1||cancelapprovetype==2)
    {
        if(ld("#"+popupobj.divid+" [tag=urgent"+cancelapprovetype+"]").find(" [name=urgent]").prop("checked"))
            urgent='yes';
    }
    urlstring +='&urgent='+urgent;
    if(2 == cancelapprovetype){
		var approveopts = inputs.approveopts.value;
		if(empty(approveopts)){
			var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str); 
			return false;
		}
		urlstring += '&approveid='+approveopts;
	}
	var fld_module = inputs.fld_module.value;
	var record = inputs.record.value;
//	urlstring += '&fld_module='+fld_module+'&record='+record;
    ld("#"+popupobj.divid+"_btnok").attr('disabled','disabled');
    
	ldAjax(urlstring, ld("#"+popupobj.divid+" [name=frmcancelapprove]").serialize(),function(data){
		if(data.code == 1){
			popupobj.CancelEvent();
			workflowCallApiPop(data.result);//工作流API弹窗

			var tmparra=new Array();
			tmparra.push(record);
          
			var tmpobj= new AfterUpdatePrevPopupObjContent(fld_module,getEmptyValueInfo(),tmparra);
			//服务单保存后刷新服务单的历史记录(查看界面)
			tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);
           
            tmpobj.eachrefreshlistbyModules(data.result.refreshdetailmodules);
            
            //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
            ModelDataBindobj.setButtonName='cancelapprove';
            ModelDataBindobj.setpropertyname='approvesavebutton';
		}else{
		  ld("#"+popupobj.divid+"_btnok").removeAttr("disabled");
			if(data.msg == 'NEXTSTEPNOUSER'){
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str); 
			}else{
				RemindsMsg("","LdPopWidth400px","","yes","",data.msg); 
			}
		}
         DelProgressObjs();
	})
}
save_cancelApproved.funname='save_cancelApproved';

function cancelApproved(record,module,obj,divid,iscancel){
    var that=this;
   
    if(module=='ServiceCharge')module='Accounts';
    
    validatasave.CheckAllowSavePhpRule(module,record,'&application=cancel').then(result => {
		con = result;
    	if(!con)return '';
    
		var urlstring = 'index.php?module=Approve&action=ApproveAjax&file=getCancelApprove';
		urlstring += '&fld_module='+module+'&record='+record+'&iscancel='+iscancel+'&setype=info';
		ldAjax(urlstring,"",function(data){
			if(data.code == 1){
				var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",module,"","","","");
				crmPopupobj.prevshow();
				crmPopupobj.createScrollDiv = function () {
					crmPopupobj.scrolldiv = '<div class="dvpopupsroll ld-public-content-small" style="max-height:1200px;width: 100%;overflow-y:auto;">';
				}
				crmPopupobj.setParams(data.result.title,save_cancelApproved,"","LdPopWidth650px",module,"",data.result.oktext,"",data.result.canceltext,"");  
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				var approveerror = data.result.approveerror;
				if(approveerror == 'error'){
					var confirm_str = "金蝶销售订单中对应的单据已审批，无法反审核！";
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str); 
					DelProgressObjs();
					return false;
				}
				////duan 20220923 修改审批日志滚动条，默认显示最底部的日志
			//    var approvelog_scrollobj = ld("#"+crmPopupobj.divid+" [name=approvelog_scroll]");
			//    if(approvelog_scrollobj.length>0){
			//        approvelog_scrollobj.get(0).scrollTop = approvelog_scrollobj.get(0).scrollTopMax;
			//    }
				//初始化反审批弹出层
				var inputs = document.frmcancelapprove;
				var approvetype = document.getElementsByName('cancelapprovetype');
			//	approvetype[0].value = 0;
				var approvetypelen = approvetype.length;
				if(inputs.approveopts != undefined){
					if(inputs.approveopts.options.length > 0)
						inputs.approveopts.selectedIndex = 0;
					else{
						approvetype[2].disabled = true;
					}
					ld("#"+crmPopupobj.divid+" [name=approveopts]").unbind("change").bind("change",function(){
					//  ld("#"+crmPopupobj.divid+" [name=username_approver_1]").css('display','none');
						//ld("#"+crmPopupobj.divid+" [name=username_approver_2]").css('display','none');
						that.changeApproveStep(ld(this).val(),2);
					})
				}
				
				//当前审批流程删除时，直接使用新审批流程
				if(approveerror != 'Delete'){
					if(inputs.approveopts != undefined){
						inputs.approveopts.style.display = 'none';
					}
					
					for(var i=0; i<approvetypelen; i++){
						approvetype[i].onclick = function(){//给三个反审批状态绑定点击事件
							var cancelapprovetype = 0;
							for(var i=0; i<approvetypelen; i++){//获取当前反审批状态
								if(approvetype[i].checked){
									cancelapprovetype = approvetype[i].value;
								}
							}
							if(2 == cancelapprovetype){//使用新的审批流程，显示审批流程下拉框
								inputs.approveopts.style.display = 'inline';
								var selecttypeobj = ld("#"+crmPopupobj.divid).find("[name=approveopts]");
								var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr('name'));
								cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
								cls_resetComboxHtmlobj.setComboxObjHtml();
								var selectwidth = Tools.getParentobjByChild(selecttypeobj,'td').width();
                				cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,selectwidth-105);
							}else{//非使用新流程状态，隐藏审批流程下拉框
								inputs.approveopts.style.display = 'none';
								ld("#"+crmPopupobj.divid).find("[name=dv_cmb_approveopts]").css('display','none');
							}
							ld("#"+crmPopupobj.divid+' [name=procecess_table_1]').css("display:none");//使用当前流程重新流转
							ld("#"+crmPopupobj.divid+' [name=procecess_table_2]').css("display:none");//使用新的流程重新流转
							ld("#"+crmPopupobj.divid).find("tr[tag=rowdata]").remove();
							ld("#"+crmPopupobj.divid+' tr[tag=tr_process').css("display",'none');
							ld("#"+crmPopupobj.divid+" [name=username_approver_1]").css('display','none');
							ld("#"+crmPopupobj.divid+" [name=username_approver_2]").css('display','none');
							ld("#"+crmPopupobj.divid+" [name=cancel_curprocessid]").css('display','none');
							ld("#"+crmPopupobj.divid+" [name=concurrentidStepCount]").val(1);
							ld("#"+crmPopupobj.divid+" [name=urgent]").prop("checked",false);
							ld("#"+crmPopupobj.divid+" [name=span_urgent]").css("display",'none');
							if(cancelapprovetype == 2){
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td1').addClass('padT8');
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td2').addClass('padT8');
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td3').addClass('padT8');
							}
							else{
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td1').removeClass('padT8');
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td2').removeClass('padT8');
								ld("#"+crmPopupobj.divid+' #cancelapprovetype2_td3').removeClass('padT8');
							}
							if(cancelapprovetype==2||cancelapprovetype==1){
								var tmp_approveid=0;
								if(cancelapprovetype==1){
									tmp_approveid=ld("#"+crmPopupobj.divid+" [name=curapproveid]").val();
									ld("#"+crmPopupobj.divid+" [name=cancel_curprocessid]").css('display','');
								}
								else{
									tmp_approveid=ld("#"+crmPopupobj.divid+" [name=approveopts]").val();
								}
							
								that.changeApproveStep(tmp_approveid,cancelapprovetype);
								
							}
							else{
								//切换到回撤上一步或返回初始状态时更新审批意见必填状态
								var requireobj =  ld("#"+crmPopupobj.divid+' input[name=requiretext]');
								if(requireobj.attr('stepvalue')=='yes'){
									ld("#"+crmPopupobj.divid+' font[name=markrequire]').css("display",'');
									requireobj.val('yes');
								}else{
									ld("#"+crmPopupobj.divid+' font[name=markrequire]').css("display",'none');
									requireobj.val('no');
								}
							}
							
						}
					}
				}
			}
			else if(data.code == -1){
				MessagePopup.TipOne_warning(data.msg);
				return false;
			}
			DelProgressObjs();
		})
	})
    this.changeApproveStep=function(tmp_approveid,cancelapprovetype){
        var crmPopupobj=CrmPopup.getPopupObj('last');
        ld("#"+crmPopupobj.divid+" [name=span_urgent]").css("display",'none');
        ld("#"+crmPopupobj.divid+" [name=urgent]").prop("checked",false);
        ldAjaxNoProgress("index.php?getnextstepinfo="+tmp_approveid+"&module=Approve&file=SubmitApprove&action=ApproveAjax&approve_recordid="+record,{},function(data){
           	ld("#"+popupobj.divid).find("tr[tag=rowdata]").remove();
           	if(data.result.approveinfo.showurgent=='yes')
            	ld("#"+crmPopupobj.divid+" [tag=urgent"+cancelapprovetype+"]").css("display",'');
           	ld("#"+popupobj.divid+" [name=isnewapprove]").val(data.result.isnewapprove);
           	ld("#"+popupobj.divid+" [name=concurrentidStepCount_cancel]").val(data.result.steplist.length);
           	var tableobj=ld("#"+popupobj.divid+' [name=procecess_table_'+cancelapprovetype+']');
           	ld(tableobj).css("display",'');
           	ld("#"+popupobj.divid+' tr[name=tr_process_'+cancelapprovetype+']').css("display",'');
           	//根据反审批选择的审批流程更新审批日志显示
           	ld("#"+popupobj.divid+" [name=submitapprovelog]").html(data.result.submitapprovelog);
           	var trhtml='';
           	//trhtml += '<tr tag="rowdata"><td align="right" style="width:100px">'+data.result.labels.stepname+'</td><td></td></tr>';
            ld.each(data.result.steplist,function(tmpindex,tmpinfo){
                trhtml+="<tr tag='rowdata'>";
                trhtml+='<td align="right" style="width:100px" class="padT16">'+arrJsPopLabel['APPROVALSTEP']+'</td>';
                trhtml+='<td class="padT16 padL10">';                 
                trhtml+='<input type="text" readonly=true class="ld-input-inner" name="nextstepname_'+tmpindex+'" value="'+tmpinfo.nextstepname+'">';
                trhtml+='<input type="hidden" name="nextstep_cancel_'+tmpindex+'" value="'+tmpinfo.stepid+'">';                 
                trhtml+='<input type="hidden" name="stepseq_cancel_'+tmpindex+'" value="'+tmpindex+'">';
                trhtml+='<input type="hidden" name="nextstep_countersigner_cancel_'+tmpindex+'" value="'+tmpinfo.countersigner+'"/>'
                trhtml+='<input type="hidden" name="nextstep_augmentsinger_cancel_'+tmpindex+'" value="'+tmpinfo.countersigner+'"/>';
                trhtml+='<input type="hidden" name="userid_name_cancel_'+tmpindex+'" id="userid_name_cancel_'+tmpindex+'" value="'+tmpinfo.newstepapprover+'"/>';
                trhtml+='<input type="hidden" name="userid_cancel_'+tmpindex+'" id="userid_cancel_'+tmpindex+'" value="'+tmpinfo.stepuserids+'"/>';
                trhtml+='<input type="hidden" name="allow_emptyapprover_'+tmpindex+'" value="'+tmpinfo.allow_emptyapprover+'"/>';
                trhtml+='</td>';
                trhtml+="</tr>";
                //zkt 1002441 审批，审批人添加框样式优化
                var tmpuserarr = tmpinfo.stepuseridtonamearr;
                trhtml += '<tr tag="rowdata" id="approvestep_selecttr_'+tmpindex+'" name="approvestep_selecttr_'+tmpindex+'" >';
                trhtml += '<td align="right" class="padT16">';
                if (tmpinfo.countersigner == 'yes')
                    trhtml+='<span tag="label_countersigner">'+data.result.labels.Countersigner+'</span>';
                else
                    trhtml+='<span tag="label_approver">'+data.result.labels.APPROVER+'</span>';
                trhtml += '</td>';
                trhtml += '<td class="ld-form-item-content padL10">';
                trhtml += '<div class="pubclear" id="before_approve_selectdiv_'+tmpindex+'">';
                trhtml += '<div class="CCrange ld-input-inner-div" id="approvers_div_'+tmpindex+'" name="approvers_div_'+tmpindex+'" tag="ccrange" style="overflow-y: auto;max-height:90px;">';
                trhtml += '<ul class="reader-bar-list ld-input-inner-div-items">';
                ld.each(tmpuserarr,function(id,name){
                    //zkt 20220607 52560001通用问题，审批弹框乱码
                    trhtml += "<li class='ld-input-inner-div-item' itemid='approver_"+tmpindex+"_"+id+"' title='"+name+"'>";
                    trhtml += '<span class="item-name">'+name+'</span>';
                    //可以选择审批人时显示
                    if(tmpinfo.specifyapproverid==0){
                        trhtml += '<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,\'userid_cancel_'+tmpindex+'\',\'userid_name_cancel_'+tmpindex+'\')">×</span>';
                    }
                    trhtml += '</li>';
                });
                trhtml += '</ul>';
                trhtml +='</div>';
                //可以选择审批人时显示
                if(tmpinfo.specifyapproverid==0){
                    trhtml += "<a class='ld-text-change' onclick='concurrentstepapprove_cancel_selectuser("+tmpindex+");'>"+arrJsPopLabel['replacement']+"</a>";
                }
                trhtml +=' </div></td></tr>';
            })
            ld(tableobj).append(trhtml);
            //选择重新开始流程时，更新审批意见必填状态
            if(data.result.approveinfo.markrequire =='yes'){
                ld("#"+popupobj.divid+' font[name=markrequire]').css("display",'');
                ld("#"+popupobj.divid+' input[name=requiretext]').val('yes');
            }else{
                ld("#"+popupobj.divid+' font[name=markrequire]').css("display",'none');
                ld("#"+popupobj.divid+' input[name=requiretext]').val('no');
            }
            popupobj.center();
           /*var spcifyapprove=data[2];
            var approveuserid=data[3];
            var approveusername=data[1];
            ld("#"+crmPopupobj.divid+" [name=username_approver_"+cancelapprovetype+"]").css('display','contents');
             ld("#userid_name_"+cancelapprovetype).html(approveusername);
             ld("#userid_name_"+cancelapprovetype).val(approveusername);
             ld("#approveuserid").val(approveuserid);
             ld("#"+popupobj.divid+" [tag=label_approver_1]").css("display",'none');
             ld("#"+popupobj.divid+" [tag=label_countersigner_1]").css("display",'none');
             ld("#"+popupobj.divid+" [tag=label_approver_2]").css("display",'none');
             ld("#"+popupobj.divid+" [tag=label_countersigner_2]").css("display",'none');
             if(data[4]=='yes'){
                //会签审批,修改标签名称
                ld("#"+popupobj.divid+" [tag=label_countersigner_"+cancelapprovetype+"]").css("display",'');
             }
             else{
                ld("#"+popupobj.divid+" [tag=label_approver_"+cancelapprovetype+"]").css("display",'');
             }
            if(spcifyapprove==0){//允许指定审批人
			
                ld("#"+crmPopupobj.divid+" [name=username_approver_"+cancelapprovetype+"]").unbind("click").bind("click",function(){
                    var fieldobj = {'selecttype':2,'selecetids':"approveuserid",'selecetids2':"userid_name_"+cancelapprovetype,'functiontype':'wareHouseselectUser','functype2':'approvestep','InactiveUser':'no'};
                    
                    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
                    ScopePopup_Details.getInstance().AllocateApplicationRange_Public(fieldobj);
                    });
                });
            }
            else{
                // ld("#"+crmPopupobj.divid+" [name=before_approve_select_"+cancelapprovetype+"]").css("display",'none');
                ld("#"+crmPopupobj.divid+" [name=username_approver_"+cancelapprovetype+"]").unbind("click");
                
            }*/
                            
        });
    }
	return false;
	
}


/**
edit:kevin
date:2013-09-10
reason:审批流程详情
*/
function approveSteps(record,module,approveid,stepid,obj,divid){
    new Ajax.Request("index.php",
    	{
    		queue:{
    			position:"end",
    			scope:"command"
    		},
    		method:"post",
    		postBody:"module=Approve&action=ApproveStepResult&fld_module="+module+"&record="+record+"&approveid="+approveid+"&stepid="+stepid,
    		onComplete:function (response) {   		           
              results=response.responseText.split("###SUCCESS###");    
                         
              $('approvestepresult').innerHTML=results[1];
              fnvshobj(obj,divid);
              //setPosition(obj,divid); 
              //Drag.init(document.getElementById("approvestep_div_title"), document.getElementById("approvestepresult"));     
    		}
    	});
}

/**
edit:kevin
date:2013-09-10
reason:审批历史
*/
function approveLogs(record,module,approveid,obj,divid){
    new Ajax.Request("index.php",
    	{
    		queue:{
    			position:"end",
    			scope:"command"
    		},
    		method:"post",
    		postBody:"module=Approve&action=ApproveAjax&file=ApproveLog&fld_module="+module+"&record="+record+"&approveid="+approveid,
    		onComplete:function (response) {
    		  results=response.responseText.split("###SUCCESS###");  
              //alert(results);             
              $('approvelog').innerHTML=results[1];
              fnvshobj(obj,divid);
              //setPosition(obj,divid); 
              //Drag.init(document.getElementById("approvelog_div_title"), document.getElementById("approvelog"));     
    		}
    	});
}


/**
*edit:kevin
*date:2013-09-16
reason:审批回撤
*/
function unApprove(record,fld_module,obj){
	//自动生成div反审批层
	var divid = 'cancelApproved';var divObj;
	if(0 == ld('#'+divid).length){//当层未创建时，创建层
		divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'D_pop_box LdPopWidth400px';
		divObj.style.display = "none";
		document.body.appendChild(divObj);
	}else{
		divObj = document.getElementById(divObj);
	}
	//fnvshobj(divObj, divid);//显示反审批层
	cancelApproved(record,fld_module,obj,divid,'1');//调用反审批方法
  
}
/*
edit:lmx
date:20140217
reason:转普通/转公海
0:转普通，1:转公海
*/
function detailconvertaccount(recordid,customtype)
{
    //请不要去掉注释，否则 转转普通会有错误
	/*if(customtype == 0){
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:"module=Accounts&record="+recordid+"&action=AccountsAjax&file=ConvertAccount&types=Account_deatil_view&customtype="+customtype,
				onComplete: function(response)
				 {
					$("status").style.display="none";
					if(empty(response.responseText)) return false;
					var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
					createElementDiv('massConvert');//创建DIV
					ld('#massConverttitlename').html(restobj.title.value);
					sethtml(document.getElementById('massConvertcontent'),restobj.log.value);
                   
					ld('#massConvert .D_pbtn .D_pbtncancel').css('display','none');
					fnvshobj(this,'massConvert');
					ld('#massConvert .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						if(restobj.error_num.value >= 1){
							fninvshnew('massConvert');puyoungJS_DialogBox.unblock();
							return false;
						}else{
							fninvshnew('massConvert');puyoungJS_DialogBox.unblock();
							window.location="index.php?module=Accounts&action=DetailView&record="+recordid;
						}
					});
					return false;
				 }
			}
	  );
	}else{*/
		//window.location="index.php?module=Accounts&record="+recordid+"&action=ConvertAccount&types=Account_deatil_view&customtype="+customtype;
	//}
	/*var surl = "index.php?module=Accounts&record="+recordid+"&action=AccountsAjax&file=ConvertAccount&types=Account_deatil_view&customtype="+customtype;

	ldAjax(surl,{},function(data){
		if(data.code == 1){
			
			var tmparra=new Array();
			tmparra.push(recordid);
			var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',getEmptyValueInfo(),tmparra);
            tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);
			tmpobj.eachrefreshlistbyModules(data.result.refreshdetailmodules);
	
			
			if(recordid>0)
			{
			//	tmpobj.update();//更新界面字段
			}
            DelProgressObjs();
		}
         
	})*/
	cls_PublicAccount.account_transfer(recordid);
   
    
}


// ****  整理EditView.js	**** ///
function selectContacts(check,type,frmName,related)
{   
	var record = document.getElementsByName("record")[0].value;
    /*if(type=='general'&& frmName.name=='EditView'){
        window.open("index.php?module=VendorContact&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&recordid="+record,"","width=840,height=602,resizable=0,scrollbars=0");
        return false;
    }*/
	if($("single_accountid"))
	{ 
		var potential_id = '';
        /**
        *bug 0009026: IE8浏览器：销售机会新增界面：联系人姓名“+”按钮点击，网页左下角报错
        *by andy 
        *others 先注释，引起问题再改
		//if(document.getElementById("potential_id")!=undefined)
		//	potential_id = frmName.potential_id.value;
        */
		account_id = frmName.account_id.value;
        var fromlink = '';
        /**
       *新增操作,销售机会增加 相关客户字段
       *date 20140320
       * by andy
       */
        var url=location.search;
        var Request = new Object();
        if(url.indexOf("?")!=-1)
        {
            var str = url.substr(1)  //去掉?号
            strs = str.split("&");
            for(var i=0;i<strs.length;i++)
            {
                Request[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
            }
        }
        /*
        if(Request["module"] == 'Potentials' )
            related_accountid = frmName.related_accountid.value;   
        */
     
		if(potential_id != '')
		{
			record_id = potential_id;
			module_string = "&parent_module=Potentials";
		}
		else
		{   if(related == '1')
            {
                record_id = account_id;
                module_string = "&parent_module=Accounts";
            }
            else
            {
                 if(frmName.related_accountid!=undefined)
                 {
                    account_id=frmName.related_accountid.value;
                    record_id = frmName.related_accountid.value;
                    
                 }
                 else
                 {
                    account_id=frmName.account_id.value;
                    record_id = frmName.account_id.value;
                 }
                fromlink = "&fromlink=qcreate";
                module_string = "&parent_module=Accounts";
            }
			
		};
        var fromModule = frmName.module.value;
		if(record_id != ''){
            window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&fromModule="+fromModule+"&form=EditView"+fromlink+"&accountid="+account_id+module_string+"&relmod_id="+record_id+"&related="+related,"","width=840,height=602,resizable=1,scrollbars=1");
		}else{
		    window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&fromModule="+fromModule+"&form=EditView"+fromlink+"&related="+related,"","width=840,height=602,resizable=1,scrollbars=1");
        }
	}
	else if(($("parentid")) && type != 'task')
	{
		if(getObj("parent_type")){
			rel_parent_module = frmName.parent_type.value;
			record_id = frmName.parent_id.value;
			module = rel_parent_module.split("&");
			if(record_id != '' && module[0] == "Leads")
			{
			     //无法从潜在客户选择相关联系人
				//alert(alert_arr.CANT_SELECT_CONTACTS);
			}
			else
			{
				if(check == 'true')
					search_string = "&return_module=Calendar&select=enable&popuptype=detailview&form_submit=false";
				else
					search_string="&popuptype=specific";
				if(record_id != '')
					//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string+"&relmod_id="+record_id+"&parent_module="+module[0],"test","width=840,height=602,resizable=0,scrollbars=0");
                    window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string+"&relmod_id="+record_id+"&parent_module="+module[0],"","width=840,height=602,resizable=1,scrollbars=1");
				else
					//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string,"test","width=840,height=602,resizable=0,scrollbars=0");
                    window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string,"","width=840,height=602,resizable=1,scrollbars=1");

			}
		}else{
			//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&return_module=Calendar&select=enable&popuptype=detailview&form=EditView&form_submit=false","test","width=840,height=602,resizable=0,scrollbars=0");
            window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&return_module=Calendar&select=enable&popuptype=detailview&form=EditView&form_submit=false","","width=840,height=602,resizable=1,scrollbars=1");
		}
	}
	else if(($("contact_name")) && type == 'task')
	{
		var formName = frmName.name;
		var task_recordid = '';
		if(formName == 'EditView')
		{
			if($("parent_type"))
			{
				task_parent_module = frmName.parent_type.value;
				task_recordid = frmName.parent_id.value;
				task_module = task_parent_module.split("&");
				popuptype="&popuptype=specific";
			}
		}
		else
		{
			if($("task_parent_type"))
			{
				task_parent_module = frmName.task_parent_type.value;
				task_recordid = frmName.task_parent_id.value;
				task_module = task_parent_module.split("&");
				popuptype="&popuptype=toDospecific";
			}
		}
		if(task_recordid != '' && task_module[0] == "Leads" )
		{
		    //无法从潜在客户选择相关联系人
			//alert(alert_arr.CANT_SELECT_CONTACTS);
		}
		else
		{
			if(task_recordid != '')
				//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker"+popuptype+"&form="+formName+"&task_relmod_id="+task_recordid+"&task_parent_module="+task_module[0],"test","width=840,height=602,resizable=0,scrollbars=0");
                window.open("index.php?module=Contacts&action=Popup&html=Popup_picker"+popuptype+"&form="+formName+"&task_relmod_id="+task_recordid+"&task_parent_module="+task_module[0],"","width=840,height=602,resizable=1,scrollbars=1");
			else
				//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form="+formName,"test","width=840,height=602,resizable=0,scrollbars=0");
                window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form="+formName,"","width=840,height=602,resizable=1,scrollbars=1");
		}

	}
	else
	{
	   
        if(document.getElementById('vendor_id')!=undefined)
        {
                var vendorid=document.getElementById('vendor_id').value;
                window.open("index.php?module=VendorContact&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&vendorid="+vendorid,"","width=840,height=602,resizable=1,scrollbars=1");
        }
        else
        {
            window.open("index.php?module=VendorContact&action=Popup&html=Popup_picker&popuptype=specific&form=EditView","","width=840,height=602,resizable=1,scrollbars=1");
        }
        
	}
}
function deleteProducts(module,record){
	var url = 'module='+module+'&action=Delete&return_action=ListView&record='+record;
    url += '&return_module='+module;
	ldAjaxHtmlNoProgress('index.php?',url+'&inven_product=yes',function(response) {
		$("status").style.display="none";
		var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
		if(restobj.stype.value == 'success'){
			//chj 2021/3/5 44699: （61mis.com/kfbcrm）工具-产品管理-详情；在详情界面操作删除产品后，页面自动刷新回到了首页
			RequestAjax(url,function(rest){
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				if(restobj.code == 1){
					workflowSyncPop(restobj.result);

					var popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
					popupobj.CancelEvent();//关闭查看界面

					var tmparra={};
					var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
					var tmpmodules=[module];//先这样吧有问题再修改（理论上应该有后台返回，例如删除出库，可能要更新合同订单列表的已出库数量）
					tmpobj.eachrefreshlistbyModules(tmpmodules);

				}else{
					MessagePopup.TipOne_warning(restobj.msg);
				}
				DelProgressObjs();
			});
		}else{
			MessagePopup.TipOne_warning(restobj.log.value);
		}
		return false;
	});
}
function deleteAccount(module,record){
	var url = 'module='+module+'&action=DeleteSet&return_action=ListView&record='+record;
	url += '&return_module='+module;
	ldAjaxHtmlNoProgress('index.php?',url,function(data) {
		$("status").style.display="none";

		var restobj = eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);


		if(restobj.code == 1){
			workflowSyncPop(restobj.result);

			// var popupobj=CrmPopup.getPopupObj('last');
			var popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
			popupobj.CancelEvent();//关闭查看界面

			var tmparra={};
			var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
			var tmpmodules=[module];//先这样吧有问题再修改（理论上应该有后台返回，例如删除出库，可能要更新合同订单列表的已出库数量）
			tmpobj.eachrefreshlistbyModules(tmpmodules);
			DelProgressObjs();


		}else{
			MessagePopup.TipOne_warning(restobj.log.value);

		}
		return false;
	});
}

//菜单风格 保存
function saveMenuStyleColpick(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid = popupobj.divid;
	var menuback = '';
	var menuhover = '';
	var menufont = '';
	var background = '';
	var radio_menustyle = ld("#"+divid+" [name^=menustyle_].checkMenuStyle").attr('menustyle');
	if(radio_menustyle == 'custom'){//自定义
		var hexColorRegex = /^#[0-9a-fA-F]+$/;//验证颜色有效性
		menuback = CrmPopup.findHtmlobj(divid,'input_menuback').val();
		if(!hexColorRegex.test(menuback)){
			MessagePopup.TipOne_warning(arrJsPopLabel['entervalidcolor']);
			return false;
		}else{
			menuback = menuback.replace('#','');
		}
		menuhover = CrmPopup.findHtmlobj(divid,'input_menuhover').val();
		if(!hexColorRegex.test(menuhover)){
			MessagePopup.TipOne_warning(arrJsPopLabel['entervalidcolor']);
			return false;
		}else{
			menuhover = menuhover.replace('#','');
		}
		menufont = CrmPopup.findHtmlobj(divid,'input_menufont').val();
	}else if(radio_menustyle == 'lightcolour'){	//浅色版  白色
		menuback = 'FFFFFF';
		menuhover = 'EFF4FF';
		menufont = '3B4859';
	}else if(radio_menustyle == 'dark'){	//深色版 蓝色
		menuback = '3B7CFF';
		menuhover = '4E89FF';
		menufont = 'FFFFFF';
	} else if(radio_menustyle == 'red'){	//红色
		menuback = 'F26D78';
		menuhover = 'F4848D';
		menufont = 'FFFFFF';
	} else if(radio_menustyle == 'black'){	//黑色
		menuback = '13121F';
		menuhover = '2B2A35';
		menufont = 'FFFFFF';
	}
	//自定义背景色
	var radio_background = ld("#"+divid+" [name^=menubackground_].checkMenuStyle").attr('background');
	if(radio_background == 'bg1'){
		background = 'F2F5FB';
	}else if(radio_background == 'bg2'){
		background = 'E4E7ED';
	}else if(radio_background == 'bg3'){
		background = 'EBEEF4';
	} else if(radio_background == 'bg4'){
		background = 'DDDFE5';
	}
	var urlstring = 'index.php?module=Users&action=UsersAjax&file=updateColpickCss&ajax=true&menuback='+menuback+'&menuhover='+menuhover+'&menustyle='+radio_menustyle+'&background='+background+'&menufont='+menufont;
	ldAjax(urlstring,"",function(data){
		if(data.code == 1){
			// MessagePopup.TipOne_success(arrJsPopLabel['SUCCESSFULLYMODIFIED']);
			// ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			// 	popupobj.CancelEvent();
			// 	window.location.reload();
			// })
			MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYMODIFIED']);
			setTimeout(function () {
				window.location.reload();
			},500);
			DelProgressObjs();
		}
	})
}
//设置好微信小程序后，根据按钮类型，再次生成不同的二维码弹窗
function edit_miniprogrambytype(type){
	//取消上一个弹窗
	var popupobj = CrmPopup.getPopupObj('last');
	//获取按钮类型
	popupobj.CancelEvent();
    getJsScript("include/js/modules/Settings/wechat_miniprogram_setting.js",function(){ 
       //点击生成编辑微信小程序二维码窗口
        wechat_miniprogram_setting.edit(type);
    });
}
