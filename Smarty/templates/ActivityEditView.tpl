{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
{assign var=email_info value=$ACTIVITYDATA.0}       
{assign var=remind_info value=$ACTIVITYDATA.1} 
{assign var=remind_content value=$ACTIVITYDATA.2}
<input type=hidden name="inviteesid" id="inviteesid" value="{$USERLISTIDS}">
<input type=hidden name="parent_id" id="parent_id" value="{$PRODUCTID}"> 
<tr>
	<td colspan="4" class="ld-from-headblock e">
		<div class="ld-from-headblock-title" tag="headblock-title">{'SETTINGS'|@getFixedLabel}</div>
	</td>
</tr>
<tr>
   <td colspan="4" class="ld-acitvity-content Bornone">
       <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF">
		   <tr style="border:none;">
			<td style="border:none;">
				<table border="0" cellpadding="3" cellspacing="0" width="100%">
					<tr style="border:none;">
						<td id="cellTabLoop" name="cellTabLoop" class="dvtSelectedCellCommon dvtSelectedCell height20" align="center" nowrap="nowrap" onClick="Calendar_switchClass('cellTabLoop');">
							<a href="javascript:doNothing()">{'循环日程'|@getFixedLabel}</a>
						</td>
						<td class="dvtTabCache height20" style="width:10px" nowrap>&nbsp;</td>

                        <td id="cellTabAlarm" name="cellTabAlarm" class="dvtUnSelectedCell height20" align="center" nowrap="nowrap" onClick="Calendar_switchClass('cellTabAlarm');">
                            <a href="javascript:doNothing()" >
                            {'REMINDS'|@getFixedLabel}
                            </a>
                        </td>                        
					    <td class="dvtTabCache height20" style="width:10px" nowrap>&nbsp;</td>
					    <td id="cellTabInvite" name="cellTabInvite" class="dvtUnSelectedCell height20" align="center" nowrap="nowrap" onClick="Calendar_switchClass('cellTabInvite');">
                            <a href="javascript:doNothing()">{'INVITE'|@getFixedLabel}</a>
                        </td>
               									
						<td class="dvtTabCache height20" style="width:100%;border-right:none;">&nbsp;</td>
                    </tr>
                 </table>
            </td>
          </tr>
		   <tr style="border:none;">
             <td width=100% valign=top align=left class="dvtContentSpace" style="padding:10px;">
				 {include file="modules/Calendar/LoopCalendarRemindsEditView.tpl"}
             <!--提醒-->
                <!-- Reminder UI -->     
				<div id="addEventAlarmUI" name="addEventAlarmUI" style="width:100%;display:none;">
                <!--email remind-->					                
					<table>
					  {assign var=secondval value=$email_info}                                                                          
						<tr>
              <td style="border:none;">{'SENDEMAILREMINDER'|@getFixedLabel}</td><td style="border:none;">
                <input type="hidden" id="set_remind" name="set_remind" value="false"/>									
						    {if $secondval.1 eq 1}
      						{assign var=reminstyle value='style="display:block;width:100%"'}
      						<input type="radio" name="set_remind" value="Yes" checked onClick="showBlock('reminderOptions')">&nbsp;{'YES'|@getFixedLabel}&nbsp;
      						<input type="radio" name="set_remind" value="No" onClick="fnhide('reminderOptions')">&nbsp;{'NO'|@getFixedLabel}&nbsp;
      					{else}
      						{assign var=reminstyle value='style="display:none;width:100%"'}
      						<input type="radio" name="set_remind" value="Yes" onClick="showBlock('reminderOptions')">&nbsp;{'YES'|@getFixedLabel}&nbsp;
      						<input type="radio" name="set_remind" value="No" checked onClick="fnhide('reminderOptions')">&nbsp;{'NO'|@getFixedLabel}&nbsp;
      					{/if}							
  						</td>
              <td style="border:none;padding-left:10%">
  					    <div id="reminderOptions" {$reminstyle}>
  						    <table border=0 cellspacing=0 cellpadding=2  width=100%>
  							    <tr>
                      <td style="border:none;" nowrap align=right width=20% valign=middle>{'REMINDS'|@getFixedLabel} : </td>
  								    <td style="border:none;" width=80%>
  									    <table border=0>
  									      <tr>
  										      <td class="ld-form-item-content" style="border:none;padding-left: 10px;">
                              <input name="email_remind" id="email_remind"  type="hidden" value="{$secondval.0}"> 
                      				<input name="email_date_only" class="Wdate ld-input-inner" id="jscal_field_email_remind" type="text"  style="border:1px solid #bababa;width:180px;" size="15" maxlength="25" value="{$secondval.0}" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})">
                              <input type="hidden" name="email_time" id="email_time">
                            </td>
                            <!--<td>
                             <img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_email_remind">
                            </td>
                            <td>
                                 {$secondval.1} 
                            </td>
                    				<script type="text/javascript" id='massedit_calendar_email_remind'>
                    					Calendar.setup ({ldelim}
                    						inputField : "jscal_field_email_remind", ifFormat : "%Y-%m-%d %H:%M:%S", showsTime : true, button : "jscal_trigger_email_remind", singleClick : true, step : 1
                    					{rdelim})
                    		  	</script>-->
  										    </tr>
  									    </table>
  								    </td>
  							    </tr>
  						    </table>
  					    </div>
              </td>
            </tr>
				  </table>								
          <!--popup remind-->                                   
					<table>
						{assign var=secondval value=$ACTIVITYDATA.1}                                                                          
						<tr>
              <td style="border:none;">{'POPMESSAGENOTICE'|@getFixedLabel}</td>
              <td style="border:none;">
                <input type="hidden" name="pop_reminds" id="pop_reminds">
      					{if $secondval.1 eq 1}
      						{assign var=reminstyle value='style="display:block;width:100%"'}
      						<input type="radio" name="pop_reminds" value="Yes" checked onClick="showBlock('reminderOptions2')">&nbsp;{'YES'|@getFixedLabel}&nbsp;
      						<input type="radio" name="pop_reminds" value="No" onClick="fnhide('reminderOptions2')">&nbsp;{'NO'|@getFixedLabel}&nbsp;
      					{else}
      						{assign var=reminstyle value='style="display:none;width:100%"'}
      						<input type="radio" name="pop_reminds" value="Yes" onClick="showBlock('reminderOptions2')">&nbsp;{'YES'|@getFixedLabel}&nbsp;
      						<input type="radio" name="pop_reminds" value="No" checked onClick="fnhide('reminderOptions2')">&nbsp;{'NO'|@getFixedLabel}&nbsp;
      					{/if}
						  </td>
              <td style="border:none;padding-left:10%">
                    <div id="reminderOptions2" {$reminstyle}>
                      <table border=0 cellspacing=0 cellpadding=2  width=100%>
                        <tr>
                            <td style="border:none;" nowrap align=right width=20% valign=middle>{'REMINDS'|@getFixedLabel} : </td>
                            <td style="border:none;" width=80%>
                                <table border=0>
                                <tr>
                                    <td class="ld-form-item-content" style="border:none;padding-left: 10px;" >
                                      <input name="date_time" type="hidden" value="{$secondval.0}">
                                      <input maxlength="25" size="15" name="date_only" value="{$secondval.0}" type="text"  id="jscal_field_date_only" style="border:1px solid #bababa;width:180px;" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate ld-input-inner "/>
                                      <input type="hidden" name="time_reminds" id="time_reminds">
                    				        </td>
                                    <!--<td>
                                     <img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_date_only">
                                    </td>
                                    <script type="text/javascript">
                            					Calendar.setup ({ldelim}
                            						inputField : "jscal_field_date_only", ifFormat : "%Y-%m-%d %H:%M:%S", showsTime : true, button : "jscal_trigger_date_only", singleClick : true, step : 1
                            					{rdelim})
                            				</script>-->
                                </tr>
    									       </table>
    								        </td>
                        </tr>
                      </table>							
				            </div>
              </td>
            </tr>
          </table>
      </div>
      <!-- 邀请 -->
			<div name="addEventRelatedtoUI" id="addEventRelatedtoUI" style="display:none;width:100%;">
				<ul class="mar0 pad0 noborder greyFont9">
					<li style="line-height: 25px;">1.{'INVITEMENTHODUSER'|@getFixedLabel}</li>
					<li style="line-height: 25px;">2.{'REMOVEINVITEUSER'|@getFixedlabel}</li>
				</ul>
				<table name="addEventRelatedtoTable" id="addEventRelatedtoTable" border=0 cellspacing=0 cellpadding=2 style="max-width: 600px;">
					
					<tr>
						<td class="Bornone">{'USERSCANCHOOSE'|@getFixedLabel}</td>
						<td class="Bornone">&nbsp;</td>
						<td class="Bornone" style="margin: 10px;">{'USERHASSELECTED'|@getFixedLabel}</td>
					</tr>
					<tr>
						<td class="Bornone" width="265px" align=left valign=top>
						<input style="width: 92%;margin-top: 5px;border: 1px solid #dbdbdb;border-radius: 3px;" type="text" class="member_select" name="member_select" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'availableusers', event)" placeholder="{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}" />
						<select ondblclick="addCalendarColumn('availableusers','selectedusers')" name="availableusers" id="availableusers" class=small size=5 multiple style="height:100px;width:250px;margin-top: 10px;">
						{foreach item=username key=userid from=$USERSLIST}
						{if $userid != ''}
						<option value="{$userid}">{$username}</option>
						{/if}
						{/foreach}
						</select>
						</td>
						<td class="Bornone" width="55px" align=left valign=top>
							<a class="icon-newhomearr icon-mright" style="margin-top: 40px;" href="javascript:;" onclick="copySelectedOptionsCalendarModule('availableusers','selectedusers');" title="{'MOVERIGHT'|@getFixedLabel}"></a>
							<a class="icon-newhomearr icon-mleft" style="margin-top: 10px;" href="javascript:;" onclick="copySelectedOptionsCalendarModule('selectedusers','availableusers');" title="{'MOVELEFT'|@getFixedLabel}"></a>
						</td>
						<td class="Bornone" width="260px" align=left valign=top>
						<select ondblclick="addCalendarColumn('selectedusers','availableusers')" name="selectedusers" id="selectedusers" class=small size=5 multiple style="height:100px;width:250px;margin-top: 34px;">
						{foreach item=username key=userid from=$INVITEDUSERS}
						{if $userid != ''}
						<option value="{$userid}">{$username}</option>
							{/if}
							{/foreach}
						</select>
						
						</div>
						</td>
					</tr>
				</table>
				<div class="greyFont9" style="margin-left: 355px;"> {'SELECTEUSEEMAIL'|@getFixedLabel}
				</div>
                  <!--重复-->  
                <div name="addEventRepeatUI" id="addEventRepeatUI" style="display:;width:100%;">
					<table border=0 cellspacing=0 cellpadding=2  width=100%>
						<tr  style="border:none;">
							<td align=right width="100" valign=top>
								<strong>{'REPEAT'|@getFixedLabel}</strong>
							</td>
							<td valign="top">
								<table border=0 cellspacing=0 cellpadding=0 style=" margin-left: 10px;">
								<tr style="border:none;">
									<td width=20>
									{if $RECURRINGVALUE.recurringcheck eq 'Yes'}
										{assign var=rptstyle value='style="display:block"'}
										{if $RECURRINGVALUE.eventrecurringtype eq 'Daily'}
											{assign var=rptmonthstyle value='style="display:none"'}
											{assign var=rptweekstyle value='style="display:none"'}
										{elseif $RECURRINGVALUE.eventrecurringtype eq 'Weekly'}
											{assign var=rptmonthstyle value='style="display:none"'}
											{assign var=rptweekstyle value='style="display:block"'}
										{elseif $RECURRINGVALUE.eventrecurringtype eq 'Monthly'}
											{assign var=rptmonthstyle value='style="display:block"'}
											{assign var=rptweekstyle value='style="display:none"'}
										{elseif $RECURRINGVALUE.eventrecurringtype eq 'Yearly'}
											{assign var=rptmonthstyle value='style="display:none"'}
											{assign var=rptweekstyle value='style="display:none"'}
										{/if}
									<input type="checkbox" name="recurringcheck" onClick="showhide('repeatOptions')" checked style="margin-bottom: 2px;">
									{else}
										{assign var=rptstyle value='style="display:none"'}
										{assign var=rptmonthstyle value='style="display:none"'}
										{assign var=rptweekstyle value='style="display:none"'}
									<input type="checkbox" name="recurringcheck" onClick="showhide('repeatOptions')" style="margin-bottom: 2px;">
									{/if}
									</td>
									<td>{'ENABLEREPEAT'|@getFixedLabel}<td>
								</tr>
								<tr style="border:none;">
									<td colspan=2>
									<div id="repeatOptions" {$rptstyle}>
									<table border=0 cellspacing=0 cellpadding=2>
									<tr style="border:none;">
									<td>{'REPEATONCEIN'|@getFixedLabel}</td>
									<td>
									<select name="repeat_frequency">
                                        {section name="repeat" loop=15 start=1 step=1}
                                        {if $smarty.section.repeat.iteration eq $RECURRINGVALUE.repeat_frequency}
                                                {assign var="test" value="selected"}
                                        {else}    {assign var="test" value=""}                                                                                                                                                                                                                  {/if}
                                        <option "{$test}" value="{$smarty.section.repeat.iteration}">{$smarty.section.repeat.iteration}</option>
                                        {/section}
                                    </select>
									</td>
									<td><select name="recurringtype" onChange="rptoptDisp(this)">
									<option value="Daily" {if $RECURRINGVALUE.eventrecurringtype eq 'Daily'} selected {/if}>{'Day'|@getFixedLabel}</option>
									<option value="Weekly" {if $RECURRINGVALUE.eventrecurringtype eq 'Weekly'} selected {/if}>{'Week'|@getFixedLabel}</option>
								    <option value="Monthly" {if $RECURRINGVALUE.eventrecurringtype eq 'Monthly'} selected {/if}>{'MONTH'|@getFixedLabel}</option>
									<option value="Yearly" {if $RECURRINGVALUE.eventrecurringtype eq 'Yearly'} selected {/if}>{'YEAR'|@getFixedLabel}</option>
									</select>
									<!-- Repeat Feature Enhanced -->
									<b>{'TO'|@getFixedLabel}</b> <input type="text" name="calendar_repeat_limit_date" id="calendar_repeat_limit_date" class="Wdate" style="width:90px" value="" onClick="WdatePicker()" ></td><td align="left">
									<!--<img border=0 src="{$IMAGE_PATH}btnL3Calendar.gif" alt="{$MOD.LBL_SET_DATE}..." title="{$MOD.LBL_SET_DATE}..." id="jscal_trigger_calendar_repeat_limit_date">
									{literal}
										<script type="text/javascript">
										Calendar.setup ({inputField : "calendar_repeat_limit_date", ifFormat : {/literal}
"%Y-%m-%d"
{literal}, showsTime : false, button : "jscal_trigger_calendar_repeat_limit_date", singleClick : true, step : 1})</script>
									{/literal}
									 END -->
									</td>
								</tr>
								</table>
								<div id="repeatWeekUI" {$rptweekstyle}>
								<table border=0 cellspacing=0 cellpadding=2>
								<tr style="border:none;">
									<td><input name="sun_flag" value="sunday" {$RECURRINGVALUE.week0} type="checkbox"></td><td>{$MOD.LBL_SM_SUN}</td>
									<td><input name="mon_flag" value="monday" {$RECURRINGVALUE.week1} type="checkbox"></td><td>{$MOD.LBL_SM_MON}</td>
									<td><input name="tue_flag" value="tuesday" {$RECURRINGVALUE.week2} type="checkbox"></td><td>{$MOD.LBL_SM_TUE}</td>
									<td><input name="wed_flag" value="wednesday" {$RECURRINGVALUE.week3} type="checkbox"></td><td>{$MOD.LBL_SM_WED}</td>
									<td><input name="thu_flag" value="thursday" {$RECURRINGVALUE.week4} type="checkbox"></td><td>{$MOD.LBL_SM_THU}</td>
									<td><input name="fri_flag" value="friday" {$RECURRINGVALUE.week5} type="checkbox"></td><td>{$MOD.LBL_SM_FRI}</td>
									<td><input name="sat_flag" value="saturday" {$RECURRINGVALUE.week6} type="checkbox"></td><td>{$MOD.LBL_SM_SAT}</td>
								</tr>
								</table>
								</div>
								<div id="repeatMonthUI" {$rptmonthstyle}>
								<table border=0 cellspacing=0 cellpadding=2>
								<tr style="border:none;">
									<td>
										<table border=0 cellspacing=0 cellpadding=2>
										<tr>
										<td><input type="radio" checked name="repeatMonth" {if $RECURRINGVALUE.repeatMonth eq 'date'} checked {/if} value="date"></td><td>{$MOD.LBL_ENABLE_ON}</td><td>{$MOD.LBL_THE_MONTH}</td><td><input type="text" class=textbox style="width:20px" value="{$RECURRINGVALUE.repeatMonth_date}" name="repeatMonth_date" ></td><td>{$MOD.LBL_DAY_OF_THE_MONTH}</td>
										</tr>
										</table>
									</td>
								</tr>
								<tr style="border:none;">
									<td>
										<table border=0 cellspacing=0 cellpadding=2>
										<tr><td>
										<input type="radio" name="repeatMonth" {if $RECURRINGVALUE.repeatMonth eq 'day'} checked {/if} value="day"></td>
										<td>{'ACTIVATE'|@getFixedLabel}</td>
										<td>
										<select name="repeatMonth_daytype">
											<option value="first" {if $RECURRINGVALUE.repeatMonth_daytype eq 'first'} selected {/if}>{'THEFIRST'|@getFixedLabel}</option>
											<option value="last" {if $RECURRINGVALUE.repeatMonth_daytype eq 'last'} selected {/if}>{'THELAST'|@getFixedLabel}</option>
										</select>
										</td>
										<td>
										<select name="repeatMonth_day">
											<option value=1 {if $RECURRINGVALUE.repeatMonth_day eq 1} selected {/if}>{'Monday'|@getFixedLabel}</option>
											<option value=2 {if $RECURRINGVALUE.repeatMonth_day eq 2} selected {/if}>{'Tuesday'|@getFixedLabel}</option>
											<option value=3 {if $RECURRINGVALUE.repeatMonth_day eq 3} selected {/if}>{'Wednesday'|@getFixedLabel}</option>
											<option value=4 {if $RECURRINGVALUE.repeatMonth_day eq 4} selected {/if}>{'Thursday'|@getFixedLabel}</option>
											<option value=5 {if $RECURRINGVALUE.repeatMonth_day eq 5} selected {/if}>{'Friday'|@getFixedLabel}</option>
											<option value=6 {if $RECURRINGVALUE.repeatMonth_day eq 6} selected {/if}>{'Saturday'|@getFixedLabel}</option>
										</select>
										</td>
										</tr>
										</table>
									</td>
								</tr>
								</table>
								</div>
							</div>
						</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>				
		</div>    
             </td>   
          </tr>
         </table>        
  </td>
</tr>
						     