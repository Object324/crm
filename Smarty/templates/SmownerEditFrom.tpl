<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script type='text/javascript' src='{$JSURL}include/js/user_approveby.js'></script>
<form class="ld-massedit-form" name="EditView" id="massedit_form" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
	<input id="idstring" value="{$IDS}" type="hidden" />
	<input type="hidden" name="massedit_recordids" value="{$IDSTRINGSMOWNERIDS}"/>
	<input type="hidden" name="massedit_module"/>
	{if $MODULE eq 'Accounts' || $MODULE eq 'Potentials'}
		<input type="hidden" name="module" value="{$MODULE}"/>
	{else}
		<input type="hidden" name="module" value="Users"/>
	{/if}
	<input type="hidden" name="action" value="SmownerEditSave"/>
    <input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
    <input  type="hidden" name="assign_name" value="{$SMOWNERIDS}" id="assign_name"/>
    <input type="hidden" name="return_action" id="return_action" value="{$RETURN_ACTION}" />
	<input type="hidden" name="return_module" id="return_module" value="{$RETURN_MODULE}" />
	<input type="hidden" name="from_module" id="from_module" value="{$MODULE}" />
    <input type="hidden" name="assigntype" value="US" />
    <input  type="hidden" name="mass_allocate_totalrows" value="{$TOTALSELECTROWS}" id="mass_allocate_totalrows"/>					
	{foreach key=header name=block item=data from=$BLOCKS}
	{if $smarty.foreach.block.index eq 0}    					    						
      {assign var="fromlink" value=""}
      {foreach key=label item=subdata from=$data}
        {foreach key=mainlabel item=maindata from=$subdata}
            {assign var="uitype" value="$maindata[0][0][0]"}
            {assign var="fldlabel" value="$maindata[1][0]"}
            {assign var="fldlabel_sel" value="$maindata[1][1]"}
            {assign var="fldlabel_combo" value="$maindata[1][2]"}
            {assign var="fldlabel_other" value="$maindata[1][3]"}
            {assign var="fldname" value="$maindata[2][0]"}
            {assign var="fldvalue" value="$maindata[3][0]"}
            {assign var="secondvalue" value="$maindata[3][1]"}
            {assign var="thirdvalue" value="$maindata[3][2]"}
            {assign var="typeofdata" value="$maindata[4]"}
            {assign var="vt_tab" value="$maindata[5][0]"}
            {if $typeofdata eq 'M'}
                {assign var="mandatory_field" value="*"}
            {else}
                {assign var="mandatory_field" value=""}
            {/if}
            {assign var="usefldlabel" value=$fldlabel}
            {assign var="fldhelplink" value=""}
             {if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
                {assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}                           
                {if $uitype neq '10'}
                    {assign var="usefldlabel" value="$fldlabel $fldhelplink"}
                {/if}
            {/if}
            {if $uitype eq 53}
            <div class="D_pop_tit">
            	<strong class="D_ptita">{'ALLOCATE'|@getFixedLabel}</strong>
                <a href="javascript:fninvshnew('smowneredit');" class="D_ptitc">
                    <img style="margin:5px 0px 0px 4px;padding:0px;" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                </a>
            </div>
			<div id="div_share">
				<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
				  <tr>
                   {if $MODULE eq 'ServiceCharge'}
                    {assign var=usefldlabel value='MODIFYTHESERVICECHARGEFOR'|@getFixedLabel}
                   {else}
					 {assign var=usefldlabel value=$TRANSFERMESSAGER|@getFixedLabel}
                    {/if}
					 
					{include file='DetailView/AllocateSmowner.tpl'}
				
				  </tr>
				</table> 
			</div>
			<div class="D_pbtn">
				<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" /><span>&nbsp;</span>
				<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('smowneredit');"/>
				<!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
			</div>  
			
            {/if}
        {/foreach}
      {/foreach}
    {else}
        {assign var="fromlink" value=""}
      {foreach key=label item=subdata from=$data}
        {foreach key=mainlabel item=maindata from=$subdata}
            {assign var="uitype" value="$maindata[0][0][0]"}
            {assign var="fldlabel" value="$maindata[1][0]"}
            {assign var="fldlabel_sel" value="$maindata[1][1]"}
            {assign var="fldlabel_combo" value="$maindata[1][2]"}
            {assign var="fldlabel_other" value="$maindata[1][3]"}
            {assign var="fldname" value="$maindata[2][0]"}
            {assign var="fldvalue" value="$maindata[3][0]"}
            {assign var="secondvalue" value="$maindata[3][1]"}
            {assign var="thirdvalue" value="$maindata[3][2]"}
            {assign var="typeofdata" value="$maindata[4]"}
            {assign var="vt_tab" value="$maindata[5][0]"}
            {if $typeofdata eq 'M'}
                {assign var="mandatory_field" value="*"}
            {else}
                {assign var="mandatory_field" value=""}
            {/if}
            {assign var="usefldlabel" value=$fldlabel}
            {assign var="fldhelplink" value=""}
             {if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
                {assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}                           
                {if $uitype neq '10'}
                    {assign var="usefldlabel" value="$fldlabel $fldhelplink"}
                {/if}
            {/if}
            {if $uitype eq 53}
                <div class="D_pop_tit">
                	<strong class="D_ptita">{'ALLOCATE'|@getFixedLabel}</strong>
                    <a href="javascript:fninvshnew('smowneredit');" class="D_ptitc">
                        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                    </a>
                </div>
				<div id="div_share">
					<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
						<tr>
							  {if $MODULE eq 'ServiceCharge'}
                                {assign var=usefldlabel value='MODIFYTHESERVICECHARGEFOR'|@getFixedLabel}
                               {else}
            					 {assign var=usefldlabel value=$TRANSFERMESSAGER|@getFixedLabel}
                                {/if}

							{include file='DetailView/AllocateSmowner.tpl'}
						</tr>
					</table>
               	</div>  
                <div class="D_pbtn">
                	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" /><span>&nbsp;</span>
                    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('smowneredit');"/>
                    <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
                </div>                           
            {/if}
        {/foreach}
      {/foreach}  
	{/if}
	{/foreach}				
</form>