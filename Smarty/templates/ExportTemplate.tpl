<script type="text/javascript">
    {literal}
        function ckAllExportxls(obj)
        {
             var cks=document.getElementsByName('exports[]');
           
          
                for(var i=0;i<cks.length;i++)
                {
                    var value=cks[i].getAttribute('typeofdata');
                     if(value!='M')
                     {
                        cks[i].checked=obj.checked;
                     }
                }
         
        }
    {/literal}
</script>

<div class="ExportTemp">
<div class="foot">
	<input class="createauto" type="button" value="{'EXPORTTEMPLATES'|@getFixedLabel}" onclick="ExportTemplate(this)" />
	<input type="button" class="cancelauto" onclick="history.go(-1)" value="{'ASTEP'|@getFixedLabel}" >
    {if 'Calendar' != $MODULE}
		<input type="button" class="cancelauto" onclick="location.href='index.php?module={$MODULE}&action=index';" value="{'CANCEL'|@getFixedLabel}" >
	{else}
		<input type="button" class="cancelauto" onclick="location.href='index.php?module={$MODULE}&action=ListView';" value="{'CANCEL'|@getFixedLabel}" >
	{/if}
</div>
<form name="frmExport" action="index.php">
<input  type="hidden" value="{$MODULE}" name="module"/>
<input  type="hidden" value="ExportTemplateFile" name="action"/>

<div class="top">{$MODULE|@getTranstab} &gt;&gt; {'EXPORTTEMPLATES'|@getFixedLabel} </div>

<table class="listEntries" width="100%" cellspacing="1" cellpadding="0" border="0">
    <tr>
        <th width="15%" style="text-align:left;"><input type="checkbox" onclick="ckAllExportxls(this)"/></th>
        <th>{'BLOCK'|@getFixedLabel}</th>
        <th>{'FIELDNAME'|@getFixedLabel}</th>
    </tr>
    {foreach item=value name=export key=ky from=$EXPORTS}
     {if $smarty.foreach.export.index %2 ==0}
     <tr class="lvtColData">
     {else}
     <tr class="lvtColDataBj">
     {/if}
        {if $value.1 eq 'M'}
            <td>
				<input  type="checkbox" typeofdata='M' checked="true" disabled="true" value="{$ky}-{$value.3}" />
				<input type="hidden" name="exports[]" value="{$ky}-{$value.3}"/>
            </td>
        {elseif $value.1 eq 'DEFAULT'}
             <td>
				<input  type="checkbox" typeofdata='V' checked="true"  value="{$ky}-{$value.3}"  name="exports[]" />
				<!--<input type="hidden" name="exports[]" value="{$ky}-{$value.3}"/>-->
            </td>
        {else}
           <td ><input  type="checkbox" name="exports[]" typeofdata='K' value="{$ky}-{$value.3}" /></td>
        {/if}
        <td>{$value.0}</td>
        <td>{$value.2}</td>
        
    </tr>
    {/foreach}
</table>

<div class="foot" style="border-top: none;">
	<input class="createauto" type="button" value="{'EXPORTTEMPLATES'|@getFixedLabel}" onclick="ExportTemplate(this)" />
	<input type="button" class="cancelauto" onclick="history.go(-1)" value="{'ASTEP'|@getFixedLabel}" >
    {if 'Calendar' != $MODULE}
		<input type="button" class="cancelauto" onclick="location.href='index.php?module={$MODULE}&action=index';" value="{'CANCEL'|@getFixedLabel}" >
	{else}
		<input type="button" class="cancelauto" onclick="location.href='index.php?module={$MODULE}&action=ListView';" value="{'CANCEL'|@getFixedLabel}" >
	{/if}
</div>
</form>
</div> 


