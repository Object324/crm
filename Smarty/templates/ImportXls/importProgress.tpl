

<div id="dvImport"  style="display: block;position: absolute;width:100%;width:{$PAGEWIDTH};  visibility: visible;">
       
        <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
                
            <tr>
                <td>
                     <div style="font-size: 16px;font-weight: 600;color: #868686;text-align: center;" id="dvc" >正在导入数据，请不要关闭或刷新浏览器</div>
                     <div style="margin-top:10px;text-align:center" id="dvctimedescription" ></div>
                    <div id="dv"></div>
                    <div class="progress">
                        <div id="dvImportprogress" class="bar">&nbsp;</div>
                    </div>
                    <div class="clear"></div>
                   
                </td>
            </tr>
        
        </table>
</div>
        <script type="text/javascript">
        {literal}
                      var pagewidth=Math.max(document.body.clientWidth ,document.body.scrollWidth );
                      var pageheight=Math.max(document.body.clientHeight ,document.body.scrollHeight );
                     
                      var updatewidth=document.getElementById('dvImport').offsetWidth;
                      var updateheight=document.getElementById('dvImport').offsetHeight;
                      
                      document.getElementById('dvImport').style.left=(pagewidth-updatewidth)/2+"px";
                      document.getElementById('dvImport').style.top=(pageheight-updateheight)/2+"px";
                      function fninvshnew(idname)
                      {
                        	var newbox=document.getElementById(idname);
                             newbox.style.display="none";
                      }
                  {/literal}
        </script>