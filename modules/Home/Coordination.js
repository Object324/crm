
//节点加载事件，在onload之前
ld(function(){
	// 判断当前浏览器是否支持indexOf、remove事件，不支持则添加
	if(typeof Array.indexOf !== 'function'){//数组包含
		Array.prototype.indexOf = function(args){
			var index = -1;
			for(var i=0,l=this.length;i<l; i++){
				if(this[i] === args){
					index = i;
					break;
				}
			}
			return index;
		}
	}
	String.prototype.len = function(){// 给string增加个len ()方法，计算string的字节数
		return this.replace(/[^\x00-\xff]/g,"xx").length;
	}
	if(homecontrol != undefined){
		if(1 == homecontrol){
			isword = 2;
			initWordReport();//
		}else if(0 == homecontrol){
			iswidget = 2;
			initWidgets();
		}
	}
   
});
//选择抄送范围事件
setEventSelectUser = function(div_tag,selectNum,selectUserid){
	var module = 'CooperativeWork';
	var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=checkbox';
	var popup_header = '<p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput"  id=\'popup_locationdiv\' value=\''+arrJsPopLabel['searchforcolleagues']+'\'></p>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var scopepopupobj =  new ScopePopupObj(module);
		scopepopupobj.popup_caption_value =arrJsPopLabel['LBL_SELECTUSER'];//标题
		scopepopupobj.popup_searchvalue = arrJsPopLabel['searchforcolleagues'];//查询框默认值
		scopepopupobj.popup_header = popup_header;
		scopepopupobj.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 75px;\'><div class=\'view-search\' ></div></div>';
		scopepopupobj.popup_footer = '<div class="D_pbtn"><div>已选<span id="selectnum">0</span>/<span id="totalnum">77</span></div><div><input class="D_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+'<input class="D_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div></div>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			cls_ScopePopup.prop.popup_module = module;//模块
			cls_ScopePopup.prop.popup_value = selectUserid;
			var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
			//加载用户总数和已选的用户数
			scopepopupobj.setEventLoad=function(){
				var selectUseridAll = [];//显示的全部用户数
				var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
				//alert(cls_ScopePopup.popup_divid);
				ld('#'+cls_ScopePopup.popup_divid+' .filetree span').each(function(){
					var record = ld(this).attr('record');
					var recordarr = record.split('_');
					//处理用户图标
					if('user' == recordarr[0]){
						//ld(this).attr('class','user');
						var parentfilter = ld(this).attr('parent');
						var parentarr = parentfilter.split('_');
						if('Inactive' != parentarr[1] &&  'Inactive' != parentarr[2]){//因为停用用户不显示，所以在这不进行计算
							if('nogroup' == parentarr[1]){
								/*if(!viewuser_nogroupuser){//false
									if(ld('#viewuser_disableuser').prop("checked")==true){
										selectUseridAll[selectUseridAll.length] = recordarr[1];
									}
								}else{*/
									selectUseridAll[selectUseridAll.length] = recordarr[1];
								//}
							}else{
								selectUseridAll[selectUseridAll.length] = recordarr[1];
							}
						}
					}
				});
				var userAll = js_unique(selectUseridAll);
				ld('#selectnum').html(selectNum);//已选
				ld('#totalnum').html(userAll.length);//全部
				ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
					cls_ScopePopups.noGroupUser('viewuser_nogroupuser');
					if(!empty(cls_ScopePopup.return_obj.return_id)){
						var userid = cls_ScopePopup.return_obj.return_id.split(',');
						selectNum = userid.length;//已选
					}else{
						selectNum = 0;
					}
					scopepopupobj.setEventLoad();
				});
			}
			//用户选择后的执行事件
			scopepopupobj.setEventSelGroupByUsers=function(){
				if(!empty(cls_ScopePopup.return_obj.return_id)){
					var userid = cls_ScopePopup.return_obj.return_id.split(',');
					ld('#selectnum').html(userid.length);//已选
				}else{
					ld('#selectnum').html(0);
				}

			}
			//重写确认按钮事件
			scopepopupobj.setEventBtnOk=function(){
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					//基本查询 - 发起人
					if(div_tag == '_select_sponsor_div'){
						ld('.D_pbtn .D_pbtncancel').click();
						var userid = cls_ScopePopup.return_obj.return_id.split(',');
						var _name;
						ld('#'+div_tag+' ul.reader-bar-list').empty();
						//一个用户
						if(userid.length == 1){
							_name = cls_ScopePopup.return_obj.return_name;
						}else{
							_name = userid.length +'个同事';
						}
						ld('#'+div_tag+' ul.reader-bar-list').append('<li><span class="item-name">'+_name+'</span><span class="remove-h">×</span></li>');
						ld('#'+div_tag+' ul.reader-bar-list li .remove-h').unbind('click').click(function(){
							ld('#'+div_tag+' ul.reader-bar-list li').remove();
							ld('#sponsor_value').val('');
							fun_search();
							return false;
						});
						ld('#sponsor_value').val(userid);
						fun_search();
					}else{
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}else{
							ld('.D_pbtn .D_pbtncancel').click();
							var userid = cls_ScopePopup.return_obj.return_id.split(',');
							var username = cls_ScopePopup.return_obj.return_name.split(',');
							//每次确认之前，先情况之前记录
							ld('#'+div_tag+' ul.reader-bar-list').empty();
							for(var i = 0; i < userid.length; i++){
								//添加新的li
								ld('#'+div_tag+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
								//绑定删除事件
								ld('#'+div_tag+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
									var liuserid = ld(this).parent().attr('userid');
									ld('#'+div_tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
									return false;
								});
							}
						}
					}
				});
			}
		});
	});
}

var cur_panel='sendWeibo';//设置当前点击的面板tag的属性值
var old_panel = '';
var panelEmptyText={'sendWeibo':'发布微博…','cocmd':'发布任务…','sendLog':'请填写工作心得体会'};
var pop_obj_coordinate=null;//弹出层对象
var pop_num = 0;//弹出层打开时，是否关闭其他弹出层 0是  1否
function setPanelShow(){
	ld('.form-thumb').addClass('ui-hide');
	ld('#sendLog').removeClass('ui-hide');
	ld('#sendLog div[tag=workfield] div[entitytype]').addClass('ui-hide');
	ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+']').removeClass('ui-hide');
	ld('.panel-visible-h,.pub_btn').css('display','block');//显示X图标、发布按钮
	ld('#sendLogFoot > div').not('.CCrange').addClass('ui-hide');//隐藏所有的控件层
	ld('#sendLogFoot > div.'+cur_panel+'').removeClass('ui-hide');//显示对应的层
	//光标移入第一个textarea
	var text_area=ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div:eq(0) textarea').eq(0);
	//将光标移动到输入框最后面
	var text_area_val=text_area.val();text_area.val('').focus().val(text_area_val);
	//ld('textarea').autosize();//监控输入内容的高度变化
	setTimeout(function() {
		if(cur_panel == 'sendWeibo' || cur_panel == 'cocmd'){
			ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] textarea').autosize();//监控输入内容的高度变化
			ld('#sendLog div[tag=workfield] div[entitytype=saleskit]').addClass('ui-hide');
		}
		else{
			var sendlog_date = '';
			ld('#sendLog div[tag=workfield] div[entitytype=saleskit]').removeClass('ui-hide');
			var worktype = '';
			ld('#stream-hsent-title a').each(function(){
				if(ld(this).attr('class') == 'curr'){
					//console.log(ld(this).attr('tag'));
					worktype = 'worktype_1';
					if(ld(this).attr('tag') == 'day'){
						ld('#saleskit_this_week').hide();
						ld('#saleskit_last_week').hide();
						ld('#saleskit_this_month').hide();
						ld('#saleskit_last_month').hide();
						worktype = 'worktype_1';
						sendlog_date = getNowDate();
						var deploy_value = ld('#deploy_value').val();
						if(deploy_value != 1){
							var saleskit_date_html = '<a type="text" style="width:110px;height:25px;line-height:25px;" size="15" name="sendlog_saleskit_date" id="sendlog_saleskit_date" onclick="WdatePicker()">'+sendlog_date+'</a>';
							ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(saleskit_date_html);
						}else{
							ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
						}
					}
					else if(ld(this).attr('tag') == 'week'){
						ld('#saleskit_this_week').show();
						ld('#saleskit_this_week').css('color','red');
						ld('#saleskit_last_week').show();
						ld('#saleskit_last_week').css('color','');
						ld('#saleskit_this_month').hide();
						ld('#saleskit_last_month').hide();
						worktype = 'worktype_2';
						var begin_date = getWeekStartDate();
						var end_date = getWeekEndDate();
						sendlog_date = begin_date +' ~ '+end_date;
						ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
					}
					else if(ld(this).attr('tag') == 'month'){
						ld('#saleskit_this_week').hide();
						ld('#saleskit_last_week').hide();
						ld('#saleskit_this_month').show();
						ld('#saleskit_last_month').show();
						ld('#saleskit_this_month').css('color','red');
						ld('#saleskit_last_month').css('color','');
						worktype = 'worktype_3';
						var begin_date = getMonthStartDate();
						var end_date = getMonthEndDate();
						sendlog_date = begin_date +' ~ '+end_date;
						ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
					}
					ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type='+worktype+'] textarea').autosize();//监控输入内容的高度变化
				}
			});
			//工作汇报：工作协同
			//alert("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit&sendlog_date="+sendlog_date);
			getSendLog_SalesKit(sendlog_date);
			//监听变更内容事件
			ld("#sendlog_saleskit_date").bind("DOMNodeInserted",function(e){
				var this_value = ld(e.target).html();
				getSendLog_SalesKit(this_value);
			})
		}
	}, 100);
	if('sendLog' == cur_panel){
	   //
		//ld('.endmenu > ul > li.linebg').click();
		if(ld('.settingfield').length > 0)
			ld('.settingfield').removeClass('ui-hide');
	}else{
		if(ld('.settingfield').length > 0)
			ld('.settingfield').addClass('ui-hide');
	}

}
var texttag = '';
function getSendLog_SalesKit(sendlog_date){
	ld.ajax("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit&sendlog_date="+sendlog_date)
	.done(function(results){
		var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
		var saleskit = new Array('Leads','Accounts','Contacts','Potentials','ContactRecords','SalesOrder','ServiceContracts','CashBill','Singin');
		ld.each(saleskit,function(index,smodule){
			ld('#sendLog div[tag=workfield] div[entitytype=saleskit] span[tag=create_span_'+smodule.toLowerCase()+']').unbind('click');
			if(restobj.list[smodule] == undefined){
				ld('#sendLog div[tag=workfield] div[entitytype=saleskit] div[tag=div_'+smodule.toLowerCase()+']').hide();
			}else{
				var values = restobj.list[smodule];
				ld('#sendLog div[tag=workfield] div[entitytype=saleskit] span[tag=create_span_'+smodule.toLowerCase()+']').html(values.nums);
				ld('#sendLog div[tag=workfield] div[entitytype=saleskit] div[tag=span_transtab_'+smodule.toLowerCase()+']').html(values.label);
				//alert(values.nums + '---'+values.label);
				//if(values.nums > 0){
					ld('#sendLog div[tag=workfield] div[entitytype=saleskit] span[tag=create_span_'+smodule.toLowerCase()+']').on('click',function(){
						if(smodule == 'Singin'){
							url = 'index.php?module=OftenUseReport&action=ListView&UseReport=25&worktype='+worktype+'&sendlog_date='+sendlog_date;
							window.open(url); 
						}else{
							//alert("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_Target&sendlog_date="+sendlog_date+"&worktype="+worktype+"&frommodule="+smodule);
							ld.ajax("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_Target&sendlog_date="+sendlog_date+"&worktype="+worktype+"&frommodule="+smodule)
							.done(function(){
								url = 'index.php?module='+smodule+'&action=ListView&query_session=1';
								window.open(url); 
							})
						}
						//
					});
					
				}
			//}
		});
	})
}
/**
 * 绑定工作协同节点事件（页面加载初始化）
 * @author Tujt 2015-01-30
 */
function initWordReport(){
    if(ld('#stream-hsent-title')==undefined||ld('#stream-hsent-title').length<=0)
    {
        return false;
    }
   
	var titlewidtth = parseInt(ld('#stream-hsent-title > li > a:first-child').offset().left)-parseInt(ld(".menuUl").offset().left)+parseInt(25);
	ld('.trigger_bg').css('left',titlewidtth+'px');//移动上角图标
	ld('.trigger_bg span').removeClass('ui-hide');
	cur_panel=ld('#stream-hsent-title > li > a:first-child').attr("cont");
	ld('.Showselect').css('display','none');
    ld("#stream").smartFloat();
	//本周
    ld('#saleskit_this_week').click(function(){
		ld('#saleskit_this_week').css('color','red');
		ld('#saleskit_last_week').css('color','');
		var begin_date = getWeekStartDate();
		var end_date = getWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上周
	ld('#saleskit_last_week').click(function(){
		ld('#saleskit_this_week').css('color','');
		ld('#saleskit_last_week').css('color','red');
		var begin_date = getLastWeekStartDate();
		var end_date = getLastWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//本月
    ld('#saleskit_this_month').click(function(){
		ld('#saleskit_this_month').css('color','red');
		ld('#saleskit_last_month').css('color','');
		var begin_date = getMonthStartDate();
		var end_date = getMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上月
    ld('#saleskit_last_month').click(function(){
		ld('#saleskit_this_month').css('color','');
		ld('#saleskit_last_month').css('color','red');
		var begin_date = getLastMonthStartDate();
		var end_date = getLastMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
    //1、绑定 发微博、发日志、发任务、发审批点击事件
	ld('#stream-hsent-title > li > a').click(function(){
		ld('#selectbox_datebox').hide();
		var titlewidtth = parseInt(ld(this).offset().left)-parseInt(ld(".menuUl").offset().left)+parseInt(25);
		ld('#stream-hsent-title > li > a').removeClass('curr');//取消所有标签样式
		ld(this).addClass('curr');//给当前标签添加点击样式		
		old_panel = cur_panel;
		cur_panel = ld(this).attr('cont');//获取当前
		ld('.trigger_bg').css('left',titlewidtth+'px');//移动上角图标
		//ld('#'+cur_panel).css('display','');
		getSendLogCcrange(cur_panel);
		setPanelShow();
		//alert(cur_panel);
        if(cur_panel=='sendLog')
        {
            ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type]').addClass('ui-hide');
        		var type = typeobj[ld(this).attr('tag')];
            
        		ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+']').removeClass('ui-hide');
				//0032248: 工作协同：从微博切换到日志等模块的时候，光标应该定在第一个输入框当中。
				var _i = 1;
				ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+'] fieldset').each(function(){
					
                    var _Name = ld(this).find('textarea').attr('name');
					if(_i == 1){
                       //32259:客户明细>相关信息>工作汇报：点击后工作汇报后，微博文本框默认显示不正确
						ld('#sendLog [name='+_Name+']').focus();
					}
                    
					_i++;
                    
				});
        		//切换日周月小图标字样
        		//ld('.endmenu > ul > li').attr('class','');
        		//ld(this).attr('class','linebg');
				
        }
       
       
        if(document.getElementById('raccount_id')!=null&&document.getElementById('raccount_id')!=undefined&&document.getElementById('raccount_id').value>0 && ld("#dtlview_accountname").html() != undefined)
            
             {
                 setAccountInfo(document.getElementById('raccount_id').value,ld("#dtlview_accountname").html());
                
             }
        else if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='')
        {
            
            setContactInfo(document.getElementById('rcontact_id').value,ld("#dtlview_lastname").html());
           
        }
		
	});
     
	// 点击弹出编辑窗口
	ld('.form-thumb').click(function(){
		ld('#selectbox_datebox').hide();
		setPanelShow();
        
        if('sendLog' == cur_panel)
        {
       
           //32425: 客户、联系人明细界面：相关信息-工作汇报中，点击“日志”“周计划”“月计划”，结果1.没有打开录入框
           
            /*if(document.getElementById('raccount_id')!=null&&document.getElementById('raccount_id')!=undefined&&document.getElementById('raccount_id').value>0)
            {
                
            }
            else  if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='')
            {
                
            }
             else*/
             
                 ld('#stream-hsent-title [class=curr]').click();
        }
	});
    
   
    
	//X图标关闭编辑框点击事件
	ld('.panel-visible-h').click(function(){
		ld('#sendLog').addClass('ui-hide');
		ld('.form-thumb').removeClass('ui-hide');
		ld('.panel-visible-h,.pub_btn').css('display','none');
		ld('div.pubclear div.input-empty-text').html(panelEmptyText[cur_panel]);
	});
    
    
    //编辑框收缩展开end
    
	//ld('#stream-hsent-title > li > a[cont=sendLog]').click();//激发一下发日志事件
	// ld('textarea').autosize();//textarea根据内容自动调整大小
	//textarea绑定光标移入事件，记录光标的位置
	setUpload();

	
	ld('#sendLog textarea.sendLog').focus(function(){
		texttag = ld(this);
	});
	ld(".ui-mask").unbind('click').on('click', function (){
		 ld(".ui-mask").css({'display':'none','backgroundColor':'#fff'});
		 ld('.ui-popup-close').each(function(){
		 	if(!ld(this).is(':hidden')){
		 		ld(this).click();
		 	}
		 });
	});
	//用户组件
	ld('#sendLog .btns .addtouch').click(function(event){
		//添加透明背景遮罩
		ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
		var e = event || window.event;
		var obj = e.srcElement||e.target;
		//再次点击时，清空文本框内的值
		ld('#searchColleagueText').val('');
		//再次点击时。触发文本框的onkeyup事件
        //26940: 工作协同：发日志，工作心得体会里输入内容后再@用户，结果覆盖掉了原来输入的内容，当把当前内容清空后重新@，还会带入之前@的用户
		//if(isuserinit == 1){
		//	ld('#searchColleagueText').trigger("onkeyup");
		//}
		UserPopupInit(obj,event,function(){//加载用户选择层
         
			if('' != ld('#ColleagueDiv').html()){
				//用户弹出框样式绑定
				ld('#ColleagueDiv > div').unbind('click').click(function(){
				   
					if('' == texttag) texttag = 'Today';//默认到今日总结文本域
					ld(texttag).val(
						ld(texttag).val() + '@' +ld(this).find('span').html()+' '
					);
					//ld('#sendLog textarea[tag='+texttag+']').val(ld('#sendLog textarea[tag='+texttag+']').val()+'@'+ld(this).find('span').html()+' ');
					var atuser = ld('[name=sendLog]').find('[name=sendLog_at_user]').val();
					atuser += ld(this).attr('userid')+',';
                    
					ld('[name=sendLog]').find('[name=sendLog_at_user]').val(atuser);
				});
			}
			if('' != ld('#DepartmentDiv').html()){
				//用户弹出框样式绑定
               
				ld('#DepartmentDiv > div').unbind('click').click(function(){
					// if('' == texttag) texttag = 'Today';//默认到今日总结文本域
					// ld('#sendLog textarea[tag='+texttag+']').val(ld('#sendLog textarea[tag='+texttag+']').val()+'@'+ld(this).find('span').html()+' ');
                         
					ld(texttag).val(
						ld(texttag).val() + '@' +ld(this).find('span').html()+' '
					);

					var atuser = ld('[name=sendLog]').find('[name=sendLog_at_group]').val();
					atuser += ld(this).attr('groupid')+',';
					ld('[name=sendLog]').find('[name=sendLog_at_group]').val(atuser);
				});
			}
			ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
			ld('.usercontrol > li[tag=Department]').css('display','none');//显示部门标签
			ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
			ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
			ld('#searchColleagueText').css('display','none');//隐藏搜索框
			//用户搜索框placeholder属性赋值
			ld('#searchColleagueText').css('display','');//显示搜索框
			ld('#searchColleagueText').attr('placeholder','搜索同事');
			ld('#searchColleagueText').attr('tag',5);//1 发任务 2发日志 3@
			ld('#searchColleagueText').focus();
		});
	});
    //添加表情
	ld('#sendLog .btns .addemojicookie').click(function(event){
	   	//添加透明背景遮罩
		ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
	var e = event || window.event;
		var obj = e.srcElement||e.target;
		emojicookiePopupInit(obj,event,function(){//加载表情选择层
				//用户弹出框样式绑定
				ld('#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
					ld(texttag).val(
         
						ld(texttag).val() +'['+ld(this).attr('data-name')+']'
					);
				});
		});
        }); 
    //关联客户
	ld('#sendLog .btns .addcustomer').click(function(event){
		//window.open("index.php?module=Accounts&action=Popup&popuptype=specific_account_address_pop&form=TasksEditView&form_submit=false&fromlink=&fromModule=Contacts&related=1","testHomeContacts","width=840,height=602,resizable=1,scrollbars=1");
		
		var surl = "module=Accounts&action=Popup&popuptype=specific_account_address_pop&form=TasksEditView&form_submit=false&fromlink=&fromModule=Contacts&related=1&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Accounts');
		
	});
	//关联联系人
	ld('#sendLog .btns .addcontact').click(function(event){
		//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific_contact_address_pop&fromModule=ContactRecords&form=EditView","testHomeContacts","width=840,height=602,resizable=1,scrollbars=1");
		var surl = "module=Contacts&action=Popup&html=Popup_picker&popuptype=specific_contact_address_pop&fromModule=CooperativeWork&form=EditView&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Contacts');
	});
    //关联产品
	ld('#sendLog .btns .addproducts').click(function(event){
		//window.open("index.php?module=Products&action=Popup&html=Popup_picker&popuptype=specific&fromModule=CooperativeWork&form=EditView","testHomeContacts","width=840,height=602,resizable=1,scrollbars=1");
		var surl = "module=Products&action=Popup&html=Popup_picker&popuptype=specific&fromModule=CooperativeWork&form=EditView&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Products');
	});
	//绑定用户弹出层点击事件
	ld('.usercontrol > li').click(function(){
		var tag = ld(this).attr('tag');
		ld('.usercontrol li').each(function(){
			if(ld(this).attr('tag') == tag){
				ld(this).attr('class','On');
				ld('#'+tag+'Div').css('display','');
			}else{
				ld(this).attr('class','');
				ld('#'+ld(this).attr('tag')+'Div').css('display','none');
			}
		});
	});
	//日周月计划标签绑定事件
	var typeobj = {'day':1,'week':2,'month':3};
	ld('.endmenu > ul > li').click(function(){
		ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type]').addClass('ui-hide');
		var type = typeobj[ld(this).attr('tag')];
		ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+']').removeClass('ui-hide');
		//切换日周月小图标字样
		ld('.endmenu > ul > li').attr('class','');
		ld(this).attr('class','linebg');
		
	});

	//editor:gyqX160717 reason：点评人初始绑定  date:2016 07 17  Bug:0022891: 工作协同：发布日志，点击默认的点评人右方的【×】按钮，弹出选择层
	ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list .remove-h').unbind('click').click(function(){
		ld(this).parent().remove();
		return false;
	});
	ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list .remove-h').unbind('click').click(function(){
		ld(this).parent().remove();
		return false;
	});
	//批阅人事件绑定 input.input-field
	ld('#sendLogFoot > div[tag=reader] div.selectbar *').click(function(event){
		//再次点击时，清空文本框内的值
		ld('#searchColleagueText').val('');
		//再次点击时。触发文本框的onkeyup事件
		if(isuserinit == 1){
			ld('#searchColleagueText').trigger("onkeyup");
		}
		//添加透明背景遮罩
		ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
		// var e = event || window.event;
		// var obj = e.srcElement||e.target;
		//点击选择点评人链接时，show-select-panel对象点击事件
		//obj = ld('#sendLogFoot > div[tag=reader] div.selectbar .show-select-panel').get(0);
		obj=ld('#sendLogFoot > div[tag=reader] div.selectbar').get(0);
		if('remove-h' == ld(obj).attr('class')){
			return false;
		}
		ld('#sendLogFoot > div[tag=reader] input.input-field').removeClass('ui-hide');
		ld('#sendLogFoot > div[tag=reader] input.input-field').addClass('ui-show');
		//if('show-select-panel' != ld(obj).attr('class')){
			//ld('#sendLogFoot > div[tag=reader] .input-tip').css('display','none');
			//ld('#sendLogFoot > div[tag=reader] input.input-field').focus();
			//ld('#sendLogFoot > div[tag=reader] div.selectbar .show-select-panel').click();
		//}else{
			UserPopupInit(obj,event,function(){//加载用户选择层

               
                
				if('' != ld('#ColleagueDiv').html()){
					//用户弹出框样式绑定
					ld('#ColleagueDiv > div').unbind('click').click(function(){
						//清空ul下面的li标签
						ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li').remove();
						//添加新的li
						ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list').append('<li userid="'+ld(this).attr('userid')+'" emptype="p"><span class="item-name">'+ld(this).find('span').html()+'</span><span class="remove-h">×</span></li>');
						ld('#sendLogsmownerDiv').find('.ui-popup-close').click();
						//绑定删除事件
						ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list .remove-h').unbind('click').click(function(){
							var liuserid = ld(this).parent().attr('userid');
							ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li[userid='+liuserid+']').remove();
							return false;
						});
					});
				}
				ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
				ld('.usercontrol > li[tag=Department]').css('display','none');//隐藏部门标签
				ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
				ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
				//用户搜索框placeholder属性赋值
				ld('#searchColleagueText').css('display','');//显示搜索框
				ld('#searchColleagueText').attr('placeholder','搜索同事');
				ld('#searchColleagueText').attr('tag',2);//1 发任务 2发日志
				ld('#searchColleagueText').focus();
			});
		//}
	});
	//点评人 input文本框，光标移除 ，显示选择点评人字样
	ld('#sendLogFoot > div[tag=reader] input.input-field').blur(function(){
		ld('#sendLogFoot > div[tag=reader] input.input-field').removeClass('ui-show');
		ld('#sendLogFoot > div[tag=reader] input.input-field').addClass('ui-hide');
		ld('#sendLogFoot > div[tag=reader] .input-tip').css('display','');
	});
    
    
    
    	//执行人事件绑定 input.input-field
	ld('#sendLogFoot > div[tag=cmduser] div.selectbar *').click(function(event){
		//添加透明背景遮罩
		ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
		//再次点击时，清空文本框内的值
		ld('#searchColleagueText').val('');
		//再次点击时。触发文本框的onkeyup事件
		if(isuserinit == 1){
			ld('#searchColleagueText').trigger("onkeyup");
		}
      
		//var e = event || window.event;
		//var obj = e.srcElement||e.target;
		//点击选择执行人链接时，show-select-panel对象点击事件
		//obj = ld('#sendLogFoot > div[tag=cmduser] div.selectbar .show-select-panel').get(0);
		obj = ld('#sendLogFoot > div[tag=cmduser] div.selectbar').get(0);
		// if('remove-h' == ld(obj).attr('class')){
		// 	return false;
		// }
		ld('#sendLogFoot > div[tag=cmduser] input.input-field').removeClass('ui-hide');
		ld('#sendLogFoot > div[tag=cmduser] input.input-field').addClass('ui-show');
		//if('show-select-panel' != ld(obj).attr('class')){
			//ld('#sendLogFoot > div[tag=reader] .input-tip').css('display','none');
			//ld('#sendLogFoot > div[tag=reader] input.input-field').focus();
			//ld('#sendLogFoot > div[tag=cmduser] div.selectbar .show-select-panel').click();
		//}else{
			UserPopupInit(obj,event,function(){//加载用户选择层
				if('' != ld('#ColleagueDiv').html()){
					//用户弹出框样式绑定
					ld('#ColleagueDiv > div').unbind('click').click(function(){
						//清空ul下面的li标签
						ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li').remove();
						//添加新的li
						ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list').append('<li userid="'+ld(this).attr('userid')+'" emptype="p"><span class="item-name">'+ld(this).find('span').html()+'</span><span class="remove-h">×</span></li>');
						//绑定删除事件
						ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list .remove-h').unbind('click').click(function(){
							var liuserid = ld(this).parent().attr('userid');
							ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li[userid='+liuserid+']').remove();
							return false;
						});
					});
				}
				ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
				ld('.usercontrol > li[tag=Department]').css('display','none');//隐藏部门标签
				ld('.usercontrol > li[tag=Colleague]').css('display','none');//隐藏同事标签
				ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
				//用户搜索框placeholder属性赋值
				ld('#searchColleagueText').css('display','');//显示搜索框
				ld('#searchColleagueText').attr('placeholder','搜索同事');
				ld('#searchColleagueText').attr('tag',1);//1 发任务 2发日志
			});
		//}
	});
	//执行人 input文本框，光标移除 ，显示选择执行人字样
	ld('#sendLogFoot > div[tag=cmduser] input.input-field').blur(function(){
		ld('#sendLogFoot > div[tag=cmduser] input.input-field').removeClass('ui-show');
		ld('#sendLogFoot > div[tag=cmduser] input.input-field').addClass('ui-hide');
		ld('#sendLogFoot > div[tag=cmduser] .input-tip').css('display','');
	});
	//选择抄送范围事件绑定
	ld('#sendLogFoot > div[tag=ccrange]').click(function(event){
		var e = event || window.event;
		var obj = e.srcElement||e.target;
		//点击选择点评人链接时，show-select-panel对象点击事件
		obj = ld('#sendLogFoot > div[tag=ccrange] .show-select-panel').get(0);
		if('remove-h' == ld(obj).attr('class')){
			return false;
		}
		ld('#sendLogFoot > div[tag=ccrange] input.input-field').removeClass('ui-hide');
		ld('#sendLogFoot > div[tag=ccrange] input.input-field').addClass('ui-show');
		if('show-select-panel' != ld(obj).attr('class')){
			//ld('#sendLogFoot > div[tag=ccrange] .input-tip').css('display','none');
			//ld('#sendLogFoot > div[tag=ccrange] input.input-field').focus();
			ld('#sendLogFoot > div[tag=ccrange] .show-select-panel').click();
		}else{
			var selectUserid = [];//默认选中的用户id
			var selectNum = 0;
			ld('#sendLogFoot > div[tag=ccrange] ul.reader-bar-list li').each(function(){
				selectUserid[selectUserid.length] = ld(this).attr('userid');
				selectNum++;
			});
			
			//选择抄送范围事件
			setEventSelectUser('sendLogFoot > div[tag=ccrange]',selectNum,selectUserid.join(','));
		}
	});
	//点评人 input文本框，光标移除 ，显示选择点评人字样
	ld('#sendLogFoot > div[tag=ccrange] input.input-field').blur(function(){
		ld('#sendLogFoot > div[tag=ccrange] input.input-field').removeClass('ui-show');
		ld('#sendLogFoot > div[tag=ccrange] input.input-field').addClass('ui-hide');
		ld('#sendLogFoot > div[tag=ccrange] .input-tip').css('display','');
	});
	
	//发布事件
	var issubmitlog = 1;
	ld('#ReleaseBtn').unbind('click').click(function(event){

        if(1 != issubmitlog) return false;
         delAccount={};
         delContact={};
        selectAccount={};
        selectContact={};
        var savetype = 1;
        
        if(pop_obj_coordinate!=null)
        {
            pop_obj_coordinate.style.display="none";
            
        }
         
        if('sendLog' == cur_panel)
        	savetype = typeobj[ld('#stream-hsent-title [class=curr]').attr('tag')];
         
        var sendLogObj = ld('#sendLog div[entitytype='+cur_panel+'] div[type=worktype_'+savetype+']');
        var mandatory_bool = true;//必填项是否填写
		ld(sendLogObj).find('textarea[is_mandatory=0]').each(function() {
			if(empty(ld(this).val())){//必填判断，未填写
				flash_empty("sendTxt");//提示用户
				ld(this).focus();//光标移入
				return mandatory_bool = false;
			}
		});
		if(!mandatory_bool) return false;//未填写
		//组装对应的字段和值
		var workfldfilter = '';var workfldstring = '';
		ld(sendLogObj).find('textarea').each(function(){
			workfldfilter += '&'+ld(this).attr('name')+'='+ld(this).val();
			workfldstring += ld(this).attr('name') +',';
		});
		workfldfilter += '&workfld='+workfldstring;

		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=saveSendLog'+workfldfilter;

		var entitytype = '';
		var saleskit_date = '';
		switch(cur_panel){
			case 'sendWeibo'://微博
				entitytype = 'weibo';
				break;
			case 'sendLog'://发日志
				entitytype = 'workreport';
				var reader = '';//批阅人
				if(ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li').length > 0){
					ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li').each(function(){
						if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
							reader = ld(this).attr('userid');
							return false;//结束循环
						}
					});
				}//比有值，不必判断非空
				urlstring += '&reader='+reader;
				if(savetype == 1){
					if(ld('#sendlog_saleskit_date').val() != undefined){
						saleskit_date = ld('#sendlog_saleskit_date').html();
					}else{
						saleskit_date = ld('#span_saleskit_date').html();
					}
					//日志日期不能大于当前日期
					var now_date = getNowDate();
					if(saleskit_date > now_date){
						var confirm_str = arrJsPopLabel['thelogdatecannotbegreater'];//提示内容    
						RemindsMsg("","LdPopWidth400px","","","",confirm_str); 
						return false;
					}
					
				}else{
					saleskit_date = ld('#span_saleskit_date').html();
				}
				break;
			case 'cocmd'://任务
				entitytype = 'cocmd';
				var date = ld('#d241').val();//完成时间
	            var time = ld('#d242').val();//完成时间
	            var startdate = ((date.replace('年','-')).replace('月','-')).replace('日',' ')+ time;
	            if(empty(startdate)){
					//alert('请选择完成时间。');
	                flash_empty("d241");
	                flash_empty("d242");
	                return false;
				}
	            var myDate = new Date();
	            var year = myDate.getFullYear();
	            var month = (myDate.getMonth()+1)<10?"0"+(myDate.getMonth()+1):(myDate.getMonth()+1);
	            mytime = year+"-"+month+"-"+((myDate.getDate())<10?"0"+myDate.getDate():myDate.getDate())+" "+((myDate.getHours())<10?"0"+myDate.getHours():myDate.getHours())+":"+((myDate.getMinutes())<10?"0"+myDate.getMinutes():myDate.getMinutes())+":"+((myDate.getSeconds())<10?"0"+myDate.getSeconds():myDate.getSeconds());
	            if (mytime >= startdate) {
	                //alert('完成时间不能早于当前时间。');
	                if(0 == ld('#cmd-time-error').length){//当层未创建时，创建层
	                	/**
	                    ld(".ui-mask").css('display','block');
	                    var divObj = document.createElement("div");
	            		divObj.setAttribute('id','cmd-time-error');
	            		divObj.className = 'cmd-time-error';
	            		divObj.style.position = "absolute";
	            		divObj.style.zIndex = "9999";
	                    divObj.style.width = "380px";
	            		document.body.appendChild(divObj);
	            		divObj.innerHTML ='<div class="ui-popup" style="width:100%;"><div class="popup-head"><span class="popup-title ui-popup-cursor">&nbsp;</span><i class="dialog-close ui-popup-close">×</i></div>'+
	                                       '<div class="popup-centent ui-popup-centent" style=" padding-bottom: 10px;"><p style="padding:0px 0px 15px 4px;">完成时间不能早于当前时间。</p>' +
	                                        '<p style="margin-bottom:0px;text-align:right;">'+
	                                        '<button class="button-blue ui-popup-close" type="button">确定</button></p>'+
	                                      '</div></div>';
	                     var e = event || window.event;
	            		var obj = e.srcElement||e.target;
	            		var tagName = getId('cmd-time-error');
                        
	            	    FindEvent(obj,tagName,event,-20,-160);
	                    WinPopup('cmd-time-error');
	                    ld('.cmd-time-error .button-blue,.cmd-time-error .dialog-close').click(function(){
	                        ld(".cmd-time-error").remove(); 
	                    });
	                    **/
						var confirm_str = '完成时间不能早于当前时间。';
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	                }
	                return false;
	            }
				var cmduser = '';//执行人
				if(ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li').length > 0){
					ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li').each(function(){
						if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
							cmduser = ld(this).attr('userid');
							return false;//结束循环
						}
					});
				}//执行人必有值，不必判断是否为空
				urlstring += '&cmduser='+cmduser;  
            	urlstring += '&startdate='+startdate+'&enddate='+startdate;  
				break;
		}
    
        
        if(entitytype == ''){
            var confirm_str = '单据异常，请清除缓存并刷新页面后操作。';
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
        }
        
        if('cocmd' == cur_panel){//任务执行人必选
            if(empty(cmduser)){
    		 	//alert('请选择执行人。');
                ld('#sendLogsmownerDiv').css('display','');
    	 		return false;
    	 	}
        }
        if('sendLog' == cur_panel){//日志点评人必选
            if(empty(reader)){
                 //alert('请选择批阅人。');
                 ld('#sendLogsmownerDiv').css('display','');
     		     return false;
    		}
        }
        var header='';
		if(document.getElementById('header') != undefined){
			header = document.getElementById('header').value;
		}
        var popupobj=CrmPopup.getPopupObj("last");
        var relatedmodulerecordid="";
        
        if(popupobj!=undefined&&popupobj.type=='workreport')
        {
            header=popupobj.header;
            relatedmodulerecordid=popupobj.record;
        }
        var accountlist = '';var contactlist = '';var productslist = '';//关联的客户、联系人、产品
       
		if(ld('#sendLogAcctlist ul.reader-bar-list li').length > 0){
			ld('#sendLogAcctlist ul.reader-bar-list li').each(function(){
				accountlist += ld(this).attr('accountid')+',';
			});
		}else if(header == 'Accounts' && relatedmodulerecordid > 0){
			accountlist += 'Accounts,'+relatedmodulerecordid;
		}
		if(ld('#sendLogContlist ul.reader-bar-list li').length > 0){
			ld('#sendLogContlist ul.reader-bar-list li').each(function(){
				contactlist += ld(this).attr('contactid')+',';
			});
		}else if(header == 'Contacts' && relatedmodulerecordid > 0){
			contactlist += 'Contacts,'+relatedmodulerecordid;
		}
        if(ld('#sendLogProlist ul.reader-bar-list li').length > 0){
			ld('#sendLogProlist ul.reader-bar-list li').each(function(){
				productslist += ld(this).attr('productid')+',';
			});
		}else if(header == 'Products' && ld('#roleid') != undefined && ld('#roleid').val() > 0){
			productslist += 'Products,'+ld('#roleid').val();
		}
        
        var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
		if(ld('#sendLogFoot > div[tag=ccrange] ul.reader-bar-list li').length > 0){
			ld('#sendLogFoot > div[tag=ccrange] ul.reader-bar-list li').each(function(){
				if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
					ccuser += ld(this).attr('userid')+',';
				}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
					ccgroup += ld(this).attr('groupid')+',';
				}
			});
		}
        
        if('sendWeibo' == cur_panel){//微博必须填写抄送范围
            if(empty(ccuser) && empty(ccgroup)){
    			//alert('请选择抄送范围。');
                ld('#sendLogFoot > div[tag=ccrange]').click();
                var tagName = document.getElementById('sendLogsmownerDiv');
                var e = event || window.event;
                var obj = e.srcElement||e.target;
                FindEvent(obj,tagName,event,70,-25);
    			return false;
            }
        }
        //获取相关图片
		var uploadimgList = '';
		if(ld('#sendLogUploadImg ul li').length > 0){
			ld('#sendLogUploadImg ul li').each(function(){
				uploadimgList += ld(this).attr('record')+',';
			});
		}
        
        //获取相关
		var uploadattList = '';
		if(ld('#sendLogUploadAtt ul li').length > 0){
			ld('#sendLogUploadAtt ul li').each(function(){
				uploadattList += ld(this).attr('record')+',';
			});
		}        
        //at 用户、部门
		var atuser = ld('[name=sendLog] [name=sendLog_at_user]').val();
		var atgroup = ld('[name=sendLog] [name=sendLog_at_group]').val();
		
		urlstring += '&entitytype='+entitytype+'&savetype='+savetype+'';
		urlstring += '&accountlist='+accountlist+'&contactlist='+contactlist+'&productslist='+productslist;
		urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup;
		urlstring += '&atuser='+atuser+'&atgroup='+atgroup;
		urlstring += '&uploadimgList='+uploadimgList;
        urlstring += '&uploadattList='+uploadattList;                
		urlstring += '&saleskit_date='+saleskit_date;

		issubmitlog = 2;
		//alert(urlstring);
		//return false;
		RequestAjax(urlstring,function(rest){
			issubmitlog = 1;
			ld('#sendLogUploadImg ul.reader-bar-list li').remove();
			ld('#sendLogUploadImg ul.reader-bar-list li').remove();
			ld('#sendLogUploadImg ul li').remove();
			ld('#sendLogUploadAtt ul.reader-bar-list li').remove();
			ld('#sendLogUploadAtt ul.reader-bar-list li').remove();
			ld('#sendLogUploadAtt ul li').remove();
			ld('#sendLogAcctlist ul.reader-bar-list li').remove();
			ld('#sendLogAcctlist ul.reader-bar-list li').remove();
			ld('#sendLogAcctlist ul li').remove();      
            //清空选择的联系人
			ld('#sendLogContlist ul.reader-bar-list li').remove();
			ld('#sendLogContlist ul.reader-bar-list li').remove();
			ld('#sendLogContlist ul li').remove();     
            //清空选择的产品
            ld('#sendLogProlist ul.reader-bar-list li').remove();
			ld('#sendLogProlist ul.reader-bar-list li').remove();
			ld('#sendLogProlist ul li').remove();  
                  
			//ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li').remove();
			//ld('#sendLogFoot > div[tag=ccrange] ul.reader-bar-list li').remove();	//抄送范围历史
			ld('[name=sendLog] [name=worksummary]').val('');
			ld('[name=sendLog] [name=workplan]').val('');
			ld('[name=sendLog] [name=workplan_tuesday]').val('');
			ld('[name=sendLog] [name=workplan_wednesday]').val('');
			ld('[name=sendLog] [name=workplan_thursday]').val('');
			ld('[name=sendLog] [name=workplan_friday]').val('');
			ld('[name=sendLog] [name=workexperience]').val('');
            ld('[name=sendLog] [name=sendLog_at_user]').val('');
	        ld('[name=sendLog] [name=sendLog_at_group]').val('');
            ld('#sendLogUploadImg').hide();
            ld('#sendLogUploadAtt').hide();
            ld('#sendLogAcctlist').hide();
            ld('#sendLogContlist').hide();
            ld('#sendLogProlist').hide();
            ld('.panel-visible-h').click();
           
			/**
			 * 保存后恢复默认值
			 * @reason 0014845: 控制面板 > 工作协同模板 ：设置默认值后，在工作协同中第二次发日志时不会显示默认值
			 * @author Tujt 2015-05-08
			 */
			ld('#sendLog div[tag=workfield] textarea[defaultvalue]').each(function(){
				ld(this).val(ld(this).attr('defaultvalue'));
			});
			//点击发布后，清除抄送范围弹出层，下次重新加载
			//0018864: 首页>工作协同>发微博、发日志、发任务：选择抄送范围弹出层，点击全选复选框，选择所有用户后，再发微博，选择抄送范围，勾选人员后，不显示。
			if(ld('#viewuserpopup') != undefined){
				ld('#viewuserpopup').remove();	
			}
			refresh();
		});
        
	});


	//点评选择用户
    ld('#dialogDiv .ui-popup-centent div[tag=dialog]').click(function(event){
		var e = event || window.event;
		var obj = e.srcElement||e.target;
		obj = ld('#dialogDiv .ui-popup-centent div[tag=dialog] .show-select-panel').get(0);
		//日志点评 - 选择抄送范围时，不隐藏其他弹出层
		pop_num = 1;
		if('remove-h' == ld(obj).attr('class')){
			return false;
		}
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').removeClass('ui-hide');
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').addClass('ui-show');
		if('show-select-panel' != ld(obj).attr('class')){
			//ld('#dialogDiv .ui-popup-centent div[tag=dialog] .input-tip').css('display','none');
			//ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').focus();
			ld(obj).click();
		}else{
			var selectUserid = [];//默认选中的用户id
			var selectNum = 0;
			ld('#dialogDiv .ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
				selectUserid[selectUserid.length] = ld(this).attr('userid');
				selectNum++;
			});
			var userids = '';
			if(selectUserid.length > 0){
				userids = selectUserid.split(',');
			}
			//选择抄送范围事件
			setEventSelectUser('dialogDiv .ui-popup-centent div[tag=dialog]',selectNum,userids);
		}
	});
	//点评弹出层
	ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').blur(function(){
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').removeClass('ui-show');
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').addClass('ui-hide');
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] .input-tip').css('display','');
	});
    //转发选择用户

    ld('#forwardDiv .ui-popup-centent div[tag=forward]').click(function(event){
		var e = event || window.event;
		var obj = e.srcElement||e.target;
		//转发 - 选择抄送范围时，不隐藏其他弹出层
		pop_num = 1;
		obj = ld('#forwardDiv .ui-popup-centent div[tag=forward] .show-select-panel').get(0);
		if('remove-h' == ld(obj).attr('class')){
			return false;
		}
		ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').removeClass('ui-hide');
		ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').addClass('ui-show');
		if('show-select-panel' != ld(obj).attr('class')){
			ld(obj).click();
		}else{
			var selectUserid = [];//默认选中的用户id
			var selectNum = 0;
			ld('#forwardDiv .ui-popup-centent div[tag=forward] ul.reader-bar-list li').each(function(){
				selectUserid[selectUserid.length] = ld(this).attr('userid');
				selectNum++;
			});
			//选择抄送范围事件
			setEventSelectUser('forwardDiv .ui-popup-centent div[tag=forward]',selectNum,selectUserid.join(','));
		}
	});
    //转发弹出层
	ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').blur(function(){
		ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').removeClass('ui-show');
		ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').addClass('ui-hide');
		ld('#forwardDiv .ui-popup-centent div[tag=forward] .input-tip').css('display','');
	});
  
	//列表绑定事件
	ListLoad();
    if(document.getElementById('raccount_id')!=null&&document.getElementById('raccount_id')!=undefined&&document.getElementById('raccount_id').value>0)
            ld('.form-thumb').click();
   
    if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='')
            ld('.form-thumb').click();
}
var curpagenum = 0,havenextpage = 'no';//当前页数、是否有下一页
var bigcategory = '1',smallcategory = 'all',searchcontent='';
/**
 * 绑定列表节点事件
 * @author Tujt 2015-02-05
 */
function ListLoad(){
	//一级导航标签 点击事件
	ld('.ConSwitch ul li a').click(function(){
		//一级导航 下划线切换
		var tag = ld(this).parent().attr('tag');
		ld('.ConSwitch ul li').each(function(){
			if(ld(this).attr('tag') == tag){
				ld(this).attr('class','linebg');
			}else{
				ld(this).attr('class','');
			}
		});
		//一级导航切换
		bigcategory = ld(this).attr('tag');
		ld('.ConSwitch ul li a').each(function(){
			if(bigcategory == ld(this).attr('tag')){
				ld(this).attr('class','curr');
            }else{
				ld(this).attr('class','');
            }
		});
		fun_search('ConSwitchMenu');
	});
	//二级导航标签 点击事件
	ld('.switchable-nav ul li a').on('click',function(){
		smallcategory = ld(this).attr('name');
		ld('.switchable-nav ul li a').each(function(){
			if(smallcategory == ld(this).attr('name')){
				ld(this).attr('class','curr');
			}else{
				ld(this).attr('class','');
			}
		});
		fun_search();
	});
	ld('.ConSwitch ul li a[tag=1]').click();
	ld(window).scroll(function () {
		if (ld(document).scrollTop() + ld(window).height() >= ld(document).height()) {
			WorkReportNextPage();//下一页
		}
	});
}
//二级查询菜单 - 筛选
ld('#advSearch_div').on('click',function(){
	var _display = ld('.advSearch-nav').css('display');
	if(_display == 'none'){
		ld('#search_arrow_down').hide();
		ld('#search_arrow_up').show();
		ld('.advSearch-nav').show();
	}else{
		ld('#search_arrow_down').show();
		ld('#search_arrow_up').hide();
		ld('.advSearch-nav').hide();
	}
})
//二级查询菜单 -- 时间范围
ld('.w-filter-select .value').on('click',function(){
	var data_value =  ld(this).attr('data-value');
	var _display = ld('#selectbox_datebox').css('display');
	var a = ld('.Header').outerHeight(),//头部高度
        b1 = ld('.Edit_box').outerHeight(),//输入框
        b2 = ld('.ConSwitch').outerHeight(),//类别
        c = ld('.switchable-nav').outerHeight(),
		top = '';//标签高度
	
	top = a+b1+b2+c+32;
	ld('#selectbox_datebox').css('top',top);
	ld('#selectbox_datebox').css('left',ld('.w-filter-select .value').offset().left);
	if(_display == 'none'){
		ld('#selectbox_datebox').show();
	}else{
		ld('#selectbox_datebox').hide();
	}
	ld('#selectbox_datebox .select-list li').each(function(){
		if(ld(this).attr('data-value') == data_value){
			ld(this).addClass("selected");
		}else{
			ld(this).removeClass();
		}
	})
	ld('#selectbox_datebox .select-list li').on('click',function(){
		var select_data_value =  ld(this).attr('data-value');
		if(select_data_value == 'custom'){
			var custom_value = ld('.w-filter-select .value').html();
			var begin_date = '';
			var end_date = '';
			if(!empty(custom_value) && ld('.w-filter-select .value').attr('data-value') == 'custom'){
				var custom_value_arr = custom_value.split('-');
				if(custom_value_arr.length > 1){
					begin_date = custom_value_arr[0].replace(/\//g,'-');
					end_date = custom_value_arr[1].replace(/\//g,'-');
				}
			}
			var divobj = createElementDivs('daterangrarr_custom_div');//创建DIVallocate_pop_divtitlename
			var div_title = arrJsPopLabel['custom'] + arrJsPopLabel['TIMES'];
			var div_content = arrJsPopLabel['STARTDATE1']+' <input id="begin_date" class="Wdate" name="begin_date" tabindex="d" style="border:1px solid #bababa;" fieldonly="0" size="20" maxlength="10" value="'+begin_date+'" placeholder="'+arrJsPopLabel['pleaseselectdate']+'" onclick="WdatePicker()" type="text"> &nbsp;&nbsp;&nbsp;&nbsp;'+arrJsPopLabel['ENDDATE1']+' <input id="end_date" class="Wdate" name="end_date" tabindex="d" style="border:1px solid #bababa;" fieldonly="0" size="20" maxlength="10" value="'+end_date+'" placeholder="'+arrJsPopLabel['pleaseselectdate']+'" onclick="WdatePicker()" type="text">';
			ld(divobj).find('.D_pop_tit .D_ptita').html(div_title);
			ld('#daterangrarr_custom_divcontent').html(div_content);
			ld('#daterangrarr_custom_divcontent').css("padding","7px 0px 7px 15px");
			ld('#daterangrarr_custom_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
				var begin_date = ld('#begin_date').val();
				var end_date = ld('#end_date').val();
				if(begin_date == ''){
					var confirm_str = arrJsPopLabel['STARTDATE1']+arrJsPopLabel['CANOTEMPTY']+'！';
		            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
				if(end_date == ''){
					var confirm_str = arrJsPopLabel['ENDDATE1']+arrJsPopLabel['CANOTEMPTY']+'！';
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
				if(begin_date > end_date){
					var confirm_str = arrJsPopLabel['THISDATENOEDNDATE'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
				var reg=/-/g;
				begin_date=begin_date.replace(reg,'/');
				end_date=end_date.replace(reg,'/');
				fninvshnew('daterangrarr_custom_div');lingdangJS_DialogBox.unblock();
				ld('.w-filter-select .value').html(begin_date +'-'+end_date);
				ld('.w-filter-select .value').attr('data-value',select_data_value);
				ld('#selectbox_datebox').hide();
				fun_search();
			});
			ld('#daterangrarr_custom_div .D_pbtn .D_pbtncancel').on('click',function(){
				ld('#selectbox_datebox').hide();
            });
		}else{
			var select_li_value = trim(ld(this).html());
			ld('.w-filter-select .value').html(select_li_value);
			ld('.w-filter-select .value').attr('data-value',select_data_value);
			ld('#selectbox_datebox').hide();
			fun_search();
		}
	})
})
//二级查询菜单 -- 发起人
ld('#_select_sponsor_div').on('click',function(){
	var selectUserid = ld('#sponsor_value').val();
	var selectNum = 0;
	if(!empty(selectUserid)){
		var userids = selectUserid.split(',');
		selectNum = userids.length;
	}
	//选择抄送范围事件
	setEventSelectUser('_select_sponsor_div',selectNum,selectUserid);
})
//关键字查询 - 按钮
ld('.w-filter-wrapper .btn-search').on('click',function(){
	searchcontent = ld('.w-filter-wrapper .filter-keyword').val();
	if(empty(searchcontent)){
		refresh();
	}else{
		fun_search();
	}
})
//搜索文本框
ld('.w-filter-wrapper .filter-keyword').keydown(function(e){
	if(13 == e.keyCode){
		ld('.w-filter-wrapper .btn-search').click();
	}
});
//二级菜单查询
var fun_search = function(conswitchmenu_type){
	//时间范围
	var datecategory_value;
	var datecategory = ld('.w-filter-select .value').attr('data-value');
	if(datecategory == 'custom'){
		datecategory_value = ld('.w-filter-select .value').html();
	}
	//发起人
	var sponsor = ld('#sponsor_value').val();
	//关键字查询
	var searchcontent =  ld('.w-filter-wrapper .filter-keyword').val();
	var urlstring = 'smallcategory='+smallcategory+'&bigcategory='+bigcategory+'&datecategory='+datecategory+'&datecategory_value='+datecategory_value;
	urlstring += '&sponsor='+sponsor;
	if(ld('#massdelete') != undefined && ld('#massdelete').val() == 'true'){
		urlstring += '&massdelete=true';
	}
	if(ld('#report_user_id') != undefined && ld('#report_user_id').val() > 0){
		urlstring += '&report_user_id='+ld('#report_user_id').val();
	}
    
	if(conswitchmenu_type == 'ConSwitchMenu'){
		// editor:gyqX160722 Bug:0023732
		urlstring += '&page=1&searchcontent='+searchcontent;//默认是第一页
		ld('.pubDetialC').html('<div id="worklist_page_1"></div>');
        getWorkList(urlstring,function(){
		
            //工作协同：待处理和已处理查询时，二级标签菜单不需要“微博”
            if(bigcategory=='2'||bigcategory=='3')
            {
                ld('.switchable-nav ul li[entityname=weibo]').css("display",'none');
            }
            else
            {
                ld('.switchable-nav ul li[entityname=weibo]').css("display",'');
            }
		});
	}else if(conswitchmenu_type == 'Refresh'){
		urlstring += '&page='+curpagenum+'&searchcontent='+searchcontent;
		getWorkList(urlstring,function(){
		});
	}else{
		urlstring += '&page=1&searchcontent='+searchcontent;
		getWorkList(urlstring,function(){
		});
	}
}
function GetDateStr(AddDayCount) {
	var dd = new Date();
	dd.setDate(dd.getDate()+AddDayCount);//获取AddDayCount天后的日期
	var y = dd.getFullYear();
	var m = dd.getMonth()+1;//获取当前月份的日期
	var d = dd.getDate();
	return y+"-"+m+"-"+d;
} 
/**
 * 加载列表
 * @param String urldata 传递的参数
 * @param Function callback 回传方法
 * @author Tujt 2015-02-04
 */
var workreport_field_obj = {};
function getWorkList(urldata,callback){
    var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=getList';
    if(ld("#roleid").val()!=undefined&&ld("#roleid").val()!='')
	{
		urlstring += "&roleid="+ld("#roleid").val();
	}
	if(ld('#info') != undefined && ld('#info').val() != ''){
		urlstring += '&info=yes';
	}
    var attcount='';
	if('' != urldata) urlstring += '&'+urldata;
	WordReportAjax(urlstring,function(rest){
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var tplnode = ld('#tplnode').html();
		var listhtml = '';
		var userimage,userimg,node,maxlength = 0,ispraise;
		var signcls,accountlist,accountcls,contactlist,contactcls,productslist,productscls;
		var readerbuttontit,keyreport,workimglist,workimgcls;
		//待处理数量赋值
		if(!empty(restobj.summary) && restobj.summary.processedCount > 0){
			ld('.ConSwitch ul.menuUl li span.num').html(restobj.summary.processedCount);
			ld('.ConSwitch ul.menuUl li span.num').removeClass('ui-hide');
		}else{
			/**
			 * 待处理单据全都是审批后，将待处理数量变为空，并隐藏
			 * @reason 0013825: 工作协同：只有一条待处理日志时，点评后，待处理条数还是显示1。
			 * @author Tujt 2015-03-04
			 */
			ld('.ConSwitch ul.menuUl li span.num').html('');
			ld('.ConSwitch ul.menuUl li span.num').addClass('ui-hide');
		}
		curpagenum = restobj.summary.curpagenum;
		havenextpage = restobj.summary.havenextpage;
		//获取日志自定义字段结果集
		if(empty(workreport_field_obj)){//放在公共变量里，不用每次都读取
			var setype = '';var workfldarr = {};
			ld('#sendLog div[tag=workfield] div[entitytype=sendLog] div[type]').each(function(){
				setype = ld(this).attr('type');
				workfldarr = {};
				ld(this).find('textarea').each(function(){
					workfldarr[ld(this).attr('name')] = ld(this).parent().find('label').html();
				});
				workreport_field_obj[setype] = workfldarr;
			});
		}
        if(restobj.report==''||restobj.report==null){
            listhtml = '<div class="search_empty_holder"><img class="icon-empty" alt="暂无内容" src="themes/images/emptyinfo.png">';
            listhtml += '<span class="empty-text">暂无内容</span></div>';
			//如果当前页没有内容，则直接没有一页处理
			havenextpage = 'no';
        }	
        //列表循环
		ld.each(restobj.report,function(key,report){
			if(empty(report)) return false;
			if(!empty(report.userimage)){
				userimage = report.userimage;
			}else{
				userimage = 'themes/images/defaultuser.png';
			}
			userimg = '<a><img src="'+userimage+'" alt="" report_user_id="'+report.encryptuserid+'" class="name-img"></a>';
			//是否点赞
			var lessThenIE10 = function () {
		    var UA = navigator.userAgent,
		            isIE = UA.indexOf('MSIE') > -1,
		            v = isIE ? /\d+/.exec(UA.split(';')[1]) : 'no ie';
		        return v < 10;

		    }();
		    /*兼容 IE10以下版本  
		    ,tpl文件 class 和 title解析成html时，
		    顺序 IE10与IE8，IE9解析顺序相反 */
		    if(lessThenIE10){
		        ispraise = '赞';
					if('yes' == report.ispraise){
						ispraise = '取消赞';
		                praisetitle = 'hand_handred'; //IE8,IE9,不支持 替换字符串有空格
                                                      //不支持 praisetitle = 'hand handred';
					}else{
		                praisetitle = 'hand';
					}
		    }else{//非IE10以下版本浏览器,以及非IE浏览器
    		    ispraise = 'hand';
    			if('yes' == report.ispraise){
    				ispraise = 'hand handred';
                    praisetitle = '取消赞';
    			}else{
                    praisetitle = '赞';
    			}
		    }

			signcls = 'ui-hide';
			if(!empty(report.signaddress)){
				signcls = '';
			}
			accountlist = '';accountcls = 'ui-hide';
			if(!empty(report.Accounts)){
				accountcls = '';
				ld.each(report.Accounts,function(key,accountobj){
					accountlist += '<span><a href="index.php?module=Accounts&action=DetailView&record='+accountobj.curid+'" target="_blank">'+accountobj.name+'</a></span><br>';
				})
			}
			contactlist = '';contactcls = 'ui-hide';
			if(!empty(report.Contacts)){
				contactcls = '';
				ld.each(report.Contacts,function(key,contactsobj){
					contactlist += '<span><a href="index.php?module=Contacts&action=DetailView&record='+contactsobj.curid+'" target="_blank">'+contactsobj.name+'</a></span><br>';
				})
			}
            productslist = '';productscls = 'ui-hide';
			if(!empty(report.Products)){
				productscls = '';
				ld.each(report.Products,function(key,productsobj){
					productslist += '<span><a href="index.php?module=Products&action=DetailView&record='+productsobj.curid+'" target="_blank">'+productsobj.name+'</a></span><br>';
				})
			}
			//点评、关键回复
			readerbuttontit = '回复';keyreport = 'ui-hide';keyreport_href='ui-hide';now_finish_href = '';;
			if('yes' == report.readerbutton)
            {
				readerbuttontit = '回复';
                keyreport_href='';
                
			}
            else
            {
                
				if(0 != report.approved){
				  
				
                    keyreport = '';//点评内容是否显示
					keyreport_href = 'ui-hide';
					now_finish_href = 'ui-hide';
				}
			}
           
            if(report.entitytype == 'cocmd'||report.entitytype == 'weibo')
            {
                readerbuttontit = '回复';
            }
            keyreportstr = '点评内容(1)';
            if(report.entitytype == 'cocmd')
            {
                keyreportstr = '关键回复(1)';
            }
            
			//关联图片
			workimglist = '';workimgcls = 'ui-hide';
			if(!empty(report.workachment)){
				if(!empty(report.workachment['image'])){
					workimgcls = '';var fori = 1;
					ld.each(report.workachment.image,function(key,workimgobj){
						var imgpath = workimgobj.path.value+workimgobj.newfile_name.value;
						workimglist += '<span achmentid="'+key+'"><img style="height: 67px;width: 106px;" src="'+imgpath+'" alt="" class=""></span>';
						if(fori%4==0) workimglist += '<br>';
						++ fori;
					});
				}
			}
            
			//关联附件`
			workattlist = '';workattcls = 'ui-hide';
             attcount='';
			if(!empty(report.workachment)){
				if(!empty(report.workachment['att'])){
					workattcls = '';var fori = 1;
					ld.each(report.workachment.att,function(key,workattobj){
						var attpath = workattobj.path.value+workattobj.name.value;
						workattlist += '<div achmentid="'+key+'" class="att"><div><img class="attimg f-l marT5 padR8" src=\'themes/softed/images/file.png\'></div><div><span > <a target="_blank" href="index.php?module=Home&action=openattachment&fildid='+key+'">'+workattobj.file_name.value+'</a></span><span class="file-size greyFont3">（'+workattobj.size.value.substring(0,40)+'）</span><a target="_blank" href="index.php?module=Home&action=openattachment&fildid='+key+'">下载</a></div></div>';
						++ fori;
					});
				}
                attcount=fori-1;
			}
            //微博有些信息不显示
            var strMoreInfoStatus = '';
            if(report.entitytype == 'weibo')
            {
                strMoreInfoStatus = 'ui-hide';
            }
            
            //判断回复描述是否需要
            var cocmdStr = 'ui-hide';
            var workreportStr = 'ui-hide';
            if(report.entitytype == 'workreport' && report.replycount>0)
            {
                workreportStr = '';
            }
            else if(report.entitytype == 'cocmd' && report.replycount>0)
            {
                cocmdStr = '';
            }
            //判断是否删除.
            var delStr = 'no';
            if(report.isDel=='yes'&&report.replycount==0)
            {
                delStr = 'yes';
            }
            
			if(empty(report.workreporttype)) report.workreporttype = 1;
			if(empty(report.praisecount)) report.praisecount = 0;
			//控制微博、日志、任务字段显示
			workreportlabel = '';
			var workfldarr = {'worksummary':'summary','workexperience':'experience'}
			switch(report.entitytype){
				case 'weibo'://微博
                case 'cocmd'://任务
					workreportlabel = '<div class="content-text writeexperience">'+report.experience+'</div>';
					break;
				case 'workreport'://发日志
					ld.each(workreport_field_obj['worktype_'+report.workreporttype],
						function(fldname,fldlabel){
							if(workfldarr[fldname] != undefined) fldname = workfldarr[fldname];
							workreportlabel += '<p class="content-title writesummary">'+fldlabel+'</p><div class="content-text writeexperience">'+report[fldname]+'</div>';
						}
					);
					break;
			}
			
			if(report.entitytype != 'workreport'){
				keyreport_href = 'ui-hide';
			}
			if(report.entitytype != 'cocmd'){
				now_finish_href = 'ui-hide';
			}
			node = sprintf(tplnode,
					report.curid,
					report.username,
					report.workreporttime,
					report.relateUserDescription,
					report.curid,
					report.relateUserDescription,
					report.sendlog_class,
					report.entitytypename,//类别                    
                    report.workreportstatusclass,//样式
                    report.workreportstatusclass,//样式
                    report.workreportstatusclass,//样式                    
					report.workreportstatus,//状态
					report.reader.startDateDescription,//日志，任务内容前描述，微博没有描述
					keyreport_href,//现在点评是否显示
					now_finish_href,
                    workreportlabel,
                    signcls,
                    signcls,
					report.signaddress,
					accountcls,
                    accountcls,
					accountlist,
					contactcls,
                    contactcls,
					contactlist,
                    productscls,
                    productscls,
					productslist,
					workimgcls,
					workimgcls,
					workimglist,
					workattcls,
                    attcount,
					workattcls,
					workattlist,           
					keyreport,//点评是否显示
                    keyreportstr,//点评/关键回复
                    
					report.workreporttype,//销售简报
					report.userid,//销售简报
					report.curid,//销售简报
                    report.entitytype,
                    report.curid,//更多ID
                    report.entitytype,
                    report.curid,//更多ID
                    report.curid,//转发ID
                    report.curid,
                    report.curid,//取消ID
                    report.curid,
                    
                    praisetitle,//点赞图标title
                    ispraise,//是否点赞
					report.curid,//点赞
                    
                    report.praisecount,//点赞数量
					report.curid,//回复
					report.readerbutton,//点评、回复状态
					readerbuttontit,//点评、回复文字
					report.replycount,//回复数量
					report.curid,
                    delStr,//是否删除
					report.curid, //删除
                    
                    cocmdStr,//任务描述是否存在
                    workreportStr//日志描述是否存在
			);
			node = strtr(node,'name-img',userimg);//用户图片
			if(report.praisecount > 0){//点赞数量
				node = strtr(node,'praise-num','num');
			}else{
				node = strtr(node,'praise-num','num ui-hide');
			}
			if(report.replycount > 0){//回复数量
				node = strtr(node,'reply-num','num');
			}else{
				node = strtr(node,'reply-num','num ui-hide');
			}
            if(report.entitytype == 'weibo' || report.entitytype == 'cocmd'){//微博或者任务
				node = strtr(node,'content-title writesummary','content-title writesummary ui-hide');
                node = strtr(node,'content-text writesummary','content-text writesummary ui-hide');
                node = strtr(node,'content-title writheworkplan','content-title writheworkplan ui-hide');
                node = strtr(node,'content-text writheworkplan','content-text writheworkplan ui-hide');
                node = strtr(node,'content-title writeexperience','content-title writeexperience ui-hide');
			}
			if(report.entitytype == 'workreport'){
				 node = strtr(node,'saleskit li ui-hide','saleskit li');
			}
			listhtml += node;
		});
		
		ld('#worklist_page_'+curpagenum).html(listhtml);
		ld('.pubDetialC').html(ld('.pubDetialC').html()+'<div id="worklist_page_'+(curpagenum+1)+'"></div>');
        WorkListBind();
		callback();
	});
}
/**
 * 绑定事件
 * @author Tujt 2015-02-05
 */
function WorkListBind(){
   //更多-弹框
   ld('div.func [tag=more]').on('click',function(event){
        var morename = ld(this).attr('morename');
        var seat = morename.indexOf("-");
        var typename = morename.substr(0,seat);
        var workreportid = morename.substr(seat+1,morename.length-seat);
        
        //微博和日志是转发，任务是取消
        var name = '';
        if(typename == 'workreport'||typename == 'weibo')
        {
            name = 'more-cancel-'+workreportid;
            document.getElementById(name).style.display = 'none';
            
            if(ld('div.func [tag='+morename+']').attr('class') == 'more-menu ui-hide')
            {
                ld('div.func [tag='+morename+']').removeClass('ui-hide');
            }
            else
            {
                ld('div.func [tag='+morename+']').addClass('ui-hide');
            }
        }
        else
        {
            var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
    		urlstring += '&method=checkMore&workreportid='+workreportid;
            RequestAjax(urlstring,function(rest){
                if(empty(rest)) return false;
                var report = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                
                ld.each(report,function(key,report){
        			if(empty(report)) return false;
        			if(report.approved=='yes')
                    {
                        name = 'more-cancel-'+workreportid;
                        document.getElementById(name).style.display = 'none';    
                    }
                    if(ld('div.func [tag='+morename+']').attr('class') == 'more-menu ui-hide')
                    {
                        ld('div.func [tag='+morename+']').removeClass('ui-hide');
                    }
                    else
                    {
                        ld('div.func [tag='+morename+']').addClass('ui-hide');
                    }
                    
        		});
            });
        }
        
        
	});
   //更多-转发弹框
   ld('div.func [tag=more-forward]').on('click',function(event){
        ld(".ui-mask").css('display','block');
        var replyobj = ld(this);
		var replytag = ld(this).find('span').attr('tag');
        var workreport = ld(this).attr('workreport');
		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=createforwardPop&workreportid='+workreport;
        RequestAjax(urlstring,function(rest){
            var dataobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
            
            ld('#forwardDiv').css('display','');
            var e = event || window.event;
			var obj = e.srcElement||e.target;
			var tagName = getId('forwardDiv');
			FindEvent(obj,tagName,event,'',-200);
            ld('div.func div.more-menu').addClass('ui-hide');//关闭“更多”弹出
			//var workreport = dataobj.workreport;
			var issubmit = 1;
            ld('#forwardDiv .button-r .button-green').unbind('click').click(function(){
                if(1 != issubmit) return false;//防止重复点击
                var reader_content = ld('#forwardDiv textarea.input-text').val();
                if(empty(reader_content)){
    				//alert('请填写内容。');
                    flash_empty("sendTxtForward");
                    return false;
    			}
				var reader_score = ld('#forwardDiv select.commenton-select').val();
				var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
				if(ld('#forwardDiv div.ui-popup-centent div[tag=forward] ul.reader-bar-list li').length > 0){
					ld('#forwardDiv div.ui-popup-centent div[tag=forward] ul.reader-bar-list li').each(function(){
						if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
							ccuser += ld(this).attr('userid')+',';
						}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
							ccgroup += ld(this).attr('groupid')+',';
						}
					});
				}
                
                if(empty(ccuser) && empty(ccgroup)){
                	var confirm_str = '请选择抄送范围。';
                	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        			return false;
                }
                var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
				urlstring += '&method=savereader&savetype=saveforward';
				urlstring += '&reader_content='+encodeURIComponent(reader_content)+'&reader_score='+reader_score;
				urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup+'';
				urlstring += '&workreportid='+workreport+'';
				issubmit = 2;
				RequestAjax(urlstring,function(rest){
					issubmit = 1;
					ld('#forwardDiv textarea.input-text').val('');
					ld('#forwardDiv div.ui-popup-centent div[tag=forward] ul.reader-bar-list li').remove();
					ld('#forwardDiv').css('display','none');
					refresh();//刷新页面
                    ld(".ui-mask").css('display','none');
				});
            
            });
			/* editor:gyqX160720 bug:0023701 */
			ld('#forwardDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
				ld('#forwardDiv').css('display','none');
				ld(".ui-mask").css('display','none');

			});

        });
   });
   //销售简报
   ld('div.func [tag=saleskit_target]').on('click',function(event){
		var workreporttype = ld(this).attr('workreporttype');
		var userid = ld(this).attr('userid');
		var workreportid = ld(this).attr('workreport');
		var workdate = ld(this).attr('date');
		var title = ld(this).html();
		if(workreporttype > 0 && userid > 0){
			var worktype = '';
			var sendlog_date = '';
			//工作汇报：工作协同
			//alert("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_date&workreportid="+workreportid+"&userid="+userid);
			ld.ajax("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_date&workreportid="+workreportid+"&userid="+userid)
			.done(function(results){
				var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
				sendlog_date = restobj.sendlog_date;
				title += '（'+sendlog_date+'）';
				var tablehtml = '<div id="saleskit_div" class="padL10">';
				if(restobj.list['Leads'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['Leads']['label']+'</div><span tag="span_leads" class="folder blue428 hoverUnderLine padR3">'+restobj.list['Leads']['nums']+'</span>个</div>';
				}
				if(restobj.list['Accounts'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['Accounts']['label']+'</div><span tag="span_accounts" class="folder blue428 hoverUnderLine padR3">'+restobj.list['Accounts']['nums']+'</span>个</div>';
				}
				if(restobj.list['Contacts'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['Contacts']['label']+'</div><span tag="span_contacts" class="folder blue428 hoverUnderLine padR3">'+restobj.list['Contacts']['nums']+'</span>个</div>';
				}
				if(restobj.list['Potentials'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['Potentials']['label']+'</div><span tag="span_potentials" class="folder blue428 hoverUnderLine padR3">'+restobj.list['Potentials']['nums']+'</span>个</div>';
				}
				if(restobj.list['ContactRecords'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['ContactRecords']['label']+'</div><span tag="span_contactrecords" class="folder blue428 hoverUnderLine padR3">'+restobj.list['ContactRecords']['nums']+'</span>个</div>';
				}
				if(restobj.list['SalesOrder'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['SalesOrder']['label']+'</div><span tag="span_salesorder" class="folder blue428 hoverUnderLine padR3">'+restobj.list['SalesOrder']['nums']+'</span>个</div>';
				}
				if(restobj.list['ServiceContracts'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['ServiceContracts']['label']+'</div><span tag="span_servicecontracts" class="folder blue428 hoverUnderLine padR3">'+restobj.list['ServiceContracts']['nums']+'</span>个</div>';
				}
				if(restobj.list['CashBill'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['CashBill']['label']+'</div><span tag="span_cashbill" class="folder blue428 hoverUnderLine padR3">'+restobj.list['CashBill']['nums']+'</span>元</div>';
				}
				if(restobj.list['Singin'] != undefined){
					tablehtml += '<div class="cooperativeWorktranstab"><div class="paddingBottom5">'+restobj.list['Singin']['label']+'</div><span tag="span_signin" class="folder blue428 hoverUnderLine padR3">'+restobj.list['Singin']['nums']+'</span>次</div>';
				}
				tablehtml += '</div>';
				resultRemindsMsg(title,"LdPopWidth600px","","yes","",tablehtml);
				var saleskit = new Array('Leads','Accounts','Contacts','Potentials','ContactRecords','SalesOrder','ServiceContracts','CashBill','Singin');
				ld.each(saleskit,function(index,smodule){
					if(restobj.list[smodule] != undefined){
						var values = restobj.list[smodule]['nums'];
						//if(values > 0){
							ld('#saleskit_div span[tag=span_'+smodule.toLowerCase()+']').on('click',function(){
								if(smodule == 'Singin'){
									url = 'index.php?module=OftenUseReport&action=ListView&UseReport=25&worktype='+worktype+'&sendlog_date='+sendlog_date+"&userid="+userid;
									window.open(url); 
								}else{
									//alert("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_Target&sendlog_date="+sendlog_date+"&worktype="+worktype+"&frommodule="+smodule);
									ld.ajax("index.php?action=HomeAjax&module=Home&file=WorkReportIndex&method=getSendLog_SalesKit_Target&sendlog_date="+sendlog_date+"&worktype="+worktype+"&frommodule="+smodule+"&userid="+userid)
									.done(function(){
										url = 'index.php?module='+smodule+'&action=ListView&query_session=1';
										window.open(url); 
									})
								}
								//
							});		
						}
					//}
				});
			})
		}
   });
   //更多-取消
   ld('div.func [tag=more-cancel]').on('click',function(event){
        var replyobj = ld(this);
		var replytag = ld(this).find('span').attr('tag');
        var workreport = ld(this).attr('workreport');
        
        if(0 == ld('#confirm-cancel-tip').length){//当层未创建时，创建层
        	var confirm_str = '确定取消这条任务吗';
        	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        	ld('div.func div.more-menu').addClass('ui-hide');
        	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){      		
	        	
		        var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	        		urlstring += '&method=savereader&savetype=savecancel';
	        		urlstring += '&workreportid='+workreport+'';
	        	issubmit = 1;
		        RequestAjax(urlstring,function(rest){
        			if(1 != issubmit) return false;//防止重复点击
        			ld('#forwardDiv textarea.input-text').val('');
        			ld('#forwardDiv div.ui-popup-centent div[tag=forward] ul.reader-bar-list li').remove();
        			ld('#forwardDiv').css('display','none');
        			ld('div.show-slide-up-tip-warp [tag=cancel]').click();//激发取消按钮事件
        			refresh();//刷新页面
        		});	
        	});
        
        }
        
   });   
   //点赞
   ld('div.func [tag=praise]').on('click',function(event){
		var workreportid=ld(this).attr("workreport");
		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=savepraise';
		urlstring += '&workreportid='+workreportid;
		var handobj = ld(this);
		var hand = ld(this).attr('class');
		var num = ld(handobj).parent().find('span.num > span').html();
		if(empty(num) || 1 > num) num = 0;
		else num = parseInt(num);
		if(isNaN(num)) num = 0;
       
		if(hand.indexOf('handred')=== -1){//点赞 ,当查找不到'handred'表示,点赞
			num += 1;
			ld(handobj).attr('class','hand handred');
            ld(handobj).attr('title','取消赞');
			ld(handobj).parent().find('span.num').removeClass('ui-hide');
			ld(handobj).parent().find('span.num > span').html(num);
		}else{//取消点赞
			num -= 1;
			ld(handobj).attr('class','hand');
            ld(handobj).attr('title','赞');
			if(0 == num){
				ld(handobj).attr('class','hand');
                ld(handobj).attr('title','赞');
				ld(handobj).parent().find('span.num').addClass('ui-hide');
				ld(handobj).parent().find('span.num > span').html(0);
			}else{
				ld(handobj).parent().find('span.num > span').html(num);
			}
		}
		RequestAjax(urlstring,function(rest){
			//回传
		});
	});

	//现在执行按钮事件
	ld('div.pubclear [tag=now_finish]').on('click',function(event){
		var workreport = ld(this).parents(".mainuser").attr('workreportid');
		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=createreaderPop&workreportid='+workreport;
	  
		RequestAjax(urlstring,function(rest){
			var dataobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			ld("#cocmdDiv .ui-popup-centent .dialog-l-tit>img").attr('src',dataobj.userimage);
			ld("#cocmdDiv .ui-popup-centent .dialog-l-tit .name").html(dataobj.username);
			ld("#cocmdDiv .ui-popup-centent .dialog-l-tit .aj-ctime").html(dataobj.timeDescription);
			ld("#cocmdDiv .comment-feedcontent").html(dataobj.experience);

			ld("#cocmdDiv .ui-popup-centent").css('padding','16px 16px 0px 20px');
			ld("#cocmdDiv .ui-popup-centent .commenton-btnwarp").css('margin-top','10px');
			ld("#cocmdDiv .ui-popup-centent .commenton-btnwarp").css('margin-bottom','0px');
			ld("#cocmdDiv .ui-popup-centent .commenton-btnwarp").css('padding-bottom','10px');
		    ld("#cocmdDiv .ui-popup-centent p").find('.button-r').css('margin','3px -9px 0px 0px');
			if(ld("#cocmdDiv .comment-feedcontent").find("p[tag=del-comment-content-p]") != undefined)
			{
				ld("#cocmdDiv .comment-feedcontent [tag=del-comment-content-p]").remove();
			}
		   if(dataobj.scfcolumnlabe!=null)
			{
				for(var tmp_k=0;tmp_k<dataobj.scfcolumnlabe.length;tmp_k++)
				{
					ld("#cocmdDiv .comment-feedcontent").append('<p class="work-tit"  tag="del-comment-content-p">'+dataobj.scfcolumnlabe[tmp_k].label+'</p>');
				 
					ld("#cocmdDiv .comment-feedcontent .work-tit:last").after('<p  tag="del-comment-content-p">'+dataobj[dataobj.scfcolumnlabe[tmp_k].col]+"</p>");
				}
			}

			ld(".ui-mask").css('display','block');
				ld('#cocmdDiv').css('display','');
				
				var e = event || window.event;
				var obj = e.srcElement||e.target;
				var tagName = getId('cocmdDiv');
				FindEvent(obj,tagName,event,'',-300);
				var tag_left = parseInt(tagName.style.left);
				if(tag_left > 401){
					tagName.style.left = '35%'; 
				}
				//var workreport = dataobj.workreport;
				var issubmit = 1;
				ld('#cocmdDiv .button-r .button-green').unbind('click').click(function(){
					if(1 != issubmit) return false;//防止重复点击
					var reader_content = ld('#cocmdDiv textarea.input-text').val();
					var reader_score = ld('#cocmdDiv select.commenton-select').val();
					var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
					if(ld('#cocmdDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').length > 0){
						ld('#cocmdDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
							if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
								ccuser += ld(this).attr('userid')+',';
							}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
								ccgroup += ld(this).attr('groupid')+',';
							}
						});
					}
					var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=savereader&savetype=savefinish';
					urlstring += '&reader_content='+encodeURIComponent(reader_content)+'&reader_score='+reader_score;
					urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup+'';
					urlstring += '&workreportid='+workreport+'';
					issubmit = 2;
					RequestAjax(urlstring,function(rest){
						issubmit = 1;
						ld('#cocmdDiv textarea.input-text').val('');
						ld('#cocmdDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').remove();
						ld('#cocmdDiv').css('display','none');
						refresh();//刷新页面
						ld(".ui-mask").css('display','none');
					});
				});
				//sendemojicookieDiv
				/* editor:gyqX160720 bug:0023701 */
				ld('#cocmdDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
					ld('#cocmdDiv').css('display','none');
					ld(".ui-mask").css('display','none');
				});
		})
	});


	//点评日志按钮事件
	ld('div.pubclear [tag=now_reply]').on('click',function(event){
		var workreport = ld(this).parents(".mainuser").attr('workreportid');
		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=createreaderPop&workreportid='+workreport;
	  
		RequestAjax(urlstring,function(rest){
			var dataobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			ld("#dialogDiv .ui-popup-centent .dialog-l-tit>img").attr('src',dataobj.userimage);
			ld("#dialogDiv .ui-popup-centent .dialog-l-tit .name").html(dataobj.username);
			ld("#dialogDiv .ui-popup-centent .dialog-l-tit .aj-ctime").html(dataobj.timeDescription);
			if(dataobj.workreporttype==1)
			{
				ld("#dialogDiv .popup-head .popup-title").html("点评日志");
				ld("#dialogDiv .dialog-l-tit .content_dis").html("的日志原文");
				ld("#dialogDiv .comment-feedcontent .work-tit:first").html("今日工作总结");		
				ld("#dialogDiv .comment-feedcontent .work-tit:odd").html("今日工作计划");
			}
			else if(dataobj.workreporttype==2)
			{
				ld("#dialogDiv .popup-head .popup-title").html("点评周计划");
				ld("#dialogDiv .dialog-l-tit .content_dis").html("的周计划原文");
				 ld("#dialogDiv .comment-feedcontent .work-tit:first").html("本周工作总结");
				 ld("#dialogDiv .comment-feedcontent .work-tit:eq(1)").html("本周工作计划");
			
			}
			else if(dataobj.workreporttype==3)
			{
				ld("#dialogDiv .popup-head .popup-title").html("点评月计划");
				ld("#dialogDiv .dialog-l-tit .content_dis").html("的月计划原文");
				ld("#dialogDiv .comment-feedcontent .work-tit:first").html("本月工作总结");
				ld("#dialogDiv .comment-feedcontent .work-tit:odd").html("本月工作计划");
			}
			ld("#dialogDiv .comment-feedcontent .work-tit:first+p").html(dataobj.summary);
			ld("#dialogDiv .comment-feedcontent .work-tit:eq(1)+p").html(dataobj.workplan);
			ld("#dialogDiv .comment-feedcontent .work-tit:eq(2)+p").html(dataobj.experience);
			
			if(ld("#dialogDiv .comment-feedcontent").find("p[tag=del-comment-content-p]") != undefined)
			{
				ld("#dialogDiv .comment-feedcontent [tag=del-comment-content-p]").remove();
			}

		   if(dataobj.scfcolumnlabe!=null)
			{
				for(var tmp_k=0;tmp_k<dataobj.scfcolumnlabe.length;tmp_k++)
				{
					ld("#dialogDiv .comment-feedcontent").append('<p class="work-tit"  tag="del-comment-content-p">'+dataobj.scfcolumnlabe[tmp_k].label+'</p>');
				 
					ld("#dialogDiv .comment-feedcontent .work-tit:last").after('<p  tag="del-comment-content-p">'+dataobj[dataobj.scfcolumnlabe[tmp_k].col]+"</p>");
				}
			}
			//ld('#dialogDiv').removeClass('ui-hide');
			if(dataobj.entitytype == 'cocmd')
			{
				var obj = ld('.pubDetialC > div > div[workreportid='+workreport+'] div.reply-list-div');
				var isfinish = 'no';                    
				var workreplynum = ld(this).find('span span').html();
				var wordnumobj = ld('div[workreportid='+workreport+'] .reply-list-div');
				if(!empty(workreplynum) && parseInt(workreplynum) > 0){
					ld(wordnumobj).find('.swr-action-tbar').css('display','none');
					ld(wordnumobj).find('.reply-box-hidden').css('display','');
					ld(wordnumobj).find('.reply-list-userimg').css('display','none');
					ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none');
				}
				if(dataobj.approved == '0')
				{
					ld(wordnumobj).find('.swr-action-tbar').css('display','');
					ld(wordnumobj).find('.reply-box-hidden').css('display','none');
					ld(wordnumobj).find('.reply-list-userimg').css('display','none');
					ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none');
				}
				
				//回复文本框光标显示
				ld(wordnumobj).find('.reply-box-hidden').on('click',function(){
					ld(wordnumobj).find('.reply-box-hidden').css('display','none');
					ld(wordnumobj).find('.reply-list-userimg').css('display','');
					ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','');
				});
				//显示、隐藏回复层
				var cls = ld(obj).attr('class');
				if('pubclear reply-list-div' == cls){
					ld(obj).addClass('ui-hide');
					ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').addClass('ui-hide');
					return false;
				}else{
					ld(obj).removeClass('ui-hide');
					ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').removeClass('ui-hide');
				}
				var atgroup=[],atuser=[];
				//绑定@用户事件
				ld(obj).find('.btns .addtouch').unbind('click').click(function(event){
					var e = event || window.event;
					var thisobj = e.srcElement||e.target;
					//再次点击时，清空文本框内的值
					ld('#searchColleagueText').val('');
					//再次点击时。触发文本框的onkeyup事件
					if(isuserinit == 1){
						ld('#searchColleagueText').trigger("onkeyup");
					}
					UserPopupInit(thisobj,event,function(){//加载用户选择层
						//tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
						var tagName = document.getElementById('sendLogsmownerDiv');
						FindEvent(thisobj,tagName,event,60);
						if('' != ld('#ColleagueDiv').html()){
							//用户弹出框样式绑定
							ld('#ColleagueDiv > div').unbind('click').click(function(){
								// if(!empty(atuser) && atuser.indexOf(ld(this).attr('userid')) > -1){
								// 	return false;
								// }
								atuser[atuser.length] = ld(this).attr('userid');
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
									ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
									ld(this).find('span').html()+' '
								);
							});
						}
						if('' != ld('#DepartmentDiv').html()){
							//用户弹出框样式绑定
							ld('#DepartmentDiv > div').unbind('click').click(function(){
								// if(!empty(atgroup) && atgroup.indexOf(ld(this).attr('groupid')) > -1){
								// 	return false;
								// }
								atgroup[atgroup.length] = ld(this).attr('groupid');
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
									ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
									ld(this).find('span').html()+' '
								);
							});
						}
						ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
						ld('.usercontrol > li[tag=Department]').css('display','');//显示部门标签
						ld('.usercontrol > li[tag=Colleague]').css('display','');//显示同事标签
						ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
						ld('#searchColleagueText').css('display','none');//隐藏搜索框
						//用户搜索框placeholder属性赋值
						ld('#searchColleagueText').css('width','50%');//显示搜索框
						ld('#searchColleagueText').css('display','');//显示搜索框
						ld('#searchColleagueText').attr('placeholder','搜索');
						ld('#searchColleagueText').attr('tag',6);//1 发任务 2发日志 3@
						ld('#searchColleagueText').attr('workreport',workreport);//日志ID
						ld('#searchColleagueText').focus();
					});
				});

				//绑定添加表情
				ld(obj).find('.btns .addemojicookie').unbind('click').click(function(event){
					var e = event || window.event;
					var thisobj = e.srcElement||e.target;
					emojicookiePopupInit(thisobj,event,function(){
						var tagName = document.getElementById('sendemojicookieDiv');
						FindEvent(thisobj,tagName,event,60);
					
							//用户弹出框样式绑定
							ld('#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
									ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '['	+
									ld(this).attr('data-name')+']'
								);
							});
					});
				});
				
				ld('#button-finish,#button-ordinary').removeAttr('disabled');
				ld('#button-finish,#button-ordinary').css('opacity','1');
				var approve = 0;
				var issubmit = 1;
				ld(obj).find('#button-ordinary').unbind('click').click(function(){
					if(1 != issubmit) return false;
					isfinish = 'no';
					ld(wordnumobj).find('.swr-action-tbar').css('display','');
					ld(wordnumobj).find('.reply-box-hidden').css('display','none');
					ld(wordnumobj).find('.reply-list-userimg').css('display','none');
					ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','');
					ld(wordnumobj).find('div[tag=replyarea] textarea').attr('placeholder','添加回复...');
					ld('#button-finish,#button-ordinary').attr('disabled','disabled');
					ld('#button-finish,#button-ordinary').css('opacity','0.5');
				});
				
				var issubmit = 1;
				ld(obj).find('#button-finish').unbind('click').click(function(){
					if(1 != issubmit) return false;
					isfinish = 'yes';
					ld(wordnumobj).find('.swr-action-tbar').css('display','');
					ld(wordnumobj).find('.reply-box-hidden').css('display','none');
					ld(wordnumobj).find('.reply-list-userimg').css('display','none');
					ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','');
					ld(wordnumobj).find('div[tag=replyarea] textarea').attr('placeholder','汇报结果...');
					ld('#button-finish,#button-ordinary').attr('disabled','disabled');
					ld('#button-finish,#button-ordinary').css('opacity','0.5');
					approve = 1;
				});
				
				//绑定发布、取消事件
				var issubmit = 1;
				ld(obj).find('.reply-btn-r .button-submit').unbind('click').click(function(){
					if(1 != issubmit) return false;
					var replycontent = ld(obj).find('.input-wrapper textarea').val();
					if(empty(replycontent)){
						return false;
					}
					
					var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=savereader';
					if(isfinish=='yes'){
						urlstring += '&savetype=savefinish';
					}
					urlstring += '&reader_content='+encodeURIComponent(replycontent);
					urlstring += '&ccgroup='+atgroup+'&ccuser='+atuser;
					urlstring += '&workreportid='+workreport+'';
					issubmit = 2;
					RequestAjax(urlstring,function(rest){
						ld(obj).find('.input-wrapper textarea').val('');
						var num = ld(replyobj).find('span span').html();
						if(empty(num)) num = 0;
						else num = parseInt(num);
						if(isNaN(num)) num = 0;
						num += 1;
						ld(replyobj).find('span span').html(num);
						if(1 == num){
							ld(replyobj).find('span').removeClass('ui-hide');
						}
						//恢复没有输入前的关闭样式
						ld(wordnumobj).find('.swr-action-tbar').css('display','none');
						ld(wordnumobj).find('.reply-box-hidden').css('display','');
						ld(wordnumobj).find('.reply-list-userimg').css('display','none');
						ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none')
						ld('#delete'+workreport).attr('delete','no');
						//自动添加一行
						//23002: 工作协同-任务：执行人回复时点击【已完成，汇报结果】，回复，状态仍显示”执行中
						if(isfinish == 'yes'){
							ld("div[workreportid='"+workreport+"'] span.status:last").addClass('fontgreen').html("已完成");
						}
						getReplyList(obj,workreport);
						issubmit = 1;
					});
				});

				ld(obj).find('.reply-btn-r .button-cancel').unbind('click').click(function(){//隐藏
					ld(wordnumobj).find('.swr-action-tbar').css('display','');
					ld(wordnumobj).find('.reply-box-hidden').css('display','');
					ld(wordnumobj).find('.reply-list-userimg').css('display','none');
					ld(wordnumobj).find('div[tag=replyarea]').parent().not('div[tag=replylistarea]').css('display','none');
					ld('#button-finish,#button-ordinary').removeAttr('disabled');
					ld('#button-finish,#button-ordinary').css('opacity','1');
				});
				getReplyList(obj,workreport);//获取回复列表
			}
			else
			{
				ld(".ui-mask").css('display','block');
				ld('#dialogDiv').css('display','');
				
				var e = event || window.event;
				var obj = e.srcElement||e.target;
				var tagName = getId('dialogDiv');
				FindEvent(obj,tagName,event,'',-400);
				var tag_left = parseInt(tagName.style.left);
				if(tag_left > 401){
					tagName.style.left = '35%'; 
				}
				//var workreport = dataobj.workreport;
				var issubmit = 1;
				ld('#dialogDiv .button-r .button-green').unbind('click').click(function(){
					if(1 != issubmit) return false;//防止重复点击
					var reader_content = ld('#dialogDiv textarea.input-text').val();
					var reader_score = ld('#dialogDiv select.commenton-select').val();
					var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
					if(ld('#dialogDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').length > 0){
						ld('#dialogDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
							if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
								ccuser += ld(this).attr('userid')+',';
							}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
								ccgroup += ld(this).attr('groupid')+',';
							}
						});
					}
					var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=savereader&savetype=savecomment';
					urlstring += '&reader_content='+encodeURIComponent(reader_content)+'&reader_score='+reader_score;
					urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup+'';
					urlstring += '&workreportid='+workreport+'';
					issubmit = 2;
					RequestAjax(urlstring,function(rest){
						issubmit = 1;
						ld('#dialogDiv textarea.input-text').val('');
						ld('#dialogDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').remove();
						ld('#dialogDiv').css('display','none');
						refresh();//刷新页面
						ld(".ui-mask").css('display','none');
					});
				});
				//sendemojicookieDiv
				/* editor:gyqX160720 bug:0023701 */
				ld('#dialogDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
					ld('#dialogDiv').css('display','none');
					ld(".ui-mask").css('display','none');
				});
			}
		});
	});
	//点评、回复
	ld('div.func [tag=reply]').on('click',function(event){
		var replyobj = ld(this);
		var replytag = ld(this).find('span').attr('tag');
		if(1==2){//点评	'yes' == replytag || '2' == bigcategory
			
		}else{//回复
			var workreport = ld(this).attr('workreport');//日志ID
            var obj = ld('.pubDetialC > div > div[workreportid='+workreport+'] div.reply-list-div');
			var isreply = true;
			if('none' == ld(obj).find('.reply-box-hidden').css('display') && 
					'none' == ld(obj).find('.reply-list-userimg').css('display')){
				isreply = false;//关键回复，会隐藏两个层
			}
            if('yes' == replytag){
				//ld(obj).find('.reply-log-div').css('display','');
				ld('#reply_log').attr('workreport',workreport);
			}
            var workreplynum = ld(this).find('span span').html();
            var wordnumobj = ld('div[workreportid='+workreport+'] .reply-list-div');
            if(!empty(workreplynum) && parseInt(workreplynum) > 0){
                ld(wordnumobj).find('.reply-box-hidden').css('display','');
                ld(wordnumobj).find('.reply-list-userimg').css('display','none');
                ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none');
            }
            //回复文本框光标显示
            ld(wordnumobj).find('.reply-box-hidden').on('click',function(){
                ld(wordnumobj).find('.reply-box-hidden').css('display','none');
                ld(wordnumobj).find('.reply-list-userimg').css('display','');
                ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','');
				//回复列表点击回复，光标移入textarea文本域中 tujt 2015-05-08
				ld(wordnumobj).find('div[tag=replyarea] textarea').focus();
            });
			//显示、隐藏回复层
			var cls = ld(obj).attr('class');
			if('pubclear reply-list-div' == cls && isreply){
				ld(obj).addClass('ui-hide');
				ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').addClass('ui-hide');
				return false;
			}else{
				ld(obj).removeClass('ui-hide');
				ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').removeClass('ui-hide');
			}
			var atgroup=[],atuser=[];
			//绑定@用户事件
			ld(obj).find('.btns .addtouch').unbind('click').click(function(event){
				//添加透明背景遮罩
				ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
				//再次点击时，清空文本框内的值
				ld('#searchColleagueText').val('');
				//再次点击时。触发文本框的onkeyup事件
				if(isuserinit == 1){
					ld('#searchColleagueText').trigger("onkeyup");
				}
				var e = event || window.event;
				var thisobj = e.srcElement||e.target;
				UserPopupInit(thisobj,event,function(){//加载用户选择层
                    //tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
                    var tagName = document.getElementById('sendLogsmownerDiv');
                    FindEvent(thisobj,tagName,event,60);
                
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							// if(!empty(atuser) && atuser.indexOf(ld(this).attr('userid')) > -1){
							// 	return false;
							// }
							atuser[atuser.length] = ld(this).attr('userid');
							ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
					if('' != ld('#DepartmentDiv').html()){
						//用户弹出框样式绑定
						ld('#DepartmentDiv > div').unbind('click').click(function(){
							// if(!empty(atgroup) && atgroup.indexOf(ld(this).attr('groupid')) > -1){
							// 	return false;
							// }
							atgroup[atgroup.length] = ld(this).attr('groupid');
							ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
					ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
					ld('.usercontrol > li[tag=Department]').css('display','none');//显示部门标签
					ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
					ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
					ld('#searchColleagueText').css('display','none');//隐藏搜索框
					//用户搜索框placeholder属性赋值
					ld('#searchColleagueText').css('display','');//显示搜索框
					ld('#searchColleagueText').attr('placeholder','搜索同事');
					ld('#searchColleagueText').attr('tag',3);//1 发任务 2发日志 3@
					ld('#searchColleagueText').attr('workreport',workreport);//日志ID
					ld('#searchColleagueText').focus();
				});
			});
            
            	//绑定添加表情
			ld(obj).find('.btns .addemojicookie').unbind('click').click(function(event){
				//添加透明背景遮罩
				ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
				var e = event || window.event;
				var thisobj = e.srcElement||e.target;
				emojicookiePopupInit(thisobj,event,function(){
                    var tagName = document.getElementById('sendemojicookieDiv');
                    FindEvent(thisobj,tagName,event,60);
                
						//用户弹出框样式绑定
						ld('#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
							ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val(
								ld(obj).find('.reply-wrapper div[tag=replyarea] textarea').val() + '['	+
								ld(this).attr('data-name')+']'
							);
						});
				});
			});
			//绑定发布、取消事件
			var issubmit = 1;
			ld(obj).find('.reply-btn-r .button-submit').unbind('click').click(function(){
				if(1 != issubmit) return false;
				var replycontent = ld(obj).find('.input-wrapper textarea').val();
				if(empty(replycontent)){
				    if(typeof(ld("#replynull").attr("id")) !="undefined"){
                        ld("#replynull").attr('id','')
                    }
                    ld(this).parent().parent().find('.input-wrapper').attr('id','replynull');
                    flash_empty('replynull');    
				    return false;
				}
                var newusernames = '';
                var objReplyContent = replycontent.split("@"); 
                for(var i=1; i<objReplyContent.length; i++)
                {
                    newusernames += objReplyContent[i].substring(0,objReplyContent[i].indexOf(" "))+',';
                }
                    
                    var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
            		urlstring += '&method=getNewReportUserList&workreportid='+workreport+'&newusernames='+newusernames;
            		RequestAjax(urlstring,function(rest){
            			
                        var strhtml="";
                        var usernames="";
                        var usernamesid="";
                        ld('#remindsDiv .popup-centent .popup-centent-tpl').html("");
                        if(rest!=undefined&&trim(rest)!='')
                        {
                          
                             var dataObj=eval('('+rest+')');
                            for(var i=0;i<dataObj.list.length;i++)
                            {
                                usernames+=dataObj.list[i].username+',';
                                usernamesid+=dataObj.list[i].userid+',';
                            }
                           
                            if(!empty(usernames))
                            {
                                strhtml = '回复中提到的员工：'+usernames+'不在信息的原始范围中，是否要添加？添加后他们将能看到信息的原文和所有该信息的回复。';
                                 ld('#remindsDiv .popup-centent .popup-centent-tpl').html(strhtml);
                                 ld(".ui-mask").css('display','');
                                ld('#remindsDiv').css('display','');
                    			var e = event || window.event;
                    			var obja = e.srcElement||e.target;
                    			var tagName = getId('remindsDiv');
                    			FindEvent(obja,tagName,event,200,'');
                                var issubmit =1;
                                 ld('#remindsDiv .button-r .button-blue').unbind('click').click(function(){
                				if(1 != issubmit) return false;
                            
                                var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
                				urlstring += '&method=saveSendLog&workreportid='+workreport;
                				urlstring += '&replycontent='+replycontent+'&savetype=4&backstatus=yes';
                				urlstring += '&atgroup='+atgroup+'&atuser='+usernamesid;
                				issubmit = 2;
                				RequestAjax(urlstring,function(rest){
                					ld(obj).find('.input-wrapper textarea').val('');
                					var num = ld(replyobj).find('span span').html();
                					if(empty(num)) num = 0;
                					else num = parseInt(num);
                					if(isNaN(num)) num = 0;
                					num += 1;
                					ld(replyobj).find('span span').html(num);
                					if(1 == num){
                						ld(replyobj).find('span').removeClass('ui-hide');
                					}
                                    //恢复没有输入前的关闭样式
                                    ld(wordnumobj).find('.swr-action-tbar').css('display','none');
                                    ld(wordnumobj).find('.reply-box-hidden').css('display','');
                                    ld(wordnumobj).find('.reply-list-userimg').css('display','none');
                                    ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none')
                                    
                                    ld('#remindsDiv').css('display','none');
                                    ld(".ui-mask").css('display','none');
                                    //回复后隐藏删除
                                    ld('#delete'+workreport).attr('delete','no');
                                    //自动添加一行
                					getReplyList(obj,workreport);
                                    issubmit = 1;
                				    });
            			      });
								/* gyqX160720 */
								ld('#remindsDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
									ld('#remindsDiv').css('display','none');
									ld(".ui-mask").css('display','none');
								});
                            }
                        }
                        else
                        {
                                var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
                				urlstring += '&method=saveSendLog&workreportid='+workreport;
                				urlstring += '&replycontent='+replycontent+'&savetype=4';
                				urlstring += '&atgroup='+atgroup+'&atuser='+atuser;
                				issubmit = 2;
                				RequestAjax(urlstring,function(rest){
                					ld(obj).find('.input-wrapper textarea').val('');
                					var num = ld(replyobj).find('span span').html();
                					if(empty(num)) num = 0;
                					else num = parseInt(num);
                					if(isNaN(num)) num = 0;
                					num += 1;
                					ld(replyobj).find('span span').html(num);
                					if(1 == num){
                						ld(replyobj).find('span').removeClass('ui-hide');
                					}
                                    //恢复没有输入前的关闭样式
                                    ld(wordnumobj).find('.swr-action-tbar').css('display','none');
                                    ld(wordnumobj).find('.reply-box-hidden').css('display','');
                                    ld(wordnumobj).find('.reply-list-userimg').css('display','none');
                                    ld(wordnumobj).find('div[tag=replyarea]').parent().css('display','none');
                                    
                                     //回复后隐藏删除
                                     ld('#delete'+workreport).attr('delete','no');
                                        
                					//自动添加一行
                					getReplyList(obj,workreport);
                					issubmit = 1;
                				});
                        }
                        
            		});
            
			});
			ld(obj).find('.reply-btn-r .button-cancel').unbind('click').click(function(){//隐藏
				//ld(obj).addClass('ui-hide');
                ld(wordnumobj).find('.reply-box-hidden').css('display','');
                ld(wordnumobj).find('.reply-list-userimg').css('display','none');
                ld(wordnumobj).find('div[tag=replyarea]').parent().not('div[tag=replylistarea]').css('display','none');
                ld(this).parent().parent().find('div[tag=replyarea] textarea').val('');
			});
			getReplyList(obj,workreport);//获取回复列表
		}
	});
    //报告删除
    ld("div.func [tag=delete]").on('click',function(event){
        var workreport = ld(this).attr('workreport');
        var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=DeleteReport&workreportid='+workreport;
		RequestAjax(urlstring,function(rest){
			refresh();
		});
    });
    //共有同事列表
    ld(".userInfo .group [title]").on("click",function(event){
        var workreport = ld(this).attr('workreport');
        var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=getReportUserList&workreportid='+workreport;
       
		RequestAjax(urlstring,function(rest){
			var dataObj=eval('('+rest+')');
            var strhtml="";
            ld('#fs-tip .share-group-tpl .share-group-warp').html("");
            for(var i=0;i<dataObj.list.length;i++)
            {
               
                strhtml+='<div class="share-group-items pubclear"> ';
                strhtml+='<a class="profileimage" href="###"> ';
                strhtml+=' <img  src="';
                strhtml+=dataObj.list[i].userimage;
                strhtml+=' "/> ';
                strhtml+=' </a>  <span class="name fontblue">';
                strhtml+=dataObj.list[i].username;
               strhtml+='</span> <span class="infotype"></span></div>';
            }
            ld('#fs-tip .share-group-tpl .share-group-warp').html(strhtml);
            ld('#fs-tip .share-group-countman .num').html(dataObj.usercount);
            var e=event||window.event;
            var obj=e.srcElement||e.target;
            var tagName = getId('fs-tip');
            
            FindEvent(obj,tagName,event,'',0,'lefttop');
            tagName.style.display="block";
            ld('#fs-tip .close').on('click',function(){
                ld('#fs-tip').css('display','none');
            });
         
		});
    });
	//关键回复事件
	ld('div.func [tag=keyreply]').on('click',function(){
		var workreportid = ld(this).parent().parent().parent().parent().parent().attr('workreportid');
        var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=getKeyReply&workreportid='+workreportid;
		var obj = ld('.pubDetialC > div > div[workreportid='+workreportid+'] div.reply-list-div');
		var cls = ld(obj).attr('class');
		if('pubclear reply-list-div' == cls && 'none' == ld(obj).find('.reply-box-hidden').css('display') && 'none' == ld(obj).find('.reply-list-userimg').css('display')){//先隐藏关键回复
			ld(obj).addClass('ui-hide');
			ld('.pubDetialC > div > div[workreportid='+workreportid+'] .common-up').addClass('ui-hide');
			return false;//隐藏关键回复后，直接return
		}
		RequestAjax(urlstring,function(rest){
			if(empty(rest)) return false;
			var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			var replynode = ld('#replynode').html();
            var replyhtml = '',node = '',userimg='',userimage='';
            
			ld.each(restobj,function(key,replyobj){
                node = sprintf(replynode,
                    replyobj.curid,
                    replyobj.replyuserid,
					replyobj.ecnryptuserid,
					replyobj.replyusername+': ',
					replyobj.content,
					replyobj.createdtime
				);
				userimage = 'themes/images/defaultuser.png';
				if(!empty(replyobj.userimage)){
					userimage = replyobj.userimage;
				}
				userimg = '<img src="'+userimage+'" alt="" class="name-img">';
				node = strtr(node,'name-img',userimg);//用户图片
				replyhtml += node;
			});
			ld(obj).find('.reply-list').html(replyhtml);
			ld(obj).find('.reply-box-hidden').css('display','none');
			ld(obj).find('.reply-list-userimg').css('display','none');
			ld(obj).find('.reply-wrapper div[tag=replyarea]').parent().css('display','none');
			//显示关键回复
			if('pubclear reply-list-div' != cls){
				ld(obj).removeClass('ui-hide');
				ld('.pubDetialC > div > div[workreportid='+workreportid+'] .common-up').removeClass('ui-hide');
			}
			//绑定回复事件
			var atgroup=[],atuser=[];
			var replyobj = ld('.reply-list-wrapper .reply-list-reply');
			ld(obj).find('.reply-list .reply-list-icon').unbind('click').click(function(){
				var clsobj = ld(this).parent().parent().find('.reply-list-reply');
				var spans = ld(obj).find('.reply-list-user').find('span[replyuserid]');
				if('pubclear reply-list-reply' == ld(clsobj).attr('class')){
					ld(clsobj).addClass('ui-hide');
					//关闭回复列表的
					atuser = [];atgroup = [];
					ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
				}else{
					ld(clsobj).removeClass('ui-hide');
					atuser[atuser.length] = ld(spans).attr('replyuserid');
					//关键回复列表，点击回复后，光标移入textarea文本域中 tujt 2015-05-08
					ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').focus();
					ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val(
						'@'	+ ld(spans).html()+' '
					);
				}
			});
			//绑定回复的回复发布、取消按钮事件
			ld(replyobj).find('.btns .addtouch').on('click',function(event){//@事件
				//添加透明背景遮罩
				ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
                var e = event || window.event;
				var thisobj = e.srcElement||e.target;
				//再次点击时，清空文本框内的值
				ld('#searchColleagueText').val('');
				//再次点击时。触发文本框的onkeyup事件
				if(isuserinit == 1){
					ld('#searchColleagueText').trigger("onkeyup");
				}
				UserPopupInit(thisobj,event,function(){//加载用户选择层
                    //tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
                    var tagName = document.getElementById('sendLogsmownerDiv');
                    FindEvent(thisobj,tagName,event,60);
                    
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							if(!empty(atuser) && atuser.indexOf(ld(this).attr('userid')) > -1){
								return false;
							}
							atuser[atuser.length] = ld(this).attr('userid');
							ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val(
								ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
					if('' != ld('#DepartmentDiv').html()){
						//用户弹出框样式绑定
						ld('#DepartmentDiv > div').unbind('click').click(function(){
							if(!empty(atgroup) && atgroup.indexOf(ld(this).attr('groupid')) > -1){
								return false;
							}
							atgroup[atgroup.length] = ld(this).attr('groupid');
							ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val(
								ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
					ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
					ld('.usercontrol > li[tag=Department]').css('display','none');//显示部门标签
					ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
					ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
					ld('#searchColleagueText').css('display','none');//隐藏搜索框
					//用户搜索框placeholder属性赋值
					ld('#searchColleagueText').css('display','');//显示搜索框
					ld('#searchColleagueText').attr('placeholder','搜索同事');
					ld('#searchColleagueText').attr('tag',3);//1 发任务 2发日志 3@
					ld('#searchColleagueText').attr('workreport',workreportid);//日志ID
					ld('#searchColleagueText').focus();
				});
			});
            
			ld(replyobj).find('.btns .addemojicookie').on('click',function(event){//添加表情事件
				//添加透明背景遮罩
				ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
		       	var e = event || window.event;
				var thisobj = e.srcElement||e.target;
				emojicookiePopupInit(thisobj,event,function(){//加载用户选择层
	                //tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
	                var tagName = document.getElementById('sendemojicookieDiv');
	                FindEvent(thisobj,tagName,event,60);
						//用户弹出框样式绑定
						ld('#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
							ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val(
								ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val() +
									'[' + ld(this).attr('data-name')+']'
							);
						});
				});
			});
			//回复的回复 发布事件绑定
			var issubmit = 1;
			ld(replyobj).find('.reply-btn-r .button-submit').unbind('click').click(function(){
				if(1 != issubmit) return false;
				var replycontent = ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val();
				if(empty(replycontent)){
					return false;
				}
                
                
                var str = "@";
                var newusernames = '';
                var reg = new RegExp(str);
                if(reg.test(replycontent))
                {
                    var objReplyContent = replycontent.split("@"); 
                    for(var i=1; i<objReplyContent.length; i++)
                    {
                        newusernames += objReplyContent[i].substring(0,objReplyContent[i].indexOf(" "))+',';
                    }
                    
                    var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
            		urlstring += '&method=getNewReportUserList&workreportid='+workreportid+'&newusernames='+newusernames;
            		RequestAjax(urlstring,function(rest){
						if(empty(rest)){//为空，直接保存
							var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
							urlstring += '&method=saveSendLog&workreportid='+workreportid;
							urlstring += '&replycontent='+replycontent+'&savetype=4';
							urlstring += '&atgroup='+atgroup+'&atuser='+atuser;
							var replyid = ld(this).parent().parent().parent().parent().parent().attr('replyid');
							//urlstring += '&parentid='+replyid;
							issubmit = 2;
							RequestAjax(urlstring,function(rest){
								ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
								var num = ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html();
								if(empty(num)) num = 0;
								else num = parseInt(num);
								if(isNaN(num)) num = 0;
								num += 1;
								ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html(num);
								//回复后隐藏删除
								ld('#delete'+workreport).attr('delete','no');
								//自动添加一行
								getReplyList(obj,workreportid);
								issubmit = 1;
							});
							return false;
						}
            			var dataObj=eval('('+rest+')');
                        var strhtml="";
                        var usernames="";
                        var usernamesid="";
                        ld('#remindsDiv .popup-centent .popup-centent-tpl').html("");
                        for(var i=0;i<dataObj.list.length;i++)
                        {
                            usernames+=dataObj.list[i].username+',';
                            usernamesid+=dataObj.list[i].userid+',';
                        }
                        if(!empty(usernames))
                        {
                            strhtml = '回复中提到的员工：'+usernames+'不在信息的原始范围中，是否要添加？添加后他们将能看到信息的原文和所有该信息的回复。';
                        }
                        ld('#remindsDiv .popup-centent .popup-centent-tpl').html(strhtml);
                        ld(".ui-mask").css('display','');
                        ld('#remindsDiv').css('display','');
            			var e = event || window.event;
            			var obja = e.srcElement||e.target;
            			var tagName = getId('remindsDiv');
            			FindEvent(obja,tagName,event,200,'');
                        
                        var issubmit =1;
                        ld('#remindsDiv .button-r .button-blue').unbind('click').click(function(){
            				if(1 != issubmit) return false;
                                                        
                            var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
            				urlstring += '&method=saveSendLog&workreportid='+workreportid;
            				urlstring += '&replycontent='+replycontent+'&savetype=4&backstatus=yes';
            				urlstring += '&atgroup='+atgroup+'&atuser='+usernamesid;
            				var replyid = ld(this).parent().parent().parent().parent().parent().attr('replyid');
            				issubmit = 2;
            				RequestAjax(urlstring,function(rest){
            					ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
            					var num = ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html();
            					if(empty(num)) num = 0;
            					else num = parseInt(num);
            					if(isNaN(num)) num = 0;
            					num += 1;
            					ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html(num);
            					ld('#remindsDiv').css('display','none');
                                ld(".ui-mask").css('display','none');
                                //回复后隐藏删除
                                ld('#delete'+workreport).attr('delete','no');
                                //自动添加一行
            					getReplyList(obj,workreportid);
            					issubmit = 1;
            				});
            			});
						/* gyqX160720 */
						ld('#remindsDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
							ld('#remindsDiv').css('display','none');
							ld(".ui-mask").css('display','none');
						});
            		});
                }
                else
                {
                    var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
    				urlstring += '&method=saveSendLog&workreportid='+workreportid;
    				urlstring += '&replycontent='+replycontent+'&savetype=4';
    				urlstring += '&atgroup='+atgroup+'&atuser='+atuser;
    				var replyid = ld(this).parent().parent().parent().parent().parent().attr('replyid');
    				//urlstring += '&parentid='+replyid;
    				issubmit = 2;
    				RequestAjax(urlstring,function(rest){
    					ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
    					var num = ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html();
    					if(empty(num)) num = 0;
    					else num = parseInt(num);
    					if(isNaN(num)) num = 0;
    					num += 1;
    					ld('div[workreportid='+workreportid+'] .userInfo .func a[tag=reply] span.num span').html(num);
                        //回复后隐藏删除
                        ld('#delete'+workreport).attr('delete','no');
    					//自动添加一行
    					getReplyList(obj,workreportid);
    					issubmit = 1;
    				});
                }
                //0025898: 首页>工作协同：在任务的关键回复下回复，回复后弹出层未关闭				
                ld(replyobj).find('.reply-btn-r .button-cancel').click();
			});
			//回复的回复，取消按钮事件
			ld(replyobj).find('.reply-btn-r .button-cancel').unbind('click').click(function(){
				ld(this).parent().parent().parent().parent().addClass('ui-hide');
				//关闭回复列表的
				atuser = [];atgroup = [];
				ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
			});
		});
	});
	//用户头像绑定事件
	ld('.mainuser .content .ui-cont-list span img').on('mousemove',function(){
		ld(this).css('cursor','pointer');
	});
	//绑定图片点击事件
	ld('.mainuser .userInfo .item-top dt img').on('click',function(){
		var report_user_id = ld(this).attr('report_user_id');
		if(!empty(report_user_id)){
			window.open('index.php?module=CooperativeWork&action=index&report_user_id='+report_user_id+'&info=yes');
		}
	});
	ld('.mainuser .content .ui-cont-list span img').on('mouseover',function(){
		ld(this).css('cursor','');
	});
	ld('.mainuser .content .ui-cont-list span img').on('click',function(){
		//1、生成黑色底色
       /* if(document.getElementById("workimgbgDiv") != undefined){
			
            document.getElementById("workimgbgDiv").style.height = '100%';
			show("workimgbgDiv");
		}else{*/
			 if(document.getElementById("workimgbgDiv") != undefined){
				var my = document.getElementById("workimgbgDiv");
				if (my != null)
					my.parentNode.removeChild(my);
			 }
			var bgObj = document.createElement("div");
			bgObj.setAttribute('id','workimgbgDiv');
			bgObj.style.position="fixed";
			bgObj.style.top="0";
			bgObj.style.background="#000000";
			bgObj.style.color="#FFF";
			//bgObj.style.filter="progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
			//bgObj.style.opacity="0.3";
			bgObj.style.left="0";
			bgObj.style.width='100%';
			bgObj.style.height='100%';
			bgObj.style.zIndex = "10000";
			document.body.appendChild(bgObj);
			//
			var imgbg = '<div style="height: inherit;"><div class="imgbg-header"><span class="panel-visible-h" style="display: block;">×</span></div>';//顶层
			imgbg += '<div class="imgbg-content">';
			imgbg += '<div class="imgbg-left"><a href="javascript:;">‹</a></div>';
			imgbg += '<div class="imgbg-right"><a href="javascript:;">›</a></div>';
			imgbg += '<div class="imgbg-view"></div>';
			imgbg += '</div></div>';
			ld(bgObj).html(imgbg);
		//}
		var img = '<div><img src="'+ld(this).attr('src')+'"></div>';
		ld('#workimgbgDiv .imgbg-content div:eq(2)').html(img);
		var imgobj = ld(this);//记录当前点击的图片对象
		var achmentid = ld(this).parent().attr('achmentid');//获取当前图片对应的ID
		var idx = 0;var imglen = ld(this).parent().parent().find('span').length;
		//关闭图片显示浮层
		ld('#workimgbgDiv div.imgbg-header span.panel-visible-h').on('click',function(){
			ld('#workimgbgDiv').css('display','none');
		});
       
		if(imglen < 2){//不到两个图片
			ld('#workimgbgDiv .imgbg-content div:eq(0)').addClass('ui-visibhide');
			ld('#workimgbgDiv .imgbg-content div:eq(1)').addClass('ui-visibhide');
			return false;
		}else{//显示左右标签
			ld('#workimgbgDiv .imgbg-content div:eq(0)').removeClass('ui-visibhide');
			ld('#workimgbgDiv .imgbg-content div:eq(1)').removeClass('ui-visibhide');
		}
		//循环所有图片，判断当前图片的位置
		ld(this).parent().parent().find('span').each(function(){
			if(achmentid == ld(this).attr('achmentid')){//找到当前点击的ID值
				return false;//结束本次循环
			}
			idx ++;
		});
       if(idx==0)
       {
           //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。       
         ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
       }
       else if(idx==imglen-1)
       {
        //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。
        ld('#workimgbgDiv .imgbg-content .imgbg-right').addClass('ui-visibhide');
       }
		//左标签
		ld('#workimgbgDiv .imgbg-content div:eq(0)').find('a').on('click',function(){
		  
			if(idx == 0){//就是最左边的图片，则自动切换到最后一张图片
				idx = imglen - 1;
                ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
			}else{//切换到左边的图片
				idx --;
                if(idx==0)
                {
                   //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。
                    ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
                }
                ld('#workimgbgDiv .imgbg-content .imgbg-right').removeClass('ui-visibhide');
			}
			imgobj = ld(imgobj).parent().parent().find('span:eq('+idx+')');
			var imgsrc = ld(imgobj).find('img').attr('src');
			ld('#workimgbgDiv .imgbg-content div:eq(2) img').attr('src',imgsrc);
			return false;
		});
		//右标签
		ld('#workimgbgDiv .imgbg-content div:eq(1)').find('a').on('click',function(){
			if(idx == imglen - 1){//就是最右边的图片，则自动切换到第一张图片
				idx = 0;
                
			}else{//切换到右边的图片
				idx ++;
                if(idx==imglen-1)
                {
                    //idx = 0;
                    ld('#workimgbgDiv .imgbg-content .imgbg-right').addClass('ui-visibhide');
                }
                ld('#workimgbgDiv .imgbg-content .imgbg-left').removeClass('ui-visibhide');
			}
			imgobj = ld(imgobj).parent().parent().find('span:eq('+idx+')');
			var imgsrc = ld(imgobj).find('img').attr('src');
			ld('#workimgbgDiv .imgbg-content div:eq(2) img').attr('src',imgsrc);
			return false;
		});
	});
}

/**
 * 获取回复列表
 * @author Tujt 2015-02-06
 */
function getReplyList(obj,workreport){
    //获取回复列表
	var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=getReplyList&workreportid='+workreport;
	RequestAjax(urlstring,function(rest){
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var replynode = ld('#replynode').html();
		var replyhtml = '',node = '',userimg='',userimage='';
		ld.each(restobj,function(key,replyobj){
		   node = sprintf(replynode,
				replyobj.curid,
                replyobj.replyuserid,
                replyobj.ecnryptuserid,
				replyobj.replyusername+': ',
				replyobj.content,
				replyobj.createdtime
			);
			userimage = 'themes/images/defaultuser.png';
			if(!empty(replyobj.userimage)){
				userimage = replyobj.userimage;
			}
			userimg = '<a><img src="'+userimage+'" alt="" class="name-img" report_user_id = "'+replyobj.ecnryptuserid+'"></a>';
			node = strtr(node,'name-img',userimg);//用户图片
			replyhtml += node;
		});
		ld(obj).find('.reply-list').html(replyhtml);
		//回复列表的用户头像绑定事件
		ld(obj).find('.reply-list .reply-userimg .name-img').unbind('click').click(function(){
			var report_user_id = ld(this).attr('report_user_id');
			if(!empty(report_user_id)){
				window.open('index.php?action=index&module=CooperativeWork&report_user_id='+report_user_id+'&info=yes');
			}
		});
		//回复列表的回复事件
		var atgroup=[],atuser=[];
		var replyobj = ld('.reply-list-wrapper .reply-list-reply');
		ld(obj).find('.reply-list .reply-list-icon').unbind('click').click(function(){
			var replyid = ld(this).parent().parent().attr('replyid');
			ld('#searchColleagueText').attr('replyid',replyid)
			var cls = ld(this).parent().parent().find('.reply-list-reply').attr('class');
			var spans = ld(this).parent().find('.reply-list-user').find('span[replyuserid]');
			if('pubclear reply-list-reply' == cls){
				ld(this).parent().parent().find('.reply-list-reply').addClass('ui-hide');
				//关闭回复列表的
				atuser = [];
				ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
			}else{
				ld(this).parent().parent().find('.reply-list-reply').removeClass('ui-hide');
				atuser[atuser.length] = ld(spans).attr('replyuserid');
				//回复列表点击回复后，光标移入文本域中 tujt 2015-05-08
				ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').focus();
				ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val(
					'@'	+ ld(spans).html()+' '
				);
			}
		});
		//绑定回复的回复发布、取消按钮事件
		ld(replyobj).find('.btns .addtouch').on('click',function(event){//@事件
			//添加透明背景遮罩
			ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
			var e = event || window.event;
			var thisobj = e.srcElement||e.target;
			//再次点击时，清空文本框内的值
			ld('#searchColleagueText').val('');
			//再次点击时。触发文本框的onkeyup事件
			if(isuserinit == 1){
				ld('#searchColleagueText').trigger("onkeyup");
			}
			UserPopupInit(thisobj,event,function(){//加载用户选择层
                //tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
                var tagName = document.getElementById('sendLogsmownerDiv');
                FindEvent(thisobj,tagName,event,60);
                
				if('' != ld('#ColleagueDiv').html()){
					//用户弹出框样式绑定
					ld('#ColleagueDiv > div').unbind('click').click(function(){
					
						atuser[atuser.length] = ld(this).attr('userid');
						ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val(
							ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val() +
								'@' + ld(this).find('span').html()+' '
						);
					
					});
				}
				if('' != ld('#DepartmentDiv').html()){
					//用户弹出框样式绑定
					ld('#DepartmentDiv > div').unbind('click').click(function(){
					
						atgroup[atgroup.length] = ld(this).attr('groupid');
						ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val(
							ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val() +
								'@' + ld(this).find('span').html()+' '
						);
					
					});
				}
				ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
				ld('.usercontrol > li[tag=Department]').css('display','none');//显示部门标签
				ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
				ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
				ld('#searchColleagueText').css('display','none');//隐藏搜索框
				//用户搜索框placeholder属性赋值
				ld('#searchColleagueText').css('display','');//显示搜索框
				ld('#searchColleagueText').attr('placeholder','搜索同事');
				ld('#searchColleagueText').attr('tag',4);//1 发任务 2发日志 3@
				ld('#searchColleagueText').focus();
			});
		});
        
		ld(replyobj).find('.btns .addemojicookie').on('click',function(event){//@事件
			//添加透明背景遮罩
			ld(".ui-mask").css({'display':'block','backgroundColor':'transparent'});
			var e = event || window.event;
			var thisobj = e.srcElement||e.target;
			emojicookiePopupInit(thisobj,event,function(){//加载用户选择层
                //tujt 回复 @ 弹出用户层，用用户层遮住发布按钮
                var tagName = document.getElementById('sendemojicookieDiv');
                FindEvent(thisobj,tagName,event,60);
					//用户弹出框样式绑定
					ld('#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
						ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val(
							ld(thisobj).parent().parent().find('div[tag=replylistarea] textarea').val() +
								'[' + ld(this).attr('data-name')+']'
						);
					});
			});
		});
		//回复的回复 发布事件绑定
		ld(replyobj).find('.reply-btn-r .button-submit').unbind('click').click(function(){
			var replycontent = ld(this).parent().parent().find('div[tag=replylistarea] textarea').val();
			if(empty(replycontent)){
				return false;
			}
			var newusernames = '';
			var objReplyContent = replycontent.split("@"); 
			for(var i=1; i<objReplyContent.length; i++)
			{
				newusernames += objReplyContent[i].substring(0,objReplyContent[i].indexOf(" "))+',';
			}
				
			var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
			urlstring += '&method=getNewReportUserList&workreportid='+workreport+'&newusernames='+newusernames;
			RequestAjax(urlstring,function(rest){
				var usernames="";
				var usernamesid="";
				if(rest!=undefined&&trim(rest)!='')
				{
				  
					 var dataObj=eval('('+rest+')');
					for(var i=0;i<dataObj.list.length;i++)
					{
						usernames+=dataObj.list[i].username+',';
						usernamesid+=dataObj.list[i].userid+',';
					}

				}
				var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
				urlstring += '&method=saveSendLog&workreportid='+workreport;
				urlstring += '&replycontent='+replycontent+'&savetype=4';
				urlstring += '&atgroup='+atgroup+'&atuser='+usernamesid;
				var replyid = ld(this).parent().parent().parent().parent().parent().attr('replyid');
				urlstring += '&parentid='+replyid;
				RequestAjax(urlstring,function(rest){
					// ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
					ld(this).parent().parent().find('div[tag=replylistarea] textarea').val('');
					var num = ld('div[workreportid='+workreport+'] a[tag=reply] span span').html();
					if(empty(num)) num = 0;
					else num = parseInt(num);
					if(isNaN(num)) num = 0;
					num += 1;
					ld('div[workreportid='+workreport+'] a[tag=reply] span span').html(num);
					//自动添加一行
					getReplyList(obj,workreport);
				});
			})
		});
		//回复的回复，取消按钮事件
		ld(replyobj).find('.reply-btn-r .button-cancel').unbind('click').click(function(){
			ld(this).parent().parent().parent().parent().addClass('ui-hide');
			//关闭回复列表的
			atuser = [];atgroup = [];
			// ld(replyobj).find('.reply-wrapper div[tag=replylistarea] textarea').val('');
			ld(this).parent().parent().find('div[tag=replylistarea] textarea').val('');
		});
	});
}
/**
 * 下一页
 * @author Tujt 2015-02-05
 */
function WorkReportNextPage(){
    if(!empty(havenextpage) && 'yes' == havenextpage){
		curpagenum += 1;
		//分页时增加加载效果 tujt 2015-05-08
		ld('#worklist_page_'+curpagenum).html('<div style="text-align: center;padding-bottom: 15px;"><span class="loading-icon"><img src="themes/softed/images/loading.gif"></span><span class="loading-text">正在加载，请稍后……</span></div>');
		refresh();
	}else{//不分页
		return false;
	}
}

/**
 * 刷新
 * @author Tujt 2015-02-06
 */
function refresh(){
	fun_search('Refresh');
    /*var urlstring = 'smallcategory='+smallcategory+'&bigcategory='+bigcategory;
	urlstring += '&page='+curpagenum+'&searchcontent='+searchcontent;
    getWorkList(urlstring,function(){
		//if(2 == bigcategory){//待处理
			//ld('.userInfo .func ul li span.reply-title').html('点评');
		//}
	});*/
}
/**
 * 替换字符串
 * @author Tujt 2015-02-05
 */
function strtr(str,node,to){
    var regS = new RegExp(""+node+"","g");
	return str.replace(regS,to);
}
//仿php sprintf 方法
function sprintf(){
    var arg = arguments,
	str = arg[0] || '',i, n;
    for (i = 1, n = arg.length; i < n; i++) {
        str = str.replace(/%s/, arg[i]);
    }
    return str;
}


/**
 * 选择客户方法
 * @author Tujt 2015-02-03
 */
var selectAccount = {};
var delAccount={};//16359: 工作协同>发微博、发日志、发任务：关联客户、联系人，删除该客户、联系人，再关联此客户、联系人，结果：不显示关联客户、联系人。
function setAccountInfo(accountid,accountname){
    if(typeof (selectAccount[tag]) == 'undefined')
		selectAccount[tag] = [];
  
	if(selectAccount[tag].indexOf(accountid) > -1&&delAccount[accountid]!='del')
		return true;
    delAccount[accountid]='undel';
	selectAccount[tag][selectAccount[tag].length] = accountid;
	var tag = 'sendLog';
   
	ld('#'+tag+'Acctlist ul').append('<li accountid="'+accountid+'"><span class="item-name">'+accountname+'</span><span class="remove-h">×</span></li>');
	ld('#'+tag+'Acctlist').css('display','');
	//绑定删除事件
	ld('#'+tag+'Acctlist ul .remove-h').unbind('click').click(function(){
		var accountid = ld(this).parent().attr('accountid');
        delAccount[accountid]='del';
		ld('#'+tag+'Acctlist ul li[accountid='+accountid+']').remove();
		if(0 == ld('#'+tag+'Acctlist ul li').length){
			ld('#'+tag+'Acctlist').css('display','none');
		}
	});
    return true;//不走下面的代码
}
/**
 * 选择联系人方法
 * @author Tujt 2015-02-04
 */
 //保存后要清空全局变量
var selectContact = {};
var delContact={};//16359: 工作协同>发微博、发日志、发任务：关联客户、联系人，删除该客户、联系人，再关联此客户、联系人，结果：不显示关联客户、联系人。
function setContactInfo(contactid,contactname){
	if(typeof (selectContact[tag]) == 'undefined')
		selectContact[tag] = [];
	if(selectContact[tag].indexOf(contactid) > -1&& delContact[contactid]!='del')
		return true;
    delContact[contactid]='undel';
	selectContact[tag][selectContact[tag].length] = contactid;
	var tag = 'sendLog';
	ld('#'+tag+'Contlist ul').append('<li contactid="'+contactid+'"><span class="item-name">'+contactname+'</span><span class="remove-h">×</span></li>');
	ld('#'+tag+'Contlist').css('display','');
	//绑定删除事件
	ld('#'+tag+'Contlist ul .remove-h').unbind('click').click(function(){
		var contactid = ld(this).parent().attr('contactid');
		ld('#'+tag+'Contlist ul li[contactid='+contactid+']').remove();
         delContact[contactid]='del';
		if(0 == ld('#'+tag+'Contlist ul li').length){
			ld('#'+tag+'Contlist').css('display','none');
		}
	});
    return true;//不走下面的代码
}
/**
 * 选择产品方法
 * @author diony 2016-04-20
 */
var selectProducts = {};
var delProducts={};
function setProductsInfo(productid,productname){
    if(typeof (selectProducts[tag]) == 'undefined')
		selectProducts[tag] = [];
  
	if(selectProducts[tag].indexOf(productid) > -1&&delProducts[productid]!='del')
		return true;
    delProducts[productid]='undel';
	selectProducts[tag][selectProducts[tag].length] = productid;
	var tag = 'sendLog';
   
	ld('#'+tag+'Prolist ul').append('<li productid="'+productid+'"><span class="item-name">'+productname+'</span><span class="remove-h">×</span></li>');
	ld('#'+tag+'Prolist').css('display','');
	//绑定删除事件
	ld('#'+tag+'Prolist ul .remove-h').unbind('click').click(function(){
		var productid = ld(this).parent().attr('productid');
        delProducts[productid]='del';
		ld('#'+tag+'Prolist ul li[productid='+productid+']').remove();
		if(0 == ld('#'+tag+'Prolist ul li').length){
			ld('#'+tag+'Prolist').css('display','none');
		}
	});
    return true;//不走下面的代码
}
/**
 * 加载User弹出层
 * @author Tujt 2015-02-03
 */
var isuserinit = 0;
var userColleagueArray = new Array();//所有同事
var DepartmenArray = new Array();	//所有部门
/* gyq */
function UserPopupInit(obj,event,callback){
	var tagName = document.getElementById('sendLogsmownerDiv');
	if(typeof tagName == 'undefined') return false;

	ld('#sendLogsmownerDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
		ld('#sendLogsmownerDiv').css('display','none');
		ld(".ui-mask").css('display','none');
	});
 userColleagueArray=Array();
	FindEvent(obj,tagName,event);
	if(1 == isuserinit){//已经加载过
		callback();
		tagName.style.display = '';
		return false;
	}
	var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=getUsers';
	RequestAjax(urlstring,function(rest){
		if('' == rest) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var userhtml = '';
		if('' != restobj.Colleague){
			var i = 0;
			ld.each(restobj.Colleague,function(userkey,userobj){
				userhtml += '<div userid="'+userobj.userid.value+'"><img src="'+userobj.userimgpath.value+'"><span>'+userobj.lastname.value+'</span></div>';
				userColleagueArray[i] = new Array();
				userColleagueArray[i]['userid'] =userobj.userid.value;
				userColleagueArray[i]['userimgpath'] = userobj.userimgpath.value;
				userColleagueArray[i]['lastname'] = userobj.lastname.value;
				i++;
			});
		}
        
		ld('#ColleagueDiv').html(userhtml);
		//部门排序
		var grouphtml = '';
		if('' != restobj.Department){
			var i = 0;
			ld.each(restobj.Department,function(groupid,groupobj){
				grouphtml += '<div groupid="'+groupid+'"><span>'+groupobj['name']+'</span></div>';
				DepartmenArray[i] = new Array();
				DepartmenArray[i]['groupid'] = groupid;
				DepartmenArray[i]['lastname'] = groupobj['name'];
				i++;
			});
		}
		ld('#DepartmentDiv').html(grouphtml);
		callback();
		tagName.style.display = '';
		//isuserinit = 1;26940: 工作协同：发日志，工作心得体会里输入内容后再@用户，结果覆盖掉了原来输入的内容，当把当前内容清空后重新@，还会带入之前@的用户
	});
}
//搜索同事、部门
function clickSelectControl(obj,event){
	if(ld('#searchColleagueText').attr('tag') != undefined){
		var searchColleagueText = ld('#searchColleagueText').attr('tag');
		var searchpinyin = new Array();//匹配值
		var searchPin = '';//匹配值的拼音
		var seacrchValue = '';//搜索的值
		var isSel=0;
		var userhtml = '';
		var grouphtml = '';
 
       
		if(userColleagueArray.length > 0){
			getJsScript('include/js/multipingyin.js',function(){
				
				
				ld.each(userColleagueArray,function(key,userobj){
					if('' != obj.value){
						//alert(userobj.lastname);
						seacrchValue = userobj.lastname.indexOf(obj.value);
						searchpinyin = makePy(userobj.lastname);
						searchPin = searchpinyin.join("").toLowerCase();
						var selP = searchPin.indexOf(obj.value);
						if(seacrchValue >=0 || selP >= 0){
							userhtml += '<div userid="'+userobj.userid+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
						}
					}
					else{
						userhtml += '<div userid="'+userobj.userid+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
					}
				});
				ld('#ColleagueDiv').html(userhtml);	

				if(ld('#DepartmentDiv').css('display') != 'none'){
					ld.each(DepartmenArray,function(key,groupobj){
						if('' != obj.value){
							//alert(userobj.lastname);
							seacrchValue = groupobj.lastname.indexOf(obj.value);
							searchpinyin = makePy(groupobj.lastname);
							searchPin = searchpinyin.join("").toLowerCase();
							var selP = searchPin.indexOf(obj.value);
							if(seacrchValue >=0 || selP >= 0){
								grouphtml += '<div groupid="'+groupobj.groupid+'"><span>'+groupobj.lastname+'</span></div>';
							}
						}
						else{
							grouphtml += '<div groupid="'+groupobj.groupid+'"><span>'+groupobj.lastname+'</span></div>';
						}
					});
					ld('#DepartmentDiv').html(grouphtml);	
				}
				if(searchColleagueText == 1){//发任务 - 抄送范围
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							//清空ul下面的li标签
							ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li').remove();
							//添加新的li
							ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list').append('<li userid="'+ld(this).attr('userid')+'" emptype="p"><span class="item-name">'+ld(this).find('span').html()+'</span><span class="remove-h">×</span></li>');
							//绑定删除事件
							ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list .remove-h').unbind('click').click(function(){
								var liuserid = ld(this).parent().attr('userid');
								ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list li[userid='+liuserid+']').remove();
								return false;
							});
						});
					}
				}else if(searchColleagueText == 2){//发日志 - 抄送范围
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							//清空ul下面的li标签
							ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li').remove();
							//添加新的li
							ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list').append('<li userid="'+ld(this).attr('userid')+'" emptype="p"><span class="item-name">'+ld(this).find('span').html()+'</span><span class="remove-h">×</span></li>');
							ld('#sendLogsmownerDiv').find('.ui-popup-close').click();
							//绑定删除事件
							ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list .remove-h').unbind('click').click(function(){
								var liuserid = ld(this).parent().attr('userid');
								ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list li[userid='+liuserid+']').remove();
								return false;
							});
						});
					}
				}else if(searchColleagueText == 3){//@
					var workreport =  ld('#searchColleagueText').attr('workreport');//日志ID
					var objs = ld('.pubDetialC > div > div[workreportid='+workreport+'] div.reply-list-div');
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							ld(objs).find('.reply-wrapper div[tag=replyarea] textarea').val(
								ld(objs).find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
				}else if(searchColleagueText == 4){//@
					var replyid =  ld('#searchColleagueText').attr('replyid');//回复ID
				    var thisobj = ld('.pubDetialC div.reply-list-div div.reply-list div[replyid='+replyid+'] div.reply-list-reply');
                    //var workreport =  ld('#reply-list-wrapper pubclear').attr('replyid');//日志ID
					//var objs = ld('.pubclear > div[replyid='+replyid+'] div.reply-list-div');
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							ld(thisobj).find('.pubclear .reply-wrapper div[tag=replylistarea] textarea').val(
								ld(thisobj).find('.pubclear .reply-wrapper div[tag=replylistarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
					}
				}else if(searchColleagueText == 5){
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
							//alert(texttag);
							if(texttag != undefined){
								ld(texttag).val(ld(texttag).val() + '@' +ld(this).find('span').html()+' ');
							}else{
								ld('[name=sendLog] [name=workexperience]').val(ld('[name=sendLog] [name=workexperience]').val() + '@' +ld(this).find('span').html()+' ');
							}
							var atuser = ld('[name=sendLog]').find('[name=sendLog_at_user]').val();
							atuser += ld(this).attr('userid')+',';
							
							ld('[name=sendLog]').find('[name=sendLog_at_user]').val(atuser);
						});
					}
				}else if(searchColleagueText == 6){
					if('' != ld('#ColleagueDiv').html()){
						//用户弹出框样式绑定
						ld('#ColleagueDiv > div').unbind('click').click(function(){
						    var workreportid = ld(obj).attr('workreport');
							ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val(
								ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
								ld(this).find('span').html()+' '
							);
						});
						if(ld('#DepartmentDiv').css('display') != 'none'){
							ld('#DepartmentDiv > div').unbind('click').click(function(){
								var workreportid = ld(obj).attr('workreport');
								ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val(
									ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
									ld(this).find('span').html()+' '
								);
							});
						}
					}
				}
			});
		}
		
	}
}
/**
 * 加载表情弹出层
 * @author andrew 2015-05-20
 */
//gyq
function emojicookiePopupInit(obj,event,callback){
	var tagName = document.getElementById('sendemojicookieDiv');
	if(typeof tagName == 'undefined') return false;
	ld('#sendemojicookieDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
		ld('#sendemojicookieDiv').css('display','none');
		ld(".ui-mask").css('display','none');

	});
	FindEvent(obj,tagName,event);
		callback();
		tagName.style.display = '';
		return false;
}
function findPosX(obj) {
	var curleft = 0;
	if (document.getElementById || document.all) {
		while (obj.offsetParent) {
			curleft += obj.offsetLeft;
			obj = obj.offsetParent;
		}
	} else if (document.layers) {
		curleft += obj.x;
	}
	return curleft;
}
function findPosY(obj) {
	var curtop = 0;
	if (document.getElementById || document.all) {
		while (obj.offsetParent) {
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	} else if (document.layers) {
		curtop += obj.y;
	}
	return curtop;
}
function setUpload (){
	var myatt_id=0;
	var myatt_moduel='WordReport';
	var is_type = 0;
	UploadBind('multiple',new function(){
		this.select = function(file){
			if(file.size < 10485760){// 10 * 1024 * 2014(10MB)
				var fieldtype = new Array('gif','png','jpg','jpeg','bmp','ico');
				var file_type=file.type;
				var field_arr = file_type.split('.');
				field_arr[1] = field_arr[1].toLowerCase();
				for(var i =0;i<fieldtype.length;i++){
					if(fieldtype[i] == field_arr[1]){
						is_type = 1;break;
					}
				}
			}
			if(is_type == 0){
				RemindsMsg("","LdPopWidth400px","","yes","",onlyjpggifimg +'\n'+file.name);
				ld('#multiple').uploadify('stop');
				ld('#multiple').uploadify('cancel');
				ld('#multiple').onCancel(file);
				return false;
			}
		},
		this.start = function(file){
			if(is_type == 1){
				myatt_id = document.getElementById("current_userid").value;
				var str = {'myatt_id':myatt_id,'myatt_moduel':myatt_moduel,'uploadtype':'uploadimg'};
				ld('#multiple').uploadify('settings','method','post');
				ld('#multiple').uploadify('settings','formData',str);
			}
		},
		this.success = function(file, data, response){
			if(empty(data)) return false;
			var restobj = eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);
			if(empty(restobj.record)) return false;
			var tag = 'sendLog';
			ld('#'+tag+'UploadImg ul').append('<li record="'+restobj.record+'"><span class="item-name"><img class="name-img" alt="" src="'+restobj.path+encodeURIComponent(restobj.name)+'"></span><span class="remove-h">×</span></li>');
			ld('#'+tag+'UploadImg').css('display','');
			//绑定移入显示删除标志事件
			ld('#'+tag+'UploadImg ul li').on('mouseenter',function(){
				//alert('here 1');
				ld(this).find('span.remove-h').css('display','inline');
			});
			//绑定移出隐藏删除标志事件
			ld('#'+tag+'UploadImg ul li').on('mouseleave',function(){
				ld(this).find('span.remove-h').css('display','none');
			});
			//绑定图片删除事件
			ld('#'+tag+'UploadImg ul li span.remove-h').on('click',function(){
				var record = ld(this).parent().attr('record');
				ld('#'+tag+'UploadImg ul li[record='+record+']').remove();
				if(0 == ld('#'+tag+'UploadImg ul li').length){
					ld('#'+tag+'UploadImg').css('display','none');
				}
				return false;
			});
		},
		this.end = function(){
			ld('#multiple').addClass('multiple-div');
		}
	});
    setUpload_att(); 
}

function setUpload_att (){
	var myatt_id=0;
	var myatt_moduel='WordReport';
	var is_type = 0;
	UploadBind('multiple_att',new function(){
		this.select = function(file){
			if(file.size < 10485760){// 10 * 1024 * 2014(10MB)
				var fieldtype = new Array('bmp','csv','chm','chw','dat','dll','doc','docx','dot','dps','dpt','et','ett',
							'gif','html','iso','ini','js','jpg','jpeg','rar','php','pdf','png','ptf',
							'ppt','pptx','pot','pps','rtf','sql','txt','wps','wpt','xls','xlsx','xml',
							'xlt','zip','eml','msg','ico','x-icon');
				var file_type=file.type;
				var field_arr = file_type.split('.');
				field_arr[1] = field_arr[1].toLowerCase();
				for(var i =0;i<fieldtype.length;i++){
					if(fieldtype[i] == field_arr[1]){
						is_type = 1;break;
					}
				}
			}
			if(is_type == 0){
				RemindsMsg("","LdPopWidth400px","","yes","",Afinstpasdne3M +'\n'+file.name);
				ld('#multiple_att').uploadify('stop');
				ld('#multiple_att').uploadify('cancel');
				ld('#multiple_att').onCancel(file);
				return false;
			}
		},
		this.start = function(file){
			if(is_type == 1){
				myatt_id = document.getElementById("current_userid").value;
				var str = {'myatt_id':myatt_id,'myatt_moduel':myatt_moduel,'uploadtype':'uploadatt'};
				ld('#multiple_att').uploadify('settings','method','post');
				ld('#multiple_att').uploadify('settings','formData',str);
			}
		},
		this.success = function(file, data, response){
			if(empty(data)) return false;
			var restobj = eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);
			if(empty(restobj.record)) return false;
			var tag = 'sendLog';
			ld('#'+tag+'UploadAtt ul').append('<li record="'+restobj.record+'"><img alt="'+restobj.name+'" src="themes/softed/images/file.png"><span class="upload-attname">'+restobj.name.substring(0,30)+'<br/><span class="remove-h"> 取消</span></span></li>');
            ld('#'+tag+'UploadAtt').css('display','');
			//绑定移入显示删除标志事件
			ld('#'+tag+'UploadAtt ul li').on('mouseenter',function(){
				//alert('here 1');
				ld(this).find('span.remove-h').css('display','inline');
			});
			//绑定移出隐藏删除标志事件
			ld('#'+tag+'UploadAtt ul li').on('mouseleave',function(){
				ld(this).find('span.remove-h').css('display','none');
			});
			//绑定图片删除事件
			ld('#'+tag+'UploadAtt ul li span.remove-h').on('click',function(){
			 	var record = ld(this).parent().parent().attr('record');
				ld('#'+tag+'UploadAtt ul li[record='+record+']').remove();
				if(0 == ld('#'+tag+'UploadAtt ul li').length){
					ld('#'+tag+'UploadAtt').css('display','none');
				}
				return false;
			});
		},
		this.end = function(){
			ld('#multiple_att').addClass('multiple-div');
		}
	});
}

/**
 * flash上传图片加载事件集成方法
 * @author Tujt 2015-02-10
 */
function UploadBind(ids,callback){
	var maxfilesize = 100 * 1024 * 1024;
	ld('#'+ids).uploadify({
		//uploadify.swf文件的路径。如果可能的话，这个路径应该是相对于根以避免出现问题，但也将接受相对于当前脚本的路径。
		'swf'      : 'uploaddify/uploadify.swf',//默认为uploadify.swf
		'uploader' : 'modules/Home/multipleUpload.php',//服务端处理脚本,
		'buttonText':'',//按扭的文字 arrJsPopLabel['BROWSETHEFILE']
		'height' : 14,//按扭高度
		'width' :15 ,//按扭宽度
		'onDialogClose':function(){},
		'buttonClass':'mybutton',
		'removeTimeout':1,
		'progressData':'percentage',
		'queueID'  : 'queue',
		//'queueSizeLimit':10,
		'fileSizeLimit': maxfilesize,//100 * 1024 * 1024 （100MB）
		'sizeLimit' 	 : maxfilesize ,
		//'uploadLimit':1,
		'successTimeout' : 5,
		//上传成功回调函数
		'onUploadSuccess' : function(file, data, response) {
			if(!empty(callback.success)){
				data = trim(data);
				callback.success(file, data, response);
			}
		},
		//上传完成
		//会先调用onUploadSuccess然后才调用onUploadComplete
		'onUploadComplete' : function(file) {
			if(!empty(callback.complete)){
				callback.complete(file);
			}
		},
		//从对话框回选择了文件
		//对不起，目前只支持单文件上传,'+ file_name_value1+ ' 已经上传成功! 
		'onSelectError' : function(file,errorCode,errorMsg) {
			if(!empty(callback.error)){
				callback.error(file,errorCode,errorMsg);
			}
		},

		//上传进度
		'onUploadProgress' : function(file, bytesUploaded, bytesTotal, totalBytesUploaded, totalBytesTotal) {
			ld('#progress').html(totalBytesUploaded + ' bytes uploaded of ' + totalBytesTotal + ' bytes.');
		},
	
		//开始上传
		'onUploadStart' : function(file) {
			if(!empty(callback.start)){
				callback.start(file);
			}
		}, 
		//选择上传文件时触发。
		'onSelect':function(file)
		{
			if(!empty(callback.select)){
				callback.select(file);
			}
		}
	});
	if(!empty(callback.end)){
		callback.end();
	}
}

//给弹出层加载拖动事件
function WinPopup(idstring){    
	var box = document.getElementById(idstring);
	var inputs = box.getElementsByTagName('*');
	var inputlen = inputs.length;
	var pointer = arguments[1]?arguments[1]:'ui-popup-cursor';
	var close = arguments[2]?arguments[2]:'ui-popup-close';    
	var header;var aClass = [];var dClass = [];
	var reClass = new RegExp("(^| )" + pointer + "( |$)");
	var closeCls = new RegExp("(^| )" + close + "( |$)");
	for(var i=0; i<inputlen; i++){
		reClass.test(inputs[i].className) && aClass.push(inputs[i]);
		closeCls.test(inputs[i].className) && dClass.push(inputs[i]);
	}
    var clslen = 0;
	if(aClass && aClass.length > 0){
	   clslen = aClass.length;
	}
	var scrollHeight = window.screen.availHeight,
	scrollWidth = window.screen.availWidth;

    if(clslen > 0){
    	if(box.getAttribute('id')!='sendLogsmownerDiv'){
	        for(var i=0; i<clslen; i++){
	    		aClass[i].style.cursor = 'move';
	    		aClass[i].onmousedown = function(event){//鼠标按钮被按下
	    			
		    			box.style.opacity = 0.5;
		    			box.style.filter = "alpha(opacity=50)";
		    			var event = window.event || event;
		    			var mouseX = event.clientX,
		    			mouseY = event.clientY;
		    			var boxtop,boxleft;
		    			if(box.style.top) boxtop = box.style.top;
		    			else boxtop = box.offsetTop+document.body.scrollTop;
		    			if(box.style.left) boxleft = box.style.left;
		    			else boxleft = box.offsetLeft;
		    			objY = parseInt(boxtop),
		    			objX = parseInt(boxleft);
		    			document.onmousemove = function(event){
		    				var event = window.event || event;
		    				box.style.top = event.clientY - mouseY + objY + "px",
		    				box.style.left =event.clientX - mouseX + objX + "px";
		    			}
		               
		    			document.onmouseup = function(){//鼠标按键松开
		    				box.style.opacity = 1;
		    				box.style.filter = "alpha(opacity=100)";
		    				document.onmousemove = null;
		    			}
		    			return false;
	    			}
	    		}
    	}        
    }
	if(!dClass || !dClass.length) return false;
	clslen = dClass.length;var cls,clslock
	for(var i=0; i<clslen; i++){
		cls = dClass[i];
		dClass[i].onclick = function(){
			if('' != cls.getAttribute('lock')){
				clslock = cls.getAttribute('lock');
				if('lock' == clslock){
					lingdangJS_DialogBox.unblock();
				}else if(document.getElementById(clslock) != undefined){
					document.getElementById(clslock).style.display = 'none';
				}
			}
			box.style.display = 'none';
            ld(".ui-mask").css('display','none');
		};
	}
}

function FindEvent(obj,tagName,event){
	var e = event || window.event;
	if(e){
		var x = (e.x || e.pageX);
		var y = (e.y || e.pageY);
	}
    if(pop_obj_coordinate!=null&&tagName!=pop_obj_coordinate && pop_num == 0)
    {
       //17757: 首页>工作协同>发微博、发日志、发任务：选择抄送范围、选择点评人、选择执行人弹出层。当点击其他事件时，应该关闭该弹出层。
        pop_obj_coordinate.style.display="none";
    }
	pop_num = 0;
	var leftsides = arguments[3]?arguments[3]:20;
	var topsides = arguments[4]?arguments[4]:10;
    var location_define=arguments[5]?arguments[5]:'-1';
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);

	var maxW = tagName.style.width;//元素宽度
   
	var widthM = maxW.substring(0,maxW.length-2);//去掉像素单位
	var getVal = eval(leftSide) + eval(widthM);
	var xScroll=(document.documentElement.scrollWidth>document.documentElement.clientWidth) ? document.documentElement.scrollWidth : document.documentElement.scrollWidth; //屏幕滚动总宽度
    pop_obj_coordinate=tagName;

	var position_attachment=false;//是否根据鼠标位置显示
	switch(ld(obj).attr('class')){
		case 'selectbar':{
			position_attachment=true;
			break;
		}
		case 'addemojicookie':{
			position_attachment=true;
			break;
		}
		case 'addtouch':{
			position_attachment=true;
			break;
		}
	}
	if(position_attachment){
		tagName.style.top = topSide+obj.clientHeight+3+'px';
		tagName.style.left=leftSide+'px';

	}else{  //其他弹出框居中显示位置
	 //    if(getVal> xScroll ){
		// 	leftSide = eval(leftSide) - eval(widthM);
		// 	tagName.style.left = leftSide + 34 + 'px';
		// }else{
			//tagName.style.left= leftSide + leftsides - widthM + 'px';
	        //15547: (IE7及IE8兼容问题)首页>工作协同,关于提示信息显示的问题.
		        if(location_define=='lefttop')
		        {
		            //18088: 首页>工作协同：点击查看3个同事，弹出框显示位置不合理。
		            tagName.style.left=leftSide+"px"
		        }
		        else
		        {
		            if(widthM!='')
		            	tagName.style.left=(xScroll-eval(widthM))/2+"px";//将弹出框居中
		            else
		            tagName.style.left=(xScroll)/2+"px";//17160: 客户里面的工作协同发任务后取消，弹出的框框在左侧
		        }
			 //}
    
	/*	if(leftSide < 1100){
			x = parseInt(x);
			tagName.style.left = x  + leftsides;
		}*/
		y = parseInt(y);
		tagName.style.top = topSide+obj.clientHeight+13 + topsides + 'px';// + '-1'+'px';
	}
}

//页面滚动时，左边固定
ld.fn.smartFloat = function() { 
    var position = function(element) { 
        var top = element.position().top; //当前元素对象element距离浏览器上边缘的距离 
        var pos = element.css("position"); //当前元素距离页面document顶部的距离 
        ld(window).scroll(function() { //侦听滚动时 
            var scrolls = ld(this).scrollTop(); 
            if (scrolls > top) { //如果滚动到页面超出了当前元素element的相对页面顶部的高度 
                 element.css({ 
                        position: "fixed",
                        top: 0 ,
                        marginTop:0
                    })
            }else { 
                element.css({ //如果当前元素element未滚动到浏览器上边缘，则使用默认样式 
                    position: pos, 
                    top: top ,
                    marginTop:"16px"
                })
            } 
        }); 
    }; 
    return ld(this).each(function() { 
        position(ld(this));                          
    }); 
}; 
/**发微博，发日志等编辑框为空提醒
*/
function normal(id,times){    
    var obj=ld("#"+id);    
    obj.css("background-color","#FFF");    
    if(times<0)    
    {    
        return;    
    }    
    times=times-1;    
    setTimeout("error_empty('"+id+"',"+times+")",150);    
}    
function error_empty(id,times){    
    var obj=ld("#"+id);    
    obj.css("background-color","#F6CECE");    
    times=times-1;    
    setTimeout("normal('"+id+"',"+times+")",150);  
} 
function flash_empty(id){
    error_empty(id,4);
} 
/**
 * 工作报告Ajax
 * @author Tujt 2015-02-09
 */
function WordReportAjax(data,callback){
	document.getElementById('coordinationStatus').style.display = '';
	new Ajax.Request(
		'index.php',
		{queue:{position:"end", scope:"command"},
			method:"post",
			postBody:data,
			onComplete:function (response) {
				document.getElementById('coordinationStatus').style.display = 'none';
				callback(trim(response.responseText));
			}
		}
	);
}

function delete_log(){
	window.open("index.php?module=CooperativeWork&action=index&massdelete=true");
}

//工作协同发日志、微博、任务抄送范围增加记住最近的设置
var getSendLogCcrange = function(cur_panel){
	if(ld('#stream-hsent-title') != undefined){
		ld('#stream-hsent-title > li > a').each(function(){
			var _class = ld(this).attr('class');
			var div_tag = 'sendLogFoot > div[tag=ccrange]';
			if(_class != undefined && _class == 'curr'){
				if(empty(cur_panel)){
					cur_panel = ld(this).attr('cont');
				}
				if(!empty(cur_panel)){
					var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=getLatelyScope&cur_panel='+cur_panel;
					RequestAjax(urlstring,function(rest){
						if(rest != ''){
							var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
							ld('#'+div_tag+' ul.reader-bar-list').empty();
							ld.each(restobj,function(index,userobj){
								ld('#'+div_tag+' ul.reader-bar-list').append('<li userid="'+userobj.userid+'"><span class="item-name">'+userobj.last_name+'</span><span class="remove-h">×</span></li>');
								//绑定删除事件
								ld('#'+div_tag+' ul.reader-bar-list li[userid='+userobj.userid+'] .remove-h').unbind('click').click(function(){
									var liuserid = ld(this).parent().attr('userid');
									ld('#'+div_tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
									return false;
								});
							});
						}
					});	
				}
			}
		});
	}
}

/**

设置弹出框
**/
function  setWorkReportShowPopup()
{
     ld.ajax({
        url: 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=setShowPopup',
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                
                 $("status").style.display="none";
               
                var Popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth350px","CooperativeWork","","","","");
                           
                Popupobj.show(data.result.content);
                document.getElementById(Popupobj.divid+'_imgclose').onclick=function()
                {
                    
                    for(var i=0;i<data.result.all.length;i++)
                    {
                        
                         if(ld("#"+Popupobj.divid).find("[name=cur_"+data.result.all[i].type+"]").val()!=ld("#"+Popupobj.divid).find("[name="+data.result.all[i].type+"]").val())
                         {
                            
                            window.location.reload();
                            return false;
                         }
                    }
                    Popupobj.CancelEvent();
                };
               
               
                return Popupobj;
            }    else
            {
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        
        }
       
    });
}
function setWorkReportShowStatus(obj,type)
{
    //obj.disabled=true;
   var rowIndex=obj.parentNode.parentNode.rowIndex;
   var secondcell=document.getElementById("dv_workreportshow").rows[rowIndex].cells[1];
    
   ld.ajax({
        url: 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=saveReportShow&type='+type,
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            //obj.disabled=false;
            if(data.code==1)
            {
                
                if(data.result.reportshow=='yes')
                {
                   // obj.value="停用";
                    ld(obj).text('停用');
                    secondcell.innerHTML=("<span style='color:green'>是</span><input type='hidden' value='yes' name='cur_"+type+"'>");
                }
                else
                {
                     //obj.value="启用";
                    ld(obj).text('启用');
                    secondcell.innerHTML=("<span style='color:red'>否</span><input type='hidden' value='no' name='cur_"+type+"'>");
                }
                
            }    
            else
            {
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        
        }
       
    });
    
}

