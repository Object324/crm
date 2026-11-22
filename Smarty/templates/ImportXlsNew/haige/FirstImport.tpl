<div id="importstep1" class="pop_up_content" style="display: block;width:100%;"> 
    <!-- 流程进度条 start --> 
    <div class="pop_up_content_inner">
    {include file="ImportXlsNew/haige/ImportStepTip.tpl"} 
    <!-- 流程进度条 end --> 
    <div class="pop_item pop-item-plus"> 
     <span>1. {$ARRLABEL.accordingimportdatalabel}</span> 
     <div class="download-tem"> 
      <span class="js-entity_type_select" style="display: none"><select style="width:100px"><option value="666969600180959">默认业务类型</option></select></span> 
      <span class="js-down_template"> <a href="javascript:void(0)" id="link_down">{$ARRLABEL.downloadtemplatedatalabel}</a> </span> 
     </div> 
     <div class="pop_item_content"> 
      <a href="javascript:;" class="more" onclick="showCautions()">{$ARRLABEL.viewcareitemlabel}&gt;&gt;</a> 
      <div class="pop_info bothclear hidden">
       <ul>
        <li>1) {$ARRLABEL.notencontent_firstlabel}</li> 
        <li>2) {$ARRLABEL.notencontent_secondlabel}</li> 
        <li>3) {$ARRLABEL.notencontent_thirdlabel}</li> 
       </ul> 
      </div> 
     </div> 
    </div> 
   
     
   
    <div class="pop_item"> 
     <span>2. {'USESYSIMPORTFILE'|@getFixedLabel}</span> 
     <div class="pop_item_content"> 
      <div class="fileinput-box"> 
       <span class="fileinput-button">{'ADDFILE'|@getFixedLabel}<input name="xls_file_upload" class="fileinput-input" type="file" title="选择文件" onchange="cls_XlsImportRelatedNew_HaiGe.getInstance('{$MODULE}').uploadxls()" /></span> 
       <span class="uploadqueue-item-filename" name='showfilename' title=""> </span>
       <div class="xlsimportprogress" >
            <div></div>
        </div> 
      </div> 
      <div> 
       <span>{'SUPPORTFILETYPE'|@getFixedLabel}{'wpsformatisnotsupported'|@getFixedLabel} {'HOWEVERINPORTWPS'|@getFixedLabel}</span>
      </div> 
     </div> 
    </div> 
    </div>
  </div> 
  