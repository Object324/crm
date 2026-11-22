function cls_XlsImportNew(module)
{
    this.module=module;
    this.stepindex=1;
    var that=this;
    this.blocks=new Array();
    this.fields=new Array();
    this.detailblocks=new Array();
    this.detailfields=new Array();
    this.popupobjs=new Array();
    that.ajaxobj='';
    that.helperhtml='';//帮助
    
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
        ldAjaxNoProgress('index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex,'',function(data)
        {
            if(data.code==1||data.code==2)
            {
                if(data.code==2) {
                    if(confirm(data.msg)==false) {
                        return false;
                    }
                }
                //wym 231225 BUG0077764 导入界面增加一个取消按钮
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"",arrJsPopLabel['CANCEL']);
                crmPopupobj.filename='';
                crmPopupobj.prevshow();
                //wym 231225 BUG0077764 导入界面增加一个取消按钮
                crmPopupobj.setParams(data.result.title,cls_XlsImportNew.getInstance(that.module).secondimport,"","LdPopWidth800px",this.module,"",data.result.oktext,"",arrJsPopLabel['CANCEL']);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                ld("#link_down").unbind("click").bind("click",function(){
                    cls_XlsImportNew.getInstance(that.module).downloadtemplate(ld(this));
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
                    listviewImport.importstart='no';
                    that.closePopup();
                }
                //wym 231225 BUG0077764 导入界面增加一个取消按钮
                document.getElementById(crmPopupobj.divid+'_btncancel').onclick=function()
                {
                    listviewImport.importstart='no';
                    that.closePopup();
                }
                that.detailmodule=data.result.detailmodule;
                that.popupobjs[that.stepindex]=crmPopupobj;

                // 帮助
                if(data.result.helperhtml && data.result.helperhtml!=""){
                    that.helperhtml=data.result.helperhtml;
                    ld('#'+crmPopupobj.divid + " #" + crmPopupobj.divid + '_head').find('.E_ptita').after(data.result.helperhtml);
                }
            }
            else
            {
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        });
       
    }
    //下载数据模板
    this.downloadtemplate=function(ldobj){
        var tmpurl = "index.php?file=ExportTemplateFile&action="+this.module+"Ajax&module="+this.module;
        tmpurl= cls_encryptyurl.Puyoung_Encryptyurl(tmpurl,'');
         ldobj.attr("href",tmpurl);
    }
    this.btn_addnewcondition=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var dupobj=ld("#"+divid+" [name=dv_dupcondition]");
        //zxm 20230815 BUG0064194 修改建议:单一的查询条件就不需要集合条件判断了/
        dupobj.find("[tag='dupcondition']").parent().show();
        var conditionhtml="<select class='btn-radius-system' tag='dupcondition'>";
            conditionhtml+='<option value="or">'+popupobj.orlabel+"</option>";
            conditionhtml+='<option value="and">'+popupobj.andlabel+"</option>";
            
            conditionhtml+="</select>";
            
        var selectfieldshtml='<select class="ld-select-inner gwidth30 mr50" tag="dupcolumns">';
        selectfieldshtml+="<option value=''>"+popupobj.nonelabel+"</option>";
        
        ld.each(popupobj.blocks,function(blockid,blockinfo){
            selectfieldshtml+="<optgroup label='"+blockinfo.blocklabel+"'>"+blockinfo.blocklabel;
            var thatblock=this;
            ld.each(popupobj.fields,function(fieldname,fieldinfo){
                if(fieldinfo.blockid==blockid) {
                    if (fieldinfo.uitype != 69 && fieldinfo.uitype != 1109) {
                        selectfieldshtml += '<option value="' + fieldinfo.fieldName + '">' + fieldinfo.fieldLableKey + '</option>';
                    }
                }
            });
            selectfieldshtml+="</optgroup>";
        });
         var html="<div>  <span>";
         html+=selectfieldshtml+"</select></span>";
         html+="<span style='display:none;'>&nbsp;"+conditionhtml+"</span>";
         html+="<span> <label onclick='cls_XlsImportNew.getInstance(\""+this.module+"\").deleteimportdupfieldtr(ld(this),\"dv_dupcondition\")' class='ld-fonticon ld-fonticon-del popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
         html+="</div>";
         dupobj.append(html);
    }
    //产品明细，联系人明细的查重条件
    this.btn_add_detailnewcondition=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var dupobj=ld("#"+divid+" [name=dv_detail_dupcondition]");
        //zxm 20230815 BUG0064194 修改建议:单一的查询条件就不需要集合条件判断了/
        dupobj.find("[tag='detail_dupcondition']").parent().show();
        var conditionhtml="<select class='btn-radius-system' tag='detail_dupcondition'>";
            conditionhtml+='<option value="or">'+popupobj.orlabel+"</option>";
            conditionhtml+='<option value="and">'+popupobj.andlabel+"</option>";
            conditionhtml+="</select>";
        var selectfieldshtml='<select class="ld-select-inner gwidth30 mr50" tag="detail_dupcolumns">';
        if(popupobj.detailmodule=='Contacts'){
            selectfieldshtml+="<option value=''>"+popupobj.noimport+"</option>";
        }
        else
            selectfieldshtml+="<option value=''>"+popupobj.nonelabel+"</option>";
        
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
        
         html+="<span style='display:none;'>&nbsp;"+conditionhtml+"</span>";
         html+="<span> <label onclick='cls_XlsImportNew.getInstance(\""+this.module+"\").deleteimportdupfieldtr(ld(this),\"dv_detail_dupcondition\")' class='ld-fonticon ld-fonticon-del popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
         html+="</div>";
         dupobj.append(html);
                
    }
    //wym 导入控制 检查下拉框
    this.btn_control_checkpicklist=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var checkpicklistobj=ld("#"+divid+" [name=checkPicklist]").get(0);
        var checkpicklist=ld(checkpicklistobj).prop('checked');
        var setpicklistobj=ld("#"+divid+" [name=setPicklistColumn]").get(0);
        if(ld(checkpicklistobj).prop('checked')==true){
            ld(setpicklistobj).show();
            var checkpicklist='yes';
        }else{
            ld(setpicklistobj).hide();
            var checkpicklist='no';
        }
        var label='ImportCheckPicklist';
        var isdetail=ld(checkpicklistobj).attr('tag');
        if(isdetail=='details'){
            label='ImportDetailCheckPicklist';
        }
        //wym 240506 导入/导入明细->开启“校验下拉框”参数后，设置校验字段已选字段中默认显示所下拉框字段
        var urlstring = "index.php?module=Users&action=UsersAjax&file=ImportCheckPicklist&mode=switch&curmodule="+this.module+"&label="+label+"&content="+checkpicklist;
        ldAjaxNoProgress(urlstring,'',function(data) {});
    }
    //wym 导入控制 检查下拉框 设置校验字段
    this.btn_control_setpicklistcolumn=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var checkpicklistobj=ld("#"+popupobj.divid+" [name=checkPicklist]").get(0);
        var label='ImportCheckPicklist';
        var isdetail=ld(checkpicklistobj).attr('tag');
        if(isdetail=='details'){
            label='ImportDetailCheckPicklist';
        }
        var urlstring = "index.php?module=Users&action=UsersAjax&file=ImportCheckPicklist&mode=show&curmodule="+this.module+"&label="+label;

        ldAjaxNoProgresssync(urlstring,'',function(data) {
            if(data.code==1){
                var crmPopupobj=CrmPopup.load(data.result.title,"","","LdPopWidth730px",this.module,"",data.result.oktext,"",data.result.canceltext);
                crmPopupobj.show(data.result.content);
                ld("#"+crmPopupobj.divid).addClass("popMarginPadding");
                var tableobj = ld('#'+crmPopupobj.divid).find(" table#setPicklistTable");
                var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                var RightObj = tableobj.find(" .commonMultipleSelect:last");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','280');
                crmPopupobj.center();
                ld('#' + crmPopupobj.divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    var saveurl = "index.php?module=Users&action=UsersAjax&file=ImportCheckPicklist&mode=save&curmodule="+that.module+"&label="+label;
                    var selObj=CrmPopup.findHtmlobj(crmPopupobj.divid,'selectedAssmablyColumns');
                    var selcolumn=[];
                    selObj.find("option").each(function(){
                        selcolumn.push(ld(this).val());
                    });
                    saveurl+='&selcolumn='+JSON.stringify(selcolumn);
                    ldAjaxNoProgresssync(saveurl,'',function(data) {});
                    crmPopupobj.CancelEvent();
                });
            }
        });
    }
    //wym 导入控制 触发工作流
    this.btn_control_checkworkflow=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var checkworkflowobj=ld("#"+divid+" [name=checkWorkflow]").get(0);
        if(ld(checkworkflowobj).prop('checked')==true){
            var checkworkflow='yes';
        }else{
            var checkworkflow='no';
        }
        var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=save&curmodule="+this.module+"&label=ImportCheckWorkflow&content="+checkworkflow;
        ldAjaxNoProgress(urlstring,'',function(data) {});
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
        var tmpurl = 'index.php?module='+that.module+"&action="+that.module+"Ajax&file=XlsFileUpload&frommodule="+that.module;
        var tmpparam = {};
        tmpparam['filename'] = name;
        tmpurl = cls_encryptyurl.Puyoung_EncryptyFileurl(tmpurl,tmpparam);
      that.ajaxobj= ld.ajax({
            url: tmpurl,
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
              
            }).fail(function(res) {});
    }
    //第二步骤
    this.secondimport=function(){
        listviewImport.importstart='no';
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
        that.ajaxobj= ldAjaxNoProgress('index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex+"&filename="+popupobj.filename,'',function(data)
        {
            that.popupobjs[that.stepindex]=crmPopupobj;
            if(data.code==1){
                console.log(data.result.title);
                crmPopupobj.setParams(data.result.title,cls_XlsImportNew.getInstance(that.module).prevstep,"","LdPopWidth800px",this.module,"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                crmPopupobj.excelcolumncount=data.result.excelcolumncount;

                //037256: 单据列表界面>更多>导入>选择模板后点击下一步：底部的【上一步、下一步】按钮应该是【下一步】为蓝色的，【上一步】为白色的。
                ld("#"+crmPopupobj.divid+"_btnok").attr("class",'E_pbtncancel ld-button');
                ld("#"+crmPopupobj.divid+"_btncancel").attr("class",'E_pbtnok ld-button ld-button-primary');

                document.getElementById(crmPopupobj.divid+'_imgclose').onclick=function(){
                   that.closePopup();
                }
                document.getElementById(crmPopupobj.divid+'_btncancel').onclick=function(){
                   cls_XlsImportNew.getInstance(that.module).threeimport();
                }

                // 帮助
                if(that.helperhtml && that.helperhtml!=""){
                    ld('#'+crmPopupobj.divid + " #" + crmPopupobj.divid + '_head').find('.E_ptita').after(that.helperhtml);
                }
            }
            else{
                that.prevstep();
                audioRemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                return false;
            }

            //@edit:ljj,2023-08-01,reason:BUG0070399 kfbcrm-客户-导入界面-字段标题过长时应设置换行或浮显
            tooltip('.tip-items-list', {transition: true, time: 200});
       });
    }
    
    this.secondimport.funname="cls_XlsImportNew.prototype.secondimport";
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
         var secondpopupobj=CrmPopup.getPopupObj("last");
         var divid=secondpopupobj.divid;
         var mapped_fields=new Array();
         var isfieldname=new Array();
         var isdefaultvalue=new Array();
         for(var i=0;i<secondpopupobj.excelcolumncount;i++ )
         {
             var selectcolumn=ld("#"+secondpopupobj.divid+" [name="+i+"]").val();
             mapped_fields.push(selectcolumn);//导入的字段
             //zkt 20230802 BUG0070417 Excel导入时编辑的默认值不生效，导入后的数据对应字段仍是空值。附件内容为excel导入时的操作和所用文件
             if(ld("#"+secondpopupobj.divid+" #"+selectcolumn+"-defaultvalue").length>0){
                 isdefaultvalue.push(ld("#"+secondpopupobj.divid+" #"+selectcolumn+"-defaultvalue").val());//导入字段默认值
             }
             else{
                 isdefaultvalue.push('');//导入字段默认值
             }
         }
         that.mapped_fields=mapped_fields;
         that.isdefaultvalue=isdefaultvalue;
         that.getImportDataRows();//获取导入数据
    }
    
    
     this.threeimport.funname="cls_XlsImportNew.prototype.threeimport";
      /*
      获取导入数据
      */
    that.getImportDataRows=function()
    {
        var secondpopupobj=CrmPopup.getPopupObj("last");
        ld("#"+secondpopupobj.divid).css("display",'none');//隐藏导入步骤二
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
        crmPopupobj.prevshow();
        var tmpurl="choose="+that.choose+"&importdupfields_condition="+JSON.stringify(that.importdupfields_condition)+"&importdupcheckfields="+JSON.stringify(that.importdupcheckfields);
        tmpurl+="&mapped_fields="+JSON.stringify(that.mapped_fields)+"&defaultvalue="+JSON.stringify(that.isdefaultvalue)+"&filename="+that.filename;
        if(that.detailmodule!='')
        {
        
            tmpurl+="&detail_importdupcheckfields="+JSON.stringify(that.detail_importdupcheckfields)+"&detail_importdupfields_condition="+JSON.stringify(that.detail_importdupfields_condition);
            
        }
        if(that.detailmodule=='Products')
        {
            tmpurl+="&product_import_type="+that.product_import_type;
        }
        var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&getimportrows=yes";
        that.ajaxobj=  ldAjaxNoProgress(surl,tmpurl,function(data)
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

                ldAjaxNoProgress(surl,'finishimportlog=yes&errormsg='+JSON.stringify(data.msg),function(response){// 导入日志更新为导入失败

                });
                return false;
            }
        });
    }
     /*
     显示导入进度的界面
     */
     this.showthreeimport=function(tmpdata){
         var crmPopupobj=CrmPopup.getPopupObj('last');
         
        that.stepindex=3;
        var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex;
        that.ajaxobj=ldAjaxNoProgress(surl,'',function(data)
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
                ldAjaxNoProgress(surl,'finishimportlog=yes&errormsg='+JSON.stringify(data.msg),function(response){// 导入日志更新为导入失败

                });
            }
        });
     }
    //导入数据
    this.importdata=function(startrow,endrow){
        var popupobj=CrmPopup.getPopupObj('last');
        
        var tmpurl="choose="+that.choose+"&importdupfields_condition="+JSON.stringify(that.importdupfields_condition)+"&importdupcheckfields="+JSON.stringify(that.importdupcheckfields);
        tmpurl+="&mapped_fields="+JSON.stringify(that.mapped_fields)+"&defaultvalue="+JSON.stringify(that.isdefaultvalue)+"&filename="+that.filename;
        tmpurl+="&startrow="+startrow+"&endrow="+endrow;
        if(that.detailmodule!='')
        {
            tmpurl+="&detail_importdupcheckfields="+JSON.stringify(that.detail_importdupcheckfields)+"&detail_importdupfields_condition="+JSON.stringify(that.detail_importdupfields_condition);
            
        }
        if(that.detailmodule=='Products')
        {
            tmpurl+="&product_import_type="+that.product_import_type;
        }
        var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex;
        that.ajaxobj=  ldAjaxNoProgress(surl,tmpurl,function(data)
        {
            if(data.code=='-1')
            {
                ldAjaxNoProgress(surl,'finishimportlog=yes&errormsg='+JSON.stringify(data.msg),function(response){// 导入日志更新为导入失败

                });

                alert(data.msg);
                //wym 240207 BUG0076978 客户-导入（导入文件不是按照数据模板录入的）-上传后点击导入，会弹出缺少字段的提示信息，点击确定后，弹出层就一直卡着不动，应自动关闭
                that.closePopup();
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

        });
    }
     
     
     
     this.importfinished=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        
         var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",that.module,"",'none',"","");
          that.stepindex=4;
       var tmpurl='index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&stepindex="+that.stepindex;
       
       if(that.detailmodule=='Products')
       {
            tmpurl+="&product_import_type="+that.product_import_type;
       }
       
         that.ajaxobj=ldAjaxNoProgress(tmpurl,'',function(data)
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
                 }

             }
         });
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
                break;
            }
            popupobj.CancelEvent();
           
        }
        that.popupobjs=new Array();
        cls_XlsImportNew.thisobj="";
        if(that.ajaxobj!='')
        {
            that.ajaxobj.abort();
        }
        if(that.stepindex==3)//导入进度条界面
        {
            //需要清空session
            ldAjaxNoProgress('index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportxlsStep&frommodule='+that.module+"&clearimportsession=yes",'',function(ajaxdata){
                if(data.code == 1){

                }
            });
        }
        else if(that.stepindex==4)//导入完成，刷新列表界面
        {
                    var popupobj=CrmPopup.getPopupObj('last');
                    if(popupobj.url==undefined||popupobj.url=='')
                    {
                        return false;
                    }
                    ldAjaxHtmlNoProgress("index.php?"+popupobj.url,'',function(data)
                    {
                        $("status").style.display="none";


                        var str=data;
                        if(data.indexOf("&#&#&#&#&#&#")>=0)
                        {
                            str=data.split("&#&#&#&#&#&#");
                            str=str[1];
                        }
                        //zkt 20240125 BUG20240125-11 项目立项，导入数据后，列表界面操作按钮不显示了
                        ld("#ListViewContents").html(str);
                        popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
                        if(popupobj.module == 'Accounts'){
                            IsFrameElement();
                        }
                        /*
                        * edit: chj
                        * date: 2020/7/23
                        * reason: 42068: （https://61mis.com/kfbtest/ [^]）费用报销单->导入：导入数据成功后，单据列表界面最下方显示空白
                        */
                        setContentHeight(popupobj.module);//计算内容高度
                        cls_XlsImportNew

                    })
        }
        
    }
}
cls_XlsImportNew.thisobj="";
cls_XlsImportNew.getInstance=function(module){
    if(cls_XlsImportNew.thisobj=='')
    {
       
        cls_XlsImportNew.thisobj= new cls_XlsImportNew(module);
    }
    return cls_XlsImportNew.thisobj;
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
 