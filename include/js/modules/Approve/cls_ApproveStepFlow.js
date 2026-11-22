function cls_ApproveStepFlow()
{
    //说明：childid 表示该节点有哪些子 节点，branchstepid：表示该节点的所属分支ID branchstepid:主要用户分支流程使用
    //设置父节点的目的是用于判断虚拟节点的所属分支
    var that=this;
    this.stepflowhtml='';
    this.laststepindex=0;
    this.stepflow_arr=[];
    this.label_arr=[];
    //this.conditionlabelindex=1;
    this.maxflowstepid=0;
    this.clickbtnmenuobj;//点击弹出菜单按钮的 圆圈按钮对象 或者点击黄色框审批步骤
    this.conditionvirtual='conditionvirtual';
    this.editprofile = 'yes';
    that.module='';
    this.show=function(){
        
        if(that.stepflowhtml=='')
        {
                var approveid=newApproveSetObj.approveid;
        }
        else
        {
            var approveid=0;
        }
         
       ldAjax("index.php?module=Settings&action=SettingsAjax&file=newApproveStepFlow&approveid="+approveid+"&frommodule="+newApproveSetObj.module,{},function(ajaxdata){
               DelProgressObjs();
                ld("#"+newApproveSetObj.popupobj.divid+"_scroll").html(ajaxdata.result.content);
                 that.label_arr=ajaxdata.result.label;
               that.module=newApproveSetObj.module;
               
               if(that.stepflowhtml=='')
                {
                    that.stepflow_arr=ajaxdata.result.stepflowlist;
                    that.getMaxStepid();
                }

                that.innerNodeHtml();
               
             })
           
           
        
    }
    this.innerNodeHtml=function(){
        
                     
        that.stepflowhtml='';
        //console.log(that.stepflow_arr);
         that.createhtml(-1,that.stepflow_arr);
       
        that.stepflowhtml+=that.endhtml();//审批结束
       
        
        ld("#"+newApproveSetObj.popupobj.divid+" [name=nodelist]").html(that.stepflowhtml);
        ld("#"+newApproveSetObj.popupobj.divid).css("height",CrmPopup.getClientHeight());
        ld("#"+newApproveSetObj.popupobj.divid+"_scroll").css("height","100%");
        newApproveSetObj.popupobj.center();
        that.setEvent();
    }
    this.getMaxStepid=function(){

        for(var i=0;i<that.stepflow_arr.length;i++)
        {
            if(parseInt(that.stepflow_arr[i].flowstepid)>this.maxflowstepid)
            {
                this.maxflowstepid=parseInt(that.stepflow_arr[i].flowstepid);

            }
        }
        
    }
     
  //根据菜单主键id生成菜单列表html
    //id：菜单childid
    //arry：菜单数组信息
    this.createhtml=function(childid, arry) {
        
        if(childid==''||childid==',')
        return '';
        var childArry = this.GetChildArry(childid, arry);
       
        if (childArry.length > 0) {
         
            
            var len=childArry.length;
            if(childArry[0].steptype=='condition')
            {
                //添加条件
                this.stepflowhtml+='<div class="branch-wrap">'+
                '<div class="branch-box-wrap">'+
                    '<div class="branch-box">'+
                        '<button class="add-branch" name="btn_addcondition" flowstepid='+childArry[0].flowstepid+'>'+this.label_arr.addcondition+'</button>'
            }
           
            
            for (var i=0;i<len;i++) {
                 
                
                if(childArry[i].steptype=='start')
                {
                    this.stepflowhtml+=this.starthtml(childArry[i]);
                    
                }
                else if(childArry[i].steptype=='approver')
                {
                    this.stepflowhtml+=this.approvehtml(childArry[i]);
                }
                else if(childArry[i].steptype=='condition')
                {
                   
                    
                     if(i==0)
                        this.stepflowhtml+=this.conditionhtml(childArry[i],'left');
                     else if(i==len-1)
                        this.stepflowhtml+=this.conditionhtml(childArry[i],'right');
                     else
                        this.stepflowhtml+=this.conditionhtml(childArry[i],'middle');
                }
              
              
                 
                this.createhtml(childArry[i].childid, arry);
                if(childArry[i].steptype=='condition')
                {
                    this.stepflowhtml+="</div>"
                }
            }
            
            if(childArry[0].steptype=='condition')
            {
               
                this.stepflowhtml+='</div>';
                //获取条件节点虚拟节点
                  
               var virtualstepindex= that.getVirtualStepindex(childArry[0].branchstepid);
       
                this.stepflowhtml+=this.addconditionnodehtml(that.stepflow_arr[virtualstepindex]);
                this.createhtml(that.stepflow_arr[virtualstepindex].childid, arry);
                this.stepflowhtml+='</div></div>';
            }
            
        }
    }
    this.virtualstepindex=0;
     this.getVirtualStepindex=function(flowstepid)
     {
        //获取子节点的虚拟节点
        
      
        ld.each(that.stepflow_arr,function(tmpindex,tmpstepinfo){
            if(tmpstepinfo.branchstepid==flowstepid&&tmpstepinfo.steptype==that.conditionvirtual)
            {
                 that.virtualstepindex=tmpindex
                 return false;
                
                
            }
            
        })
        return that.virtualstepindex;
        
        
     } 
    //根据菜单主键id获取下级菜单
    //childflowstepid：菜单主键id
    //arry：菜单数组信息
    this.GetChildArry=function(childflowstepid, arry) {
        childflowstepid=childflowstepid+"";
         var newArry = childflowstepid.split(",");
         var newlen=newArry.length;
		 var tmparr=[];
         var otherarr = {};

        for (var i in arry) {
				
             if(arry[i].steptype==this.conditionvirtual)
                    continue;//虚拟节点
			if(newArry.includes(arry[i].flowstepid+""))
			{
                otherarr[arry[i].flowstepid] = arry[i];
                if(newlen==1)
                {
                    //只有一个子节点
                    break;
                }
			}   
        }
        //将获取到的子步骤信息重新排序
        for (var j=0;j<newlen;j++){
            if(!empty(otherarr[newArry[j]])){
                tmparr.push(otherarr[newArry[j]]);
            }
        }
        return tmparr;
    }
	//duan 20230809 复制时获取子节点应该需要包括虚拟节点
    this.GetChildArryWithvirtual=function(childflowstepid, arry) {
        childflowstepid=childflowstepid+"";
        var newArry = childflowstepid.split(",");
        var newlen=newArry.length;
        var tmparr=[];
        var otherarr = {};

        for (var i in arry) {

            if(newArry.includes(arry[i].flowstepid+""))
            {
                otherarr[arry[i].flowstepid] = arry[i];
                if(newlen==1)
                {
                    //只有一个子节点
                    break;
                }
            }
        }
        //将获取到的子步骤信息重新排序
        for (var j=0;j<newlen;j++){
            if(!empty(otherarr[newArry[j]])){
                tmparr.push(otherarr[newArry[j]]);
            }
        }
        return tmparr;
    }
    this.starthtml=function(stepinfo){
        
        return ' <div class="node-wrap">'+
        
        '<div class="node-wrap-box node_sid-startevent start-node">'+
                    '<div>'+
                        '<div class="title" style="background:var(--ld-bg-list-head-color);">'+
                            '<span class="">' + arrJsPopLabel['LBL_START'] + '</span>'+
                        '</div>'+
                        '<div class="content">'+
                            '<div class="text">'+newApproveSetObj.approvedatainfo_arr.name+'</div>'+
                            '<span class="jiantou jiantou_right" style="display:none"></span>'+
                        '</div>'+
                    '</div>'+
                '</div>'+
                 '<div class="add-node-btn-box">'+
                    '<div class="add-node-btn">'+
                        '<button id="start" class="btn" type="button" name="btn_addmenu" flowstepid=-1 childid="'+stepinfo.childid+'">'+
                            '<span class="iconfont"></span>'+
                        '</button>'+
                    '</div>'+
                '</div>'
    }
    
    this.approvehtml=function(stepinfo){
        //if(this.approverhtmlobj==undefined)
        
        // getScriptBackWithURL('include/js/modules/Approve/cls_ApproverHtml.js',function(){
            //同步加载
       var  obj=new cls_ApproverHtml();
           
      //  });
        
        obj.setStepInfo(stepinfo)

        return obj.gethtml();
         
    }
   
   this.conditionhtml=function(stepinfo,htmltype)
   {
        //if(this.conditionhtmlobj==undefined)
        
        // getScriptBackWithURL('include/js/modules/Approve/cls_ConditionHtml.js',function(){
            //同步加载
            var obj=new cls_ConditionHtml();
           
       // });
        obj.setStepInfo(stepinfo);
        
        return obj.gethtml(htmltype);
   }
  
  this.addconditionnodehtml=function(stepinfo){
    //虚拟节点
    return '<div class="add-node-btn-box">'+
    '<div class="add-node-btn"><button class="btn" type="button" value="虚拟节点'+stepinfo.flowstepid+'" name="btn_addmenu" childid="'+stepinfo.childid+'" flowstepid="'+stepinfo.flowstepid+'">'+
    '<span class="iconfont"></span></button></div><div></div></div>';
  }
    this.endhtml=function(){
        //流程结束
        return '<div class="end-node">'+
                '<div class="end-node-circle"></div>'+
                '<div class="end-node-text">'+this.label_arr.endflow+'</div>'+
            '</div>'
    }
   
   
 
  
   this.getFlowStepIndex=function(flowstepid)
   {    
        //获取指定节点索引
    
            var childindex='';
             ld.each(that.stepflow_arr,function(tmpindex,tmpinfo){
                if(tmpinfo.flowstepid==flowstepid)
                {
                    childid=tmpinfo.childid;
                     childindex=tmpindex
                    return false;
                }
         })
         
         return childindex;
   }
   this.branchchild_arr=[];
   this.lastbranchchildindex=-1;
   this.getBranchChild=function(clickflowstepindex,parentvirtualstepinfo)
   {
        //获取指定节点的子节点包括儿子 ，孙子，重孙 等等 子子孙孙
         that.lastbranchchildindex=-1;
         that.branchchild_arr=[];
       

        that.reCyclegetBranchChild(that.stepflow_arr[clickflowstepindex].childid,parentvirtualstepinfo);

   }
   this.reCyclegetBranchChild=function(childidflowstepid,parentvirtualstepinfo){

         var childid_arr= that.GetChildArryWithvirtual(childidflowstepid,that.stepflow_arr);
        
         for(var i=0;i<childid_arr.length;i++)
         {
            
            if(childid_arr[i].flowstepid==parentvirtualstepinfo.flowstepid)
            {
                return ;
            }
            else{
                this.branchchild_arr.push(childid_arr[i]);
                that.reCyclegetBranchChild(childid_arr[i].childid,parentvirtualstepinfo);
            }
         }
   }
   

   this.getBranchLastChildStepIndex=function(clickflowstepid,branchstepid)
   {
     //表示点击的节点
        //获取分支节点最后一个子节点 所在的索引
            
            that.lastbranchchildindex=-1;
             var havebranchstep='no';
            for(var i=that.stepflow_arr.length-1;i>=0;i--)
            {
                if(that.stepflow_arr[i].branchstepid==branchstepid)
                {
                    havebranchstep='yes';
                    if(that.stepflow_arr[i].steptype==that.conditionvirtual)
                    {
                        //虚拟节点
                        
                       var findflowstepid= that.reCyclegetlastVirtualChildBranchIndex(that.stepflow_arr[i].flowstepid,that.stepflow_arr[i].flowstepid);
                        that.lastbranchchildindex=that.getFlowStepIndex(findflowstepid);
                        break;
                    }
                     
                   
                }
            }

            if(that.lastbranchchildindex==-1&&havebranchstep=='yes')
            {
                //表示分支没有虚拟节点
                var flowstepindex=that.getFlowStepIndex(clickflowstepid);

               var findflowstepid= that.reCyclegetlastChildBranchflowStepid(clickflowstepid,that.stepflow_arr[flowstepindex].childid,branchstepid);
             
               that.lastbranchchildindex=that.getFlowStepIndex(findflowstepid);
            }
            else if(havebranchstep=='yes'){
             
               var findflowstepid= that.reCyclegetlastChildBranchflowStepid(findflowstepid,that.stepflow_arr[that.lastbranchchildindex].childid,findflowstepid);
             
               that.lastbranchchildindex=that.getFlowStepIndex(findflowstepid);
            }
         
         
         return that.lastbranchchildindex;
        
   }
   this.reCyclegetlastVirtualChildBranchIndex=function(flowstepid,branchstepid)
   {
        var isfind='no';
        for(var i=that.stepflow_arr.length-1;i>=0;i--)
        {
            if(that.stepflow_arr[i].branchstepid==branchstepid)
            {
               
                if(that.stepflow_arr[i].steptype==that.conditionvirtual)
                {
                    //虚拟节点
                     isfind='yes';
                    return   that.reCyclegetlastVirtualChildBranchIndex(that.stepflow_arr[i].flowstepid,that.stepflow_arr[i].flowstepid);
                    
                }
               
            }
        }
        if(isfind=='no')
        {
            return flowstepid;
        }

   }
   this.reCyclegetlastChildBranchflowStepid=function(flowstepid,childflowstepid,branchstepid){

        var childid_arr= that.GetChildArry(childflowstepid,that.stepflow_arr);

      
        if(childid_arr.length>0)
        {
            for(var i=0;i<childid_arr.length;i++)
            {
                    if(childid_arr[i].branchstepid!=branchstepid)
                    {
                            return flowstepid;
                    }
                    else{
                        
                       return  that.reCyclegetlastChildBranchflowStepid(childid_arr[i].flowstepid,childid_arr[i].childid,branchstepid); 
                    }
            }
        }
        else{
                return flowstepid;
        }
   }
   //获取分支节点的虚拟节点
   this.getbranchlastvirtualnode=function(branchstepid)
   {

            var lastbranchchildindex=-1;
            for(var i=that.stepflow_arr.length-1;i>=0;i--)
            {
                if(that.stepflow_arr[i].branchstepid==branchstepid&&that.stepflow_arr[i].steptype==that.conditionvirtual)
                {
                    lastbranchchildindex=i;
                    break;
                }
            }
         
         
         return  lastbranchchildindex;
   }
   this.changebranchstepid=function(oldstepid,newstepid,menutype){
        //修改节点所属分支节点
        //menutype:点击的添加条件分支还是点击的添加审批人
        ld.each(that.stepflow_arr,function(tmpindex,tmpstepinfo){
            if(tmpstepinfo.branchstepid==oldstepid)
            {
                if(menutype=='approver'&&that.stepflow_arr[tmpindex].steptype==that.conditionvirtual)
                {
                    //如果添加的审批则不需要修改虚拟的节点的parentstepid
                }
                else if(that.stepflow_arr[tmpindex].steptype=='start')
                {

                }
                else
                    that.stepflow_arr[tmpindex].branchstepid=newstepid
            }
            
        })
   }
    that.changechildId=function(flowstepid,newchildid)
   {
    
        var childid='';
        var tmparr=[];
         ld.each(that.stepflow_arr,function(tmpindex,tmpinfo){
            if(tmpinfo.flowstepid==flowstepid)
            {
                childid=tmpinfo.childid;
                that.stepflow_arr[tmpindex].childid=newchildid;
                return false;
            }
         })
       
        
   }
  
    this.setEvent=function(){
        
        
         var btn_addapproverobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_addapprover]");//添加审批按钮
         ld(btn_addapproverobj).unbind("click").bind("click",function(){
            //添加审批人
                that.maxflowstepid++;
                
                var flowstepid=ld(that.clickbtnmenuobj).attr("flowstepid");
                var childid=ld(that.clickbtnmenuobj).attr("childid");
                that.changechildId(flowstepid,that.maxflowstepid+"");//修改当前节点的子节点为审批人节点
                var branchstepid=flowstepid;
                var curstepindex=that.getFlowStepIndex(flowstepid);//获取点击节点的索引
                if(that.stepflow_arr[curstepindex].steptype=='approver')
                {
                    branchstepid=that.stepflow_arr[curstepindex].branchstepid;
                }
                var stepinfo={"id":'', 'flowstepid':that.maxflowstepid+"",'stepname':arrJsPopLabel['APPROVALSTEP']+that.maxflowstepid,steptype:'approver','childid':childid+"",
                'branchstepid':branchstepid,'stepinfo':[]};
                stepinfo['stepinfo'].stepname=stepinfo.stepname;
                that.stepflow_arr.push(stepinfo);
                
                
                ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").css("display",'none')
                that.innerNodeHtml();
             
         })
         
         var btn_addconditionbranchobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_addconditionbranch]");//添加条件分支按钮
         ld(btn_addconditionbranchobj).unbind("click").bind("click",function(){
            //添加条件分支
           
            var flowstepid=ld(that.clickbtnmenuobj).attr("flowstepid");
            var curstepindex=that.getFlowStepIndex(flowstepid);//获取点击节点的索引
            var curflowstepinfo=that.stepflow_arr[curstepindex];
            
            var curchildstepid=curflowstepinfo.childid;

            if(that.stepflow_arr[curstepindex].steptype=='approver')
            {
                 var lastchildstepindex=that.getBranchLastChildStepIndex(flowstepid,curflowstepinfo.branchstepid);//获取分支节点的最后一个节点索引
            }
            else
                 var lastchildstepindex=that.getBranchLastChildStepIndex(flowstepid,flowstepid);//获取分支节点的最后一个节点索引
        
             var  flowvirtualstepid= that.maxflowstepid+3;//虚拟节点
             flowvirtualstepid+="";
            var branchstepid=flowstepid;//点击虚拟节点，或条件步骤 或开始步骤
            if(curflowstepinfo.steptype=='approver')//点击审批人
            {
                branchstepid=curflowstepinfo.branchstepid;
            }

             var flowstepid_1=that.maxflowstepid+1;
             var flowstepinfo_1={'id':'', 'flowstepid':flowstepid_1+"",'stepname':"条件"+flowstepid_1,steptype:'condition','childid':flowvirtualstepid,
             'branchstepid':branchstepid,'stepinfo':[]};
              flowstepinfo_1['stepinfo'].stepname=flowstepinfo_1.stepname;
             var flowstepid_2=that.maxflowstepid+2;
             var flowstepinfo_2={'id':'', 'flowstepid':flowstepid_2+"",'stepname':"条件"+flowstepid_2,steptype:'condition','childid':flowvirtualstepid,
             'branchstepid':branchstepid,'stepinfo':[]};
              flowstepinfo_2['stepinfo'].stepname=flowstepinfo_2.stepname;
           var  flowvirtualstepinfo={'id':'','flowstepid':flowvirtualstepid+"",'stepname':"虚拟节点"+flowvirtualstepid,steptype:that.conditionvirtual,'childid':"",
            'branchstepid':branchstepid};
               
               //改变当前节点的子节点为条件1 和条件2
             that.changechildId(flowstepid,flowstepid_1+","+flowstepid_2);
            
             if(lastchildstepindex<=0||lastchildstepindex==curstepindex)
             {
                flowvirtualstepinfo.childid=curchildstepid;//修改虚拟节点的子节点为当前节点的子节点
                that.stepflow_arr.push(flowstepinfo_1);
                that.stepflow_arr.push(flowstepinfo_2);
                that.stepflow_arr.push(flowvirtualstepinfo);
             }
             
             else{
                
                 var lastchildstepinfo=that.stepflow_arr[lastchildstepindex];
            
                var lastchildstepid= lastchildstepinfo.flowstepid
                
                  //修改条件节点所属分支节点，为条件1
                  
                  if(curflowstepinfo.steptype=='approver')//点击审批人添加条件分支
                    that.changebranchstepid(curflowstepinfo.branchstepid,flowstepid_1,'condition');
                  else if(curflowstepinfo.steptype=='condition'||curflowstepinfo.steptype==that.conditionvirtual
                  ||curflowstepinfo.steptype=='start')//点击虚拟节点，或条件步骤
                    that.changebranchstepid(flowstepid,flowstepid_1,'condition');
                   
                  that.stepflow_arr.push(flowstepinfo_1);
                  that.stepflow_arr.push(flowstepinfo_2);
                  //虚拟节点
                if(lastchildstepinfo.steptype!=that.conditionvirtual|| lastchildstepindex!=curstepindex+1)
                    that.changechildId(flowstepid_1,curchildstepid);//条件1的子节点修改为当前节点
                 
                 that.stepflow_arr.push(flowvirtualstepinfo);
                
                  if(lastchildstepinfo.childid==''||lastchildstepinfo.childid==',')
                  {
                     that.changechildId(lastchildstepid,flowvirtualstepid);
                  }
                  else if(lastchildstepinfo.steptype=='approver')
                  {
                     that.changechildId(flowvirtualstepid,lastchildstepinfo.childid );//修改虚拟节点的子节点为审批人的子节点
                     //console.log(lastchildstepid);
                    // console.log(flowvirtualstepid);
                     that.changechildId(lastchildstepid,flowvirtualstepid); // 
                   
                  }
                  else //如果最后一个节点有子节点，则虚拟节点的子节点修改为当前条件流程最后一个节点
                  {
                    that.changechildId(flowvirtualstepid,lastchildstepinfo.childid );//修改虚拟节点的子节点为审批人的子节点
                    that.changechildId(lastchildstepid,flowvirtualstepid );
                  }
             }
           
            
              ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").css("display",'none')
              
              that.maxflowstepid=parseInt(flowvirtualstepid)
           
             that.innerNodeHtml();
             
             
            
         })
         
         var btn_addconditionobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_addcondition]");//添加条件
         ld(btn_addconditionobj).unbind("click").bind("click",function(){
                //添加新条件
                var flowstepid=ld(this).attr("flowstepid");//获取的是第一个条件flowstepid
                var flowstepindex=that.getFlowStepIndex(flowstepid);
                var flowstepinfo=that.stepflow_arr[flowstepindex];
                var parentflowstepindex=that.getparentflowstepindex(flowstepid);//获取父节点的索引
                that.maxflowstepid++;
                //console.log(that.stepflow_arr[parentflowstepindex]);
                
                //设置所属父节点 新增一个子节点iD
                var childid_arr=that.stepflow_arr[parentflowstepindex].childid.split(",");
                childid_arr.push(that.maxflowstepid);
                that.stepflow_arr[parentflowstepindex].childid=childid_arr.join(",");
                
                var  newflowstepinfo={};
                ld.each(flowstepinfo,function(key,value){
                    var type=typeof value
                    if(type.toLowerCase()!='object' )
                        newflowstepinfo[key]=value;
                    else
                    {
                        newflowstepinfo[key]={};
                    }
                })
                newflowstepinfo.flowstepid=that.maxflowstepid;
              //  newflowstepinfo.nodetype='new';
                //获取所属分支节点的最后一个节点
                var lastchildstepindex=that.getbranchlastvirtualnode(that.stepflow_arr[flowstepindex].branchstepid);//获取分支节点的虚拟节点的索引
                //console.log(that.stepflow_arr[lastchildstepindex])
                //获取子节点个数
                var childarr=that.GetChildArry(that.stepflow_arr[parentflowstepindex].childid,that.stepflow_arr);
                newflowstepinfo.stepname= "条件"+that.maxflowstepid//"条件"+childarr.length;
                newflowstepinfo['stepinfo'].stepname=newflowstepinfo.stepname;//条件步骤 设置
                newflowstepinfo.id='';

                newflowstepinfo.childid=that.stepflow_arr[lastchildstepindex].flowstepid;
                that.stepflow_arr.push(newflowstepinfo);
                
                that.innerNodeHtml();
         })
         //为流程界面绑定关闭选择框事件，实现点击选择弹框以外的地方都能关闭弹框
        ld("#"+newApproveSetObj.popupobj.divid+" [name=nodelist]").unbind('click').bind('click',function(){
            var dv_menuobj = ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]");
            if(dv_menuobj.attr('addmenu') == 'yes'){
                //判断点击添加时不需要隐藏弹框
                dv_menuobj.attr('addmenu','no');
            }else if(dv_menuobj.attr('addmenu') == 'no'){ 
                //弹框出现后，再次点击其他位置则关闭弹框
                dv_menuobj.hide();
                dv_menuobj.attr('addmenu','');
            }
        })
        var btn_addmenuobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_addmenu]");//弹出添加菜单 (圆圈按钮)
        ld(btn_addmenuobj).unbind("click").bind("click",function(){
            //添加
            that.clickbtnmenuobj=ld(this);
            var left=parseInt(ld(this).offset().left);
            var width=parseInt(ld(this).css('width'));
            var top=parseInt(ld(this).offset().top);

            var scrolltop=parseInt(ld("#"+newApproveSetObj.popupobj.divid+"_scroll").find(" .approveflow-design").scrollTop());
            var scrollleft=parseInt(ld("#"+newApproveSetObj.popupobj.divid+"_scroll").find(" .approveflow-design").scrollLeft());
            ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").find(" .ant-popover").css("left",(scrollleft+left+width+30)+"px")
            ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").find(" .ant-popover").css("top",(scrolltop+top-3)+"px")
            ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").show();
            ld("#"+newApproveSetObj.popupobj.divid+" [name=dv_menu]").attr('addmenu','yes');
            //ld("#"+newApproveSetObj.popupobj.divid+"_scroll").find(" .approveflow-design").scrollTop(parseInt(ld("#"+newApproveSetObj.popupobj.divid).css("height")))
         })
        ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_copy]").unbind("click").bind("click",function(){
            //拷贝流程步骤
            var flowstepid=ld(this).attr('flowstepid');
            var flowstepindex=that.getFlowStepIndex(flowstepid);
            var parentflowstepindex= that.getparentflowstepindex(flowstepid);
            //duan 20231130 此处获取分支最下层的虚拟节点id,应该用复制节点所在的分支id:flowstepindex ,原来是用父节点所在的分支id:parentflowstepindex
            var parentvirtualnodeindex=that.getbranchlastvirtualnode(that.stepflow_arr[flowstepindex].branchstepid);

            if(parentvirtualnodeindex==-1) {
                //没有虚拟节点
                //flowstepid,childflowstepid,branchstepid
                //获取最后一代节点的flowstepid
               var lastflowstepid= that.reCyclegetlastChildBranchflowStepid(flowstepid,that.stepflow_arr[flowstepindex].childid
                        ,that.stepflow_arr[flowstepindex].branchstepid);
               var lastbranchindex=that.getFlowStepIndex(lastflowstepid);
               var parentvirtualnodeindex=that.getFlowStepIndex(that.stepflow_arr[lastbranchindex].childid.split(',')[0]);
            }
            
            var parentvirtualstepinfo=that.stepflow_arr[parentvirtualnodeindex];
            //获取需要拷贝的节点
            that.getBranchChild(flowstepindex,parentvirtualstepinfo);
            that.branchchild_arr.unshift(that.stepflow_arr[flowstepindex]);
            //newflowstep 的branchstepid修改

            var newflowstep_arr=[];
            var havechangeflowstepid_arr=[];
            ld.each(that.branchchild_arr,function(tmpbrachindex,tmpbranchstepinfo){
                var  newflowstepinfo={};
                ld.each(tmpbranchstepinfo,function(key,value){
                    var type=typeof value
                    if(type.toLowerCase()!='object' )
                        newflowstepinfo[key]=value;
                    else
                    {
                        newflowstepinfo[key]={};//stepinfo
                        ld.each(value,function(tmpkey,tmpvalue){
                            type=typeof tmpvalue
                            if(tmpvalue!='object')
                                    newflowstepinfo[key][tmpkey]=tmpvalue;
                            else
                            {
                                newflowstepinfo[key][tmpkey][tmp_key]={};//高级查询
                                ld.each(tmpvalue,function(tmp_key,tmp_value){
                                        newflowstepinfo[key][tmpkey][tmp_key]=tmpvalue;
                                })
                            }
                        })
                    }
                })
                if(havechangeflowstepid_arr[tmpbranchstepinfo.flowstepid+"aa"]==undefined)
                {
                    //如果当前节点，没有被修改节点ID
                    that.maxflowstepid++;
                    havechangeflowstepid_arr[newflowstepinfo.flowstepid+"aa"]=that.maxflowstepid;
                    newflowstepinfo.flowstepid=that.maxflowstepid;
                }
                else{
                    newflowstepinfo.flowstepid=havechangeflowstepid_arr[tmpbranchstepinfo.flowstepid+"aa"]
                }
                var childid_arr=newflowstepinfo.childid.split(',');
                var newchildid_arr=[];

                if(that.GetChildArryWithvirtual(newflowstepinfo.childid,that.branchchild_arr).length<=0)
                {
                        //最后一代节点，不需要修改子节点的ID
                }
                else
                {
                    for(var j=0;j<childid_arr.length;j++)
                    {
                        //如果该子节点已经新建过对应的节点，则不重复获取
                        if(empty(havechangeflowstepid_arr[childid_arr[j]+"aa"])){
                            that.maxflowstepid++;
                            havechangeflowstepid_arr[childid_arr[j]+"aa"]=that.maxflowstepid;
                            newchildid_arr.push(that.maxflowstepid);
                        }else{
                            newchildid_arr.push(havechangeflowstepid_arr[childid_arr[j]+"aa"]);
                        }
                    }
                    newflowstepinfo.childid=newchildid_arr.join(",");
                }
                newflowstepinfo.id='';
                newflowstepinfo.stepname=newflowstepinfo.stepname+"(复制)";
                //没有设置过信息的审批步骤增加默认stepinfo对象
                if(empty(newflowstepinfo.stepinfo) || newflowstepinfo.stepinfo == undefined)newflowstepinfo.stepinfo = {};
                newflowstepinfo.stepinfo.stepname=newflowstepinfo.stepname;
                newflowstepinfo.stepinfo.edit='yes';
                if(tmpbrachindex==0)
                        that.stepflow_arr[parentflowstepindex].childid+=","+newflowstepinfo.flowstepid;

                that.stepflow_arr.push(newflowstepinfo);
                newflowstep_arr.push(newflowstepinfo);
            })
            ld.each(newflowstep_arr,function(tmpindex,tmpinfo){
                    if(tmpindex>0)
                    {
                        //改变新节点的branchstepid
                        if(havechangeflowstepid_arr[tmpinfo.branchstepid+"aa"]!=undefined)
                            tmpinfo.branchstepid=havechangeflowstepid_arr[tmpinfo.branchstepid+"aa"]
                        else
                            tmpinfo.branchstepid=newflowstep_arr[0].branchstepid;
                    }

            })
            
            that.innerNodeHtml();

        })
        var btn_delflowstepobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_delflowstep]");
        ld(btn_delflowstepobj).unbind("click").bind("click",function(){
                //删除步骤
                var flowstepid=ld(this).attr('flowstepid');
                var curflowstepindex=that.getFlowStepIndex(flowstepid);//获取删除节点的索引
                var curflowstepinfo=that.stepflow_arr[curflowstepindex];
                //判断流程是否在使用中
                if(newApproveSetObj.popupobj.approveused == 'yes'){
                    var curstepid = curflowstepinfo['id'];
                    if(curstepid >0){
                        var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTDELETED2'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }
                }
                
                var  parentflowstepindex=that.getparentflowstepindex(flowstepid);//获取删除节点的复节点
            
                if(that.stepflow_arr[curflowstepindex].steptype=='approver')
                {
                    //删除审批人
                    that.stepflow_arr[parentflowstepindex].childid=curflowstepinfo.childid;
                    that.stepflow_arr.splice(curflowstepindex,1);
                    
                }
                else {
                    
                     //获取同级条件数组
                     var parentflowstepinfo=that.stepflow_arr[parentflowstepindex];
                      var childarr=that.GetChildArry(parentflowstepinfo.childid,that.stepflow_arr);
                      var childflowstepid_arr=[];
                      for(var i=0;i<childarr.length;i++)
                      {
                        childflowstepid_arr.push(childarr[i].flowstepid);
                        
                      }
                      var childindex=childflowstepid_arr.indexOf(flowstepid);
                      childflowstepid_arr.splice(childindex,1);
                      that.stepflow_arr[parentflowstepindex].childid=childflowstepid_arr.join(",");
                        //删除条件节点
                        that.delConditionStep(flowstepid,curflowstepinfo.branchstepid);
                   
                      if(childflowstepid_arr.length==1){
                            //如果只有一个条件了，则剩余的一个条件也删除
                         
                           childarr.splice(childindex,1);
                          
                          var delflowstepindex= that.getFlowStepIndex(childarr[0].flowstepid);
                          var branchstepid=childarr[0].branchstepid;//所属分支ID
                        
                     
                          parentflowstepinfo.childid=that.stepflow_arr[delflowstepindex].childid;
                          that.stepflow_arr.splice(delflowstepindex,1);
                         
                         
                          //所属分支的虚拟节点索引,一定会有虚拟分支节点
                          var virtualstepindex=that.getbranchlastvirtualnode(curflowstepinfo.branchstepid); 
                      
                          //获取虚拟节点的父节点
                          var  parentvirturalflowstepindex=that.getparentflowstepindex(that.stepflow_arr[virtualstepindex].flowstepid);
                        
                          //改变虚拟节点的父节点的childid
                          that.stepflow_arr[parentvirturalflowstepindex].childid=that.stepflow_arr[virtualstepindex].childid;
                         that.stepflow_arr.splice(virtualstepindex,1);//删除虚拟节点
                          
                         //改变剩余的最后一个条件的分支节点的所属分支节点
                         that.changebranchstepid(childarr[0].flowstepid,childarr[0].branchstepid);
                          
                      } 
                }
              
               
                
                that.innerNodeHtml();
                //删除步骤
                
        })
        
        
        var btn_changeconditionobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_changecondition]");
        //更改条件的优先级
        ld(btn_changeconditionobj).unbind("click").bind("click",function(){
            
            
            var changetype=ld(this).attr("changetype");
            var curflowstepid=ld(this).attr("flowstepid");
            var curflowstepindex=that.getFlowStepIndex(curflowstepid);
            var curflowstepinfo=that.stepflow_arr[curflowstepindex];
            
            var parentflowstepindex=that.getparentflowstepindex(curflowstepid);
            var childid_arr=that.stepflow_arr[parentflowstepindex].childid.split(",");
           
            if(changetype=='right')
            {
                
                var nextflowstepid;
                for(var i=0;i<childid_arr.length;i++)
                {
                    if(childid_arr[i]==curflowstepid)
                    {
                        nextflowstepid=childid_arr[i+1]
                        childid_arr[i]=childid_arr[i+1];
                        childid_arr[i+1]=curflowstepid;
                        
                        break;
                    }
                }
                var nextflowstepindex=that.getFlowStepIndex(nextflowstepid);
                
                that.stepflow_arr[curflowstepindex]=that.stepflow_arr[nextflowstepindex]
                that.stepflow_arr[nextflowstepindex]=curflowstepinfo;
                
            }
            else if(changetype=='left') {
                
                 var prevflowstepid;
                for(var i=0;i<childid_arr.length;i++)
                {
                    if(childid_arr[i]==curflowstepid)
                    {
                        prevflowstepid=childid_arr[i-1]
                        childid_arr[i]=childid_arr[i-1];
                        childid_arr[i-1]=curflowstepid;
                        break;
                    }
                }
                var prevflowstepindex=that.getFlowStepIndex(prevflowstepid);
                that.stepflow_arr[curflowstepindex]=that.stepflow_arr[prevflowstepindex]
                that.stepflow_arr[prevflowstepindex]=curflowstepinfo;
            }
            that.stepflow_arr[parentflowstepindex].childid=childid_arr.join(",");
             
            that.innerNodeHtml();
            
            //调换条件位置 优先级
        })
        
        var btn_zoomobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_zoom]");
        ld(btn_zoomobj).unbind("click").bind("click",function(){
            //放大缩小
            that.zoom(ld(this).attr("zoomtype"))
        })
        
        var btn_setapproverstepobj=ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_setapproverstep]");
        ld(btn_setapproverstepobj).parent().unbind("click").bind("click",function(){
            //修改审批人信息
             var obj;
             var flowstepid=ld(this).find('[name=btn_setapproverstep]').attr('flowstepid');
             var curflowstepindex=that.getFlowStepIndex(flowstepid);
             //getScriptBackWithURL('include/js/modules/Approve/cls_StepApproverSet.js',function(){
                //同步加载
                 obj=new cls_StepApproverSet(that.stepflow_arr[curflowstepindex].id, flowstepid,that);
            //});
            obj.editprofile = that.editprofile;
            obj.show();
        })
        //设置审批人文字部分也能点击弹出步骤编辑框
        // btn_setapproverstepobj.parent().find(' .text').unbind('click').bind('click',function(){
        //     ld(this).parent().find(' .jiantou').click();
        // })
        ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_setcondition]").unbind("click").bind("click",function(){
            //设置审批条件
            var obj;
            var flowstepid=ld(this).attr('flowstepid');
            var curflowstepindex=that.getFlowStepIndex(flowstepid);
            //getScriptBackWithURL('include/js/modules/Approve/cls_StepConditionSet.js',function(){
                //同步加载
                 obj=new cls_StepConditionSet(flowstepid,that);
            //});
            obj.show();
        })

        ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_prev]").unbind("click").bind("click",function(){
            //上一步
            newApproveSetObj.showapproveinfo();
        })
        //审批保存
        ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_approvesave]").unbind('click').bind("click",function(){
             //测试完成保存后，把newApproveSetObj.approvedatainfo_arr 的属性值finishedallowedit变空才保存
                //console.log(that.stepflow_arr);
                //console.log(JSON.stringify(that.stepflow_arr));
                var param={"approveinfo":JSON.stringify(newApproveSetObj.approvedatainfo_arr),
                'stepinfo':JSON.stringify(that.stepflow_arr)};

                ldAjax('index.php?module=Settings&action=SettingsAjax&file=newApproveSave&approveid='+newApproveSetObj.approveid+"&tabid="+newApproveSetObj.tabid,param,function(ajaxdata){
                    DelProgressObjs();
                    if(ajaxdata.code==-1)
                    {
                         RemindsMsg("","LdPopWidth400px","","yes","yes",ajaxdata.msg);
                        return ;
                    }
                    newApproveSetObj.popupobj.CancelEvent();
                    getCustomBlockList(ld("#pick_module").get(0),'','');

                })
        })
        //点击步骤1回到上一步
        ld("#"+newApproveSetObj.popupobj.divid+" [tag=firststep]").off('click').on('click',function () {
            ld("#"+newApproveSetObj.popupobj.divid+" [name=btn_prev]").click();
        })
        
        //设置事件函数
    }
    this.changeConditionPriority=function(flowstepid1,flowtepid2){
         var parentflowstepindex=that.getparentflowstepindex(curflowstepid);
         var childid_arr=that.stepflow_arr[parentflowstepindex].childid.split(",");
    }
    this.zoom=function(zoomtype){
        //放大缩小
        var scale=10;
        var zoomvalue=ld("#"+newApproveSetObj.popupobj.divid+" [name=zoomvalue]").html().substr(0,ld("#"+newApproveSetObj.popupobj.divid+" [name=zoomvalue]").html().length-1);
       
        
        if(zoomtype=='out')
        {
            if(parseInt(zoomvalue)<=50)
            {
                return ;
            }
            zoomvalue=parseInt(zoomvalue)-scale;
        }
        else{
            if(parseInt(zoomvalue)>=300)
            {
                return ;
            }
            zoomvalue=parseInt(zoomvalue)+scale;
        }
        scale=parseFloat((zoomvalue/100)).toFixed(1);
        ld("#"+newApproveSetObj.popupobj.divid+" [name=zoomvalue]").html(zoomvalue+"%")
        
        ld("#"+newApproveSetObj.popupobj.divid+" [name=nodelist]").get(0).style.transform="scale("+scale+")";	
    }
    //删除条件节点和子节点，但是不删除所属分支的虚拟节点
    
    this.delConditionStep=function(flowstepid,branchflowstepid){
       
        flowstepid=flowstepid+"";
         var newArry = flowstepid.split(",");
         var newlen=newArry.length;
		 var child_arr=[];
      
         
        for (var i in that.stepflow_arr) {
				
             if(that.stepflow_arr[i].steptype==that.conditionvirtual&&that.stepflow_arr[i].branchstepid==branchflowstepid)
             {
                continue ;
             }
			if(newArry.includes(that.stepflow_arr[i].flowstepid+""))
			{
				child_arr.push(that.stepflow_arr[i]);
                 
                if(newlen==1)
                {
                    //只有一个子节点
                    break;
                }
                 
              
			}   
        }
     
        if(child_arr.length>0)
        {
           // console.log(child_arr[0].flowstepid)
             for(var i in child_arr)
             {
               if(child_arr[i].flowstepid==undefined)
                continue;
               var flowstepindex= that.getFlowStepIndex(child_arr[i].flowstepid);
               that.stepflow_arr.splice(flowstepindex,1);
               that.delConditionStep(child_arr[i].childid,branchflowstepid);
              
             }
        }
        else{
            return ;
        }
    }
    this.getparentflowstepindex=function(childflowstepid){
        //获取父节点的索引
        childflowstepid = childflowstepid+'';
        var parentflowstepindex=-1;
        var childid_arr = [];
        ld.each(that.stepflow_arr,function(tmpindex,tmpinfo){
            childid_arr = tmpinfo.childid.split(',');
            if(childid_arr.includes(childflowstepid))
            {
                parentflowstepindex=tmpindex;
                return false;
            }
        })
        return parentflowstepindex;
    }
    
   
    

    
}