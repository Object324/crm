<script>
	ld("#dv_popup_listhighersearch [name=pop_adv_filter_div]").html("");
</script>
<form name="addToPB" method="POST" id="addToPB">
  {$PRODUCTLISTHEADER}
  <div style="max-height: 350px;overflow-y: auto;" name="ListViewContents">
    {include file="AddProductsToPriceBookContent.tpl"}
  </div>
</form>
