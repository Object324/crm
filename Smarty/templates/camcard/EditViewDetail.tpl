<table id="CamCardEdit" class="" border="0" cellpadding="0" cellspacing="0" width="100%">
    <thead>
        <tr>
            <th width="5%">#</th>
            <th width="20%" align="left">{'CAMCARDFIELDS'|@getFixedLabel}</th>
            <th width="40%" align="left">{'CAMCARDCAPTION'|@getFixedLabel}</th>
            <th width="35%" align="left">{'CAMCARDCRMFIELDS'|@getFixedLabel}</th>
        </tr>
    </thead>
    <tbody>
        {assign var="modulenamenum" value='1'}
        {assign var="i" value=0}
        {foreach item=row key=key from=$OPTIONLIST}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr mark="content_rows" class="lvtColData" tag="{$row.card_field_sh}">
            {else}
                <tr mark="content_rows" class="lvtColDataBj" tag="{$row.card_field_sh}">
            {/if}
                <td>{$modulenamenum}</td >
                <!-- <td hidden>{$row.card_field}</td> -->
                <td>{$row.card_field_sh}</td>
                <td>{$row.describe}</td>
                <td><select name="select_{$row.card_field_sh}" id="select_{$row.card_field_sh}" class="ld-select-inner">{$row.select_html}</select></td>
            </tr>
            {assign var="modulenamenum" value=$modulenamenum+1}
        {/foreach}
    </tbody>
</table>