<script language="javascript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>
<div class="D_pop_box LdPopWidth500px">    
	<div class="D_pop_tit">        
           	<strong class="D_ptita">{'WORKCALENDERMANAGEMENT'|@getFixedLabel}</strong>        	
		<a href="javascript:fninvshnew('listworkcalender');showPopDiv('EditTrackProfile');" class="D_ptitc">
			<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
		</a>
	</div>
    <div style="margin:10px;">
        <div style="margin-bottom:8px;">
            <a  class="Anu3_a" onclick="EditWorkingSpace('','','','','all_poptable','')">{'ADDLESSIONPLAN'|@getFixedLabel}</a>
        </div>
        <div style="max-height:300px;overflow-y: auto;">
            <table class='listEntries fir-center' border="0" cellspacing="1" cellpadding="0" width="100%">
              <th>#</th>
              <th>{'CALENDERNAME'|@getFixedLabel}</th>
              <th>{'OPERATING'|@getFixedLabel}</th> 
              {foreach name=workcalinfo key=work_key item=workcalinfo from =$WORKCALINFO}	       
                     <tr id="workcalender_{$workcalinfo.workcalender_id}" class="lvtColData" > 
                        <td align='center'>{$work_key+1}</td>
                        <td id="{$workcalinfo.workcalender_id}">          
                        {$workcalinfo.workcalender_name}
                        </td>
                        <td>                     
                             {if $workcalinfo.workcalender_id eq 1}<!--预置的默认工作日历不能删除-->
                                 <a class='Anu3_a' href='javascript:void(0);' onclick='EditWorkingSpace({$workcalinfo.workcalender_id},"edit","","","all_poptable","")'>{'EDIT'|@getFixedLabel}</a>
                             {else}
                                 <a class='Anu3_a' href='javascript:void(0);' onclick='EditWorkingSpace({$workcalinfo.workcalender_id},"edit","","","all_poptable","")'>{'EDIT'|@getFixedLabel}</a>
                                 <a class='Anu3_a' href='javascript:void(0);' onclick="DeleteWorkingcalender({$workcalinfo.workcalender_id},{$START})">{'DELETE'|@getFixedLabel}</a>
                             {/if}
                        </td>
                    </tr>	
        	  {/foreach}  
            </table>
        </div>
    	<div class="PageDiv0"style="float:right;margin-top:8px;">
            <ul><li>{$PAGESCOPE}</li></ul>
        </div>   
        <div style="clear:both;"></div>  
    </div>  
</div>
