<div class="Showselect LdShowselect" id="showselectsearchscope_chuantou" style="padding-top: 0px;padding-left: 12px;{if $current_language eq 'en'}width: 265px;{else}width: 245px;{/if}display:flex;align-items: center;">
	<label style="font-size: 14px;padding-top: 0px;">{'VIEWRANGE'|@getFixedLabel}:</label>
    {assign var=fldname value='ChuantouSmOwnerSearchScope'}
    <select id="ChuantouSmOwnerSearchScope" data-scopemodule="{$scopemodule}" name="ChuantouSmOwnerSearchScope" style="display:none">
    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
        {foreach key=User_id item=User_name from=$User_value}
            {foreach key=User_name_key item=User_name_value from=$User_name}
                {if $User_id eq $SelectedOwner}
                    {assign var=optText value=$User_name_key}
                    {*wym 231115 BUG0075528 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054*}
                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} value="{$User_id}" selected="true">{$User_name_key}</option>
                {else}
                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} value="{$User_id}">{$User_name_key}</option>
                {/if}
            
            {/foreach}
        {/foreach}
    {/foreach}
    </select>
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="margin-top: 0px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','showselectsearchscope_chuantou')">
     	<a style="width:130px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','showselectsearchscope_chuantou')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
            {*			wyt 221213 BUG0059452 首页英文版 图标错位了*}
            <div class="commonDetailedTextBox outline bgwhite" contenteditable="true"  id="SmOwnerSearchScopeSenior"
            style="width:120px;border-style:none;margin-left: -4px;border-style: none;overflow: hidden;position: relative;white-space: nowrap;text-overflow: ellipsis;padding-right: 17px;" picklisttype='smownerpicklist'
              name='cmb_span_optiontext_{$fldname}' title="{$optText}"
              onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}','showselectsearchscope_chuantou')" onKeyUp="com_chosen(event,'{$fldname}','showselectsearchscope_chuantou')">
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
                        <li {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if} userid="{$User_id}" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope_chuantou')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope_chuantou')">{$User_name_key}</li>
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
        <a id="icon_range" class="icon-range" style="" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon"></a>
    {/if}
</div>