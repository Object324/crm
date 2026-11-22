function cls_StepConditionSet(flowstepid,approvestepflowobj)
{
    
    //步骤条件
    var that=this;
    this.flowstepid=flowstepid;
    this.approvestepflowobj=approvestepflowobj;
   
    this.parentflowstepindex= approvestepflowobj.getparentflowstepindex(this.flowstepid);//获取父节点索引
    this.flowstepindex=approvestepflowobj.getFlowStepIndex(this.flowstepid);//获取当前节点索引
    this.curstepinfo=approvestepflowobj.stepflow_arr[this.flowstepindex];
    this.parentflowstepinfo=approvestepflowobj.stepflow_arr[this.parentflowstepindex];
    this.stepid=this.curstepinfo.id;
     
    this.show=function(){

         this.popupobj=CrmPopup.load(this.curstepinfo.stepname,this.save,"",parseInt(850),this.tabid,"","","","");
         this.popupobj.position=CrmPopup.Positions.right;
         this.popupobj.setButtonPosition('right');
         this.popupobj.setHeight(CrmPopup.getClientHeight());
         this.popupobj.popupMaxHeight=(CrmPopup.getClientHeight())
         this.popupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
         this.popupobj.prevshow();
         var stepid=that.stepid;
         if(that.curstepinfo.stepinfo.edit!=undefined){
            stepid=0;

         }
        var param={stepname:that.curstepinfo.stepname, "tabid":newApproveSetObj.tabid,'flowstepid':that.flowstepid
                ,'stepid':stepid,'childids':that.parentflowstepinfo.childid};
            if(that.curstepinfo.stepinfo.edit!=undefined)
            {
                //如果条件查询不为空
                param['advancesearch']=JSON.stringify(that.curstepinfo.stepinfo.advancesearch);
                param['groupcondition']=JSON.stringify(that.curstepinfo.stepinfo.groupcondition);
            }

         this.popupobj.advanceSearchDivid=this.popupobj.divid;
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=newApproveStepAdv&approveid="+newApproveSetObj.approveid
                ,param,function(ajaxdata){
                that.ajaxdata=ajaxdata;
               
                that.popupobj.setOkText(ajaxdata.result.oktext);
                that.popupobj.setCancelText(ajaxdata.result.canceltext);
               CrmPopup.setPopupobjHtmlscrolljquery_noposition(that.popupobj,that.ajaxdata.result.content);

                var advancefilterobj = new cls_advanceFilter();
                that.advancefilterobj = advancefilterobj;
                var params = {};
                params.columnOptionHtml = ajaxdata.result.columns_block;
                params.fLabels = ajaxdata.result.fLabels;
                params.datetimestr = ajaxdata.result.datetimestr;
                params.advfilterhtml = ajaxdata.result.foption;
                // params.fieldsinfo = data.result.fieldinfo;
                params.criteria_groups_arr = ajaxdata.result.criteria_groups_arr;
                params.module =  ajaxdata.result.module;
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = ajaxdata.result.advanceFields;
                params.makePopupCenter = 'no';
                advancefilterobj.showAdvanceFilter(that.popupobj,params);

                //wym 240112 XUQIU1001873 把高级查找的标题和按钮放在同一行
                var titlecontent = '<th class="ld-from-headblock" colspan="4" style="padding: 8px"><div class="ld-from-headblock-title">'+arrJsPopLabel['ConditionSetting']+'</div></th>';
                var tableobj = ld("#"+that.popupobj.divid+" [name=pop_adv_filter_div]").children('table');
                ld(tableobj).removeClass('settingPopTable');
                ld(titlecontent).prependTo(tableobj.find('tr'));
                if(tableobj.find('tr th').length > 1){
                    tableobj.find('tr th.ld-from-headblock').html('<div class="ld-from-headblock-title">'+arrJsPopLabel['ConditionSetting']+'<input type="button" class="ld-button" value="'+arrJsPopLabel['NEWCOMBINATION']+'" onclick="New_addNewConditionGroup(\'pop_adv_filter_div\');" style="margin-right: 15px;float: right;"></div>');
                    tableobj.find('tr th').eq(1).remove();
                }
            ld("#"+that.popupobj.divid+" [name=pop_adv_filter_div]").css("max-height",ld("#"+this.popupobj.divid).css("height"))
            that.setConditionEvent();
        })
    }
 
    this.save=function(){
        var popupobj=CrmPopup.getPopupObj('last'); 
        var stepname=ld("#"+popupobj.divid+" [name=stepname]").val();
      
        if(ld.trim(stepname)=='')
        {

            var confirm_str = arrJsPopLabel['STEPNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            ld("#"+that.divid+" [name=stepname]").focus();
            return false;
        }
        
        if(!that.advancefilterobj.checkAdvancedFilter()) return false;
         
        var advft_criteria = popupobj.advft_criteria;//$('advft_criteria').value;
        var advft_criteria_groups = popupobj.advft_criteria_groups;//$('advft_criteria_groups').value;
        //访问后台获取高级查询文本
        if(advft_criteria!=undefined){
            var surl = 'index.php?module=Approve&action=ApproveAjax&file=ApproveAdvft';
            var param = {'advft_criteria':advft_criteria,'advft_criteria_groups':advft_criteria_groups,'frommodule':that.approvestepflowobj.module};
            ldAjaxNoProgress(surl,param,function(data){
                if(data.code == 1){
                    that.advftlabel = data.result.advftlabel;
                    that.after_validate();
                }
            });
        }else{
            that.after_validate();
        }
               
    }
    
    this.after_validate = function(){
        var popupobj=CrmPopup.getPopupObj('last'); 
        var stepname=ld("#"+popupobj.divid+" [name=stepname]").val();
        
        var advft_criteria = popupobj.advft_criteria;//$('advft_criteria').value;
        var advft_criteria_groups = popupobj.advft_criteria_groups;//$('advft_criteria_groups').value;
       var value_arr={};
       if(advft_criteria!=undefined)
        {
            value_arr['advancesearch']=ld.parseJSON(advft_criteria);
            value_arr['groupcondition']=ld.parseJSON(advft_criteria_groups);
            value_arr['advftlabel']=that.advftlabel;
        }
        else{
              value_arr['advancesearch']='';
            value_arr['groupcondition']='';
        }
        value_arr['stepname']=stepname;
       //console.log( that.value_arr['advancesearch']);
     //console.log(that.value_arr['groupcondition']);
      value_arr['edit']='yes';//表示已经编辑过，不需要再从数据库获取数据
       var priorityindex=ld("#"+that.popupobj.divid+" [name=priority]").val();//修改到的优先级
       var childid_arr=that.parentflowstepinfo.childid.split(",");
       var curpriorityindex=childid_arr.indexOf(that.curstepinfo.flowstepid);//当前节点优先级
     
         popupobj.CancelEvent();
       if(curpriorityindex!=priorityindex)
       {
            //改变了优先级
          
          var changeflowstepid=childid_arr[priorityindex];
          var changeflowstepindex=that.approvestepflowobj.getFlowStepIndex(changeflowstepid);
          childid_arr[priorityindex]=that.curstepinfo.flowstepid;

          childid_arr[curpriorityindex]=changeflowstepid;
           
          that.approvestepflowobj.stepflow_arr[that.parentflowstepindex].childid=childid_arr.join(",");
          that.approvestepflowobj.stepflow_arr[that.flowstepindex]=that.approvestepflowobj.stepflow_arr[changeflowstepindex];
          that.approvestepflowobj.stepflow_arr[changeflowstepindex]=that.curstepinfo;
          that.approvestepflowobj.stepflow_arr[changeflowstepindex].stepname=stepname;
         that.approvestepflowobj.stepflow_arr[changeflowstepindex].stepinfo=value_arr;

       }
       else{
        that.approvestepflowobj.stepflow_arr[that.flowstepindex].stepname=stepname;
       that.approvestepflowobj.stepflow_arr[that.flowstepindex].stepinfo=value_arr;
       }
       console.log(that.approvestepflowobj.stepflow_arr[that.flowstepindex]);
       that.approvestepflowobj.innerNodeHtml();
    }
    this.setConditionEvent=function(){

       
    }
    
}