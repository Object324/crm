<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<form action="index.php" method="post" id="TopicBlockSelectIcon" name="TopicBlockSelectIcon">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td width="200">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="defaultIconlistList" id="defaultIconlistList" multiple="" onclick="CardSettingsobj.clickSelecticon()">
                {assign var='i' value=1}
                {foreach item=iconurl key=iconname from=$defaulticon name = iconlistname}
                    {if $i eq 1}
                    {assign var = firstvalue value=$iconurl}             
                    {/if}
                    {assign var ='j' value=$i++}                                         
                    <option value="{$iconname}" {if $j eq 1}selected=""{/if} tag="{$iconurl}">图标{$j}</option>                           
                                                                                                              
                {/foreach}
            </select> 
    	</td>
    	<td style="background-color: #c5c5c5;">
            <div style="position: relative;left: 100px;">
            <div id="defaultpreview" name='defaultpreview'>
                <img src="{$firstvalue}" style="width: 80px;height: 80px;"  border="0"/>
            </div>
            </div>
        </td>
      </tr>
    </table>
</form>