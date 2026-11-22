<link href="themes/softed/selfstyle.css" rel="stylesheet" type="text/css">
<form action="index.php" method="post" name="Saveresults" onsubmit="puyoungJS_DialogBox.block();">
    <table class="settingPopTable lasttdbordernon" id="ModuleMapfieldTable" border="0" cellpadding="0" cellspacing="0" >
        <tr>
    		<td width="250" >
    			<b>{'Available_fields'|@getFixedLabel}</b><br>
    			<input class="detailedViewTextBox" style="width:200px;margin-top: 5px;" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'AssmablyList',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" /><br>
    			<select  class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" ondblclick="addColumnCustomviewModule('AssmablyList','selectedAssmablyColumns')" multiple="">
                    {foreach key = number item = assmablys from =$PRODUCTLISTVIEWALL name=pname}
                    {assign var="assmablylabel" value=$assmablys}
                        <option value="{$number}">{$assmablys}</option>
                    {/foreach}
                </select>
    		</td>
    		<td width="50" style="padding-right: 32px;">
    			<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsCustomviewModule('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a><br>
    			<a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsCustomviewModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
    		</td>
    		<td width="250" >
    			<b>{'Selected_Fields'|@getFixedLabel}</b><br><br><br>
    			<select size="11"  class="commonMultipleSelect width200 height250 marT10" name="selectedAssmablyColumns" id="selectedAssmablyColumns" ondblclick="addColumnCustomviewModule('selectedAssmablyColumns','AssmablyList')" multiple="">
    				{if $HAVEPRODUCTLISTVIEWALL != null}
                    {foreach key = number item = assmablys from =$HAVEPRODUCTLISTVIEWALL name=pname}
                        {assign var="assmablylabel" value=$assmablys}
    			        <option value="{$number}">{$assmablys}</option>
                    {/foreach}
                    {/if}
                </select>
    		</td>
    		<td width="50" style="padding-right: 38px;">
    			<a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ProductDetailmoveUp();" title="{'MOVEUP'|@getFIxedLabel}"></a><br>
    			<a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailmoveDown();" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
    		</td>
        </tr>
    </table>
</form>