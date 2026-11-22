<div id="dailysummarys" class="dailysummarysDiV" style="{if $TYPE eq 0}display:;{else}display:none;{/if}">
	<div class="ReferenceData">{'Work_Summary'|@getFixedLabel} <span> {'DATE_NOT_WRITE_DAILY_SHOW'|@getFixedLabel}</span></div>
	
	{foreach key=value item=data from=$REPORTINFO}
	<div class="dailyReportSum">
		<div class="TitleTimeReport">
			<span class="span1">{$data.startdate}[{$data.week}]</span>
			<span style="float:right;">
			{'Write_Time'|@getFixedLabel}- {$data.submitdate}
			<a href="#top">Top</a>
			</span>
		</div>
		<div class="SummaryContent">
			<font class="fontPoint">{'Work_Summary'|@getFixedLabel}:</font>
			{$data.worksummary}
		</div>
		<div class="FuturePlan">
			<font class="fontPoint">{'The_next_day_plan'|@getFixedLabel}:</font>
			{$data.tomorrowplan}
		</div>
		<div class="Reply">
			<font class="fontPoint">{'Instructions_Reply'|@getFixedLabel}:</font>
			{foreach item=comments from=$COMMENTS.$value} 
			{if $comments.commentcontent neq ''}
			<div class="dataField" style="width: 100%; padding-top: 5px;"> 
			{$comments.commentcontent}
			</div>   
			<div class="dataLabel" style="border-bottom: 1px dotted rgb(204, 204, 204); width: 100%; padding-top: 5px;">
			<font color="darkred">{'Author'|@getFixedLabel}:              
			 {$comments.commentor}&nbsp;&nbsp; {'Added'|@getFixedLabel}{$comments.commentdate}
			 </font>
			 </div>
			 {/if}
			{/foreach}
		</div>
		<div class="end"><font class="fontPoint"> -end-</font></div>
	</div>

	{/foreach}
	
</div>

<div id="referencedates" style="{if $TYPE eq 1}display:;{else}display:none;{/if}" class="referencedatesDiv">
	<div class="ReferenceData">{'Reference_Data_Summary'|@getFixedLabel}</div>
	{include file="ReportLog/DailyReferenceData.tpl"}
</div>