<div id="importstep4" class="pop_up_content" autofocus="autofocus" style="width:100%;overflow:auto;">
		<div class="pop_up_content_inner">

    		{include file="ImportXlsNew/ImportStepTip.tpl"} 
    		<!-- 流程进度条 end -->	    
    		<!-- 导入进度条 start -->
    		<div class="import_process import_process2">
        		<div class="process_bar">				  
        		      <div class="process_now" style="width:100%;">
                        <span class="percent">100%</span>
                      </div>	    
        		</div>
        		  <div class="import_info">
                        <p style="font-weight:bold;">
        				{if $TOTALROWS neq '' || $SUCCESSROWS > -1 || $ERRORROWS > -1}
                            {'IMPORTRECORDTIPPRODUCT'|@getFixedLabel|@sprintf:$TOTALROWS:$ADDIMPORTROWS:$ERRORROWS}
                        {/if}
                        <!--{if ($ERRORROWS>0 || $FALSE == true)&&1==2}
                                失败的原因如下：
                        {/if}-->
                        </p>
                        <div  class="tdExportResult" style="display:none;background-color:#f8f8f8; padding: 5px; max-height: 200px; width:100%; overflow: auto;">
                            {if $ERRORROWS>0 || $FALSE == true || $DETAILERROR>0}{$IMPORTINFO}{/if}
                        </div>
        		 </div>	    
		   </div>
           {*zkt 20230613 BUG0068108 销售订单新建界面，导入单据明细，添加附件，成功导入时不应该显示“下载错误报告” *}
           {if $ERRORROWS>0 || $FALSE == true || $DETAILERROR>0}
	       	<!-- 导入进度条 end -->
    		<div class="pop_item">
    		      <p class="pop_tip">下载错误报告，查看失败原因</p>	    
    		      <div class="show_attachment_upload">
    		          <div class="show_attachment_border">
    		                  <div class="show_attachment_content">				 
    		                      <!-- 上传进度 -->
    		                      <div style="display: block;" class="uploadifyQueue">
    		                          <div class="uploadifyQueueItem bothclear">	 
    		                               <span class="fileClass file_class_excel"></span>
    	                                   	<span class="fileName">{$FILENAME}</span>
                                            <span class="fileDownload"> <a href="index.php?module={$MODULE}&action={$MODULE}Ajax&file=ImportLog" target="_blank">下载</a> </span>		 
                                        </div>
    		                      </div>
    		                      <!-- 上传进度 end -->		 
    		                  </div>
    	   	           </div>
    		      </div>
    		</div>
            {/if}
    </div>
</div>