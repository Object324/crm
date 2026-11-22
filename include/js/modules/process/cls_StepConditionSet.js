function cls_StepConditionSet(nodeid,approvestepflowobj)
{
    
    //步骤条件
    var that=this;
    this.nodeid=nodeid;
    this.approvestepflowobj=approvestepflowobj;
   
    this.parentflowstepindex= approvestepflowobj.getparentflowstepindex(this.nodeid);//获取父节点索引
    this.flowstepindex=approvestepflowobj.getFlowStepIndex(this.nodeid);//获取当前节点索引
    this.curstepinfo=approvestepflowobj.stepflow_arr[this.flowstepindex];
    this.parentflowstepinfo=approvestepflowobj.stepflow_arr[this.parentflowstepindex];
    this.stepid=this.curstepinfo.id;
     
    this.show=function(){

         this.popupobj=CrmPopup.load(this.curstepinfo.nodename,this.save,"",parseInt(850),this.module,"","","","");
         this.popupobj.position=CrmPopup.Positions.right;
         this.popupobj.setButtonPosition('right');
         this.popupobj.setHeight(CrmPopup.getClientHeight());
         this.popupobj.popupMaxHeight=(CrmPopup.getClientHeight())
         this.popupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
         this.popupobj.prevshow();
         var stepid=that.stepid;
         if(that.curstepinfo.nodeinfo.edit!=undefined){
            stepid=0;

         }
        var param={'nodename':that.curstepinfo.nodename, "tabid":0,'nodeid':that.nodeid,'modulename':this.approvestepflowobj.module
                ,'stepid':stepid,'childids':that.parentflowstepinfo.childid};
            if(that.curstepinfo.nodeinfo.edit!=undefined)
            {
                //如果条件查询不为空
                param['advancesearch']=JSON.stringify(that.curstepinfo.nodeinfo.advancesearch);
                param['groupcondition']=JSON.stringify(that.curstepinfo.nodeinfo.groupcondition);
            }

         this.popupobj.advanceSearchDivid=this.popupobj.divid;
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=ProcessAdvanceSet&"
                ,param,function(ajaxdata){
                that.ajaxdata=ajaxdata;
                that.popupobj.setOkText(ajaxdata.result.oktext);
                that.popupobj.setCancelText(ajaxdata.result.canceltext);
               CrmPopup.setPopupobjHtmlscrolljquery_noposition(that.popupobj,that.ajaxdata.result.content);
             
            ld("#"+that.popupobj.divid+" [name=pop_adv_filter_div]").css("max-height",ld("#"+this.popupobj.divid).css("height"))
            that.setConditionEvent();
        })
    }
 
    this.save=function(){
        var popupobj=CrmPopup.getPopupObj('last'); 
        var nodename=ld("#"+popupobj.divid+" [name=nodename]").val();
      
        if(ld.trim(nodename)=='')
        {

            var confirm_str = arrJsPopLabel['STEPNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            ld("#"+that.divid+" [name=nodename]").focus();
            return false;
        }
        
        if(!New_checkAdvancedFilter()) return false;
         
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
        var nodename=ld("#"+popupobj.divid+" [name=nodename]").val();
        
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
        value_arr['nodename']=nodename;
       //console.log( that.value_arr['advancesearch']);
     //console.log(that.value_arr['groupcondition']);
      value_arr['edit']='yes';//表示已经编辑过，不需要再从数据库获取数据
       var priorityindex=ld("#"+that.popupobj.divid+" [name=priority]").val();//修改到的优先级
       var childid_arr=that.parentflowstepinfo.childid.split(",");
       var curpriorityindex=childid_arr.indexOf(that.curstepinfo.nodeid);//当前节点优先级
     
         popupobj.CancelEvent();
       if(curpriorityindex!=priorityindex)
       {
            //改变了优先级
          
          var changenodeid=childid_arr[priorityindex];
          var changeflowstepindex=that.approvestepflowobj.getFlowStepIndex(changenodeid);
          childid_arr[priorityindex]=that.curstepinfo.nodeid;

          childid_arr[curpriorityindex]=changenodeid;
           
          that.approvestepflowobj.stepflow_arr[that.parentflowstepindex].childid=childid_arr.join(",");
          that.approvestepflowobj.stepflow_arr[that.flowstepindex]=that.approvestepflowobj.stepflow_arr[changeflowstepindex];
          that.approvestepflowobj.stepflow_arr[changeflowstepindex]=that.curstepinfo;
          that.approvestepflowobj.stepflow_arr[changeflowstepindex].nodename=nodename;
         that.approvestepflowobj.stepflow_arr[changeflowstepindex].nodeinfo=value_arr;

       }
       else{
        that.approvestepflowobj.stepflow_arr[that.flowstepindex].nodename=nodename;
       that.approvestepflowobj.stepflow_arr[that.flowstepindex].nodeinfo=value_arr;
       }
       console.log(that.approvestepflowobj.stepflow_arr[that.flowstepindex]);
       that.approvestepflowobj.innerNodeHtml();
    }
    this.setConditionEvent=function(){

       
    }
    
}