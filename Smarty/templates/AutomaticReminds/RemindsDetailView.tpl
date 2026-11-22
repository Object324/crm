<script language="JAVASCRIPT" type="text/javascript" src="include/js/AutomaticReminds.js?v={$GLOBALMINVERSION}"></script>

<form action="index.php" method="post" name="form" id="form" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveRemindsRule"/>
    <input type="hidden" name="blockid" id="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="record" id='record' value="{$RECORD}"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">{'BASICINFO'|@getFixedLabel}</th>
        </tr>
        <tr>
            <td width="20%" align="right"><font color="red">*</font>{'RULENAME'|@getFixedLabel}</td>
            <td width="80%">{$AUTOMATICREMINDS.0.name}</td>
        </tr>
        <tr>
            <td align="right"><font color="red">*</font>{'REMINDTIME'|@getFixedLabel}</td>
            <td>
                {if $AUTOMATICREMINDS.0.columnname eq 'dothis'}
                    {'custom'|@getFixedLabel}
                {else}
                    {$AUTOMATICREMINDS.0.columnname}
                {/if}
            </td>
        </tr>
        <tr style="display:none">
            <td align="right">{'ANNUALREMIND'|@getFixedLabel}</td>
            <td>
                {if $AUTOMATICREMINDS.0.annualremind eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>       
        {if $AUTOMATICREMINDS.0.columnname eq 'dothis'}
            <tr id="showcanlender">
                <td align="right">
                    {'STARTTIME'|@getFixedLabel} 
                </td>
                <td>
                    {$AUTOMATICREMINDS.0.startdate}
                </td>
            </tr>
        {/if}
        <tr>
            <td align="right"><font color="red">*</font>{'REMINDMODEL'|@getFixedLabel}</td>
            <td>
                {if $AUTOMATICREMINDS.0.remindway eq '1'}
                    {'FIXEDCYCLE'|@getFixedLabel}
                {else if $AUTOMATICREMINDS.0.remindway eq '3'}
                    {'ANNUALREMIND'|@getFixedLabel}
                {else}
                    {'APPOINTCYCLE'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        <tr>
            <td align="right"><font color="red">*</font>{'REMINDTIMES'|@getFixedLabel}</td>
            <td>
              {if $AUTOMATICREMINDS.0.remindway eq '1'}<!--固定周期提醒-->
                <span id="remindnums" >
                  {'EACH'|@getFixedLabel}
                  {$AUTOMATICREMINDS.0.remindday}
                  {'Days'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'TIXING'|@getFixedLabel}
                </span>
                {$AUTOMATICREMINDS.0.remindnum}{'TIME1'|@getFixedLabel}
              {else if $AUTOMATICREMINDS.0.remindway eq '3'}<!--每年提醒-->
                <span id="remindnums" >
                  {'AHEAD'|@getFixedLabel}
                  {$AUTOMATICREMINDS.0.remindday}
                  {'Days'|@getFixedLabel}
                </span>
              {else}
                {'TIXING'|@getFixedLabel}{$AUTOMATICREMINDS.0.remindnum}{'TIME1'|@getFixedLabel}
                <span id="remindhtml1" style="line-height:28px;">{$remindday1}</span>
              {/if}
            </td>
        </tr>
        <tr>
            <td align="right"><font color="red">*</font>{'REMINDMETHOD'|@getFixedLabel}</td>
            <td>
                {if $AUTOMATICREMINDS.0.remindmethod eq '0'}
                    {'DIALOG'|@getFixedLabel}+{'WEIXIN'|@getFixedLabel}
                {elseif $AUTOMATICREMINDS.0.remindmethod eq '1'}
                    {'EMAIL'|@getFixedLabel}
                {else}
                    {'SMS'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        <tr>
            <td align="right">{'Related_modules'|@getFixedLabel}</td>
            <td>{$mokuai_name}</td>
        </tr>
        <tr>
            <td colspan="2" class="f1"><font color="red">*</font>{'REMINDSCONTENT'|@getFixedLabel}</td>
        </tr>
        <tr>
            <td colspan="2" style="white-space: inherit;line-height: 24px;">
                {$AUTOMATICREMINDS.0.remindcontent}
            </td>
        </tr>
    </table>
                
    <div id="mnuTab" style="display: none;">
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr><th colspan="2">{'EASYTIMEFILTER'|@getFixedLabel}</th></tr>
            <tr>
               <td width="50%" align="right">{'Select_field'|@getFixedLabel} </td>
               <td width="50%">{$general.columnname}</td>
            </tr>
            <tr>
               <td align="right" class="dvtCellLabel">{'SELECT_TIME'|@getFixedLabel}</td>
                    {assign var=special value='/\d+/'}
                    {assign var=normal_last value='/last/'}
                    {assign var=normal_before value='/before/'}
                    {assign var=normal_next value='/next/'} 
                    {assign var=day value='Days'|@getFixedLabel}
                    {assign var=last value='LAST'|@getFixedLabel}
                    {assign var=before value='DAYSAGO'|@getFixedLabel }
                    {assign var=future value='FUTURE'|@getFixedLabel }
                    {assign var=after value='AFTERDAY'|@getFixedLabel } 
                    {if !empty($general.stdfilter) && $special|preg_match:$general.stdfilter:$matches eq 1}                                   
                        {assign var=normal_number value=$matches[0]}
                        {if $normal_last|preg_match:$general.stdfilter eq 1}                                   
                            {assign var=optText value=$last|cat:$normal_number|cat:$day}
                            <td>{$optText}</td>
                        {elseif $normal_before|preg_match:$general.stdfilter eq 1} 
                            {assign var=optText value=$normal_number|cat:$before}
                            <td>{$optText}</td>
                        {elseif $normal_next|preg_match:$general.stdfilter eq 1} 
                            {assign var=optText value=$future|cat:$normal_number|cat:$day}
                            <td>{$optText}</td>
                        {else} 
                            {assign var=optText value=$normal_number|cat:$after}
                            <td>{$optText}</td>
                        {/if}  
                    {else}
                        <td>{$general.stdfilter|@getFixedLabel}</td>
                    {/if}
            </tr>
            <tr>
               <td align="right">{'Start_Date'|@getFixedLabel} </td>
               <td>{$general.startdate}</td>
            </tr>
            <tr>
                <td align="right">{'End_Date'|@getFixedLabel} </td> 
                <td>{$general.enddate}</td>
            </tr>
        </table>
    </div>
    <div id="mnuTab2" style="display: block;">
        {include file='AutomaticReminds/AdvanceFilterRemindsdetial.tpl' SOURCE='customview'}
    </div>
</form>