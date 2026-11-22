function cls_ApproverHtml()
{
    var that=this;
    
    this.setStepInfo=function(stepinfo)
    {
        this.stepinfo=stepinfo;
    }
    this.gethtml=function(){
        
        
        
        var html='';
        var approver_label = arrJsPopLabel['Pleasesettheapproversjs'];
        var stepinfo_detail = this.stepinfo.stepinfo;
        //显示审批人信息
        if(!empty(stepinfo_detail.approvetype_label)){
        approver_label = arrJsPopLabel['APPROVERTYPEJS']+':'+stepinfo_detail.approvetype_label+'<br>'+stepinfo_detail.approvevalue_label;
        }
        
        html='<div class="node-wrap">'+
            '<div class="node-wrap-box node_sid-startevent">'+
                '<div>'+
                    '<div class="title" style="background:var(--ld-bg-list-head-color);">'+
                        '<span class="" name="caneditstepname sort-tip-items" title="' +this.stepinfo.stepname+ '" style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;">'+this.stepinfo.stepname+'</span>'+
                        '<span class="title-close" name="btn_delflowstep" flowstepid="'+this.stepinfo.flowstepid+'">x</span>'+
                    '</div>'+
                    '<div class="content">'+
                        '<div class="text">'+approver_label+'</div>'+
                        ' <span class="jiantou jiantou_right" name="btn_setapproverstep" flowstepid="'+this.stepinfo.flowstepid+'" ></span>'+
                    '</div>'+
                '</div>'+
            '</div>'+
            '<div class="add-node-btn-box">'+
                '<div class="add-node-btn">'+
                    '<button id="start" class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.stepinfo.childid)+'"  flowstepid="'+this.stepinfo.flowstepid+'">'+
                        '<span class="iconfont"></span>'+
                    '</button>'+
                '</div>'+
            ' </div>'+
        '</div>';
        return html;
    }
}