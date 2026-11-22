/**
 * @class  ld_NavBar
 * @author  xll
 * @date  2023/10/26 - 初始版本
 * - 页签类
 * @description  根据给定页签数组在指定DOM对象中生成页签，超出宽度的页签自动放入更多页签中
 */
function ld_NavBar() {
    var that = this;
    /**
     * 页签对象数组
     * @type {Object.<NavBarItem>|Array.<NavBarItem>}
     */
    this.NavBarList = null;
    /**
     * 放置页签的DOM对象
     * @type {HTMLElement}
     */
    this.LayoutObj = null;
    /**
     * 每个页签Html字符串的集合，键名与NavBarList一致
     * @type {Object.<string>}
     */
    this.NavBarItemList = {};
    /**
     * 页签总数量
     *  @type {number}
     */
    this.NavBarNum = 0;
    /**
     * 选中页签，默认第一个
     *  @type {number}
     */
    this.NavBarSelIndex = 0;
    /**
     * 类列表，将一些样式提取出来使用类名控制，以便控制是否需要这些样式
     *  @type {Object}
     */
    this.CssClassList = {
        NavBarItem : 'WidthFixed ',
        NavBarLabel : 'TextEllipsis ',
        NavBarMore : 'WidthFixed ',
        NavBarMoreLabel : 'TextEllipsis ',
    }

    /** 部分属性需要初始化*/
    this.init = function () {
        that.NavBarSelIndex = 0;
    }

    /**
     * @param {HTMLElement} LayoutObj 放置页签的DOM对象
     * @param {Object.<NavBarItem>|Array.<NavBarItem>} NavBarList 页签数组，含每个页签数据对象
     * @param {NavBarOptions} [Options] 配置项，非必须
     * @example
     * - ld_NavBar.ShowNavBar(LayoutObj,NavBarList)
     * - ld_NavBar.ShowNavBar(LayoutObj,NavBarList,{ OnClick : function(){} })
     */
    this.SetNavBar = function (LayoutObj,NavBarList,Options) {
        that.init();
        that.LayoutObj = LayoutObj;
        that.NavBarList = NavBarList;
        var DefaultOption = that.getDefaultOption()
        that.deepAssign(DefaultOption,Options);
        that.Options = DefaultOption;
        LayoutObj.innerHTML = '<div class="ld-NavBar"></div>';
        that.NavBarDiv = LayoutObj.querySelector('.ld-NavBar');
        that.ChangeCssVarList();
        that.ChangeCssClassList();
        that.NavBarDiv.innerHTML = that.getNavBar();
        if(that.NavBarNum === 0)
            return false;
        that.SortNavBar();
        that.SetAfterEvent();
        that.resizeEvent();
    }

    /**
     * @return {string} 生成的页签Html
     */
    this.getNavBar = function () {
        var NavBar = '';
        NavBar += '<ul class="ld-NavBarList">';
        var NavBarList = that.NavBarList;
        var NavBarItem;
        let NavBarNum;
        if(Array.isArray(NavBarList)) {
            NavBarNum = NavBarList.length;
            for (let i = 0; i < NavBarNum; i++) {
                NavBarItem = NavBarList[i];
                NavBarItem.NavBarKey = i;
                NavBar += that.getNavBarItem(NavBarItem,i);
            }
        } else {
            /** Object类型则必须将配置项中的NavBarSelKey转化为字符串 that.Options.NavBarSelKey*/
            that.Options.NavBarSelKey = String(that.Options.NavBarSelKey);
            NavBarNum = 0;
            for (let ItemKey in NavBarList) {
                NavBarItem = NavBarList[ItemKey];
                NavBarItem.NavBarKey = ItemKey;
                NavBar += that.getNavBarItem(NavBarItem,NavBarNum);
                NavBarNum += 1;
            }
            if(that.Options.NavBarSelKey === '-1'){
                that.Options.NavBarSelKey = Object.keys(NavBarList)[0];
            }
        }
        that.NavBarNum = NavBarNum;
        if(that.NavBarNum > 0)
            NavBar += that.getNavBarMoreItem();
        NavBar += '</ul>';
        return NavBar;
    }


    /**
     * 页签对象
     * @typedef  {object} NavBarItem
     * @property {string|number}    NavBarKey   - 该页签对象在NavBarList中的键值
     * @property {number}           NavBarIndex - 该页签对象在NavBarList中的顺序序列号，便于获取DOM对象
     * @property {number}           NavBarMoreIndex  - 该页签对象在更多页签下拉列表中的顺序序列号，便于获取DOM对象
     * @property {'yes'|'no'}       isNavBarClicked  - 该页签对象在更多页签下拉列表中的顺序序列号，便于获取DOM对象
     * @property {string}           [id]          - 页签id
     * @property {string}           [name]        - 页签命名
     * @property {string}           label       - 页签显示名称
     * @property {string}           [selected]    - 页签是否选中
     * @property {'Simple'|'More'}  NavBarType  - 页签类型，区分页签是否位于更多下拉列表中
     */
    /**
     * @param {NavBarItem}  ItemObj 单个页签对象
     * @param {number}  Index 页签排序索引
     * @return {string} 生成的单个页签Html字符串
     */
    this.getNavBarItem = function (ItemObj,Index) {
        ItemObj.NavBarIndex = Index;
        var NavBarKey = ItemObj.NavBarKey;
        var Id = ItemObj.id !== undefined ? ItemObj.id : '';
        var Name = ItemObj.name !== undefined ? ItemObj.name : '';
        var Label = ItemObj.label;
        var Selected = ItemObj.selected;
        var ItemHtml = '';
        //未使用该参数
        if(that.Options.NavBarSelKey === -1) {
            if(Selected === 'yes' || Selected === true){
                that.NavBarSelIndex = Index;
                that.Options.NavBarSelKey = NavBarKey;
            }
        }
        else {
            if(that.NavBarSelIndex === 0 && NavBarKey === that.Options.NavBarSelKey)
                that.NavBarSelIndex = Index;
        }
        var CustomAttr = '';
        if(that.Options.ShowAllItemInfo) {
            for (let InfoKey in ItemObj) {
                CustomAttr += ' data-' + InfoKey + '="' + ItemObj[InfoKey] + '" ';
            }
        }
        ItemHtml += '<li class="ld-NavBarItem HightLight-Bottom '+that.CssClassList.NavBarItem+'" ' +
                        'data-NavBarKey="'+NavBarKey+'" data-NavBarId="'+Id+'" data-NavBarName="'+Name+'"' + CustomAttr + ' ' +
                        'data-tip="'+Label+'" data-direction="top" data-type="position">' +
                        '<span class="NavBarLabel '+that.CssClassList.NavBarLabel+'">' + Label + '</span>' +
                    '</li>';

        that.NavBarItemList[NavBarKey] = ItemHtml;
        return ItemHtml;
    }

    /**
     * @return {string} 更多页签的Html字符串
     */
    this.getNavBarMoreItem = function () {
        let MoreItem = '',
            Text = that.Options.NavBarMoreDefaultText;
        MoreItem += '<li class="ld-NavBarMore HightLight-Bottom '+that.CssClassList.NavBarMore+'" >' +
            '            <span class="ld-NavBarMoreText NavBarLabel '+that.CssClassList.NavBarMoreLabel+'">'+Text+'</span>' +
            '            <span class="ld-NavBarMoreIcon" ></span>' +
            '            <div class="ld-NavBarMoreDiv">' +
            '                <ul class="ld-NavBarMoreList">' +
            '                </ul>' +
            '            </div>' +
            '        </li>';
        return MoreItem;
    }

    /**
     * @description 将溢出 LayoutObj 的页签元素移入“更多”页签中
     */
    this.SortNavBar = function () {
        let SimpleNum = 0,
            LayoutObj = that.LayoutObj,
            LayoutObjRect = LayoutObj.getBoundingClientRect(),
            visibleRight = LayoutObjRect.right,
            NavBarObj = LayoutObj.querySelector('.ld-NavBar'),
            NavBarMore = NavBarObj.querySelector('.ld-NavBarMore'),
            NavBarMoreList = NavBarMore.querySelector('.ld-NavBarMoreList'),
            NavBarList = NavBarObj.querySelectorAll('.ld-NavBar .ld-NavBarItem'),
            NavBarMoreWidth = NavBarMore.clientWidth,
            MaxSimpleNum = (typeof that.Options.MaxSimpleNum === 'number');
        that.LayoutObjOldWidth = LayoutObjRect.width;
        NavBarMoreList.innerHTML = ''; // 清空先前的内容
        for (let i = 0;i < NavBarList.length; i++){
            let NavBarItem = NavBarList[i],
                rect = NavBarItem.getBoundingClientRect();
            //绑定页签点击事件
            if (rect.right > visibleRight || (MaxSimpleNum && SimpleNum > that.Options.MaxSimpleNum - 1)) {
                //初次放入更多，需做回退处理，即重新判断上一个页签是否超出新的visibleRight
                if(!NavBarMoreList.children.length > 0){
                    MaxSimpleNum = true;
                    that.Options.MaxSimpleNum = SimpleNum;
                    i -= 2;
                    SimpleNum -= 2;
                    visibleRight -= NavBarMoreWidth;
                }
                // 如果页签超出范围，则添加到下拉菜单
                let ItemHtml = that.NavBarItemList[NavBarItem.getAttribute('data-NavBarKey')];
                if(NavBarItem.getAttribute('data-EventType') === 'Simple')
                    NavBarMoreList.innerHTML = ItemHtml + NavBarMoreList.innerHTML;
                else
                    NavBarMoreList.innerHTML += ItemHtml;
                if(NavBarItem.parentNode !== null)
                    NavBarItem.remove();
                //NavBarMoreList.appendChild(NavBarItem);
            }
            else {
                SimpleNum += 1;
                that.SetItemEvent(NavBarItem,'Simple');
            }
        }
        let NavBarListObj = LayoutObj.querySelector('.ld-NavBarList');
        let NavBarListAll = NavBarListObj.children;
        NavBarListObj.style.width = '100%';
        if(NavBarMoreList.children.length > 0) {
            NavBarMore.classList.remove('hidden');
            for(let i = 0; i < NavBarMoreList.children.length; i++) {
                let MoreItem = NavBarMoreList.children[i],
                    NavBarKey = MoreItem.getAttribute('data-NavBarKey');
                MoreItem.classList.remove('HightLight-Bottom');
                MoreItem.classList.remove('ld-NavBarItem');
                MoreItem.classList.add('ld-NavBarMoreItem');
                that.SetItemEvent(MoreItem,'More');
                that.NavBarList[NavBarKey].NavBarMoreIndex = i;
            }
        } else {
            NavBarMore.classList.add('hidden');
        }
        //页签宽度是否均分
        if(that.Options.WidthAvg){
            //修改页签宽度为 总宽度 / 页签数量
            let newWidth = 'calc(100% / ' + SimpleNum + ')';
            for(let i = 0; i < SimpleNum; i++) {
                NavBarListAll[i].style.width = newWidth;
            }
        }
        let SelNavBarItem = that.NavBarList[that.Options.NavBarSelKey];
        //选中指定页签
        if(that.NavBarSelIndex > SimpleNum - 1) {
            that.NavBarMoreClick(SelNavBarItem);
        }
        else {
            let SelNavBar = NavBarListAll[that.NavBarSelIndex];
            SelNavBar.classList.add('cur');
            that.SetCurNavBarItem(SelNavBar,SelNavBarItem);
        }
    }

    /**
     * @param {HTMLElement} ItemEle 页签DOM对象
     * @param {'Simple'|'More'} ItemType 页签所处位置类型,区分是否为更多下拉列表中的页签
     * @description 为页签添加事件
     */
    this.SetItemEvent = function (ItemEle,ItemType) {
        var NavBarKey = ItemEle.getAttribute('data-NavBarKey'),
            NavBarItem = that.NavBarList[NavBarKey];
        //避免事件重复绑定
        if(ItemEle.getAttribute('data-EventType') !== ItemType)
            that.EventList[ItemType](ItemEle,NavBarItem);
        ItemEle.setAttribute('data-EventType',ItemType);
    }
    
    this.EventList = {
        /**
         * @param {HTMLElement} ItemEle 页签DOM对象
         * @param {NavBarItem} NavBarItem 页签数据对象
         */
        Simple : function (ItemEle,NavBarItem) {
            this.BindEvent(ItemEle,NavBarItem,'click',async (NavBarEvent) => {
                var flag = true;
                if(that.Options.OnClickBefore) {
                    try {
                        flag = await that.Options.OnClickBefore(NavBarEvent);
                    } catch (e) {
                        return;
                    }
                }
                if(flag === false) {
                    return;
                }
                // 页签切换
                that.NavBarClick(NavBarEvent.NavBarItem);
                if(!that.Options.OneClick || NavBarEvent.NavBarItem.isNavBarClicked !== 'yes') {
                    // 执行回调
                    that.Options.OnClick(NavBarEvent);
                }
                /** 记录是否点击过 */
                NavBarEvent.NavBarItem.isNavBarClicked = 'yes';
            },false);

            // this.BindEvent(ItemEle,NavBarItem,'click',that.Options.OnClick,that.Options.OneClick);
            this.BindEvent(ItemEle,NavBarItem,'mouseenter',that.Options.OnMouseEnter,that.Options.OneMouseEnter);
            this.BindEvent(ItemEle,NavBarItem,'mouseleave',that.Options.OnMouseLeave,that.Options.OneMouseLeave);
        },
        /**
         * @param {HTMLElement} ItemEle 页签DOM对象
         * @param {NavBarItem} NavBarItem 页签数据对象
         */
        More : function (ItemEle,NavBarItem) {
            NavBarItem.NavBarType = 'More';
            // 点击事件的绑定
            this.BindEvent(ItemEle,NavBarItem,'click',async (NavBarEvent) => {
                var flag = true;
                if(that.Options.OnClickBefore) {
                    try {
                        flag = await that.Options.OnClickBefore(NavBarEvent);
                    } catch (e) {
                        return;
                    }
                }
                if(flag === false) {
                    return;
                }
                // 页签切换
                that.NavBarMoreClick(NavBarEvent.NavBarItem);
                // 是否执行普通页签的点击回调
                if(that.Options.EventIncludeMore.OnClick && (!that.Options.OneClick || NavBarEvent.NavBarItem.isNavBarClicked !== 'yes')) {
                    that.Options.OnClick(NavBarEvent);
                }
                // 是否执行更多页签的点击回调
                if(!that.Options.OneMoreOnClick || NavBarEvent.NavBarItem.isNavBarClicked !== 'yes') {
                    // 执行回调
                    that.Options.MoreOnClick(NavBarEvent);
                }
                /** 记录是否点击过 */
                NavBarItem.isNavBarClicked = 'yes';
            },false);
            // if(that.Options.EventIncludeMore.OnClick)
            //     this.BindEvent(ItemEle,NavBarItem,'click',that.Options.OnClick,that.Options.OneClick);
            if(that.Options.EventIncludeMore.OnMouseEnter)
                this.BindEvent(ItemEle,NavBarItem,'mouseenter',that.Options.OnMouseEnter,that.Options.OneMouseEnter);
            if(that.Options.EventIncludeMore.OnMouseLeave)
                this.BindEvent(ItemEle,NavBarItem,'mouseleave',that.Options.OnMouseLeave,that.Options.OneMouseLeave);
            // this.BindEvent(ItemEle,NavBarItem,'click',that.Options.MoreOnClick,that.Options.OneMoreOnClick);
        },
        /**
         * -事件绑定
         * @param {HTMLElement} ItemEle - 页签DOM对象
         * @param {NavBarItem} NavBarItem - 页签数据对象
         * @param {string} EventType - 事件类型
         * @param {function(NavBarEvent)} EventFun - 事件回调函数
         * @param {boolean} IsOnce - 事件是否仅执行一次
         */
        BindEvent : function (ItemEle,NavBarItem,EventType,EventFun,IsOnce) {
            ItemEle.addEventListener(EventType,function () {
                /** @type {NavBarEvent} */
                var Event = {},
                    curNavBarItem = that.getCurNavBarItem();
                Event.target = this;
                Event.NavBarItem = NavBarItem;
                // 跳转前的页面DOM 和页签数据对象
                Event.from = curNavBarItem.target;
                Event.lastNavBarItem = curNavBarItem.NavBarItem;
                EventFun(Event);
            },{ once : IsOnce});
        }
    }

    /**
     * - 页签（除“更多”）的基础点击事件，即增加 cur 类
     * @param {NavBarItem} SelNavBarItem - 点击的页签数据对象
     */
    this.NavBarClick = function (SelNavBarItem) {
        let NavBarList = that.LayoutObj.querySelector('.ld-NavBarList'),
            SelNavBar = NavBarList.children[SelNavBarItem.NavBarIndex],
            MoreNavBar = that.LayoutObj.querySelector('.ld-NavBar .ld-NavBarMore');
        that.SetCurNavBarItem(SelNavBar,SelNavBarItem);
        that.NavBarAddCur(SelNavBar);
        MoreNavBar.querySelector('.ld-NavBarMoreText').innerText = '';
    }

    /**
     * - 更多下拉列表的基础点击事件，即增加 cur 类并为“更多”页签赋对应属性
     * @param {NavBarItem} SelNavBarItem - 点击的页签数据对象
     */
    this.NavBarMoreClick = function (SelNavBarItem) {
        let MoreNavBar = that.LayoutObj.querySelector('.ld-NavBar .ld-NavBarMore'),
            MoreNavBarDiv = MoreNavBar.querySelector('.ld-NavBarMoreDiv'),
            NavBarMoreList = MoreNavBarDiv.querySelector('.ld-NavBarMoreList'),
            SelNavBar = NavBarMoreList.children[SelNavBarItem.NavBarMoreIndex];
        MoreNavBarDiv.style.display = 'none';
        that.SetCurNavBarItem(SelNavBar,SelNavBarItem);
        that.NavBarAddCur(MoreNavBar);
        that.NavBarAddCur(SelNavBar);
        MoreNavBar.querySelector('.ld-NavBarMoreText').innerText = SelNavBarItem.label;
        MoreNavBar.setAttribute('data-NavBarKey',SelNavBarItem.NavBarKey);
        MoreNavBar.setAttribute('data-NavBarId',SelNavBarItem.id);
        MoreNavBar.setAttribute('data-NavBarName',SelNavBarItem.name);
        //MoreNavBar.setAttribute('data-tip',SelNavBarItem.label);
    }

    /**
     * - 页签点击增加 cur 类并删除其他页签的 cur 类
     * @param {HTMLElement} SelNavBar - 需要增加cur类的页签DOM对象
     */
    this.NavBarAddCur = function (SelNavBar) {
        let NavBarListAll = SelNavBar.parentNode.children;
        for(let i = 0; i < NavBarListAll.length; i++) {
            NavBarListAll[i].classList.remove('cur');
        }
        SelNavBar.classList.add('cur');
    }

    this.SetAfterEvent = function () {
        var NavBarMoreItem = that.LayoutObj.querySelector('.ld-NavBarMore');
        NavBarMoreItem.addEventListener('mouseenter',function () {
            that.NavBarMoreHover(NavBarMoreItem,'on');
        });
        NavBarMoreItem.addEventListener('mouseleave',function () {
            that.NavBarMoreHover(NavBarMoreItem,'off');
        });
        if(typeof tooltip === "function"){
            tooltip(that.LayoutObj.querySelectorAll('li'), {transition: true, time: 200});
        }
    }

    /**
     * @param {HTMLElement} NavBarMoreItem 更多下拉框DOM对象
     * @param {'on'|'off'} type 开关，标识是否显示
     * @return {NavBarOptions} 默认的配置项
     */
    this.NavBarMoreHover = function (NavBarMoreItem,type) {
        var NavBarMoreList = NavBarMoreItem.querySelector('.ld-NavBarMoreDiv');
        if(type === 'off'){
            if(!that.EventIsInElement(NavBarMoreList))
                NavBarMoreList.style.display = 'none';
        } else if(type === 'on'){
            NavBarMoreList.style.display = 'block';
            var NavBarMoreRect = NavBarMoreItem.getBoundingClientRect(),
                NavBarMore_width = NavBarMoreRect.width,
                NavBarMoreList_width = NavBarMoreList.getBoundingClientRect().width;
            if(NavBarMore_width > NavBarMoreList_width){
                NavBarMoreList.style.right = (NavBarMore_width - NavBarMoreList_width)/2 + 'px';
            }
            NavBarMoreList.style.top = (NavBarMoreRect.height - 2) + 'px';
        }
    }

    this.ChangeCssVarList = function () {
        let CssVarList = that.Options.CssVarList,
            StyleObj = that.NavBarDiv.style;
        for (let key in CssVarList) {
            if(CssVarList[key] !== null && CssVarList[key] !== undefined)
                StyleObj.setProperty('--'+key,CssVarList[key]);
        }
    }
    
    this.ChangeCssClassList = function () {
        if(!that.Options.WidthFixed) {
            that.CssClassList.NavBarItem = '';
            that.CssClassList.NavBarLabel = '';
            that.CssClassList.NavBarMore = '';
            that.CssClassList.NavBarMoreLabel = '';
        }
    }

    /**
     * 设置选中页签
     * @param {HTMLElement} CurNavBarItem   选中页签的DOM对象
     * @param {NavBarItem} SelNavBarItem    选中页签的数据对象
     */
    this.SetCurNavBarItem = function (CurNavBarItem,SelNavBarItem) {
        that.CurNavBarEvent = {
            target: CurNavBarItem,
            NavBarItem: SelNavBarItem,
        }
    }

    /**
     * 获取选中页签
     * @return {NavBarEvent} 页签事件对象
     */
    this.getCurNavBarItem = function () {
        return that.CurNavBarEvent;
    }

    /** 使用 ResizeObserver API 实现容器宽度变化后的页签自适应  */
    this.resizeEvent = function () {
        let observer = new ResizeObserver(function (entries, observer) {
            for (let entry of entries) {
                let newWidth = entry.contentBoxSize[0].inlineSize;
                /*
                if(newWidth < that.LayoutObjOldWidth){
                    that.smallerResize();
                }
                else if(newWidth > that.LayoutObjOldWidth){
                    that.largerResize();
                }
                 */
                //todo 暂时直接重置，后续考虑优化办法
                if(newWidth !== that.LayoutObjOldWidth){
                    that.init();
                    that.NavBarDiv.innerHTML = '';
                    that.Options.NavBarSelKey = that.getCurNavBarItem().NavBarItem.NavBarKey;
                    that.NavBarDiv.innerHTML = that.getNavBar();
                    if(that.NavBarNum === 0)
                        return false;
                    that.SortNavBar();
                    that.SetAfterEvent();
                    that.LayoutObjOldWidth = newWidth;
                }
            }
        });
        observer.observe(that.LayoutObj);
    }

    /** 变大，依次将“更多”列表中的页签释放 */
    this.largerResize = function () {
        let NavBarMore = that.LayoutObj.querySelector('.ld-NavBarMore'),
            NavBarMoreList = NavBarMore.querySelector('.ld-NavBarMoreList');
        for (let NavBarMoreItem of NavBarMoreList.children){

        }
    }

    /** 变小 */
    this.smallerResize = function () {
        
    }


    /**
     * 页签事件对象
     * @typedef {object} NavBarEvent
     * @property {HTMLElement} target 事件的目标页签DOM对象
     * @property {NavBarItem} NavBarItem 页签DOM对象对应的页签数据对象
     * @property {HTMLElement} [from] 页签切换前的页签DOM
     * @property {NavBarItem} [lastNavBarItem] 页签切换前的页签数据对象
     */
    /**
     * “更多”下拉列表的页签是否触发各事件回调函数配置的对象
     * @typedef {object} EventIncludeMore
     * @property {boolean} [OnClick]        是否触发OnClick回调
     * @property {boolean} [OnMouseEnter]   是否触发OnMouseEnter回调
     * @property {boolean} [OnMouseLeave]   是否触发OnMouseLeave回调
     */
    /**
     * “更多”下拉列表的页签是否触发各事件回调函数配置的对象，参数均需携带对象
     * @typedef {object} NavBarCssVarList
     * @property {string} [NavBarHeight]                页签高度，默认100%
     * @property {string} [NavBarItemMinWidth]          页签宽度最小宽度，默认 130px
     * @property {string} [NavBarMoreItemMinWidth]      “更多”页签最小宽度
     * @property {string} [NavBarMoreItemWidth]         “更多”页签宽度
     * @property {string} [NavBarMoreDivWidth]          “更多”下拉列表中的页签宽度
     * @property {string} [NavBarMoreListItemHeight]    “更多”下拉列表中的页签高度
     * @property {string} [NavBarMoreListMaxNum]        “更多”下拉列表中页签的最大显示数量
     */
    /**
     * 配置项对象
     * @typedef {object} NavBarOptions
     * @property {string|number}    [NavBarSelKey]      - 选中页签的键值，默认为0即第一个
     * @property {boolean}          [ShowAllItemInfo]   - 是否将页签数组中每个页签对象的所有键值设为其对应页签DOM元素的自定义属性，属性名为 data-键名
     * @property {string|number}    [NavBarMoreDefaultText] - “更多”页签的默认文本
     * @property {boolean}          [WidthAvg]              - 页签宽度是否均分，默认 false
     * @property {boolean}          [WidthFixed]            - 页签宽度是否均分，默认 true
     * @property {NavBarCssVarList}         [CssVarList]    - 页签的css变量列表
     * @property {function(NavBarEvent)}    [OnClick]       - 页签点击回调函数（默认含更多页签），回调函数接受唯一参数，即页签事件对象
     * @property {function(NavBarEvent)}    [MoreOnClick]   - “更多”下拉列表页签点击回调函数，回调函数接受唯一参数，即页签事件对象
     * @property {function(NavBarEvent)}    [OnMouseEnter]  - 页签鼠标移入事件回调函数（默认含更多页签），回调函数接受唯一参数，即页签事件对象
     * @property {function(NavBarEvent)}    [OnMouseLeave]  - 页签鼠标移出事件回调函数（默认含更多页签），回调函数接受唯一参数，即页签事件对象
     * @property {boolean}          [OneClick]          - 回调函数onClick函数是否仅执行一次
     * @property {boolean}          [OneMoreOnClick]    - 回调函数MoreOnClick函数是否仅执行一次
     * @property {boolean}          [OneMouseEnter]     - 回调函数OnMouseEnter函数是否仅执行一次
     * @property {boolean}          [OneMouseLeave]     - 回调函数OnMouseLeave函数是否仅执行一次
     * @property {EventIncludeMore} [EventIncludeMore]  - “更多”下拉列表的页签是否触发各事件回调函数配置的对象
     * @property {'dependOnWidth' | number} [MaxSimpleNum]  - 普通页签的最大数量，默认值 dependOnWidth 意为取决于宽度，即取决于页签宽度和父元素宽度，也可取具体的数字
     * @property {function(NavBarEvent)} [OnClickBefore]  - 普通页签的最大数量，默认值 dependOnWidth 意为取决于宽度，即取决于页签宽度和父元素宽度，也可取具体的数字
     */
    /**
     * @return {NavBarOptions} 默认的配置项
     */
    this.getDefaultOption = function () {
        return {
            NavBarSelKey : -1,
            ShowAllItemInfo : false,
            NavBarMoreDefaultText : '',
            WidthAvg : false,
            WidthFixed : true,
            CssVarList : {

            },
            OnClick : function (Evt) {
                return true;
            },
            OneClick : false,
            MoreOnClick : function (Evt) {
                return true;
            },
            OneMoreOnClick : false,
            OnMouseEnter : function (Evt) {
                return true;
            },
            OneMouseEnter : false,
            OnMouseLeave : function (Evt) {
                return true;
            },
            OneMouseLeave : false,
            EventIncludeMore : {
                OnClick : true,
                OnMouseEnter : true,
                OnMouseLeave : true,
            },
            MaxSimpleNum : 'dependOnWidth',
            OnClickBefore: function (Evt) {
                return true
            }
        }
    }

    /**
     * 用于将源对象的所有可枚举属性复制到目标对象中（深层复制）,若源对象为 undefined则不做处理
     * @param target 目标对象
     * @param resource 源对象
     */
    this.deepAssign = function (target,resource) {
        if(typeof resource !== 'undefined')
            for (let key in resource) {
                if(resource[key] === null || typeof resource[key] !== 'object'){
                    target[key] = resource[key];
                    // if(typeof target[key] === 'function'){
                    //     target[key].name = 'NavBar' + key;
                    // }
                }
                else
                    that.deepAssign(target[key],resource[key]);
            }
    }

    /**
     * 检查事件触发时，鼠标坐标是否在指定元素中（包括元素边框）
     * @param element 指定元素
     * @return {boolean} 鼠标坐标是否在指定元素中
     */
    this.EventIsInElement = function (element) {
        var rect = element.getBoundingClientRect(),
            borderWidth_str = window.getComputedStyle(element).borderWidth,
            borderWidth = parseInt(borderWidth_str.slice(0,-2));
        return (
            event.clientX >= rect.left + borderWidth &&
            event.clientX <= rect.right - borderWidth &&
            event.clientY >= rect.top + borderWidth &&
            event.clientY <= rect.bottom - borderWidth
        );
    }

    /**
     * 获取指定元素的css变量的值
     * @param varName 指定元素
     * @param element 指定元素
     * @return {string} 指定元素的css变量的值
     */
    this.getCssVarValue = function (varName,element) {
        if(element.style.getPropertyValue(varName) !== '')
            return element.style.getPropertyValue(varName);
        else if(that.Options.CssVarList[varName])
            return that.Options.CssVarList[varName];
        else
            return window.getComputedStyle(element).getPropertyValue(varName);
    }
}
ld_NavBar.prototype.constructor = ld_NavBar;
ld_NavBar.prototype._instanceList = {};
/**
 * 创建一个NavBar实例，使用当前时间戳作为键值，将该实例储存在 ld_NavBar.prototype._instanceList中
 * @param {HTMLElement} LayoutObj 放置页签的DOM对象
 * @param {Object.<NavBarItem>|Array.<NavBarItem>} NavBarList 页签数组，含每个页签数据对象
 * @param {NavBarOptions} [Options] 配置项，非必须
 * @return {ld_NavBar} NavBar实例
 * @example
 * - NavBar.ShowNavBar(LayoutObj,NavBarList)
 * - NavBar.ShowNavBar(LayoutObj,NavBarList,{ OnClick : function(){} })
 */
ld_NavBar.ShowNavBar = function (LayoutObj,NavBarList,Options) {
    let instanceId = LayoutObj.getAttribute('_navbar_instance_');
    let NavBarObj;
    if(instanceId === null){
        NavBarObj = new ld_NavBar();
        instanceId = 'navbar_' + (new Date - 0);
        ld_NavBar.prototype._instanceList[instanceId] = NavBarObj;
        LayoutObj.setAttribute('_navbar_instance_',instanceId);
    }
    else {
        NavBarObj = ld_NavBar.prototype._instanceList[instanceId];
    }
    NavBarObj.SetNavBar(LayoutObj,NavBarList,Options);
    return NavBarObj;
}
/**
 * 获取选中页签
 * @return {boolean|NavBarEvent} 页签事件对象
 */
ld_NavBar.getCurNavBar = function (LayoutObj) {
    let NavBarObj,
        instanceId = LayoutObj.getAttribute('_navbar_instance_');
    if(instanceId === null){
        console.error(new Error('The NavBarList is not exist'));
        return false;
    }
    else {
        NavBarObj = ld_NavBar.prototype._instanceList[instanceId];
    }
    return NavBarObj.getCurNavBarItem();
}