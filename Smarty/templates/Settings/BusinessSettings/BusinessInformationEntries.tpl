{if {$selectpage} eq 'functionsetting'}
    {*功能设置*}
    <div id="showpagecontentheader">
    <table  width="100%">
        <tbody>
            <tr>
                <td class="ld-form-item-label">
                    {'businessqueryinterfacemethod'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <select id="businessqueryinterfacemethod" name="businessqueryinterfacemethod" class="ld-select-inner" style="width: 220px;" onchange="BusinessInformationobj.BusinessSearchChange(this)">
                        <option value="1" {if $business_insterfacekey_deploy_value eq 1}selected{/if}>{'uselingdangbusinessinterfacekey'|@getFixedLabel}</option>
                        <option value="0" {if $business_insterfacekey_deploy_value eq 0}selected{/if}>{'useselfpurchasedbusinessinterfacekey'|@getFixedLabel}</option>
                    </select>
                </td>
            </tr>
            <tr id="business_usage_period_tr" style="{if $business_insterfacekey_deploy_value eq 0}display:none;{/if}">
                <td class="ld-form-item-label">
                    {'usageperiod'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    {$usage_starttime} ~ {$usage_endtime} ({$businesssearchcountlabel})
                </td>
            </tr>
            <tr id="business_insterfacekey_tr" style="{if $business_insterfacekey_deploy_value neq 0}display:none;{/if}">
                <td class="ld-form-item-label" >
                    <font color="red" name="business_insterfacekey_required">*</font><span >{'TIANYANCHABUSINESSINTERFACEKEY'|@getFixedLabel}</span>
                </td>
                <td class="ld-form-item-content">
                    <span id="business_insterfacekey_span">{$business_insterfacekey_value}</span><a style="margin-left: 10px" id="business_insterfacekey_edit" onclick="BusinessInformationobj.editBusiness_insterfacekey();">{'EDIT'|@getFixedLabel}</a>
                </td>
            </tr>
            <tr id="business_fuzzyquery_tr" >
                <td class="ld-form-item-label" style="width: 260px;">
                    <span >{'BUSINESSFUZZYQUERYSTARTQUANTITY'|@getFixedLabel}</span>
                </td>
                <td class="ld-form-item-content">
                    <select id="fuzzyquerytosearchnum" name="fuzzyquerytosearchnum" class="ld-select-inner" style="width: 220px;" onchange="BusinessInformationobj.SaveBusiness_fuzzyquery_num(this)">
                        {foreach item=entityinfo name=listentity key=index from=$fuzzyquerytosearchnum_arr}
                            <option value="{$entityinfo}" {if $business_fuzzyquerytosearchnum eq $entityinfo}selected{/if}>{$entityinfo}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>
            <tr  >
                <td colspan="2"class="ld-form-item-content" align="right">
                    <a id="add_businessmodule" href="javascript:;" class="ld-button ld-button-primary" onclick="BusinessInformationobj.createBusinessModule()" title="{'NEW'|@getFixedLabel}">{'NEW'|@getFixedLabel}</a>
                </td>
            </tr>
        </tbody>
    </table>
    </div>
    <div id="showpagecontentbody" class="ld-table-container ld-table-container-line ld-table-container-bgcolor">
        <table border=0 cellspacing=0 cellpadding=0 width="100%" class="fir-center" id="business_information">
            <thead>
            <tr>
                <th width="65px">#</th>
                <th width="250px" title="{'MODULENAME'|@getFixedLabel}" align="center">{'MODULENAME'|@getFixedLabel}</th>
                <th width="250px" class="locking-left" title="{'BusinessQueryField'|@getFixedLabel}" align="center">{'BusinessQueryField'|@getFixedLabel}</th>
                <th width="145px" title="{'ENABLEBUSINESSQUERY'|@getFixedLabel}" align="center">{'ENABLEBUSINESSQUERY'|@getFixedLabel}</th>
                <th width="200px" title="{'NOBUSINESSINFOLNOTALLOWSAVE'|@getFixedLabel}" align="center">{'NOBUSINESSINFOLNOTALLOWSAVE'|@getFixedLabel}</th>
                <th width="145px" title="{'NOBUSINESSINFOLNOTALLOWIMPORT'|@getFixedLabel}" align="center">{'NOBUSINESSINFOLNOTALLOWIMPORT'|@getFixedLabel}</th>
                <th width="200px" title="{'ENABLEBUSINESSFUZZYQUERY'|@getFixedLabel}" align="center">{'ENABLEBUSINESSFUZZYQUERY'|@getFixedLabel}</th>
                <th width="145px" class="locking-rightleft" title="{'ENABLEBUSINESSBATCHBACKFILLING'|@getFixedLabel}" align="center">{'ENABLEBUSINESSBATCHBACKFILLING'|@getFixedLabel}</th>
                <th width="145px" class="locking-right" title="{'OPERATING'|@getFixedLabel}" align="center">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            </thead>
            <tbody>
            {assign var="listentity" value='1'}
            {assign var="i" value=0}
            {foreach item=entityinfo name=listentity key=tabid from=$businessinformation_arr}
                {assign var="j" value=$i++}
                {assign var="tmpmodule" value={$tabid|@getTabModuleName}}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$j}" data-tabid="{$tabid}" data-module="{$tmpmodule}" tabindex="{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        {else}
                    <tr id="setting_{$j}" data-tabid="{$tabid}" data-module="{$tmpmodule}" tabindex="{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                    <td >{$listentity}</td>
                    <td>{{$tabid|@getTabModuleName}|@getTranstab}</td>
                    <td class="locking-left ld-form-item-content">
                        <select id="businessqueryfield" name="businessqueryfield_{$tabid}" class="ld-select-inner" style="height: 30px;" onchange="BusinessInformationobj.changeBusinessQueryField(this)">
                            {foreach item=fieldinfo key=fieldid from=$entityinfo.field_arr}
                                <option value="{$fieldid}" {$fieldinfo.selected}>{$fieldinfo.fieldlabel}</option>
                            {/foreach}
                        </select>
                    </td>
                    <td>
                        <input type="checkbox" onclick="BusinessInformationobj.BusinessInformationset(this,'{$tmpmodule}','enablebusiness')"  class="second_switch" {if $entityinfo.enablebusiness eq 'yes'}checked=''{/if} />
                    </td>
                    <td>
                        <input type="checkbox" id="nobusiness_notsave" name="nobusiness_notsave" onclick="BusinessInformationobj.BusinessInformationset(this,'{$tmpmodule}','nobusinessnosave')"  class="second_switch" {if $entityinfo.nobusinessnosave eq 'yes'}checked=''{/if} {if $entityinfo.enablebusiness neq 'yes'}disabled{/if}/>
                        <a href="javascript:;" style="{if $entityinfo.nobusinessnosave neq 'yes'}display:none;{/if}margin-left:5px;" id="business_expection" name="business_expection" onclick="BusinessInformationobj.BusinessExpection(this)">{'SETEXCEPTION'|@getFixedLabel}</a>
                    </td>
                    <td>
                        <input type="checkbox" id="nobusiness_notimport" name="nobusiness_notimport" onclick="BusinessInformationobj.BusinessInformationset(this,'{$tmpmodule}','nobusinessnoimport')"  class="second_switch" {if $entityinfo.nobusinessnoimport eq 'yes'}checked=''{/if} {if $entityinfo.nobusinessnosave neq 'yes' || $entityinfo.enablebusiness neq 'yes'}disabled{/if}/>
                    </td>
                    <td>
                        <input type="checkbox" id="enablefuzzyquery" name="enablefuzzyquery" onclick="BusinessInformationobj.BusinessInformationset(this,'{$tmpmodule}','enablefuzzyquery')"  class="second_switch" {if $entityinfo.enablefuzzyquery eq 'yes'}checked=''{/if} {if $entityinfo.enablebusiness neq 'yes'}disabled{/if}/>
                        <a href="javascript:;" style="{if $entityinfo.enablefuzzyquery neq 'yes'}display:none;{/if}margin-left:5px;" id="business_fuzzycontrol" onclick="BusinessInformationobj.BusinessFuzzyControl(this)">{'SetFuzzy'|@getFixedLabel}</a>
                    </td>
                    <td class="locking-rightleft">
                        <input type="checkbox" id="enablebatchbackfill" name="enablebatchbackfill" onclick="BusinessInformationobj.BusinessInformationset(this,'{$tmpmodule}','enablebatchbackfill')"  class="second_switch" {if $entityinfo.enablebatchbackfill eq 'yes'}checked=''{/if} {if $entityinfo.enablebusiness neq 'yes'}disabled{/if}/>
                    </td>
                    <td class="locking-right">
                        {* <a class="Anu3_a" href="javascript:void(0);" onclick="BusinessInformation.getInstance().createBusinessModule({$tabid})" tag="edit">{'EDIT'|@getFixedLabel}</a> *}
                        <a class="Anu3_a redFont" href="javascript:void(0);" onclick="BusinessInformationobj.deleteBusinessModule(this)" tag="delete">{'DELETE'|@getFixedLabel}</a>
                    </td>
                </tr>
            {assign var="listentity" value=$listentity+1}
            {foreachelse}
                <tr bgcolor="white">
                    <td colspan="7" align="center" style="height: 0px;">
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
        <div style="width: 100%;line-height:35px;display: none;">
            <a id="addrow" name="addrow" style="margin: 0 auto;width: 50px;display: block" tabindex="0" onclick="BusinessInformationobj.createBusinessModule()">+{'NEW'|@getFixedLabel}</a>
        </div>
            
    </div>
{elseif {$selectpage} eq 'backfillingmaprule'}
    {*回填映射规则*}
    <div id="showpagecontentheader">
    <table  width="50%">
        <tbody>
        <tr>
            <td class="ld-form-item-label">
                {'SELECTMODULE'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content" >
                <select id="backfillingmapmodule" name="backfillingmapmodule" onchange="BusinessInformationobj.BackfillingmoduleChange(this)"  >
                    {foreach item=modulename name=listentity key=index from=$selectmodulearr}
                        <option value="{$modulename}" {if $selectmodule eq $modulename}selected{/if}>{$modulename|@getTranstab}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <div id="showpagecontentbody" style="overflow: auto;position: relative;">
        <table border=0 cellspacing=0 cellpadding=0 style="width: 100%;" class="settingTable" id="backfillingmap">
        <tr style="position: sticky; top:0px;z-index:1;">
            <th style="width: 65px;">#</th>
            <th title="{'MODULENAME'|@getFixedLabel}" width="80" align="center">{'MODULENAME'|@getFixedLabel}</th>
            <th title="{'RELFECTLBL_FIELDNAME'|@getFixedLabel}" width="200" align="center">{'RELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
            <th title="{'FIELDTYPEBEFOREMAPPING'|@getFixedLabel}" width="200" align="center">{'FIELDTYPEBEFOREMAPPING'|@getFixedLabel}</th>
            <th title="{'AFTERRELFECTLBL_FIELDNAME'|@getFixedLabel}" width="200" align="center">{'AFTERRELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
            <th title="{'FIELDTYPEAFFTERMAPPING'|@getFixedLabel}" width="200" align="center">{'FIELDTYPEAFFTERMAPPING'|@getFixedLabel}</th>
            <th title="{'OPERATING'|@getFixedLabel}" width="200" align="center">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        {assign var="listentity" value='1'}
        {assign var="i" value=0}
        {foreach item=entityinfo name=listentity key=index from=$backfillingmap_arr}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}"  data-module="{$selectmodule}" name="{$entityinfo.tianyanchaname}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                <tr id="setting_{$j}"  data-module="{$selectmodule}" name="{$entityinfo.tianyanchaname}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            <td style="width: 65px;">{$listentity}</td>
            <td width="80">{$selectmodule|@getTranstab}</td>
            <td width="200">
                {$entityinfo.label}
            </td>
            <td width="200">
                {'Text'|@getFixedLabel}
            </td>
            <td width="200" name="tranlabel">
                {$entityinfo.tranlabel}
            </td>
            <td width="200" name="trantype">
                {if $entityinfo.trancolumnname neq '' && $entityinfo.trancolumnname neq 'null'}
                    {if $entityinfo.type eq 'text'}
                        {'Text'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'textarea'}
                        {'TEXT_AREA'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'longtextarea'}
                        {'WholeTextArea'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'picklist'}
                        {'PickList'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'phone'}
                        {'Phone'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'mobile'}
                        {'Mobil'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'date'}
                        {'DATE'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'datetime'}
                        {'DateTime'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'email'}
                        Email
                    {elseif $entityinfo.type eq 'url'}
                        {'Website'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'moduleno'}
                        {'DocumentNumber'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'number'}
                        {'Numberc'|@getFixedLabel}
                    {elseif $entityinfo.type eq 'currency'}
                        {'Currencyc'|@getFixedLabel}
                    {else}
                        {$entityinfo.type}
                    {/if}
                {/if}
            </td>
            <td width="200">
                <a class="Anu3_a" onclick="BusinessInformationobj.EditBackfillingfield(this,'{$selectmodule}','{$entityinfo.tianyanchaname}')">{'EDIT'|@getFixedLabel}</a>
            </td>
            </tr>
            {assign var="listentity" value=$listentity+1}
            {foreachelse}
            <tr bgcolor="white">
                <td colspan="7" align="center" style="height: 0px;">
                    {include file="NoRecords.tpl"}
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
    </div>
{elseif {$selectpage} eq 'businesslog'}
    {*工商日志查询*}
    <div id="showpagecontentheader">
    <table  width="100%">
        <tbody>
        <tr>
            <td class="ld-form-item-label">
                {'SELECT'|@getFixedLabel}{'DATE'|@getFixedLabel}:
            </td>
            <td class="ld-form-item-content" >
                <input name="startdate" id="businesslogstartdate" class="Wdate ld-input-inner width120"  type="text"  size="20" maxlength="10" value="{$startdate}" onClick="WdatePicker();">
                ~
                <input name="enddate" id="businesslogenddate" class="Wdate ld-input-inner width120"  type="text"  size="20" maxlength="10" value="{$enddate}" onClick="WdatePicker();">
            </td>
            <td class="ld-form-item-content">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="BusinessInformationobj.SearchBusinesslogList(this);" title="{'SEARCH'|@getFixedLabel}">{'SEARCH'|@getFixedLabel}</a>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <div id="showpagecontentbody" style="overflow: auto;position: relative;">
        <table border=0 cellspacing=0 cellpadding=0 style="width: 100%;" class="settingTable" id="businesslog">
        <tr style="position: sticky; top:0px;z-index:1;">
            {foreach item=entityinfo name=listentity key=index from=$businessloglistheader_arr}
                {if $entityinfo == '#'}
                    <th style="width: 65px;">{$entityinfo}</th>
                {else}
                    <th title="{$entityinfo}" width="200" align="center">{$entityinfo}</th>
                {/if}
            {/foreach}
        </tr>
        {assign var="listentity" value='1'}
        {assign var="i" value=0}
        {foreach item=entityinfo name=listentity key=index from=$businessloglistshow_arr}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}"  class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                <tr id="setting_{$j}"  class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            {foreach item=keyentityinfo name=tmplistentity key=tmpindex from=$headerkeyarr}
                {if $keyentityinfo == '#'}
                    <td style="width: 65px;" name="num">{$entityinfo[$keyentityinfo]}</td>
                {elseif $keyentityinfo == 'action'}
                    <td width="200">
                        <a class="Anu3_a" onclick="BusinessInformationobj.getBusinesslogDetail('{$entityinfo.searchdate}')">{'VIEWDETAILS'|@getFixedLabel}</a>
                    </td>
                {else}
                    <td width="200">
                        {$entityinfo[$keyentityinfo]}
                    </td>
                {/if}
            {/foreach}
            {assign var="listentity" value=$listentity+1}
            {foreachelse}
            <tr bgcolor="white">
                <td colspan="7" align="center" style="height: 0px;">
                    {include file="NoRecords.tpl"}
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
    </div>
{elseif {$selectpage} eq 'businessdataanalysis'}
    {*数据分析*}
    <div id="showpagecontentheader">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" style="width:100%;table-layout: fixed;">
        <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
        <tr>
            <td class="ld-form-item-label">
                <span class="category_span">{'operatoroer'|@getFixedLabel}</span>
            </td>
            <td class="ld-form-item-content">
                <select class="ld-select-inner gwidth50" id="dataanalysisoperator" name="businessoperator">
                    <option value="" >{'ALL'|@getFixedLabel}</option>
                    {foreach item=entityinfo name=listentity key=index from=$operatorarr}
                        <option value="{$index}" {if $index eq $selectedoperator}selected{/if}>{$entityinfo}</option>
                    {/foreach}
                </select>
            </td>
            <td class="ld-form-item-label">
                {'QUERYMETHOD'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select class="ld-select-inner gwidth50" id="dataanalysissearchtype" name="businesssearchtype" >
                    <option value="" >{'ALL'|@getFixedLabel}</option>
                    {foreach item=entityinfo name=listentity key=index from=$operationtypearr}
                        <option value="{$index}" {if $selectedoperationtype eq $index}selected{/if}>{$entityinfo}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'SELECT'|@getFixedLabel}{'DATE'|@getFixedLabel}:
            </td>
            <td class="ld-form-item-content" >
                <input name="startdate" id="dataanalysisstartdate" class="Wdate ld-input-inner width120" type="text"  size="20" maxlength="10" value="{$startdate}" onClick="WdatePicker();">
                ~
                <input name="enddate" id="dataanalysisenddate" class="Wdate ld-input-inner width120" type="text"  size="20" maxlength="10" value="{$enddate}" onClick="WdatePicker();">
            </td>
            <td class="ld-form-item-label">
            </td>
            <td class="ld-form-item-content">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="BusinessInformationobj.SearchBusinessdataanalysis()" title="{'SEARCH'|@getFixedLabel}">{'SEARCH'|@getFixedLabel}</a>
            </td>
        </tr>
    </table>
    </div>
    <div id="showpagecontentbody" style="overflow: auto;position: relative;">
        <div id="businessdataanalysis_charts" style="{if {$businesslogarr|@count} >0}width: 100%;height: 300px;{/if}"></div>
        <table border=0 cellspacing=0 cellpadding=0 style="width: 100%;" class="settingTable" id="businessdataanalysistable">
            <tr >
                {foreach item=entityinfo name=listentity key=index from=$businessloglistheader_arr}
                    <th title="{$entityinfo}" width="200" >{$entityinfo}</th>
                {/foreach}
            </tr>
            {assign var="listentity" value='1'}
            {assign var="i" value=0}
            {foreach item=entityinfo name=listentity key=index from=$businesslogarr}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$j}"  class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        {else}
                    <tr id="setting_{$j}"  class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                {foreach item=keyentityinfo name=tmplistentity key=tmpindex from=$headerkeyarr}
                    <td width="200">
                        {$entityinfo[$keyentityinfo]}
                    </td>
                {/foreach}
                </tr>
                {foreachelse}
                <tr bgcolor="white">
                    <td colspan="3" align="center" style="height: 0px;">
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
            {/foreach}
            {if {$businesslogarr|@count} >0}
                <td width="300">{'TOTAL'|@getFixedLabel}</td>
                <td width="200">
                    {$searchcounttotal}
                </td>
                <td width="200">
                    {$searchvalidcounttotal}
                </td>
            {/if}
            </tbody>
        </table>
    </div>
{elseif {$selectpage} eq 'blacklist'}
    {*黑名单*}
    <div id="showpagecontentheader">
        <table  width="100%" id="blacklist_headertable">
        <tbody>
        <tr>
            <td class="ld-form-item-label">
                {'SEARCHKEY'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content" >
                <input type="text" fieldonly="1" tabindex="a" name="blacksearchkeywords" id="blacksearchkeywords" onkeyup="BusinessInformationobj.SearchBlacklistkeywords(event);" value="{if $searchwords neq ''}{$searchwords}{/if}" placeholder="{'SEARCHKEYWORDS'|@getFixedLabel}" class="ld-input-inner">
            </td>
            <td class="ld-form-item-label " style="width: 50%;" align="right">
                    <a href="javascript:;" class="ld-button ld-button-primary" onclick="BusinessInformationobj.EditBlackKeywords(0);" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <div id="showpagecontentbody" style="overflow: auto;position: relative;">
        <table border=0 cellspacing=0 cellpadding=0 style="width: 100%;" class="settingTable" id="backfillingmap">
            <tr style="position: sticky; top:0px;z-index:1;">
                <th style="width: 65px;">#</th>
                <th title="{'SEARCHKEY'|@getFixedLabel}" width="400" align="center">{'SEARCHKEY'|@getFixedLabel}</th>
                <th title="{'Person_in_charge'|@getFixedLabel}" width="200" align="center">{'Person_in_charge'|@getFixedLabel}</th>
                <th title="{'Createtime1'|@getFixedLabel}" width="200" align="center">{'Createtime1'|@getFixedLabel}</th>
                <th title="{'OPERATOR'|@getFixedLabel}" width="200" align="center">{'OPERATOR'|@getFixedLabel}</th>
                <th title="{'OPERATTIME'|@getFixedLabel}" width="200" align="center">{'OPERATTIME'|@getFixedLabel}</th>
                <th title="{'OPERATING'|@getFixedLabel}" width="200" align="center">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            {assign var="listentity" value='1'}
            {assign var="i" value=0}
            {foreach item=entityinfo name=listentity key=index from=$blackwordlistkey_arr}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$j}"  class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        {else}
                    <tr id="setting_{$j}"  class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                <td style="width: 65px;" name="num">{$listentity}</td>
                <td width="400" name="keywords">{$entityinfo.wordkey}</td>
                <td width="200">
                    {$entityinfo.creater_name}
                </td>
                <td width="200">
                    {$entityinfo.createdtime}
                </td>
                <td width="200" name="tranlabel">
                    {$entityinfo.modifieder_name}
                </td>
                <td width="200" name="trantype">
                    {$entityinfo.modifiedtime}
                </td>
                <td width="200">
                    <a class="Anu3_a" onclick="BusinessInformationobj.EditBlackKeywords('{$entityinfo.id}')">{'EDIT'|@getFixedLabel}</a>
                    <a class="Anu3_a redFont" onclick="BusinessInformationobj.DeleteBlackKeywords('{$entityinfo.id}')">{'DELETE'|@getFixedLabel}</a>
                </td>
                </tr>
                {assign var="listentity" value=$listentity+1}
                {foreachelse}
                <tr bgcolor="white">
                    <td colspan="7" align="center"  style="height: 0px;">
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>
    <div id="showpagecontentbottom">
        <div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;width: 100%;">
        </div>
    </div>
    <script>
        var last_crmpopup = CrmPopup.getPopupObj("last");
        var tmp_pagedata = {
            'currentpage': {$STARTPAGE},
            'count': {$LISTVIEWRECORDCOUNT},
            'pagecount': {$LISTVIEWPAGECOUNT},
            'language': language,
            'changepage': function (pagenum){
                last_crmpopup.businessInformationobj.getbalcklistbypage(pagenum);
            },
        }
        AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
        var tmp_divid = '';
        tmp_divid = last_crmpopup.divid;
        var listviewpagination = ld('#'+tmp_divid+' #listviewpagination');
        var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);
        last_crmpopup.businessInformationobj.listviewpaginationobj = listviewpaginationobj;
    </script>
{/if}