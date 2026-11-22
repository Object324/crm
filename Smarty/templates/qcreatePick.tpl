<div id="div_quickcreate">


    
    <select id="qccombo" onchange="QCreate(this)" name="qccombo" style="display:none">
        {*edit:diony time:20140918 *}
        {*0011523: 快速创建下拉列表中，刘总建议把“快速创建”列表值给去掉-如图*}
        {*<option value="none">{'Quickly_create'|@getFixedLabel}</option>*}
       {foreach key=ky item=details from=$QUICKMODULE}
    
             <option value="{$details[1]}">{$details[0]}</option>
        
       {/foreach}
    </select>
    <div name="dv_chzn_qccombo" class="chzn-container chzn-container-single"  onMouseLeave="cmb_mouseleave(event,'qccombo','div_quickcreate')">
     	<!--<a style="width:132px" class="chzn-single" onclick="com_img_change(event,'qccombo','div_quickcreate')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_qccombo">
            <span name="cmb_span_optiontext_qccombo">{'Quickly_create'|@getFixedLabel}</span>
            <div>
                <b></b>
            </div>
        </a>-->
        <div class="newquickcreate" name="cmb_span_optiontext_qccombo" {if isSearchCRMVersion() eq 'yes'} style="display:none"{/if}>
            <a href="javascript:void(0);">
            <img src="./themes/softed/images/newquickcreate.png" style="padding:0 3px;margin-bottom: 2px;"/>{'Quickly_create'|@getFixedLabel}
            </a>
        </div>
        <div style=" left:-9000px;width: 140px; top: 20px;" class="chzn-drop" name='dv_drop_qccombo' >
    		<div class="chzn-search">
    		<input class="search_bg" type="text" autocomplete="off" style="width: 127px;" tabindex="0"  name='txt_search_qccombo' onclick="com_chosen(event,'qccombo','div_quickcreate')" onKeyUp="com_chosen(event,'qccombo','div_quickcreate')">
    		</div>
    		 <ul class="chzn-results" name="cmb_ul_qccombo">
    		    {*edit:diony time:20140918 *}
                {*0011523: 快速创建下拉列表中，刘总建议把“快速创建”列表值给去掉-如图*}
                {*<option value="none">{'Quickly_create'|@getFixedLabel}</option>
                <li style="border-top:0px #ccc solid;" class="active-result" id="dv_chzn_1_qccombo" onclick="cmb_liclick('none','qccombo')" onmouseover="cmb_limouseover(event,'qccombo')"> {'Quickly_create'|@getFixedLabel}</li>
                {assign var="i" value=$i+1}*}   
                {foreach key=ky item=details from=$QUICKMODULE}
                      {assign var="i" value=$i+1}  
                      <li class="active-result" name="dv_chzn_{$i}_qccombo" onclick="cmb_liclick('{$details[1]}','qccombo','div_quickcreate')" onmouseover="cmb_limouseover(event,'qccombo','div_quickcreate')"> {$details[0]}</li>
                {/foreach}
                   
                   <li class="" name="li_chzn_qccombo" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
    		 </ul>
        </div>
    </div>


</div>