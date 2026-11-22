<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<table border=0 cellspacing=0 cellpadding=0 width=100% class="ld-table-container-draggable fir-center">
    <thead>
        <tr>
            <th width="65px">#</th>
            <th width="250px" class="locking-left" align="left" title="{'CNTAG'|@getFixedLabel}">{'CNTAG'|@getFixedLabel}</th>
            <th width="250px" align="left" title="{'ENTAG'|@getFixedLabel}">{'ENTAG'|@getFixedLabel}</th>
            <th width="145px" align="left" title="{'DATABASECOLUMNNAME'|@getFixedLabel}">{'DATABASECOLUMNNAME'|@getFixedLabel}</th>
            <th width="145px" align="left" title="{'WIDTHMM'|@getFixedLabel}">{'WIDTHMM'|@getFixedLabel}</th>
            <th width="145px" align="left" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
            <th width="145px" align="left" title="{'LBL_MANDATORYFIELDS'|@getFixedLabel}">{'LBL_MANDATORYFIELDS'|@getFixedLabel}</th>
            <th width="145px" class="locking-rightleft" align="left" title="{'DOYOUNEEDTOEDIT'|@getFixedLabel}">{'DOYOUNEEDTOEDIT'|@getFixedLabel}</th>
            <th width="145px" class="locking-right">{'OPERATING'|@getFixedLabel}</th>
        </tr>
    </thead>
    <tbody>
    {$PRODUCTFIELDHTML}
    </tbody>
</table>

<script>
var formulafieldsobj='{$FORMUALFIELDS}';
{literal}
    var objField=new Array();
    var restobj = eval('('+ formulafieldsobj +')')?eval('('+ formulafieldsobj +')'):JSON.parse(formulafieldsobj);
    for(var i=0 ;i<restobj.formula.length;i++){
        var toolfield=new toolFieldInfo();
      
        toolfield.columnname=restobj.formula[i].columnname;
        toolfield.fieldlabel=restobj.formula[i].fieldlabel;
        objField.push(toolfield);
    }
    ListFieldDragSort();
    tooltip('.sort-tip-items', {transition: true, time: 200});
{/literal}
</script>