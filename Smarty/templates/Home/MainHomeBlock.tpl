<!--修改编码格式:统一编码：UTF-8-->
{*<!-- this file displays a widget div - the contents of the div are loaded later usnig javascript -->*}
{assign var="homepagedashboard_title" value='Home Page Dashboard'|@getTranslatedString:'Home'}
{assign var="stitle" value=$tablestuff.Stufftitle}
<script type="text/javascript">var vtdashboard_defaultDashbaordWidgetTitle = '{$homepagedashboard_title}';</script>

{*//2020-1127 zxm 誉帆 项目报表做全横得*}
{if $tablestuff.Stufftype eq 'saleskit'||$tablestuff.Stuffid==47||$tablestuff.Stuffid==51||$tablestuff.Stuffid==64||$tablestuff.Stuffid==65}
	<div id="stuff_{$tablestuff.Stuffid}" class="MatrixLayer_row{if $tablestuff.Stufftitle eq $homepagedashboard_title} twoColumnWidget{/if}">
{else}
	<div id="stuff_{$tablestuff.Stuffid}" class="MatrixLayer MatrixLayer_row {if $tablestuff.Stufftitle eq $homepagedashboard_title} twoColumnWidget{/if}">
{/if}
	<table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
		<tr id="headerrow_{$tablestuff.Stuffid}" >
            <th class="N_con_tit">
            	<div class="N_con_tit_name">
	            	<span class="icon-bluelt"></span>
                    {if $tablestuff.Stuffid eq '2'}
                        {"Y"|@date|@cat:$stitle}
					{elseif $tablestuff.Stuffid eq '43'}
						{*@edit:zhouxiaomei @date:2020-9-10 @reason: 首页增加日程管理组件 标题使用模块名称*}
						{'Calendar'|@getTransTab}
					{else}
                        {$stitle}{if $tablestuff.Stuffid eq '21'}（{'Double_click_to_enter_edit_mode'|@getFixedLabel}）{/if}
                    {/if}
	                {if $tablestuff.Stuffid neq '36' && $tablestuff.Stuffid neq '2'}
	                	<span id="refresh_{$tablestuff.Stuffid}" style="position:relative;"></span>
	                {/if}
            	</div>
            	{if $tablestuff.Stuffid eq '35'||$tablestuff.Stuffid eq '64'||$tablestuff.Stuffid eq '65'}
	            	<div>
                        {if $IsAdmin eq true}
							{*//工程行业 新增的两个组件 也需要设置*}
                    	    <a href="javascript:void(0);" onclick="SalesKitSet(event,ld(this),{$tablestuff.Stuffid},'{$stitle}')">{'SETTINGS'|@getFixedLabel}</a>
                        {/if}
	            	</div>
            	{/if}
            </th>
            <th colspan="2" class="N_con_tit" align="right">
				{*zxm  2021-0623 中孚的增加刷新按钮*}
				{if $tablestuff.Stuffid eq 58||$tablestuff.Stuffid eq 59}
					<a style="height: 25px; margin-right: 8px;float: right; font-size:12px; font-weight: normal;cursor: pointer"  title="{'REFRESH'|@getFixedLabel}"  id="refresh_{$tablestuff.Stuffid}" onclick="loadStuff({$tablestuff.Stuffid},'{$tablestuff.Stufftype}');">
						{'REFRESH'|@getFixedLabel}
					</a>
				{/if}
				{if $tablestuff.url neq ''}
					<a style="height: 25px; margin-right: 8px;float: right; font-size:12px; color:#999;font-weight: normal;"  title="{'MORE'|@getFixedLabel}" onclick="homestuffObj.home_href_popup('{$tablestuff.Stuffid}','','','{$tablestuff.url}','{$tablestuff.page_addurl}')" href="javascript:;" id="a_{$tablestuff.Stuffid}">
						{'MORE'|@getFixedLabel}<b class="home_next"></b>
					</a>
				{/if}
				{*销售排行榜*}
				{*@edit:zhouxiaomei @date:2020-9-7 @reason: 首页增加近6个月销售目标完成情况（40）组件 更多按钮 *}
				{*@edit:zhouxiaomei @date:2020-9-9 @reason: 首页增加日程管理（43）组件 更多按钮 *}
				{if $tablestuff.Stuffid eq '33'||$tablestuff.Stuffid eq '40'||$tablestuff.Stuffid eq '43'}
					<div style="display:flex;justify-content: flex-end;">
					{*				@edit:zhouxiaomei @date:2020-9-9 @reason: 首页增加日程管理组件 增加新建日程按钮  样式于20220907修改bug编号BUG0056198  *}
					{if $tablestuff.Stuffid eq 43}
						<div class="home-calendar-create" style="border: none;border-radius: 0;background-color: #fff;margin-left:5px;z-index:999;">
							<div class="Cbox_R" style="position:relative;float:left;margin-top:0;padding-right:5px;">
							<span class="add-new">{'CREATE'|@getFixedLabel}</span>
							</div>
						</div>
					{/if}
					{if $tablestuff.Stuffid eq 40 and ('SalesGoal'|@isPermitted:"EditView" eq 'yes' or 'SalesGoal'|@isPermitted:"Create" eq 'yes')}
						<span class="Stuff_ManageSalesgoal" onclick="SalesGoalManage()">{'MANAGEINDICATORS'|@getFixedLabel}</span>
					{/if}
					<a style="height: 25px; margin-right: 8px; font-size:12px; color:#999;font-weight: normal;display: inline-block;"  title="{'MORE'|@getFixedLabel}" href="#" id="a_{$tablestuff.Stuffid}" onclick="SalesRankings({$tablestuff.Stuffid})">
					{'MORE'|@getFixedLabel}<b class="home_next"></b>
					</a>
					</div>
				{/if}
				{if $tablestuff.Stuffid eq '66'}
					{*zxm2021-1213 更多按钮跳转到常用报表*}
					<a target="_blank" data-id="{$tablestuff.usereportid}" style="height: 25px; float: right;margin-right: 8px; font-size:12px; color:#999;font-weight: normal;"  title="{'MORE'|@getFixedLabel}" href="index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl=%26report_name%3DServiceKanban%26refreshUseReport%3D{$tablestuff.usereportid}%26refreshleftmenuclick%3Dyes" id="a_{$tablestuff.Stuffid}">
						{'MORE'|@getFixedLabel}<b class="home_next"></b>
					</a>
				{/if}
            </th>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed">
		<tr id="maincont_row_{$tablestuff.Stuffid}">
			<td colspan="2">
				{*@edit:zhouxiaomei @date:2020-97-7 @reason: 首页增加近6个月销售目标完成情况组件 销售指标tab切换*}
				{if $tablestuff.Stuffid eq 40 ||$tablestuff.Stuffid eq 39}
					<div class="widget-content" id="sales_target_tab" style="height: 40px">
						<div class="tab" style="display:flex;justify-content: space-between;">
							{$tablestuff.html}
						</div>
					</div>
				{/if}
{*				zxm 2020-1205 排行榜切换*}
				{if $tablestuff.Stuffid eq 50||$tablestuff.Stuffid eq 56}
					<div class="widget-content" id="ranking_list_tab">
						<div class="tab" style="display:flex;justify-content: space-between;">
							<span style="width:20%;margin:0;text-align: center;padding:0;" class="tab-item cur" data-type="hetongList" data-stuffid="50" onclick="tabChange({$tablestuff.Stuffid},this)">
						合同签约排行榜</span>
							<span style="width:20%;margin:0;text-align: center;padding:0;" class="tab-item" data-type="chanzhiList" data-stuffid="50" onclick="tabChange({$tablestuff.Stuffid},this)">
						产值排行榜</span>
							<span style="width:20%;margin:0;text-align: center;padding:0;" class="tab-item" data-type="maoliList" data-stuffid="50" onclick="tabChange({$tablestuff.Stuffid},this)">
						毛利排行榜</span>
							<span style="width:20%;margin:0;text-align: center;padding:0;" class="tab-item" data-type="maoliRateList" data-stuffid="50" onclick="tabChange({$tablestuff.Stuffid},this)">
						毛利率排行榜</span>
							<span style="width:20%;margin:0;text-align: center;padding:0;" class="tab-item" data-type="shoukuanList" data-stuffid="50" onclick="tabChange({$tablestuff.Stuffid},this)">
						收款排行榜</span>
						</div>
					</div>
				{/if}
				{if $tablestuff.Stufftype eq 'saleskit' ||$tablestuff.Stuffid==47 }
					<div id="stuffcont_{$tablestuff.Stuffid}" style="overflow:hidden;width:100%;">
					</div>
				{elseif $tablestuff.Stuffid==51||$tablestuff.Stuffid==64||$tablestuff.Stuffid==65}
					<div id="stuffcont_{$tablestuff.Stuffid}" style="overflow-x:hidden;width:100%;">
					</div>
				{else}
					<div id="stuffcont_{$tablestuff.Stuffid}" style="overflow-y: auto; overflow-x:hidden;width:100%;height:{if $tablestuff.Stuffid eq 40}285px{else}330px{/if};">
					</div>
				{/if}
			</td>
	   	</tr>
	</table>
</div>

<script language="javascript" >
	function home_href(surl,page_addurl){
		if(page_addurl != ''){
			page_addurl = '&page_addurl='+encodeURIComponent(page_addurl);
		}
		window.open(surl+page_addurl);
	}
	function SalesRankings(stuffid){
		if(stuffid == 33){
			ld('#stuffcont_'+stuffid+' .widget-content .tab span').each(function(){
				var tab_item = ld(this).attr('class');
				if(tab_item == 'tab-item cur'){
					var data_type = ld(this).attr('data-type'),page_addurl;
					if(data_type == 'amount'){
						page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=sendpament_amount');
						window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
					}else if(data_type == 'contractaount'){
						page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=due_amount');
						window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
					}else if(data_type == 'contractquantity'){
						page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=due_num');
						window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
					}
					else {
						page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value='+data_type);
						window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
					}
				}
			})
		}else if(stuffid == 40 || stuffid == 101){
			//@edit:zhouxiaomei @date:2020-9-7 @reason: 首页增加近6个月销售目标完成情况组件  更多按钮的跳转路由
            //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘
			window.open("index.php?pageto_module=SalesGoal&pageto_action=index");
		}else if(stuffid == 43){
			//@edit:zhouxiaomei @date:2020-9-9 @reason: 首页增加日程管理组件  更多按钮的跳转路由
			window.open("index.php?pageto_module=Calendar&pageto_action=index");
		}

	}
	/**
	 * @edit:zhouxiaomei
	 * @date:2020-09-07
	 * @reason:近6个月销售目标完成情况 tab切换点击事件
	 * @param stuffId
	 * @param obj
	 */
	function tabChange(stuffId,obj)
	{
        //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘（更多页签的处理）
		var curObj = obj;
		var objTag = ld(obj).attr('tag');
		if(objTag == 'more'){
			curObj = ld(obj).parents('.tab_more');
		} else {
			var TabMoreTextObj = ld(obj).siblings('.tab_more').find('.tab_more_text');
			TabMoreTextObj.text('');
		}
		//销售指标
		if(stuffId == 40 || stuffId == 101){
			let data_type = ld(curObj).attr('data-type');
			ld('#maincont_row_'+stuffId+' .widget-content .tab span').removeClass('cur');
			ld(curObj).addClass('cur');
			loadStuff(stuffId,'chart',data_type);
		}
		//销售指标
		if(stuffId == 50||stuffId == 56){
			let data_type = ld(curObj).attr('data-type');
			ld('#maincont_row_'+stuffId+' .widget-content .tab span').removeClass('cur');
			ld(curObj).addClass('cur');
			loadStuff(stuffId,'rankinglist',data_type);
		}
	}

</script>