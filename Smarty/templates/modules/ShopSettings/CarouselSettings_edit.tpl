<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="carselsettings" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="ShopSettings"/>
    <input type="hidden" name="recordid" value="{$RECORDID}"/>
    <input type="hidden" name="mode" value="{$OperateMode}"/>
    <input type="hidden" name="version_account" value="{$version_account}"/>
    <input type="hidden" name="selectproductfield" value="{$productfieldname}"/>
    <input type="hidden" name="ajax" value="save"/>

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class = "ld-form-item-label"><font color="red">*</font>{'NavigationPicture'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div style="padding-bottom: 10px;">
                    <div class="E_pbtncancel" style="float:left;height:25px;line-height:22px;margin-top:5px;" >
            		  <input  type="file" name="file" accept="image/*" id="upload" onchange="CarouseSelectpicture(this)" style="opacity:0;position:absolute;margin-left: -10px;width:70px">
                      <label for="upload">{'Select_file'|@getFixedLabel}</label>
                    </div>
                    <span style="margin-top:12px;margin-left: 10px;display: inline-block;">（  轮播图尺寸比例宽*高：11*5px ）</span>
                </div>
                <div name="div_upload_span" style="{if $LOADFILENAME eq ''}display: none;{else}display: block;{/if}width: 100px;height: 30px;background-size: 100px 100px;background-repeat: no-repeat;margin-top: 10px;padding-top:5px">
                    <span class="info" name="span_upload_fielname" style="padding-left:5px">{$LOADFILENAME}</span>
                    <span name="span_upload_fielsize" style="color:#798699;padding-left:5px">{if $FILESIZE neq ''}({$FILESIZE}){/if}</span>
                    <span class=""  style="line-height: 24px;padding-left:5px"><a href="javascript:;" onclick="CarouseDeletepicture('upload')">{'DELETE'|@getFixedLabel}</a></span>
                    <input type="hidden" name="upload_img_hidden" value="{$FILENAME}">    
                </div>
             </td>
        </tr>
        <tr>
            <td class = "ld-form-item-label"><font color="red">*</font>{'NavigationLinkType'|@getFixedLabel}</td>
            <td class="ld-form-item-content" style="overflow: inherit;">
                    {assign var ='fldname' value='linktype'}
                    <select id="{$fldname}" onchange="getLinkTypeinfo(this)" name="{$fldname}" style="display:none">
                    
                        {assign var='LinkTypedefaulttext' value=$linktype.Carousel_ProductCategoryList}
                        {assign var='LinkTypedefaultvalue' value='Carousel_ProductCategoryList'}
                        {foreach item=text key=value from=$linktype}
                        {if $value eq $LINKTYPE}
                            {assign var='LinkTypedefaulttext' value=$text}
                            {assign var='LinkTypedefaultvalue' value=$value}
                            <option value="{$value}"  selected="">{$text}</option>
                        {else}
                            <option value="{$value}"  >{$text}</option>
                        {/if}
                        {/foreach}
                    </select>
                    
                    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','')">
                          <a style="width:198px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
                    	       <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','')" onKeyUp="com_chosen(event,'{$fldname}','')" value="{$LinkTypedefaulttext}">
                               <div>
                                    <b></b>
                               </div>
                          </a>
                       <div style=" left:-9000px;width: 198px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                    	 <ul class="chzn-results" name="cmb_ul_{$fldname}">
                            {assign var="i" value=0}
                    	    {foreach item=value key=key  from=$linktype}
                                <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','')" onmouseover="cmb_limouseover(event,'{$fldname}','')">{$value}</li>
                                {assign var="i" value=$i+1}
                           {/foreach}
                            <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                    	 </ul>
                       </div>
                    </div>
            </td>
        </tr>
        <tr id="productcategory_tr" {if $LinkTypedefaultvalue neq 'Carousel_ProductCategoryList'} style="display:none;"{/if}>
            <td class = "ld-form-item-label"><font color="red">*</font>{'ProductCategory'|@getFixedLabel}</td>
            <td class="ld-form-item-content" style="overflow: inherit;">
                {assign var ='fldname' value='productcategory'}
                <select id="{$fldname}" name="{$fldname}" style="display:none">
                {assign var='productcategorytext' value=$categorylist.0.text}
                {assign var='productcategoryvalue' value=$categorylist.0.value}
                {foreach item=category from=$categorylist}
                {if $category.value eq $CATEGORYID}
                    {assign var='productcategorytext' value=$category.text}
                    {assign var='productcategoryvalue' value=$category.value}
                    <option value="{$category.value}"  selected="">{$category.text}</option>
                {else}
                    <option value="{$category.value}"  >{$category.text}</option>
                {/if}
                {/foreach}
                </select>
                
                <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','')">
                      <a style="width:198px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
                	       <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','')" onKeyUp="com_chosen(event,'{$fldname}','')" value="{$productcategorytext}">
                           <div>
                                <b></b>
                           </div>
                      </a>
                   <div style=" left:-9000px;width: 198px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                	 <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {assign var="i" value=0}
                	    {foreach item=valueinfo  from=$categorylist}
                            <li  class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$valueinfo.value}','{$fldname}','')" onmouseover="cmb_limouseover(event,'{$fldname}','')">{$valueinfo.text}</li>
                            {assign var="i" value=$i+1}
                       {/foreach}
                        <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                	 </ul>
                   </div>
                </div>
            </td>
        </tr>
        <tr id="selectproduct_tr" {if $LinkTypedefaultvalue neq 'Carousel_Productdetails'} style="display:none;"{/if}>
            <td class="ld-form-item-label"><font color="red">*</font>{'SelectProducts'|@getFixedLabel}
                <input type="hidden" name="Carousel_Productdetails" value="{'SelectProducts'|@getFixedLabel}"/>
                </td>
            <td class="ld-form-item-content">
                {assign var ='fldname' value=$productfieldname}
                {assign var ='selectmodule' value='Products'}
                <input style="width:198px;" readonly name="{$fldname}_name" type="text" fieldonly='0' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
				<input name="{$fldname}" type="hidden" value="{$PRODUCTID}">
                <a class="icon-homeimg icon-select" href="javascript:;" tag="{$fldname}" title="{'SELECT'|@getFixedLabel}" onclick='showputonproductslist("{$MODULE}","{$selectmodule}","select","",this);'></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_CarouselSelectfielddata('{$selectmodule}','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;"/>							
            </td>
        </tr>
        <tr>
            <td class = "ld-form-item-label"><font color="red">*</font>{'WHETHERTODISPLAY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input class="second_switch" name="carousel_status" tabindex="i" type="checkbox" {if $Status eq 'no'}{else}checked=""{/if}>
            </td>
        </tr>
        
    </table>
</form>
</div>