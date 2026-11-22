function cls_ConditionHtml()
{
    
    
    this.setStepInfo=function(stepinfo)
    {
        this.stepinfo=stepinfo;
    }
    this.gethtml=function(htmltype)
    {
        if(!empty(this.stepinfo.stepinfo.advftlabel)){
            this.advftlabel = this.stepinfo.stepinfo.advftlabel;
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
                                    '<div class="auto-judge node_ba8a_d998" style="background: #FFFFFF;">'+
                                        '<div class="sort-left">'+
                                            '<span class="jiantou jiantou_left" changetype="left" flowstepid="'+this.stepinfo.flowstepid+'" name="btn_changecondition"></span></div>'+
                                        '<div class="title-wrapper">'+
                                            '<span class="editable-title">'+this.stepinfo.stepname+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="rfloat marL5" name="btn_delflowstep" flowstepid="'+this.stepinfo.flowstepid+'"><img style="width: 18px;height: 18px;margin: 0px 4px;cursor: pointer;" src="themes/icon/button/Delete.png"></span>'+
                                            '<span class="restore-default-icon restore-default-icon-copy rfloat" style="cursor: pointer;" name="btn_copy" flowstepid="'+this.stepinfo.flowstepid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" flowstepid="'+this.stepinfo.flowstepid+'">'+this.advftlabel+'</div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.stepinfo.childid)+'"  flowstepid="'+this.stepinfo.flowstepid+'">'+
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
                                            '<span class="jiantou jiantou_left" changetype="left" flowstepid="'+this.stepinfo.flowstepid+'" name="btn_changecondition"></span>'+
                                       ' </div>'+
                                        '<div class="title-wrapper">'+
                                            '<span class="editable-title">'+this.stepinfo.stepname+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="rfloat marL5" name="btn_delflowstep" flowstepid="'+this.stepinfo.flowstepid+'"><img style="width: 18px;height: 18px;margin: 0px 4px;cursor: pointer;" src="themes/icon/button/Delete.png"></span>'+
                                            '<span class="restore-default-icon restore-default-icon-copy rfloat" style="cursor: pointer;" name="btn_copy" flowstepid="'+this.stepinfo.flowstepid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" flowstepid="'+this.stepinfo.flowstepid+'">'+this.advftlabel+'</div>'+
                                        '<div class="sort-right">'+
                                            '<span class="jiantou jiantou_right" changetype="right" flowstepid="'+this.stepinfo.flowstepid+'" name="btn_changecondition"></span>'+
                                        '</div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.stepinfo.childid)+'"  flowstepid="'+this.stepinfo.flowstepid+'">'+
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
                                            '<span class="editable-title">'+this.stepinfo.stepname+'</span>'+
                                            '<span class="priority-title"></span>'+
                                            '<span class="rfloat marL5" name="btn_delflowstep" flowstepid="'+this.stepinfo.flowstepid+'"><img style="width: 18px;height: 18px;margin: 0px 4px;cursor: pointer;" src="themes/icon/button/Delete.png"></span>'+
                                            '<span class="restore-default-icon restore-default-icon-copy rfloat" style="cursor: pointer;" name="btn_copy" flowstepid="'+this.stepinfo.flowstepid+'"></span>'+
                                        '</div>'+
                                        '<div class="content" name="btn_setcondition" flowstepid="'+this.stepinfo.flowstepid+'">'+this.advftlabel+'</div>'+
                                        '<div class="sort-right">'+
                                            '<span class="jiantou jiantou_right"  changetype="right" flowstepid="'+this.stepinfo.flowstepid+'" name="btn_changecondition"></span>'+
                                        '</div>'+
                                    '</div>'+
                                    '<div class="add-node-btn">'+
                                        '<button class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.stepinfo.childid)+'"  flowstepid="'+this.stepinfo.flowstepid+'">'+
                                           ' <span class="iconfont"></span>'+
                                        '</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>';
                            //最后一个html 结束符号用于添加子节点
                        //'</div>';
    }
}