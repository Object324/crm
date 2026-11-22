<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" name="monthstart" value="{$MONTHSTART}"/>
<input type="hidden" name="monthend" value="{$MONTHEND}"/>
<input type="hidden" name="monthsyear" value="{$MONTHSYEAR}"/>
<input type="hidden" name="montheyear" value="{$MONTHEYEAR}"/>

<table cellspacing="0" cellpadding="3" border="0" width="100%" style="margin-top:10px;">
    <tr>
        <td align="center" style="font-size: 20px;color:#555;">
        <!--<a href="index.php?module=ReportLog&action=WeekAndMonthSummary&monthdate={$MONTHLAST}"><<</a>-->
        <a onclick="submitdate('{$MONTHLAST}')" href="javascript:void(0)">&lt;&lt;</a>
           {if $languageType eq "en"}
                {'nMonth'|@getFixedLabel} {$MONTHSTART} of {$MONTHSYEAR} ~ {'nMonth'|@getFixedLabel} {$MONTHEND} of {$MONTHEYEAR} {'MONTHREPORT'|@getFixedLabel}
           {else}
                {$MONTHSYEAR}{'nYear'|@getFixedLabel} {$MONTHSTART}{'nMonth'|@getFixedLabel} ~ {$MONTHEYEAR}{'nYear'|@getFixedLabel} {$MONTHEND}{'nMonth'|@getFixedLabel} {'MONTHREPORT'|@getFixedLabel}   
           {/if}
           {if $DISPLAYEND eq 1}
           <a onclick="submitdate('{$MONTHNEXT}')" href="javascript:void(0)">&gt;&gt;</a>
          <!-- <a href="index.php?module=ReportLog&action=WeekAndMonthSummary&monthdate={$MONTHLAST}">>></a>-->
           {/if}
        </td>
    </tr>
</table>
<table class="ReportLogTab" cellspacing="0" cellpadding="0" width="100%">
    <thead>
    <tr>
        <th width="10%">{'TIME'|@getFixedLabel}</th>
        {foreach item=data from=$MONTHHEAD}
        <th width="15%" nowrap="">
        {if $languageType eq "en"}
            {'nMonth'|@getFixedLabel} {$data.ofyear} <!--of {$data.year}-->({$data.ed}~{$data.sd})
        {else}
            <!--{$data.year}{'YEAR'|@getFixedLabel}-->{$data.ofyear}{'nMonth'|@getFixedLabel}({$data.ed}~{$data.sd})
        {/if}
        </th>
        {/foreach}
    </tr>
    </thead>
    <tbody>
        {foreach item=data from=$ALLCONTENTS}

        <tr valign="top">        
            <td width="10%" nowrap="nowrap">{$data.0.0}</td>
            {foreach key=k item=detail from=$data.0.1}
            <td width="15%">            
            {$detail.worksummary}
            <br>            
            {$detail.nextworkplan} <br />  
            {if $data.1.$k|@count}         
            <b>{'Reply'|@getFixedLabel}:</b>
            {/if}
            {foreach item=comment from=$data.1.$k}
            {$comment.commentcontent}
            {/foreach}
            {$detail.url}        
            </td>         
          {/foreach}
        </tr>

    {/foreach}
    </tbody>
</table>