<div class="E_pop_tit">
    <strong class="E_ptita">{'IMPORT'|@getFixedLabel}</strong>
    <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('actiondiv');"></button>
</div>
{if $DISPLAYERROR eq ''}
    <form action="index.php" name="frmimport">
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tbody>
                <tr>
                    <th align="left" colspan="2">
            			{$MODULELABEL} >> {'IMPORT'|@getFixedLabel}
            		</th>
                </tr>
                <tr>
                    <td>{'Stage'|@getFixedLabel} 2 <span style="padding-left:20px;font-size:12px;">{'TCMFTMF'|@getFixedLabel}</span></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table class="listEntries" width="100%" cellspacing="1" cellpadding="0">
                            <colgroup>
                                <col width="25%"/>
                                <col width="25%"/>
                                <col width="25%"/>
                                <col width="25%"/>
                            </colgroup>
                            <tr>
                                <th>{'Field_title'|@getFixedLabel}</th>
                                <th>{'Row'|@getFixedLabel}</th>
                                <th>CRM&nbsp;{'LBL_Field'|@getFixedLabel}</th>
                                <th>{'Default'|@getFixedLabel}</th>
                            </tr>
                        </table>
                        <div id="ImportXlsDiv" style="max-height:360px;overflow:auto;">
                        <table id="Importtable" class="listEntries" width="100%" cellspacing="1" cellpadding="0" style="border-collapse:separate;">
                            <colgroup>
                                <col width="25%"/>
                                <col width="25%"/>
                                <col width="25%"/>
                                <col width="25%"/>
                            </colgroup>
                            {foreach item=value key=ky from=$IMPORTDATA}
                                <tr bgcolor="white">
                                {assign var='V3' value=$value.3 }
                                <td>{$value.0}<input type="hidden" name="isfieldname[]" value="{$value.0}" /> </td>
                                <td>{$value.1}<!--<input type="hidden" name="isfieldnamevalue[]" value="{$value.1}" />--></td>
                                <td>
                                    <select  style="width: 75%" name="mapped_fields[]" onchange="defaultImportXls(this,'{$ky}')">
                                        {foreach item=drp  from=$IMPORTCOLUMN}
                                             {if $value.3 eq $drp.1}
                                                <option value="{$drp.1}" selected="true">{$drp.2} </option>
                                             {else}
                                                 <option value="{$drp.1}" >{$drp.2} </option>
                                             {/if}
                                        {/foreach}
                                    </select>
                                </td>
                                <td>
                                    <span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
                                      {if $value.2 eq 15}
                                        <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue">
                                            {foreach item=drp key=drpky from=$DROPHTML.$V3}
                                                
                                                    <option value="{$drpky}">{$drpky}</option>
                                                
                                            {/foreach}
                                        </select>
                                      {elseif $value.2 eq 56}
                                         <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                      {elseif $value.2 eq 5}
                                     	
                            			<input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate" value="" onClick="WdatePicker()" size="15" />
                                        <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
                                      {elseif $value.2 neq 0}
                                        <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                      {/if}
                                     </span>
                                </td>
                                </tr>
                                
                            {/foreach}
                        
                        
                        </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td align="right" colspan="2" class="borderALL" style="border-top:none;">
                        <input type="hidden" value="{$MODULE}" name="module"/>
                        {if $importxbx eq 'xbx'}
                            <input  type="hidden" value="XBXImportXls" name="action"/>
                        {else}
                            <input  type="hidden" value="ImportXls" name="action"/>
                        {/if}
                        <input type="hidden" value="Third" name="xlsStep"/>
                        <input class="editauto" type="button" value="{'IMPORT'|@getFixedLabel}" onclick="ImportXlsSecondStep(this,'{$IMPORTMODULE}')"/>
                        <input class="cancelauto" type="button" id="canceltype" onclick="fninvshnew('actiondiv');" value="{'CANCEL'|@getFixedLabel}" name="cancel">
                    </td>
                </tr>
            </tbody>
        </table>
    </form>

    <div id="defaultValuesElementsContainer" style="visibility: hidden; height: 0px;">
        {foreach item=value from=$IMPORTCOLUMN}
            {assign var='V3' value=$value.1}
            {if $V3|@array_key_exists:$SELCOLUMN neq true}
                <span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
                    {if $value.0 eq 15}
                        <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue">
                            {foreach item=drp key=drpky from=$DROPHTML.$V3}
                                <option value="{$drpky}">{$drpky}</option>
                            {/foreach}
                        </select>
                    {elseif $value.0 eq 56}
                         <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                    {elseif $value.0 eq 5}
                     	<input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate" value="" onClick="WdatePicker()" size="15" />
                        <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
                    {elseif $value.0 neq 0}
                        <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                    {/if}
                </span>
            {/if}
        {/foreach}
    </div>
{else}
    <div class="pad2010">
        {$DISPLAYERROR}
    </div>
{/if}