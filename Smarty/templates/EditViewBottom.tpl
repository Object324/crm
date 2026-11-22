
{if ($MODULE eq 'Emails') and ($USE_RTE eq 'true')}
  <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
  <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>
  <script type="text/javascript" defer="1">
	var textAreaName = null;
	{if $MODULE eq 'Documents'}
    textAreaName = "notecontent";
	{else}
    textAreaName = 'description';
	{/if}
  {literal}
    oCKeditor = UE.getEditor(textAreaName);//ÊµÀý»¯±à¼­Æ÷
  {/literal}
  if(document.getElementById('Rich'+textAreaName) != undefined)
	{ldelim}
		document.getElementById('Rich'+textAreaName).onclick=function()
		{ldelim}
			OpenRichTextTemplate(this);
		{rdelim}
	{rdelim}
  </script>
{/if}
{if $MODULE eq 'Accounts'}
  <script>
  	ScrollEffect.limit = 201;
  	ScrollEffect.closelimit= 200;
  </script>
{/if}
<script>	

  var fieldname = new Array({$VALIDATION_DATA_FIELDNAME})
  var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL})
  var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE})
	var ProductImages=new Array();
	var count=0;
	function delRowEmt(imagename)
	{ldelim}
    ProductImages[count++]=imagename;
	{rdelim}

	function displaydeleted()
	{ldelim}
		var imagelists='';
		for(var x = 0; x < ProductImages.length; x++)
		{ldelim}
			imagelists+=ProductImages[x]+'###';
		{rdelim}

		if(imagelists != '')
			document.EditView.imagelist.value=imagelists;
	{rdelim}
</script>

{if $FIELDHELPINFO}
<script type='text/javascript'>
{literal}var fieldhelpinfo = {}; {/literal}
{foreach item=FIELDHELPVAL key=FIELDHELPKEY from=$FIELDHELPINFO}
	fieldhelpinfo["{$FIELDHELPKEY}"] = "{$FIELDHELPVAL}";
{/foreach}
</script>
{/if}