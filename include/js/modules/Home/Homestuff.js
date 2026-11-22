/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *******************************************************************************/

//刷新调用事件
function initWidgets(){
	initStuffArr();
	for(var i=0;i<Vt_homePageWidgetInfoList.length;i++)
	{
		loadAllWidgets(Vt_homePageWidgetInfoList[i]);
	}
	ld("#home-content-div").scroll(function() {
		for(var i=0;i<Vt_homePageWidgetInfoList.length;i++)
		{
			loadAllWidgets(Vt_homePageWidgetInfoList[i]);
		}
	});
}

/**
 * this function is used to reload a widgets' content based on its id and type
 * @param {string} stuffid - the widget id
 * @param {string} stufftype - the type of the widget
 * @param {string} data_type 销售指标 zxm 近六个月目标完成情况使用
 */
function loadStuff(stuffid,stufftype,data_type){
	var params = getHomeAllParams();
    var url='index.php?module=Home&action=HomeAjax&file=HomeBlock&homestuffid='+stuffid+'&blockstufftype='+stufftype;
	if(stuffid==112) {
		var boardselect_stage_value = ld('#boardselect_stage_value').val();
		boardselect_stage_value = boardselect_stage_value==undefined?'':boardselect_stage_value;
		url += '&boardselect_stage_value=' + boardselect_stage_value;
	}
    if(loadStuff.param!="")
    {
       
        url+="&"+loadStuff.param;
    }
	//@edit:zhouxiaomei @date:2020-9-7 @reason: 首页增加近6个月销售目标完成情况组件 增加传参销售指标值
    //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘
	//使用ld_NavBar生成组件页签的组件id数组
	var stuffid_arr = ['39','40','101','100','114','118'];
	if(stuffid_arr.includes(stuffid.toString())){
		var popupobj = CrmPopup.getPopupObj("last");
		var CurTabObj;
		if(popupobj.divid != ''){
			CurTabObj = ld('#'+popupobj.divid+' #stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
		} else {
			CurTabObj = ld('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
		}
		var targetid = '';
		if(CurTabObj.length > 0){
			data_type = CurTabObj.attr('data-NavBarName');
			targetid = CurTabObj.attr('data-NavBarId');
			url+="&targetid="+targetid;
		}
		url+="&data_type="+data_type;
	}
	//@edit:zhouxiaomei @date:2020-1205 @reason: 誉帆 排行榜
	if(stuffid==50||stuffid==56){
		url+="&data_type="+data_type;
	}
 	ldAjaxHtml(url,params,function(data){
        loadStuff.param="";
        DelProgressObjs();
        //js报表效果
        //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘
		var newCharArr = ['1','4','5','9','19','40','41','42','44','45','48','49','53','55','57','61','62','63','101','100','102','103','104','105','106','107','112','113','114','115','119'],
			newStuffArr = ['116','117'],
			stuffConJqObj = ld('#stuffcont_'+stuffid);
		stuffid = parseInt(stuffid.toString());
		if(newCharArr.includes(stuffid.toString())){
			var restobj = eval('(' + data + ')') ? eval('(' + data + ')') : JSON.parse(data);
			newChart(stuffid, restobj.result,data_type);
		}
		else if(newStuffArr.includes(stuffid.toString())) {
			data = eval('(' + data + ')') ? eval('(' + data + ')') : JSON.parse(data);
			AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
			LoadStuffClass.showStuff(parseInt(stuffid),stuffConJqObj,data.result);
		}
		else {
			stuffConJqObj.html(data);
			stuffConJqObj.css('height','100%');
			// 日程管理 @edit:zhouxiaomei @date:2020-9-9 @reason: 首页日程管理
			if(stuffid === 43){
				intStart();
				WorkListBind();
				// //屏幕大小变换
				ld(window).resize(function(){
					var div_width = CrmPopup.getClientWidth()-getLeftMenuWidth()-16;
					ld('.widget-content .salekit-list .salekit-item').css('width', parseInt((div_width-28)/count)+'px');
					ld('#MainMatrix [tag=2]').css('width', (div_width/2-13)+'px');
					intStart();
					WorkListBind();
				});
			}
		}
		//视图标签的事件绑定
		//zxm 2021-0322
		home_menu_stuff_bind('stuffcont_'+stuffid);
		//230720 wym BUG0069815 1.改tips 2.鼠标样式变pointer
		var tooltipList = ld('#stuffcont_'+stuffid).find('.sort-tip-items');
		if(tooltipList.length > 0){
			tooltip(tooltipList, {transition: true, time: 200});
		}
		getJsScript('include/js/modules/Home/newChart_class.js', function () {
			if(stuffid !== 43 && stuffid !== 35 && stuffid !== 114&& stuffid !== 118)
				newChart_class.changeStuffHeight(stuffid, 0)
			if(stuffid==118){
				newChart_class.setEvent(stuffid);
			}
		});
	 	ld('#rptContentLoading').hide();
	}) 

}
loadStuff.param="";

/**
 * 使用ld_NavBar生成首页组件页签
 * @author xll
 * @data 2023/10/27
 * @param {StuffInfo} StuffInfo - ld_NavBar的页签事件对象
 * @param {function} callbackfun - 请求回调后且页签设置完成后的回调函数
 * @param {any} callbackOption - 回调函数的唯一参数
 */
function LoadStuffNavBar(StuffInfo,callbackfun,callbackOption){
	var stuffid = StuffInfo.stuffid;
	var stufftype = StuffInfo.stufftype;

	var boardid = 0;
	var editHomeboardPopobj = CrmPopup.getPopupObj("last");
	if(editHomeboardPopobj && editHomeboardPopobj.divid && editHomeboardPopobj.boardtype){
		boardid = ld('#'+editHomeboardPopobj.divid).find('#boardid').val();
	}
	else if(ld('#boardid').length !== 0 && ld('#boardid').val() !== undefined){
		boardid = ld('#boardid').val();
	}
	var url = 'index.php?module=Home&action=HomeAjax&file=HomeBoardStuff_PreHtml';
	var params = '&viewStyle=refresh';
	params = '&getPageTabList=yes';
	params += '&boardid=' + boardid;
	params += '&stuffid=' + stuffid;
	params += '&stufflisttype=' + StuffInfo.stufflisttype;
	params += '&stufftype=' + StuffInfo.stufftype;
	ldAjaxNoProgress(url,params,function (data) {
		LoadStuffNavBar_callback(stuffid,data,stufftype);
		if(data.code==1){
			callbackfun(callbackOption);
		}
	});
}
/**
 * 使用ld_NavBar生成首页组件页签方法中，请求后的回调函数
 * @author xll
 * @data 2023/10/30
 * @param {string|number} stuffid - 组件id
 * @param {Object} data - 返回值
 */
function LoadStuffNavBar_callback (stuffid,data,stufftype) {
	var StuffNavBarList = data.result.NavBarList;
	var Popupobj = CrmPopup.getPopupObj('last');
	if(data.code==-1){
		//页签数据为空 普通成员 没有共享给我目标管理数据，页签为空 不应该显示统计图。显示统计图也是错误的。
		var stuffconObj,stuffcont_labelObj;
		var stuffconSelector = ' #stuff_'+stuffid+' #stuffcont_'+stuffid;
		if(Popupobj && Popupobj.divid && ld('#'+Popupobj.divid + stuffconSelector).length > 0){
			stuffconObj = ld('#'+Popupobj.divid + stuffconSelector);
			stuffcont_labelObj= ld('#'+Popupobj.divid + '#stuffcont_label_'+stuffid);
		}
		else{
			stuffconObj = ld(stuffconSelector);
			stuffcont_labelObj= ld('#stuffcont_label_'+stuffid);
		}


		stuffconObj.css('width','100%').html('<div class="home_nomsg_div padT20" style="height:calc(100% - 55px)">\n' +
			'          <div>\n' +
			'              <img class="icon-empty" alt="'+data.msg+'" src="themes/images/emptyinfo.png">\n' +
			'              <span>'+data.msg+'</span>\n' +
			'          </div>\n' +
			'      </div>');
		stuffcont_labelObj.hide();
		return;
	}
	var LayoutObj;
	var Selector = ' #stuff_'+stuffid+' #sales_target_tab';
	if(Popupobj && Popupobj.divid && ld('#'+Popupobj.divid + Selector).length > 0)
		LayoutObj = ld('#'+Popupobj.divid + Selector);
	else
		LayoutObj = ld(Selector);

	if(typeof ld_NavBar === "undefined"){
		dynamicJsScript['ld_NavBar'] = 0;
	}
	AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
	ld_NavBar.ShowNavBar(LayoutObj.get(0),StuffNavBarList,{
		NavBarSelKey : data.result.NavBarSelKey,
		OnClick : function(evt){
			StuffNavBarClick(stuffid,evt,stufftype);
		},
	});
}


//@edit:zhouxiaomei @date:2020-9-8 @reason: 首页增加近6个月销售目标完成情况组件 销售指标参数不同显示Y轴的不同名称 客户数
function newChart(stuffid, data,data_type){
    if(typeof data_type=='undefined'||data_type==undefined)
    {
        data_type='contractamount';
    }
	var theme = echartTheme;

	//zxm 2021-0308 首页图表更改为echarts图表
	var popupobj = CrmPopup.getPopupObj("last"),
		myChart_jsObj;
	if(popupobj.divid != ''){
		var Selector = ' #preview_stuffcont_'+stuffid;
		//edit : xll 2023/10/27 BUG0074640
		if(ld('#'+popupobj.divid+Selector).length > 0)
			myChart_jsObj = ld('#'+popupobj.divid+Selector).get(0);
		else {
			myChart_jsObj = ld(Selector).get(0);
		}
		myChart = echarts.init(myChart_jsObj,theme);
	}else{
		myChart_jsObj = document.getElementById('stuffcont_'+stuffid);
		var myChart = echarts.init(myChart_jsObj,theme);
	}
	myChart_jsObj.addEventListener("dragenter", function () {
		myChart.resize();
	});
	//edit: xll 编辑看板时进行宽度变化监测，宽度变动则执行resize
	var widthobserver = new ResizeObserver(function (entries, observer) {
		myChart.resize();
	});
	widthobserver.observe(myChart_jsObj);
	//edit: xll 2023/08/28 XUQIU1001645 PC端增加销售龙虎榜
	getJsScript('include/js/modules/Home/newChart_class.js', function () {
			var newChartObj = new newChart_class();
			newChartObj.setData(data);
			var params = { 'data_type': data_type , stuffid : stuffid };
			//使用ld_NavBar生成组件页签的组件id数组，页签来源为目标管理中的目标
			var stuffid_arr = ['39','40','101','114','118'];
			if (stuffid_arr.includes(stuffid.toString())) {
				params.targetid = ld('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur').data('navbarid');
			}
			newChartObj.setParams(params);
			newChartObj.setMychartObj(myChart);
			var option = newChartObj.getOption();

			myChart.clear();
			if (option !== false)
				myChart.setOption(option, true);
			myChart.resize();
			newChartObj.setClick();
		});
	var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
	var element = ld('section.main-content').get(0);
	var observer = new MutationObserver((mutationList) => {
		setHomeBoardWidth();
	})
	observer.observe(element, { attributes: true, attributeFilter: ['style'], attributeOldValue: true })
}
//视图标签的事件绑定
var home_menu_stuff_bind =function(stuffcont_stuffid){
	//标签切换
	ld('#'+stuffcont_stuffid+' .widget-content .tab span').each(function(){
		ld(this).unbind("click").on('click',function(){
			var menu_type = ld(this).attr('data-type');
			ld('#'+stuffcont_stuffid+' .widget-content .tab span').each(function(){
				ld(this).attr('class','tab-item');
			})
			ld(this).attr('class','tab-item cur');
			ld('#'+stuffcont_stuffid+' .widget-content .deal-list .deal-total').each(function(){
				var tag = ld(this).attr('tag');
				if(tag == menu_type){
					ld(this).show();
				}else{
					ld(this).hide();
				}
			});
			ld('#'+stuffcont_stuffid+' .widget-content .deal-list .deal-item').each(function(){
				var tag = ld(this).attr('tag');
				if(tag == menu_type){
					ld(this).show();
				}else{
					ld(this).hide();
				}
			});
			
		})
		
	})
}
var startindex=0;
 
 
function loadAllWidgets(widgetInfoList){
	//使用ld_NavBar生成页签的数组
	var stuffid_arr = ['39','40','101','100','114','118'];
    if(widgetInfoList==undefined || widgetInfoList.length<=0)
    return ;
    var plateindex=homeplatestuff_arr[widgetInfoList[0].plateindex];
	for(plateindex; plateindex<widgetInfoList.length;plateindex++) {
	   var index=plateindex;

		var widgetId = widgetInfoList[index].widgetId;
        
		var widgetType = widgetInfoList[index].widgetType;
		var reporttype = widgetInfoList[index].report_type;
		var chart_type = widgetInfoList[index].chart_type;
         
		//@edit:zhouxiaomei @date:2020-9-10 @reason:近6个月目标完成情况 选项切换的时候销售指标的参数需要获取传值
		let sales_target_tab = '';
		if(widgetId == 40){
			sales_target_tab = ld('#sales_target_tab').find('.cur').attr('data-type');
		}

		if(widgetType=='echart' || widgetInfoList[index].widgetlistType == 'customreport'|| widgetType=='customtable' ||widgetInfoList[index].widgetlistType == 'customtable'){
			if(widgetType=='echart' || widgetInfoList[index].widgetlistType == 'customreport'){
				if(ld("#stuff_charts_"+widgetId).offset().top>CrmPopup.getClientHeight())
					break;
			}
			//自定义统计图 在这里请求数据和渲染
			var params = getHomeAllParams();
			params += '&fromhome=yes';

			if(reporttype=='sqlchart'||widgetType=='sqlchart'){
				//zxm 20230512 XUQIU1001246	统计表	报表分析->SQL统计图：增加设置，允许添加到首页组件中显示
				var popupobj = new CrmPopup();
				var divid = "chartInfoForm";//链接模块
				var boardstuffid = ld('#stuff_charts_'+widgetId).data('boardstuffid');
				params+="&boardstuffid="+boardstuffid;
				//edit: xll BUG20240131-23 2024/01/31 改为AjaxJSPage同步获取js，而后再执行代码； 使用 getScriptBackWithURL 回调函数会出现因为获取过慢 局部变量 参数 已经在循环中被修改
				AjaxJSPage("CustomEchartsSqlDetail_js", 'include/js/modules/CustomEcharts/CustomEchartsSqlDetail.js');
				var CustomEchartsSqlDetailObj = new CustomEchartsSqlDetail();
				CustomEchartsSqlDetailObj.show(popupobj,divid,widgetId,chart_type,params);
			}else if(reporttype=='chart'||widgetType=='chart'){
				var popupobj = new CrmPopup();
				var divid ='searchInfo';
				var boardstuffid = ld('#stuff_charts_'+widgetId).data('boardstuffid');
				params+="&boardstuffid="+boardstuffid;
				AjaxJSPage("CustomEchartsDetail_js", 'include/js/modules/CustomEcharts/CustomEchartsDetail.js');
				var CustomEchartsDetailObj = new CustomEchartsDetail();
				CustomEchartsDetailObj.show(popupobj,divid,widgetId,chart_type,params);
			}else if(reporttype=='selectfield'||widgetType=='selectfield'){
				//自定义统计表---todo---
				//自定义统计表
				var boardstuffid = ld('#stuff_tables_'+widgetId).data('boardstuffid');
				params+="&boardstuffid="+boardstuffid;
				var Popupsqltableobj = new CrmPopup();
				Popupsqltableobj.divid = "myTable_"+widgetId;
				AjaxJSPage("CustomTablesDetailHome_js", 'include/js/modules/CustomTables/CustomTablesDetailHome.js');
				var CustomTablesDetailHomeObj = new CustomTablesDetailHome();
				CustomTablesDetailHomeObj.show(Popupsqltableobj,Popupsqltableobj.divid,widgetId,params);
			}else if(reporttype=='sql'||widgetType=='sql'){

				var boardstuffid = ld('#stuff_tables_'+widgetId).data('boardstuffid');
				params+="&boardstuffid="+boardstuffid;
				//SQL统计表---todo---
				var Popupsqltableobj = new CrmPopup();
				Popupsqltableobj.divid = "myTable_"+widgetId;
				AjaxJSPage("CustomTablesSqlDetailHome_js", 'include/js/modules/CustomTables/CustomTablesSqlDetailHome.js');
				var CustomTablesSqlDetailHomeObj = new CustomTablesSqlDetailHome();
				CustomTablesSqlDetailHomeObj.show(Popupsqltableobj,Popupsqltableobj.divid,widgetId,params);
			}
		}
		else{
			if(ld("#stuff_"+widgetId).offset().top>CrmPopup.getClientHeight())
				break;
			var callbackfun = function(Option){
				loadStuff(Option.widgetId,Option.widgetType,Option.sales_target_tab);
			}
			if(stuffid_arr.includes(widgetId.toString())){
				var CurWidgetInfo = widgetInfoList[index];
				var StuffInfo = {
					stuffid : CurWidgetInfo.widgetId,
					stufflisttype : CurWidgetInfo.widgetlistType,
					stufftype : CurWidgetInfo.widgetType,
				};
				LoadStuffNavBar(StuffInfo,callbackfun,{widgetId:widgetId,widgetType:widgetType,sales_target_tab:sales_target_tab});
			}else{
				loadStuff(widgetId,widgetType,sales_target_tab);
			}

		}

	}
    homeplatestuff_arr[widgetInfoList[0].plateindex]=plateindex;
     
}
var Header_Top_Load = function(){
	//@edit:liushuai,2020-09-08,reason:【ID1000285】PC端：首页增加首页视图设置
	ld(' .home_header_top .home-header-top-setting a').on('click',function(){
		var crmPopupobj=CrmPopup.load("","","","1000",'Settings',"","","","");
		crmPopupobj.prevshow();
		var surl = 'index.php?module=Settings&action=listtemplate&parenttab=Settings&ReportHeader=dheader&from_module=home';
		ldAjax(surl,"",function(data){
			if(data.code==1){
				getJsScript('include/js/modules/Settings/listtemplate.js', function () {
					crmPopupobj.setParams(data.result.title, '', "", "LdPopWidth1100px", 'Settings', "", "", "", "");
					crmPopupobj.show(data.result.content);
					ld('#' + crmPopupobj.divid + ' .E_pop_tit .E_ptitc').unbind('click').on('click', function () {
						window.location.reload();
						return false;
					});
				});
			}
			DelProgressObjs();
		});
	})
}

//首页：销售简报穿透
var setSalesTragetUrl = function(stufflabel,jqueryobj){
	var stuffid = ld(jqueryobj).attr("data-stuffid");
	var params = getHomeAllParams();
	var modules=ld(jqueryobj).attr("module");
	if(stuffid==46||stuffid==47||stuffid==51||stuffid==52){//zxm 2020-1202 誉帆项目报告穿透 zxm 2020-1203 易冲新销售简报穿透
		var stufflabel = '';
		var reportlabel=ld(jqueryobj).attr("reportlabel");//zxm 2020-1202 誉帆项目报告穿透
		//zxm 2020-1204 stuffid==47项目报告 chengben maoli maoli_rate maoli_rate_max maoli_rate_min 直接跳转指定链接
		if(reportlabel=="chengben"||reportlabel=="maoli"||reportlabel=="maoli_rate"||reportlabel=="maoli_rate_max"||reportlabel=="maoli_rate_min"){
			if(stuffid==47){
				OpenNewWebTab("CustomReport/JsReport/index.php?crm_report_key=yufan_project.mrt&default_report=1&report_name=%E9%A1%B9%E7%9B%AE%E6%8A%A5%E8%A1%A8");
				return;
			}else{
				OpenNewWebTab("index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ConstructionReport&function_name=getProjectReport&reportlabel="+reportlabel+"&selectuserid="+selectuserid+"&search_date_custom_value="+search_date_custom_value+"&approve_value="+approve_value);
				return;
			}
		}
		//zxm 2020-1204 stuffid==47项目报告 chanzhi_target_rate lirun_target_rate 点不动
		if(reportlabel=="chanzhi_target_rate"||reportlabel=="lirun_target_rate"){
			return;
		}
		//zxm 2021-0104  trading_unit  trading_unit_money important_account_nums business_year_money需求待确定
		//edit: xll BUG20240130-52 请求模块使用ReportAnalysis
		if(reportlabel=="trading_unit"||reportlabel=="trading_unit_money"||reportlabel=="important_account_nums"||reportlabel=="business_year_money"){
			OpenNewWebTab("index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=YichongReport&function_name=getCustomsList&reportlabel="+reportlabel+"&selectuserid="+selectuserid+"&search_date_custom_value="+search_date_custom_value+"&approve_value="+approve_value);
			return;
		}
	}else if(stuffid==54){
		//zxm  2021-0706 工程行业项目报告 只有产值可以跳转
		var reportlabel=ld(jqueryobj).attr("reportlabel");
		if(reportlabel!="chanzhi"){
			return;
		}
	}else{
		var stufflabel=ld(jqueryobj).attr("stufflabel");
		var reportlabel= '';
	}
	var addurl=encodeURIComponent("&query_session=1&start=1");//edit:Can 047405: https://81mis.com/kfbcrm [^]，首页-销售简报-有过翻页后，更改时间审批状态后，再点击简报，依旧是上次的页数

	ldAjax("index.php?module=Home&action=HomeAjax&file=setModuleSearchForHome&stufflabel="+stufflabel+"&reportlabel="+reportlabel+"&searchtype="+ld(jqueryobj).attr("searchtype")+"&searchmodule="+modules+params,
		{selectuserid:selectuserid,pageurl:ld(jqueryobj).attr("pageurl"),addurl:addurl},
		function(ajaxdata){
		var pageurls=ld(jqueryobj).attr("pageurl").split(",");
		//if(module == 'Potentials_lastsales_stage')module = 'Potentials';
		DelProgressObjs();
		ld.each(pageurls,function(tmpindex,tmpurl){

			url = tmpurl+'&page_addurl='+addurl;
			if(from_login_type=='pc_dingtalk'||from_login_type=='pc_yunzhijia')
			{
				// window.open(url);
				OpenNewWebTab("Register/LoginSession.php?session="+encodeURIComponent(ajaxdata.result.encode)+"&query_session=1&start=1");
			}
			else
				OpenNewWebTab(url);
		})

	})
}

function SmOwnerSearchScopeheight() {
	if(document.getElementById('showselectsearchscope_new') != undefined){

		if(Showselect_obj && Showselect_obj.optionList && Showselect_obj.optionList.length > 0){
			var optionlists = Showselect_obj.optionList;
			for(var i=0;i<optionlists.length;i++){
				if(optionlists[i]['value'] == 'smowner_search_senior'){
					Showselect_obj.eventChangeSelected(i);
					break;
				}
			}
		}
	}
}
//wyt 221118 XUQIU1000853 首页查询组件优化
//首页：查看范围 new
function SmOwnerSearchScope(obj){
	var SearchScope=ld('#HomeSmOwnerSearchScope').val();
	if(SearchScope=='smowner_search_senior'||ld(obj).attr("tag")=="icon"){
		var scopepopupobj;
		var selectuserid = '';
		if(ld('#selectuserid') != undefined){
			selectuserid = ld('#selectuserid').val();
		}
		//zkt 20231201 BUG0076092 kfbcrm-成员hxg数据范围为测试部，首页高级查看范围中应只显示“测试部”
		var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Home&popup_inputtype=checkbox&popup_selecttype=user&popup_scopetype=private&popup_type=listselecthigher';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'yes'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = arrJsPopLabel['VIEWRANGESENIOR'];//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
				cls_ScopePopup.prop.popup_url = popup_url;//popup_url
				cls_ScopePopup.prop.popup_module = 'Home';//模块
				cls_ScopePopup.prop.popup_value = selectuserid;
				var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}else{
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							if(ld('#selectuserid') != undefined){
								ld('#selectuserid').val(selected_user);
								if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
								{
									//通讯录(pc端企业微信)
									cls_wxOpenDataobj.bindAllOpenData();
								}
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
								initWidgets();
								//增加用户选择查看范围的记忆功能
								var boardid = ld("#boardid").val()===undefined?0:ld("#boardid").val();
								var value=SearchScope+':'+ld('#selectuserid').val();
								var module='Home';
								var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard'+'&boardid='+boardid;
								url += '&chooseSearchScope='+value+'&mode=change';
								ldAjax(url,"",function(data){
									ld('#rptContentLoading').hide();
								});
							}
						}
					});
				}
			});
		});
	}else {
		var value='';
		if (SearchScope == 'SmOwner_Search_All') {
			value+=SearchScope+':';
			var tmpuserid = ld('#selectuserid_all').val();
			ld('#selectuserid').val(tmpuserid);
			initWidgets();
		} else {
			ld('#selectuserid').val(SearchScope);
			initWidgets();
		}
		//增加用户选择查看范围的记忆功能
		var boardid = ld("#boardid").val()===undefined?0:ld("#boardid").val();
		value+=ld('#selectuserid').val();
		// console.log("common",value);
		var module='Home';
		var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard'+'&boardid='+boardid;
		url += '&chooseSearchScope='+value+'&mode=change';
		ldAjax(url,"",function(data){
			ld('#rptContentLoading').hide();
		});
	}

}
//穿透类 HomeStuffChuantou 包括首页、报表分析模块的报表穿透
AjaxJSPage('HomeStuffChuantou','include/js/modules/Home/HomeStuffChuantou.js');
var homestuffObj = new HomeStuffChuantou();
//edit: xll 2023/08/14 XUQIU1001400 目标完成率仪表盘和近六个月目标完成情况组件（ 更多 页签的移入事件）
function tabMoreHover(obj,type){
	var TabMoreObj = ld(obj);
	var TabMoreListObj = TabMoreObj.find('.tab_more_div');
	if(type == 'off'){
		TabMoreListObj.hide();
	} else if(type == 'on'){
		TabMoreListObj.show();
		TabMoreListObj.css('display','inline-flex');
	}
	var TabMoreObj_width = TabMoreObj.outerWidth();
	var TabMoreListObj_width = TabMoreListObj.outerWidth();
	if(TabMoreListObj_width < TabMoreObj_width){
		var TabMoreListObj_right = (TabMoreObj_width - TabMoreListObj_width)/2;
		TabMoreListObj.css('right',TabMoreListObj_right)
	}
}
//edit: xll 2023/08/14 XUQIU1001400 目标完成率仪表盘和近六个月目标完成情况组件（ 更多 页签的点击事件）
function tabMoreChange(obj){
	var TabMoreItemObj = ld(obj);
	var TabMoreListObj = TabMoreItemObj.parents('.tab_more_div');
	var TabMoreObj = TabMoreListObj.parents('.tab_more');
	var TabMoreTextObj = TabMoreObj.find('.tab_more_text');
	TabMoreListObj.hide();
	TabMoreObj.addClass('cur');
	var cur_cont = TabMoreItemObj.text();
	TabMoreTextObj.text(cur_cont);
	var param_arr = ['type','targetid'];
	ld.each(param_arr,function (key,tmpparam) {
		var tmpvalue = TabMoreItemObj.attr('data-'+tmpparam);
		TabMoreObj.attr('data-'+tmpparam,tmpvalue);
	});
}

/**
 * 首页组件页签点击事件，需使用ld_NavBar生成页签
 * @author xll
 * @data 2023/10/27
 * @param {string|number} stuffid - 组件id
 * @param {NavBarEvent} evt - ld_NavBar的页签事件对象
 */
function StuffNavBarClick (stuffid,evt,stufftype='chart') {
	let NarBarItem = evt.NavBarItem,
		data_type = NarBarItem.name,
		popupObj = CrmPopup.getPopupObj('last');
	if(popupObj && popupObj.divid && popupObj.boardtype)
		Homeboard.getInstance().loadStuff(stuffid,stufftype)
	else
		loadStuff(stuffid,stufftype,data_type);
}




