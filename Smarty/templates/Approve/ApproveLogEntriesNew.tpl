{if $noapprovesetting neq 'yes'}
<div style="margin:10px 0px;padding:5px;">
    <span style="margin:0px 5px 0px 10px;" >{'SHOWCURRENTAPPROVE'|@getFixedLabel}</span>
    <input type="checkbox" class="second_switch" name="showcurrentapprove" {if $APPROVELOGSETINFO['showcurrentapprove'] neq 'no'}checked="true"{/if} modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApproveLogSet(this);" style="margin-bottom: 3px;" /> 
    <span style="margin:0px 5px 0px 20px;" >{'HIDEAUTOPASSSTEP'|@getFixedLabel}</span>
    <input type="checkbox" class="second_switch" name="hideautopassstep" {if $APPROVELOGSETINFO['hideautopassstep'] neq 'no'}checked="true"{/if} modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApproveLogSet(this);" style="margin-bottom: 3px;"/>
</div>
{/if}
<div name="approvelog_view" class="approvelog_view">
    
    <div class="topnews">
    <div class="box">
      <ul class="event_list" style="overflow: hidden;background: #fff;">
        {assign var=count value=1}
        {foreach item=approve name=loop key=index from=$WholeApproveLog}
            {if $count eq 1 && $approve.showtype eq 'pre_hidden'}
            <div class="approvelog-20230506 {$approve.icon_class} pre_hidden_btn" style="{if $count eq 1}margin-top:0px;{/if}{if $pre_hidden_btn eq 'no'}display:none;{/if}" tag="pre_hidden_btn">
                <b class="icons {$approve.icon_class}" ></b>
                <span class="hidden_btn" modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApprovelogShowtype(this)" style="font-size:17px;margin-left:0px;" hiden_type="pre_hidden_btn" show_type="{$approve.showtype}" ><···></span>
            </div>  
            {/if}
            <div class="approvelog-20230506 {$approve.icon_class}" style="{if $count eq 1}margin-top:0px;{/if} {if $approve.showtype eq 'pre_hidden' && $pre_hidden_btn neq 'no'}display:none;{else if $approve.showtype eq 'next_hidden' && $next_hidden_btn neq 'no' }display:none;{/if}"  tag="{$approve.showtype}" >
                <b class="icons {$approve.icon_class}"></b>
                <span class="Title">{$approve.stepname}</span>
                <span style="color:{$approve.tip_color};">{$approve.tip}</span>
                {if $approve.expediting eq 'yes'}
                <span style="background-color:rgb(255,127,0);color: white;padding: 2px 7px;border-radius: 3px;">{'Expediting'|getFixedLabel}</span>
                {/if}
                {if $count eq 1 && $approve.showtype eq 'pre_hidden'}
                    <span class="hidden_btn" modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApprovelogShowtype(this)" style="cursor:pointer;{if $pre_hidden_btn neq 'no'}display:none;{/if}" tag="pre_hidden"  show_type="pre_hidden_btn" hiden_type="pre_hidden" >{'COLLAPSE'|@getFixedLabel}</span>
                {/if}
                {foreach item=stepinfo key=stepindex from=$approve.approveloginfo}
                <li>
                    <div class="div_p" {if $noapprovesetting eq 'yes'}style="width:90%;"{/if}>
                        <div class="div_span">
                        {if $approve.concurrentid > 0 }
                            <div>
                                <span>{'STEPNAME'|getFixedLabel}: {$stepinfo.STEPNAME}</span>
                            </div>
                        {/if}
                        <div class="">
                        <b class="icons_detail {$stepinfo.icon_class}" style="top: -1px;"></b>
                        <span  style="color:{$stepinfo.tip_color};">{$stepinfo.tip}</span>
                        <span>{$stepinfo.OPERATOR}</span>
                        <span style="color:rgb(189,194,202);">{$stepinfo.CREATEDTIME}</span></div>
                        {if $stepinfo.APPROVERESULT neq ''}
                            <div><span>{$stepinfo.APPROVERESULT}</span></div>
                        {/if}
                        {if $stepinfo.DESCRIPTION neq ''}
                            <div><span>{'APPROVALSUGGESTION'|getFixedLabel}:
                            <span style="color:{$stepinfo.descrition_color};margin-left:0px;">{$stepinfo.DESCRIPTION}</span></span></div>
                        {/if}
                        {if $AUTOGRAPH eq 1 && $stepinfo.APPROVEAUTOGRAPHPATH neq ''}
                			<div style="width:100px;height:auto;" >
                                <img id="{$stepinfo.APPROVEID}_img" style='cursor:pointer;width:100%;height:100px;transform: rotate(-90deg);margin-left: 30px;' 
                                    onclick="previewImage(this)" border=0 src='{$stepinfo.APPROVEAUTOGRAPHPATH}'>        
                            </div>
                		{/if}
                        </div>
                    </div>
                </li>
                
                {/foreach}
            </div>               
            {if $approve.showtype eq 'next_hidden'}
                {assign var=next_hidden value='yes'}
            {/if}            
            {assign var=count value=$count+1}            
        {/foreach}
      </ul>
    </div>
    </div>
</div>
<div name="approvelog_view" class="approvelog_view_hid" style="font-size:14px;margin:5px 0 10px 0;">
{if $next_hidden eq 'yes'}
    <span class="hidden_btn" modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApprovelogShowtype(this)" tag="next_hidden_btn" style="{if $next_hidden_btn eq 'no'}display:none;{/if}"  hiden_type="next_hidden_btn" show_type="next_hidden" >{'LOADMORENODES'|getFixedLabel}</span>
    <span class="hidden_btn" modulename="{$MODULENAME}" record="{$RECORD}" onclick="ChangeApprovelogShowtype(this)" tag="next_hidden" style="{if $next_hidden_btn neq 'no'}display:none;{/if}" hiden_type="next_hidden" show_type="next_hidden_btn" >{'COLLAPSE'|getFixedLabel}</span>         
{/if}
<input name="pre_hidden_btn" value="{$pre_hidden_btn}" type="hidden" />
<input name="next_hidden_btn" value="{$next_hidden_btn}" type="hidden" />
</div>


<script>
    // 使用listview.js中的previewImage函数 展示图片
    ld(function(){
        var images= ld('#approve_log_table img');
        if(images.length>0){
            ld.each(images,function (i,val) {
                // 使用previewImage函数 需要提前加载加载事件。要不会出现第一次点击不能弹出
                previewImage(val);
            })
        }
    })
</script>