<div class="Showselect" id="showselectsearchscope">
{assign var=fldname value='EmailSmOwnerSearchScope'}
	<label>{'VIEWRANGE'|@getFixedLabel}</label>

		<select onchange="EmailSmOwnerSearchScopeChange(this,'Email','{$CATEGORY}')" id="{$fldname}" name="{$fldname}" style="display:none">
	
    
    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
        {foreach key=User_id item=User_name from=$User_value}
            {foreach key=User_name_key item=User_name_value from=$User_name}
            
                {if $User_id eq $SelectedOwner2}
                    {assign var=optText value=$User_name_key}
                    <option value="{$User_id}" selected="true">{$User_name_key}</option>
                {else}
               <!-- /*
                andrew
                20140916
                0011132: 银行初始化中按角色查看时下拉列表异常
                目前无法确定neq 'BankAccountSet'的需求是否有，先删除，如发现其他部分出现问题，再修改
                */-->
                   <!--{*{if $MODULE neq 'BankAccountSet'}*}-->
                   <!-- bug 0015295 zyh 20150603-->
                    {if $MODULE eq 'BankAccountSet'}
                        {if $User_id == 'SmOwer_Search_ShareMe' || $User_id == 'SmOwer_Search_MeToShare'}
                        
                        {else}
                            <option value="{$User_id}">{$User_name_key}</option>
                        {/if}
                    {else}
                        <option value="{$User_id}">{$User_name_key}</option>
                    {/if}
                    <!--{*/if*} -->
                {/if}
            
            {/foreach}
        {/foreach}
    {/foreach}
  
    </select>
                            
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','showselectsearchscope')">
     	<a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','showselectsearchscope')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','showselectsearchscope')" onKeyUp="com_chosen(event,'{$fldname}','showselectsearchscope')" value="{$optText}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 117px; top: 25px;z-index:902;" class="chzn-drop" name='dv_drop_{$fldname}' >
            <ul class="chzn-results" name="cmb_ul_{$fldname}">{assign var="show" value=0}{assign var="i" value=0}
            {foreach key=User_Key item=User_value from=$Merge_SmOwner }
                {foreach key=User_id item=User_name from=$User_value name=foo}
                    {foreach key=User_name_key item=User_name_value from=$User_name }
                            <!-- bug 0015295 zyh 20150603-->
                            {if $MODULE eq 'BankAccountSet'}
                                {if $User_id == 'SmOwer_Search_ShareMe' || $User_id == 'SmOwer_Search_MeToShare'}
                                
                                {else}
                                    <li style="" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope')">{$User_name_key}</li>  
                                {/if}
                            {else}
                                <li style="" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','showselectsearchscope')" onmouseover="cmb_limouseover(event,'{$fldname}','showselectsearchscope')">{$User_name_key}</li>
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