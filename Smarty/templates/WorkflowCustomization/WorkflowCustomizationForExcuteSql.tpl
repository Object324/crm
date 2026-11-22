<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
	<input type="hidden" name="workflow_aciton_type" value="ExcuteSql" />
	<input type="hidden" name="workflow_id" value="{$WORDFLOW_ID}" />
	<input type="hidden" name="tabid" value="{$TABID}" />
	<input type="hidden" name="mode" value="save" />
	<input type="hidden" name="workflow_actionid" value='{$workflow_actionid}' />
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
		 <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'ActionTitle'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="action_title" tag="{'ActionTitle'|@getFixedLabel}" value="{$ACTION_TITLE}" />
            </td>
        </tr>
        <tr>
        	<td class="ld-form-item-label">
				<font color="red">*</font>SQL
            </td>
            <td class="ld-form-item-content">
				<textarea placeholder="" class="ld-textarea-inner" tabindex="d" tag="{'ExcuteSQL'|@getFixedLabel}" fieldonly="0" name="excute_sql_content" id="excute_sql_content" cols="90" style="height: 250px;overflow-y: scroll;">{$QUERY_SQL}</textarea>
            </td>
        </tr>
    </table>
	<div style="width: 100%;padding: 0 10px;">
	</div>
	<div class="listRloesHelp padB20">
		<font color="red">{'SHARERULE_EXPLAIN'|@getFixedLabel}</font>
		<ul>
			<li>{'SQLstatementssupportcallingstoredprocedures'|@getFixedLabel}</li>
			<li>{'DROPandotherkeywordsinSQLstatements'|@getFixedLabel}</li>
			<li>{'WildcardcurrentdocumentID'|@getFixedLabel}</li>
		</ul>
	</div>
</form>