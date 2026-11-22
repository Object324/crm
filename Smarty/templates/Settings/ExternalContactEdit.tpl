<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="parenttab" value="Settings"/>
  <input type="hidden" name="action"/>
  <input type="hidden" name="ajax" value="save"/>
  <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
  <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
  <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
      <td class="ld-form-item-content">
        <input type="checkbox" class="second_switch" name="switch" value="open" {if $SWITCH eq 'open'}checked{/if} />
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'IMPORTDATATTITLE6'|@getFixedLabel}</td>
      <td class="ld-form-item-content">
        <div id='view_scope' class="select-input">
            <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();">
            <span class="padR10">{'ALLTHEUSERS'|@getFixedLabel}</span></label>
            <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$USERSACCOUNT}')" value="group" name="radioUser">
            <span class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</span></label>
            <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$USERSACCOUNT}');" value="user" name="radioUser">
            <span class="padR10">{'SETBYUSERS'|@getFixedLabel}{'APPLICABLESCOPE'|@getFixedLabel}</span></label>
            <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'role'}checked="" {/if} undefined="" onclick="CustomScope.setScopeRole('{$ALLOCATEID}');" value="role" name="radioUser">
            <span class="padR10">{'SetByRole'|@getFixedLabel}</span></label>
            <input id="customscope_type" class="templateprintuser" type="hidden" value="{$USERSACCOUNT_TYPE}" name="customscope_type">
            <input id="customscope_ids" class="templateprintuser" type="hidden" value="{$USERSACCOUNT}" name="customscope_ids">
        </div>
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label"></td>
      <td class="ld-form-item-content">
        {'EXPLAIN'|@getFixedLabel}：{'ExplainOfExternalContact'|@getFixedLabel}
      </td>
    </tr>
  </table>
</form>
</div>