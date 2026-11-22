{if $UPDATEING eq 'yes'}
    <div id="hideDiv" style="height: 100%; width: 100%; position: fixed; left: 0px; top: 0px; background-color: rgb(128, 128, 128); z-index: 9998; opacity: 0.6;"></div>
        
        <div id="updateWareSqlDiv" class="D_pop_box LdPopWidth650px" style="position: fixed; z-index: 9999; top: 50%; left: 50%; display: block; margin-top: -79px; margin-left: -201px; max-height: 500px; width: 400px; background: rgb(253, 253, 253);">
            <div class="D_pop_tit">
                <strong class="D_ptita" id="deleteremindertitlename">温馨提示</strong><a href="javascript:;" class="D_ptitc" onclick="fninvshnew();"><img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="关闭" title="关闭"></a>  
            </div>
            <div id="updateWareSqlDivcontent" class="pop_remind_content" style="max-height: 400px; border: none;">
                <div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">
                    <div class="msgDlg_left">
                        <div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon">
                        </div>
                    </div>
                <div class="msgDlg_right">
                    <div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">
                        数据库正在升级中（请不要关闭当前浏览器），如果长时间没有响应，请尝试通过手动升级解决！
                    </div>
                </div>
            </div>
        </div>
        <div class="D_pbtn ww_dialog_foot">
            <input class="D_pbtnok" value="确认" type="button" onclick="fninvshnew('hideDiv');document.getElementById('updateWareSqlDiv').style.display='none';">
        </div>
    </div>
</div>
{else}



<div id="dvUpdate" class="D_pop_box LdPopWidth450px" style="margin-top:-50px;display: block;position: absolute; z-index: 9999;height:150px; visibility: visible;">
        <div class="D_pop_tit">
            <strong class="D_ptita">升级数据库</strong>
            <a class="D_ptitc" href="javascript:fninvshnew('dvUpdate');">
            <img title="关闭" alt="关闭" src="themes/icon/pop_close.png" style="margin:5px 0px 0px 4px;padding:0px;outline:0;">
            </a>
        </div>
        <table class="D_pop_bod" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">
        <tbody>
            <tr>
                <td style="text-align:center;">
                    <div>
                        <div id="dv" style="float: left;">
                        </div>
                        <div style="float: right;">
                            <?php if($common_version['oem_crm'] == 'no'){ ?>
                                <a href="javascript:void(0);" style="float: right;cursor: pointer;display: inline-block;background-image: url(../../themes/softed/images/home-icons.png);background-repeat: no-repeat;vertical-align: middle;position: relative;width: 20px;height: 17px;background-position: -5px -251px;" onclick="window.open('<?php echo $linkurl; ?>')"></a>
                            <?php } ?>
                        </div>
                    </div>
                    <div style="float:left;background-color:#FFFFFF;width:410px;height:24px;padding:1px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;margin-bottom:20px;">
                        <div id="dvprogress" style="float:left;width:0;height:20px;background-color:#3B7CFF;overflow:hidden;">&nbsp;</div>
                    </div>
                    <div class="clear"></div>
                    <div style="display:-webkit-inline-box;" id="dvc">正在升级数据库，请不要关闭或刷新浏览器</div>
                </td>
            </tr>
        </tbody>
        </table>
</div>   
     
<script type="text/javascript">
{literal}
              var pagewidth=Math.max(document.body.clientWidth ,document.body.scrollWidth );
              var pageheight=Math.max(document.body.clientHeight ,document.body.scrollHeight );
             
              var updatewidth=document.getElementById('dvUpdate').offsetWidth;
              var updateheight=document.getElementById('dvUpdate').offsetHeight;
              
              document.getElementById('dvUpdate').style.left=(pagewidth-updatewidth)/2+"px";
              document.getElementById('dvUpdate').style.top=(pageheight-updateheight)/2+"px";
             
{/literal}
         </script>
{/if}
<script>

{literal}
     function fninvshnew(idname)
    {
     
                    	var newbox=document.getElementById(idname);
                         newbox.style.display="none";
    }
{/literal}
</script>