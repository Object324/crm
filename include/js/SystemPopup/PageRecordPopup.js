//编辑，创建，查看弹出层
//因为目前没有做编辑，创建，查看弹出层，那么这个对象就是编辑，创建，查看页面
function PageRecordPopup() {
    var that = this;
    this.isshowpage = false;
    this.picklistobjarray = [];//下拉框对象(cls_picklist
    var parentshow = this.show;
    this.timeCount = 0;
    this.oCKeditors = [];
    this.picklistcontent = [];//下拉框
    this.fieldrulefieldnames = [];//布局规则的查询字段
    this.sensitiverelatedfield = [];//敏感规则的相关字段
    this.picklistobjarray = [];//下拉框对象(cls_picklist
    that.detailfieldrulefieldnames=[];//明细字段的布局规则
    that.js_detailtablename='proTab';//分录所在的表格名称
    that.detailpicklist=[];//明细字段的下拉框内容
    that.detailpicklistseq=[];//明细字段的下拉框排序
    that.detailpicklistColors=[];//主表和明细字段的下拉框内容
    this.detailtableobj;//单据分录
    this.newrowhtml='';//单据分录的新增行的html
    this.issavesubmit='no';
    that.open_relateproducteffect_column_arr=[];
    this.approve_arr=[];//
    that.sys_deploy = [];
    this.isShowFullscreen='yes';
    this.fullscreenlabel='EditFullscreen';//全屏缩小用于保存后台的label值
    this.fullscreen='yes';//全屏缩小用户值，默认全屏
    this.setObjEventArr = [];

    /** @return {jQuery} */
    this.getPopupJqObj = function () {
        var popupJqObj = this.jQueryObj;
        if(!popupJqObj) {
            popupJqObj = ld('#'+this.divid);
            if(popupJqObj.length > 0) {
                this.jQueryObj = popupJqObj;
            }
        }
        return popupJqObj;
    }
    /** @return {jQuery} */
    this.getDetailTableJqObj = function () {
        return this.detailTableJqObj || (this.detailTableJqObj = this.getPopupJqObj().find(`[name="${this.js_detailtablename}"]`));
    }
    /** @return {jQuery} */
    this.getDetailRowJqObj = function (rowIndex) {
        return this.getDetailTableJqObj().find(`tr[rowindex="${rowIndex}"]`);
    }
    /** @return {jQuery} */
    this.getDetailFieldTdJqObj = function (rowIndex, fieldName) {
        return this.getDetailRowJqObj(rowIndex).find(`td[detailfieldname="${fieldName}"]`);
    }

    // that.detailresetComboxHtmlobjs=[];//明细字段的下拉框对象
    this.getDetailTableObj=function(){
        //edit:can 2020-09-17 获取单据分录table对象
        if(this.detailtableobj!=undefined&&ld(this.detailtableobj).length>0)
        {

        }
        else
        this.detailtableobj= ld("#"+this.divid+" [name="+this.js_detailtablename+"]");

        //工单管理模块每次都需要重新获取分录对象
        if(this.module=='WorkSheet'){
            this.detailtableobj= ld("#"+this.divid+" [name="+this.js_detailtablename+"]");
        }

        
        return this.detailtableobj;
    }
    this.ResetgetDetailTableObj=function(){
        //edit:can 2020-09-17 获取单据分录table对象
        
        this.detailtableobj= ld("#"+this.divid+" [name="+this.js_detailtablename+"]");
        return this.detailtableobj;
    }
    //edit:can 2020-09-17 获取单据分录的行
    //DelType:获取行的类型
    this.getTrObjsByDelType=function(DelType)
    {
        var tableobj=this.getDetailTableObj();
        if(DelType=='no')
        {
            return ld(tableobj).find("tr[detaildeleted=no]");
        }
        else if(DelType=='yes')
        {
            return ld(tableobj).find("tr[detaildeleted=yes]");
        }

    }
    this.getTrObjByChild=function(jqueryobj)
    {       var tagname='';
             if(ld(jqueryobj).length>0)
             {
                while(ld(jqueryobj).prop("tagName")!=undefined&&ld(jqueryobj).prop("tagName")!="TR"&&ld(jqueryobj).prop("tagName")!="BODY")
                {
                    jqueryobj=ld(jqueryobj).parent();
                }
             }
             return jqueryobj;
    }
    this.createTextBeforeSave = function () {
        this.issavesubmit = 'no';
        var displaybtn = 'no';
        if (this.approve_arr != undefined && this.approve_arr.length > 0){
            displaybtn = 'yes';
        }
        var btn_html = '<input name="button" id="' + this.divid + '_btnsavesubmit" class="E_pbtnok ld-button ld-button-primary" value="' + this.savesubmittext + '" tagClick="savesubmit"  type="button" '+(displaybtn=='no'?'style="display:none;"':'')+' >';
        return  btn_html;
    }
     this.SaveSubmit=function(){
        //保存提交
         var approveid = ld("#" + that.divid + " [name=approvevalue]").val();
         if(approveid == 0 || approveid == -1){
             RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['APPROVALNOTEMPTY']);
             return '';
         }
        var submitapprove_text = ld("#"+this.divid+" [id=submit_description]").val();//提交意见是否为空
        var submitlabelobj = ld("#"+this.divid+" [name=submitremarkrequire]");//提交意见是否必填
        if(ld.trim(submitapprove_text)==""&&ld(submitlabelobj).css("display")=="inline")
        {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
            return false;
        }
        this.issavesubmit='yes';
        getJsScript('include/js/DetailButtons.js',function(){
                SaveDataRecord.save();
           });
        
    }
    //zxm2021-0629 title部分增加【页面设置】【单据分录定制】按钮
    this.createHeadHtml=function()
    {
        var popupobj=CrmPopup.getPopupObj("last");
        this.popupheadhtml='<div class="E_pop_tit" id="'+this.divid+'_head" style="cursor:move">';
        this.popupheadhtml+='<strong class="E_ptita">'+this.headtitle+'</strong>';
        this.popupheadhtml+='<button class="ld-fonticon ld-fonticon-close tip-items-pop" value="'+arrJsPopLabel['LBL_CLOSE']+'" data-tip="'+arrJsPopLabel['LBL_CLOSE']+'" data-direction="bottom" data-type="position"  id="'+this.divid+'_imgclose"></button>';
        if(this.isShowFullscreen && that.getFullscreen()=='yes'){
            this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gosmall tip-items-pop' data-tip='" + arrJsPopLabel['RECOVERY'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='recovery'></i> ";
        } else if(this.isShowFullscreen && that.getFullscreen()=='no'){
            this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gobig tip-items-pop' data-tip='" + arrJsPopLabel['FULLSCREEN'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='fullscreen'></i> ";
        }
        if(this.module!="CustomEcharts"&&popupobj.isadmin == 'on') {
            if (popupobj.detailfieldmodule != '' && popupobj.detailfieldmodule != undefined &&this.module!="ExpenseBudget") {
                this.popupheadhtml += '<a target="_blank" href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ProductToolField&formodule=' + this.module + '" style="float: right">' + arrJsPopLabel['LBL_ProductTool_field'] + '</a>';
            }
            if(popupobj.is_page_setting == "yes"){
                this.popupheadhtml += '<a target="_blank" href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&formodule=' + this.module + '" style="float: right;">' + arrJsPopLabel['LBL_PAGE_SET'] + '</a>';
            }
        };
        /* 赛可出行
        * edit: chj
        * date: 2020/8/11
        * reason: 流转、更新、结案、结案备注
        */
        if(this.module == 'Accounts' && typeof(version_account) != "undefined" && version_account != undefined && version_account == 'saic'){

            if(popupobj.type == 'createpage' || popupobj.type ==  'pagerecord'){
                this.popupheadhtml+='<a href="javascript:;" tag="closedremarks" value="结案备注" onclick="saic_save_account(ld(this),event);return false;" style="padding-right:50px;">结案备注</a>';
                this.popupheadhtml+='<a href="javascript:;" tag="closed" value="结案" onclick="saic_save_account(ld(this),event);return false;">结案</a>';
                this.popupheadhtml+='<a href="javascript:;" tag="wander" value="流转" onclick="saic_save_account(ld(this),event);return false;">流转</a>';
                this.popupheadhtml+='<a href="javascript:;" tag="submit1" value="提交" onclick="saic_save_account(ld(this),event);return false;">提交</a>';
                this.popupheadhtml+='<a href="javascript:;" tag="update" value="更新" onclick="saic_save_account(ld(this),event);return false;">更新</a>';
                this.popupheadhtml+='<a href="javascript:;" tag="zancun" value="暂存" onclick="saic_save_account(ld(this),event)">暂存</a>';
            }
        }
        this.popupheadhtml+='</div>';
    }
    this.changeapproveEvent=function(){

        ld("#"+this.divid+"_btnsavesubmit").unbind("click").bind("click",function(){
            that.SaveSubmit();
        })
         ld("#"+this.divid+" [name=approvevalue]").attr("onchange",'');
         ld("#"+this.divid+" [name=approvevalue]").unbind("change").bind("change",function(){
                    that.ChangeApprove();
         })
         ld.each(that.fields,function(tmpindex,fieldinfo){
            
             if(fieldinfo.uitype==53||fieldinfo.uitype==153||fieldinfo.uitype==154)
             {
                //edit:can 20220628 服务工单模块，单据号FWGD-0016，第一步审批找不到审批人，详见单据的审批日志~ 
                var tmpobj=ld("#"+that.divid+" [name="+fieldinfo.fieldname+"]");
                ld(tmpobj).unbind("change",that.ChangeApprove);
                ld(tmpobj).bind("change",event,that.ChangeApprove);
                   
               
             }
         })
    }
    this.ChangeApprove=function(){
        
        //审批流程改变事件
         if(that.approve_arr==undefined||that.approve_arr.length<=0)
            return ;
            var approveid=ld("#"+that.divid+" [name=approvevalue]").val();
            var requestvalues=getPageValueByCrmPopupFieldsNew(that);
            if(approveid == 0 || approveid == -1){
                var submitapprovestep_tableobj=ld("#"+that.divid+" [name=submitapprovestep_table]");
                submitapprovestep_tableobj.find("tr[tag=rowdata]").remove();
                ld("#" + that.divid + " [tag=rowdata]").css('display', 'none');
                return ;
            }
            var param = {
                "frommodule":that.module,
                "record":that.record,
                "requestvalues":requestvalues['requestvalue'],
                "sensitiverequestfield": requestvalues['sensitiverequestfield'],
                "requestvalue_arr": requestvalues['requestvalue_arr']
            };
            var detaildata_arr = getPageValueByCrmPopupAllProductDetail(that);
            if(!empty(detaildata_arr)){
                param['detaildata_arr'] = detaildata_arr;
            }


            ldAjaxNoProgress("index.php?module=Approve&action=ApproveAjax&file=getFirstStepInfo&approveid="+approveid,param,function(ajaxdata){
                
                ChangeSubmitHtml(ajaxdata);
                ld("#"+that.divid+" [tag=rowdata]").css('display','');
                ld("#"+that.divid+" #subappcontent").css('width','100%');
            })
    }
    this.show = function (htmlcontent) {

   
        picklist = false;
        var that = this;
        if (this.isshowpage == true) {
            parentshow.apply(this, [htmlcontent]);  //调用父类show()函数
            PageRecordPopup.moduleEdit(that);

            this.showafter();
            //放在show函数后面判断是对的，不要移动
            CrmPopup.findHtmlobj(this.divid, "dv_pagecollapse").css("display", "none");
            var tableobj=ld("#"+this.divid+" [name="+this.js_detailtablename+"]");
            that.SortDetailTableRow();//拖动事件
            if (that.detailfields != undefined && that.detailfields.length > 0) {
                //带有分录的模块显示
                    
                   that.detailfieldcolumninfo=[];
                   ld.each(that.detailfields,function(tmpindex,tmpfieldinfo){
                        //zkt 20230719 BUG0069585 折扣额无法自动带出  同时启用折扣额和整单折扣字段
                        if(that.detailtable_arr != undefined && !(that.detailtable_arr.indexOf(tmpfieldinfo.tablename)>-1)){
                            return true;
                        }
                        that.detailfieldcolumninfo[tmpfieldinfo.columnname]=tmpfieldinfo;
                   })
                   var rowobj=ld(tableobj).find("tr[detaildeleted=no]");
                   ld.each(rowobj,function(){
                        var tmpi=ld(this).attr("rowindex");
                       
                        that.SetDetailFieldControl(tmpi);
                      
                        /*
                        if(that.module=='CustomForm26'&&ld(this).find(" #sf315").length>0)
                        {
                            var tmpoldvalue=ld(this).find(" #sf315").val();
                            that.changezhoudccontent(ld(this).find(" #sf314").val(),tmpi);
                            ld(this).find(" #sf315").val(tmpoldvalue);
                            ld(this).find(" [name=cmb_span_optiontext_sf315]").val(tmpoldvalue);
                        }
                        */
                        
                   })
            }

            that.center();
            that.updateBlocklist();
            this.InitPageValue();

            that.setDetailAttachmentEvent();

            that.setRelatedFieldEvent();
        }
        else {

        }
    }
    this.updateBlocklist=function()
    {
        //XUQIU1002354 新增编辑界面优化
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]");
        var block_list = [];
        ld.each(ld(blockobjs),function(tmpindex,tmpblockobj){
            block_list[tmpindex]=ld(tmpblockobj).text();
        })
        var editleft_html = '<ul>';
        ld.each(block_list,function(tmpindex,tmpblock_label) {
            editleft_html += '<li><div class="block-list" block_index="'+tmpindex+'"><a title="'+tmpblock_label+'">'+tmpblock_label+'</a></div></li>';
        });
        editleft_html += '</ul>';
        ld("#"+that.divid+" .edit-left").html(editleft_html);
    }
    this.SetDetailFieldControl=function(rowindex){
        var tableobj=that.getDetailTableObj();
       
        var rowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");
        //alert(ld(rowobj).find("select").length);
        var selectobjs=ld(rowobj).find("[fieldtype=select]");
        var strrowindex=rowindex+"";//转换为字符串
        var rowindex_strlen=strrowindex.length;
       
        ld.each(selectobjs,function(){
            var name=ld(this).attr("detailcolumnname");
            
            var columnname=name;//.substr(0,name.length-rowindex_strlen);
            
            if(that.detailpicklist==null)
            {
                return false;
            }
            var comboxobj=ld(this);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
            cls_resetComboxHtmlobj.setPopupObj(that);//edit:can 产品多选//产品套餐选择
            cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowindex);
            var picklistcontent=that.detailpicklist[columnname];
            var picklistcontentseq=that.detailpicklistseq[columnname];

            cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
            cls_resetComboxHtmlobj.setPickListContentseq(picklistcontentseq);


            var tmpwidth=Tools.Number.convertmmToPx(ld("#"+that.divid+" [head_detailfieldname="+columnname+"]").attr("head_width"));
            tmpwidth=parseInt(tmpwidth);
            var setgreyobj=ld(comboxobj).parent().find(" .icon-setgrey");
            var setobj = ld(comboxobj).parent().find("[name=picklistset_icon]");
        
            if(setgreyobj.length>0  || setobj.length > 0){
                var settingwdith=parseInt(ld(setgreyobj).css("width"));
                var picklistColors=that.detailpicklistColors[columnname];
                cls_resetComboxHtmlobj.setPickListColors(picklistColors);
                if(that.detailfieldmodule=='Products')
                    cls_resetComboxHtmlobj.setEvent();
                else
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj,tmpwidth-40);
            }
            else
            {
                //仓库
                if(that.detailfieldmodule=='Products')
                    cls_resetComboxHtmlobj.setEvent(); //仓库
                else
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj,tmpwidth);
                // cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj,tmpwidth);
            }
             
        })
       
        ld.each(that.detailfields,function(tmpindex,tmpdetailfieldinfo){
                //42213: （61mis.com/kfbcrm）费用报销单模块>新建单据界面：分录明细自定义“多选框111”字段无法选择（需要补丁）
                if(tmpdetailfieldinfo.edit_permission !=1&& (tmpdetailfieldinfo.uitype==63||tmpdetailfieldinfo.fieldtype =='SelectComBox'))
                {
                   if(!ld(rowobj).find(" #"+tmpdetailfieldinfo.columnname+"").is("select"))
                   {
                    return true;
                   }
                    ld(rowobj).find(" #"+tmpdetailfieldinfo.columnname).select2({closeOnSelect: true, dropdownParent: ld("#"+that.divid)});
                    ld(rowobj).find(" #"+tmpdetailfieldinfo.columnname).on("select2:open",function(e)
                    {
                                    var effect_column=ld(this).attr("detailcolumnname");
                                    
                                    var param = {}; //根据触发字段获取对应值组成json对象。
                                     if(ld.inArray(effect_column,that.open_relateproducteffect_column_arr)>=0)
                                        return false;
                                     that.open_relateproducteffect_column_arr.push(effect_column);
                                     popupobj.RelatedProductToolFieldtriggcols=[];
                                     if(!empty(popupobj.relatedproducttoolfield)){
                                         ld.each(popupobj.relatedproducttoolfield,function(tmpindex,tmpinfo){
                                             for(var i=0;i<tmpinfo.trigger_columnname.length;i++)
                                             {

                                                 var trigger_column=tmpinfo.trigger_columnname[i];
                                                 if(ld(rowobj).find(" #"+trigger_column).length>0&&ld(rowobj).find(" #"+trigger_column).val()!='')
                                                 {
                                                     param[trigger_column]=ld(rowobj).find(" #"+trigger_column).val();

                                                 }
                                             }

                                         })
                                         ld.each(popupobj.relatedproducttoolfield,function(tmpindex,tmpinfo){
                                             if(ld.inArray(effect_column,tmpinfo.effect_columnname)>=0)
                                             {
                                                 var requestvalues = getPageValueByCrmPopupFields(that);//获取页面所有的值
                                                 var surl = 'index.php?module=Settings&action=SettingsAjax&file=getRelatedPicklistByColumn&modulename='+that.module+'&param='+JSON.stringify(param)+'&requestvalues='+encodeURIComponent(requestvalues['requestvalue'])+'&sensitiverequestfield='+encodeURIComponent(requestvalues['sensitiverequestfield']);
                                                 surl+='&effect_columnname='+effect_column;
                                                 var selected_arr=ld(rowobj).find(" #"+effect_column).val();
                                                 ldAjaxNoProgress(surl,{},function(ajaxdata){

                                                     ld(rowobj).find(" #"+effect_column).empty();
                                                     ld.each(ajaxdata.result.list,function(tmptext,tmpvalue){
                                                         ld(rowobj).find(" #"+effect_column).append("<option value='"+tmpvalue+"'>"+tmpvalue+"</option>");

                                                     })

                                                     ld(rowobj).find(" #"+effect_column).val(selected_arr);
                                                     ld(rowobj).find(" #"+effect_column).select2({closeOnSelect: true, dropdownParent: ld("#"+that.divid)});
                                                     ld(rowobj).find(" #"+effect_column).select2('open');
                                                 });
                                                 ld(rowobj).find(" #"+effect_column).on("select2:close",function(e){
                                                     var effect_column=ld(this).attr("detailcolumnname");
                                                     if(ld.inArray(effect_column,that.open_relateproducteffect_column_arr)>=0)
                                                     {
                                                         that.open_relateproducteffect_column_arr.splice(ld.inArray(effect_column,that.open_relateproducteffect_column_arr),1);

                                                     }
                                                 });

                                                 return false;
                                             }

                                         })
                                     }

                                    
                                    
                     })
                     
                     
                    
                
                    
                }
				if(tmpdetailfieldinfo.uitype==60)
                {
					popupobj.RelatedProductToolFieldtriggcols=[];
				}
              
                
            })
            
            //zkt 先注释，后续客户那边实现方式修改
            //that.changezhoudcevent(rowindex);
           
    }
    /*
    this.changezhoudcevent=function(rowindex)
    {
         if(that.module=='CustomForm26')
         {
                var tableobj=that.getDetailTableObj();
       
                var rowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");
                ld(rowobj).find(" #sf314").unbind("change").bind("change",function(){
                          that.changezhoudccontent(ld(this).val(),rowindex);
                           
                })
       }
    }
    this.changezhoudccontent=function(val,rowindex){
        
        if(that.module!='CustomForm26')
            return ;
            
        var tableobj=that.getDetailTableObj();
       
        var rowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("sf315");
        var comboxobj=ld(rowobj).find(" #sf315");
        
        var setgreyobj=ld(comboxobj).parent().find(" .icon-setgrey");
        
        cls_resetComboxHtmlobj.setPopupObj(popupobj);//edit:can 产品多选//产品套餐选择
        cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowindex);
       
        var picklistcontent=[];
        switch(val)
        {
			case '线索阶段':
				picklistcontent.push("客户面谈，客户需求挖掘/现场勘察");
				picklistcontent.push("商机决策");
				break;
			case '商机阶段':
				picklistcontent.push("客户基本信息摸排（预算、决策链、全面客户关系管理策略）");
				picklistcontent.push("策划方案启动会");
				picklistcontent.push("概念方案制作");
				picklistcontent.push("概念方案内审/交底");
				picklistcontent.push("概念方案概算/内审");
				picklistcontent.push("立项决策");
				break
			case '立项阶段':
				picklistcontent.push("立项会输出：边际目标、项目CEO、项目级别、施工范围、合同引导目标");
				picklistcontent.push("全面客户关系管理目标和实施计划");
				picklistcontent.push("设计方案勘察现场");
				picklistcontent.push("设计方案制作");
				picklistcontent.push("《设计方案》内审");
				picklistcontent.push("《设计方案》清单预算/内审");
				picklistcontent.push("《设计方案》汇报并获得决策人认可，方案定稿");
				picklistcontent.push("《设计方案》交底");
				picklistcontent.push("施工图设计/内审");
				picklistcontent.push("设计施工方案报价清单/内审");
				break;
			case '商务谈判阶段':
				picklistcontent.push("明确客户内部采购流程及决策因素");
				picklistcontent.push("明确客户招投标流程及影响因素");
				picklistcontent.push("商务流程推动（前审）");
				picklistcontent.push("标书撰写及排他性举措");
				picklistcontent.push("客户发标书");
				picklistcontent.push("投标决策");
				picklistcontent.push("拆标会（投标组织和策略制定）");
				picklistcontent.push("标书制作");
				picklistcontent.push("投标文件内审评标");
				break;
			case '合同签订阶段':
				picklistcontent.push("中标/中标方案确认");
				picklistcontent.push("设计方案深化");
				picklistcontent.push("合同决策");
				picklistcontent.push("合同签订");
				picklistcontent.push("首付款");
				break;
			case '交付阶段':
				picklistcontent.push('客户预计使用时间');
				break;
			case '交付阶段-项目启动':
				picklistcontent.push("项目内部启动会");
				break;
			case '交付阶段-深化设计':
				picklistcontent.push("深化设计（方案深化、图纸深化、全专业合图）");
				picklistcontent.push("深化设计内审");
				picklistcontent.push("深化设计汇报/确认 ");
				picklistcontent.push("深化设计交底");
				break;
			case '交付阶段-装修':
				picklistcontent.push("空间方案确认");
				picklistcontent.push("装修分包进场-放线验线");
				picklistcontent.push("封样/定样");
				picklistcontent.push("隐蔽验收");
				picklistcontent.push("装修收尾");
				break;
			case '交付阶段-美工':
				picklistcontent.push("资料整理");
				picklistcontent.push("方案汇报/确认");
				picklistcontent.push("美工/1:1上墙");
				picklistcontent.push("平面发排");
				picklistcontent.push("设计交底");
				picklistcontent.push("美工收尾");
				break;
			case '交付阶段-沙盘/模型/雕塑':
				picklistcontent.push("方案确认");
				picklistcontent.push("过程/出厂验收");
				break;
			case '交付阶段-多媒体/设备设计、实施':
				picklistcontent.push("多媒体/设备设计方案确认");
				picklistcontent.push("多媒体/设备设计中勘");
				picklistcontent.push("主要设备进场/报验");
				picklistcontent.push("展项调试完成");
				break;
			case '交付阶段-影片/程序':
				picklistcontent.push("影片脚本/程序方案汇报及确认");
				picklistcontent.push("影片预演/程序DEMO汇报及确认");
				picklistcontent.push("成片/程序完整版输出");
				break;
			case '交付阶段-竣工验收':
				picklistcontent.push("内部验收");
				picklistcontent.push("外部初验");
				picklistcontent.push("外部竣工验收");
				break;
			case '结算阶段':
				picklistcontent.push("审计结算资料及报送甲方");
				picklistcontent.push("完成对审，定案");
				break;
			case '客户使用时间':
				picklistcontent.push("客户使用时间");
				break;
        }
        ld(comboxobj).empty();
        ld.each(picklistcontent,function(index,value){
            comboxobj.append("<option value='"+value+"'>"+value+"</option>");
        })
         cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
         var settingwdith=parseInt(ld(setgreyobj).css("width"));
         var picklist_colors_values=popupobj.detailpicklistColors['sf315'];
         cls_resetComboxHtmlobj.setPickListColors(picklist_colors_values);
         var tmpwidth=Tools.Number.convertmmToPx(ld("#"+that.divid+" [head_detailfieldname=sf315]").attr("head_width"));
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj,tmpwidth-40);
    }
    */
    this.InitPageValue = function () {
        var length=this.fields.length;
        
        for (var i = 0; i < length; i++) {

            if (SaveDataRecord.isfileattachUitype(this.fields[i].uitype)) {
                var fileuploader = CrmPopup.findHtmlobj(this.divid, this.fields[i].fieldname);
                //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 0:21
                //此处要做单例缓存，避免重复请求；若后台判断出是cos，应即可返回临时授权码
                var uploadFile = new WebUploadFile();
               
                globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                uploadFile.setEvent(globalWebUploadType,fileuploader,that,i);
             
                if (that.fields[i].uitype == 28) {
                    that.docfilename = this.fields[i].fieldname;
                    showType();
                }
               window.setTimeout(function (i) {
                    
                    if(that.fields[i].allowedit=='no'){
                         ld("#"+that.divid+" [name="+that.fields[i].fieldname+"]").find(" [tag=deletefile]").remove();//("display",'none');
                         ld("#"+that.divid+" [name="+that.fields[i].fieldname+"]").find(" .webuploader-pick").remove();//css("display",'none');
                         ld("#"+that.divid+" [name="+that.fields[i].fieldname+"]").find(" input[name=file]").parent().remove();//
                    }
                 },200,i);
                
                
            }

            else if (this.fields[i].uitype == 230 || this.fields[i].uitype == 231) {


                var tmpokeditor = UE.getEditor(that.fields[i].fieldname);//实例化编辑器
                this.oCKeditor = tmpokeditor;
                this.oCKeditors[that.fields[i].fieldname] = tmpokeditor;
                var tmpfieldname = that.fields[i].fieldname;
                window.setTimeout(function (j) {
                    //33793: 知识管理序时簿界面：点击操作列下面的“编辑”按钮，“知识管理”弹出层位置太靠下，“保存”按钮被遮挡
                    var id = ld('#' + j).children("div:first-child").attr("id");
                    ld('#' + id).css('z-index', '99999');
                    ld('#' + id).parent().addClass('resizeNone');
                    that.center();
                    //zkt BUG20240830-04 BUG管理，BUG管理界面，按F5刷新页面，新建bug的时候，详情下面会有3个富文本框；原因及解决办法那里也有；第二次新建就没有了；（谷歌浏览器）
                    if( ld('#' +  j).find(".edui-editor").length>1)
                    {
                        ld('#' +  j).find(".edui-editor").not("#"+id).remove();
                    }
                }, 500, tmpfieldname);//防止变量污染，故需传递到闭包里面，可拿联系人模块的负责项目uitype为33测试。
            }
            else if(this.fields[i].uitype==251)
            {
                //40471: （http://51mis.com/demo/panlulu004演示账套 [^]）财务核算->收款单，收款单新建界面，选择客户有预收单的源单后，更改账户下拉选项，可使用的预收单信息也应该随之更新
				if(this.fields[i].allowedit == 'yes'){
					var cls_resetComboxHtmlobj=new cls_resetComboxHtml(that.fields[i].fieldname);
					cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
				}
            }
            else if (this.fields[i].uitype == 33) {
                var tmpfieldname = that.fields[i].fieldname;
                //ld('#' + tmpfieldname).select2({closeOnSelect: false});//详情编辑页面的多选框支持连续多选不收起
                //设置select2的zIndex
                ld('#' + that.divid + " [name='" + tmpfieldname + "[]']").select2({
                    closeOnSelect: false,//详情编辑页面的多选框连续多选不收起
                    dropdownParent: ld("#" + that.divid)
                });
            }else if (this.fields[i].uitype == 65){
                var tmpfieldname = that.fields[i].fieldname;
                var locationaddressobj = ld('#'+that.divid).find('#'+tmpfieldname);
                if (locationaddressobj.length > 0){
                    locationaddressobj.unbind('compositionstart').bind('compositionstart',function(){ //开始输入
                        ld(this).attr('inputtype','start');
                    });
                    locationaddressobj.unbind('compositionend').bind('compositionend',function(){ //结束输入
                        ld(this).attr('inputtype','finish');
                    });
                }
            }

        }

        if (that.picklistcontent != null && that.picklistcontent != undefined)
            for (var k = 0; k < that.picklistcontent.length; k++) {
                //下拉框
                var fieldname = that.picklistcontent[k].fieldname;
                that.picklistobjarray[that.picklistcontent[k].fieldname] = new cls_picklist(that.picklistcontent[k].fieldname, that.picklistcontent[k].optionvalue);

                if (that.picklistdepencyfields != null && that.picklistdepencyfields != "" && that.picklistdepencyfields[fieldname] != undefined) {
                    that.picklistobjarray[that.picklistcontent[k].fieldname].setparentDependField(that.picklistdepencyfields[fieldname]);

                }
            }
        
        if (that.picklistdepencyfields != null && that.picklistdepencyfields != undefined) {
            ld.each(that.picklistdepencyfields, function (childfieldname, parentfieldname) {
                if (that.picklistobjarray[parentfieldname] != undefined) {

                    that.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
                }
            });
        }

        fielddepend = new FieldDependencies(this.picklistdepency);
        fielddepend.setup(CrmPopup.findHtmlobj(this.divid, "EditView"));
         that.column_fields=[];
        
        ld.each(that.fields,function(tmpindex,fieldinfo){
           
            that.fieldname_fields[fieldinfo.fieldname]=fieldinfo;
            that.column_fields[fieldinfo.columnname]=fieldinfo;
          
            
            if(fieldinfo.uitype==53||fieldinfo.uitype==153)
             {
                //edit:can 20220628 服务工单模块，单据号FWGD-0016，第一步审批找不到审批人，详见单据的审批日志~ 
                var tmpobj=ld("#"+that.divid+" [name="+fieldinfo.fieldname+"]");
                
                ld(tmpobj).unbind("change",that.ChangeApprove);
                ld(tmpobj).bind("change",event,that.ChangeApprove);
                   
                 
             }
            
        })
        ld("#"+that.divid+" .E_morefields ").css('display','none');
        var fieldruleobj = new cls_fieldrule(that,that.fieldrulefieldnames);
        that.fieldruleobj = fieldruleobj;
        fieldruleobj.setEvent();
        fieldruleobj.setValues(that.columnfields_value);
        var fieldSensitiveruleobj=new cls_fieldSensitiverule(that,that.sensitiverelatedfield);
        that.fieldSensitiveruleobj=fieldSensitiveruleobj;
        fieldSensitiveruleobj.setEvent();
        //edit:can 2021-01-06 042970: （8.2.7安装包）项目工时新建界面，工时详细信息区块界面显示异常
        if(that.detailfields!=undefined&&that.detailfields.length>0)
             fieldruleobj.resetDetailColumns();//布局规则，重新设置分录表头的显示和隐藏
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
         {
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(that);
         }
         
         if(account_version=='langjie')
         {
            //设置列头标签显示
            if(that.module=='CustomForm18')
                setTableTdLabellangjie();
            else if(that.module=='CustomForm19')
                setTableTdLabellangjieCustomForm19();
         }

        var blocklist_obj=ld('#'+this.divid+' .block-list');
        ld.each(blocklist_obj,function(tmpindex,tmpblockobj){//wym XUQIU1002285 新增编辑界面，点击左侧快速定位到指定区块
            ld(tmpblockobj).unbind("click").bind("click", function () {
                that.blocklist_anchor(this);
            })
        })
        ld("#" + this.divid + " .dvpopupsroll").get(0).addEventListener('scroll', that.blocklist_scroll);
        this.blocklist_scroll();//一进界面先触发一下滚动事件

        that.setSpecialEvent();

        that.setCommonFieldEvent();//绑定公共字段事件
        //产品模块 zxm 20241011
        //产品模块 zxm 20241011
        if(that.setObjEventArr){
            ld.each(that.setObjEventArr,function(i,eventfun){
                eventfun();
            })
        }

    }
    //wym XUQIU1002285 新增编辑界面，左侧增加快速定位到指定区块
    this.blocklist_anchor = function (obj) {
        var blockobj= ld('#'+this.divid+' .block-list.selected');
        ld(blockobj).removeClass('selected');
        ld(blockobj).find('a').css('color','#8392A7');
        ld(obj).addClass('selected');
        ld(obj).find('a').css('color','#3B7CFF');
        var target_index = ld(obj).attr('block_index'); // 获取点击的区块序号
        //XUQIU1002354 新增编辑界面优化
        var targetElement = ld("#"+that.divid+" [tag=headblock-title]").eq(target_index); // 查找对应序号的区块
        if (targetElement.length) {
            var scrollobj= ld('#'+this.divid+' .dvpopupsroll');
            var currentScrollPosition = ld(scrollobj).scrollTop();
            if(ld("#" + that.divid + '_head').length>0){
                var headheight = ld("#" + that.divid + '_head').outerHeight();
            }
            //点击事件不能触发滚动事件，先把右侧滚动条事件解绑
            ld(scrollobj).get(0).removeEventListener('scroll', that.blocklist_scroll);
            // 使用动画效果滚动到目标元素
            ld(scrollobj).get(0).scrollTop = currentScrollPosition+targetElement.offset().top-headheight;            // 等待一段时间，然后重新绑定滚动事件处理程序
            setTimeout(function () {
                ld(scrollobj).get(0).addEventListener('scroll', that.blocklist_scroll);
            }, 1000); // 1秒后重新绑定滚动事件处理程序
        }
    }
    //wym XUQIU1002285 右侧滚动，左侧选中当前区块
    this.blocklist_scroll = function () {
        //XUQIU1002354 新增编辑界面优化
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]"); //区块标题元素
        var headheight=0;
        if(ld("#" + that.divid + '_head').length>0) {
            headheight = ld("#" + that.divid + '_head').outerHeight();
        }
        ld.each(ld(blockobjs),function(tmpindex,tmpobj){
            var targettop = ld(tmpobj).offset().top-headheight;
            if(targettop>=0){
                var select_blockobj= ld('#'+that.divid+' .block-list.selected');
                if(ld(select_blockobj).length>0){
                    ld(select_blockobj).removeClass('selected');
                    ld(select_blockobj).find('a').css('color','#8392A7');
                }
                var blockobjs= ld('#'+that.divid+' .block-list');
                if(targettop>0){//targettop大于零，则表示是上一个区块
                    if(tmpindex==0){ //BUG0077529 如果是第一个区块 则选中第一个
                        var cur_blockobj=ld(blockobjs).eq(tmpindex);
                    }else{
                        var cur_blockobj=ld(blockobjs).eq(tmpindex-1);
                    }
                }else if(targettop==0){//targettop等于零，则表示是当前区块
                    var cur_blockobj=ld(blockobjs).eq(tmpindex);
                }
                ld(cur_blockobj).addClass('selected');
                ld(cur_blockobj).find('a').css('color','#3B7CFF');
                return false;
            }
        })
    }

    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（编辑）
    this.setDetailAttachmentEvent=function(){
        that.detailimage_arr=[];
        //edit: xll XUQIU1000357 单据分录定制，增加“附件”字段类型（编辑界面）
        if (!empty(that.detailfields)) {//分录
            for (var i = 0; i < this.detailfields.length; i++) {
                if (this.detailfields[i].bigtype == "image"){
                    that.detailimage_arr.push(this.detailfields[i]);
                }
                if (this.detailfields[i].bigtype == "fileattachment"){
                    that.detailimage_arr.push(this.detailfields[i]);
                }
            }

            var trobjs=this.getTrObjsByDelType('no');
            for (var j = 0; j < trobjs.length; j++) {
                var rowindex = ld(trobjs[j]).attr("rowindex");
                for (var i = 0; i < that.detailimage_arr.length; i++) {
                    // if (this.detailfields[i].bigtype == "image") {
                    // var fileuploader = ld("#"+this.divid+" tr[rowindex="+rowindex+"] [detailfieldname="+that.detailimage_arr[i].fieldname+"] div[name="+that.detailimage_arr[i].fieldname+"]");//分录可能有多行需要区分
                    var fileuploader = ld(trobjs[j]).find(" [detailfieldname="+this.detailimage_arr[i].fieldname+"]").find(" div#"+this.detailimage_arr[i].fieldname);
                    //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 0:21
                    //此处要做单例缓存，避免重复请求；若后台判断出是cos，应即可返回临时授权码
                    var uploadFile = new WebUploadFile();

                    globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                    uploadFile.setDetailEvent(globalWebUploadType,fileuploader,that,i,rowindex);

                    window.setTimeout(function (i) {

                        if(that.detailimage_arr[i].edit_permission!=0)
                            ld("#"+that.divid+" [name="+that.detailimage_arr[i].fieldname+"]").find(" [tag=deletefile]").css("display",'none');//删除
                        // ld("#"+that.divid+" [name="+that.detailimage_arr[i].fieldname+"]").find(" .webuploader-pick").css("display",'none');//添加
                    },200,i);

                    // }
                }
            }
            
            //this.detailfilejsondata = [];//要清空编辑时已有的文件信息，否则复制行或者删除再新增行会重新将文件信息写入 delete popupobj.detailfilejsondata;
            
            
        }
    }

    this.setRelatedFieldEvent = function () {
        ld.each(that.fields, function (tmpindex, fieldinfo) {
            var tmpfieldname = fieldinfo.fieldname;
            if (account_version == 'fengming' &&
                ((that.module == 'CustomForm04' && tmpfieldname == 'cf_5591') ||
                    (that.module == 'CustomForm16' && tmpfieldname == 'cf_5619') ||
                    (that.module == 'CustomForm17' && tmpfieldname == 'cf_5858') ||
                    (that.module == 'CustomForm18' && tmpfieldname == 'cf_5865'))
            ) {
                ld('#' + that.divid + " [name='" + tmpfieldname + "']").on('input', function() {
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(that.module, 1, '', tmpfieldname, that.module, 'special_noselect');
                    });
                });
            }
        })

       /* ld.each(that.picklistcontent, function (tmpindex, fieldinfo) {
            var tmpfieldname = fieldinfo.fieldname;
            ld("#" + that.divid + ' [name=dv_cmb_' + tmpfieldname + "]").unbind('click').on('click', function() {
                getJsScript('include/js/relatedfield.js', function () {
                    getRelatedFieldData(that.module, 1, '', tmpfieldname, that.module, 'select');
                });
            });
        })*/
    }

    //特殊开发的一些页面动作监听事件
    this.setSpecialEvent = function () {
        if (account_version == 'baxter' && ld.inArray(that.module,['CustomForm72','CustomForm74'])>=0) {
            getJsScript('include/js/Baxter.js', function () {
                var baxterobj = new Baxter(that);
                that.baxterobj = baxterobj;
                baxterobj.setEvent();
            })

        }

    }

    that.beforeshowInitValue=function(data)
    {
        var Popupobj=that;
        Popupobj.picklistdepency = data.result.picklistDependencyDatasource;
        Popupobj.isshowpage = true;
        var paramsobj = Popupobj.paramsobj;
        if (paramsobj != undefined){
            Popupobj.refreshpage = paramsobj.refreshpage;
			Popupobj.relatedcreate = paramsobj.relatedcreate;
		}
        Popupobj.validatasave = data.result.validatasave;
        Popupobj.validatasaverule = data.result.validatasaverule;
        Popupobj.fieldname = data.result.fieldname;
        Popupobj.fieldlabel = data.result.fieldlabel;
        Popupobj.fielddatatype = data.result.datatype;
        Popupobj.fields = data.result.fields;
        
        Popupobj.filejsondata = data.result.filejsondata;
        if(Popupobj.filejsondata==undefined){
            Popupobj.filejsondata=[];
        }

        Popupobj.detailfilejsondata = data.result.detailfilejsondata;
        if(typeof Popupobj.detailfilejsondata == 'undefined'){
            Popupobj.detailfilejsondata=[];
        }
        Popupobj.isadmin = data.result.isadmin;
        Popupobj.is_page_setting = data.result.is_page_setting;
        Popupobj.columnfields_value = data.result.columnfields_value;
        Popupobj.tablerelfields = "";
        Popupobj.picklistcontent = data.result.picklistcontent;//下拉框
        Popupobj.picklistdepencyfields = data.result.picklistdepencyfields;
        Popupobj.fieldrulefieldnames = data.result.fieldrulefieldnames;//布局规则查询字段
        Popupobj.detailfieldrulefieldnames = data.result.detailfieldrulefieldnames;//明细布局规则查询字段
        Popupobj.sensitiverelatedfield = data.result.sensitiverelatedfield;//敏感规则相关字段
        if(data.result.fieldrulevalues)
            Popupobj.fieldrulevalues = data.result.fieldrulevalues;//布局规则隐藏的字段
        // //关联创建
        Popupobj.frommodule = '';
        Popupobj.fromid = '0';
        Popupobj.detailfields = data.result.detailfields;
        Popupobj.detailfieldmodule = data.result.detailfieldmodule;
        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0) {
            Popupobj.detailtable_arr = [];
            Popupobj.detailtable_arr.push(data.result.detailtablename);
            Popupobj.detailtable_arr.push(data.result.detailtablenamescf);
            if(Popupobj.detailfieldmodule == 'Products'){
                Popupobj.detailtable_arr.push('ld_products');
                Popupobj.detailtable_arr.push('ld_productscf');
            }
        }
        Popupobj.allproductimagefieldname = new Array();//产品分录的所有的产品属性图片字段

        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0 && Popupobj.detailfieldmodule == 'Products') {
            Popupobj.productfieldinfo = data.result.productfieldinfo;
            Popupobj.detailpicklist=data.result.detailpicklist//edit:can 2020-09-11 下拉框字段的内容
            Popupobj.detailpicklistseq=data.result.detailpicklistseq//明细下拉框字段的排序

            Popupobj.detailpicklistColors=data.result.global_picklist_colors_values;
            //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示（产品分录的所有的产品属性图片字段）
            for(var i=0;i<Popupobj.detailfields.length;i++)
            {
                if (Popupobj.detailfields[i].uitype == 69 && (Popupobj.detailfields[i].tablename == "ld_products" || Popupobj.detailfields[i].tablename == "ld_productcf")) {
                    Popupobj.allproductimagefieldname.push(Popupobj.detailfields[i].fieldname);
                }
            }
        }
        Popupobj.fieldname_fields = [];
        Popupobj.uitypes = [];
        for (var i = 0; i < Popupobj.fields.length; i++) {
            var fieldname = Popupobj.fields[i].fieldname;
            var columnname = Popupobj.fields[i].columnname;
            Popupobj.uitypes[fieldname] = Popupobj.fields[i].uitype;
            Popupobj.fieldname_fields[fieldname] = Popupobj.fields[i];
            //Popupobj.column_fields[columnname]=Popupobj.fields[i];
        }

        //@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品、输入数量后自动带出价格
        Popupobj.relatedproducttoolfield = data.result.relatedproducttoolfield;
        Popupobj.sys_deploy = data.result.sys_deploy;

        Popupobj.moduleData = data.result;

        if (data.result.cur_groupinfo != undefined) {
            Popupobj.cur_groupinfo = data.result.cur_groupinfo;
        }
    }
    that.setInitValue=function(data,paramsobj)
    {
        var Popupobj = that;
        this.beforeshowInitValue(data);
        Popupobj.createScrollDiv();
    }
    this.aftershowInitValue=function(data){
        getJsScript('include/js/freezeEntriesColumns.js', function () {
            var freezeEntriesColumnsobj = new FreezeEntriesColumns(that,'proTab');
            freezeEntriesColumnsobj.freezeTheadAndBody();
        });
        // 系统设置->单据分录定制，增加“设置冻结前几列”参数
        // getJsScript('include/js/freezecolumns.js',function(){
        //    
        //      that.freezecolumnsObj=freezecolumnsObj;
        //      that.freezecolumnsObj.stickthindex=ld(that.getDetailTableObj()).find('tr[tag=trhead]').find('.set-sticky').attr("thindex");
        //     freezecolumnsObj.init('proTab');//冻结列类初始化
        //     freezecolumnsObj.freezeThColumn('set-sticky');
        // });
        var Popupobj = that;
        //加载tip 20230525 diony
        // tooltip(ld("#"+Popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
        var paramsobj=Popupobj.paramsobj;
        Popupobj.mainfieldformulaobj=new cls_mainfieldformula(data.result.mainfieldformula);
        Popupobj.mainfieldformulaobj.setPopupobj(Popupobj);
        Popupobj.mainfieldformulaobj.init();
        Popupobj.mainfieldformulaobj.setEvent();
    
        Popupobj.detail2mainformulaobj=new cls_detail2mainformula(data.result.mainfieldformula);
        Popupobj.detail2mainformulaobj.setPopupobj(Popupobj);
        Popupobj.detail2mainformulaobj.init();
        Popupobj.detail2mainformulaobj.setEvent();
       
        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0 && Popupobj.detailfieldmodule == 'Products') {
            setProductDivWidth.pageMode='edit';
            Popupobj.noprofiledetailfields=data.result.noprofilefields;
            setProductDivWidth(Popupobj);//设置列宽
            Popupobj.detailtableindex=data.result.detailtableindex;//明细表主键
            //字段布局规则
            
            Popupobj.detaildisplaycolumns=data.result.detailfieldruleinfo.displaycolumns;
            Popupobj.detailhidecolumns=data.result.detailfieldruleinfo.hidecolumns;
            //duan 20230419 产品分录模块进入调用分录布局规则控制
            Popupobj.fieldruleobj.resetDetailColumns();
            var oS = document.createElement('script');
            oS.src = global_js_url + "include/js/modules/Products/Products.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            Popupobj.selectproductobj = new fun_selectproduct(Popupobj.productfieldinfo);
            Popupobj.selectproductobj.setPopupobj(Popupobj);
            if(Popupobj.module=="WorkSheet"){
                Popupobj.selectproductobj.worksheettablecolumn_arr=data.result.headdetailcolumn
                Popupobj.selectproductobj.worksheet_sourcevalue_arr=data.result.worksheet_sourcevalue
            }
            Popupobj.selectproductobj.fnAddProductTdBtn();
            Popupobj.selectproductobj.AfterchooseSourceHide();//选择源单后隐藏按钮（严格控制选择源单）
            if(data.result.sourcemodule!=null)
                Popupobj.sourcemodule_arr=data.result.sourcemodule;
            Popupobj.baseColumn=data.result.baseColumn;
            Popupobj.fieldformulaobj = new fieldFormula(Popupobj.productfieldinfo);
            //edit:can 2020-10-12 产品分录明细：系统参数“价格和金额计算时的基准字段”设置为“不含税单价”，录入“税率”应反算“含税单价”
            Popupobj.fieldformulaobj.baseColumn=data.result.baseColumn;
            Popupobj.fieldformulaobj.setPopupobj(Popupobj)
            Popupobj.pricestrategyobj = new PriceStrategy();
            Popupobj.productstrategyobj = data.result.productstrategyobj;
            Popupobj.havebatchtextcolumnname = 'no';
            Popupobj.ordertype_onclick = data.result.ordertype_onclick;
            //editor:gyq_161 reason:带分录模块弹出层   2019/11/21 17:05
            Popupobj.detailtablename = data.result.detailtablename;
            Popupobj.detailtablenamescf = data.result.detailtablenamescf;
            Popupobj.detaildatavalue_arr=data.result.detaildatavalues;
            for (var i = 0; i < Popupobj.productfieldinfo.fields.length; i++) {
                if (Popupobj.productfieldinfo.fields[i].columnname == 'batchtext') {
                    Popupobj.havebatchtextcolumnname = 'yes';

                    break;
                }
            }
              
            oS.onload = oS.onreadystatechange = function () {
              /* Popupobj.fieldformulaobj.setAllRowEvent();//设置字段公式
                var trobjs=Popupobj.getTrObjsByDelType('no');
                 ld.each(trobjs,function(){
                    var i=ld(this).attr("rowindex");
                     // BUG0057646 ls 20221013 自用账套，CustomForm13 添加的单据分录 CustomForm13 带出规则，编辑界面没有触发
                     Popupobj.RelatedProductToolFieldtriggcols=[];
                    //  getRelatedProductToolFieldPriceCallBack(Popupobj,i);//BUG0058184 ls 20221031 销售合同 分录中 限制条件字段，点击编辑时 此值 自动就清空了(受影响字段是客户手动添加的，需要编辑时不触发，故先注释)
                    getRelatedProductToolFieldPrice(Popupobj,i);
                 
                 })
                    
                */
                
            }
          //  setProductDivWidth.mode='edit';
        //    setProductDivWidth();//设置明细列的宽度
           // SetDiscountPercent(Popupobj);
          //  UpDownPointFocus(Popupobj);
          //  DisCountFocusShowMess(Popupobj);
            //zkt 2023-10-12  BUG0073756 首页数据简报中，进入报价单数，修改单据无法保存
            if(Popupobj.module=='Quotes' && account_version == 'haige'){
                HaigeControlTrElement();
            }
        }
        else if (Popupobj.hasOwnProperty('detailfieldmodule')&& Popupobj.detailfieldmodule !== undefined && Popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
          //  setProductDivWidth.pageMode='edit';
            setProductDivWidth(Popupobj);//设置列宽
            //zkt 20210930 0047602: https://81mis.com/kfbcrm [^]，请假单-进入后如图显示 布局规则，设置分录表头的显示和隐藏
            Popupobj.fieldruleobj.resetDetailColumns();
            //字段布局规则
            Popupobj.detaildisplaycolumns=data.result.detailfieldruleinfo.displaycolumns;
            Popupobj.detailhidecolumns=data.result.detailfieldruleinfo.hidecolumns;
            Popupobj.detailtablename = data.result.detailtablename;
            Popupobj.detailtablenamescf = data.result.detailtablenamescf;
            Popupobj.detailtableindex=data.result.detailtableindex;//明细表主键
            if(data.result.sourcemodule!=null)
                Popupobj.sourcemodule_arr=data.result.sourcemodule;
            var oS = document.createElement('script');
            oS.src = global_js_url + "include/js/producttool/TabDetailFieldFormula.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            oS.onload = oS.onreadystatechange = function () {
                Popupobj.fieldformulaobj = new tabDetailFieldFormula(data.result.product_fields_info);
                Popupobj.fieldformulaobj.setPopupobj(Popupobj)
                if (Popupobj.fieldformulaobj.baseColumn != '')
                    Popupobj.fieldformulaobj.cur_input_focus_obj = ld('#' + Popupobj.divid + ' [name="' + Popupobj.fieldformulaobj.baseColumn + '1"]').get(0);
                Popupobj.fieldformulaobj.setAllRowEvent();//设置字段公式
                Popupobj.selectproductobj = new fun_selectproduct(Popupobj.productfieldinfo);
                fnAddProductTdBtn();
            };
        }
        AjaxJSPage('PricePolicyUse', 'include/js/modules/PricePolicy/PricePolicyUse.js');
        var useObj = PricePolicyUse.getInstance(Popupobj);
        try {
            if (useObj.getBlockInfo()) {
                useObj.updateTotal(useObj.reCalculateTotal());
            }
        }
        catch (e) {
            console.log(e);
        }
    }
    this.picklist_arrow_click = function (event, fieldname) {
        cmb_fldname = fieldname;//用于picklist.js中document.onclick调用
        cmb_parentdivid = this.divid;//用于picklist.js中document.onclick调用
        that.picklistobjarray[fieldname].arrow_click(fieldname);

    }
	this.picklist_end_foucs=function(event,fieldname)
    {
		ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();

    }
    this.SortDetailTableRow=function()
    {
        
        if(that.detailfieldmodule==''||that.detailfieldmodule==undefined)
            return false;
        var tableobj=this.getDetailTableObj();
        var tbody=ld(tableobj).find("tbody").get(0);
        if (empty(tbody)){
            return false;
        }
        Sortable.create(tbody,{
		     draggable: ".dragtrrow",  // 允许拖拽的项目类名,否则会拖拽到小计行
		//	animation: 500,
			handle: '.drag-handle',
		
            onStart:function(evt){
                evt.preventDefault();
                evt.stopPropagation();
            },
		   onUpdate: function (/**Event*/evt) {
                                        // same properties as onEnd
             evt.preventDefault();
             },
			onEnd: function (evt) {	//移动行
                //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录拖动
                var tmpfromrowindex = evt.oldIndex-1;//因为table默认空tr及header的tr,因此rowindex=trindex-1
                var tmptorowindex = evt.newIndex-1;
			    Detaildatachange_byrowindexoperation(that,'before','exchange',tmpfromrowindex,tmptorowindex);
                
                if(that.detailfieldmodule=='Products')
                {
                     that.selectproductobj.fnAddProductTdBtn();
                        var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
                        var startrowindex=1;
                        if(parseInt(evt.oldIndex)<parseInt(evt.newIndex))
                        {
                             var start=parseInt(evt.oldIndex)-1
                             var end=parseInt(evt.newIndex)
                        }
                        else{
                             var start=parseInt(evt.newIndex)-1
                             var end=parseInt(evt.oldIndex)
                        }
                        //交换行数组内容交换
                        var arr_temp = [].concat(that.detaildatavalue_arr);  //创建一个新的临时数组，用以操作后不变更原数组
                        arr_temp.splice(tmptorowindex-1, 0, arr_temp.splice(tmpfromrowindex-1, 1)[0]);  //在b位置插入从a位置截取的元素
 
                       ld.each(trobjs,function(){
                            ld(this).attr("rowindex",startrowindex);
                            ld(this).attr("row",startrowindex);
                            var tmprowindex=parseInt(ld(this).attr("rowindex"));
                              if(tmprowindex>=start&&tmprowindex<=end)
                            {

                                var tmparr={};
                                ld.each(arr_temp[startrowindex - 1],function(tmpcolumnname,value){
                                    
                                    tmparr[tmpcolumnname]=value;
                                })
                                that.detaildatavalue_arr[startrowindex - 1]=tmparr;
                                that.detaildatavalue_arr[startrowindex - 1].databind='no';
                               that.selectproductobj.onmouseevent(ld(this));
                               
                            }
                            startrowindex++;
                       })
                    
                     
                }
                else if(that.detailfieldmodule!=''&&that.detailfieldmodule!=undefined)
                {
                    fnAddProductTdBtn();
                    that.fieldformulaobj.setAllRowEvent(); 
                }
               
                
                 ld(tableobj).find("tr[rowindex=1]").find('[tag="btn_del"]').remove;//删除第一行的删除按钮
                 Detaildatachange_byrowindexoperation(that,'after','exchange',tmpfromrowindex,tmptorowindex);
               //  that.selectproductobj.fnAddProductTdBtn();//重新定义第一列的按钮
			}
		}); 
        
        
    }
    this.getpopupMaxHeight=function()
   {
    return CrmPopup.getClientHeight();
   }
   
    this.setInnerHtml = function () {



        ld("#"+this.divid).html(this.popupheadhtml +this.scrolldiv+this.htmlcontent+'</div>'+this.popupbottomhtml);
        
        document.getElementById(this.divid).style.display = "block";

        this.setScrollDivMaxHeight();
    }
    /**
     *获取界面的值,编辑返回值为空，是因为我们可以从弹出层界面直接获取
     **/
    this.getsavedeskpageValue = function () {

        return "";

    }
    /**
     **/
    this.getFileDataArr = function () {
        return "";
    }
    this.setTimeCount = function () {
        this.timeintervalid = setInterval(function () {
            that.timeCount += 3;
        }, 3000);


    }
    this.clearTimeCount = function () {
        this.timeCount = 0;

        clearInterval(this.timeintervalid);
    }
    var parentcancelevent = this.CancelEvent;
    this.CancelEvent = function () {

        parentcancelevent.apply(this, []);
        this.clearTimeCount();
    }
    //wym 231204 XUQIU1002278 新增编辑页全屏,重写setScrollDivMaxHeight事件
    //wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
    this.setScrollDivMaxHeight = function () {
        var fullscreen=this.getFullscreen();
        if(fullscreen=='no'){//缩小
            var maxheight = that.getMaxHeight();
            ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
            ld("#" + this.divid + " .dvpopupsroll").css("height", 'auto');
        }else {//全屏
            var maxheight = CrmPopup.getClientHeight();
            if (ld("#" + this.divid + '_head').length > 0) {
                maxheight -= ld("#" + this.divid + '_head').outerHeight();
            }
            if (ld("#" + this.divid + '_popupbottom').length > 0) {
                maxheight -= ld("#" + this.divid + '_popupbottom').outerHeight();
            }
            ld("#" + this.divid + " .dvpopupsroll").css("height", maxheight);
            ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
        }
    }

    this.getBigpopupwidth = function (){
        return parseInt(CrmPopup.getClientWidth());
    }

    this.getSmallpopupwidth = function (){//全屏与缩小界面切换比例
        return parseInt(CrmPopup.getClientWidth()*0.8);
    }

    this.Fullscreencallback = function (switchtotype){
        if(switchtotype=="fullscreen"){
            this.fullscreen='yes';
        } else{
            this.fullscreen='no';
        }
        this.setScrollDivMaxHeight();
        //zkt 20240328 3、BUG20240328-21  	kfbcrm-销售订单-下推出库单1.先点击在当前页签新建出库单，右上角点击缩小界面，关闭新建界面2.再点击打开新页签新建出库单，这时候的界面大小是记住上次的选择 是缩小的，点击右上角放大界面，分录不会跟着变化
        if(/*that.detailfields != undefined && that.detailfields.length > 0 &&*/ that.detailfieldmodule != undefined){
            setProductDivWidth(that);
        }
        that.center();
    }

    this.getFullscreen = function () {
        if(empty(that.fullscreen)){
            var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
            ldAjaxNoProgresssync(urlstring,'',function(data) {
                if(data.code==1){
                    if(data.result.content != ''){
                        that.fullscreen=data.result.content;
                    }
                    else{
                        that.fullscreen = 'yes';
                    }
                }
            });
        }
        var fullscreen = that.fullscreen;
        return fullscreen;
    }

    this.getWidth = function () {
        var fullscreen = that.getFullscreen();
        if(fullscreen == 'no'){
            return parseInt(CrmPopup.getClientWidth()*0.8);
        }else{
            return parseInt(CrmPopup.getClientWidth());
        }
    }
    //duan 20240925 绑定公共字段事件
    this.setCommonFieldEvent = function () {
        var common_field_event_obj = new cls_common_field_event(this);
        this.common_field_event_obj = common_field_event_obj;
        this.common_field_event_obj.setEvent();
        this.common_field_event_obj.setAllEntryEvent();
    }

}
PageRecordPopup.setDetailViewTitle = function (divid) {

    var link_label = "";
    var link_value = "";
    var smownerlabel = "";
    var smownervalue = "";
    var k = 0;
    var popupobj = CrmPopup.getPopupObj("last");
    if (popupobj.type == 'relatedpagelist') {
        //32532: 合同订单>明细>相关信息>客户服务单：当客户服务单为0时，新建客户服务单保存后，上方的负责人显示为“负责人：”，没有显示合同的负
        popupobj = CrmPopup.getPopupObj("lastprev");
    }
    //设置查看界面标题栏

    for (var i = 0; i < popupobj.fields.length; i++) {

        if (popupobj.fields[i].fieldname == popupobj.list_link_field) {
            link_label = popupobj.fields[i].fieldlabel;

            link_value = popupobj.column_fields_value[popupobj.fields[i].columnname][1];

            k++;
        }
        if (popupobj.fields[i].columnname == popupobj.smownercolumnname) {
            smownerlabel = popupobj.fields[i].fieldlabel;

            smownervalue = popupobj.column_fields_value[popupobj.fields[i].columnname][1];
            k++;
        }
        if (k == 2) {
            break;
        }
    }
    var strhtml = '<b style="float:left;font-size: 15px;padding-left:5px;padding-right:20px;" > ';

    strhtml += link_label + languagecolon[language] + link_value;
    strhtml += "</b>";
    if (!empty(popupobj.smownercolumnname_value)) {
        smownervalue = popupobj.smownercolumnname_value;
    }
    //银行账户：没有负责人字段
    if (popupobj.module != "Users" && smownerlabel != "") {
        //languagecolon[language]：中英文冒号
        strhtml += '<span style="font-size: 15px;">' + smownerlabel + languagecolon[language] + smownervalue + "</span><span  style='font-size: 15px;'></span>";
    }

    ld("#" + divid + " [name=detailviewtitle]").html(strhtml);

}

PageRecordPopup.params = {"refreshpage": "yes", "relatedcreate": "no", "isduplicate": "no",'save_funname':''};
PageRecordPopup.fun_params=function(){
    return PageRecordPopup.params;
}
//wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
PageRecordPopup.getWidth=function(){
    var fullscreen = '';
    var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
    ldAjaxNoProgresssync(urlstring,'',function(data) {
        if(data.code==1){
            if(data.result.content != ''){
                fullscreen=data.result.content;
            } else {
                fullscreen = 'yes';
            }
        }
    });
    if(fullscreen == 'no'){
        return parseInt(CrmPopup.getClientWidth()*0.8);
    }else{
        return parseInt(CrmPopup.getClientWidth());
    }
}
PageRecordPopup.showpage = function (module, record, tmpurl, params) {
    var Popupobj = CrmPopup.getPopupObj("last"),
        PopupJqObj = ld('#'+Popupobj.divid);
    Popupobj.paramsobj=params;
    Popupobj.lasturl=tmpurl;
    var addurl = '';
// @edit:liushuai,2021-03-19,reason:【ID1001377】链接模块，弹出层标签修改
    //zkt 添加判断，链接模块的编辑操作,防止相关信息的编辑冲突
    if (typeof linkmodulecustom != "undefined"&& Popupobj.type != 'relatelistpage') {
        var page_title = ld(" .detail_path li").html();
        addurl = '&is_linkmodulecustom='+linkmodulecustom+'&page_title='+encodeURIComponent(page_title);
        //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
        //获取链接模块viewname
        var page_addurl = getSearchString('page_addurl',location.href);
        if(page_addurl != undefined){
            var linkmodule_viewname = getSearchString('viewname',page_addurl);
            if(linkmodule_viewname != undefined){
                Popupobj.linkmoduleviewname=linkmodule_viewname;
                addurl +='&linkmodule_viewname='+linkmodule_viewname;
            }
        }
    }
    // diony 2023-12-15 XUQIU1002381 新增、编辑、明细界面做Skeleton 骨架屏
    AjaxJSPage('ld_Skeleton','include/js/component/ld_Skeleton.js');
    PopupJqObj.find('div[name=prevshowdv]').remove();
    ld_Skeleton.showSkeletonPop(Popupobj, CrmPopup.getClientHeight()-128);
    Popupobj.center();
    // return;

    // Safari浏览器增加一个样式
    if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Mac') != -1 && navigator.userAgent.indexOf('Chrome') == -1) {
        // console.log('Safari on Mac detected, applying class...');
        PopupJqObj.addClass('ld-safari-mac'); // provide a class for the safari-mac specific css to filter with
    }
    var url = 'index.php?module=' + module + '&action=' + module + 'Ajax&file=EditView&record=' + record + tmpurl + addurl+ "&sourcefrom=PC";

    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    var popupobj = CrmPopup.getPopupObj('lastprev');
    if(module == 'Users' && popupobj.user_type){
        url += '&user_type='+popupobj.user_type;
        Popupobj.user_type = popupobj.user_type;
    }
    ldAjax(url,'',function (data) {
        DelProgressObjs();
        if (data.code == 1) {
            //duan 20230804 首页点击数据穿透,进入详情,点击编辑会报错,去除以前的加载按钮
            //$("status").style.display = "none";
            cur_PageInfo.pagetype.push('poplayerdetailview');
            cur_PageInfo.modulenames.push(module);
            cur_PageInfo.pagemode.push('poplayer');
            Popupobj.helpdesk_log = data.result.helpdesk_log;
            if(module=='CashBill'){
                //显示预收款信息
                if(data.result.cashbilltype!=undefined){
                    //收款单的收款类型
                    Popupobj.cashbilltype=data.result.cashbilltype;
                }
                if(data.result.columnfields_value['account_id']!=undefined)
                    var accountid=data.result.columnfields_value['account_id'];
                else
                    var accountid=0;
                if(data.result.columnfields_value['bankaccountsetid']!=undefined)
                    var bankaccountsetid=data.result.columnfields_value['bankaccountsetid'];
                else
                    bankaccountsetid=0;

                //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
                if(data.result.columnfields_value['currency_id']!=undefined)
                    var currency_id=data.result.columnfields_value['currency_id'];
                else
                    currency_id=0;

                if(Popupobj.cashbilltype!=undefined)
                    var cashtype=Popupobj.cashbilltype;
                else
                    var cashtype='';

                if(accountid>0)
                {
                    var  relatelistobj=getChooseRelateLists.getInstance(Popupobj);

                    relatelistobj.setCurrencyId(currency_id);
                    relatelistobj.getChooseAccountRelateList(bankaccountsetid,accountid,cashtype);

                }
            }
            var tmpwidth=PageRecordPopup.getWidth();
            //BUG20240829-42 建议：如果模块名称是“***管理”，新增、编辑、复制单据的时候，标题显示新增、编辑、复制****即可，把管理2个字去掉（邱：只修改中文版，最后两个字是【管理】）
            if (data.result.title.trim().slice(-2) == '管理'){
                data.result.title = data.result.title.trim().slice(0,-2);
            }
            data.result.title = arrJsPopLabel['TitleEdit']+data.result.title;
            if(module == 'SocialPromotion'){

                // @edit:dong @date:2020/7/10 @reason:  增加弹出层按钮上一步
                Popupobj.createBottomHtml=function(){
                    Popupobj.popupbottomhtml= socialCreateBtnHtml(Popupobj,data);
                }
                //社交推广 新建步骤为一步一步
                Popupobj.setParams(data.result.title,socialCreateNextStep,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);
            }
            else if(module == 'Questionnaire'){
                //问卷调查   ID1001572
                Popupobj.createBottomHtml=function(){
                    Popupobj.popupbottomhtml= Questionnaire.prototype.questionnaireCreateBtnHtml(Popupobj,data);
                }
                var parentdivmaxheight=Popupobj.setScrollDivMaxHeight;
                Popupobj.setScrollDivMaxHeight=function(){

                    parentdivmaxheight.apply(this,[]);
                    var maxheight=this.getMaxHeight()-10;

                    ld("#"+this.divid+" [name=displayfields]").css("height",maxheight);
                }
                Popupobj.setParams(data.result.title,Questionnaire,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);
            }
            //海格报价单保存事件改为savehaigequote
            else if(account_version=='haige'&&module=='Quotes')
            {
                Popupobj.SaveSubmit=function(){
                    //保存提交
                    var submitapprove_text = PopupJqObj.find("[id=submit_description]").val();//提交意见是否为空
                    var submitlabelobj = PopupJqObj.find("[name=submitremarkrequire]");//提交意见是否必填
                    if(ld.trim(submitapprove_text)==""&&ld(submitlabelobj).css("display")=="inline")
                    {
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
                        return false;
                    }
                    this.issavesubmit='yes';
                    getJsScript('include/js/DetailButtons.js',function(){});
                    getJsScript('include/js/modules/Quotes/Quotes.js',function(){
                        savehaigequote();
                    });


                }

                Popupobj.setParams(data.result.title,savehaigequote,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);

            }
            else{
                if(typeof params=="undefined" || typeof params.save_funname=="undefined"||params.save_funname==''||params.save_funname==undefined)
                {

                    Popupobj.setParams(data.result.title,SaveDataRecord.save,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);
                }
                else//选择产品套餐界面调整按钮
                    Popupobj.setParams(data.result.title,params.save_funname,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);
            }

            Popupobj.setInitValue(data,params)


            /**
             *界面显示后加载相关模块的ajax
             **/
            Popupobj.showafter = function () {
                ld('textarea').not('.proName_note').autosize();

            }
            Popupobj.approve_arr=data.result.approve_arr;
            Popupobj.savesubmittext=data.result.savesubmittext;
            Popupobj.show(data.result.allcontent);

            //wyt 221123 BUG0058835 kfbcrm 当审批步骤中设置了审批必填的字段，点击确认后，光标应定位到必填字段上（例：合同订单SO270 ）（邱：autofocus="autofocus"，这个是不固定的，可能需要动态增加属性，下拉框可能无法定位光标）
            if(data.result.curapproveformodulefield!=undefined){
                for(var i=0;i<data.result.curapproveformodulefield.length;i++){
                    if(empty(PopupJqObj.find("[name="+data.result.curapproveformodulefield[i]+"]").val())){
                        PopupJqObj.find("[name="+data.result.curapproveformodulefield[i]+"]").attr('autofocus','autofocus');
                        PopupJqObj.find("[name="+data.result.curapproveformodulefield[i]+"]").focus();
                        break;
                    }
                }
            }

            Popupobj.changeapproveEvent();//审批流程改变事件


            if(data.result.approve_arr!=undefined&&data.result.approve_arr.length>0)
            {
                Popupobj.ChangeApprove();
            }
            //@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格(序时簿点击编辑按钮时，给产品分录行的产品和数量绑定事件,逻辑在Popupobj.show之后)
            var rowcnt = PopupJqObj.find("[name=rowcnt]").val();


            if(cashtype=='cashbill'&&typeof relatelistobj!="undefined")//收款单查看界面
                relatelistobj.showDebuctionList();

            //增加获取审批相关的字段信息
            if (data.result.approve_fieldname_arr != undefined) {
                getJsScript('include/js/modules/Approve/cls_approvestep_change.js', function () {
                    Popupobj.approvestep_changeobj = new cls_approvestep_change(Popupobj,data.result.approve_fieldname_arr);
                });
            }
            if (data.result.module_setting != undefined){
                Popupobj.module_setting = data.result.module_setting;
            }else{
                Popupobj.module_setting = {};
            }

            Popupobj.sourcemodule_arr=[];
            Popupobj.aftershowInitValue(data);


            Popupobj.before_validate = function () {

                return true;
            }
            Popupobj.after_validate = function () {

                return true;
            }
            Popupobj.before_duplicate = function () {
                return true;
            }
            Popupobj.after_duplicate = function () {
                return true;
            }
            Popupobj.addOtherSaveUrl=function(){
                return '';
            }
            var oS = document.createElement('script');

            oS.src = global_js_url + "include/js/modules/" + module + "/Save.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            oS.onload = oS.onreadystatechange = function () {
                if (!this.readyState || this.readyState == 'loaded' || this.readyState == 'complete') {
                    Popupobj.showafter();//js加载完成

                    // 朗捷
                    // start  save.js加载完成后再执行,否则会因为异步导致报错
                    if(ld("#version_account").val() === 'langjie'){
                        //客服下单->报关单草单->报关类型与单据分录 设置字段隐藏
                        if(module == 'CustomForm22'){
                            HideDetail();
                        }
                        if(module =="CustomForm18" || module =="CustomForm19"){
                            // @edit:dong @date:2020/09/18 @reason: tapd ID1001112 朗捷费用单个性化开发
                            eval(module+"NotAllowEdit()");
                        }
                        // 客服下单->空运订单->编辑 设置只读
                        if(module == 'CustomForm24'){
                            setDetailReadOnly();
                        }
                        //客服下单->空运订单回传->空运订单回传单 单据分录不允许修改
                        if(module == 'CustomForm25'){
                            setDetailTableReadyOnly();
                        }
                    }
                    // end
                    //ZXM 2021-0713 0046845: （https://81mis.com/kfbcrm/ [^]）OA表单->费用预算单，单据编号：BUD42，填入了调整金额，但预算金额没有变。
                    if(module == 'ExpenseBudget'){
                        ExpenseBudgetObj.calculationBudget();
                    }
                    //@edit:liushuai,2020-8-12,reason:【ID1001000】（王耀文的客户）个性化开发
                    if(account_version == 'haochen' && module == 'Accounts'){ //新建，CreatePagePopup.js  showpage也需要该逻辑
                        PopupJqObj.find("[name=accountname]").on("input", function() {
                            var accountname = CrmPopup.getHtmlobjval(Popupobj.divid,'accountname');
                            var account_product_line = CrmPopup.getHtmlobjval(Popupobj.divid,'cf_2738');//客户产品线
                            PopupJqObj.find("[name=cf_2787]").val(trim(accountname)+trim(account_product_line));//客户全称(产品)
                        });
                    }
                }
            }
            // if (typeof Popupobj.selectproductobj != 'undefined')
            //   Popupobj.selectproductobj.showTooltipByTable();
            if(data.result.columnfields_value.approvestatus == '已批准'){ //BUG0069554 xxy 2023-7-24 审批流程定制，设置审批结束允许编辑单据时，已批准的单据编辑界面，去掉单据分录明细的“新增、复制、删除、导入明细、清空、重算”操作按钮
                Popupobj.approvestatus = data.result.columnfields_value.approvestatus;
                if(!empty(data.result.showproductbtn)){
                    Popupobj.showproductbtn = data.result.showproductbtn;
                }
                if(Popupobj.showproductbtn == 'no'){
                    PopupJqObj.find("table[class='ProductTabTotal']").remove();
                }
            }


            Popupobj.setTimeCount();
            // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
            tooltip(PopupJqObj.find(".tip-items-pop"), {transition: true, time: 200});
            return Popupobj;
        }
        else {
            Popupobj.CancelEvent();
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
        }

    })

}
PageRecordPopup.type = 'pagerecord';
PageRecordPopup.pagetype = "create_edit_modulepage"
PageRecordPopup.loadobj = function (headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText, record) {
    PageRecordPopup.prototype = new CrmPopup();

    PageRecordPopup.prototype.constructor = PageRecordPopup;
    PageRecordPopup.prototype.refreshpage = 'yes';
    PageRecordPopup.prototype.type = PageRecordPopup.type;
    PageRecordPopup.prototype.fieldname = "";
    PageRecordPopup.prototype.fieldlabel = "";
    PageRecordPopup.prototype.fielddatatype = "";
    PageRecordPopup.prototype.fields = "";
    PageRecordPopup.prototype.picklistdepency = [];
    PageRecordPopup.prototype.record = record;
    PageRecordPopup.prototype.filejsondata = [];//附件
    PageRecordPopup.prototype.detailfilejsondata = [];//分录图片
    PageRecordPopup.prototype.isadmin = "";
    PageRecordPopup.prototype.tablerelfields = "";

    PageRecordPopup.prototype.columnfields_value = "";//获取$focus->column_fields的值
    var Popupobj = new PageRecordPopup();
    Popupobj.pagetype = PageRecordPopup.pagetype;
    cssWidth=PageRecordPopup.getWidth();//wym BUG0077320 编辑页变成全屏了 所以不用输入的csswidth了
    if(cssWidth != CrmPopup.getClientWidth()){
        Popupobj.fullscreen = 'no';
    }
    Popupobj.setParams(headtitle, SaveDataRecord.save, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText);

    return Popupobj;

}

//headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText
PageRecordPopup.load = function (module) {
    PageRecordPopup.prototype = new CrmPopup();
    PageRecordPopup.prototype.constructor = PageRecordPopup;
    PageRecordPopup.prototype.type = PageRecordPopup.type;
    PageRecordPopup.prototype.fieldname = [];
    PageRecordPopup.prototype.fieldlabel = [];
    PageRecordPopup.prototype.fielddatatype = [];
    PageRecordPopup.prototype.fields = [];//获取界面所有字段信息
    PageRecordPopup.prototype.module = module;
    var PageRecordPopupobj = new PageRecordPopup();
    PageRecordPopupobj.divid = "div_pagerecord";
    CrmPopup.global_listPopupObj.push(PageRecordPopupobj);
    // PageRecordPopup.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return PageRecordPopupobj;

}

PageRecordPopup.moduleEditFun = {
    PricePolicy: function () {
        AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
        PricePolicy.getInstance().getEditInstance().moduleEdit();
    },
    //产品属性模块
    ProductProperty: function () {
        AjaxJSPage('ProductProperty', 'include/js/modules/ProductProperty/ProductProperty.js');
        //ProductProperty.moduleEdit();
    },
    //产品编辑页面的产品属性信息
    Products: function () {
        AjaxJSPage('ProductsEdit', 'include/js/modules/Products/ProductsEdit.js');
        ProductsEdit.moduleEdit();
    }
}

PageRecordPopup.moduleEditDetail = {
    Products: function () {
        try {
            AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
            PricePolicy.getInstance().getUseInstance().showBlock();

            // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
            AjaxJSPage('ProductPropertyGroup', 'include/js/modules/ProductProperty/ProductPropertyGroup.js');
        }
        catch (e) {
            console.log(e);
        }
    },
}

PageRecordPopup.moduleEdit = function (popupObj) {
    var module = popupObj.module,
        detailModule = popupObj.detailfieldmodule,
        moduleEdit = PageRecordPopup.moduleEditFun[module],
        moduleEditDetail = PageRecordPopup.moduleEditDetail[detailModule];
    if(typeof moduleEdit === "function") {
        moduleEdit();
    }
    if(typeof moduleEditDetail === "function") {
        moduleEditDetail();
    }
}
 