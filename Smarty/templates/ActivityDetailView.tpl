<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script>
{assign var=email_info value=$ACTIVITYDATA.0}
{assign var=remind_info value=$ACTIVITYDATA.1}
{assign var=remind_content value=$ACTIVITYDATA.2}
<input type=hidden name="inviteesid" id="inviteesid" value="">
<tr>
   <td>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF">
        <tr>
            <td>
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td id="cellTabLoop" name="cellTabLoop" class="dvtSelectedCellCommon dvtSelectedCell height20" align="center" nowrap="nowrap" onClick="Calendar_switchClass('cellTabLoop');">
                            <a href="javascript:doNothing()">{'循环日程'|@getFixedLabel}</a>
                        </td>
                        <td class="dvtTabCache height20" style="width:10px" nowrap>&nbsp;</td>

                        <td id="cellTabAlarm" name="cellTabAlarm" class="dvtUnSelectedCell height20" align="center" onClick="Calendar_switchClass('cellTabAlarm');" nowrap>
                            <a href="javascript:doNothing()">{'REMINDS'|@getFixedLabel}</a>
                        </td>
                        <td class="dvtTabCache height20" style="width:10px" nowrap>&nbsp;</td>
                        <td id="cellTabInvite" name="cellTabInvite" class="dvtUnSelectedCell tbHeight" align="center" onClick="Calendar_switchClass('cellTabInvite');" nowrap>
                            <a href="javascript:doNothing()">{'INVITE'|@getFixedLabel}</a>
                        </td>
                        <td class="dvtTabCache height20" style="width:10px">&nbsp;</td>
                        <!-- <td id="cellTabRepeat" class="dvtUnSelectedCell" align=center nowrap><a href="javascript:doNothing()" onClick="switchClass('cellTabAlarm','off');switchClass('cellTabInvite','off');switchClass('cellTabRepeat','on');ghide('addEventAlarmUI');gshow('addEventRepeatUI','','','','','','','','','');ghide('addEventRelatedtoUI');">{'REPEAT'|@getFixedLabel}</a></td> -->
                        <td class="dvtTabCache height20" style="width:10px">&nbsp;</td>
                        <td class="dvtTabCache height20" colspan="2" style="width:100%">&nbsp;</td>
                    </tr>
                 </table>
            </td>
        </tr>
        <tr>
            <td width=100% valign=top align=left class="dvtContentSpace">
                <!--循环日程-->
                <div id="addEventLoopUI" name="addEventLoopUI" style="width:100%;display:block;">
                    <table>
                        <tr class="ld-form-item">
                            <td class="ld-form-item-label">
                                {'LoopSchedule'|@getFixedLabel}
                            </td>

                            <td class="ld-form-item-content" name="td_cmb_loop_type">
                                {$ACTIVITYDATA.loop_setting_info.loop_description}
                            </td>

                        </tr>

                        {*提醒设置*}
                        <tr class="ld-form-item" name="tr_reminder_setting">
                            <td class="ld-form-item-label">
                                {'ReminderSettings'|@getFixedLabel}
                            </td>

                            <td class="ld-form-item-content" name="td_reminder_setting">
                                {$ACTIVITYDATA.loop_setting_info.reminder_description}
                            </td>
                        </tr>

                        {*到期日期*}
                        {if $ACTIVITYDATA.loop_setting_info.loop_type neq 'norepeat'}
                        <tr class="ld-form-item" name="tr_expiredate">
                            <td class="ld-form-item-label">
                                {'ExpireDate'|@getFixedLabel}
                            </td>

                            <td class="ld-form-item-content" name="td_expiredate">
                                {$ACTIVITYDATA.loop_setting_info.expiredate}
                            </td>
                        </tr>
                        {/if}

                    </table>

                </div>

                <!--提醒-->
                <div name="addEventAlarmUI" id="addEventAlarmUI" style="display:none;width:100%">
                    <table class="DetailContentTable" width="100%" cellspacing="0" border="0">
                        <tr>
                            <td class="DetailedTd1Label" width="20%" align=right>{'SENDEMAILREMINDER'|@getFixedLabel}：</td>
                            <td class="DetailedTd2Info" width="80%" align=left>{$ACTIVITYDATA.set_reminder}　　{if $ACTIVITYDATA.set_reminder != 'NO'|@getFixedLabel}{'REMINDS'|@getFixedLabel}:&nbsp;&nbsp;{$ACTIVITYDATA.reminder_str}{/if}</td>
                        </tr>
                    </table>
                    <table class="DetailContentTable" width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td class="DetailedTd1Label" width="20%" align=right>{'POPMESSAGENOTICE'|@getFixedLabel}：</td>
                            <td class="DetailedTd2Info" width="80%" align=left>{$ACTIVITYDATA.date_time}　　{if $ACTIVITYDATA.date_time != 'NO'|@getFixedLabel}{'REMINDS'|@getFixedLabel}:&nbsp;&nbsp;{$ACTIVITYDATA.date_str}{/if}</td>
                        </tr>
                    </table>
                </div>
                <!--邀请-->
                <div name="addEventRelatedtoUI" id="addEventRelatedtoUI" style="display:none;width:100%; ">
                    <table class="DetailContentTable" width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td class="DetailedTd1Label" width="20%" align=right>{'USERHASSELECTED'|@getFixedLabel}:</td>
                            <td class="DetailedTd2Info" width="80%" align=left>
                                {if count($INVITEDUSERS) neq 0}
                                    {foreach item=username key=userid from=$INVITEDUSERS}
                                        {$username}
                                    {/foreach}
                                {else}
                                    {'NONE'|@getFixedLabel}
                                {/if}
                            </td>
                        </tr>
                    </table>
                </div>
                <!--重复-->
                <div id="addEventRepeatUI" style="display:none;width:100%;">
                    <table class="DetailContentTable" width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td class="DetailedTd1Label" width="20%" align=right>{'ENABLEREPEAT'|@getFixedLabel}</td>
                            <td class="DetailedTd2Info" width="80%" align=left>{$ACTIVITYDATA.recurringcheck}</td>
                        </tr>
                        {if $ACTIVITYDATA.repeat_str neq ''}
                        <tr>
                            <td class="DetailedTd1Label" align=right>&nbsp;</td>
                            <td class="DetailedTd2Info">{'REPEATONCEIN'|@getFixedLabel}&nbsp;{$ACTIVITYDATA.repeat_frequency}&nbsp;{$MOD[$ACTIVITYDATA.recurringtype]}</td>
                        </tr>
                        <tr>
                            <td class="DetailedTd1Label" align=right>&nbsp;</td>
                            <td class="DetailedTd2Info">{$ACTIVITYDATA.repeat_str}</td>
                        </tr>
                        {/if}
                    </table>
                </div>
            </td>
        </tr>
        </table>
    </td>
</tr>