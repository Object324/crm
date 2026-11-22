<!--排序div-->
<div id="sortoption" class="E_pop_box LdPopWidth300px" style="display:none; position: absolute; left: 200px; top: 200px; z-Index:9999;" >
    <div class="E_pop_tit">
    	<strong class="E_ptita">{'LBL_CHANGEORDER'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('sortoption');"></button>
    </div>
    <table class="D_pop_bod marB10" border="0" cellpadding="1" cellspacing="0">
        <td width="150">
            <input class="detailedViewTextBox" style="width: 200px; color: rgb(0, 0, 0);" type="text" onkeyup="_onsortoptionkeyup(this,'selectedAssmablyColumns')" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedlabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedlabel}" onblur="return _onsortoptionblur(this)" onfocus="return _onsortoptionfocus(this)" name="allmember">
            <select size="11" style="height: 230px;width:200px;" class="commonMultipleSelect" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="">
			    {foreach key=k item=sortOption from=$LIST_ENTRIES}
                    {if $LANGUAGETYPE == 'zh'}
			    	<option value="{$k}">{$sortOption.label.zh}</option>
                    {else}
                    <option value="{$k}">{$sortOption.label.en}</option>
                    {/if}
                {/foreach}
            </select>
        </td>
        <td width="30">
			<a class="icon-newhomearr icon-mup" style="margin-left: -4px;" href="javascript:;" onclick="ModuleDetailmoveUp('selectedAssmablyColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
			<a class="icon-newhomearr icon-mdown" style="margin-top: 15px;margin-left: -4px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedAssmablyColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
		</td>
    </table>
    <div class="E_pbtn">
    	<input type="button" name="save" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="sortModule({$TABID});"/><span>&nbsp;</span>
        <input type="button" name="cancel" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('sortoption');"/>  
    </div>
</div>

<!--列表信息-->
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
  <tr>
    <th width="60" title="{$LIST_HEADER.0}">#</th>
    <th width="" title="{$LIST_HEADER.1}">{$LIST_HEADER.1}</th>
    <th width="" title="{$LIST_HEADER.2}">{$LIST_HEADER.2}</th>
    <th width="130" title="{$LIST_HEADER.3}">{$LIST_HEADER.3}</th>
    <th width="130" title="{$LIST_HEADER.4}">{$LIST_HEADER.4}</th>
    <th width="200" title="{$LIST_HEADER.5}">{$LIST_HEADER.5}</th>
{*      // @edit:dong @date:2020/08/13 @reason: bug 0042402*}
{*    <th width="130" title="{$LIST_HEADER.6}">{$LIST_HEADER.6}</th>*}
    {if $LANGUAGETYPE eq 'en'}
    <th width="68">{'OPERATING'|@getFixedLabel}</th>
    {else}
    <th width="60">{'OPERATING'|@getFixedLabel}</th>
    {/if}
  </tr>
    {assign var="i" value=0}
	{foreach name=optionlist key=k item=optionvalues from=$LIST_ENTRIES}
    {assign var="j" value=$i++}
    {if $j mod 2 eq '0'}
        <tr id="setting_{$j}" class="lvtColData" onmouseout="settingListOnMouseOut({$j},'on');" onmouseover="settingListOnMouseOver({$j});">
    {else}
        <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="settingListOnMouseOut({$j},'On');" onmouseover="settingListOnMouseOver({$j});">
    {/if}
	<td>{$i}</td>
 	<td>
      	<span title="{$optionvalues.label.zh}">{$optionvalues.label.zh}</span>
	</td>
	<td>
        <span title="{$optionvalues.label.en}">{$optionvalues.label.en}</span>
	</td>
    <td>
        {if $optionvalues.presence eq 0}
            <input type="checkbox" onclick="change_tablefield_presence(this,{$optionvalues.id},'option_module_presence')" class="second_switch"  checked="" />
        {else}
            <input type="checkbox" onclick="change_tablefield_presence(this,{$optionvalues.id},'option_module_presence')" class="second_switch"  />
        {/if}
    </td>
    <td>
        {if $optionvalues.isdefault eq '1'}
            <input type="checkbox" onclick="change_tablefield_presence(this,{$optionvalues.id},'option_module_default')" class="second_switch"  checked="" />
        {else}
            <input type="checkbox" onclick="change_tablefield_presence(this,{$optionvalues.id},'option_module_default')" class="second_switch"  />
        {/if}
    </td>
{*        // @edit:dong @date:2020/07/23 @reason: 添加是否必填 列*}
    <td>
        {if $optionvalues.no_signin eq 'yes'}
            {$optionvalues.allowable_distance}{'metre'|@getFixedLabel}
        {else}
            {'notenabled'|@getFixedLabel}
        {/if}
    </td>
{*        // @edit:dong @date:2020/08/13 @reason: bug 0042402*}
{*    <td>
        {if $optionvalues.approve_demand eq '0' || $optionvalues.approve_status eq '-1'}
            <span title="{'NONE'|@getFixedLabel}">{'NONE'|@getFixedLabel}</span>
        {else}
            <span title="{'Approved'|@getFixedLabel}">{$optionvalues.approve_status}</span>
        {/if}
    </td>*}
    <td align="center">
        <a class="Anu3_a" onclick="fnvshobj(this,'editOption_{$k}')">{'EDIT'|@getFixedLabel}</a>
    </td>
</tr>
{/foreach}
</table>

<!--编辑div-->
<!--0025356: 控制面板>源单类型定制：点击编辑，弹出编辑属性弹出框，左边的列宽比例太小了。-->
<!--之前编辑div是放在列表循环中的，但是格式会受listEntries影响，现在拆出来，再遍历一次-->
{foreach name=optionlist key=k item=optionvalues from=$LIST_ENTRIES}
<div id="editOption_{$k}" class="E_pop_box LdPopWidth450px" style="display:none; position: absolute; left: 200px; top: 200px; z-Index:9999;" >
    <div class="E_pop_tit">
    	<strong class="E_ptita">{'EDITPROPERTIES'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('editOption_{$k}');"></button>
    </div>
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr id="">
            <td width="150" align="right">
                {'CNTAG'|@getFixedLabel}
            </td>
            <td align="left">
                    <input type="text" class="detailedViewTextBox" name="fieldlabel" disabled="" id="" value="{$optionvalues.label.zh}" />
            </td>
		</tr>
		<tr id="">
            <td align="right" >
                {'ENTAG'|@getFixedLabel}
            </td>
            <td align="left">
                <input type="text" class="detailedViewTextBox" name="fieldlabels" disabled="" id="" value="{$optionvalues.label.en}" />                        
            </td>
		</tr>
	         <tr>
           <td align="right">
           {'ALLOWDataRange'|@getFixedLabel}
           </td>
           	<td>
				<select name="datarang" id="datarang_{$k}" class="btn-radius-system">
					<option value="all" {if $optionvalues.datarang eq 'all'}selected{/if}>{'ALL'|@getFixedLabel}</option>
					<option value="permit" {if $optionvalues.datarang eq 'permit'}selected{/if}>{'ALLOWINQUIRE'|@getFixedLabel}</option>
				</select>
				</td>
        </tr>
		{if $optionvalues.approve_status != '-1'}
			<tr>
				<td align="right">
					{'APPROVEDEMAND'|@getFixedLabel}
				</td>
				<td>
					<select id="option_approve_{$k}" name="option_approve" class="btn-radius-system">
						<option value="0" {if $optionvalues.approve_demand eq '0'}selected{/if}>{'NONE'|@getFixedLabel}</option>
						<option value="1" {if $optionvalues.approve_demand eq '1'}selected{/if}>{$optionvalues.approve_status}</option>
					</select>
				</td>
			</tr>
		{else}
			<input type="hidden" value="0" id="option_approve_{$k}" name="option_approve" />
		{/if}
         <tr>
				<td align="right">
					{'MaxRowsShow'|@getFixedLabel}
				</td>
				<td>
					<select name="maxrowsshow" id="maxrowsshow_{$k}" class="btn-radius-system">
    	                <option value="1" {if $optionvalues.maxrowsshow eq '1'}selected{/if}>1</option>
						<option value="5" {if $optionvalues.maxrowsshow eq '5'}selected{/if}>5</option>
						<option value="10" {if $optionvalues.maxrowsshow eq '10'}selected{/if}>10</option>
                        <option value="15" {if $optionvalues.maxrowsshow eq '15'}selected{/if}>15</option>
                        <option value="20" {if $optionvalues.maxrowsshow eq '20'}selected{/if}>20</option>
                        <option value="50" {if $optionvalues.maxrowsshow eq '50'}selected{/if}>50</option>
                        <option value="100" {if $optionvalues.maxrowsshow eq '100'}selected{/if}>100</option>
					</select>
				</td>
			</tr>
 	  <tr>
            <td style="text-align: right;">
                <input id="option_presence_{$k}" class="second_switch" type="checkbox"
                    {if $optionvalues.presence eq '0'}
                    checked                          
                    {/if}
                >
            </td>
			<td align="left">
				{'OUTSIDESIGN'|@getFixedLabel}{'ACTIVATE'|@getFixedLabel}
			</td>
		</tr>
       
        <tr>
            <td style="text-align: right;">
                <input id="option_default_{$k}" class="second_switch" type="checkbox"
                    {if $optionvalues.isdefault eq '1'}
                    checked
                    {/if}
                >
            </td>					
			<td align="left">
                {'OUTSIDESIGN'|@getFixedLabel}{'Set_Default'|@getFixedLabel}
			</td>
            
		</tr>

{*        @edit:liushuai,2021-06-02,reason:【ID1001653】签到源单类型定制，增加参数“拜访签到上传图片添加水印”（第一版）*}
        <tr>
            <td style="text-align: right;">
                <input id="option_uploadwatermark_{$k}" class="second_switch" type="checkbox"
                        {if $optionvalues.uploadwatermark eq 'yes'}
                            checked
                        {/if}
                >
            </td>
            <td align="left">
                {'UploadWatermark'|@getFixedLabel}
            </td>
            
        </tr>

        {*        // @edit:dong @date:2020/08/13 @reason: tapd ID1001007 签到源单类型定制功能优化*}
        <!--<tr>
            <td align="right">
                {'EnableWhenAdding'|@getFixedLabel}
            </td>
            <td>
                <input id="option_enablewhenadding_{$k}" class="second_switch" type="checkbox"
                        {if $optionvalues.enablewhenadding eq '1'}
                            checked
                        {/if}
                >
            </td>
        </tr>
        <tr>
            <td align="right">
                {'WHETHERITISAREQUIREDFILED'|@getFixedLabel}
            </td>
            <td>
                <input id="option_required_{$k}" class="second_switch" type="checkbox"
                        {if $optionvalues.required eq '1'}
                            checked
                        {/if}
                >
            </td>
        </tr>

        <tr>
            <td align="right">
                {'Automaticallysignin'|@getFixedLabel}
            </td>
            <td>
                <input id="option_automatically_{$k}" class="second_switch" type="checkbox"
                        {if $optionvalues.automaticallysign eq '1'}
                            checked
                        {/if}
                >
            </td>
        </tr>-->
        <tr>
            <td style="text-align: right;">
                <input id="no_signin_{$k}" class="second_switch" type="checkbox"
                        {if $optionvalues.no_signin eq 'yes'}
                            checked
                        {/if}
                >
            </td>
            <td align="left">
                {'Ifitexceedstheerrorrange'|@getFixedLabel}<select class="btn-radius-system marL10" name="allowable_distance_{$k}" id="allowable_distance_{$k}" style="width: 70px;" onchange="allowable_distance_click(this,{$k})">
                            <option value="100" {if $optionvalues.allowable_distance eq 100}selected{/if}>100{'metre'|@getFixedLabel}</option>
                            <option value="200" {if $optionvalues.allowable_distance eq 200 || $optionvalues.no_signin eq 'no'}selected{/if}>200{'metre'|@getFixedLabel}</option>
                            <option value="300" {if $optionvalues.allowable_distance eq 300}selected{/if}>300{'metre'|@getFixedLabel}</option>
                            <option value="500" {if $optionvalues.allowable_distance eq 500}selected{/if}>500{'metre'|@getFixedLabel}</option>
                            <option value="800" {if $optionvalues.allowable_distance eq 800}selected{/if}>800{'metre'|@getFixedLabel}</option>
                            <option value="1000" {if $optionvalues.allowable_distance eq 1000}selected{/if}>1000{'metre'|@getFixedLabel}</option>
                            <option value="2000" {if $optionvalues.allowable_distance eq 2000}selected{/if}>2000{'metre'|@getFixedLabel}</option>
                            <option value="3000" {if $optionvalues.allowable_distance eq 3000}selected{/if}>3000{'metre'|@getFixedLabel}</option>
                            <option value="5000" {if $optionvalues.allowable_distance eq 5000}selected{/if}>5000{'metre'|@getFixedLabel}</option>
                            <option value="custom" {if $optionvalues.no_signin eq 'yes' && $optionvalues.allowable_distance neq '100' && $optionvalues.allowable_distance neq '200' && $optionvalues.allowable_distance neq '300' && $optionvalues.allowable_distance neq '500' && $optionvalues.allowable_distance neq '800' && $optionvalues.allowable_distance neq '1000' && $optionvalues.allowable_distance neq '2000' && $optionvalues.allowable_distance neq '3000' && $optionvalues.allowable_distance neq '5000'}selected{/if}>{'custom'|@getFixedLabel}</option>
                        </select>
                        
                            <input {if $optionvalues.allowable_distance neq '100' && $optionvalues.allowable_distance neq '200' && $optionvalues.allowable_distance neq '300' && $optionvalues.allowable_distance neq '500' && $optionvalues.allowable_distance neq '800' && $optionvalues.allowable_distance neq '1000' && $optionvalues.allowable_distance neq '2000' && $optionvalues.allowable_distance neq '3000' && $optionvalues.allowable_distance neq '5000' && $optionvalues.no_signin eq 'yes'}style="width: 50px;height: 30px;"{else}style="width: 50px;display:none;height: 30px;"{/if} type="text" name="custom_allowable_distance_{$k}" class="detailedViewTextBox" id="custom_allowable_distance_{$k}" value="{$optionvalues.allowable_distance}" style="width: 50px;">
            </td>
            
        </tr>
    </table>
    <div class="E_pbtn">
    	<input type="button" name="save" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="editOption('{$k}');"/><span>&nbsp;</span>
        <input type="button" name="cancel" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('editOption_{$k}');"/>  
    </div>
</div>
{/foreach}