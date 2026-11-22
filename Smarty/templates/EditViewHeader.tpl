
<script type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script type="text/javascript">
	ld.noConflict();
</script>
{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
getJsScript('include/js/FieldDependencies.js',function(){ldelim}
	fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});
	ld(function(){ldelim}
		(fielddepend.init());
	{rdelim});
{rdelim})
</script>
{/if}

<!-- overriding the pre-defined #company to avoid clash with lingdang_field in the view -->
{literal}
<style type='text/css'>
#company {
	height: auto;
	width: 90%;
}
</style>
{/literal}

<script type="text/javascript">
var gVTModule = '{$smarty.request.module|@vtlib_purify}';
function sensex_info()
{ldelim}
        var Ticker = $('tickersymbol').value;
        if(Ticker!='')
        {ldelim}
                $("vtbusy_info").style.display="inline";
                new Ajax.Request(
                      'index.php',
                      {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: 'module={$MODULE}&action=Tickerdetail&tickersymbol='+Ticker,
                                onComplete: function(response) {ldelim}
                                        $('autocom').innerHTML = response.responseText;
                                        $('autocom').style.display="block";
                                        $("vtbusy_info").style.display="none";
                                {rdelim}
                        {rdelim}
                );
        {rdelim}
{rdelim}
function AddressSync(Addform,id)
{ldelim}
	checkAddress(Addform,id);
{rdelim}

</script>