<link  rel="stylesheet" type="text/css" href="themes/softed/selfstyle.css"/>
<form action="index.php" method="post" name="frmPotentialstShare">
<input  type="hidden" name="potentialid" value="{$POTENTIALSID}"/>
<input  type="hidden" name="module" value="Potentials"/>
<input  type="hidden" name="action" value="SavePotentialsShare"/>

<div class="D_pop_tit">
	<strong class="D_ptita">{'SHARE'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('divPotentialsShare');" class="D_ptitc">
        <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
  <tr>
    <td>
        
		<div class="divPeople-Content">
            {'TQTUHTBSPSOARI'|@getFixedLabel}
        </div>
        <div class="divPeople-Title">
            {'DATAFORALL'|@getFixedLabel}：{$SMOWNERNAME}
        </div>
        <div class="scrollContent" style="margin: 10px auto;height:150px;">
            <div class="divPeople-Title">
                {'SHAREFOR'|@getFixedLabel}：
            </div>
            <ul class="People-List">
                {foreach item=userinfo from=$USERINFO}  
                    {if $userinfo.2 neq 0}
                        <li>  
                        {foreach item=user from=$userinfo.1}
                            {if $user.chkbox eq 0}   <!--未共享-->   
                                <div class="Character-Names">
                                    <input id="{$user.userid}" type="checkbox" value="{$user.userid}" name="owners[]" 
                                    class="StepUserClass"  groupname="{$userinfo.0.rolename}" />
                                    {$user.username}
                                </div>
                            {else}<!--已共享-->
                                 {if $SHARINGSETTINGS != 'disabled'}
    								<div class="Character-Names">
                                        <input id="{$user.userid}" type="checkbox"  checked="true" value="{$user.userid}" name="owners[]" class="StepUserClass"  groupname="{$userinfo.0.rolename}">
                                        {$user.username}
                                    </div>
    							 {else}
    								<div class="Character-Names">
    									<input type="checkbox" disabled="true" checked="true" {$SHARINGSETTINGS} class="StepUserClass" groupname="{$userinfo.0.rolename}">
                                        {$user.username}
    									<input type="hidden" name="owners[]" id="{$user.userid}" value="{$user.userid}"/>
    								</div>
    							 {/if}
                            {/if}
                        {/foreach}
                        <div class="clear"></div>
                        </li>
                    {/if}
                {/foreach}
            </ul>
            <div class="divPeople-Title">
                {'LBL_ROLES'|@getFixedLabel}：
            </div>
            <div class="Role">
           		{foreach item=userinfo from=$USERINFO}
                    <div class="Character-Names">
                        <input id="{$userinfo.0.roleid}" type="checkbox" value="" onclick="select_all(this,'{$userinfo.0.rolename}');" />
                        {$userinfo.0.rolename}
                    </div>
               {/foreach}
           		<div class="clear"></div>
           </div>
       </div>
    </td>
  </tr>
</table>
<div class="D_pbtn">
	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SavePotentialstShare(this)" /><span>&nbsp;</span>
    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('divPotentialsShare');"/>  
</div>
</form>