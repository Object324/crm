{*<!--

/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
<!--修改编码格式:统一编码：UTF-8-->
-->*}

<script type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<link href="themes/softed/Control.css?v={$GLOBALMINVERSION}" rel="stylesheet" type="text/css" />
<div class="DivL_Control">
	<h2 style="margin:0px;">{'CONTROLPANEL'|@getFixedLabel}</h2>
    
    {foreach key=BLOCKID item=BLOCKLABEL from=$BLOCKS name=itr}
	{if $BLOCKLABEL neq 'LBL_MODULE_MANAGER'}
	
        {assign var=count value=$smarty.foreach.itr.iteration}
        <a class="Title" id="controlTitle_{$count}" onclick="showControl(this,{$count});"><!--<span class="Icon {$ICONIMG[$count]} F_l">icon</span>-->
            <span class="Name" style="padding-left:0px;">{$BLOCKLABEL|@getFixedLabel}</span><span class="Icon F_r">Icon</span>
        </a>
        {if  $BLOCKID eq $smarty.request.blockidsetting}
        {*if  $BLOCKID eq $BLOCKIDSETTING*}
        <ul style="display:block;margin:0px;" class="ControlUl" id="controlUl_{$count}">
        {else}
        <ul style="display:none;margin:0px;" class="ControlUl" id="controlUl_{$count}">
        {/if}
            {*editor:gyq_104 reason:小程序设置优化  2019/3/4 17:48 *}
        {if $SelfServiceConfig_Step eq ''}
            {foreach item=data from=$FIELDS.$BLOCKID}
               {if $data.link neq ''}
                    {assign var=label value=$data.name}
                    {if $smarty.request.action eq $data.action && $smarty.request.module eq $data.module  || $data.fieldid eq $FIELDIDSETTING}
                        <li><a {if $data.name eq 'LBL_AUTHENINFO'} target="_blank"{/if}  href="{$data.link}&blockidsetting={$BLOCKID}&fieldidsetting={$data.fieldid}" class="On" style="padding: 5px 10% 5px 5%;"><i class="ico-dot"></i>{$label|@getFixedLabel}</a></li>
                    {else}
                        <li><a {if $data.name eq 'LBL_AUTHENINFO'} target="_blank"{/if}  href="{$data.link}&blockidsetting={$BLOCKID}&fieldidsetting={$data.fieldid}" style="padding: 5px 10% 5px 5%;"><i class="ico-dot"></i>{$label|@getFixedLabel}</a></li>
                    {/if}
               {/if}
            {/foreach}
        {else}
            {foreach item=data from=$FIELDS.$BLOCKID}
                {if $data.link neq ''}
                    {assign var=label value=$data.name}
                    {if  $data.fieldid eq $FIELDIDSETTING}
                        <li><a {if $data.name eq 'LBL_AUTHENINFO'} target="_blank"{/if}  href="{$data.link}&blockidsetting={$BLOCKID}&fieldidsetting={$data.fieldid}" class="On" style="padding: 5px 10% 5px 5%;"><i class="ico-dot"></i>{$label|@getFixedLabel}</a></li>
                    {else}
                        <li><a {if $data.name eq 'LBL_AUTHENINFO'} target="_blank"{/if}  href="{$data.link}&blockidsetting={$BLOCKID}&fieldidsetting={$data.fieldid}" style="padding: 5px 10% 5px 5%;"><i class="ico-dot"></i>{$label|@getFixedLabel}</a></li>
                    {/if}
                {/if}
            {/foreach}
        {/if}
        </ul>
	{/if}
    {/foreach}    

</div>
<script type="text/javascript">
  var module='{$MODULE}';
{literal}
  //18070: 控制面板>用户管理：点击下一页或上一页后，查看用户， 结果：用户管理页签收起。
 if(module=='Users')
 {
    var obj=document.getElementById('controlTitle_1');
    showControl(obj,1);
 }
function showControl(obj,fori){
    var inputs = $$(".ControlUl");
    for(var i=0;i<inputs.length;i++){
        inputs[i].style.display = 'none';
        document.getElementById('controlTitle_'+(i+1)).className = 'Title';
    }
    document.getElementById('controlUl_'+fori).style.display = 'block';
    obj.className = 'Title TitleOn';
}
{/literal}
</script>

