<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
<div style="padding:0px 5px 10px;margin:0 auto;">
<div style="color:#3382b6;font-weight:bold;padding:5px 0px;"><font style="font-size:16px;">{'CHECKTHEDAILY'|@getFixedLabel} —— {'ASUMMARYOFALLUSERS'|@getFixedLabel}</font> {$STARTDATE}({$WEEK})</div>
<table class="listEntries listEntriesSpace" cellpadding="0" cellspacing="1" style="width:100%;"> 
    <thead>
        <tr>
            <th width="8%">{'LBL_USERS'|@getFixedLabel}</th>
            <th width="10%">{'SUBMITTIME'|@getFixedLabel}</th>
            <th width="32%">{'DAILYSUMMARY'|@getFixedLabel}</th>
            <th width="30%">{'PLANS'|@getFixedLabel}</th>
            <th width="20%">{'Reply'|@getFixedLabel}</th>
        </tr>
    </thead>
    <tbody>
    {assign var="i" value=0}
    {foreach key=value item=data from=$REPORTINFO}
    {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
            <tr id="row_{$j}" class="lvtColData" onmouseout="listOnMouseOut({$j},'on');" onmouseover="listOnMouseOver({$j});">
        {else}
            <tr id="row_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut({$j},'On');" onmouseover="listOnMouseOver({$j});">
        {/if}
            <td>{$data.username}</td>
            <td>{$data.submitdate}</td>
            <td>{$data.worksummary}</td>
            
            <td>{$data.tomorrowplan}</td>
            
            <td>
            {foreach item=comments from=$COMMENTS.$value} 
                {$comments.commentcontent}
                {if $comments.commentor neq ''}
             <font color="darkred">    {'Author'|@getFixedLabel}:               
        {$comments.commentor}&nbsp;&nbsp; {'Added'|@getFixedLabel} {$comments.commentdate}</font><br />
        {/if}
         {/foreach}
            </td>
            
        </tr>
        {/foreach}
    </tbody>
</table>
</div>