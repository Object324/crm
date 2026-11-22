<div class="step_flow">
        		<div class="step_first {if $STEPINDEX gte 1} step_choosed {/if}">
        		  <p>{$ARRLABEL.fileuploadlabel}</p>
        		  <div class="process {if $STEPINDEX gt 1} process_finish {/if}"><span class="corner"></span></div>
        		</div>
        		<div class="step_two {if $STEPINDEX gte 2} step_choosed {/if}">
        	   	   <p>{$ARRLABEL.mappingfieldlabel}</p>
        		  <div class="process {if $STEPINDEX gt 2} process_finish {/if}"><span class="corner"></span></div>
        		</div>
        		<div class="step_middle {if $STEPINDEX gte 3} step_choosed {/if}">
        		  <p>{$ARRLABEL.importdatalabel}</p>
        		  <div class="process {if $STEPINDEX gt 3} process_finish {/if}"><span class="corner"></span></div>
        		</div>
        		<div class="step_last {if $STEPINDEX gte 4} step_choosed {/if}">
        		  <p>{$ARRLABEL.finishedlabel}</p>
        		  <div class="process {if $STEPINDEX gt 4} process_finish {/if}"><span class="corner"></span></div>
                </div>
            
</div>