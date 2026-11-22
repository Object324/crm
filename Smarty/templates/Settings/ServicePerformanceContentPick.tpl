<div style="display: flex">
    {foreach item=fieldvalue key=ky from=$DEPENCYFIELDVALUE}
        {assign var='fldname' value=$ky}
        {assign var='fldvalue'  value=$fieldvalue.0}
        {assign var='usefldlabel' value=$fieldvalue.1}
        {assign var="i" value=$i+1}
        {include file='Settings/serviceformancepick.tpl'}
    {/foreach}
</div>