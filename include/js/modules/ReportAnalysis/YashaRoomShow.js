function  YashaRoomShow(){
    var that = this;
    this.terminal = 'pc';
    that.divid = 'yasha_content';

    this.setTerminal = function(terminal){
        that.terminal = terminal;
    }
    this.setEvent = function(){
        //楼盘点击事件
        ld('#'+that.divid).find('[tag=loupan_name]').unbind('click').click('bind',function(){
            ld(this).find('ul').toggle();
            if(ld(this).find('.file').hasClass('user-right-tip')){
                ld(this).find('.file').removeClass('user-right-tip');
            }else{
                ld(this).find('.file').addClass('user-right-tip');
            }
        });
        //楼栋号点击事件
        ld('#'+that.divid).find('[tag=builing_num]').unbind('click').click('bind',function(){
            event.stopPropagation();
            var loupan = ld(this).data('loupan');
            var buildingnum = ld(this).data('buildingnum');
            ld('#'+that.divid).find('[tag=builing_num]').css('background-color','#fff');
            ld(this).css('background-color','#E4F0FF');
            that.showRoom(loupan,buildingnum);
        });
        ld('#'+that.divid).unbind('click').click('bind',function(){
            ld('#' + that.divid).find('#yasha_droplist').css('visibility','hidden');
        });
        //展开收起图标点击
        ld('#'+that.divid).find('#expandtd').unbind('click').click('bind',function(){
            var tdObj = ld("#"+that.divid+" .user-left-td");//树结构td区块
            var tdExpandObj = ld("#"+that.divid+" #expandtd");//展开收起图标td
            var expand = tdObj.css("display")=='none'?'no':'yes';
            tdExpandObj.attr("data-tip",expand=='no'?arrJsPopLabel['EXPANSION']:arrJsPopLabel['COLLAPSE']);//展开 EXPANSION 收起COLLAPSE
            if(expand == 'yes'){
                tdObj.css('display','none');
                tdExpandObj.find('.tree-closeopen').removeClass('tree-close').addClass('tree-open');
            }else{
                tdObj.css('display','');
                tdExpandObj.find('.tree-closeopen').removeClass('tree-open').addClass('tree-close');
            }
        });
    }
    this.setHeight = function(){
        var height = ld(window).height();
        ld('#'+ that.divid).find('#yasha_table_content').css('height',(height-110)+'px');
    }
    this.showRoom = function(loupan,buildingnum){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=YashaRoomShow&function_name=showRoom';
        var params = '&loupan='+loupan+'&buildingnum='+buildingnum;
        params += '&terminal='+that.terminal;
        ldAjaxNoProgress(url,params,function(res) {
            if (res.code == 1) {
                ld('#' + that.divid).find('#roomlist_content').html(res.result.content);
                that.setHeight();
                ld('#' + that.divid).find('[tag=show_droplist]').unbind('click').bind('click',function(){
                    event.stopPropagation();
                    that.dropdownShow(this);
                })
            }
        })
    }
    this.dropdownShow = function(obj){
        var left = ld(obj).offset().left;
        var top = ld(obj).offset().top;
        var pid = ld(obj).data('pid');
        ld('#' + that.divid).find('#yasha_droplist').css('top',top+'px').css('left',left+'px').css('visibility','visible');
        ld('#' + that.divid).find('#yasha_droplist li').unbind('click').bind('click',function(){
            var tag = ld(this).attr('tag');
            that.btnclick(pid,tag);
        });
    }
    this.btnclick = function(pid,tag){
        switch (tag){
            case 'detail':
                window.open("index.php?pageto_module=Products&pageto_action=index&pageto_record="+pid);
                break;
            case 'Leads':
            case 'Accounts':
            case 'CustomForm166':
            case 'CustomForm44':
            case 'SalesOrder':
                //都是打开新页签
                var url = 'index.php?pageto_module='+tag+'&pageto_action=index';
                var thisMoudule = 'Products';
                var event_content = "related_add_url('index.php?module="+tag+"&action=EditView&return_module="+tag+"&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=Products&fromid="+pid+"&parent_id="+pid+"&product_id="+pid+"','Products',\'"+tag+"\',"+pid+")";
                sessionStorage.setItem('isNewPage',event_content + '%' + thisMoudule);
                setTimeout(function(){ window.open(url); }, 1000);
                setTimeout(function(){ sessionStorage.removeItem('isNewPage'); }, 5000);
                break;

        }
    }
}