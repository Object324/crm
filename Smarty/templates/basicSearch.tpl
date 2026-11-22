<div name="dv_listbasicsearch" id="dv_listbasiscsearch" class="E_pop_box LdPopWidth400px" style="display:none">
   
    <table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td  align="right">{'SEARCHHISTORY'|@getFixedLabel}</td>
            <td style="width: 75%;overflow:inherit;">
                <div name="SearchHistory" >
                    <select class="commonSelectPop gwidth90" >
                        <option style="display:none;"></option>
                        <option>{'NOTTOEXIST'|@getFixedLabel}{'SEARCHHISTORY'|@getFixedLabel}</option>
                    </select>
                </div>
            </td>
        </tr>
        <tr>
            <td align="right">{'Find_field'|@getFixedLabel}</td>
            <td>
    			<div id="basicsearchcolumns_real">
    			<select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth90">
    			 {html_options  options=$SEARCHLISTHEADER selected=$SEATCH_INPUT.search_field}
    			</select>
    			</div>
                <input type="hidden" name="searchtype" value="BasicSearch">
    		</td>
        </tr>
        <tr>
            <td align="right">{'SEARCHKEY'|@getFixedLabel}</td>
    		<td>
				<input type="text" onkeyup="searchSubmit(event,'Basic')" class="commonTextBoxPop" name="search_text" value="{$SEATCH_INPUT.search_text}">
			</td>
        </tr>
    </table>
    
</div>