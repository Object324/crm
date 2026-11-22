<!--修改编码格式:统一编码：UTF-8-->
{*	0034542: 客户、联系人、服务收费管理列表界面>更多>自动查重合并：左上角的查重改为“自动查重”*}
{*editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 15:15
<div class="FindDuplicateDisplayDiv">
    <span class="FindDuplicateDisplaySpan">{'CHECKMERGE'|@getFixedLabel}&nbsp;{$MODULE|@getTranstab}</span>
</div>*}
<!--分页-->
{if is_array($NAVIGATION) && $NAVIGATION|@count > 0}
<div class="Paging_div_new" style="background-color: #fff;float: none;">
  <div class="Showselect">
 	    {assign var='massDelete' value=$MODULE|@getTranstab}
      {if $DELETE eq $massDelete}
      <input class="deleteauto" type="button" value="{'DELETE'|@getFixedLabel}" onclick="return delete_fields('{$MODULE}')"/>
      {/if}
  </div>
 	<div class="PageDiv0">
		<div class="ld-flex-start">
			<div class="ld-pagenum-div">{$recordListRange}</div>
			{$NAVIGATION}
		</div>
  </div>
</div>
{/if}
<input name="popuptype" id="popup_type" type="hidden" value="mergduplicate"/>
<input name="duplicate_viewid" id="duplicate_viewid" type="hidden" value="{$DUPLICATE_VIEWID}"/>
<!--分页  end-->
<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
    <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
		<div  style="float:left; padding-right:20px">
			<table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{$LISTVIEWTOTALWIDTH}px" >
				<tbody>
					<tr>
    					{foreach item=header key=i from=$customViewFieldsarr}
    						<th style="width:{$LISTHEADERWIDTH[$i]+13}px" headermodule='{$MODULE}' headername='{$HEADERNAME[$i]}' tag="{$i}">{$header}</th>
    					{/foreach}
                        {assign var='namecount' value=$HEADERNAME|@count}
                        <th  style="text-align:center;width:{$CHKBOXWIDTH+10}px" tag="{$namecount+1}" headermodule="{$MODULE}" headername='chkbox'>
							<input class="checkbox-item j-all-checkbox" type="checkbox" headermodule="{$MODULE}"  value="" name="selectall"/>&nbsp;&nbsp;{'MERGESELECT'|@getFixedLabel}
						</th>
					   <th width="{$OPERATIONWIDTH}" tag="{$namecount+2}" >{'OPERATING'|@getFixedLabel}</th>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
    <div style="overflow:auto;height:400px;" id="resize_content_table_divid" name="resize_content_table_divid">
		<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$LISTVIEWTOTALWIDTH}px" class="listEntries marT-53" >
			<tbody>
				<tr>
    				{foreach item=header key=i from=$customViewFieldsarr}
    					<th style="width:{$LISTHEADERWIDTH[$i]+13}px" headermodule='{$MODULE}' headername='{$HEADERNAME[$i]}' tag="{$i}">{$header}</th>
    				{/foreach}
                    <th  style="text-align:center;width:{$CHKBOXWIDTH+10}px" tag="{$namecount+1}" headermodule="{$MODULE}" headername='chkbox'>
    					<input class="checkbox-item j-all-checkbox" type="checkbox" headermodule="{$MODULE}"  value="" name="selectall"/>&nbsp;&nbsp;{'MERGESELECT'|@getFixedLabel}
    				</th>
    			   <th width="{$OPERATIONWIDTH}" tag="{$namecount+2}">{'OPERATING'|@getFixedLabel}</th>
				</tr>
                {assign var=entity_id value=0}
				{assign var=tdclass value='lvtColDataBj'}
                {foreach key=key1 item=data from=$ALL_VALUES}
                    {assign var=cnt value=$data|@sizeof}
            		{assign var=cnt2 value=0}
            		
                    {assign var=recordid value='RECORDID'|@getFixedLabel}
            			{foreach key=key3 item=newdata1 from=$data}
                        {if $tdclass eq 'lvtColDataBj'}
                			{assign var=tdclass value='lvtColData'}
                		{else if $tdclass eq 'lvtColData'}
                			{assign var=tdclass value='lvtColDataBj'}
                		{/if}
                        {assign var=entity_id value=$entity_id+1}
						{if $entity_id%2 == 0}
						<tr class="{$tdclass}" onmouseout="listOnMouseOut(ld(this),'On')" onmouseover="listOnMouseOver(ld(this))" id="row_{$entity_id}">
						{else}
						<tr class="{$tdclass}" onmouseout="listOnMouseOut(ld(this),'on')" onmouseover="listOnMouseOver(ld(this))" id="row_{$entity_id}">
						{/if}
                            {assign var=entitytype value='ENTITYTYPE'|@getFixedLabel}
                            {foreach key=key item=newdata2 from=$newdata1}
                                <td>
        							{if $key eq 'recordid'}	
        								<a href="index.php?module={$MODULE}&action=DetailView&record={$data.$key3.recordid}&parenttab={$CATEGORY}" target ="blank">{$newdata2}</a>
        							{else}
        								{if $key eq $entitytype}
            									{if $newdata2 eq 0 && $newdata2 neq NULL}
            										{if $VIEW eq true}
            											{'LASTIMPORTED'|@getFixedLabel}
            										{else}
            											{'EXPORT'|@getFixedLabel}
            										{/if}
            									{else}
            										{'EXISTING'|@getFixedLabel}
            								    {/if}
            							{else}
            								{$newdata2}
            							{/if}
        							{/if}
                            {/foreach}
                            <td nowrap="nowrap"  align="center">
                                {*editor:gyq_72 reason:查重合并样式修改 date:20180705*}
        						<input class="checkbox-item j-all-checkbox" name="{$key1}" id="{$key1}" tag="mergerecord" value="{$RECORDID_ARR.$key1.$key3}" type="checkbox">
        					</td>
        					{if $cnt2 eq 0 && $MODULEMERGE eq 'permitted'}
                                {if $MODULEMERGE eq 'permitted'}
                                    <td align="center" rowspan='{$cnt}'><input class="editauto" name="merge" value="{'Merge'|@getFixedLabel}" onclick="merge_fields('{$key1}','{$MODULE}','{$CATEGORY}');" type="button"/></td>
                                {else}
                                    <td align="center" rowspan='{$cnt}'></td>
                                {/if}
        					{/if}
        					{assign var=cnt2 value=$cnt2+1}
                            </td>
						
						
					</tr>
				
					{/foreach}
                {/foreach}
			</tbody>
		</table>
	</div>
</div>
{*
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
	{foreach key=key item=field_values from=$FIELD_NAMES}
		<th  style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' > 
			{$key}
		</th>
	{/foreach}
	<th style="text-align:center;">
    <input class="checkbox-item j-all-checkbox" type="checkbox" name="selectall"/>&nbsp;&nbsp;{'MERGESELECT'|@getFixedLabel}
	</th>
	<th width="120"  style="text-align:center;">
		{'OPERATING'|@getFixedLabel}
	</th>
</tr>
	{assign var=tdclass value='IvtColdata'}
	{foreach key=key1 item=data from=$ALL_VALUES}
		{assign var=cnt value=$data|@sizeof}
		{assign var=cnt2 value=0}
		{if $tdclass eq 'IvtColdata'}
			{assign var=tdclass value='sep1'}
		{else if $tdclass eq 'sep1'}
			{assign var=tdclass value='IvtColdata'}
		{/if}
        {assign var=recordid value='RECORDID'|@getFixedLabel}
			{foreach key=key3 item=newdata1 from=$data}
				<!--<tr class="{$tdclass}" nowrap="nowrap" >-->
                    <tr bgcolor="white" >
					
						
				
                    {assign var=entitytype value='ENTITYTYPE'|@getFixedLabel}
					{foreach key=key item=newdata2 from=$newdata1}
						<td>
							{if $key eq 'recordid'}	
								<a href="index.php?module={$MODULE}&action=DetailView&record={$data.$key3.recordid}&parenttab={$CATEGORY}" target ="blank">{$newdata2}</a>
							{else}
                                
								{if $key eq $entitytype}
									{if $newdata2 eq 0 && $newdata2 neq NULL}
										{if $VIEW eq true}
											{'LASTIMPORTED'|@getFixedLabel}
										{else}
											{'EXPORT'|@getFixedLabel}
										{/if}
									{else}
										{'EXISTING'|@getFixedLabel}
								{/if}
							{else}
								{$newdata2}
							{/if}
							{/if}
						</td>
					{/foreach}	
					<td nowrap="nowrap" width="80" align="center">
						<input class="checkbox-item j-all-checkbox" name="{$key1}" id="{$key1}" tag="mergerecord" value="{$RECORDID_ARR.$key1.$key3}" type="checkbox">
					</td>
					{if $cnt2 eq 0 && $MODULEMERGE eq 'permitted'}
                        {if $MODULEMERGE eq 'permitted'}
                            <td align="center" rowspan='{$cnt}'><input class="editauto" name="merge" value="{'Merge'|@getFixedLabel}" onclick="merge_fields('{$key1}','{$MODULE}','{$CATEGORY}');" type="button"></td>
                        {else}
                            <td align="center" rowspan='{$cnt}'></td>
                        {/if}
					{/if}
					{assign var=cnt2 value=$cnt2+1}
				</tr>
			{/foreach}
	{/foreach}
</table>*}
<div name="group_count" id="group_count" style="display :none">
		{$NUM_GROUP}
</div>
