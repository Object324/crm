
/* creator:gyq_13 reason:新增数字框处理类 date:2016.6.21 */
var inputAddSubNumberBox = (function () {

    //参数：传递给单例的一个参数集合
    function entrance() {
        this.startnum = '*';
        this.endnum = '*';
        this.page = 1;
        this.boxs = '';
        this.browser = '';
        this.paddingTop = '';
        this.isnumber = false;
        this.boxtype = '';
        this.oldval = 0;
    }
    /* 获取数字输入框类型  */
    entrance.prototype.init_boxtype = function(){
        var start = false;
        var end = false;
        var type = '';
        if(parseInt(this.startnum)==this.startnum) {
            start = true;
        }
        if(parseInt(this.endnum)==this.endnum) {
            end = true;
        }
        if(start && end){
            type = 'limit_both';  // 限制最小值与最大值
        }else if(start && !end){
            type = 'limit_start';  // 仅限制最小值
        }else if(!start && end){
            type = 'limit_end';   // 仅限制最大值
        }else{
            type = 'limit_none';  // 不作限制
        }
        this.boxtype = type;
    }
    /* 初始化数字输入框 */
    entrance.prototype.init = function(boxdiv,startnum,endnum,page,boxtype){
        if(boxdiv != undefined) {
            this.boxs = boxdiv;
            if(startnum === 0){
                this.startnum = 0;
            }else{
                this.startnum = startnum ? startnum : '*';
            }
            if(this.endnum === 0){
                this.endnum = 0;
            }else{
                this.endnum = endnum ? endnum : '*';
            }
            this.page = page ? page : 1;
            if (boxtype) {
                this.boxtype = boxtype;
            } else {
                this.init_boxtype();
            }
            var jself = this;
            this.getbrowser();
            this.boxs.each(function (i) {
                var thisinput = ld(this).find('input').eq(0);
                if (empty(thisinput.val())) {
                    thisinput.val(0);
                }
                jself.onkeydown(thisinput);
                jself.onkeyup(thisinput);
                thisinput.focus(function(){//光标移入，全选输入框内容
                    thisinput.select();
                });
                if (jself.boxtype == 'limit_both_systemset') {
                    //thisinput.attr('title', jself.startnum + '-' + jself.endnum)
                    ld(this).find('a').eq(0).unbind('click').bind('click',function () {
                        //28663: 控制面板>系统参数设置：设置单据分录明细中数量字段小数位数、设置单据分录明细中单价字段小数位数不能设置为0
                        // if((parseInt(thisinput.val())- jself.page) >=0){
                        //     thisinput.val(parseInt(thisinput.val()) - jself.page);
                        // }
                        //0043367: （https://61mis.com/kfbcrm [^]）系统设置->系统参数：“设置单据分录明细新增时预置的分录行数”应该不能设置为0.预期结果：设置为“1”点击减号时应该点不动  zxm 2021-0107
                        if((parseInt(thisinput.val())- startnum) >0 &&(parseInt(thisinput.val())- jself.page) >=0){
                            thisinput.val(parseInt(thisinput.val()) - jself.page);
                        }
                        return false;
                    });
                    ld(this).find('a').eq(1).unbind('click').bind('click',function () {
                        if((parseInt(thisinput.val()) + jself.page) <= jself.endnum){
                            thisinput.val(parseInt(thisinput.val()) + jself.page);
                        }
                        return false;
                    });
                }else if(jself.boxtype == 'limit_none'){
                    ld(this).find('a').eq(0).unbind('click').bind('click',function () {
                        thisinput.val(parseInt(thisinput.val()) - jself.page);
                        return false;
                    });
                    ld(this).find('a').eq(1).unbind('click').bind('click',function () {
                        thisinput.val(parseInt(thisinput.val()) + jself.page);
                        return false;
                    });
                }

                if(jself.browser == 'MSIE' || jself.browser == 'Opera'){
                    ld(this).find('a')[0].style.fontSize = '17px';
                }

                if (this.browser != '') {
                    switch (this.browser) {//浏览器兼容
                        case 'Firefox':
                            thisinput.css('paddingTop', '2px');
                            break;
                        case 'Google':
                            thisinput.css('paddingTop', '0px');
                            break;
                        case 'MSIE':
                            thisinput.css('marginTop', '3px');
                            break;
                        case 'Opera':
                            thisinput.css('paddingTop', '5px');
                            break;
                    }
                }
            });
        }
    }
    entrance.prototype.onkeydown = function(obj){
        var jself = this;
        obj.on('keydown',function(event){
            var e = event||window.event;
            if((e.keyCode > 47 && e.keyCode < 58) || (e.keyCode > 95 && e.keyCode < 106)){
                jself.isnumber = true;
            }else{
                jself.isnumber = false;
            }
            if(jself.isnumber){
                if(jself.boxtype == 'limit_both_systemset'){
                    if(obj.val() <= jself.endnum)
                        jself.oldval = obj.val();
                    if(jself.endnum < 10)
                        obj.val('');
                }
            }
        });
    }
    entrance.prototype.onkeyup = function(obj){
        var jself = this;
        obj.on('keyup',function(){
            if(jself.isnumber){//输入的是数字
                if(jself.boxtype == 'limit_both_systemset') {
                    var reg = '';
                    if (jself.endnum > 9)
                        reg = eval("/\[" + jself.startnum + "-9]/g");
                    else
                        reg = eval("/\[" + jself.startnum + "-" + jself.endnum + "]/g");
                    if (obj.val().replace(reg, '0') == 0) {
                        if (parseInt(obj.val()) > jself.endnum)
                            obj.val(oldval);
                        else
                            obj.val(parseInt(obj.val()));
                    } else {
                        obj.val(0);
                        obj.select();
                    }
                }
            }else{
                obj.val(0);
                obj.select();
            }
        });

    }
    entrance.prototype.getbrowser = function(){
        if(navigator.userAgent.indexOf('MSIE')>0) {
            this.browser = 'MSIE';
        }else if(navigator.userAgent.indexOf('Firefox') > 0){
            this.browser = 'Firefox';
        }else if(navigator.userAgent.indexOf('Chrome') > 0){
            this.browser = 'Google';
        }else if(navigator.userAgent.indexOf('Opera') > -1){
            this.browser = 'Opera';
        }else if(navigator.userAgent.indexOf('Safari') > 0){
            this.browser = 'Safari';
        }else{
            this.browser = '';
        }


    }
    entrance.prototype.inits = function(){}

//实例容器
    var instance;

    var _static = {

        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }
            return instance;

        }
    };
    return _static;

})();
