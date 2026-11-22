function cls_XlsImportRelatedNew_HaiGe(module,relatedmodule,record)
{
    this.module=module;	//当前模块
	this.record = record;	//单据ID
	this.relatedmodule = relatedmodule;	//相关信息模块
    this.stepindex=1;
    var that=this;
    this.blocks=new Array();
    this.fields=new Array();
    this.detailblocks=new Array();
    this.detailfields=new Array();
    this.popupobjs=new Array();
    that.ajaxobj='';
    
    /*
    *上一步
    */
    this.previndex=function(){
        this.stepindex--;
    }
  
    /*
    添加条件
    */
    this.addcondition=function()
    {
        
    }
    this.firstimport=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        
        that.listurl=popupobj.url;//列表查询的url
        
        ld.ajax({
            url: 'index.php?module='+that.relatedmodule+'&action='+that.relatedmodule+'Ajax&file=ImportxlsStep_haige&frommodule='+that.relatedmodule+"&stepindex="+that.stepindex+"&relatedlist=yes",
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 0,
            success: function(data)
            {
                if(data.code==1||data.code==2)
                {
                   if(data.code==2)
                   {
                     if(confirm(data.msg)==false)
                     {
                        return false;
                     }
                   }
                    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
                    crmPopupobj.filename='';
                    crmPopupobj.prevshow();
                    crmPopupobj.setParams(data.result.title,cls_XlsImportRelatedNew_HaiGe.getInstance(that.relatedmodule).threeimport,"","LdPopWidth800px",this.relatedmodule,"",data.result.oktext,"","");
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                   ld("#link_down").unbind("click").bind("click",function(){
                            cls_XlsImportRelatedNew_HaiGe.getInstance(that.module).downloadtemplate(ld(this));
                   });
                   crmPopupobj.nonelabel=data.result.nonelabel;
                   crmPopupobj.andlabel=data.result.andlabel;
                   crmPopupobj.deletelabel=data.result.deletelabel;
                   crmPopupobj.orlabel=data.result.orlabel;
                   crmPopupobj.blocks=data.result.blocks;
                   crmPopupobj.fields=data.result.fields;
                   crmPopupobj.detailblocks=data.result.detailblocks;
                   crmPopupobj.detailfields=data.result.detailfields;
                   crmPopupobj.detailmodule=data.result.detailmodule;
                   crmPopupobj.noimport=data.result.noimport;
                   document.getElementById(crmPopupobj.divid+'_imgclose').onclick=function()
                   {
                    
                       that.closePopup();
                   }
                   that.detailmodule=data.result.detailmodule;
                   that.popupobjs[that.stepindex]=crmPopupobj;
                   
                }
                else
                {
                    RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                }
            }
        })
       
    }
    //下载数据模板
    this.downloadtemplate=function(ldobj){
         ldobj.attr("href","index.php?file=ImportxlsStep_haige&fileupload=ExportTemplateFile&action="+this.relatedmodule+"Ajax&module="+this.relatedmodule+"&frommodule="+this.module+"&relatedlist=yes");  
    }
    this.btn_addnewcondition=function(){
        
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var dupobj=ld("#"+divid+" [name=dv_dupcondition]");
        var conditionhtml="<select class='btn-radius-system' tag='dupcondition'>";
            conditionhtml+='<option value="or">'+popupobj.orlabel+"</option>";
            conditionhtml+='<option value="and">'+popupobj.andlabel+"</option>";
            
            conditionhtml+="</select>";
            
        var selectfieldshtml='<select class="ld-select-inner gwidth30 mr50" tag="dupcolumns">';
        selectfieldshtml+="<option value=''>"+popupobj.nonelabel+"</option>";
       // console.log(popupobj.fields);
        
        ld.each(popupobj.blocks,function(blockid,blockinfo){
            selectfieldshtml+="<optgroup label='"+blockinfo.blocklabel+"'>"+blockinfo.blocklabel;
            var thatblock=this;
            ld.each(popupobj.fields,function(fieldname,fieldinfo){
                
                if(fieldinfo.blockid==blockid)
                    if(fieldinfo.uitype!= 69 && fieldinfo.uitype != 1109)
                        selectfieldshtml+='<option value="'+fieldinfo.fieldname+'">'+fieldinfo.fieldLableKey+'</option>';
                        
                
            });
            selectfieldshtml+="</optgroup>";
            
        });
         var html="<div>  <span>";
         html+=selectfieldshtml+"</select></span>";
        
         html+="<span>&nbsp;"+conditionhtml+"</span>";
         html+="<span> <label onclick='cls_XlsImportRelatedNew_HaiGe.getInstance(\""+this.module+"\").deleteimportdupfieldtr(ld(this),\"dv_dupcondition\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
         html+="</div>";
         dupobj.append(html);
                
    }
    //产品明细，联系人明细的查重条件
    this.btn_add_detailnewcondition=function(){
        
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var dupobj=ld("#"+divid+" [name=dv_detail_dupcondition]");
        var conditionhtml="<select class='btn-radius-system' tag='detail_dupcondition'>";
            conditionhtml+='<option value="or">'+popupobj.orlabel+"</option>";
            conditionhtml+='<option value="and">'+popupobj.andlabel+"</option>";
            
            conditionhtml+="</select>";
            
        var selectfieldshtml='<select class="ld-select-inner gwidth30 mr50" tag="detail_dupcolumns">';
       if(popupobj.detailmodule=='Contacts')
       {
        selectfieldshtml+="<option value=''>"+popupobj.noimport+"</option>";
       }
       else
        selectfieldshtml+="<option value=''>"+popupobj.nonelabel+"</option>";
       // console.log(popupobj.fields);
        
       // ld.each(popupobj.detailblocks,function(blockid,blockinfo){
           // selectfieldshtml+="<optgroup label='"+blockinfo.blocklabel+"'>"+blockinfo.blocklabel;
            var thatblock=this;
            ld.each(popupobj.detailfields,function(fieldname,fieldinfo){
                
                //if(fieldinfo.blockid==blockid)
                
                    if(fieldinfo.uitype!= 69 && fieldinfo.uitype != 1109&&fieldinfo.uitype!=202)
                        selectfieldshtml+='<option value="'+fieldname+'">'+fieldinfo.fieldLableKey+'</option>';
                
            });
          //  selectfieldshtml+="</optgroup>";
            
       // });
         var html="<div>  <span>";
         html+=selectfieldshtml+"</select></span>";
        
         html+="<span>&nbsp;"+conditionhtml+"</span>";
         html+="<span> <label onclick='cls_XlsImportRelatedNew_HaiGe.getInstance(\""+this.module+"\").deleteimportdupfieldtr(ld(this),\"dv_detail_dupcondition\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
         html+="</div>";
         dupobj.append(html);
                
    }
    this.deleteimportdupfieldtr=function(ldobj,parentname)
    {
         var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var dupobj=ld("#"+divid+" [name="+parentname+"]");
        ldobj.parent().parent().remove();
       // dupobj.remove(ldobj.parent().parent());
    }
    /*上传导入文件**/
    this.uploadxls=function()
    { 
         var popupobj=CrmPopup.getPopupObj('last');
         var that=this;
         var formData = new FormData();
        formData.append('ImportXlsFile', ld('#'+popupobj.divid+" [name=xls_file_upload]").get(0).files[0]);
        formData.append('name', ld('#'+popupobj.divid+" [name=xls_file_upload]").val());
        //console.log(ld('#'+popupobj.divid+" [name=xls_file_upload]").get(0).files[0]);
        var size=ld('#'+popupobj.divid+" [name=xls_file_upload]").get(0).files[0].size;
        var name=ld('#'+popupobj.divid+" [name=xls_file_upload]").get(0).files[0].name;
        var sizedescription='';
        if(size>=1024*1024)
        {
            sizedescription=parseFloat(size/1024/1024).toFixed(2)+'MB';
        }
        else if(size>=1024)
        {
            sizedescription=parseFloat(size/1024).toFixed(2)+'KB';
        }
        else
        {
            sizedescription=size.toFixed(2)+'b';
        }
        if(name.toLocaleLowerCase().indexOf(".xls")<=0&&name.toLocaleLowerCase().indexOf(".xlsx")<=0)
        { 
            audioRemindsMsg('','',this.module,'','','只能导入excel文件');
            return false;
        }
        ld("#"+popupobj.divid+" [name=showfilename]").html(name+"-"+sizedescription);
      that.ajaxobj= ld.ajax({
            url: 'index.php?module='+that.relatedmodule+"&action="+that.relatedmodule+"Ajax&file=ImportxlsStep_haige&fileupload=XlsFileUpload&frommodule="+that.relatedmodule+"&cur_module="+that.module+"&relatedlist=yes",
            type: 'POST',
            cache: false,
            data: formData,
            processData: false,
            contentType: false,
            dataType:'json',
            xhr:function(){
                var xhr=new XMLHttpRequest();
                xhr.upload.addEventListener('progress',function(e){
                    var progressRate=(e.loaded/e.total)*100+"%";
                    ld("#"+popupobj.divid+' .xlsimportprogress').css('display','block');
                    ld("#"+popupobj.divid+' .xlsimportprogress > div').css('width', progressRate);
                })
                return xhr;
            }
        }).done(function(res) {
            ld("#"+popupobj.divid+' .xlsimportprogress').css('display', 'none');
            ld("#"+popupobj.divid+' .xlsimportprogress > div').css('width', 0);
             popupobj.filename=res.result.filename;
			 that.filename = res.result.filename;
              
            }).fail(function(res) {});
    }
    //第二步骤
    this.secondimport=function(){
        
        var popupobj=CrmPopup.getPopupObj('last');
        
        if(popupobj.filename=='')
        {
            audioRemindsMsg('','',this.module,'','',arrJsPopLabel['IMPORTFILECANOTEMPTY']);
            return false;
        }
      
        var filename=popupobj.filename;
        var choose=ld("#"+popupobj.divid+" [name=choose]").val();//导入方式：覆盖，跳过，追加
        var importdupcheckfields=new Array();//查重字段
        var importdupfields_condition=new Array();//查重字段的条件
        var detail_importdupcheckfields=new Array();//明细查重字段
        var detail_importdupfields_condition=new Array();
        ld.each(ld("#"+popupobj.divid+" [tag=dupcolumns]"),function(index,obj){
           
                if(ld(obj).val()=='')
                {
                    return true;
                }
                importdupcheckfields.push(ld(obj).val());
                var dupconditionobjs= ld("#"+popupobj.divid+" [tag=dupcondition]");
                 importdupfields_condition.push(ld(dupconditionobjs[index]).val());
           });
           //明细查重字段
           ld.each(ld("#"+popupobj.divid+" [tag=detail_dupcolumns]"),function(index,obj){
           
                if(ld(obj).val()=='')
                {
                    return true;
                }
                detail_importdupcheckfields.push(ld(obj).val());
               
                var dupconditionobjs= ld("#"+popupobj.divid+" [tag=detail_dupcondition]");
                 detail_importdupfields_condition.push(ld(dupconditionobjs[index]).val());
           });
          
           if(that.detailmodule=='Products')
           {
            //设置产品管理不存在时导入方式
             that.product_import_type=ld("#"+popupobj.divid+" [name=product_import_type]").val();
           }
           that.filename=filename;
           that.choose=choose;
           
           that.importdupcheckfields=importdupcheckfields;
           that.importdupfields_condition=importdupfields_condition;
           that.detail_importdupcheckfields=detail_importdupcheckfields;
           that.detail_importdupfields_condition=detail_importdupfields_condition;
           
        ld("#"+popupobj.divid).css("display",'none');
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
        crmPopupobj.prevshow();
        that.stepindex=2;
       that.ajaxobj= ld.ajax({
            url: 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex+"&filename="+popupobj.filename,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 0,
            success: function(data)
            {
                that.popupobjs[that.stepindex]=crmPopupobj;
               
                if(data.code==1)
                {
                    
                    crmPopupobj.setParams(data.result.title,cls_XlsImportRelatedNew_HaiGe.getInstance(that.module).prevstep,"","LdPopWidth800px",this.module,"",data.result.oktext,"",data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                    crmPopupobj.excelcolumncount=data.result.excelcolumncount;
                   
                    //037256: 单据列表界面>更多>导入>选择模板后点击下一步：底部的【上一步、下一步】按钮应该是【下一步】为蓝色的，【上一步】为白色的。
                    ld("#"+crmPopupobj.divid+"_btnok").attr("class",'E_pbtncancel ld-button');
                    ld("#"+crmPopupobj.divid+"_btncancel").attr("class",'E_pbtnok ld-button ld-button-primary');
                    
                    
                    document.getElementById(crmPopupobj.divid+'_imgclose').onclick=function()
                    {
                        
                           that.closePopup();
                    }
                     document.getElementById(crmPopupobj.divid+'_btncancel').onclick=function()
                     {
                         
                        
                         cls_XlsImportRelatedNew_HaiGe.getInstance(that.module).threeimport();
                            
                     }
                    
                }
                else
                {
                   
                    audioRemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                    that.prevstep();
                     return false;
                }
            },
            error:function(one,two,status){
                alert(status);
            }
        })
    }
    
    this.secondimport.funname="cls_XlsImportRelatedNew_HaiGe.prototype.secondimport";
    //导入方式选择覆盖，则提示
    this.chooseAlert=function(tipcontent){
        var popupobj=CrmPopup.getPopupObj("last");
        if(ld("#"+popupobj.divid+" [name=choose]").val()=='Update' || ld("#" + popupobj.divid + " [name=choose]").val() == 'UpdateAll')
        {
             RemindsMsg("","LdPopWidth400px","","yes","",tipcontent);
            return false;
        }
        
    }
    
    //第三步骤
    this.threeimport=function()
    {
		 var popupobj=CrmPopup.getPopupObj('last');
        
        if(popupobj.filename=='')
        {
            audioRemindsMsg('','',this.module,'','',arrJsPopLabel['IMPORTFILECANOTEMPTY']);
            return false;
        }
        that.getImportDataRows();//获取导入数据

    }
    
    
     this.threeimport.funname="cls_XlsImportRelatedNew_HaiGe.prototype.threeimport";
      /*
      获取导入数据
      */
     that.getImportDataRows=function()
     {
		  var popupobj=CrmPopup.getPopupObj('last');
        var secondpopupobj=CrmPopup.getPopupObj("last");
        ld("#"+secondpopupobj.divid).css("display",'none');//隐藏导入步骤二
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
        crmPopupobj.prevshow();
        var tmpurl="";
         that.ajaxobj=  ld.ajax({
            
                url: 'index.php?module='+that.relatedmodule+'&action='+that.relatedmodule+'Ajax&file=ImportxlsStep_haige&frommodule='+that.relatedmodule+"&getimportrows=yes&filename="+popupobj.filename,
                type: 'POST',
                data:tmpurl,
                dataType:'json',
                async: true,//
                timeout: 0,
                success: function(data)
                {
                                  
                    if(data.code==1)
                    {
                         
                        
                        that.showthreeimport(data);//显示导入进度条
                         
                    }
                    else
                    {
                         crmPopupobj.CancelEvent();
                         ld("#"+secondpopupobj.divid).css("display",'block');
                         RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                         return false;
                    }
                },
                 
                
            })
     }
     /*
     显示导入进度的界面
     */
     this.showthreeimport=function(tmpdata){
         var crmPopupobj=CrmPopup.getPopupObj('last');
         
        that.stepindex=3;
        that.ajaxobj=ld.ajax({
            url: 'index.php?module='+that.relatedmodule+'&action='+that.relatedmodule+'Ajax&file=ImportxlsStep_haige&frommodule='+that.relatedmodule+"&stepindex="+that.stepindex,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code==1)
                {
                 
                    that.startrow=0;
                    crmPopupobj.setParams(data.result.title,"","","LdPopWidth600px",that.module,"","","",data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                    document.getElementById(crmPopupobj.divid+'_imgclose').onclick=function()
                    {
                        that.closePopup();
                    }
                    that.popupobjs[that.stepindex]=crmPopupobj;
                    
                     that.maxrows=parseInt(tmpdata.result.maxrows,10);
                    ld("#"+crmPopupobj.divid+" .import_info").html(tmpdata.result.timedescription);
                        
                    ld('#'+crmPopupobj.divid+" .process_now").css("width",tmpdata.result.cur_progress_step+"%");
                    ld("#"+crmPopupobj.divid+" .percent").html(tmpdata.result.cur_progress_step+"%");
                    that.importdata(that.startrow,that.startrow+4);//开始导入
                }
                else
                {
                    
                }
            }
        })
     }
     //导入数据
     this.importdata=function(startrow,endrow){
            var popupobj=CrmPopup.getPopupObj('last');
           var tmpurl='';
         that.ajaxobj=  ld.ajax({
            
                url: 'index.php?module='+that.relatedmodule+'&action='+that.relatedmodule+'Ajax&file=ImportxlsStep_haige&frommodule='+that.relatedmodule+"&stepindex="+that.stepindex+"&filename="+that.filename+"&startrow="+startrow+"&endrow="+endrow+'&record='+that.record,
                type: 'POST',
                data:tmpurl,
                dataType:'json',
                async: true,//
                timeout: 0,
                success: function(data)
                {
					if(data.code=='-1')
					{
						alert(data.msg);
						return false;
					}
                   that.startrow=parseInt(data.result.endrow,10)+1;
                     ld("#"+popupobj.divid+" .import_info").html(data.result.timedescription);
                    
                     ld('#'+popupobj.divid+" .process_now").css("width",data.result.cur_progress_step+"%");
                     ld("#"+popupobj.divid+" .percent").html(data.result.cur_progress_step+"%");
                    
                     if(parseInt(that.maxrows,10)<=parseInt(that.startrow)){
                       
                        that.importfinished();//导入完成
                        return false;
                    }
                     for(var i=0;i<=2000;i++)
                     {
                        //暂停
                     }
                      that.importdata(that.startrow,that.startrow+4);
                    
                },
            })
     }
     
     
     
     this.importfinished=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        
         var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
          that.stepindex=4;
       var tmpurl='index.php?module='+that.relatedmodule+'&action='+that.relatedmodule+'Ajax&file=ImportxlsStep_haige&frommodule='+that.relatedmodule+"&stepindex="+that.stepindex;
       
         that.ajaxobj=ld.ajax({
            url: tmpurl,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code==1)
                {
                     ld("#"+popupobj.divid).css('display','none');
                    crmPopupobj.setParams(data.result.title,that.closePopup,"","LdPopWidth800px",that.module,"",data.result.oktext,"","");
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                    that.popupobjs[that.stepindex]=crmPopupobj;
                    document.getElementById(crmPopupobj.divid+'_imgclose').onclick=function()
                    {
						that.closePopup();
						if($('refresh-Products')){
							$('refresh-Products').click();
						}
                    }
					document.getElementById(crmPopupobj.divid+'_btnok').onclick=function()
                    {
						that.closePopup();
						if($('refresh-Products')){
							$('refresh-Products').click();
						}
                    }
                    
                }
            }
        })
    }
    this.prevstep=function()
    {
       
        //上一步
        var tmppopupobj=CrmPopup.getPopupObj('last');
        that.popupobjs.pop();
        tmppopupobj.CancelEvent();
        
        that.stepindex--;
        var popupobj=CrmPopup.getPopupObj('last');
        ld("#"+popupobj.divid).css("display",'block');
    }
    /*
    弹出层关闭
    */
    this.closePopup=function()
    {
        
        for(var i=1;i<=that.stepindex;i++)
        {
            var popupobj=that.popupobjs.pop();
            if(popupobj==undefined)
            {
               
            }else{
				 popupobj.CancelEvent();
			}
        }
		that.stepindex = 1;
    }
}
cls_XlsImportRelatedNew_HaiGe.thisobj="";
cls_XlsImportRelatedNew_HaiGe.getInstance=function(module,relatedmodule,record){
    if(cls_XlsImportRelatedNew_HaiGe.thisobj=='')
    {
       
        cls_XlsImportRelatedNew_HaiGe.thisobj= new cls_XlsImportRelatedNew_HaiGe(module,relatedmodule,record);
    }
    return cls_XlsImportRelatedNew_HaiGe.thisobj;
}




function defaultImportXls(obj,rowindex)
 {
   
   /*
    var tab=document.getElementById('Importtable');
    rowindex=parseInt(rowindex)+1;
    var cellobj=tab.rows[rowindex].cells[3];
    var oldspanobj=cellobj.firstChild;
    var parentnode=cellobj;
    var optvalue=obj.options[obj.selectedIndex].value;
   
    var newspanobj=document.getElementById(optvalue+'-defaultvalue-container');
    var defaultValuesElementsContainer=document.getElementById('defaultValuesElementsContainer');
    var childhtml= parentnode.innerHTML;
  
    if(newspanobj != undefined && newspanobj != null){
         if(newspanobj.parentNode.id==undefined||newspanobj.parentNode.id=='')
         {
              parentnode.innerHTML='';
              defaultValuesElementsContainer.innerHTML+=childhtml;
            
             return ;
         }
           
         parentnode.innerHTML='';
         defaultValuesElementsContainer.removeChild(newspanobj); 
    }else{
       
        var newNode = document.createElement('span');
        var newNodeId = optvalue+'-defaultvalue-container';
        //var newNodeId = document.getElementById(optvalue+'-defaultvalue-container');
        newNode.setAttribute('id',newNodeId);
        newNode.setAttribute('name',optvalue+'-defaultvalue-container');
        newNode.innerHTML = "<input id="+optvalue+"-defaultvalue name="+optvalue+"-defaultvalue type=\"text\" class=\"btn-radius-system\">";
        //newNode.innerHTML = "";
        parentnode.appendChild(newNode);
        newspanobj=document.getElementById(newNodeId);
        parentnode.innerHTML='';
    } 
    
    parentnode.appendChild(newspanobj);  
    defaultValuesElementsContainer.innerHTML+=childhtml;;*/
    
    
   
 }
 