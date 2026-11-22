
<div class="Showselect LdShowselect" id="showselectsearchscope" style="margin-top: 5px;padding-left: 12px;{if $current_language eq 'en'}width: 265px;{else}width: 245px;{/if}">
	<label style="font-size: 14px;padding-top: 1px;">{'VIEWRANGE'|@getFixedLabel}:</label>
    {assign var=fldname value='HomeSmOwnerSearchScope'}
    <select onchange="SmOwnerSearchScope(this)" id="HomeSmOwnerSearchScope" name="HomeSmOwnerSearchScope" style="display:none">
    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
        {foreach key=User_id item=User_name from=$User_value}
            {foreach key=User_name_key item=User_name_value from=$User_name}
                    {if $User_id eq $SelectedOwner2}
                        {assign var=optText value=$User_name_key}
                       {* wym XUQIU1002054 未勾选显示离职，隐藏离职成员*}
                        <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} value="{$User_id}" selected="true">{$User_name_key}</option>
                    {else}
                        <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} value="{$User_id}">{$User_name_key}</option>
                    {/if}
            {/foreach}
        {/foreach}
    {/foreach}
    </select>
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','showselectsearchscope')">
     	<a style="width:130px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','showselectsearchscope')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
            <div class="commonDetailedTextBox outline bgwhite" contenteditable="true"  id="SmOwnerSearchScopeSenior"
            style="width:120px;border-style:none;margin-left: -4px;border-style: none;overflow: hidden;position: relative;white-space: nowrap;text-overflow: ellipsis;padding-right: 17px;" picklisttype='smownerpicklist'
              name='cmb_span_optiontext_{$fldname}' {if $iskehu001 eq 'no'}title="{$optText}"{/if}
              onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}','showselectsearchscope')" onKeyUp="com_chosen(event,'{$fldname}','showselectsearchscope')">
              
            {$optText}
            </div>
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 130px; top: 30px;z-index:902;" class="chzn-drop" name='dv_drop_{$fldname}' >
            <ul class="chzn-results" name="cmb_ul_{$fldname}">{assign var="show" value=0}{assign var="i" value=0}
            {foreach key=User_Key item=User_value from=$Merge_SmOwner }
                {foreach key=User_id item=User_name from=$User_value name=foo}
                    {foreach key=User_name_key item=User_name_value from=$User_name }
                        <!-- bug 0015295 zyh 20150603-->
                        <li {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} userid="{$User_id}" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope')">{$User_name_key}</li>
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
        <a class="icon-range" style="margin-top: 2px;" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon" onclick="SmOwnerSearchScope(this)"></a>
    {/if}
</div>