<link  rel="stylesheet" type="text/css" href="themes/softed/AccountAllView.css"/>
<div id="AccountAllView" style="border:none;">
	<form action="index.php" method="post" name="frmTemplatePrint">
        <input  type="hidden" name="templateprintid" value="{$templateprintid}"/>
        <input  type="hidden" name="module" value="Settings"/>
        <input  type="hidden" name="action" value="SaveTemplatePrint"/>
        <input  type="hidden" name="printtabid" value="{$printtabid}"/>
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
       {*
        使用提示：被共享的用户拥有该客户的查看权限，是否能够查看到更多信息受用户参数“允许查看客户全景”控制
        </div>
        *}   
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'APPLICABLEPERSONNEL'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('divPrintAllocate');" class="D_ptitc">
            <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <div class="scrollContent" style="height:220px;margin:10px auto;">
	<table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0" style="margin: 0px auto;">
        <tr><td>{'TEMPLATENAME'|@getFixedLabel}：{$templateprintname}</td></tr>
          <tr>
                <td  style="width:450px"><b>{'APPLICABLEPERSONNEL'|@getFixedLabel}：</b></td>
            </tr>
            {foreach item=userinfo from=$USERINFO}  
            <tr> 
                 {if $userinfo.2 neq 0}
                <td style="border-bottom: 1px dotted #C3C3C3">        
                {foreach item=user from=$userinfo.1}
                <span style="white-space:nowrap">  
                    <input id="{$user.userid}" type="checkbox" {if in_array($user.userid,$useridlist)} checked="true" {/if}
                    value="{$user.userid}" name="owners[]" 
                    class="StepUserClass"  groupname="{$userinfo.0.rolename}"/>
                <label for="M1">{$user.username}</label>       
                </span> 
                {/foreach}
                </td>
                {/if}
            </tr>
            {/foreach}
        
            <tr>
                <td width="100%">
                {'ROLES'|@getFixedLabel}：
                {foreach item=userinfo from=$USERINFO}
                <input id="{$userinfo.0.roleid}" type="checkbox" value="" onclick="select_all(this,'{$userinfo.0.rolename}');">
                <label for="group1">{$userinfo.0.rolename}</label>      
                {/foreach}
                </td>
            </tr>
        </table>
        </div>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveTemplatePrintAllocate(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('divPrintAllocate');puyoungJS_DialogBox.unblock()"/>
    </div>
    </form>
</div>