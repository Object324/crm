/**
 * @class  ld_Pagination
 * @author  hzx
 * @date  2023/12/07 - 初始版本
 * @description  翻页组件
 */

function ld_Pagination(){
    var that = this;

    /**
     * 当前页数，当前选中页数
     * @type {number}
     */
    this.currentpage = 1;

    /**
     * 数据总条数
     * @type {number}
     */
    this.count = 0;

    /**
     * 总页数
     * @type {number}
     */
    this.pagecount = 1;

    /**
     * 翻页容器的DOM对象
     * @type {HTMLElement}
     */
    this.LayoutObj = undefined;

    /**
     * 页码切换回调事件
     * @type {function(evt)}
     */
    this.changepage = null;

    /**
     * 语言种类
     * @type {string}
     */
    this.language = 'zh-cn';

    /**
     * 配置翻页对象的实例
     * @param {HTMLElement} obj 翻页容器的DOM对象
     */
    this.setEventObj = function (obj){
        that.LayoutObj = obj;
    }

    /**
     *是否显示总页数
     * @type {Boolean}
     */
    this.showpagecount = false;

    /**
     *是否显示每页多少条
     * @type {Boolean}
     */
    this.showpagepernum = true;

    /**
     *翻页dom对象
     * @type {HTMLElement}
     */
    this.paginationobj = undefined;

    /**
     * 每页显示条数 下拉框选项数组
     * @type {Array}
     */
    this.pagepernumarr = [];

    /**
     * 设置页面最多显示条数回调事件
     * @type {function(evt)}
     */
    this.changepagecount = null;

    /**
     * 翻页跳转按钮是否显示
     * @type {Boolean}
     */
    this.jumpbutton = false;

    /**
     *配置翻页属性
     */
    this.setPagination = function (PaginationData) {
        if (PaginationData.count && PaginationData.count >= 0) {
            that.count = PaginationData.count;
        }else{
            that.count = 0;
        }
        if (PaginationData.pagecount && PaginationData.pagecount >= 1) {
            that.pagecount = PaginationData.pagecount;
        }else{
            that.pagecount = 1;
        }
        if (PaginationData.currentpage && PaginationData.currentpage >= 1) {
            if(that.currentpage > that.pagecount){
                that.currentpage = 1;
            }else{
                that.currentpage = PaginationData.currentpage;
            }
        }else{
            that.currentpage = 1;
        }
        if (PaginationData.changepage) {
            that.changepage = PaginationData.changepage;
        }

        if (PaginationData.pagepernumarr && PaginationData.pagepernumarr.length && PaginationData.pagepernumarr.length>0) {
            that.pagepernumarr = PaginationData.pagepernumarr;
        }

        if (PaginationData.changepagecount) {
            that.changepagecount = PaginationData.changepagecount;
        }
        if (PaginationData.language) {
            that.language = PaginationData.language;
        }
        if (PaginationData.jumpbutton) {
            that.jumpbutton = PaginationData.jumpbutton;
        }
    }

    /**
     *生成翻页
     */
    this.showHtml = function (){
        that.getPaginationHtml();
        that.getPageBtnListHtml();
        that.afetBindEvent();
    }

    /**
     *组合翻页html
     */
    this.getPaginationHtml = function (){
        var paginationhtml = '';
        if(that.language == 'zh-cn'){
            paginationhtml = '<div class="ld_Pagination">' +
                '<div class="ld_Pagination_total">' +
                '<span>共 '+that.count+' 条</span>';
            if(that.showpagecount){
                paginationhtml += '<span>共 '+that.pagecount+' 页</span>';
            }
            paginationhtml += '</div>';
            if(that.pagepernumarr.length > 0){
                var countpagelabel = '请选择';
                for(let i = 0;i < that.pagepernumarr.length;i++){
                    if(that.pagepernumarr[i].selected){
                        countpagelabel = that.pagepernumarr[i].label;
                        break;
                    }
                }
                paginationhtml += '<div class="ld_Pagination_countpage" tabindex="98"><span>'+countpagelabel+'</span><b class="ld_Pagination_arrowicon"></b></div>'
            }

            paginationhtml += '<ul class="ld_Pagination_btnlist">' +
                '</ul>' +
                '<div class="ld_Pagination_gotopagenum">' +
                '<span>前往</span>' +
                '<input type="number" name="pagenum" class="ld_Pagination_gotopage" value="'+that.currentpage+'"/>' +
                '<span>页</span>';
            if(that.jumpbutton){
                paginationhtml += '<div><span class="ld_Pagination_gotopage_gobtn">Go</span></div>';
            }
            paginationhtml += '</div>' +
                '</div>';
        }else{
            paginationhtml = '<div class="ld_Pagination">' +
                '<div class="ld_Pagination_total">' +
                '<span>'+that.count+' Records total</span>';
            if(that.showpagecount){
                paginationhtml += '<span>'+that.pagecount+' Pages total</span>';
            }
            paginationhtml += '</div>';
            if(that.pagepernumarr.length > 0){
                var countpagelabel = 'Please Select';
                for(let i = 0;i < that.pagepernumarr.length;i++){
                    if(that.pagepernumarr[i].selected){
                        countpagelabel = that.pagepernumarr[i].label;
                        break;
                    }
                }
                paginationhtml += '<div class="ld_Pagination_countpage" tabindex="98"><span>'+countpagelabel+'</span><b class="ld_Pagination_arrowicon"></b></div>'
            }

            paginationhtml += '<ul class="ld_Pagination_btnlist">' +
                '</ul>' +
                '<div class="ld_Pagination_gotopagenum">' +
                '<span>go to</span>' +
                '<input type="number" name="pagenum" class="ld_Pagination_gotopage" value="'+that.currentpage+'"/>' +
                '<span>page</span>';
            if(that.jumpbutton){
                paginationhtml += '<div><span class="ld_Pagination_gotopage_gobtn">Go</span></div>';
            }
            paginationhtml += '</div>' +
                '</div>';
        }


        that.LayoutObj.innerHTML = paginationhtml;
        that.paginationobj = that.LayoutObj.querySelector('.ld_Pagination');
    }

    /**
     * 获取页码按钮
     */
    this.getBtnList = function (){
        var btnlist = [];
        if(that.pagecount <= 7){
            for(let i = 0;i<that.pagecount;i++){
                btnlist.push(i+1);
            }
        }else{
            var pagenow = that.currentpage;
            var leftdrift = 3 - pagenow;
            if(leftdrift < 0){
                leftdrift = 0;
            }
            var rightdrift = pagenow - that.pagecount + 2;
            if(rightdrift < 0){
                rightdrift = 0;
            }
            var page = pagenow + leftdrift - rightdrift;
            btnlist = [page-2,page-1,page,page+1,page+2];
        }
        return btnlist;
    }

    /**
     * 获取页码按钮html
     */
    this.getPageBtnListHtml = function (){
        var btnlisthtml = '';
        if(this.currentpage > 1){
            btnlisthtml += '<li data-pagenum="'+(that.currentpage-1)+'"><i class="arrow_icon arrow-left allowactive"></i></li>';
        }else{
            btnlisthtml += '<li class="noallowactive"><i class="arrow_icon arrow-left"></i></li>';
        }

        var btnlist = that.getBtnList();

        if(that.pagecount > 7 && btnlist[0] > 1){
            btnlisthtml += '<li data-pagenum="1"><span>1</span></li>';
        }
        if(that.pagecount > 7 && btnlist[0] > 2){
            var left_skit = that.currentpage - 5;
            if(left_skit < 1){
                left_skit = 1;
            }
            btnlisthtml += '<li data-pagenum="'+left_skit+'"><i class="more_icon"></i><i class="skip_icon skip-left"></i></li>';
        }

        for(let i = 0;i < btnlist.length;i++){
            if(btnlist[i] == that.currentpage){
                btnlisthtml += '<li class="currentpage" data-pagenum="'+btnlist[i]+'"><span>'+btnlist[i]+'</span></li>';
            }else{
                btnlisthtml += '<li data-pagenum="'+btnlist[i]+'"><span>'+btnlist[i]+'</span></li>';
            }
        }

        if(that.pagecount > 7 && that.pagecount - btnlist[4] > 1){
            var right_skit = that.currentpage + 5;
            if(right_skit > that.pagecount){
                right_skit = that.pagecount;
            }
            btnlisthtml += '<li data-pagenum="'+right_skit+'"><i class="more_icon"></i><i class="skip_icon skip-right"></i></li>';
        }
        if(that.pagecount > 7 && btnlist[4] < that.pagecount){
            btnlisthtml += '<li data-pagenum="'+that.pagecount+'"><span>'+that.pagecount+'</span></li>';
        }

        if(that.currentpage >= that.pagecount){
            btnlisthtml += '<li class="noallowactive"><i class="arrow_icon arrow-right"></i></li>'
        }else{
            btnlisthtml += '<li data-pagenum="'+(that.currentpage+1)+'"><i class="arrow_icon arrow-right allowactive"></i></li>'
        }
        if(that.paginationobj != undefined){
            that.paginationobj.querySelector('ul.ld_Pagination_btnlist').innerHTML = btnlisthtml;
        }
    }

    /**
     * 生成翻页html后的操作 绑定事件
     */
    this.afetBindEvent = function (){
        var paginationobj = that.paginationobj;
        if(that.pagecount > 7){
            paginationobj.querySelector('.ld_Pagination_gotopagenum').style.display = '';
            paginationobj.querySelector('.ld_Pagination_gotopagenum input.ld_Pagination_gotopage').addEventListener('keydown',function (){
                if(window.event.keyCode == 13){
                    if(1<=parseInt(this.value) && parseInt(this.value)<=that.pagecount){
                        that.changePageNum(parseInt(this.value));
                    }
                    if(parseInt(this.value) > that.pagecount){
                        that.changePageNum(that.pagecount);
                    }
                    if(parseInt(this.value) < 1){
                        that.changePageNum(1);
                    }
                }
            });
            if(paginationobj.querySelector('.ld_Pagination_gotopagenum span.ld_Pagination_gotopage_gobtn') != null){
                paginationobj.querySelector('.ld_Pagination_gotopagenum span.ld_Pagination_gotopage_gobtn').addEventListener('click',function (){
                    var pagenum_value = paginationobj.querySelector('.ld_Pagination_gotopagenum input.ld_Pagination_gotopage').value;
                    if(1<=parseInt(pagenum_value) && parseInt(pagenum_value)<=that.pagecount){
                        that.changePageNum(parseInt(pagenum_value));
                    }
                    if(parseInt(pagenum_value) > that.pagecount){
                        that.changePageNum(that.pagecount);
                    }
                    if(parseInt(pagenum_value) < 1){
                        that.changePageNum(1);
                    }
                });
            }
        }else{
            paginationobj.querySelector('.ld_Pagination_gotopagenum').style.display = 'none';
        }
        if(that.pagecount == 1){
            paginationobj.querySelector('ul.ld_Pagination_btnlist').style.display = 'none';
        }else{
            paginationobj.querySelector('ul.ld_Pagination_btnlist').style.display = '';
        }


        that.bindPageBtnListEvent();
    }

    /**
     * 绑定页码按钮的点击事件
     */
    this.bindPageBtnListEvent = function (){
        var paginationobj = that.paginationobj;
        var pagebtnlistdom = paginationobj.querySelectorAll('ul.ld_Pagination_btnlist li');
        for(var i = 0;i < pagebtnlistdom.length;i++){
            pagebtnlistdom[i].addEventListener('click',function (){
                var tmp_pagenum = this.getAttribute('data-pagenum');
                if(tmp_pagenum != null){
                    that.changePageNum(parseInt(tmp_pagenum));
                }
            });
        }

        var perpagerecordsdom = paginationobj.querySelector('.ld_Pagination_countpage');
        if(perpagerecordsdom != null){
            perpagerecordsdom.addEventListener('click',that.showPageCountSelect);
            perpagerecordsdom.addEventListener('blur',function (){
                var contentobj = that.paginationobj.querySelector('.ld_Pagination_countpage .ld_Pagination_countpage_content');
                that.paginationobj.querySelector('.ld_Pagination_countpage b.ld_Pagination_arrowicon').className = 'ld_Pagination_arrowicon';
                if(contentobj != null){
                    contentobj.remove();
                }
            })
        }
    }

    this.showPageCountSelect = function(){
        if(that.paginationobj.querySelector('.ld_Pagination_countpage .ld_Pagination_countpage_content') == null){
            that.paginationobj.querySelector('.ld_Pagination_countpage b.ld_Pagination_arrowicon').className = 'ld_Pagination_arrowicon ld_Pagination_xuanzhuanicon';
            var pagecountdiv = document.createElement('div');
            pagecountdiv.className = 'ld_Pagination_countpage_content';
            var pagecounthtml = '<ul>';
            for(let i = 0;i<that.pagepernumarr.length;i++){
                pagecounthtml += '<li data-pagenumindex="'+i+'">'+that.pagepernumarr[i].label+'</li>';
            }
            pagecounthtml += '</ul>';
            pagecountdiv.innerHTML = pagecounthtml;
            that.paginationobj.querySelector('.ld_Pagination_countpage b.ld_Pagination_arrowicon').after(pagecountdiv);
            var pagecountliobj = that.paginationobj.querySelectorAll('.ld_Pagination_countpage .ld_Pagination_countpage_content ul li');
            if(pagecountliobj.length > 0){
                for(let i = 0;i<pagecountliobj.length;i++){
                    pagecountliobj[i].addEventListener('click',function (){
                        event.stopPropagation();
                        var liindex = parseInt(this.getAttribute('data-pagenumindex'));
                        that.paginationobj.querySelector('.ld_Pagination_countpage span').innerHTML = that.pagepernumarr[liindex].label;
                        if(that.changepagecount != null){
                            var EVENT = {};
                            EVENT['target'] = this;
                            EVENT['NavBarItem'] = that.pagepernumarr[liindex];
                            that.changepagecount(EVENT);
                        }
                        that.paginationobj.querySelector('.ld_Pagination_countpage b.ld_Pagination_arrowicon').className = 'ld_Pagination_arrowicon';
                        var contentobj = that.paginationobj.querySelector('.ld_Pagination_countpage .ld_Pagination_countpage_content');
                        if(contentobj != null){
                            contentobj.remove();
                        }
                    });
                }
            }
        }else{
            var contentobj = that.paginationobj.querySelector('.ld_Pagination_countpage .ld_Pagination_countpage_content');
            that.paginationobj.querySelector('.ld_Pagination_countpage b.ld_Pagination_arrowicon').className = 'ld_Pagination_arrowicon';
            if(contentobj != null){
                contentobj.remove();
            }
        }
    }

    /**
     * 页码切换事件回调
     */
    this.changePageNum = function (pagenum){
        that.currentpage = pagenum;
        if(that.changepage != null){
            that.changepage(pagenum);
        }
        that.getPageBtnListHtml();
        that.bindPageBtnListEvent();
    }

}

/**
 * 创建一个ld_Pagination实例
 * @param {HTMLElement} LayoutObj 放置页码的DOM对象
 * @param {Object.<PaginationData>|Array.<PaginationData>} PaginationData 下拉框配置JSON
 * @return {ld_Pagination} ld_Pagination实例
 * @example
 * - ld_Pagination.showPagination(LayoutObj,PaginationData);
 */
ld_Pagination.showPagination = function (obj,PaginationData){
    var ld_PaginationObj = new ld_Pagination();
    ld_PaginationObj.setEventObj(obj);
    ld_PaginationObj.setPagination(PaginationData);
    ld_PaginationObj.showHtml();
    return ld_PaginationObj;
}