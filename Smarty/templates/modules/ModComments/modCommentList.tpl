 <!--添加评论 by LD Can 20130205 -->
{* vtlib Customization: Embed DetailViewWidget block:// type if any *}
{if $MODECHANGE eq 'yes'}
	    {if $COMMENTMODE neq 'concise'}
	        {include file="modules/ModComments/widgets/DetailViewBlockCommentNew.tpl"}
				
	    {else}
	        {include file="modules/ModComments/widgets/DetailViewBlockCommentOld.tpl"}
	    {/if}

{else}
	{if $MODCOMMENTDISPLAYRIGHT eq 'yes'}
	    {$MODCOMMENTOBJ}
	{else}
			{$MODCOMMENTOBJ}
	{/if}
{/if}
			
	
    
