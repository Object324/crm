/*
* 检查浏览器是否支持某种类型的缓存
* eg：localStorage
* */
function storageAvailable(type) {
    var storage;
    try {
        storage = window[type];
        var x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
    }
    catch(e) {
        return e instanceof DOMException && (
                // everything except Firefox
            e.code === 22 ||
            // Firefox
            e.code === 1014 ||
            // test name field too, because code might not be present
            // everything except Firefox
            e.name === 'QuotaExceededError' ||
            // Firefox
            e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
            // acknowledge QuotaExceededError only if there's something already stored
            (storage && storage.length !== 0);
    }
}

/*
* 获取当前地址栏url的站点  例如：www.baidu.com
* protocol 是否保留协议头，默认保留
* */
function getCurrentUrlSite(protocol,url) {
    url =  url|| '';
    if (typeof(url) !== "string" || url.match(/^https?:\/\//i) || url.match(/^\//)) {
        return url;
    }

    if (protocol === false) {
        var currentURL = window.location.hostname + (window.location.port ? ":" + window.location.port : "");
    }else{
        var currentURL = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ":" + window.location.port : "");
    }

    var indexSlash = window.location.pathname.lastIndexOf("/");
    if (indexSlash <= 0) {
        var path = "/";
    } else {
        var path = window.location.pathname.substr(0, indexSlash) + "/";
    }

    return currentURL + path + url;
}
//给页面innerHtml value赋值
(function(ld) {
    var oldHTML = ld.fn.html;
    ld.fn.formhtml =function() {
        var Popupobj = CrmPopup.getPopupObj("last");

        if (arguments.length) return oldHTML.apply(this,arguments);
        ld("input,button", this).each(function() {
            this.setAttribute('value',this.value);
        });
        ld("textarea", this).each(function() {
            this.setAttribute('value',this.value);
            // ld(this).html(this.value);

            var fieldname = ld(this).attr('name');
            if (typeof Popupobj.oCKeditors != 'undefined' && typeof Popupobj.oCKeditors[fieldname] != 'undefined'){
                ld(this).html(Popupobj.oCKeditors[fieldname].getContent());
            }else{
                ld(this).html(this.value);
            }
        });
        ld(":radio,:checkbox", this).each(function() {
            if (this.checked) this.setAttribute('checked', 'checked');
            else this.removeAttribute('checked');
        });
        ld("option", this).each(function() {
            if (this.selected) this.setAttribute('selected', 'selected');
            else this.removeAttribute('selected');
        });
        return oldHTML.apply(this);
    };
})(jQuery);

