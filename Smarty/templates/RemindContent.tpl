<!--修改编码格式:统一编码：UTF-8-->
{assign var=email_info value=$ACTIVITYDATA.0}       
{assign var=remind_info value=$ACTIVITYDATA.1} 
{assign var=remind_content value=$ACTIVITYDATA.2} 
                                 
<tr>
   <td colspan="4" style="padding:5px;">
       <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF">
		<tr>
			<td>
				<table border="0" cellpadding="3" cellspacing="0" width="100%">
					<tr>
						<td class="dvtTabCache" style="width:10px" nowrap>&nbsp;</td>
                        <td id="cellTabAlarm" class="dvtSelectedCellCommon dvtSelectedCell" align=center nowrap>
                        <a href="javascript:doNothing()" onClick="gshow('addEventAlarmUI','',document.EditView.date_start.value,document.EditView.due_date.value,document.EditView.starthr.value,document.EditView.startmin.value,document.EditView.startfmt.value,document.EditView.endhr.value,document.EditView.endmin.value,document.EditView.endfmt.value);">
                        {$MOD.LBL_REMINDER}
                        </a>
                        </td>
                        <td class="dvtTabCache" style="width:100%">&nbsp;</td>
                    </tr>
                 </table>
            </td>
          </tr>
          <tr>
             <td width=100% valign=top align=left class="dvtContentSpace" style="padding:10px;height:120px">
                <div id="addEventAlarmUI" style="width:100%">
                    <!--email remind-->
                    <table>
						{assign var=secondval value=$email_info}
                                                      
						<tr><td>{$MOD.reminder_time}</td><td>

					{if $secondval.1 eq 1}
						{assign var=emailremind value="style='display:block;width:100%;'"}
						<input type="radio" id="set_remind" name="set_remind" value="Yes" checked onClick="reset_remindtime(0);showBlock('reminderOptions')">&nbsp;{$MOD.yes_val}&nbsp;
						<input type="radio" name="set_remind" value="No" onClick="fnhide('reminderOptions')">&nbsp;{$MOD.no_val}&nbsp;

					{else}
						{assign var=emailremind value="style='display:none;width:100%;'"}
						<input type="radio" id="set_remind" name="set_remind" value="Yes" onClick="reset_remindtime(0);showBlock('reminderOptions')">&nbsp;{$MOD.yes_val}&nbsp;
						<input type="radio" name="set_remind" value="No" checked onClick="fnhide('reminderOptions')">&nbsp;{$MOD.no_val}&nbsp;

					{/if}
						</td></tr>
					</table>
                    <!--邮件提醒-->
					<DIV id="reminderOptions" {$emailremind}>
						<table border=0 cellspacing=0 cellpadding=2  width=100%>
							<tr>
								<td nowrap align=right width=20% valign=top><b><font color="red">*</font>{$MOD.LBL_RMD_ON} : </b></td>
								<td width=80%>
									<table border=0>
									<tr>
										<td>
                                       
						                       <input type="hidden" name="email_remind"  value="{$secondval.0}"/>
                                              
                                				<input name="email_date_only" id="jscal_field_email_remind"  style="border:1px solid #bababa;width:150px;" size="15" maxlength="10" value="{$secondval.0}" onClick="WdatePicker()" class="Wdate"/>
                                                <input type="hidden" name="email_time" id="email_time">
                                				</td>
                                                <td>
                                                 <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_email_remind">-->
                                                </td>
                                               
										</tr>
                                        
									</table>
								</td>
							</tr>
						
						</table>
					</DIV>
                    <!--popup remind-->

					<table> 
		           {assign var=datetime_val value=$remind_info}                                                                                           
						<tr><td>{'POPMESSAGENOTICE'|@getFixedLabel}</td><td>

					{if $datetime_val.1 eq 1}
						{assign var=popremind value="style='display:block;width:100%;'"}
						<input type="radio" id="pop_reminds" name="pop_reminds" value="Yes" checked onClick="reset_remindtime(1);showBlock('reminderOptions2')">&nbsp;{$MOD.yes_val}&nbsp;
						<input type="radio" name="pop_reminds" value="No" onClick="fnhide('reminderOptions2')">&nbsp;{$MOD.no_val}&nbsp;

					{else}
                        {assign var=popremind value="style='display:none;width:100%;'"}				
						<input type="radio" id="pop_reminds" name="pop_reminds" value="Yes" onClick="reset_remindtime(1);showBlock('reminderOptions2')">&nbsp;{$MOD.yes_val}&nbsp;
						<input type="radio" name="pop_reminds" value="No" checked onClick="fnhide('reminderOptions2')">&nbsp;{$MOD.no_val}&nbsp;

					{/if}
						</td></tr>
					</table>
                    <!---弹出框提醒---->
					<DIV id="reminderOptions2" {$popremind}>
    						<table border=0 cellspacing=0 cellpadding=2  width=100%>
    							<tr>
    								<td nowrap align=right width=20% ><b><font color="red">*</font>{'REMINDS'|@getFixedLabel} : </b></td>
    								<td width=80%>
    									<table border=0>
    									<tr>
    										<td>
    						                       <input name="date_time"  type="hidden" value="{$datetime_val.0}">
                                    				<input name="date_only" id="jscal_field_date_time"  style="border:1px solid #bababa;width:150px;" size="15" maxlength="10" value="{$datetime_val.0}" onClick="WdatePicker()" class="Wdate">
                                                    <input type="hidden" name="time_reminds" id="time_reminds">
                                    				</td>
                                                    <td>
                                                     <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_date_time">-->
                                                    </td>
                                                    
    										</tr>                                        
    									</table>
    								</td>
    							</tr>
                                </table>                            
                            	</DIV>
                                <!--提醒内容--->
                                {if $datetime_val.2 eq 1  || $secondval.2 eq 1}
                                {assign var=reminstyle value="style='display:block;width:100%;'"}
                                {if $ACTIVITYDATA.2 neq '' || $ACTIVITYDATA.3 neq ''}
                                {if $ACTIVITYDATA.2 neq ''}
                                {assign var=remind_content value=$ACTIVITYDATA.2}
                                {else}
                                 {assign var=remind_content value=$ACTIVITYDATA.3}
                                {/if}
                                {/if}
                                
                                {else}
                                {assign var=reminstyle value="style='display:none;width:100%;'"}
                                {/if}
                             <DIV id="reminderOptions3" {$reminstyle}>
                                     <table border=0 cellspacing=0 cellpadding=2  width=100%>
                                    <tr>
                                        <td nowrap align=right width=20%>
                                           <b><font color="red">*</font>{$MOD.remind_content} : </b>
                                        </td>
                                        <td width=80%>                                       
                                          <textarea class="detailedViewTextBox" rows="8" cols="90" onblur="this.className='detailedViewTextBox'" name="contents" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" tabindex="" id="detailedViewContent">{$remind_content}</textarea>                                                   
                                        </td>
                                    </tr>
        						
        						</table>
			             	</div>
	
                </div>
             </td>   
          </tr>
         </table>        
  <td>
</tr>