<!--修改编码格式:统一编码：UTF-8-->

    {*
    edit:andrew
    date:20140107
    reason: 当月行动和日报参考添加显示隐藏功能
    *}

<div id="weekrptEdit">
        <div align="left" style="margin-right:30px;font-size:20px;font-weight:bold;color:#555;">
            {'A_D_REFERENCXEMONTH'|@getFixedLabel}:
            <a href="javascript:showHideStatuscode('ReferenceWeek','even more');" id='even more' style="COLOR:red; font-weight:normal;font-size: 13px;">{if $NONEMODE==1}>>{'MORE'|@getFixedLabel}{else}>>{'COLLAPSE'|@getFixedLabel}{/if}</a>
        </div>
        <div {if $NONEMODE==1}style="display: none;"{else}style="display: block;"{/if} id="ReferenceWeek">  
        
        <div class="calmenu Category" style="clear:both;margin:10px 0px;overflow:hidden;">
            <ul style="padding:0px;margin:0px;">
                {if $CALENDARSTATUS eq 'allcategor'}
                    <li class="calsel" id="calsel">
                {else}
                    <li>
                {/if}
                    <a href="javascript:document.getElementById('calsel').className='';CalendarStatus='allcategor';CalendarClick(2)"  onclick="ACalendar=this;this.parentNode.className='calsel' " id="All" >{'All_Categories'|@getFixedLabel}:</a>
                </li>
                
                  {if $CALENDARSTATUS eq 'Calendar'}
                    <li class="calsel" id="calsel">
                  {else}
                        <li>
                  {/if}
                    <a href="javascript:document.getElementById('calsel').className='';CalendarStatus='Calendar';CalendarClick(2)"  onclick="ACalendar=this;this.parentNode.className='calsel' " id="Calendar" >{'Schedule'|@getFixedLabel}</a>
                </li>
                {if $CALENDARSTATUS eq '计划中'}
                    <li class="calsel" id="calsel">
                {else}
                    <li>
                {/if}
                (<a href="javascript:document.getElementById('calsel').className='';CalendarStatus='计划中';CalendarClick(2)" onclick="ACalendar=this;this.parentNode.className='calsel' " id="Planning">{'Plan'|@getFixedLabel}</a>
                </li>
                {if $CALENDARSTATUS eq '已执行'}
                    <li class="calsel" id="calsel">
                {else}
                    <li>
                {/if}
                <a href="javascript:document.getElementById('calsel').className='';CalendarStatus='已执行';CalendarClick(2)"  onclick="ACalendar=this;this.parentNode.className='calsel' "id="InOperaton">{'Executed'|@getFixedLabel}</a>
                </li>
                
                 {if $CALENDARSTATUS eq '未执行'}
                    <li class="calsel" id="calsel">
                {else}
                    <li>
                {/if}
                 <a href="javascript:document.getElementById('calsel').className='';CalendarStatus='未执行';CalendarClick(2)" onclick="  ACalendar=this;this.parentNode.className='calsel'" id="Completed">{'NOT_Executed'|@getFixedLabel}</a>)
                </li>
                {if $CALENDARSTATUS eq 'ContactRecord'}
                    <li class="calsel" id="calsel">
                {else}
                    <li>
                {/if}
                 <a href="javascript:document.getElementById('calsel').className='';CalendarStatus='ContactRecord';CalendarClick(2)" onclick="  ACalendar=this;this.parentNode.className='calsel'" id="Contactrecord">{'Contact_Record'|@getFixedLabel}</a>
                </li>
                <li style="float:right;">
                {'Customer'|@getFixedLabel}:
                <select name="cu_id" style="width:160px" onchange="ChangeAccount(this,2)" id="cu_id">
                   {$ACCOUNTOPTIONS}
                </select>
                </li>
                
             
            </ul>
        </div>
        
        <table class="borderLBR" style="border-collapse:collapse;clear:both;color:#555;" width="100%" border="0" cellspacing="0" cellpadding="1">
            <tr style="text-align:left;">
                <th width="14%" class="TitleHeading">
                    {'Monday'|@getFixedLabel}
                </th>
                 <th width="10%" class="TitleHeading">
                    {'Tuesday'|@getFixedLabel}
                 </th>
                 <th width="10%" class="TitleHeading">
                    {'Wednesday'|@getFixedLabel}
                 </th>
                 <th width="10%" class="TitleHeading">
                    {'Thursday'|@getFixedLabel}
                 </th>
                 <th width="10%" class="TitleHeading">
                    {'Friday'|@getFixedLabel}
                 </th>
                 <th width="10%" class="TitleHeading">
                    {'Saturday'|@getFixedLabel}
                 </th>
                 <th width="10%" class="TitleHeading">
                    {'Sunday'|@getFixedLabel}
                 </th>
                 <th width="15%" class="TitleHeading">
                    {'Week_Summary'|@getFixedLabel}
                 </th>
                <th width="15%" class="TitleHeading">
                    {'Plan_next_week'|@getFixedLabel}
                 </th>
            </tr>
           
            <!--日程列表-->
       {foreach key=weekss item=weekscontent from=$CALENDARTR}
                     {foreach key=trs item=tds from=$weekscontent}
                     {$tds}
                     {/foreach}
         {/foreach}
          
        </table>
</div>
            
</div>

<script>
var more='{'MORE'|@getFixedLabel}';
var collapse='{'COLLAPSE'|@getFixedLabel}';
{literal}
function showHideStatuscode(sId,anchorId,sImagePath)
{
	oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
		oObj.style.display = 'none';
		if(anchorId !=null){
			eval(document.getElementById(anchorId)).innerHTML =  '>>'+more;
		}
	}
	else
	{
		oObj.style.display = 'block';
		if(anchorId !=null){
			eval(document.getElementById(anchorId)).innerHTML = '>>'+collapse;
		}
	}
}
{/literal}
</script>
    
