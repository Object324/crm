var coordination_searchscope='';
var cur_left_location = 'all';//当前左侧导航，all全部，myself我的工作台，mymsg我的消息
var curpagenum = 0,havenextpage = 'no';//当前页数、是否有下一页
var bigcategory = '1',smallcategory = 'all',searchcontent='';
var ViewallCooperativeWork='yes';//是否为查看全部界面yes:是
var cos_webuploader = 0;
var current_date = '';
var weekStart = '';
var weekEnd = '';
var MonthStart = '';
var MonthEnd = '';
var editDate = 'yes';
var minDate = '';
var maxDate = '';
ld.fn.smartFloat = function(){
	var position = function(element) {
		var top = element.position().top; //当前元素对象element距离浏览器上边缘的距离
		var pos = element.css("position"); //当前元素距离页面document顶部的距离
		ld(window).scroll(function() { //侦听滚动时

		});
	};
	return ld(this).each(function() {
		position(ld(this));
	});
}

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
	var homecontrol = ld("#homecontrol").val();
	if(homecontrol != undefined){
		if(1 == homecontrol){
			isword = 2;
			initWordReportLeftBtn();//左侧导航
			initWordReport();
			intStart();//右侧日程
		}else if(0 == homecontrol){
			iswidget = 2;
			initWidgets();
		}
	}

});
//选择抄送范围事件
setEventSelectUser = function(div_tag,selectNum,selectUserid,selectDisableUserid=''){
	var module = 'CooperativeWork';
    if(div_tag=='_select_sponsor_div')
    {
        //edit:can BUG0073784 工作汇报设置李小娟的查看范围只有销售部华东区，但李小娟的账号可通过筛选看到其他部门的工作汇报 
     var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=checkbox';   
    }
    else
	var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=checkbox&checkprivilege=no';

	if(div_tag=='_select_sponsor_div')
	{
		//选择发起人
		popup_url+="&popup_scopetype=private";
	}
	//zkt 0046534: （81mis.com/kfbcrm）OA表单-工作汇报-新建，新建日志抄送时，没有“子部门默认收起”的控制按钮
	var popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['searchforcolleagues']+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var scopepopupobj =  new ScopePopupObj(module);
		scopepopupobj.popup_caption_value =arrJsPopLabel['LBL_SELECTUSER'];//标题
		scopepopupobj.popup_searchvalue = arrJsPopLabel['searchforcolleagues'];//查询框默认值
		scopepopupobj.popup_header = popup_header;
		scopepopupobj.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'display: block;position: absolute;top: 84px;\'><div class=\'view-search\' ></div></div>';
		scopepopupobj.popup_footer = '<div class="E_pbtn"><div>'+arrJsPopLabel['isselect']+'<span id="selectnum">0</span>/<span id="totalnum">77</span></div><div><input class="E_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+'<input class="E_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div></div>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			cls_ScopePopup.prop.popup_module = module;//模块
			cls_ScopePopup.prop.popup_value = selectUserid;
			var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
			ld('#'+cls_ScopePopup.popup_divid).css('z-index',"9999");
			//加载用户总数和已选的用户数
			scopepopupobj.setEventLoad=function(){
				var selectUseridAll = [];//显示的全部用户数
				var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
				//alert(cls_ScopePopup.popup_divid);
				var disabled_arr = selectDisableUserid.split(',');
				ld('#'+cls_ScopePopup.popup_divid+' .filetree span').each(function(){
					var inputobj = ld(this).find('[name=popup_inputtype]');
					var record = ld(this).attr('record');
					var recordarr = record.split('_');
					if (disabled_arr.length > 0){
						ld.each(disabled_arr,function (index,userid) {
							if(userid == recordarr[1] && recordarr[0] == 'user'){
								inputobj.attr('disabled',true);
								inputobj.css('border-color','#9DBDFF');
								inputobj.css('background-color','#9DBDFF');
							}
						})
					}
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
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){

					//基本查询 - 发起人
					if(div_tag == '_select_sponsor_div'){

						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

						var userid = trim(cls_ScopePopup.return_obj.return_id,',');
						var _name;
						ld('#'+div_tag+' ul.reader-bar-list').empty();
						//BUG0064739 zxm 20230413 kfbcrm 工作汇报
						if(empty(userid)){
							return false;
						}
						userid = userid.split(',');
						if(userid.length == 1){
							//一个用户
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
						//edit:can 2020-11-25 043346: （https://61mis.com/kfbtest [^]）工作汇报的日志中如果先将页面下拉到底部加载出更多的工作汇报，这时候点击筛选，指定发起人。下方新加载出来的信息不会被隐藏。
						ld('.pubDetialC').html('<div id="worklist_page_1"></div>');
						fun_search();
					}else{
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
							RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							var userid = cls_ScopePopup.return_obj.return_id.split(',');
							var username = cls_ScopePopup.return_obj.return_name.split(',');
							//每次确认之前，先情况之前记录
							ld('#'+div_tag+' ul.reader-bar-list').empty();
							var disabled_arr = selectDisableUserid.split(',');
							for(var i = 0; i < userid.length; i++){
								var disabled = 'no';
								if (disabled_arr.length > 0 && div_tag == 'sendLogFoot > div[tag=ccrange]'){
									ld.each(disabled_arr,function (index,tmpuserid) {
										if(userid[i] == tmpuserid){
											ld('#'+div_tag+' ul.reader-bar-list').append('<li userid="'+userid[i]+'" disabled=""><span class="item-name">'+username[i]+'</span></li>');
											disabled = 'yes';
										}
									});
								}
								if (disabled == 'no'){
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
					}
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
					{
						//通讯录(pc端企业微信)
						cls_wxOpenDataobj.bindAllOpenData();
					}

				});
			}
		});
	});
}
var global_worktype="";
var cur_panel='';//设置当前点击的面板tag的属性值
var old_panel = '';
var cur_panel_tag = '';
var pop_obj_coordinate=null;//弹出层对象
var pop_num = 0;//弹出层打开时，是否关闭其他弹出层 0是  1否
function setPanelShow(){

	ld('.form-thumb').addClass('ui-hide');
	ld('#sendLog').removeClass('ui-hide');
	//chj 2021/5/26 46074: https://kehu001.com/weixin/kh42705/ [^] 客户工作汇报模块下发布任务以后无法看见，同时关闭了微博，但是工作提醒出现有新的微博抄送给你字样
	if(empty(cur_panel)){
		ld('#stream-hsent-title a').each(function(){
			cur_panel = ld(this).attr('tag');
			//chj 2021/6/29 46609: （81mis.com/kfbcrm）客户管理-工作汇报，进入工作汇报界面后，直接点击发布微博，界面异常没有输入编辑框
			if(cur_panel == 'weibo'){
				cur_panel = 'sendWeibo';
			}
			return false;
		});
	}
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
	// setTimeout(function() {
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
					worktype = 'worktype_1';
					var saleskit_week_obj = ld('#saleskit_this_week,#saleskit_last_week,#saleskit_lastlast_week');
					var saleskit_month_obj = ld('#saleskit_this_month,#saleskit_last_month,#saleskit_lastlast_month');
					var kuohao_obj = ld('#kuohao_left,#kuohao_right');
					if(ld(this).attr('tag') == 'day'){//日志
						saleskit_week_obj.hide();
						saleskit_month_obj.hide();
						kuohao_obj.hide();
						worktype = 'worktype_1';
						sendlog_date = getNowDate();
						if(editDate == 'yes'){
							var onpickhtml = 'onpicked:function(dp){getSendLog_SalesKit(dp.cal.getNewDateStr())}';
							var onclick_html = 'onclick="WdatePicker({'+onpickhtml+'})"';
							if (minDate != '' && maxDate != ''){
								onclick_html = 'onclick="WdatePicker({startDate: \'%y-%M-%d\',minDate:\''+minDate+'\',maxDate:\''+maxDate+'\','+onpickhtml+' })"';
							}
							var saleskit_date_html = '<input  name="sendlog_saleskit_date" id="sendlog_saleskit_date"'+onclick_html+' class="ld-Wdate ld-input-inner" type="text" style="box-sizing: border-box;color:" size="15" maxlength="25" value="'+sendlog_date+'" autocomplete="off">'
							ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(saleskit_date_html);
						}else{
							if(!empty(current_date)){// 不允许变更日期时取服务器时间，周月同理
								sendlog_date = current_date;
							}
							ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
						}
						ld('#saleskit_select_day').show();
						ld('#saleskit_select_week').hide();
						ld('#saleskit_select_month').hide();
						ld('#saleskit_select_day').unbind('click').bind('click',function(){
							getSendLog_SalesKit_Info(ld('#sendlog_saleskit_date').val(),'day','');
						});
					}
					else if(ld(this).attr('tag') == 'week'){
						saleskit_month_obj.hide();
						ld('#saleskit_this_week').addClass('curr_data');
						ld('#saleskit_last_week,#saleskit_lastlast_week').removeClass('curr_data');
						kuohao_obj.show();
						worktype = 'worktype_2';
						var begin_date = getWeekStartDate();
						var end_date = getWeekEndDate();
						if(editDate == 'no'){//不允许修改日期
							if (!empty(weekStart) && !empty(weekEnd)){
								begin_date = weekStart;
								end_date = weekEnd;
							}
							saleskit_week_obj.hide();
						}else {//允许修改日期
							saleskit_week_obj.show();

						}
						sendlog_date = begin_date +' ~ '+end_date;
						ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
						ld('#saleskit_select_day').hide();
						ld('#saleskit_select_week').show();
						ld('#saleskit_select_month').hide();
						ld('#saleskit_select_week').unbind('click').bind('click',function(){
							getSendLog_SalesKit_Info(ld('#span_saleskit_date').text(),'week','');
						});
					}
					else if(ld(this).attr('tag') == 'month'){
						saleskit_week_obj.hide();
						ld('#saleskit_this_month').addClass('curr_data');
						ld('#saleskit_last_month,#saleskit_lastlast_month').removeClass('curr_data');
						kuohao_obj.show();
						worktype = 'worktype_3';
						var begin_date = getMonthStartDate();
						var end_date = getMonthEndDate();
						if (editDate == 'no'){
							if(!empty(MonthStart) && !empty(MonthEnd)){
								begin_date = MonthStart;
								end_date = MonthEnd;
							}
							saleskit_month_obj.hide();
						}else {
							saleskit_month_obj.show();
						}
						sendlog_date = begin_date +' ~ '+end_date;
						ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
						ld('#saleskit_select_day').hide();
						ld('#saleskit_select_week').hide();
						ld('#saleskit_select_month').show();
						ld('#saleskit_select_month').unbind('click').bind('click',function(){
							getSendLog_SalesKit_Info(ld('#span_saleskit_date').text(),'month','');
						});
					}
					ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type='+worktype+'] textarea').autosize();//监控输入内容的高度变化
					global_worktype=worktype;
				}
			});
			//工作汇报：工作协同
			getSendLog_SalesKit(sendlog_date);
			//监听变更内容事件 谷歌最新版启用了DOMNodeInserted
			// ld("#sendlog_saleskit_date").bind("DOMNodeInserted",function(e){
			// 	var this_value = ld(e.target).html();
			// 	getSendLog_SalesKit(this_value);
			// })
		}
	// }, 100);
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
//工作简报
function getSendLog_SalesKit(sendlog_date) {
	var url = "index.php?action=CooperativeWorkAjax&module=CooperativeWork&file=WorkReportIndex&method=getSendLog_SalesKit&option=list&sendlog_date=" + sendlog_date;
	var worktype='';
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
		worktype=popupobj.worktype;
	}else{
		var popupobjid = '';
		worktype=ld('#stream-hsent-title > li > a').filter('.curr').attr("tag");
	}
	ld('#rptContentLoading').show();

	url += '&worktype='+worktype;
	ldAjax(url, '', function (data) {
		ld.each(data.list,function (name,info) {
			ld(popupobjid+'[name=Salesbriefing]').find('[tag=create_span_'+name+']').text(info.nums);
			ld(popupobjid+'[name=Salesbriefing]').find('[tag=create_span_'+name+']').attr('data-tip',info.nums);
			ld(popupobjid+'[name=Salesbriefing]').find('[tag=create_span_'+name+']').attr('name',name);
			ld(popupobjid+'[name=Salesbriefing]').find('[tag=create_span_'+name+']').attr('module',info.module);
			if (info.istotalempty == 'no'){
				ld(popupobjid+'[name=Salesbriefing]').find('[tag=create_span_'+name+']').unbind('click').bind('click',function () {
					getSendLog_SalesKit_ChuantouInfo(ld(this),data.userid,'edit');
				});
			}
		});
		tooltip(popupobjid+'.tip-workbirefreport-list',{transition: true, time: 200});
		ld('#rptContentLoading').hide();
		if(data.auto_generate_brief == 'yes'){
			getSendLog_SalesKit_Info(sendlog_date,worktype,'yes');
		}
	});
}
function getSendLog_SalesKit_Info(sendlog_date,worktype,auto_param){
	//XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华）wsh
	auto_param = (!!auto_param) ? auto_param:'no';
	if (ld('#ReleaseBtn').attr('autogene_progress') == "start"){
		return false;
	}
	ld('#ReleaseBtn').attr('autogene_progress','start');
	// var popupobj=CrmPopup.getPopupObj("last");
	// var popupobjid = (popupobj != undefined && popupobj.divid != undefined)?"#"+popupobj.divid+' ':'';
	// var saleskit_showtype = ld(popupobjid+'#saleskit_showtype').val();
	var url = "index.php?action=CooperativeWorkAjax&module=CooperativeWork&file=WorkReportIndex&method=getSendLog_SalesKit&sendlog_date="+sendlog_date+'&option=text';
	ldAjax(url,'',function (data) {
		DelProgressObjs();
		showSalesKit(worktype,data.saleskit_showtype,data.list,auto_param);
	});
}

function createForwardPop(obj){
	var workreport = ld(obj).attr('workreport');
	// var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	// urlstring += '&method=createforwardPop&workreportid='+workreport;
	// ldAjaxHtml(urlstring,'',function (data){
		var html = ld('#forwardDiv').prop('outerHTML');
		var popupobj = CrmPopup.load(arrJsPopLabel['FORWARDING'],forwardReport,'','LdPopWidth600px','CooperativeWork','',arrJsPopLabel['FORWARDING'],'',arrJsPopLabel['CANCEL']);
		popupobj.show(html);
		popupobj.workreportid = workreport;
		var divobj = ld('#'+popupobj.divid);
		divobj.find('#forwardDiv').css('display','');
		popupobj.setPopBodyMaxHeight('#forwardDiv');
		popupobj.center();
		divobj.find('#forwardCCrange').off('click').on('click',function (event) {
			var selectUserid = [];//默认选中的用户id
			var selectNum = 0;
			ld('#forwardDiv .ui-popup-centent div[tag=forward] ul.reader-bar-list li').each(function(){
				selectUserid[selectUserid.length] = ld(this).attr('userid');
				selectNum++;
			});
			//选择抄送范围事件
			setEventSelectUser(popupobj.divid+' #forwardCCrange',selectNum,selectUserid.join(','));
		})
		DelProgressObjs();
	// })
}

function forwardReport(){
	var popupobj = CrmPopup.getPopupObj('last');
	var divobj = ld('#'+popupobj.divid);
	var reader_content = divobj.find('#forwardDiv textarea.input-text').val();
	if(empty(reader_content)){
		//alert('请填写内容。');
		flash_empty("sendTxtForward");
		return false;
	}
	var reader_score = divobj.find('#forwardDiv select.commenton-select').val();
	var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
	if(divobj.find('#forwardCCrange ul.reader-bar-list li').length > 0){
		divobj.find('#forwardCCrange ul.reader-bar-list li').each(function(){
			if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
				ccuser += ld(this).attr('userid')+',';
			}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
				ccgroup += ld(this).attr('groupid')+',';
			}
		});
	}

	if(empty(ccuser)){
		var confirm_str = '请选择抄送范围。';
		MessagePopup.TipTwo_warning(confirm_str);
		return false;
	}
	var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=savereader&savetype=saveforward';
	urlstring += '&reader_content='+encodeURIComponent(reader_content)+'&reader_score='+reader_score;
	urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup;
	urlstring += '&workreportid='+popupobj.workreportid;
	ldAjaxHtml(urlstring,'',function (rest) {
		popupobj.CancelEvent();
		refresh();//刷新页面
		DelProgressObjs();
	})
}

function createReaderPop(obj,type = ''){
	var workreport = ld(obj).parents(".mainuser").attr('workreportid');
	var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=createreaderPop&workreportid='+workreport;
	var divid = type === 'finish' ? 'cocmdDiv' : 'dialogDiv';
	var title = type === 'finish' ? arrJsPopLabel['PerformTasks'] : arrJsPopLabel['ReviewLog'];
	var oktext = type === 'finish' ? arrJsPopLabel['ReportResults'] : arrJsPopLabel['COMMENTAPP'];

	ldAjax(urlstring,'',function (dataobj) {
		var html = ld('#'+divid).prop('outerHTML');
		if (dataobj.workreporttype == 1) {
			title = arrJsPopLabel['ReviewLog'];
		} else if (dataobj.workreporttype == 2) {
			title = arrJsPopLabel['ReviewWeekPlan'];
		}if (dataobj.workreporttype == 3) {
			title = arrJsPopLabel['ReviewMonthPlan'];
		}
		var popupobj = CrmPopup.load(title,'','','LdPopWidth600px','CooperativeWork','',oktext,'',arrJsPopLabel['CANCEL']);
		popupobj.show(html);
		popupobj.workreportid = workreport;
		var divobj = ld('#'+popupobj.divid);
		divobj.find('#'+divid).css('display','');
		popupobj.setPopBodyMaxHeight('#'+divid);
		popupobj.center();
		divobj.find("#nameImage").attr('src',dataobj.userimage);
		divobj.find("#name").html(dataobj.username);
		divobj.find("#aj-ctime").html(dataobj.timeDescription);
		divobj.find("#comment-feedcontent").html(dataobj.experience);
		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
		{
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
		}
		var feedcontent_obj = divobj.find("#comment-feedcontent");
		if(type === 'finish'){
			divobj.find('#'+popupobj.divid+'_btnok').off('click').on('click',function(){
				var reader_content = divobj.find('#input-text').val();
				var reader_score = '';
				var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
				if(divobj.find('#cocmdDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').length > 0){
					divobj.find('#cocmdDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
						if(ld(this).attr('userid') !== undefined && ld(this).attr('userid') > 0){
							ccuser += ld(this).attr('userid')+',';
						}else if(ld(this).attr('groupid') !== undefined && ld(this).attr('groupid') > 0){
							ccgroup += ld(this).attr('groupid')+',';
						}
					});
				}
				var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
				urlstring += '&method=savereader&savetype=savefinish';
				urlstring += '&workreportid='+workreport;
				var params = {};
				params.reader_content = reader_content;
				params.reader_score = reader_score;
				params.ccuser = ccuser;
				params.ccgroup = ccgroup;
				console.log(params)
				ldAjaxHtml(urlstring,params,function (data) {
					alert(1);
					DelProgressObjs();
					popupobj.CancelEvent();
					refresh();//刷新页面
				})
			})
		}else {
			if (dataobj.workreporttype == 1) {
				divobj.find('#content_dis').html(arrJsPopLabel['JOURNAL']);
			} else if (dataobj.workreporttype == 2) {
				divobj.find('#content_dis').html(arrJsPopLabel['WEEKPLAN']);
			} else if (dataobj.workreporttype == 3) {
				divobj.find('#content_dis').html(arrJsPopLabel['MONTHPLAN']);
			}


			//显示日志内容
			if (dataobj.old_scfcolumnlabe) {
				feedcontent_obj.html('');
				for (var tmp_k = 0; tmp_k < dataobj.old_scfcolumnlabe.length; tmp_k++) {
					var columnname = dataobj.old_scfcolumnlabe[tmp_k].col;
					html = '<p class="work-tit" tag="' + columnname + '">' + dataobj.old_scfcolumnlabe[tmp_k].label + '</p>';
					if(columnname == 'worksummary'){
						var text = dataobj['summary'];
					}else if (columnname == 'workexperience'){
						var text = dataobj['experience'];
					}else {
						var text = dataobj[columnname];
					}
					html += '<p tag="'+columnname+'">' + text + "</p><br/>";
					feedcontent_obj.append(html);
				}
			}

			//抄送范围
			divobj.find('[tag=dialog]').off('click').on('click',function () {
				var selectUserid = [];//默认选中的用户id
				var selectNum = 0;
				divobj.find('#dialogDiv .ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
					selectUserid[selectUserid.length] = ld(this).attr('userid');
					selectNum++;
				});
				var userids = '';
				selectUserid+='';
				//41884: （https://61mis.com/kfbtest/ [^]）工作汇报，点击现在点评弹出层中，抄送范围选择成员后，再点击选择抄送范围按钮点不动

				if(ld.trim(selectUserid).length > 0){
					userids = selectUserid.split(',');
				}
				//选择抄送范围事件
				setEventSelectUser(popupobj.divid+' #dialogDiv div[tag=dialog]',selectNum,userids);
			})

			//var workreport = dataobj.workreport;
			divobj.find('#'+popupobj.divid+'_btnok').off('click').on('click',function(){
				var reader_content = divobj.find('#input-text').val();
				var reader_score = divobj.find('#commenton-select').val();
				var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
				if(divobj.find('#dialogDiv div[tag=dialog] ul.reader-bar-list li').length > 0){
					divobj.find('#dialogDiv div[tag=dialog] ul.reader-bar-list li').each(function(){
						if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
							ccuser += ld(this).attr('userid')+',';
						}else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
							ccgroup += ld(this).attr('groupid')+',';
						}
					});
				}

				var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
				urlstring += '&method=savereader&savetype=savecomment';
				urlstring += '&workreportid='+workreport+'';
				var params = {};
				params.reader_content = reader_content;
				params.reader_score = reader_score;
				params.ccuser = ccuser;
				params.ccgroup = ccgroup;
				ldAjaxHtml(urlstring,params,function (rest) {
					DelProgressObjs();
					popupobj.CancelEvent();
					refresh();//刷新页面
				});
			});

		}


		if (dataobj.entitytype != 'cocmd' && dataobj.scfcolumnlabe != null) {
			for (var tmp_k = 0; tmp_k < dataobj.scfcolumnlabe.length; tmp_k++) {
				feedcontent_obj.append('<p class="work-tit"  tag="del-comment-content-p">' + dataobj.scfcolumnlabe[tmp_k].label + '</p>');
				feedcontent_obj.find(".work-tit:last").after('<p tag="del-comment-content-p">' + dataobj.scfcolumnlabe[tmp_k].value + "</p>" + "<p>&nbsp;</p>");
			}
		}
		if(feedcontent_obj.find("p[tag=del-comment-content-p]").length > 0) {
			feedcontent_obj.find("p[tag=del-comment-content-p]").remove();
		}
	})
}

function showSalesKit(worktype,showtype,list,auto_param = 'no') {
	if (worktype == 'cocmd' || worktype == 'weibo' || worktype == undefined){
		return false;
	}
	ld('#ReleaseBtn').attr('autogene_progress','end')
	var popupobj=CrmPopup.getPopupObj("last");
	var popupobjid = (popupobj != undefined && popupobj.divid != undefined)?"#"+popupobj.divid+' ':'';
	var saleskit_con = ld(popupobjid+'[name=sendLog] [name=saleskit_'+worktype+']');
	ld(popupobjid+'#fieldset_saleskit_'+worktype).show();
	saleskit_con.val('');

	var nodeName = saleskit_con.prop('nodeName').toLowerCase();
	//简报生成格式
	var workreporttype = 'saleskit_'+worktype;
	//隐藏域赋值
	ld(popupobjid+'#saleskit_showtype').val(showtype);
	ld(popupobjid+'#saleskit_listinfo').val('');
	ld(popupobjid+'#saleskit_listinfo').val(JSON.stringify(list));
	if(showtype == 'html' && nodeName != 'div'){
		var saleskit_html = '<div name="'+saleskit_con.attr('name')+'" area="'+saleskit_con.attr('area')+'" style="height:50px;overflow-y:hidden;width: 100%;" is_mandatory="'+saleskit_con.attr('is_mandatory')+'" defaultvalue="'+saleskit_con.attr('defaultvalue')+'"></div>'
		saleskit_con.replaceWith(saleskit_html);
		saleskit_con = ld(popupobjid+'[name=sendLog] [name='+workreporttype+']');
	}else if(showtype == 'text' && nodeName != 'textarea'){
		var saleskit_html = '<textarea name="'+saleskit_con.attr('name')+'" area="'+saleskit_con.attr('area')+'" style="height:50px;overflow-y:hidden;width: 100%;" is_mandatory="'+saleskit_con.attr('is_mandatory')+'" defaultvalue="'+saleskit_con.attr('defaultvalue')+'"></textarea>'
		saleskit_con.replaceWith(saleskit_html);
		saleskit_con = ld(popupobjid+'[name=sendLog] [name='+workreporttype+']');
		saleskit_con.autosize();
	}

	if(list.length > 0){

		var content = getSalesKitContent(showtype,list);


		if (showtype == 'html'){
			saleskit_con.html('<p style="word-wrap: break-word;font-size: 14px">'+content+'</p>');
		}else {
			saleskit_con.val(content);
		}
		saleskit_con.each(function () {
			this.style.height = 'auto';
			this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
		}).on('input', function () {
			this.style.height = 'auto';
			this.style.height = (this.scrollHeight) + 'px';
		});
	}else{
		if (auto_param != 'yes'){
			MessagePopup.TipOne_warning(arrJsPopLabel['visiblerangsettings1']);
		}

	}

}

function getSalesKitContent(showtype,list) {
	var Linebreaks = showtype == 'html' ? '<br>' : '\n';
	var content = '';
	ld.each(list,function(index,info){
		content += info.label+':'+Linebreaks;
		ld.each(info.list,function (tmp_index,tmp_list) {
			var text = tmp_list.text;
			if(showtype == 'html'){
				var href = tmp_list.href;
				ld.each(href,function (tmp_key,hrefinfo) {
					var href_content = '<a href="javascript:;" onclick="saleSkitToListView(this)" module="'+hrefinfo.module+'" record="'+hrefinfo.record+'" style="color:#3487E2;text-decoration:none;">'+hrefinfo.label+'</a>';
					// var regex = new RegExp(hrefinfo.replace, "g");
					// text = text.replace(regex,href_content);
					text = text.replace(hrefinfo.replace,href_content);
				})
				text = text.replace(/\\\\n/g, Linebreaks);
			}
			content += text+Linebreaks;
		})
		if (showtype == 'html'){
			content += Linebreaks;
		}
		content += '\r';
	});
	return content;
}

function getSendLog_SalesKit_ChuantouInfo(obj,userid,type){
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
	if (type == 'edit'){
		var sendlog_date= ld(popupobjid+'[tag=saleskit_date]').text();
	}else {
		var sendlog_date= type;
	}
	var chuantou_name = ld(obj).attr('name');
	var chuantou_module = ld(obj).attr('module');
	getJsScript('include/js/modules/Home/HomeStuffChuantou.js', function () {
		var workBriefReportChuantou = new HomeStuffChuantou();
		global_home_approve=[];
		workBriefReportChuantou.surl='index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkBriefReport&mode=advance_value&userid='+userid;
		workBriefReportChuantou.initParam();
		workBriefReportChuantou.fromHome='yes';//wym 231220 BUG0077444 首页穿透要全屏，报表穿透不全屏，所以要用这个参数区分出首页和报表
		workBriefReportChuantou.unchangeParams = "&search_date_custom_value="+sendlog_date+'&chuantou_name='+chuantou_name+'&stufftype=workBriefReport&chuantou_module='+chuantou_module;
		workBriefReportChuantou.type='workBriefReport';
		workBriefReportChuantou.popupchuantou(workBriefReportChuantou.surl+workBriefReportChuantou.unchangeParams,workBriefReportChuantou.changeParams,'');
	});
}

function setReaderEvent(event,type = '') {
	//防止冒泡事件
	event.stopPropagation();
	event.preventDefault();
	if(type == 'cmd'){
		var reuserid = ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list').find('[emptype=p]').attr('userid');
		var tag = 'cmduser';
	}else {
		var reuserid = ld('[name=reuserid]').val();
		var tag = 'reader';
	}
	var module = 'CooperativeWork';
	var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module=CooperativeWork&popup_inputtype=radio&popup_selecttype=user&checkprivilege=no';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
	{
		scopepopupobj =  new ScopePopupObj(module);
		if(type == 'cmd'){
			scopepopupobj.popup_caption_value = '选择执行人';//标题title
		}else{
			scopepopupobj.popup_caption_value = '选择点评人';//标题title
		}
		scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
		scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容

		cls_ScopePopup.popup_selecttype = 'user';
		cls_ScopePopup.prop.popup_module = module;//模块
		cls_ScopePopup.prop.popup_url = popup_user_url;
		cls_ScopePopup.prop.popup_value = reuserid;
		var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

		scopepopupobj.setEventBtnOk=function(){
			ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function() {
				var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
				var selected_name = cls_ScopePopup.return_obj.return_name;
				ld('[name=reuserid]').val(selected_user)
				ld('[name=reusername]').val(selected_name)
				//清空ul下面的li标签
				ld('#sendLogFoot > div[tag='+tag+'] ul.reader-bar-list li').remove();
				//添加新的li
				ld('#sendLogFoot > div[tag='+tag+'] ul.reader-bar-list').append('<li userid="'+selected_user+'" emptype="p"><span class="item-name">'+selected_name+'</span><span class="remove-h">×</span></li>');
				//绑定删除事件
				ld('#sendLogFoot > div[tag='+tag+'] ul.reader-bar-list .remove-h').unbind('click').click(function(){
					ld('#sendLogFoot > div[tag='+tag+'] ul.reader-bar-list li[userid='+selected_user+']').remove();
				});
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)
					cls_wxOpenDataobj.bindAllOpenData();
				}
				msgConfirm();
			});

		};
	});
}
/**
 * 绑定工作协同节点事件（页面加载初始化）
 * @author Tujt 2015-01-30
 */
function initWordReport(){
	if (ld('#stream-hsent-title') == undefined || ld('#stream-hsent-title').length <= 0) {
		return false;
	}
	var popupobj=CrmPopup.getPopupObj("last");
	var titlewidtth = parseInt(ld('#stream-hsent-title > li > a:first-child').offset().left)-parseInt(ld(".menuUl").offset().left)+parseInt(25);
	ld('.trigger_bg').css('left',titlewidtth+'px');//移动上角图标
	ld('.trigger_bg span').removeClass('ui-hide');
	cur_panel=ld('#stream-hsent-title > li > a:first-child').attr("cont");
	if(empty(cur_panel)){
		cur_panel = ld('#'+popupobj.divid+' #stream-hsent-title > li > a:first-child').attr("cont");
	}

	ld('.Showselect').css('display','none');
	ld("#stream").smartFloat();
//本周
	ld('#saleskit_this_week').click(function(){
		ld('#saleskit_this_week').addClass('curr_data');
		ld('#saleskit_last_week,#saleskit_lastlast_week').removeClass('curr_data');
		var begin_date = getWeekStartDate();
		var end_date = getWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上周
	ld('#saleskit_last_week').click(function(){
		ld('#saleskit_last_week').addClass('curr_data');
		ld('#saleskit_this_week,#saleskit_lastlast_week').removeClass('curr_data');
		var begin_date = getLastWeekStartDate();
		var end_date = getLastWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上上周
	ld('#saleskit_lastlast_week').click(function(){
		ld('#saleskit_lastlast_week').addClass('curr_data');
		ld('#saleskit_this_week,#saleskit_last_week').removeClass('curr_data');
		var begin_date = getLastLastWeekStartDate();
		var end_date = getLastLastWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//本月
	ld('#saleskit_this_month').click(function(){
		ld('#saleskit_this_month').addClass('curr_data');
		ld('#saleskit_last_month,#saleskit_lastlast_month').removeClass('curr_data');
		var begin_date = getMonthStartDate();
		var end_date = getMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上月
	ld('#saleskit_last_month').click(function(){
		ld('#saleskit_last_month').addClass('curr_data');
		ld('#saleskit_this_month,#saleskit_lastlast_month').removeClass('curr_data');
		var begin_date = getLastMonthStartDate();
		var end_date = getLastMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld('#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上上月
	ld('#saleskit_lastlast_month').click(function(){
		ld('#saleskit_lastlast_month').addClass('curr_data');
		ld('#saleskit_this_month,#saleskit_last_month').removeClass('curr_data');
		var begin_date = getLastLastMonthStartDate();
		var end_date = getLastLastMonthEndDate();
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
		cur_panel_tag = ld(this).attr('tag');//获取当前
		var cur_releasetext = arrJsPopLabel["RELEASENEW"];
		var languageType = ld('#languageType').val();
		if(languageType == 'en'){
			cur_releasetext += ' ';
		}
		if(cur_panel_tag == 'weibo'){
			cur_releasetext += arrJsPopLabel["BLOG"];
		}
		else if(cur_panel_tag == 'day'){
			cur_releasetext += arrJsPopLabel["JOURNAL"];
		}
		else if(cur_panel_tag == 'week'){
			cur_releasetext += arrJsPopLabel["WEEKPLAN"];
		}
		else if(cur_panel_tag == 'month'){
			cur_releasetext += arrJsPopLabel["MONTHPLAN"];
		}
		else if(cur_panel_tag == 'cocmd'){
			cur_releasetext += arrJsPopLabel["TASK"];
		}
		cur_releasetext += '...';
		ld('#cur_releasetext').val(cur_releasetext);
		ld('.trigger_bg').css('left',titlewidtth+'px');//移动上角图标
		//ld('#'+cur_panel).css('display','');
		getSendLogCcrange(cur_panel,cur_panel_tag);
		getWorkReportTextarea();
		if(cur_panel=='sendLog')
		{
			ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type]').addClass('ui-hide');
			var type = typeobj[ld(this).attr('tag')];
			if(type == 2){
				ld('#saleskit_this_week').click();
			}else if(type == 3){
				ld('#saleskit_this_month').click();
			}
			ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+']').removeClass('ui-hide');
			//0032248: 工作协同：从微博切换到日志等模块的时候，光标应该定在第一个输入框当中。
			var first_textareaobj = ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+'] fieldset:first').find('textarea');
			first_textareaobj.focus();
			texttag = first_textareaobj;
			//切换日周月小图标字样
			//ld('.endmenu > ul > li').attr('class','');
			//ld(this).attr('class','linebg');

			// ljj 20231117 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
			getRelatedWorkContent(type);

		}else {
			var first_textareaobj = ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_1] fieldset:first').find('textarea');
			first_textareaobj.focus();
			texttag = first_textareaobj;
		}

		// ljj 20231011 BUG0073746 工作汇报编写的时候，当输入框中有值时才应该显示“复制”图标按钮,鼠标为该范围时出现复制
		var editfieldset=ld("#sendLog").find('[name="editfieldset"]');
		ld(editfieldset).each(function(){
			ld(this).unbind('mouseout').bind('mouseout',function () {
				ld(this).find('[name=workreporteditcopy]').css('display','none');
			});
			ld(this).unbind('mouseover').bind('mouseover',function () {
				var textarea=ld(this).find('[area=edittextarea]');
				if (!empty(ld(textarea).val())){
					ld(this).find('[name=workreporteditcopy]').css('display','block');
				}
				ld(textarea).bind('input',function (){
					if (!empty(ld(this).val())){
						if (ld(this).parent().find('[name=workreporteditcopy]').css('display') == 'none'){
							ld(this).parent().find('[name=workreporteditcopy]').css('display','block');
						}
					}else{
						ld(this).parent().find('[name=workreporteditcopy]').css('display','none');
					}
				});
			});
		});
		/*  if(document.getElementById('raccount_id')!=null&&document.getElementById('raccount_id')!=undefined&&document.getElementById('raccount_id').value>0 && ld("#dtlview_accountname").html() != undefined)

               {
                   setAccountInfo(document.getElementById('raccount_id').value,ld("#dtlview_accountname").html());

               }
          else if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='')
          {

              setContactInfo(document.getElementById('rcontact_id').value,ld("#dtlview_lastname").html());

          }*/
		cos_webuploader++;
		setUpload();
	});
	// 点击弹出编辑窗口
	ld('.form-thumb').click(function(){
		ld('#selectbox_datebox').hide();
		setPanelShow();
		getWorkReportTextarea();
		var cur_panel = ld('#stream-hsent-title > li > a:first-child').attr("cont");
		if('sendLog' == cur_panel)
		{
			ld('#stream-hsent-title [class=curr]').click();
		}
		cos_webuploader++;
		setUpload();
		// ljj 20231117 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
		if (cur_panel_tag == 'weibo' || cur_panel_tag == 'cocmd'){
			var type = 1;
			var entitytype = cur_panel_tag == 'weibo'?'sendWeibo':'cocmd';
		}else if (cur_panel_tag == 'day' || cur_panel_tag == 'week' || cur_panel_tag == 'month'){
			var type = typeobj[cur_panel_tag];
			var entitytype = 'sendLog';
		}
		var first_textareaobj = ld('#sendLog div[tag=workfield] div[entitytype='+entitytype+'] div[type=worktype_'+type+'] fieldset:first').find('textarea');
		first_textareaobj.focus();
		texttag = first_textareaobj;
		if (entitytype == 'sendLog'){
			getRelatedWorkContent(type);
		}
	});
	//暂存设置
	ld('textarea').bind('input propertychange', function(){
		if(cur_panel_tag == ''){
			cur_panel_tag = ld('#cur_panel_tag').val();
		}
		var current_userid = ld('#current_userid').val();
		var storage_name = ld(this).attr('name');
		var storage_value = ld(this).val();
		var key = cur_panel_tag+'_'+current_userid+'_'+storage_name;
		localStorage.setItem(key, storage_value);
	});
	//X图标关闭编辑框点击事件
	ld('.panel-visible-h').click(function(){
		ld('#sendLog').addClass('ui-hide');
		ld('.form-thumb').removeClass('ui-hide');
		ld('.panel-visible-h,.pub_btn').css('display','none');
		ld('div.pubclear div.input-empty-text').html(ld('#cur_releasetext').val());
	});
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
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
					{
						//通讯录(pc端企业微信)
						cls_wxOpenDataobj.bindAllOpenData();
					}
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
			ld('#searchColleagueText').attr('placeholder',arrJsPopLabel['searchforcolleagues']);
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
			ld( '#sendemojicookieDiv .ui-popup-centent a').unbind('click').click(function(){
				ld(texttag).val(

					ld(texttag).val() +'['+ld(this).attr('data-name')+']'
				);
			});
		});
	});
	//关联客户
	ld( '#sendLog .btns .addcustomer').click(function(event){
		//window.open("index.php?module=Accounts&action=Popup&popuptype=specific_account_address_pop&form=TasksEditView&form_submit=false&fromlink=&fromModule=Contacts&related=1","testHomeContacts","width=840,height=602,resizable=1,scrollbars=1");

		var surl = "module=Accounts&action=Popup&popuptype=specific_account_address_pop&form=TasksEditView&form_submit=false&fromlink=&fromModule=Contacts&related=1&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Accounts');

	});
	//关联联系人
	ld( '#sendLog .btns .addcontact').click(function(event){
		//window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific_contact_address_pop&fromModule=ContactRecords&form=EditView","testHomeContacts","width=840,height=602,resizable=1,scrollbars=1");
		var surl = "module=Contacts&action=Popup&html=Popup_picker&popuptype=specific_contact_address_pop&fromModule=CooperativeWork&form=EditView&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Contacts');
	});
	//关联产品
	ld( '#sendLog .btns .addproducts').click(function(event){
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
	ld('#sendLogFoot > div[tag=cmduser] ul.reader-bar-list .remove-h').unbind('click').click(function(){
		ld(this).parent().remove();
		return false;
	});
	//点评人事件绑定 input.input-field
	ld('#sendLogFoot > div[tag=reader] div.selectbar *').unbind('click').bind('click',function(event){
		setReaderEvent(event);
	});
	//editor:gyqX160717 reason：点评人初始绑定  date:2016 07 17  Bug:0022891: 工作协同：发布日志，点击默认的点评人右方的【×】按钮，弹出选择层
	ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list .remove-h').unbind('click').click(function(){
		ld(this).parent().remove();
		return false;
	});
	//点评人 input文本框，光标移除 ，显示选择点评人字样
	ld('#sendLogFoot > div[tag=reader] input.input-field').blur(function(){
		ld('#sendLogFoot > div[tag=reader] input.input-field').removeClass('ui-show');
		ld('#sendLogFoot > div[tag=reader] input.input-field').addClass('ui-hide');
		ld('#sendLogFoot > div[tag=reader] .input-tip').css('display','');
	});
	//执行人事件绑定 input.input-field
	ld('#sendLogFoot > div[tag=cmduser] div.selectbar *').click(function(event){
		setReaderEvent(event,'cmd');
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
			var selectDisableUserid = [];//默认选中的用户id
			var selectNum = 0;
			ld('#sendLogFoot > div[tag=ccrange] ul.reader-bar-list li').each(function(){
				var disable_status =  ld(this).attr('disabled');
				var userid = ld(this).attr('userid');
				selectUserid[selectUserid.length] = userid;
				if (disable_status == 'disabled'){
					selectDisableUserid[selectDisableUserid.length] = userid;
				}
				selectNum++;
			});

			//选择抄送范围事件
			setEventSelectUser('sendLogFoot > div[tag=ccrange]',selectNum,selectUserid.join(','),selectDisableUserid.join(','));
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
		if (ld('#ReleaseBtn').attr('autogene_progress') == 'start'){
			var confirm_str = arrJsPopLabel['pleaseWaitToPublishTips'];//提示内容
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		if(1 != issubmitlog) return false;
		var savetype = 1;
		var popupobj=CrmPopup.getPopupObj("last");
		if(empty(cur_panel)){
			cur_panel = ld('#'+popupobj.divid+' #stream-hsent-title > li > a:first-child').attr("cont");
		}

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
				//flash_empty("sendTxt");//提示用户
				let notice_msg = arrJsPopLabel['CONTENTCANOTEMPTY'];
				if(cur_panel !='sendWeibo' && cur_panel !='cocmd'){
					var fieldTitle = ld(this).parent().find('label').text();
					notice_msg = fieldTitle+"不能为空！";
				}
				audioRemindsMsg("","","CooperativeWork","","",notice_msg);
				ld(this).focus();//光标移入
				return mandatory_bool = false;
			}
		});
		if(!mandatory_bool) return false;//未填写


		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=saveSendLog';

		var entitytype = '';
		var saleskit_date = '';
		var showtype = '';
		var listinfo = '';

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
						saleskit_date = ld('#sendlog_saleskit_date').val();
					}else{
						saleskit_date = ld('#span_saleskit_date').html();
					}
					//日志日期不能大于当前日期
					var now_date = getNowDate();
					if(saleskit_date > now_date){
						var confirm_str = arrJsPopLabel['thelogdatecannotbegreater'];//提示内容
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
					}

				}else{
					saleskit_date = ld('#span_saleskit_date').html();
				}
				showtype = ld('#saleskit_showtype').val();
				listinfo = ld('#saleskit_listinfo').val();

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
						var confirm_str = '完成时间不能早于当前时间。';
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
				MessagePopup.TipZero_warning(arrJsPopLabel['SELECTREVIEWER']);
				ld('#sendLogFoot > div[tag=reader] div.selectbar *').click();
				// ld('#sendLogsmownerDiv').css('display','');
				return false;
			}
		}
		var header='';
		if(document.getElementById('header') != undefined){
			header = document.getElementById('header').value;
		}
		var popupobj=CrmPopup.getPopupObj("last");
		var relatedmodulerecordid="";

		if(popupobj!=undefined && popupobj.divid!=undefined&&popupobj.type=='workreport')
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

		var params = {};
		params.saleskit_listinfo = listinfo;
		params.saleskit_showtype = showtype;
		//组装对应的字段和值
		var content_str = '';
		var workfldfilter = '';var workfldstring = '';
		ld(sendLogObj).find('textarea').each(function(){
			var tmp_content = ld(this).val();
			content_str += tmp_content;
			params[ld(this).attr('name')] = tmp_content;
			workfldstring += ld(this).attr('name') +',';
		});
		params.workfld = workfldstring;

		//at 用户、部门
		var atuser = ld('[name=sendLog] [name=sendLog_at_user]').val();
		var atgroup = ld('[name=sendLog] [name=sendLog_at_group]').val();

		var tmp_userColleagueArray = userColleagueArray;
		var atuser_arr = atuser.split(',');
		if (atuser_arr.length >0 && tmp_userColleagueArray.length > 0){
			var atuserinfo = {};
			var new_atuser_arr = [];
			ld.each(tmp_userColleagueArray,function (tmp_key,tmp_info) {
				var tmp_userid = tmp_info.userid;
				var tmp_lastname = tmp_info.lastname;
				atuserinfo[tmp_userid] = '@'+tmp_lastname+' ';
			});
			ld.each(atuser_arr,function (tmp_key,tmp_userid) {
				if (content_str.indexOf(atuserinfo[tmp_userid]) > -1){
					new_atuser_arr.push(tmp_userid);
				}
			});
			atuser = new_atuser_arr.join(',');
		}

		urlstring += '&entitytype='+entitytype+'&savetype='+savetype+'';
		urlstring += '&accountlist='+accountlist+'&contactlist='+contactlist+'&productslist='+productslist;
		urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup;
		urlstring += '&atuser='+atuser+'&atgroup='+atgroup;
		urlstring += '&uploadimgList='+uploadimgList;
		urlstring += '&uploadattList='+uploadattList;
		urlstring += '&saleskit_date='+saleskit_date;
		//alert(urlstring);

		issubmitlog = 2;
		//alert(urlstring);
		//return false;
		ldAjaxHtmlNoProgress("index.php?"+urlstring+workfldfilter,params,function(rest){
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
			//清空生成的工作简报
			ld('#fieldset_saleskit_day').hide();
			ld('#fieldset_saleskit_week').hide();
			ld('#fieldset_saleskit_month').hide();

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
			ld('#saleskit_showtype').val('');
			ld('#saleskit_listinfo').val('');
			//循环删除对应缓存
			ld(sendLogObj).find('textarea').each(function() {
				var current_userid = ld('#current_userid').val();
				var storage_name = ld(this).attr('name');
				var key = cur_panel_tag+'_'+current_userid+'_'+storage_name;
				localStorage.removeItem(key);
			});

			if (cur_panel_tag && (cur_panel_tag == 'day' || cur_panel_tag == 'week' || cur_panel_tag == 'month')){
				var saleskit_con = ld('[name=sendLog] [name=saleskit_'+cur_panel_tag+']');
				var saleskit_html = '<textarea name="'+saleskit_con.attr('name')+'" area="'+saleskit_con.attr('area')+'" style="height:50px;overflow-y:hidden;width: 100%;" is_mandatory="'+saleskit_con.attr('is_mandatory')+'" defaultvalue="'+saleskit_con.attr('defaultvalue')+'"></textarea>'
				saleskit_con.replaceWith(saleskit_html);
				saleskit_con.autosize();
				ld('#saleskit_showtype').val('text');
				ld('#saleskit_listinfo').val('');
			}


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
			DelProgressObjs();
			refresh();
		});

	});

	//点评弹出层
	ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').blur(function(){
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').removeClass('ui-show');
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').addClass('ui-hide');
		ld('#dialogDiv .ui-popup-centent div[tag=dialog] .input-tip').css('display','');
	});
	//转发选择用户
	// ld('#forwardDiv .ui-popup-centent div[tag=forward]').click(function(event){
	// 	var e = event || window.event;
	// 	var obj = e.srcElement||e.target;
	// 	//转发 - 选择抄送范围时，不隐藏其他弹出层
	// 	pop_num = 1;
	// 	obj = ld('#forwardDiv .ui-popup-centent div[tag=forward] .show-select-panel').get(0);
	// 	if('remove-h' == ld(obj).attr('class')){
	// 		return false;
	// 	}
	// 	ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').removeClass('ui-hide');
	// 	ld('#forwardDiv .ui-popup-centent div[tag=forward] input.input-field').addClass('ui-show');
	// 	if('show-select-panel' != ld(obj).attr('class')){
	// 		ld(obj).click();
	// 	}else{
	// 		var selectUserid = [];//默认选中的用户id
	// 		var selectNum = 0;
	// 		ld('#forwardDiv .ui-popup-centent div[tag=forward] ul.reader-bar-list li').each(function(){
	// 			selectUserid[selectUserid.length] = ld(this).attr('userid');
	// 			selectNum++;
	// 		});
	// 		//选择抄送范围事件
	// 		setEventSelectUser('forwardDiv .ui-popup-centent div[tag=forward]',selectNum,selectUserid.join(','));
	// 	}
	// });
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


	var editcopy=ld("#sendLog").find('[name=workreporteditcopy]');
	//绑定编辑界面复制事件
	ld(editcopy).unbind('click').bind('click',function () {
		// 赋值复制内容
		var edittextarea=ld(this).parent().find('[area=edittextarea]');
		var copycontent = ld(edittextarea).val();
		if (empty(copycontent)){
			MessagePopup.TipZero_warning(arrJsPopLabel['NOCONTENTTOCOPY']);
		}
		else{
			var copy_content = document.createElement("textarea");
			copy_content.value=copycontent;
			document.body.appendChild(copy_content);
			copy_content.select();
			// 执行复制
			document.execCommand("copy");
			document.body.removeChild(copy_content);
			DelProgressObjs();
			MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED']);
		}
	});

}


function initEditReport(){
	var crmPopupobj=CrmPopup.getPopupObj("last");
	//绑定删除点击事件
	var tag = 'sendLog';
	var popupobjid = "#"+crmPopupobj.divid+' ';
    // var deploy_value = ld(popupobjid+'#deploy_value').val();
	var entitytype = ld(popupobjid+'#entitytype').val();
    var type = ld(popupobjid+'#type').val();
    var sendlog_workdate = ld(popupobjid+'#sendlog_workdate').val();
    var textedit = ld(popupobjid+'#textedit').val();

	ld(popupobjid+' #sendLog div[tag=workfield]  div[type=worktype] textarea').autosize();

	if(textedit != 'noedit'){
		var first_textareaobj = ld(popupobjid+'#sendLog div[tag=workfield] div[type=worktype] fieldset:first').find('textarea');
		first_textareaobj.focus();
	}

	if(entitytype == 'workreport'){
		if(type == 1 ){
			ld('#kuohao_left,#kuohao_right').hide();
			var onpickhtml = 'onpicked:function(dp){getSendLog_SalesKit(dp.cal.getNewDateStr());}';
			var onclick_html = 'onclick="WdatePicker({'+onpickhtml+'})"';
			if (crmPopupobj.report_date != 'all'){
				onclick_html = 'onclick="WdatePicker({startDate: \'%y-%M-%d\',minDate:\''+crmPopupobj.minDate+'\',maxDate:\''+crmPopupobj.maxDate+'\','+onpickhtml+'})"';
			}
			var saleskit_date_html = '<input  name="sendlog_saleskit_date" id="sendlog_saleskit_date"'+onclick_html+' class="ld-Wdate ld-input-inner" type="text" style="box-sizing: border-box;color:" size="15" maxlength="25" value="'+sendlog_workdate+'" autocomplete="off">'
			//var saleskit_date_html = '<a type="text" style="width:110px;height:25px;line-height:25px;" size="15" name="sendlog_saleskit_date" id="sendlog_saleskit_date" onclick="WdatePicker({startDate: \'%y-%M-%d\',minDate:\''+crmPopupobj.minDate+'\',maxDate:\''+crmPopupobj.maxDate+'\','+onpickhtml+'})">'+sendlog_workdate+'</a>';
			ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(saleskit_date_html);
			crmPopupobj.worktype = 'day';
			var saleskit_showtype = ld(popupobjid+'#saleskit_showtype').val();
			ld(popupobjid+'#saleskit_select_day').click(function(){
				getSendLog_SalesKit_Info(ld(popupobjid+'#sendlog_saleskit_date').val(),'day','');
			});
		}else if(type == 2){
			crmPopupobj.worktype = 'week';
			ld(popupobjid+'#saleskit_select_week').click(function(){
				getSendLog_SalesKit_Info(ld(popupobjid+'#span_saleskit_date').text(),'week','');
			});
		}else if(type == 3){
			crmPopupobj.worktype = 'month';
			ld(popupobjid+'#saleskit_select_month').click(function(){
				getSendLog_SalesKit_Info(ld(popupobjid+'#span_saleskit_date').text(),'month','');
			});
		}
	}

	getSendLog_SalesKit(sendlog_workdate);
	//监听变更内容事件 谷歌最新版启用了DOMNodeInserted
	// ld(popupobjid+"#sendlog_saleskit_date").bind("DOMNodeInserted",function(e){
	// 	var this_value = ld(e.target).html();
	// 	getSendLog_SalesKit(this_value);
	// })

	//当周
	ld(popupobjid+'#saleskit_week').click(function(){
		ld(this).addClass('curr_data');
		ld(popupobjid+'#saleskit_this_week,#saleskit_last_week,#saleskit_lastlast_week').removeClass('curr_data');
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_workdate);
		getSendLog_SalesKit(sendlog_workdate);
	});
	//本周
	ld(popupobjid+'#saleskit_this_week').click(function(){
		ld(popupobjid+'#saleskit_this_week').addClass('curr_data');
		ld(popupobjid+'#saleskit_week,#saleskit_last_week,#saleskit_lastlast_week').removeClass('curr_data');
		var begin_date = getWeekStartDate();
		var end_date = getWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上周
	ld(popupobjid+'#saleskit_last_week').click(function(){
		ld(popupobjid+'#saleskit_last_week').addClass('curr_data');
		ld(popupobjid+'#saleskit_week,#saleskit_this_week,#saleskit_lastlast_week').removeClass('curr_data');
		var begin_date = getLastWeekStartDate();
		var end_date = getLastWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上上周
	ld(popupobjid+'#saleskit_lastlast_week').click(function(){
		ld(popupobjid+'#saleskit_lastlast_week').addClass('curr_data');
		ld(popupobjid+'#saleskit_week,#saleskit_this_week,#saleskit_last_week').removeClass('curr_data');
		var begin_date = getLastLastWeekStartDate();
		var end_date = getLastLastWeekEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
    //当月
	ld(popupobjid+'#saleskit_month').click(function(){
		ld(this).addClass('curr_data');
		ld(popupobjid+'#saleskit_this_month,#saleskit_last_month,#saleskit_lastlast_month').removeClass('curr_data');
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_workdate);
		getSendLog_SalesKit(sendlog_workdate);
	});
	//本月
	ld(popupobjid+'#saleskit_this_month').click(function(){
		ld(popupobjid+'#saleskit_this_month').addClass('curr_data');
		ld(popupobjid+'#saleskit_month,#saleskit_last_month,#saleskit_lastlast_month').removeClass('curr_data');
		var begin_date = getMonthStartDate();
		var end_date = getMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上月
	ld(popupobjid+'#saleskit_last_month').click(function(){
		ld(popupobjid+'#saleskit_last_month').addClass('curr_data');
		ld(popupobjid+'#saleskit_month,#saleskit_this_month,#saleskit_lastlast_month').removeClass('curr_data');
		var begin_date = getLastMonthStartDate();
		var end_date = getLastMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});
	//上上月
	ld(popupobjid+'#saleskit_lastlast_month').click(function(){
		ld(popupobjid+'#saleskit_lastlast_month').addClass('curr_data');
		ld(popupobjid+'#saleskit_month,#saleskit_this_month,#saleskit_last_month').removeClass('curr_data');
		var begin_date = getLastLastMonthStartDate();
		var end_date = getLastLastMonthEndDate();
		sendlog_date = begin_date +' ~ '+end_date;
		ld(popupobjid+'#sendLog div[tag=workfield] span[tag=saleskit_date]').html(sendlog_date);
		getSendLog_SalesKit(sendlog_date);
	});

	//绑定图片删除事件
	ld(popupobjid+'#'+tag+'UploadImg ul li').find('[tag=img_delete]').off('click').on('click',function(){
		var record = ld(this).data('record');
		ld(popupobjid+'#'+tag+'UploadImg ul li[record='+record+']').remove();
		if(ld(popupobjid+'#'+tag+'UploadImg ul li').length == 0){
			ld(popupobjid+'#'+tag+'UploadImg').css('display','none');
		}
	});

	//绑定附件删除事件
	ld(popupobjid+'#'+tag+'UploadAtt ul li').find('[tag=att_delete]').off('click').on('click',function(){
		var record = ld(this).data('record');
		ld(popupobjid+'#'+tag+'UploadAtt ul li[record='+record+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'UploadAtt ul li').length){
			ld(popupobjid+'#'+tag+'UploadAtt').css('display','none');
		}
	});

	ld(popupobjid+'#'+tag+'Acctlist ul .remove-h').unbind('click').click(function(){
		var accountid = ld(this).parent().attr('accountid');
		ld(popupobjid+'#'+tag+'Acctlist ul li[accountid='+accountid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Acctlist ul li').length){
			ld(popupobjid+'#'+tag+'Acctlist').css('display','none');
		}
	});
	ld(popupobjid+'#'+tag+'Contlist ul .remove-h').unbind('click').click(function(){
		var contactid = ld(this).parent().attr('contactid');
		ld(popupobjid+'#'+tag+'Contlist ul li[contactid='+contactid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Contlist ul li').length){
			ld(popupobjid+'#'+tag+'Contlist').css('display','none');
		}
	});
	ld(popupobjid+'#'+tag+'Prolist ul .remove-h').unbind('click').click(function(){
		var productid = ld(this).parent().attr('productid');
		ld(popupobjid+'#'+tag+'Prolist ul li[productid='+productid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Prolist ul li').length){
			ld(popupobjid+'#'+tag+'Prolist').css('display','none');
		}
	});
	ld(popupobjid+'#sendLog .btns .addcustomer').click(function(event){
		var surl = "module=Accounts&action=Popup&popuptype=specific_account_address_pop&form=TasksEditView&form_submit=false&fromlink=&fromModule=Contacts&related=1&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Accounts');

	});
	//关联联系人
	ld(popupobjid+'#sendLog .btns .addcontact').click(function(event){
		var surl = "module=Contacts&action=Popup&html=Popup_picker&popuptype=specific_contact_address_pop&fromModule=CooperativeWork&form=EditView&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Contacts');
	});
	//关联产品
	ld(popupobjid+'#sendLog .btns .addproducts').click(function(event){
		var surl = "module=Products&action=Popup&html=Popup_picker&popuptype=specific&fromModule=CooperativeWork&form=EditView&popup=yes&page_popup=yes";
		CrmPopupWindow('CooperativeWork',surl,'Products');
	});
	// ljj 20231011 BUG0073746 工作汇报编写的时候，当输入框中有值时才应该显示“复制”图标按钮,鼠标为该范围时出现复制
	var editfieldset=ld(popupobjid+"#sendLog").find('[name="editfieldset"]');
	ld(editfieldset).each(function(){
		ld(this).unbind('mouseout').bind('mouseout',function () {
			ld(this).find('[name=workreporteditcopy]').css('display','none');
		});
		ld(this).unbind('mouseover').bind('mouseover',function () {
			var textarea=ld(this).find('[area=edittextarea]');
			if (!empty(ld(textarea).val())){
				ld(this).find('[name=workreporteditcopy]').css('display','block');
			}
			ld(textarea).on('input',function (){
				if (!empty(ld(this).val())){
					if (ld(this).parent().find('[name=workreporteditcopy]').css('display') == 'none'){
						ld(this).parent().find('[name=workreporteditcopy]').css('display','block');
					}
				}else{
					ld(this).parent().find('[name=workreporteditcopy]').css('display','none');
				}
			});
		});
	});
	var editcopy=ld(popupobjid+"#sendLog").find('[name=workreporteditcopy]');
	//绑定编辑界面复制事件
	ld(editcopy).unbind('click').bind('click',function () {
		// 赋值复制内容
		var edittextarea=ld(this).parent().find('[area=edittextarea]');
		var copycontent = ld(edittextarea).val();
		if (empty(copycontent)){
			MessagePopup.TipZero_warning(arrJsPopLabel['NOCONTENTTOCOPY']);
		}
		else{
			var copy_content = document.createElement("textarea");
			copy_content.value=copycontent;
			document.body.appendChild(copy_content);
			copy_content.select();
			// 执行复制
			document.execCommand("copy");
			document.body.removeChild(copy_content);
			DelProgressObjs();
			MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED']);
		}
	});
	cos_webuploader++;
	setUpload();
}
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
		if(bigcategory == '5'){
			bigcategory = '1';
			smallcategory = ld(this).parent().attr('tag');
		}else{
			smallcategory = 'all';
		}
		ld('.ConSwitch ul li a').each(function(){
			if(bigcategory == ld(this).attr('tag')){
				ld(this).attr('class','curr');
			}else{
				ld(this).attr('class','');
			}
		});
		fun_search('ConSwitchMenu');
	});
	ld('.ConSwitch ul li a[tag=10]').click();	//默认我相关的
	ld('.main_grid_box').scroll(function () {
		if (ld('.wrapper-panel-inner .main_grid_box').scrollTop() + ld(window).height() >= ld('.Cbox_C').height()) {
			WorkReportNextPage();//下一页
		}
	});
	//筛选显示隐藏
	ld('#advSearch_div').on('click',function(){
		var _display = ld('.filter-conten').css('display');
		if(_display == 'none'){
			ld('#search_arrow_down').hide();
			ld('#search_arrow_up').show();
			ld('.filter-conten').show();
		}else{
			ld('#search_arrow_down').show();
			ld('#search_arrow_up').hide();
			ld('.filter-conten').hide();
		}
	});
	//筛选 -- 时间范围
	ld('.w-filter-select .value').unbind("click").on('click',function(){
		selectDateChoice(ld(this));
	})
	ld(".w-filter-select .value").click(function(e) {
		e?e.stopPropagation():event.cancelBubble = true;
	});
	ld(document).click(function() {
		ld("#selectbox_datebox").fadeOut();
	});
	//筛选 -- 发起人
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
	//筛选 -- 关键字查询 - 按钮
	ld('.w-filter-wrapper .btn-search').on('click',function(){
		searchcontent = ld('.w-filter-wrapper .filter-keyword').val();
		if(empty(searchcontent)){
			refresh();
		}else{
			fun_search();
		}
	})
	//筛选 -- 快捷键查询
	ld('.w-filter-wrapper .filter-keyword').keydown(function(e){
		if(13 == e.keyCode){
			ld('.w-filter-wrapper .btn-search').click();
		}
	});
}

function selectDateChoice(htmlobj){

	var data_value =  ld(htmlobj).attr('data-value');

	var _display = ld('#selectbox_datebox').css('display');
	var a = 41,//间隔
		b1 = ld('.Edit_box').outerHeight(),//输入框
		b2 = ld('.ConSwitch').outerHeight(),//类别
		top = '';//标签高度

	if(ld('.Edit_box').is(':hidden')){

		top = a+17;
	}
	else{

		top = a+b1+b2+32;
	}
	//alert(ld(htmlobj).offset().top);
	//edit:can 2020-11-17 43308: （https://61mis.com/WX/kh41415 [^]）点击移动端首页的销售漏斗（方案确认）页面会一直转圈圈，点击功能菜单中的销售漏斗是可以直接查看客户信息的（后台报错）
	top =ld(htmlobj).offset().top-30;
	ld('#selectbox_datebox').css('top',top);
	var left = ld('.w-filter-select .value').offset().left;
	var mainwidth = getLeftMenuWidth();
	ld('#selectbox_datebox').css('left',left - mainwidth -8);

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
			var div_content = '<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">';
			div_content += '<tr>';
			div_content += '<td class="ld-form-item-label">'+arrJsPopLabel['STARTDATE1']+'</td><td class="ld-form-item-content"><input id="begin_date" class="Wdate ld-input-inner" name="begin_date" tabindex="d" fieldonly="0" size="20" maxlength="10" value="'+begin_date+'" placeholder="'+arrJsPopLabel['pleaseselectdate']+'" onclick="WdatePicker()" type="text"></td>';
			div_content += '</tr><tr>';
			div_content += '<td class="ld-form-item-label">'+arrJsPopLabel['ENDDATE1']+'</td><td class="ld-form-item-content"><input id="end_date" class="Wdate ld-input-inner" name="end_date" tabindex="d" fieldonly="0" size="20" maxlength="10" value="'+end_date+'" placeholder="'+arrJsPopLabel['pleaseselectdate']+'" onclick="WdatePicker()" type="text"></td>';
			div_content += '</tr>';
			div_content += '</table>';
			ld(divobj).find('.E_pop_tit .E_ptita').html(div_title);
			ld('#daterangrarr_custom_divcontent').html(div_content);
			ld('#daterangrarr_custom_div .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				var begin_date = ld('#begin_date').val();
				var end_date = ld('#end_date').val();
				if(begin_date == ''){
					var confirm_str = arrJsPopLabel['STARTDATE1']+arrJsPopLabel['CANOTEMPTY']+'！';
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
				if(end_date == ''){
					var confirm_str = arrJsPopLabel['ENDDATE1']+arrJsPopLabel['CANOTEMPTY']+'！';
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
				if(begin_date > end_date){
					var confirm_str = arrJsPopLabel['THISDATENOEDNDATE'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
				var reg=/-/g;
				begin_date=begin_date.replace(reg,'/');
				end_date=end_date.replace(reg,'/');
				fninvshnew('daterangrarr_custom_div');puyoungJS_DialogBox.unblock();
				ld('.w-filter-select .value').html(begin_date +'-'+end_date);
				ld('.w-filter-select .value').attr('data-value',select_data_value);
				ld('#selectbox_datebox').hide();
				fun_search();
			});
			ld('#daterangrarr_custom_div .E_pbtn .E_pbtncancel').on('click',function(){
				ld('#selectbox_datebox').hide();
			});
		}else{
			var select_li_value = trim(ld(this).html());
			ld('.w-filter-select .value').html(select_li_value);
			ld('.w-filter-select .value').attr('data-value',select_data_value);
			ld('#selectbox_datebox').hide();
			fun_search();
		}
	});


}
//加载列表前期工作
function fun_search(conswitchmenu_type){
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
	var urlstring = 'left_location='+cur_left_location+'&smallcategory='+smallcategory+'&bigcategory='+bigcategory+'&datecategory='+datecategory+'&datecategory_value='+datecategory_value;
	urlstring += '&sponsor='+sponsor;
	if(ld('#massdelete') != undefined && ld('#massdelete').val() == 'true'){
		urlstring += '&massdelete=true';
	}
	if(ld('#report_user_id') != undefined && ld('#report_user_id').val() > 0){
		urlstring += '&report_user_id='+ld('#report_user_id').val();
	}
	if(cur_left_location == 'all' && ViewallCooperativeWork != 'no'){
		urlstring+="&ViewallCooperativeWork=yes";//查看全部的界面标识（yes：是)
	}
	else{
		urlstring+="&ViewallCooperativeWork=no";//查看全部的界面标识（yes：是)
	}
	if(conswitchmenu_type == 'ConSwitchMenu'){
		// editor:gyqX160722 Bug:0023732
		urlstring += '&page=1&searchcontent='+searchcontent;//默认是第一页
		// ld('.pubDetialC').html('<div id="worklist_page_1"></div>');
		getWorkList(urlstring,function(){
			if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			{
				//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
			}
		});
	}else if(conswitchmenu_type == 'Refresh'){
		urlstring += '&page='+curpagenum+'&searchcontent='+searchcontent;
		getWorkList(urlstring,function(){
			if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			{
				//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
			}
		});
	}else{
		urlstring += '&page=1&searchcontent='+searchcontent;
		getWorkList(urlstring,function(){
			if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			{
				//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
			}
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
	urlstring += '&method=getList&searchscope='+coordination_searchscope;
	if(ld("#roleid").val()!=undefined&&ld("#roleid").val()!='')
	{
		urlstring += "&roleid="+ld("#roleid").val();
	}
	if(ld('#info') != undefined && ld('#info').val() != ''){
		urlstring += '&info=yes';
	}
	var detailViewPopupObj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
	if(detailViewPopupObj != undefined){
		urlstring += '&relateinfo=yes';
	}

	var attcount='';
	if('' != urldata) urlstring += '&'+urldata;
	//alert(urlstring);
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
			listhtml = '<div class="search_empty_holder"><img class="icon-empty" alt="'+arrJsPopLabel['NOCONTENT']+'" src="themes/images/emptyinfo.png">';
			listhtml += '<span class="empty-text">'+arrJsPopLabel['NOCONTENT']+'</span></div>';
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
					accountlist += '<span><a href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record='+accountobj.curid+'" target="_blank">'+accountobj.name+'</a></span><br>';
				})
			}
			contactlist = '';contactcls = 'ui-hide';
			if(!empty(report.Contacts)){
				contactcls = '';
				ld.each(report.Contacts,function(key,contactsobj){
					contactlist += '<span><a href="index.php?pageto_module=Contacts&pageto_action=index&pageto_record='+contactsobj.curid+'" target="_blank">'+contactsobj.name+'</a></span><br>';
				})
			}
			productslist = '';productscls = 'ui-hide';
			if(!empty(report.Products)){
				productscls = '';
				ld.each(report.Products,function(key,productsobj){
					productslist += '<span><a href="index.php?pageto_module=Products&pageto_action=index&pageto_record='+productsobj.curid+'" target="_blank">'+productsobj.name+'</a></span><br>';
				})
			}
			//点评、关键回复
			readerbuttontit = arrJsPopLabel['Reply'];keyreport = 'ui-hide';keyreport_href='ui-hide';now_finish_href = '';;
			if('yes' == report.readerbutton)
			{
				readerbuttontit = arrJsPopLabel['Reply'];
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
				readerbuttontit = arrJsPopLabel['Reply'];
			}
			keyreportstr = arrJsPopLabel['COMMENTCONTENT']+'(1)';
			if(report.entitytype == 'cocmd')
			{
				keyreportstr = '关键回复(1)';
			}
			//关联图片
			var download_permit = ld('#download_permit').val();
			var preview_permit = ld('#preview_permit').val();
			workimglist = '';workimgcls = 'ui-hide';
			if(!empty(report.workachment)){
				if(!empty(report.workachment['image'])){
					workimgcls = '';
					var fori = 1;

					ld.each(report.workachment.image,function(key,workimgobj){
						if(workimgobj.storage_location.value=='cos')
						{
							var imgpath=decodeURIComponent(workimgobj.cloud_path.value);
						}
						else
							var imgpath = workimgobj.path.value+workimgobj.newfile_name.value;

						var html = '<div achmentid="'+key+'" class="uploader-list" style="padding-bottom:5px">';
						html += '<span class="item-name"><img style="width: 80px;height: 80px" src="'+imgpath+'"></span>';
						html += '<span style="padding-left:10px;max-width:50%" class="overflow-space">'+workimgobj.file_name.value+'</span>';
						html += '<span class="file-size" style="color:#798699;">('+workimgobj.size.value.substring(0,40)+')</span>';
						if(download_permit == 'yes'){
							html += '<span class="webuploadPrebtn" style="padding-left:10px">';
							html += '<a target="_blank" href="index.php?module=Home&action=HomeAjax&file=openattachment&fildid='+key+'"><span>'+arrJsPopLabel['DOWNLOAD']+'</span></a>';
							html += '</span>';
						}
						if(preview_permit == 'yes'){
							html += '<span class="webuploadPrebtn" style="padding-left:10px">';
							html += '<a href="javascript:void(0);" onclick="previewImage(ld(this).parents(\'.uploader-list\').get(0));ld(this).parent().find(\'img\').click();"><span>'+arrJsPopLabel['PREVIEW']+'</span></a>';
							html += '<img style="display:none;width: 80px;height: 80px" src="'+imgpath+'">';
							html += '</span>';
						}
						html += '</div>';
						workimglist += html;
						++ fori;
					});
				}
			}

			//关联附件`
			workattlist = '';workattcls = 'ui-hide';
			attcount='';
			if(!empty(report.workachment)){
				if(!empty(report.workachment['att'])){
					workattcls = '';
					var fori = 1;
					ld.each(report.workachment.att,function(key,workattobj){
						var attpath = workattobj.path.value+workattobj.name.value;
						var html = '<div achmentid="'+key+'" class="att"><div>';
						html += '<img class="attimg lfloat marT7 marR5" src=\'themes/softed/images/file.png\'>';
						var href = 'href="javascript:;"';
						if (download_permit == 'yes'){
							href = 'target="_blank" href="index.php?module=Home&action=HomeAjax&file=openattachment&fildid='+key+'"';
						}
						html += '<span><a class="overflow-space" style="max-width:50%"'+href+'>'+workattobj.file_name.value+'</a></span>';
						html += '<span class="file-size" style="color:#798699;">('+workattobj.size.value.substring(0,40)+')</span>';
						if (download_permit == 'yes'){
							html += '<a '+href+' style="padding-left: 10px">';
							html += '<span>'+arrJsPopLabel['DOWNLOAD']+'</span></a>';
						}
						if (preview_permit == 'yes'){
							html += '<a href="javascript:void(0);" onclick="open_Attachment(' + report.curid + ',' + key + ',\'CooperativeWork\',\''+workattobj.newfile_name.value+'\')" style="padding-left: 10px">';
							html += '<span>'+arrJsPopLabel['PREVIEW']+'</span></a>';
						}
						html += '</div></div>';

						workattlist += html;
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
			//判断是否支持修改
			var editStr = 'no';
			if(report.isEdit=='yes')
			{
				editStr = 'yes';
			}
			var Stxtdisplay = 'ui-hide';
			if(0 != report.approved && report.editcount>0){
				Stxtdisplay = '';
			}
			//判断是否显示修改日志
			var loglist = 'ui-hide';
			if(report.editcount>0)
			{
				loglist = '';
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
			var workfldarr = {'worksummary':'worksummary','workexperience':'workexperience'}
			switch(report.entitytype){
				case 'weibo'://微博
				case 'cocmd'://任务
					//0043254: 合同订单 ->单据分录新增产品属性字段，选择产品自定义表字段，保存后再编辑字段长度显示异常
					workreportlabel = '<div class="content-text writeexperience" style="-webkit-user-select: text !important;-moz-user-select: text !important;-ms-user-select: text !important;">'+report.workexperience+'</div>';
					break;
				case 'workreport'://发日志
					ld.each(workreport_field_obj['worktype_'+report.workreporttype],
						function(fldname,fldlabel){
							if(workfldarr[fldname] != undefined) fldname = workfldarr[fldname];
							if((fldname == 'saleskit_day' || fldname == 'saleskit_week' || fldname == 'saleskit_month') && (report[fldname] == '' || report[fldname] == null)){

							}else{
								var content = report[fldname];
								if (fldname == 'saleskit_day' || fldname == 'saleskit_week' || fldname == 'saleskit_month'){
									var saleskit_showtype = report.saleskit_showtype;
									if (saleskit_showtype == 'html') {
										content = getSalesKitContent(saleskit_showtype,report.saleskit_listinfo)
									}
								}
								workreportlabel += '<div name="content-title-text">';
								workreportlabel += '<p class="content-title writesummary" name="content-title">'+fldlabel+'<a class="workreportviewcopy" name="workreportviewcopy" href="javascript:void(0);">'+arrJsPopLabel['COPY']+'</a></p>';
								workreportlabel += '<div class="content-text writeexperience" name="content-text" style="-webkit-user-select: text !important;-moz-user-select: text !important;-ms-user-select: text !important;">'+content+'</div>';
								workreportlabel += '</div>';
							}
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
				Stxtdisplay,
				loglist,//修改日志是否显示
				report.editcount,//修改数量
				report.workreporttype,//销售简报
				report.userid,//销售简报
				report.curid,//销售简报
//移除原来更多中的占位符    XUQIU1001397工作汇报，将更多中的“转发”按钮直接显示在“更多”的位置上（去掉“更多”操作按钮）
/*				report.entitytype,
				report.curid,//更多ID
				report.entitytype,
				report.curid,//更多ID*/

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

				report.curid,//编辑
				editStr,//是否编辑
				report.curid, //编辑

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
			//XUQIU1001397工作汇报，将更多中的“转发”按钮直接显示在“更多”的位置上（去掉“更多”操作按钮）
			//工作日志，设置取消按键只在任务中显示   &任务的状态为   ”已完成“ (report.approved:1)和”已取消“(report.approved:2) 不再显示取消按键
			if(report.entitytype == 'cocmd' && report.approved != 1 && report.approved != 2){
				node = strtr(node,'more-menu-cancel ui-hide','more-menu-cancel');
			}
			listhtml += node;
		});

		ld('#worklist_page_'+curpagenum).html(listhtml);
		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
		}

		ld('.pubDetialC').html(ld('.pubDetialC').html()+'<div id="worklist_page_'+(curpagenum+1)+'"></div>');
		WorkListBind();

		//查看界面复制悬浮事件
		var viewcopy=ld("#worklist_page_1").find("div[name=content-text]:contains():not(:empty())");//含有文本但不为空
		// var viewcopy=ld("#worklist_page_1").find("div[name=content-title-text]");
		ld(viewcopy).each(function (index,textdiv){
			var title_text_div=ld(this).parent('div[name=content-title-text]');
			ld(title_text_div).unbind('mouseout').on('mouseout',function (event){
				ld(this).find('a[name=workreportviewcopy]').css('display','none');
			});
			ld(title_text_div).unbind('mouseover').on('mouseover',function (event){
				ld(this).find('a[name=workreportviewcopy]').css('display','block');
			});
			ld(title_text_div).find('a[name=workreportviewcopy]').unbind('click').on('click',function(){
				// 赋值复制内容
				var copycontent =ld(textdiv).html();
				copycontent=copycontent.replace(/<br>/g,'\n');
				// 创建textarea标签，将复制内容暂存为value值
				var copy_content = document.createElement("textarea");
				copy_content.value=copycontent;
				document.body.appendChild(copy_content);
				copy_content.select();
				// 执行复制
				document.execCommand("copy");
				document.body.removeChild(copy_content);
				DelProgressObjs();
				MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED']);
			});
		});

		//ljj 20240618 XUQIU20240521-06 工作汇报点评人固定、提交期限提醒时间自定义（张宇彦）
		//个人描述设置悬浮事件
		var stram_text_div=ld('[name=stream_group_list]');
		ld(stram_text_div).unbind('mouseout').on('mouseout',function (event){
			if (ld('[name=stream_text]')[0].tagName == 'P'){
				ld(this).find('a[name=stream_text_set]').css('display','none');
			}
		});
		ld(stram_text_div).unbind('mouseover').on('mouseover',function (event){
			if (ld('[name=stream_text]')[0].tagName == 'P') {
				ld(this).find('a[name=stream_text_set]').css('display', 'block');
			}
		});

		callback();
	});
}
function saveedit(){
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
	var prevapproved = ld(popupobjid+'#approved').val();
	var workreportid = ld(popupobjid+'#workreportid').val();
	var entitytype = ld(popupobjid+'#entitytype').val();
	var type = ld(popupobjid+'#type').val();
	var mandatory_bool = true;//必填项是否填写
	ld(popupobjid).find('textarea[is_mandatory=0]').each(function() {
		if(empty(ld(this).val())){//必填判断，未填写
			let notice_msg = arrJsPopLabel['CONTENTCANOTEMPTY'];
			if(entitytype !='weibo' && entitytype !='cocmd'){
				var fieldTitle = ld(this).parent().find('label').text();
				notice_msg = fieldTitle+"不能为空！";
			}
			audioRemindsMsg("","","CooperativeWork","","",notice_msg);
			ld(this).focus();//光标移入
			return mandatory_bool = false;
		}
	});
	if(!mandatory_bool) return false;//未填写
	//组装对应的字段和值
	var workfldfilter = '';var workfldstring = '';
	ld(popupobjid).find('textarea').each(function(){
		workfldfilter += '&'+ld(this).attr('name')+'='+encodeURIComponent(ld(this).val());
		workfldstring += ld(this).attr('name') +',';
	});
	workfldfilter += '&workfld='+workfldstring;
	var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
	urlstring += '&method=editReport';
	urlstring += '&reportid='+workreportid+'&approved='+prevapproved;
	urlstring += '&entitytype='+entitytype;

	var params = {};
	if(entitytype == 'workreport'){
		if(type == 1){
			if(ld(popupobjid+'#sendlog_saleskit_date').val() != undefined){
				saleskit_date = ld(popupobjid+'#sendlog_saleskit_date').val();
			}else{
				saleskit_date = ld(popupobjid+'#span_saleskit_date').html();
			}
			//日志日期不能大于当前日期
			var now_date = getNowDate();
			if(saleskit_date > now_date){
				var confirm_str = arrJsPopLabel['thelogdatecannotbegreater'];//提示内容
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}else{
			saleskit_date = ld(popupobjid+'#span_saleskit_date').html();
		}
		urlstring += '&saleskit_date='+saleskit_date;
		var showtype =ld(popupobjid+'#saleskit_showtype').val();
		params['saleskit_showtype'] = showtype;
		params['saleskit_listinfo'] = ld(popupobjid+'#saleskit_listinfo').val();

	}
	if(entitytype == 'cocmd'){
		var date = ld(popupobjid+'#d241').val();//完成时间
		var time = ld(popupobjid+'#d242').val();//完成时间
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
			if(0 == ld('#cmd-time-error').length){//当层未创建时，创建层
				var confirm_str = '完成时间不能早于当前时间。';
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			}
			return false;
		}
		urlstring += '&startdate='+startdate+'&enddate='+startdate;
	}

	var accountlist = '';var contactlist = '';var productslist = '';//关联的客户、联系人、产品

	if(ld(popupobjid+'#sendLogAcctlist ul.reader-bar-list li').length > 0){
		ld(popupobjid+'#sendLogAcctlist ul.reader-bar-list li').each(function(){
			accountlist += ld(this).attr('accountid')+',';
		});
	}
	if(ld(popupobjid+'#sendLogContlist ul.reader-bar-list li').length > 0){
		ld(popupobjid+'#sendLogContlist ul.reader-bar-list li').each(function(){
			contactlist += ld(this).attr('contactid')+',';
		});
	}
	if(ld(popupobjid+'#sendLogProlist ul.reader-bar-list li').length > 0){
		ld(popupobjid+'#sendLogProlist ul.reader-bar-list li').each(function(){
			productslist += ld(this).attr('productid')+',';
		});
	}
	//获取相关图片
	var uploadimgList = '';
	if(ld(popupobjid+'#sendLogUploadImg ul li').length > 0){
		ld(popupobjid+'#sendLogUploadImg ul li').each(function(){
			uploadimgList += ld(this).attr('record')+',';
		});
	}

	//获取相关
	var uploadattList = '';
	if(ld(popupobjid+'#sendLogUploadAtt ul li').length > 0){
		ld(popupobjid+'#sendLogUploadAtt ul li').each(function(){
			uploadattList += ld(this).attr('record')+',';
		});
	}
	urlstring += '&accountlist='+accountlist+'&contactlist='+contactlist+'&productslist='+productslist;
	urlstring += '&uploadimgList='+uploadimgList;
	urlstring += '&uploadattList='+uploadattList;
	ldAjaxNoProgress("index.php?"+urlstring+workfldfilter,params,function(rest){
		if(rest.msg!='success'){
			RemindsMsg("","LdPopWidth400px","","yes","yes",rest.msg);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			popupobj.CancelEvent();
			refresh();
			});
		}else{
			popupobj.CancelEvent();
			refresh();
		}
	})
}
/**
 * 绑定事件
 * @author Tujt 2015-02-05
 */
var cur_morename = '';	//更多按钮
function WorkListBind(){
	//更多-弹框
	var more_li_obj = ld('[name=more_operation]');
	more_li_obj.on('mouseover',function(event){
		var morename = ld(this).find('[tag=more]').attr('morename');
		var seat = morename.indexOf("-");
		var typename = morename.substr(0,seat);
		var workreportid = morename.substr(seat+1,morename.length-seat);
		cur_morename = morename;
		//微博和日志是转发，任务是取消
		var name = '';
		if(typename == 'workreport'||typename == 'weibo')
		{
			name = 'more-cancel-'+workreportid;
			ld('#'+name).css('display','none');
			ld('[tag='+morename+']').removeClass('ui-hide');
		}
		else
		{
			var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
			urlstring += '&method=checkMore&workreportid='+workreportid;
			ldAjaxHtml('index.php?',urlstring,function (rest) {
				if(empty(rest)) return false;
				var report = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);

				ld.each(report,function(key,report){
					if(empty(report)) return false;
					if(report.approved=='yes')
					{
						name = 'more-cancel-'+workreportid;
						ld('#'+name).css('display','none');
					}
					ld('[tag='+morename+']').removeClass('ui-hide');

				});
				DelProgressObjs();
			})
		}
	});
	more_li_obj.on('mouseleave',function(event){
		var morename = ld(this).find('[tag=more]').attr('morename');
		var seat = morename.indexOf("-");
		var workreportid = morename.substr(seat+1,morename.length-seat);
		var name = '';
		name = 'more-cancel-'+workreportid;
		ld('#'+name).css('display','');
		ld(this).find('[tag='+morename+']').addClass('ui-hide');
	});
	//更多-转发弹框
	ld('div.func [tag=more-forward]').on('click',function(event){
		createForwardPop(this);
	});
	//销售简报
	ld('div.func [tag=saleskit_target]').on('click',function(event){
		var workreporttype = ld(this).attr('workreporttype');
		var userid = ld(this).attr('userid');
		var workreportid = ld(this).attr('workreport');
		var workdate = ld(this).attr('date');
		var title = ld(this).html();

		if(workreporttype > 0 && userid > 0){
			var worktype =global_worktype;
			var sendlog_date = '';
			//工作汇报：工作协同
			var popupobj=CrmPopup.load("","","","LdPopWidth600px",'WorkBriefReport',"","","","");
			popupobj.prevshow();
			ldAjax("index.php?action=CooperativeWorkAjax&module=CooperativeWork&file=WorkReportIndex&method=getSendLog_SalesKit_date&workreportid="+workreportid+"&userid="+userid,'',function (data) {
				popupobj.setParams(title+data.sendlog_date,popupobj.CancelEvent,'',"LdPopWidth600px",'WorkBriefReport','',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['LBL_CLOSE']);
				var tablehtml = '<div id="saleskit_div" style="max-height: 400px;overflow-y: auto;margin: 15px;">';
				ld.each(data.list,function (name,info) {
					tablehtml += '<div class="cooperativeWorktranstab" style="overflow: hidden;text-overflow:ellipsis" tag="div_'+name+'">' +
						'<div tag="span_transtab_'+name+'" class="padB5">'+info.label+'</div>' +
						'<span tag="create_span_'+name+'" name="'+name+'" module="'+info.module+'" class="folder colorLink hoverUnderLine padR3 tip-workbirefreport-list" data-tip="'+info.nums+'" data-direction="top" data-type="position">'+info.nums+'</span>' +
						'</div>';
				});
				tablehtml += '</div>';
				popupobj.show(tablehtml);
				ld.each(data.list,function (name,info) {
					if (info.istotalempty == 'no'){
						ld('#'+popupobj.divid).find('[tag=create_span_'+name+']').unbind('click').bind('click',function () {
							getSendLog_SalesKit_ChuantouInfo(ld(this),data.userid,data.sendlog_date);
						});
					}
				});
				tooltip('.tip-workbirefreport-list',{transition: true, time: 200});
				DelProgressObjs();
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
					DelProgressObjs();
					refresh();//刷新页面
				});
			});

		}
	});
	//点赞
	ld('div.func [tag=praise]').on('click',function(event){
		if(cur_morename != undefined && cur_morename != ''){
			ld('div.func [tag='+cur_morename+']').addClass('ui-hide');
		}
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
			DelProgressObjs();
		});
	});
	//现在执行按钮事件
	ld('div.pubclear [tag=now_finish]').on('click',function(event){
		createReaderPop(this,'finish');
	});
	//点评日志按钮事件
	ld('div.pubclear [tag=now_reply]').on('click',function(event){
		createReaderPop(this,'reply');
	});
	//点评、回复
	ld('div.func [tag=reply]').on('click',function(event){
		var replyobj = ld(this);
		var replytag = ld(this).find('span').attr('tag');
		if(1==2){//点评	'yes' == replytag || '2' == bigcategory

		}else{//回复
			//chj 2020/11/12 42946: （https://61mis.com/kfbtest [^]）工作汇报数据列表界面，点击更多后，再点击回复时，转发选项没有隐藏
			if(cur_morename != undefined && cur_morename != ''){
				ld('div.func [tag='+cur_morename+']').addClass('ui-hide');
			}
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
				ld(obj).parent().find('.userInfo').removeClass('nobottomborderradius');
				ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').addClass('ui-hide');
				//显示“以下为日志点评人的点评：”，隐藏“回复内容：”
				ld(obj).find('.reply-info').eq(0).addClass('ui-hide');
				ld(obj).find('.reply-info').eq(1).removeClass('ui-hide');
				return false;
			}else{
				ld(obj).removeClass('ui-hide');
				ld(obj).parent().find('.userInfo').addClass('nobottomborderradius');
				ld('.pubDetialC > div > div[workreportid='+workreport+'] .common-up').removeClass('ui-hide');
				//zkt 0046914: https://81mis.com/kfbcrm/ [^] ，oa表单-工作汇报-回复-以下为日志点评人的点评，不仅显示日志点评人的点评也显示其他人的回复，描述不准确，应改为以下为评论区所有内容。
				//隐藏“以下为日志点评人的点评：”，显示“回复内容：”
				ld(obj).find('.reply-info').eq(0).removeClass('ui-hide');
				ld(obj).find('.reply-info').eq(1).addClass('ui-hide');
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
							if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
							{
								//通讯录(pc端企业微信)

								cls_wxOpenDataobj.bindAllOpenData();
							}
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
							if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
							{
								//通讯录(pc端企业微信)

								cls_wxOpenDataobj.bindAllOpenData();
							}
						});
					}
					ld('.usercontrol > li[tag=Recently]').css('display','none');//隐藏最近标签
					ld('.usercontrol > li[tag=Department]').css('display','none');//显示部门标签
					ld('.usercontrol > li[tag=Colleague]').css('display','none');//显示同事标签
					ld('.usercontrol > li[tag=Colleague]').click();//激发同事标签点击事件
					ld('#searchColleagueText').css('display','none');//隐藏搜索框
					//用户搜索框placeholder属性赋值
					ld('#searchColleagueText').css('display','');//显示搜索框
					ld('#searchColleagueText').attr('placeholder',arrJsPopLabel['searchforcolleagues']);
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

								urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4&backstatus=yes';
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
									DelProgressObjs();
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
						urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4';
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
							DelProgressObjs();
						});
					}
					DelProgressObjs();
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
		var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
		var that = ld(this);
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

		//确定按钮
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){

			var workreport = that.attr('workreport');
			var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
			urlstring += '&method=DeleteReport&workreportid='+workreport;
			RequestAjax(urlstring,function(rest){
				DelProgressObjs();
				refresh();
			});
		});
	});
	//报告编辑
	ld("div.func [tag = edit]").unbind('click').on('click',function(event){
		var that = ld(this);
		var workreport = that.attr('workreport');
		var surl = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=ModifyView';
		surl +='&workreportid='+workreport;
		var crmPopupobj=CrmPopup.load(arrJsPopLabel['EDIT'],'',"","LdPopWidth600px",'CooperativeWork',"",'',"",''); //加载弹窗
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,'',function(data) {
			if(data.code == 1){
				if (empty(data.result)){
					crmPopupobj.CancelEvent();
					return false;
				}
				crmPopupobj.setParams(arrJsPopLabel['EDIT']+data.result.entitytypename,saveedit,"","LdPopWidth600px",'CooperativeWork',"",arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL']); //加载弹窗
				crmPopupobj.isShowFullscreen='yes';
				crmPopupobj.Fullscreencallback = function (switchtotype) {
					var headHeight = ld('#' + crmPopupobj.divid + '_head').outerHeight();
					var bottomHeight =ld('#' + crmPopupobj.divid + '_popupbottom').outerHeight();
					var contentheight = CrmPopup.getClientHeight()- headHeight-bottomHeight;
					if(switchtotype == 'fullscreen'){
						ld('#'+crmPopupobj.divid+'_scroll').css({'max-height':CrmPopup.getClientHeight(),'height':contentheight});
					}else if(switchtotype=='recovery'){
						ld('#'+crmPopupobj.divid+'_scroll').css('max-height',ld('#'+crmPopupobj.divid+' .Edit_box').outerHeight());
						ld('#'+crmPopupobj.divid).css('width','600px');
						crmPopupobj.center();
					}
				}
				crmPopupobj.center();
				// CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				crmPopupobj.show(data.result.content);
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
				if(data.result.saleskit_showtype == 'html'){
					showSalesKit(data.result.reporttype,'html',data.result.saleskit_listinfo);
				}
				initEditReport();
			}else{
				crmPopupobj.cancelEvent();
			}

		});
	})
	//新建日程
	var isCreate = 1;
	ld("div.Cbox_R .add-new").unbind('click').on('click',function(event){
		if(isCreate > 1)return false;
		isCreate++;
		//getDataList
		var wh_chose_day = 0;
		var wh_isToday = 0;
		chooseDate = '';

		var year_month = ld('.wh_content_all .wh_content_li').attr('data-yearmonth');
		year_month = year_month.replace('年', '-');
		year_month = year_month.replace('月', '-');
		ld('.wh_content_all .wh_content .wh_item_date').each(function(){
			var date_class = ld(this).attr('class');
			if(date_class == 'wh_item_date wh_chose_day' || date_class == 'wh_item_date wh_isToday wh_chose_day'){
				if(ld(this).html().indexOf('<i class="wh_top_tag_spot"></i>') == -1){
					wh_chose_day = ld(this).html();
				}else{
					//@edit:zhouxiaomei,2020-09-10,reason:bug 选择日期时 获取选中日期
					wh_chose_day = ld(this).attr('tag');
				}
			}
			if(date_class == 'wh_item_date wh_isToday'){
				//@edit:zhouxiaomei,2020-09-10,reason:bug 未选择日期时 获取当前日期
				wh_isToday = ld(this).attr('tag');
			}
		});
		var confirm_chose_date = 0;
		if(wh_chose_day > 0){
			confirm_chose_date = wh_chose_day;
		}else{
			confirm_chose_date = wh_isToday;
		}
		if(confirm_chose_date < 10){
			confirm_chose_date = '0'+confirm_chose_date;
		}
		var objparams = new CreatePagePopup.params();
		objparams.params['isduplicate'] = 'no';
		objparams.params['refreshpage'] = 'no';
		objparams.params['createdtype'] = 'create';
		var start_date = year_month + confirm_chose_date+' 00:00:00';
		var end_date = year_month + confirm_chose_date+' 23:59:59';
		var lasturl = '&date_start='+start_date+'&due_date='+end_date;
		CreatePagePopup.type = 'cooperativework_create';
		CreatePagePopup.showpage('Calendar', lasturl, objparams);

		var popupobj=CrmPopup.getPopupObj("last");
		if(ld(this).data('stuffid') != undefined && ld(this).data('stuffid')>0){
			popupobj.homestuffid = ld(this).data('stuffid');
			popupobj.homestufftype = ld(this).data('stufftype');
		}
		//edit:can 20210820 47608: （https://81mis.com/kfbcrm [^]）测试部演示账套-工作汇报-界面右侧日程管理-新建-新建时设置好日程时间段保存后，会自动变成当天的0点到24点
		popupobj.lasturl='';
		isCreate = 1;
		//ld("#"+popupobj.divid+" [name=due_date]").val(end_date);
	})
	//共有同事列表
	ld(".userInfo .group [tag=fstip]").on("click",function(event){
		var workreport = ld(this).attr('workreport');
		var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
		urlstring += '&method=getReportUserList&workreportid='+workreport;

		RequestAjax(urlstring,function(rest){
			var dataObj=eval('('+rest+')');
			var strhtml="";
			ld('#fs-tip .share-group-tpl .share-group-warp').html("");
			if(dataObj.list){
				for(var i=0;i<dataObj.list.length;i++){
					strhtml+='<div class="share-group-items pubclear"> ';
					strhtml+='<a class="profileimage" href="javascript:;"> ';
					strhtml+=' <img src="';
					strhtml+=dataObj.list[i].userimage;
					strhtml+=' "/> ';
					strhtml+=' </a>  <span class="name fontblue">';
					strhtml+=dataObj.list[i].username;
					strhtml+='</span> <span class="infotype"></span></div>';
				}
			}
			ld('#fs-tip .share-group-tpl .share-group-warp').html(strhtml);
			ld('#fs-tip .share-group-countman .num').html(dataObj.usercount);
			var e=event||window.event;
			var obj=e.srcElement||e.target;
			var tagName = getId('fs-tip');

			FindEvent(obj,tagName,event,'',0,'lefttop');
			if(dataObj.usercount > 0){
				tagName.style.display="block";
			}
			else{
				tagName.style.display="none";
			}
			// diony 2020-08-13
			// 【0041506: （61mis.com/kfbcrm）工作汇报模块，点击已经发布了的工作汇报数据中的“3个同事”，弹出弹窗后点击空白部分，应该自动关闭弹窗】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001000904
			ld("#fs-tip").click(function(e) {
				e?e.stopPropagation():event.cancelBubble = true;
			});
			ld(document).click(function() {
				ld("#fs-tip").fadeOut();
			});
			ld('#fs-tip .close').on('click',function(){
				ld('#fs-tip').css('display','none');
			});
			DelProgressObjs();

			if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			{
				//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
			}
		});
	});
	//修改日志事件
    ld('div.func [tag=loglist]').on('click',function() {
		var workreportid = ld(this).parent().parent().parent().parent().parent().attr('workreportid');
		var surl = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=ChangelogView';
		surl += "&workreportid="+workreportid;
		var crmPopupobj=CrmPopup.load('',"","","630",'CooperativeWork',"",'',"",''); //加载弹窗
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,'',function(data) {
			if (data.code == 1) {
				if (empty(data.result)){
					return false;
				}
				crmPopupobj.isShowFullscreen='yes';
				crmPopupobj.Fullscreencallback = function (switchtotype) {
					var biaotouheight = ld('#'+crmPopupobj.divid+' #resize_header_tableid_changelog').height();
					var headHeight = ld('#' + crmPopupobj.divid + '_head').outerHeight();
					var bottomHeight =ld('#' + crmPopupobj.divid + '_popupbottom').outerHeight();
					var biaotiheight = CrmPopup.getClientHeight()-headHeight-bottomHeight-biaotouheight;
					if(switchtotype == 'fullscreen'){
						ld('#'+crmPopupobj.divid+' #resize_content_table_divid_changelog').css({'height':biaotiheight,'overflow':'auto'});
					}else if(switchtotype=='recovery'){
						ld('#'+crmPopupobj.divid+' #resize_content_table_divid_changelog').css({'height':'400px','overflow':'auto'});
						ld('#'+crmPopupobj.divid).css('width','630px');
					}
					crmPopupobj.center();
					ld('#'+crmPopupobj.divid+' #resize_header_tableid_changelog').css('width',ld('#'+crmPopupobj.divid+' #resize_content_tableid_changelog').width());
				}
				crmPopupobj.setParams(data.result.title,crmPopupobj.CancelEvent,'',"630",'CooperativeWork','',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['LBL_CLOSE']);
				crmPopupobj.show(data.result.content);
				ld('#'+crmPopupobj.divid+' #resize_content_table_divid_changelog').css({'height':'400px','overflow':'auto'});
				ld('#'+crmPopupobj.divid).find('td').each(function() {
					ld(this).css({'white-space':'pre-wrap','word-wrap':'break-word'});
				});
				crmPopupobj.center();
				ld('#'+crmPopupobj.divid+' #resize_header_tableid_changelog').css('width',ld('#'+crmPopupobj.divid+' #resize_content_tableid_changelog').width());
			}else{
				crmPopupobj.cancelEvent();
			}
		});
    })
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
			//显示“以下为日志点评人的点评：”，隐藏“回复内容：”
			ld(obj).find('.reply-info').eq(0).addClass('ui-hide');
			ld(obj).find('.reply-info').eq(1).removeClass('ui-hide');
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
							if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
							{
								//通讯录(pc端企业微信)

								cls_wxOpenDataobj.bindAllOpenData();
							}
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
					ld('#searchColleagueText').attr('placeholder',arrJsPopLabel['searchforcolleagues']);
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
							urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4';
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
								//edit:can 2021-01-08 43010: （8.2.7PHP7+Redis安装包）工作汇报，点评数据后，点击点评内容->回复，输入数据点击回复时，界面一直显示加载中
								ld('#delete'+workreportid).attr('delete','no');
								//自动添加一行
								getReplyList(obj,workreportid);
								issubmit = 1;
								DelProgressObjs();
							});
							DelProgressObjs();
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
							urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4&backstatus=yes';
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
								DelProgressObjs();
							});
						});
						/* gyqX160720 */
						ld('#remindsDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
							ld('#remindsDiv').css('display','none');
							ld(".ui-mask").css('display','none');
						});
						DelProgressObjs();
					});
				}
				else
				{
					var urlstring = 'module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=saveSendLog&workreportid='+workreportid;
					urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4';
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
						DelProgressObjs();
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
			DelProgressObjs();
		});
	});
	//用户头像绑定事件
	ld('.mainuser .content .ui-cont-list span img').on('mousemove',function(){
		ld(this).css('cursor','pointer');
	});
	//绑定用户头像图片点击事件
	ld('.mainuser .userInfo .item-top dt img').on('click',function(){
		var report_user_id = ld(this).attr('report_user_id');
		if(!empty(report_user_id)){
			//edit:can 20210408 45388: （61mis.com/kfbcrm）OA表单-工作汇报；管理员登录，在工作汇报界面点击成员ASD的头像，进入的新链接界面应只显示成员ASD日志月计划等
			var page_addurl=encodeURIComponent('&report_user_id='+report_user_id+'&info=yes');
			window.open('index.php?pageto_module=CooperativeWork&pageto_action=index&&page_addurl='+page_addurl);
		}
	});
	ld('.mainuser .content .ui-cont-list span img').on('mouseover',function(){
		ld(this).css('cursor','');
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
		if(empty(rest)) {
			DelProgressObjs(); return false;
		}
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
				window.open('index.php?pageto_action=index&pageto_module=CooperativeWork&report_user_id='+report_user_id+'&info=yes');
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
						if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
						{
							//通讯录(pc端企业微信)

							cls_wxOpenDataobj.bindAllOpenData();
						}
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
				ld('#searchColleagueText').attr('placeholder',arrJsPopLabel['searchforcolleagues']);
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
			var replysubmitobj = ld(this);
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
				urlstring += '&replycontent='+encodeURIComponent(replycontent)+'&savetype=4';
				urlstring += '&atgroup='+atgroup+'&atuser='+usernamesid;
				var replyid = ld(replysubmitobj).parent().parent().parent().parent().parent().attr('replyid');
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
					DelProgressObjs();
				});
				DelProgressObjs();
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
		DelProgressObjs();
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

		//edit:can BUG20240829-29  工作汇报--现在工作汇报的加载有问题，加载会显示多个加载提示，红框应该全部取消，仅留蓝框即可 
		///ld('#worklist_page_'+curpagenum).html('<div style="text-align: center;padding-bottom: 15px;"><span class="loading-icon"><img src="themes/softed/images/loading.gif"></span><span class="loading-text">正在加载，请稍后……</span></div>');
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
var tag = 'sendLog';
function setAccountInfo(accountid,accountname){
	var popupobj=CrmPopup.getPopupObj("lastprev");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
    var existing = ld(popupobjid+'#'+tag+'Acctlist ul li[accountid='+accountid+']');
	if(existing.length<=0){
		ld(popupobjid+'#'+tag+'Acctlist ul').append('<li accountid="'+accountid+'"><span class="item-name">'+accountname+'</span><span class="remove-h">×</span></li>');
	}
	ld(popupobjid+'#'+tag+'Acctlist').css('display','');
	//绑定删除事件
	ld(popupobjid+'#'+tag+'Acctlist ul .remove-h').unbind('click').click(function(){
		var accountid = ld(this).parent().attr('accountid');
		ld(popupobjid+'#'+tag+'Acctlist ul li[accountid='+accountid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Acctlist ul li').length){
			ld(popupobjid+'#'+tag+'Acctlist').css('display','none');
		}
	});
	return true;//不走下面的代码
}
/**
 * 选择联系人方法
 * @author Tujt 2015-02-04
 */

function setContactInfo(contactid,contactname){

	var tag = 'sendLog';
	var popupobj=CrmPopup.getPopupObj("lastprev");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
	var existing = ld(popupobjid+'#'+tag+'Contlist ul li[contactid='+contactid+']');
	if(existing.length<=0){
		ld(popupobjid+'#'+tag+'Contlist ul').append('<li contactid="'+contactid+'"><span class="item-name">'+contactname+'</span><span class="remove-h">×</span></li>');
	}
	ld(popupobjid+'#'+tag+'Contlist').css('display','');
	//绑定删除事件
	ld(popupobjid+'#'+tag+'Contlist ul .remove-h').unbind('click').click(function(){
		var contactid = ld(this).parent().attr('contactid');
		ld(popupobjid+'#'+tag+'Contlist ul li[contactid='+contactid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Contlist ul li').length){
			ld(popupobjid+'#'+tag+'Contlist').css('display','none');
		}
	});
	return true;//不走下面的代码
}
/**
 * 选择产品方法
 * @author diony 2016-04-20
 */
function setProductsInfo(productid,productname){
	var tag = 'sendLog';
	var popupobj=CrmPopup.getPopupObj("lastprev");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
	var existing = ld(popupobjid+'#'+tag+'Prolist ul li[productid='+productid+']');
	if(existing.length<=0){
		ld(popupobjid+'#'+tag+'Prolist ul').append('<li productid="'+productid+'"><span class="item-name">'+productname+'</span><span class="remove-h">×</span></li>');
	}
	ld(popupobjid+'#'+tag+'Prolist').css('display','');
	//绑定删除事件
	ld(popupobjid+'#'+tag+'Prolist ul .remove-h').unbind('click').click(function(){
		var productid = ld(this).parent().attr('productid');
		ld(popupobjid+'#'+tag+'Prolist ul li[productid='+productid+']').remove();
		if(0 == ld(popupobjid+'#'+tag+'Prolist ul li').length){
			ld(popupobjid+'#'+tag+'Prolist').css('display','none');
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
		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
		{
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
		}
		callback();
		tagName.style.display = '';
		DelProgressObjs();
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
			if(iskehu001=='yes'){
				EmptyProgressObjs();//清空
				if('' == obj.value){

					ld.each(userColleagueArray,function(key,userobj){

						userhtml += '<div userid="'+userobj.userid+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';


					});
					ld('#ColleagueDiv').html(userhtml);
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
					{
						//通讯录(pc端企业微信)

						cls_wxOpenDataobj.bindAllOpenData();
					}
					CoorSearchResult();
					return ;
				}
				ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=searchUserByKehu001&iskehu001="+iskehu001,{'searchvalue':obj.value},function(data){
					if(data.result.list.length>0){
						ld.each(userColleagueArray,function(key,userobj){
							if(ld.inArray(userobj.userid,data.result.list)>=0){
								userhtml += '<div userid="'+userobj.userid+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';

							}
						});
						ld('#ColleagueDiv').html(userhtml);
						if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
						{
							//通讯录(pc端企业微信)
							cls_wxOpenDataobj.bindAllOpenData();
						}
						CoorSearchResult();
					}

				});
			}
			else{

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
					CoorSearchResult();

				});
			}
		}

	}
}
function CoorSearchResult()
{   var searchColleagueText = ld('#searchColleagueText').attr('tag');
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
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)

					cls_wxOpenDataobj.bindAllOpenData();
				}
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

				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)

					cls_wxOpenDataobj.bindAllOpenData();
				}
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
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)

					cls_wxOpenDataobj.bindAllOpenData();
				}
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
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)

					cls_wxOpenDataobj.bindAllOpenData();
				}
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

				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)

					cls_wxOpenDataobj.bindAllOpenData();
				}
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
				if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
				{
					//通讯录(pc端企业微信)
					cls_wxOpenDataobj.bindAllOpenData();
				}
			});
			if(ld('#DepartmentDiv').css('display') != 'none'){
				ld('#DepartmentDiv > div').unbind('click').click(function(){
					var workreportid = ld(obj).attr('workreport');
					ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val(
						ld('.pubDetialC div[workreportid='+workreportid+'] ').find('.reply-wrapper div[tag=replyarea] textarea').val() + '@'	+
						ld(this).find('span').html()+' '
					);
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
					{
						//通讯录(pc端企业微信)

						cls_wxOpenDataobj.bindAllOpenData();
					}
				});
			}
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
var uploadFileobj = new WebUploadFile();
function setUpload (){

	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}

	
	globalWebUploadType=uploadFileobj.uploadType();

	if(globalWebUploadType=='cos' && cos_webuploader == 0)
	{

		AjaxJSPage('Speical_webUploaderCos_js','include/js/webuploader/Speical_webUploaderCos.js');

		ld(popupobjid+"[name=multiple_att]").special_powerWebUploadCos({
			fileTypeDuplicate:'yes',	//附件类型判断
			fileNameDuplicate:'yes',	//同名附件判断
			mode:'',	//当前单据 create or edit
			module:'CooperativeWork',	//当前模块
			jsonData:'',	//edit data,编辑界面显示已上传的附件
			record:'',	//单据单据id
			admin:'',//是否是管理员
			uitype:'1108',
			popupobj:popupobj,
			supportformat:'',//支持格式
			inputFileName:'multiple_att'	//选择附件后赋值标签的name
		});

		//渲染容器
		ld(popupobjid+"[name=multiple]").special_powerWebUploadCos({
			fileTypeDuplicate:'yes',	//附件类型判断
			fileNameDuplicate:'yes',	//同名附件判断
			mode:'',	//当前单据 create or edit
			module:'CooperativeWork',	//当前模块
			jsonData:'',	//edit data,编辑界面显示已上传的附件
			record:'',	//单据单据id
			admin:'',//是否是管理员
			uitype:'69',
			popupobj:popupobj,
			supportformat:'',//支持格式
			inputFileName:'multiple'	//选择附件后赋值标签的name
		});
	}
	else
	{
		getJsScript('include/js/special_webuploader.js', function () {
			ld(popupobjid+"[name=multiple_att").special_powerWebUpload({
				fileTypeDuplicate:'yes',	//附件类型判断
				fileNameDuplicate:'yes',	//同名附件判断
				mode:'',	//当前单据 create or edit
				module:'CooperativeWork',	//当前模块
				jsonData:'',	//edit data,编辑界面显示已上传的附件
				record:'',	//单据单据id
				admin:'',//是否是管理员
				uitype:'',
				popupobj:popupobj,
				supportformat:'',//支持格式
				inputFileName:''	//选择附件后赋值标签的name
			});

			//渲染容器
			ld(popupobjid+"[name=multiple").special_powerWebUpload({
				fileTypeDuplicate:'yes',	//附件类型判断
				fileNameDuplicate:'yes',	//同名附件判断
				mode:'',	//当前单据 create or edit
				module:'CooperativeWork',	//当前模块
				jsonData:'',	//edit data,编辑界面显示已上传的附件
				record:'',	//单据单据id
				admin:'',//是否是管理员
				uitype:'69',
				popupobj:popupobj,
				supportformat:'',//支持格式
				inputFileName:''	//选择附件后赋值标签的name
			});
		});
	}
	//edit:can 工作汇报-》日志 -》费用报销-》新增
	globalWebUploadType='';
	return false;

}

function setUpload_att (){
	var myatt_id=0;
	var myatt_moduel='WordReport';
	var is_type = 0;
	var popupobj=CrmPopup.getPopupObj("lastprev");
	if(popupobj!=undefined && popupobj.divid!=undefined){
		var popupobjid = "#"+popupobj.divid+' ';
	}else{
		var popupobjid = '';
	}
	UploadBind(popupobjid+'#multiple_att',new function(){
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
				RemindsMsg("","LdPopWidth400px","","yes","yes",Afinstpasdne3M +'\n'+file.name);
				ld(popupobjid+'#multiple_att').uploadify('stop');
				ld(popupobjid+'#multiple_att').uploadify('cancel');
				ld(popupobjid+'#multiple_att').onCancel(file);
				return false;
			}
		},
			this.start = function(file){
				if(is_type == 1){
					myatt_id = document.getElementById("current_userid").value;
					var str = {'myatt_id':myatt_id,'myatt_moduel':myatt_moduel,'uploadtype':'uploadatt'};
					ld(popupobjid+'#multiple_att').uploadify('settings','method','post');
					ld(popupobjid+'#multiple_att').uploadify('settings','formData',str);
				}
			},
			this.success = function(file, data, response){
				if(empty(data)) return false;
				var restobj = eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);
				if(empty(restobj.record)) return false;
				var tag = 'sendLog';
				ld(popupobjid+'#'+tag+'UploadAtt ul').append('<li record="'+restobj.record+'"><img alt="'+restobj.name+'" src="themes/softed/images/file.png"><span class="upload-attname">'+restobj.name.substring(0,30)+'<br/><span class="remove-h"> 取消</span></span></li>');
				ld(popupobjid+'#'+tag+'UploadAtt').css('display','');
				//绑定移入显示删除标志事件
				ld(popupobjid+'#'+tag+'UploadAtt ul li').on('mouseenter',function(){
					//alert('here 1');
					ld(this).find('span.remove-h').css('display','inline');
				});
				//绑定移出隐藏删除标志事件
				ld(popupobjid+'#'+tag+'UploadAtt ul li').on('mouseleave',function(){
					ld(this).find('span.remove-h').css('display','none');
				});
				//绑定图片删除事件
				ld(popupobjid+'#'+tag+'UploadAtt ul li span.remove-h').on('click',function(){
					var record = ld(this).parent().parent().attr('record');
					ld(popupobjid+'#'+tag+'UploadAtt ul li[record='+record+']').remove();
					if(0 == ld(popupobjid+'#'+tag+'UploadAtt ul li').length){
						ld(popupobjid+'#'+tag+'UploadAtt').css('display','none');
					}
					return false;
				});
			},
			this.end = function(){
				ld(popupobjid+'#multiple_att').addClass('multiple-div');
			}
	});
}

/**
 * flash上传图片加载事件集成方法
 * @author Tujt 2015-02-10
 */
function UploadBind(ids,callback){
	return false;
	//getJsScript('uploaddify/jquery.uploadify.min.js', function () {
	var maxfilesize = 100 * 1024 * 1024;
	ld(ids).uploadify({
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
	//})
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
		//chj 2021/6/17 44357: PC端-工作汇报，点击 @ 之后，选人弹出层无法拖动
		//if(box.getAttribute('id')!='sendLogsmownerDiv'){
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
		//}
	}
	if(!dClass || !dClass.length) return false;
	clslen = dClass.length;var cls,clslock
	for(var i=0; i<clslen; i++){
		cls = dClass[i];
		dClass[i].onclick = function(){
			if('' != cls.getAttribute('lock')){
				clslock = cls.getAttribute('lock');
				if('lock' == clslock){
					puyoungJS_DialogBox.unblock();
				}else if(document.getElementById(clslock) != undefined){
					document.getElementById(clslock).style.display = 'none';
				}
			}
			box.style.display = 'none';
			ld(".ui-mask").css('display','none');
		};
	}
}

function FindEventaa(obj,tagName,event){
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
	if(ld(obj) != undefined){
		if('addtouch' == ld(obj).attr('class')){

		}
	}
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
		//topSide -= 65;
		//leftSide -= 60;
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
function FindEvent(obj,tagName,event){
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var a = ld('.Edit_box .Top_menu').height(),
		b = ld('#sendTxt').height();
	var position_attachment=false;//是否根据鼠标位置显示
	switch(ld(obj).attr('class')){
		case 'selectbar':
		case 'addemojicookie':
		case 'addtouch':
			position_attachment=true;
			break;
	}
	if(position_attachment){
		var cur_left = 79;
		if(cur_pageLeftType=='Open') {
			cur_left = 180;
		}
		if(ld(obj).attr('class') == 'selectbar'){
			var c = 5+16+35+10+10,//最上面padding-top，选中图标，列别选择，点评margin-top，点评padding-top
				d = ld('#sendLogFoot .sendLog').height(),
				e = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
			if(cur_panel == 'cocmd'){
				d = ld('#sendLogFoot .cocmd').height()-38;
			}
			var crmpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
			if(!empty(crmpopupobj)){
				var scrollTop = ld('#'+crmpopupobj.divid+' .main_grid .main_grid_box').get(0).scrollTop-135;
			}else {
				var scrollTop = ld('#container .main_grid .main_grid_box').get(0).scrollTop - 45;
			}
			ld('#sendLogsmownerDiv').css('top', topSide-40-d-scrollTop+'px').css('left', leftSide-cur_left+'px');
		}
		if(ld(obj).attr('class') == 'addemojicookie'){
			var c = 5+16+35,//最上面padding-top，选中图标，列别选择
				d = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
			ld('#sendemojicookieDiv').css('top', topSide-40-d+'px').css('left', leftSide-cur_left+'px');
		}
		if(ld(obj).attr('class') == 'addtouch'){
			var c = 5+16+35,//最上面padding-top，选中图标，列别选择
				d = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
			ld('#sendLogsmownerDiv').css('top', topSide-40-d+'px').css('left', leftSide-cur_left+'px');
		}
	}
	else{
		var cur_left = 79;
		if(cur_pageLeftType=='Open') {
			cur_left = 180;
		}
		// 共有几个同事弹出
		if(ld(obj).attr('tag') == 'fstip'){
			var DivCTableObj = ld(obj).parents("div .DivCTable");
			if(DivCTableObj.length > 0){
				var c = event.clientY;
				ld('#fs-tip').css('top',c+20+'px').css('left', leftSide-cur_left-120+'px');
			}else{
				var c = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
				ld('#fs-tip').css('top',topSide-40-c+'px').css('left', leftSide-cur_left+'px');
			}
			//ld('#fs-tip').css('top',topSide-40-c+'px').css('left', leftSide-cur_left+'px');
		}
		// 回复-添加表情
		if(ld(obj).attr('tag') == 'addemojicookie_reply'){
			var c = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
			ld('#sendemojicookieDiv').css('top',topSide-40-c+'px').css('left', leftSide-cur_left+'px');
		}
		// 回复-添加提到
		if(ld(obj).attr('tag') == 'addtouch_reply'){
			var c = ld('.wrapper-panel-inner .main_grid_box').scrollTop();
			ld('#sendLogsmownerDiv').css('top',topSide-40-c+'px').css('left', leftSide-cur_left+'px');
		}
	}
}

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
	//document.getElementById('coordinationStatus').style.display = '';
	//0052396	zxm 20230601 点击OA表单的工作汇报，页面会有两个加载齿轮(BUG0054890 )
	ldAjaxHtml('index.php',data,function (ajaxhtml){
		DelProgressObjs();
		callback(trim(ajaxhtml));
	})
}

function delete_log(){
	window.open("index.php?pageto_module=CooperativeWork&pageto_action=index&massdelete=true");
}

//工作协同发日志、微博、任务抄送范围增加记住最近的设置
var getSendLogCcrange = function(cur_panel,cur_panel_tag){
	var tmp_cur_panel = cur_panel;
	if(ld('#stream-hsent-title') != undefined){
		ld('#stream-hsent-title > li > a').each(function(){
			var _class = ld(this).attr('class');
			var div_tag = 'sendLogFoot > div[tag=ccrange]';
			if(_class != undefined && _class == 'curr'){
				if(empty(cur_panel)){
					cur_panel = ld(this).attr('cont');
				}
				if(!empty(cur_panel)){
					var urlstring = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex';
					urlstring += '&method=getLatelyScope&cur_panel='+cur_panel+'&cur_panel_tag='+cur_panel_tag;
					ld('#rptContentLoading').show()
					ldAjax(urlstring,'',function (data) {
						DelProgressObjs();
						if (data.code == 1){
							ld('#download_permit').val(data.result.download_permit);
							ld('#preview_permit').val(data.result.preview_permit);

							//固定点评人
							var reuser = data.result.reuser;
							if (reuser != undefined && !empty(reuser.userid)) {
								var reuser_userid = reuser.userid;
								var reuser_last_name = reuser.last_name;
								ld('[name=reuser_bar_button]').css('display', 'none');
								var reuser_html = '<li emptype="p" userid="' + reuser_userid + '">\n' +
									'<span class="item-name">' + reuser_last_name + '</span>' +
									' </li>';
								ld('[name=reuser_bar_list]').html(reuser_html);
								ld('#sendLogFoot > div[tag=reader] div.selectbar *').unbind('click');
							} else {
								if (reuser != undefined) {
									ld('[name=reuser_bar_list]').html('');
								} else {
									var reuser_userid = ld('[name=reuserid]').val();
									var reuser_last_name = ld('[name=reusername]').val();
									var reuser_html = '<li emptype="p" userid="' + reuser_userid + '">\n' +
										'<span class="item-name">' + reuser_last_name + '</span><span class="remove-h">×</span>\n' +
										' </li>';
									ld('[name=reuser_bar_list]').html(reuser_html);
								}
								ld('[name=reuser_bar_button]').css('display', '');
								ld('#sendLogFoot > div[tag=reader] div.selectbar *').unbind('click').bind('click', function (event) {
									setReaderEvent(event);
								});
								ld('#sendLogFoot > div[tag=reader] ul.reader-bar-list .remove-h').unbind('click').click(function(){
									ld(this).parent().remove();
									return false;
								});
							}

							//最小抄送范围
							var ccuser = data.result.ccuser;
							ld('#'+div_tag+' ul.reader-bar-list').empty();
							ld.each(ccuser,function(index,userobj){
								var disable = userobj.disable;
								var ccuser_html = '';
								if (disable == 'yes'){
									ccuser_html = '<li userid="'+userobj.userid+'" disabled><span class="item-name">'+userobj.last_name+'</span></li>';
								}else {
									ccuser_html = '<li userid="'+userobj.userid+'"><span class="item-name">'+userobj.last_name+'</span><span class="remove-h">×</span></li>';
								}
								ld('#'+div_tag+' ul.reader-bar-list').append(ccuser_html);
								//绑定删除事件
								ld('#'+div_tag+' ul.reader-bar-list li[userid='+userobj.userid+'] .remove-h').unbind('click').click(function(){
									var liuserid = ld(this).parent().attr('userid');
									ld('#'+div_tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
									return false;
								});
							});

							current_date = data.result.serverNowDate;// 当前服务器时间
							weekStart = data.result.weekStart;// 本周周一
							weekEnd = data.result.weekEnd;// 本周周日
							MonthStart = data.result.MonthStart;// 本月第一天
							MonthEnd = data.result.MonthEnd;// 本月最后一天
							if (data.result.reportDate != undefined){
								var reportDate = data.result.reportDate;
								editDate = reportDate.editDate;//汇报日期是否可选
								if(reportDate.minDate != undefined && reportDate.maxDate != undefined){
									minDate = reportDate.minDate;//汇报日期的最小日期
									maxDate = reportDate.maxDate;//汇报日期的最大日期
								}
							}
							if (!empty(tmp_cur_panel)){
								setPanelShow();
							}
						}
						ld('#rptContentLoading').hide();
					})
				}
			}
		});
	}
}

function  setWorkReportText(type)
{
	var saveobj = ld('[name=stream_text_save]')
	var cancelobj = ld('[name=stream_text_cancel]')
	var settingobj = ld('[name=stream_text_set]')
	var textobj = ld('[name=stream_text]');
	if (type == 'edit'){
		var content = textobj.text();
		var html = '<textarea class="ld-textarea-inner" name="stream_text" text="'+content+'">'+content+'</textarea>'
		textobj.replaceWith(html);
		saveobj.css('display','');
		cancelobj.css('display','');
		settingobj.css('display','none');
	}else if (type == 'save'){
		var content = textobj.val().trim();
		var html = '<p name="stream_text" >'+content+'</p>'
		textobj.replaceWith(html);
		saveobj.css('display','none');
		cancelobj.css('display','none');
		var url = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=saveReportShow&mode=savetext&fieldlabel='+encodeURIComponent(content)+'&labelbol=COOPERATIVEWORKTITLE';
		ldAjaxNoProgress(url,'',function (data) {
			if (data.code == 1){
			}
		});
	}else {
		var content = textobj.attr('text');
		var html = '<p name="stream_text" >'+content+'</p>'
		textobj.replaceWith(html);
		saveobj.css('display','none');
		cancelobj.css('display','none');
	}
}


// ls 2021-10-20 【1002089】工作汇报，工作类别增加编辑功能
//编辑、取消
function editWorkReportType(rowid,mode) {
	if(mode == 'edit'){    //编辑
		ld('#span_type_'+rowid).hide();
		ld('#div_type_'+rowid).show();
	}else{  //取消
		ld('#span_type_'+rowid).show();
		ld('#div_type_'+rowid).hide();
		//取消时将input value值还原
		ld('#div_type_'+rowid+' input').attr('value',ld('#span_type_'+rowid).text());
	}
}
//编辑保存
function saveWorkReportType(rowid,type,labelbol) {
	var fieldlabel = ld('#div_type_'+rowid+' input').val().trim();//eg: type：weibo fieldlabel：微博 labelbol：BLOG

	var popupobj = CrmPopup.getPopupObj("last");
	document.getElementById(popupobj.divid+'_imgclose').onclick=function()
	{
		window.location.reload();
	};

	ld.ajax({
		url: 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=saveReportShow&mode=savetype&type='+type+'&fieldlabel='+fieldlabel+'&labelbol='+labelbol,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				ld('#span_type_'+rowid).text(fieldlabel);
				ld('#div_type_'+rowid+' input').attr('value',fieldlabel);
				ld('#span_type_'+rowid).show();
				ld('#div_type_'+rowid).hide();
			}
			else
			{
				editWorkReportType(rowid,'cancel');//异常情况恢复原值
				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
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
		success: function(data){
			if(data.code==1){
			}
			else{
				// gxj 230712 BUG0069285 工作汇报设置弹窗中，“是否启用”列修改为按钮样式，操作列去掉停用操作按钮
				obj.checked=true;
				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
			}
		}
	});
}

//暂存获取
function getWorkReportTextarea(){
	if(cur_panel_tag == ''){
		cur_panel_tag = ld('#cur_panel_tag').val();
	}
	if (cur_panel_tag && (cur_panel_tag == 'day' || cur_panel_tag == 'week' || cur_panel_tag == 'month')){
		var saleskit_con = ld('[name=sendLog] [name=saleskit_'+cur_panel_tag+']');
		var saleskit_html = '<textarea name="'+saleskit_con.attr('name')+'" area="'+saleskit_con.attr('area')+'" style="height:50px;overflow-y:hidden;width: 100%;" is_mandatory="'+saleskit_con.attr('is_mandatory')+'" defaultvalue="'+saleskit_con.attr('defaultvalue')+'"></textarea>'
		saleskit_con.replaceWith(saleskit_html);
		saleskit_con.autosize();
		ld('#saleskit_showtype').val('text');
		ld('#saleskit_listinfo').val('');
	}
	var current_userid = ld('#current_userid').val();
	var savetype = 1;
	if('sendLog' == cur_panel){
		var typeobj = {'day':1,'week':2,'month':3};
		savetype = typeobj[ld('#stream-hsent-title [class=curr]').attr('tag')];
	}
	var sendLogObj = ld('#sendLog div[entitytype='+cur_panel+'] div[type=worktype_'+savetype+']');
	ld(sendLogObj).find('textarea').each(function() {
		var storage_name = ld(this).attr('name');
		var key = cur_panel_tag+'_'+current_userid+'_'+storage_name;
		var storage_value = localStorage.getItem(key);
		if(storage_value && storage_value != ''){
			ld(this).val(storage_value);
		}
	});
}

function initWordReportLeftBtn(){
	var all_str = ld('.ConSwitch ul').html();
	//左侧菜单
	ld('.work-nav-inner li a').click(function(){
		var choose_tag = ld(this).attr('tag');
		cur_left_location = choose_tag;
		//alert(choose_tag);
		if(choose_tag == 'myself' || choose_tag == 'mymsg'){
			ld(this).parent().next().toggle();
			if (ld(this).parent().hasClass('expand')) {
				ld(this).parent().removeClass('expand');
			}
			else{
				ld(this).parent().addClass('expand');
			}
		}
		else{

			ld('.work-nav-inner li').each(function(){
				ld(this).removeClass('cur-icon');
			});
			ld(this).parent().addClass('cur-icon');

			var ulstring = '';
			if(choose_tag == 'all'){
				ulstring = all_str;
			}
			else if(choose_tag == '@me'){
				ulstring += "<li class='linebg' tag='received'><a class='curr' href='javascript:void(0);' tag='1'>@"+arrJsPopLabel["mywork"]+"</a></li>";//@我得工作
				ulstring += "<li class='' tag='initiated'><a class='' href='javascript:void(0);' tag='2'>@"+arrJsPopLabel["MYREPLY"]+"</a></li>";//@我的回复
			}else if(choose_tag == 'myreply' || choose_tag == 'mypraise'){
				ulstring += "<li class='linebg' tag='received'><a class='curr' href='javascript:void(0);' tag='1'>"+arrJsPopLabel["IRECEIVED"]+"</a></li>";//我收到的
				ulstring += "<li class='' tag='initiated'><a class='' href='javascript:void(0);' tag='2'>"+arrJsPopLabel["IINITIATED"]+"</a></li>";//我发起的
			}
			else{
				ulstring += "<li class='' tag='initiated'><a class='' href='javascript:void(0);' tag='4'>"+arrJsPopLabel["IINITIATED"]+"</a></li>";//我发起的
				// @edit:dong @date:2020/08/03 @reason: tapd 1000973 工作汇报，我的工作台，微博/日志/周计划/月计划/任务界面，默认“我相关的”页签
				if(choose_tag == 'weibo' ||choose_tag == 'logday' || choose_tag == 'logweek' || choose_tag == 'logmonth' ||choose_tag == 'cocmd'){
					ulstring += "<li class='linebg' tag='related'><a class='curr' href='javascript:void(0);' tag='7'>"+arrJsPopLabel["IRELATED"]+"</a></li>";//我相关的
				}
				else{
					ulstring += "<li class='' tag='initiated'><a class='' href='javascript:void(0);' tag='7'>"+arrJsPopLabel["IRELATED"]+"</a></li>";//我相关的
				}
				// ulstring += "<li class='' tag='related'><a class='' href='javascript:void(0);' tag='7'>"+arrJsPopLabel["IRELATED"]+"</a></li>";//我相关的
				if(choose_tag == 'logday' || choose_tag == 'logweek' || choose_tag == 'logmonth'){
					ulstring += "<li class='' tag='unreviewed'><a class='' href='javascript:void(0);' tag='2'>"+arrJsPopLabel["UNREVIEWED"]+"</a></li>";//待点评的
					ulstring += "<li class='' tag='reviewed'><a class='' href='javascript:void(0);' tag='3'>"+arrJsPopLabel["REVIEWED"]+"</a></li>";//已点评的
				}
				if(choose_tag == 'cocmd'){
					ulstring += "<li class='' tag='unexecuted'><a class='' href='javascript:void(0);' tag='2'>"+arrJsPopLabel["UNEXECUTED"]+"</a></li>";//待执行的
					ulstring += "<li class='' tag='executed'><a class='' href='javascript:void(0);' tag='3'>"+arrJsPopLabel["EXECUTEDNEW"]+"</a></li>";//已执行的
				}
			}
			ld('.ConSwitch ul').html(ulstring);
			bigcategory = '10';	//默认我相关的
			if(choose_tag == 'all'){
				//smallcategory = 'all';
			}
			// @edit:dong @date:2020/08/03 @reason: tapd 1000973 工作汇报，我的工作台，微博/日志/周计划/月计划/任务界面，默认“我相关的”页签
			else if(choose_tag == 'weibo' ||choose_tag == 'logday' || choose_tag == 'logweek' || choose_tag == 'logmonth' ||choose_tag == 'cocmd'){
				//smallcategory = 'initiated';
				bigcategory = 7;	//我相关的
			}
				// else if(choose_tag == 'logday' || choose_tag == 'logweek' || choose_tag == 'logmonth'){
				// 	//smallcategory = 'unreviewed';
				// 	bigcategory = 2;	//待处理
			// }
			else if(choose_tag == 'cocmd'){
				//smallcategory = 'unexecuted';
			}
			else if(choose_tag == '@me' || choose_tag == 'myreply' || choose_tag == 'mypraise'){
				//smallcategory = 'received';
			}
			//fun_search('ConSwitchMenu');
			var urlstring = '&smallcategory='+choose_tag+'&bigcategory='+bigcategory;
			if(choose_tag == '@me'){
				urlstring += '&leftcategory=me';
			}else if(choose_tag == 'mypraise'){
				urlstring += '&leftcategory=mywork_praise';
			}else if(choose_tag == 'myreply'){
				urlstring += '&leftcategory=mywork_reply';
			}
			//alert(urlstring);
			ld('.pubDetialC').html('<div id="worklist_page_1"></div>');
			getWorkList(urlstring,function(){
			});
			//if(choose_tag != 'all'){
			//一级导航切换后 点击事件
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
				if(bigcategory == '5'){
					bigcategory = '1';
					var datecategory_value;
					var datecategory = ld('.w-filter-select .value').attr('data-value');
					if(datecategory == 'custom'){
						datecategory_value = ld('.w-filter-select .value').html();
					}
					//发起人
					var sponsor = ld('#sponsor_value').val();
					//关键字查询
					var searchcontent =  ld('.w-filter-wrapper .filter-keyword').val();
					smallcategory = ld(this).parent().attr('tag');
					var urlstring = 'left_location='+cur_left_location+'&smallcategory='+smallcategory+'&bigcategory='+bigcategory+'&datecategory='+datecategory+'&datecategory_value='+datecategory_value;
					urlstring += '&sponsor='+sponsor;
					if(ld('#massdelete') != undefined && ld('#massdelete').val() == 'true'){
						urlstring += '&massdelete=true';
					}
					if(ld('#report_user_id') != undefined && ld('#report_user_id').val() > 0){
						urlstring += '&report_user_id='+ld('#report_user_id').val();
					}
					if(cur_left_location == 'all' && ViewallCooperativeWork != 'no'){
						urlstring+="&ViewallCooperativeWork=yes";//查看全部的界面标识（yes：是)
					}
					else{
						urlstring+="&ViewallCooperativeWork=no";//查看全部的界面标识（yes：是)
					}
					//smallcategory = ld(this).parent().attr('tag');
				}else{
					var urlstring = '&smallcategory='+choose_tag+'&bigcategory='+bigcategory;
					if(choose_tag == '@me'){
						if(bigcategory == 1){
							urlstring += '&leftcategory=me';
						}
						else if(bigcategory == 2){
							//edit: xll 2023/08/01 BUG0065539 kfbcrm -工作汇报-我的消息内@我的，显示没有内容
							urlstring += '&leftcategory=atmyreply';
						}
					}else if(choose_tag == 'mypraise'){	//我的赞
						if(bigcategory == 1){
							urlstring += '&leftcategory=mywork_praise';	//我收到的
						}else{
							urlstring += '&leftcategory=mypraise';	//我发起的
						}
					}else if(choose_tag == 'myreply'){	//我的回复
						if(bigcategory == 1){
							urlstring += '&leftcategory=mywork_reply';	//我收到的
						}else{
							urlstring += '&leftcategory=myreply';	//我发起的
						}
					}
				}
				ld('.ConSwitch ul li a').each(function(){
					if(bigcategory == ld(this).attr('tag')){
						ld(this).attr('class','curr');
					}else{
						ld(this).attr('class','');
					}
				});

				getWorkList(urlstring,function(){

				});
				//leftcategory
				//fun_search('ConSwitchMenu');
			});
			//}


		}
	});
}
//加载日历
var myDate = new Date();
var chooseDate = '';
var workcanceldar = new Array();
var last_click_month = '';
var calendar_date = '';
var calendar_display_type = 'month';
function intStart(){
	//星期

	var textTopWeeks = '';
	var textTop = ["一", "二", "三", "四", "五", "六", "日"];
	if(current_language=="en"){
		textTop = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
	}
	for(i=0;i<textTop.length;i++){
		textTopWeeks += "<div class='wh_content_item'>";
		textTopWeeks += "<div class='wh_top_tag'>"+textTop[i]+"</div>";
		textTopWeeks += "</div>";
	}

	ld(' .wh_content_weeks').html(textTopWeeks);

	//加载日历js
	getJsScript('include/js/modules/Home/calendar.js',function(){
		getDataList();
	});
	// 上月
	ld(' .wh_top_changge li:first-child').unbind('click');
	ld(' .wh_top_changge li:first-child').click(function(){
		myDate = dateFormat(calendar_date);
		myDate = getOtherMonth(myDate, "preMonth");
		workcanceldar = new Array();
		chooseDate = '';
		calendar_date= '';
		// calendar_display_type = 'month';
		last_click_month = '';
		getDataList();
	});
	// 下月
	ld(' .wh_top_changge li:last-child').unbind('click');
	ld(' .wh_top_changge li:last-child').click(function(){
		myDate = dateFormat(calendar_date);
		myDate = getOtherMonth(myDate, "nextMonth");
		workcanceldar = new Array();
		chooseDate = '';
		calendar_date= '';
		// calendar_display_type = 'month';
		last_click_month = '';
		getDataList();
	});
}

/***
 * edit:zhouxiaomei
 * 2020-0910
 * 获取日历列表 bug修改 日期点击事件不生效，日期样式不正确等问题的修改
 * 后续需求新增：
 * content:ljj 20240110 XUQIU1002379 看板组件的长宽高适配，针对日程管理组件在工作台显示（直接借鉴纷享）
 * node:新增calendar_display_type(日历显示形式为月month或周week--收起展开)  calendar_date(今日或选中日期 date形式)
 */
function getDataList(){
	// 月份数组
	var month_en = new Array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	//获取之前选中的日期date 默认为今天
	if (calendar_date != ''){
		myDate = calendar_date;
	}else {
		calendar_date =myDate;
	}
	//当前日期
	var cur_year = myDate.getFullYear();
	var cur_month = myDate.getMonth() + 1;
	var cur_date = myDate.getDate();//@edit:zhouxiaomei,2020-09-10,reason:获取当前日期
	if(current_language=="en"){
		var dateTop = month_en[cur_month-1] +' '+ cur_year;
	}else{
		if(cur_month < 10)
			cur_month = '0'+cur_month;
		var dateTop = cur_year + '年' + cur_month + '月';
	}
	ld(' .wh_content_li').html(dateTop);
	ld(' .wh_content_li').attr('data-yearmonth',cur_year + '年' + cur_month + '月');
	chooseDateClick(dateTop,cur_date);
	//获取日期数据
	if(calendar_display_type == "month"){//获取当前月所有日期
		var dayArr = getMonthList(myDate);
	}else if (calendar_display_type == "week"){//获取当前选中日期的那周所有日期
		var dayArr = getWeekList(myDate);
	}
	var textTopDays = '';
	for(var  i=0;i<dayArr.length;i++){
		textTopDays += "<div class='wh_content_item' tag='"+ dayArr[i]['date'] +"' otherMonth='"+ dayArr[i]['otherMonth'] +"'>";
		let days_class = '';
		let tag = '';
		let choose_class = '';
		if(dayArr[i]['otherMonth'] != 'nowMonth'){
			days_class = 'wh_other_dayhide';
		}else{
			tag = 'tag="'+dayArr[i]['id']+'"';
		}
		if(dayArr[i]['isToday']){
			days_class = 'wh_isToday';
		}
		if (calendar_date != '' ){
			const date = dateFormat(calendar_date);
			if(dayArr[i]['date'] == date){
				if (days_class != ''){
					choose_class = ' wh_chose_day';
				}else {
					choose_class = 'wh_chose_day';
				}
			}
		}
		textTopDays += "<div "+tag+" class='wh_item_date "+ days_class + choose_class +"'>"+dayArr[i]['id']+"</div>";
		textTopDays += "</div>";
	}
	ld(' .wh_content_days').html(textTopDays);
	// 选择日期
	ld(' .wh_content_days .wh_content_item').click(function(){
		var  otherMonth = ld(this).attr('otherMonth');
		ld(' .wh_item_date').removeClass('wh_chose_day');
		ld(this).find(' .wh_item_date').addClass('wh_chose_day');
		var choose_date = ld(this).find(' .wh_item_date').parent().attr('tag');
		calendar_date = new Date(choose_date);
		if (otherMonth === "nowMonth") {
			let dateNum = ld(this).find(' .wh_item_date').attr('tag')
			chooseDateClick(dateTop,dateNum);
		}else if(otherMonth === "preMonth"){
			workcanceldar = new Array();
			chooseDate = '';
			last_click_month = '';
			getDataList();
		}else{
			workcanceldar = new Array();
			chooseDate = '';
			last_click_month = '';
			getDataList();
		}
	});
	//展开、收起
	var show_value=arrJsPopLabel["EXPANSION"];
	var hide_value=arrJsPopLabel["COLLAPSE"];
	var hideAndshow ='<div class="hide-show-div">';
	hideAndshow +='<a name="hide-show-content" style="display: flex">';
	hideAndshow +='<input class="hide-show-input" name="hide-show-input" type="text" timetype="'+calendar_display_type+'" readonly';
	if(calendar_display_type == 'week'){
		hideAndshow +=' value="'+show_value+'">';
		hideAndshow +='<i name="hide-show-jiantou" class="hide-show-month"></i>';
	}else if (calendar_display_type == 'month'){
		hideAndshow +=' value="'+hide_value+'">';
		hideAndshow +='<i name="hide-show-jiantou" class="hide-show-week"></i>';
	}
	hideAndshow +='</a></div>';
	ld('[name=click_hide_show]').html(hideAndshow);
	//展开、收起 点击事件
	ld('[name=hide-show-content]').unbind('click').bind('click',function () {
		var timetype=ld('[name=hide-show-input]').attr('timetype');
		if(timetype == 'month'){
			ld('[name=hide-show-jiantou]').addClass('hide-show-week');
			calendar_display_type='week';
			ld('[name=hide-show-input]').attr('timetype',calendar_display_type);
			ld('[name=hide-show-input]').attr('value',hide_value);
			getDataList();
		}else if (timetype == 'week'){
			ld('[name=hide-show-jiantou]').removeClass('hide-show-week');
			calendar_display_type='month';
			ld('[name=hide-show-input]').attr('timetype',calendar_display_type);
			ld('[name=hide-show-input]').attr('value',show_value);
			getDataList();
		}
	});
}

/***
 * @author zhouxiaomei
 * @date 2020-09-10
 * 点击日期 右侧展示当天日程 未点击则默认当日
 * @param chooseDate
 * @param dateNum
 */
function chooseDateClick(dateTop,dateNum)
{
	let url = "index.php?module=Calendar&action=CalendarAjax&file=getWorkCanceldar&date="+dateTop;
	ldAjaxNoProgress(url,"",function(data){
		if(data.code=='-1')
			return '';

		let code = data.code;
		let content = data.result.content;
		let schedule = content[dateNum];
		//渲染日历样式
		if(code==1 && content!=undefined && content != ''){
			ld.each(content,function(index,item){
				if(ld(this).attr('othermonth') != 'preMonth' && ld(this).attr('othermonth') != 'nextMonth') {
					ld(' .wh_content_days  .wh_content_item [tag=' + index + ']').html(index + "<i class='wh_top_tag_spot'></i>");
				}
			})
		}
		// 渲染当日日程列表
		if(code == 1 && schedule !=undefined){
			let calendar_content_list = '<p class="line"></p><ul style="width:100%;overflow:hidden;text-align: left;padding-bottom:36px;">';
			ld.each(schedule,function(date,canceldarinfo){
				calendar_content_list += '<li class="schedule-item" style="display: flex;">';
				calendar_content_list += '<div class="schedule-item-div">'+arrJsPopLabel['Schedule']+'</div>';
				calendar_content_list += '<p class="content" style="padding-left: 10px" module="Calendar" record="'+canceldarinfo.activityid+'" onclick="ListLinkClick(ld(this),event)" lasturl="">'+canceldarinfo.start_date+'-'+canceldarinfo.end_date+'&emsp;'+canceldarinfo.subject+'</p>';
				calendar_content_list += '</li>';
			})
			calendar_content_list += '</ul>';
			ld(' .calendar-content-list').html(calendar_content_list);
		}else{
			let list_notcontent = '<div style="text-align: center;color: #666;margin: 5px 0;">'+arrJsPopLabel['NOCONTENT']+'</div>';
			ld(' .calendar-content-list').html(list_notcontent);
		}
	})
}
//打开设置组件弹窗
function setbriefcomponent(obj){
	getJsScript('include/js/modules/Home/EditHomeStuffDetail.js', function () {
		var params = {
			surl : 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkBriefReport&mode=edit',
			params_data : '',
			delete_str : arrJsPopLabel['CANCELBRIEFREPORTSETCHECK'],
			popuptype : 'WorkBriefReport'
		};
		EditHomeStuffDetail(params,function (crmPopupobj,data) {
			getJsScript('include/js/modules/Home/workBriefReport.js', function () {
				if(data.code == 1){
					crmPopupobj.moduleArr=data.result.moduleArr;
					crmPopupobj.all_list=data.result.all_list;
					if (empty(data.result.select_list)){
						crmPopupobj.select_list = new Object;
					}else {
						crmPopupobj.select_list=data.result.select_list;
					}
					crmPopupobj.old_select_list = crmPopupobj.select_list;
					crmPopupobj.custom_maxid=data.result.custom_maxid;
					crmPopupobj.custom_count=data.result.custom_count;
					crmPopupobj.create_list= new Object;
					crmPopupobj.delete_list= new Object;
					crmPopupobj.newCustomInfo=data.result.newCustomInfo;
					crmPopupobj.languageType=data.result.languageType;
					crmPopupobj.briefReportLayout=data.result.briefReportLayout;
					var cls_workBriefReportobj = new workBriefReport();
					cls_workBriefReportobj.setEvent();
					crmPopupobj.workBriefReport = cls_workBriefReportobj;
				}
			});
		});
	})


}


/*
* editor:ljj
* time:20231117
* reason:XUQIU1002166
* content:工作汇报模板定制增加“自动引用工作内容”（宋清华）
* node:1.只有日志、周计划、月计划 才能引用
* */
function getRelatedWorkContent(type){
	if (cur_panel_tag == 'cocmd' || cur_panel_tag == 'weibo'){
		return false;
	}
	var url='index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkReportIndex&method=getRelatedModuleField&reporttype='+cur_panel_tag;
	ldAjaxNoProgress(url,"",function (data){
		ld.each(data,function(index,value){
			var fieldnameobj=ld('#sendLog div[tag=workfield] div[entitytype='+cur_panel+'] div[type=worktype_'+type+']').find('[name='+value.name+']');
			if (empty(value.content) || fieldnameobj.length == 0){
				return false;
			}
			var content=value.content.replace(/<br>/g,'\n');
			var tmpvalue=fieldnameobj.val();

			var current_userid = ld('#current_userid').val();
			var key = cur_panel_tag+'_'+current_userid+'_'+value.name;
			var storage_value = localStorage.getItem(key);
			if(!storage_value || empty(storage_value)){
				if (empty(tmpvalue)) {
					fieldnameobj.val(content);
				}else {
					fieldnameobj.val(tmpvalue+'\n'+content);
				}
				var height = fieldnameobj.outerHeight(true);
				var srollHeight = fieldnameobj.get(0).scrollHeight;
				if (srollHeight > 0 && srollHeight > height){
					fieldnameobj.css('height',srollHeight);
				}
			}
			var new_storage_value=fieldnameobj.val();
			localStorage.removeItem(key);
			localStorage.setItem(key, new_storage_value);
		});

	});


}

function saleSkitToListView(obj,event){
	StopEvent(event);
	var module = ld(obj).attr('module');
	var record = ld(obj).attr('record');
	var url = 'index.php?pageto_module='+module+'&pageto_action=index&pageto_record='+record;
	url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,'');
	OpenNewWebTab(url);
}

