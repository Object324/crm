{if $searchtype eq 'BasicSearch'}
    {assign var=fldname value=$searchtype}
    <select id="{$fldname}" onchange="" name="{$fldname}" style="display:none">
    {foreach item=tmp_searchvalue from=$SEARCHVALUEARR}
        <option value="{$tmp_searchvalue.id}"  >{$tmp_searchvalue.label}</option>
    {/foreach}
    </select>
    {assign var=searchhistory value = 'SEARCHHISTORY'|@getFixedLabel}
    {if is_array($SEARCHVALUEARR) && sizeof($SEARCHVALUEARR) >0}
        {assign var=defaulttext  value='VIEWALL'|@getFixedLabel|cat:$searchhistory}
    {/if}
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','{$divid}')" style="width: 90%;">
     	<a style="width:100%;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','{$divid}')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','{$divid}')" onKeyUp="search_chosen(event,'{$fldname}','{$divid}')" placeholder="{$defaulttext}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width:100%;top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
			 <ul class="chzn-results" name="cmb_ul_{$fldname}" style="overflow:auto;">
				{assign var="i" value=0}
        	   {foreach item=tmp_searchvalue from=$SEARCHVALUEARR}
                   {if $searchfrom eq 'selectsearchdetail'}
                       <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="advanceFilterSearch.getInstance().searchhistory_change_new(this)" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')" optionvalue="{$tmp_searchvalue.searchvalue.search_field}" searchid="{$tmp_searchvalue.id}" divid="{$divid}" fldname="{$fldname}" searchtext="{$tmp_searchvalue.searchvalue.search_text}" title="{$tmp_searchvalue.label}"  >{$tmp_searchvalue.label}</li>
                   {else}
                       <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="searchhistory_change(this)" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')" optionvalue="{$tmp_searchvalue.searchvalue.search_field}" searchid="{$tmp_searchvalue.id}" divid="{$divid}" fldname="{$fldname}" searchtext="{$tmp_searchvalue.searchvalue.search_text}" title="{$tmp_searchvalue.label}"  >{$tmp_searchvalue.label}</li>
                   {/if}
                   {assign var="i" value=$i+1}
	            {/foreach}
                <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                {if $i > 0}
                    {if $searchfrom eq 'selectsearchdetail'}
                        <li class="active-result blueFont" name="clear_{$fldname}" searchtype="{$searchtype}" searchfrom="{$searchfrom}" onclick="advanceFilterSearch.getInstance().clearhistoryNew(this)" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')">{'CELARALL'|@getFixedLabel}{'SEARCHHISTORY'|@getFixedLabel}</li>
                    {else}
                        <li class="active-result blueFont" name="clear_{$fldname}" searchtype="{$searchtype}" onclick="clearhistory(this)" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')">{'CELARALL'|@getFixedLabel}{'SEARCHHISTORY'|@getFixedLabel}</li>
                    {/if}
                {/if}
			 </ul>
	    </div>
    </div>	
{elseif $searchtype eq 'advance'}
    {assign var=fldname value=$searchtype}
    <select id="{$fldname}" onchange="" name="{$fldname}" style="display:none;">
    {foreach item=tmp_searchvalue from=$SEARCHVALUEARR}
        <option value="{$tmp_searchvalue.id}"  >{$tmp_searchvalue.label}</option>
    {/foreach}
    </select>
    {if is_array($SEARCHVALUEARR) && sizeof($SEARCHVALUEARR) >0}
    {assign var=searchjostory value = 'SEARCHHISTORY'|@getFixedLabel}
    {assign var=defaulttext  value='VIEWALL'|@getFixedLabel|cat:$searchjostory}
    {/if}
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','{$divid}')">
     	<a style="width:550px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','{$divid}')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','{$divid}')" onKeyUp="search_chosen(event,'{$fldname}','{$divid}')" placeholder="{$defaulttext}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width:550px;top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
			 <ul class="chzn-results" name="cmb_ul_{$fldname}" style="overflow:auto;">
				{assign var="i" value=0}
        	   {foreach item=tmp_searchvalue from=$SEARCHVALUEARR}
                   {if $searchfrom eq 'selectsearchdetail' || $advancefiltersearch eq 'yes'}
                        <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" tag="selectoption" {if $newAdvanceFilter neq 'yes'}onclick="advanceFilterSearch.getInstance().searchhistory_change_new(this)"{/if} onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')" optionvalue="{$tmp_searchvalue.searchvalue.search_field}" searchid="{$tmp_searchvalue.id}" divid="{$divid}" fldname="{$fldname}" searchtext="{$tmp_searchvalue.searchvalue.search_text}" title="{$tmp_searchvalue.label}"  >{$tmp_searchvalue.label}</li>
                   {else}
                       <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" tag="selectoption" {if $newAdvanceFilter neq 'yes'}onclick="searchhistory_change(this)"{/if}  onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')" optionvalue="{$tmp_searchvalue.searchvalue.search_field}" searchid="{$tmp_searchvalue.id}" divid="{$divid}" fldname="{$fldname}" searchtext="{$tmp_searchvalue.searchvalue.search_text}" title="{$tmp_searchvalue.label}"  >{$tmp_searchvalue.label}</li>
                   {/if}
                   {assign var="i" value=$i+1}
	            {/foreach}
                <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                {if $i > 0}
                    {if $searchfrom eq 'selectsearchdetail' || $advancefiltersearch eq 'yes'}
                        <li class="active-result blueFont" name="clear_{$fldname}" searchtype="{$searchtype}" {if $newAdvanceFilter neq 'yes'}onclick="advanceFilterSearch.getInstance().clearhistoryNew(this)"{/if}  searchfrom="{$searchfrom}" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')">{'CELARALL'|@getFixedLabel}{'SEARCHHISTORY'|@getFixedLabel}</li>
                    {else}
                        <li class="active-result blueFont" name="clear_{$fldname}" searchtype="{$searchtype}" {if $newAdvanceFilter neq 'yes'}onclick="clearhistory(this)"{/if}  searchfrom="{$searchfrom}" onmouseover="cmb_limouseover(event,'{$fldname}','{$divid}')">{'CELARALL'|@getFixedLabel}{'SEARCHHISTORY'|@getFixedLabel}</li>
                    {/if}
                {/if}
			 </ul>
	    </div>
    </div>	

{/if}