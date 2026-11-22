<div class="Showselect" id="showselectsearchscope">
{assign var=fldname value='SmOwnerSearchScope'}
	<label>{'VIEWRANGE'|@getFixedLabel}</label>
    <select onchange="SmOwnerSearchScopeChange(this,'{$MODULE}','{$CATEGORY}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
        {foreach key=User_id item=User_name from=$User_value}
            {foreach key=User_name_key item=User_name_value from=$User_name}
                {if $User_id eq $SelectedOwner2}
                    {assign var=optText value=$User_name_key}
                    {* wym XUQIU1002054 未勾选显示离职，隐藏离职成员*}
                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}" selected="true">{$User_name_key}</option>
                {else}
                   <!-- bug 0015295 zyh 20150603-->
                    {if $MODULE eq 'BankAccountSet'}
                        {if $User_id == 'SmOwer_Search_ShareMe' || $User_id == 'SmOwer_Search_MeToShare'}

                        {else}
                            <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}">{$User_name_key}</option>
                        {/if}
                    {else}
                        <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}">{$User_name_key}</option>
                    {/if}
                    <!--{*/if*} -->
                {/if}

            {/foreach}
        {/foreach}
    {/foreach}
    </select>
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','showselectsearchscope')">
     	<a style="width:125px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','showselectsearchscope')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
            {* zkt 20230412 BUG0063191 客户->查看范围，选择成员姓名后，成员姓名显示乱码（BUG0064657） *}
            <div class="commonDetailedTextBox outline bgwhite 3" contenteditable="true"
            style="width:100px;margin-left: -4px;border-style:none;overflow: hidden;position: relative;white-space: nowrap;text-overflow: ellipsis;" picklisttype='smownerpicklist'
              name='cmb_span_optiontext_{$fldname}' title='{$optText}'
              onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}','showselectsearchscope')" onKeyUp="com_chosen(event,'{$fldname}','showselectsearchscope')">
            {$optText}
            </div>
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 125px; top: 30px;z-index:902;" class="chzn-drop" name='dv_drop_{$fldname}' >
            <ul class="chzn-results" name="cmb_ul_{$fldname}">{assign var="show" value=0}{assign var="i" value=0}
            {foreach key=User_Key item=User_value from=$Merge_SmOwner }
                {foreach key=User_id item=User_name from=$User_value name=foo}
                    {foreach key=User_name_key item=User_name_value from=$User_name }
                            <!-- bug 0015295 zyh 20150603-->
                            {if $MODULE eq 'BankAccountSet'}
                                {if $User_id == 'SmOwer_Search_ShareMe' || $User_id == 'SmOwer_Search_MeToShare'}

                                {else}
                                    <li {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  userid="{$User_id}" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope')">{$User_name_key}</li>
                                {/if}
                            {else}
                                <li {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  userid="{$User_id}" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope')">{$User_name_key}</li>
                            {/if}

                            {if $User_id eq 'smowner_search_senior'}
                            {assign var="show" value=1}
                            {/if}
							{assign var="i" value=$i+1}
                     {/foreach}
                 {/foreach}
            {/foreach}
                   <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
	    </div>
    </div>
    {if $show eq 1}
    <a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
    {/if}
</div>