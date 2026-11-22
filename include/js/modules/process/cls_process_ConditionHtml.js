function cls_process_ConditionHtml()
{
    
    
    this.setStepInfo=function(nodeinfo)
    {
        this.nodeinfo=nodeinfo;
    }
    this.gethtml=function(htmltype)
    {
        if(!empty(this.nodeinfo.nodeinfo.advftlabel)){
            this.advftlabel = this.nodeinfo.nodeinfo.advftlabel;
        }else{
            this.advftlabel = arrJsPopLabel['PLEASESETCONDITIONS'];
        }
        
        if(htmltype=='left')
        {
            return this.leftconditionhtml();
        }
        else if(htmltype=='right')
            return this.rightconditionhtml();
        else
            return this.middlehtml();
            
    }
      //条件html
    this.rightconditionhtml=function()
    {
        return ' <div class="col-box"> '+
                            '<div class="condition-node">'+
                                '<div class="condition-node-box">'+
                                    '<div class="auto-judge node_ba8a_d998">'+
                                        '<div class="sort-left">'+
                                            '<span class="jiantou jiantou_left" changetype="left" nodeid="'+this.nodeinfo.nodeid+'" name="btn_changecondition"></span></div>'+
                                        '<div class="title-wrapper">'+
                                            '<span class="editable-title">'+this.nodeinfo.nodename+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="icon-homeimg icon-del rfloat marL5" name="btn_delflowstep" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                            '<span class="icon-homeimg icon-copy rfloat" name="btn_copy" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" nodeid="'+this.nodeinfo.nodeid+'"><span nodeid="'+this.nodeinfo.nodeid+'" >'+this.advftlabel+'</span></div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.nodeinfo.childid)+'"  nodeid="'+this.nodeinfo.nodeid+'">'+
                                            '<span class="iconfont"></span>'+
                                        '</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>'+
                            '<div class="top-right-cover-line"></div>'+
                            '<div class="bottom-right-cover-line"></div>';
                            //最后一个html 结束符号用于添加子节点
                        //'</div>';

    }
    this.middlehtml=function()
    {
        return '<div class="col-box">'+
                            '<div class="condition-node">'+
                                '<div class="condition-node-box">'+
                                    '<div class="auto-judge node_cb2d_496d">'+
                                       ' <div class="sort-left">'+
                                            '<span class="jiantou jiantou_left" changetype="left" nodeid="'+this.nodeinfo.nodeid+'" name="btn_changecondition"></span>'+
                                       ' </div>'+
                                        '<div class="title-wrapper">'+
                                            '<span class="editable-title">'+this.nodeinfo.nodename+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="icon-homeimg icon-del rfloat marL5"   name="btn_delflowstep" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                            '<span class="icon-homeimg icon-copy rfloat" name="btn_copy" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" nodeid="'+this.nodeinfo.nodeid+'"><span nodeid="'+this.nodeinfo.nodeid+'">'+this.advftlabel+'</span></div>'+
                                        '<div class="sort-right">'+
                                            '<span class="jiantou jiantou_right" changetype="right" nodeid="'+this.nodeinfo.nodeid+'" name="btn_changecondition"></span>'+
                                        '</div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.nodeinfo.childid)+'"  nodeid="'+this.nodeinfo.nodeid+'">'+
                                            '<span class="iconfont"></span>'+
                                        '</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>';
                            
                        //最后一个html 结束符号用于添加子节点
                      //  '</div>';
    }
    this.leftconditionhtml=function(){
        
        
        return  '<div class="col-box">'+
                            '<div class="top-left-cover-line"></div>'+
                            '<div class="bottom-left-cover-line"></div>'+
                            '<div class="condition-node">'+
                                '<div class="condition-node-box">'+
                                    '<div class="auto-judge node_cb2d_496d">'+
                                        '<div class="title-wrapper">'+
                                            '<span class="editable-title">'+this.nodeinfo.nodename+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="icon-homeimg icon-del rfloat marL5" name="btn_delflowstep" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                            '<span class="icon-homeimg icon-copy rfloat" name="btn_copy" nodeid="'+this.nodeinfo.nodeid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" nodeid="'+this.nodeinfo.nodeid+'"><span nodeid="'+this.nodeinfo.nodeid+'">'+this.advftlabel+'</span></div>'+
                                        '<div class="sort-right">'+
                                            '<span class="jiantou jiantou_right"  changetype="right" nodeid="'+this.nodeinfo.nodeid+'" name="btn_changecondition"></span>'+
                                        '</div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.nodeinfo.childid)+'"  nodeid="'+this.nodeinfo.nodeid+'">'+
                                           ' <span class="iconfont"></span>'+
                                        '</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>';
                            //最后一个html 结束符号用于添加子节点
                        //'</div>';
    }
}