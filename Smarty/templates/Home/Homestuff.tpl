{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script>
	var salesCurrentIndex = 1;
	var current_language = "{$current_language}";
	AjaxJSPage("HomeStuff_js",'include/js/modules/Home/Homestuff.js');
</script>
<script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
<link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
<input id="homeLayout" type="hidden" value="{$LAYOUT}">
<input id="selectuserid" type="hidden" {if $selected_searchscope_value neq ''}value="{$selected_searchscope_value}"{/if}>
<input id="selectuserid_all" type="hidden" value="{$ALL_USER_ID}">
<input id="search_date_custom" type="hidden" value="">
<div id="home_index" class="home-index ld-bg-color" >
	<div class="home_header_top">
		<div style="float: left;margin-top: 12px;">
			{include file='SearchScope_New.tpl'}
		</div>
		<div class="home_laydate_div" style="margin-left: 12px;">
			<input type="hidden" class="laydate_time_value" data-value="{$timeDefault}">
			<input type="hidden" class="laydate_time_hiddenvalue" {if {$customDateValue} neq ''}value="{$customDateValue}"{/if}>
			<input type="text" {if $current_language eq 'en'}style="width:120px;"{/if} placeholder="{'SELECT'|getFixedLabel}" id="home_laydate_time" class="home_laydate_time laydate_time cursorPointer" readonly="" value="{$DATASELECT[$timeDefault]}">
			<label for="home_laydate_time" class="home_laydate_jiantou laydate_jiantou cursorPointer"></label>
		</div>
		<div id="homeboard_approve" style="position: relative;float: left;margin-top: 12px;margin-left: 20px;"></div>
		<div class="home-header-top-setting" {if $MODULE eq 'VisualAnalysis'} style="display: none" {/if}>
			<div style="margin-top: 12px;margin-right: 10px;">
				<div tabindex="-2" style="cursor: pointer;" class="homeboard_name" id="homeboard_name" boardid="{$Home_boardid}">
					{'Default_Kanban'|@getFixedLabel}
					<span class="ld_icon_arrowdown" style="margin-left: 8px;"></span>
					<div id="homeboard_List" tabindex="-1" style="outline: 0;" class="ld_homeboard_head_select">
						{include file='Home/HomeboardDropList.tpl'}
					</div>
				</div>
			</div>
		</div>
	</div>

	<div id="home-content-div" class="home-content-div">
		<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" valign="top" id="homestuffdiv">
			<tr>
				<td width="100%" align="center" valign="top">
					<div id="MainMatrix" class="show_tab" style="padding:0px;width:100%;position:relative;z-index:10;">
						{foreach item=tablestuff key=cnt from=$HOMEFRAME name="homeframe"}
							{if $cnt < 0 }
								<div tag="1" style="display: flex;float: left;width: 100%;">
							{else}
								{if $cnt%2 == 0}
									<div tag="2" style="display: flex;float: left;width: 100%;margin-right: 10px;">
								{else}
									<div tag="2" style="display: flex;float: left;width: 100%;">
								{/if}
							{/if}
										{*自定义统计图现在在首页的模板文件*}
										{if $tablestuff['source']=='customechart'}
											{include file="CustomEcharts/homeChart.tpl"}
										{elseif $tablestuff['source']=='customechart'}
											{include file="CustomTables/homeTable.tpl"}
										{else}
											{include file="Home/MainHomeBlock.tpl"}
										{/if}
								</div>
						{/foreach}
					</div>
				</td>
			</tr>
		</table>
	</div>
</div>
<script language="javascript">
	//hzx XUQIU1002272 首页看板界面、设置，审批状态修改为下拉框，样式优化模块单据界面：查询分类、查看范围下拉框样式优化
	var approvelist = {$APPROVE_LIST};
	{literal}
	//首页查询审批状态过滤
	if(typeof global_home_approve !== "undefined"){
		global_home_approve = [];
	}else{
		var global_home_approve = [];
	}
	for(let i = 0;i<approvelist.length;i++){
		if(approvelist[i].selected){
			global_home_approve.push(approvelist[i].value);
		}
	}
	homeboardApproveRender(approvelist);//审批组件

 	var Listpagepopupobj=new CrmPopup();
  	Listpagepopupobj.type="home";
  	Listpagepopupobj.refreshpage='no';
  	Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
  	Listpagepopupobj.module='Home';
  	CrmPopup.global_listPopupObj.push(Listpagepopupobj);
	/*setHeight();
	ld(window).resize(function() {
		setHeight();
	});
	function setHeight(){
		ld('body').css('overflow','hidden');
		var a = ld('.Header').outerHeight(),//头部高度
      		b = ld('.home_header_top').outerHeight(),//筛选高度
      		c_height = 0,
      		s_height = ld('#pagecontent').height();

		if(a==null) a=0;
		if(b==null) b=0;
  		c_height = s_height;
		var homeIndexObj = ld('#home_index');
		homeIndexObj.css('height',c_height);
	}*/
	(function ScrollBoard() {
		//edit: xll 2024/02/22 BUG20240219-35 kfbcrm-首页看板-点击看板后再打开下拉框，应自动滚动到当前看板位置
		ld('#home_index').find('#homeboard_name').one('mouseover',function () {
			ScrollBoardIntoView(ld(this).attr('boardid'))
		})
	})();
{/literal}
</script>
{*<!-- Main Contents Ends Here -->*}
<script>
var _isAdmin = '{$ISADMIN}';
var version_account = '';
var Vt_homePageWidgetInfoList=[];
var homeplatestuff_arr=[];

function initStuffArr() {
	homeplatestuff_arr[0]=0;
	Vt_homePageWidgetInfoList[0] = [
		{if $HOMEFRAME|@count > 0}
		{assign var=HOMEFRAME value=$HOMEFRAME}
		{foreach item=tablestuff key=index from=$HOMEFRAME name="homeframe"}
		{if ($tablestuff.Stufftype neq 'Default' || $tablestuff.Stufftitle neq 'Home Page Dashboard'|@getTranslatedString:'Home')
	&& $tablestuff.Stufftype neq 'DashBoard' && $tablestuff.Stufftype neq 'ReportCharts'}
		{ldelim}
			'widgetId': {$tablestuff.Stuffid},
			'widgetType': '{$tablestuff.Stufftype}',
			'widgetlistType':'{$tablestuff['stufflisttype']}',
			'report_type': '{$tablestuff.report_type}',
			'chart_type': '{$tablestuff.chart_type}',
			'plateindex': 0
			{rdelim}
		{if $index+1 < $HOMEFRAME|@count},{/if}
		{/if}
		{/foreach}
		{/if}
	];

}
{literal}

ld(function(){
	initWidgets();
   	Header_Top_Load();

})

{/literal}
</script>
<script language="javascript">
	{literal}
		var div_width = CrmPopup.getClientWidth()-getLeftMenuWidth();//区块间隔宽度
		if(crmorprmtype != 'prm'){
			div_width = div_width - 20;
		}
		ld('#MainMatrix [tag=1]').css('width', div_width-15+'px');
		if(CrmPopup.getClientWidth() <= 414){
			ld('#MainMatrix [tag=2]').css('width', div_width-15+'px');	
		}
		else{
			ld('#MainMatrix [tag=2]').css('width', (div_width/2-13)+'px');
		}
	// 首页日期加载
	homeboardLaydateRender();
	//edit: txy 2023/09/04 首页看板增加拖动排序功能
	homeboardListSorting();
    {/literal}
</script>