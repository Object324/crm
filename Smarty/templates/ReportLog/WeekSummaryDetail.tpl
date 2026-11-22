<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" name="start" value="{$START}"/>
<input type="hidden" name="end" value="{$END}"/>
<input type="hidden" name="syear" value="{$SYEAR}"/>
<input type="hidden" name="eyear" value="{$EYEAR}"/>
<table cellspacing="0" cellpadding="3" border="0" width="100%" style="margin-top:10px;">
    <tr>
        <td align="center" style="font-size: 20px;color:#555;">
        <a onclick="submitdate('{$LAST}')" href="javascript:void(0)">&lt;&lt;</a>         
           {if $languageType eq "en"}
            {'Week'|@getFixedLabel} {$START} of {$SYEAR} ~ {'Week'|@getFixedLabel} {$END} of {$EYEAR} {'WEEKREPORT'|@getFixedLabel}   
           {else}
            {$SYEAR}{'nYear'|@getFixedLabel} {$START}{'Week'|@getFixedLabel} ~ {$EYEAR}{'nYear'|@getFixedLabel} {$END}{'Week'|@getFixedLabel} {'WEEKREPORT'|@getFixedLabel}
           {/if}
           {if $DISPLAYEND eq 1}
           <a onclick="submitdate('{$NEXT}')" href="javascript:void(0)">&gt;&gt;</a> 
           {/if}
        </td>
    </tr>
</table>
<table class="ReportLogTab" cellspacing="0" cellpadding="0" width="100%">
    <thead>
    <tr>
        <th width="10%">{'Time'|@getFixedLabel}</th>
        {foreach item=data from=$WEEKHEAD}
        <th width="15%" nowrap="">
        {if $languageType eq "en"}
            {'Week'|@getFixedLabel} {$data.ofyear} <!--of {$data.year}-->{'Week'|@getFixedLabel}({$data.ed}~{$data.sd})
        {else}
            <!--{$data.year}{'YEAR'|@getFixedLabel}-->{$data.ofyear}{'Week'|@getFixedLabel}({$data.ed}~{$data.sd})
        {/if}
        </th>
        {/foreach}
    </tr>
    </thead>
    <tbody>
    {foreach item=data from=$ALLCONTENTS}

        <tr valign="top">        
            <td width="10%" nowrap="">{$data.0.0}</td>
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