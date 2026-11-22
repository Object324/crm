<div class="select-input pad10">
	<input type="checkbox" name="is_module_tree" {if $is_module_tree eq 0}checked{/if} id="is_module_tree">
	<label for="is_module_tree">{'Enabletreestructureclassification'|@getFixedLabel}</label>
    <label class="gray" style="padding-left:0;" for="is_module_tree">{'EnableTreeStructure'|@getFixedLabel}</label>
</div>
<table class="pad10" border="0" cellspacing="0" cellpadding="0" width="100%" style="text-align:center;border-bottom: 1px solid #DEE1E6;border-spacing:0px 10px;">
    <tr>
        <td>{'TREEIMGEXPLAIN1'|@getFixedLabel}</td>
        <td>{'TREEIMGEXPLAIN2'|@getFixedLabel}</td>
    </tr>
    <tr>                
        <td><img src="{$IMAGEURL}themes/images/TreePic1.png?v={$GLOBALMINVERSION}" height="200px" width="200px" style="border:1px solid #DEE1E6" /></td>
        <td><img src="{$IMAGEURL}themes/images/TreePic2.png?v={$GLOBALMINVERSION}" height="200px" width="200px" style="border:1px solid #DEE1E6" /></td>
    </tr>
</table>
<div class="pad10" name="div_show_default_tab">
	{'Treestructuregroupingfield'|@getFixedLabel}&nbsp;&nbsp;
	<select name="tree_fieldname" class="ld-select-inner width180" tagclick="moduletree.click">
		{foreach key=fieldname item=fieldlabel from=$FIELDTREE}
			<option value="{$fieldname}" {if $tree_fieldname eq $fieldname}selected{/if}>{$fieldlabel}</option>
		{/foreach}
	</select>
    {*zkt //设置按钮跳转值页面设置界面*}
    {if $IS_ADMIN eq true}
        <a onclick="AddPicklistField({$blockid},{$tabid});" style="cursor:pointer;margin-left:3px;">{'NewGroupingField'|@getFixedLabel}</a>
        <input type="hidden" id="pickmodule" value="{$selectmodule}"/>
        {*hjz //级联字段定制页面跳转*}
        <a class='marT5 marL12 cursorPointer' id="addNewDependencyPicklist" name="addNewDependencyPicklist" {if $FIELDTREELENGTH eq 0}style="display: none"{/if} title="{'AddCascadingField'|@getFixedLabel}" onclick="addNewDependencyPicklist('{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">{'AddCascadingField'|@getFixedLabel}</a>
    {/if}
</div>

<div class="pad10" style="{if $tree_field_cnt eq 0}display:none;{/if}" name="div_show_tree_depency" >
	<table class="ControlTable1 listEntries fir-center listSettingData" width="100%" cellspacing="1" cellpadding="0" border="0" name="tree_table">
		<tbody>
			<tr>
				<th title="{'CascadeField'|@getFixedLabel}" width="50%" align="left">{'CascadeField'|@getFixedLabel}</th>
				<th title="{'whethertodisplayasatreenode'|@getFixedLabel}" width="30%" style="text-align: center;">{'whethertodisplayasatreenode'|@getFixedLabel}</th>
                <th title="{'OPERATING'|@getFixedLabel}" width="20%" style="text-align: center;">{'OPERATING'|@getFixedLabel}</th>
			</tr>
			{foreach key=i item=info from=$tree_field}
				{assign var="rowid" value=$i+1}   
				<tr class="lvtColData">
					{if $rowid eq 1}
						<td align="left">{$info.fieldlabel}</td><td align="center"><input type="checkbox" name="is_tree_field_1" rowid="1" value="{$info.fieldname}" disabled="" checked=""></td><td></td>
					{else}
						<td align="left">{$info.fieldlabel}</td><td align="center"><input type="checkbox" name="is_tree_field_{$rowid}" rowid="{$rowid}" {$info.disabled} value="{$info.fieldname}" {if $info.deleted eq 0}checked=""{/if}></td>
                        <td style="text-align: center;"><a class="cursorPointer" {if $info.deleted neq 0}style="display:none"{/if} name="set_field_{$rowid}" rowid="{$rowid}">设置级联选项</a></td>
					{/if}
				</tr>
			{/foreach}
		</tbody>
	</table>
</div>

<div class="pad10">
    <div class="listRloesHelp" style="padding:0;">
        <font color="red">{'EXPLAINTREE'|@getFixedLabel}</font>
        <ul>
            <li>{'DetailedDescriptionTree1'|@getFixedLabel}</li>
            <li>{'DetailedDescriptionTree2'|@getFixedLabel}</li>
            <li>{'DetailedDescriptionTree3'|@getFixedLabel}</li>
        </ul>
    </div>
</div>
