/**
 * 微信分享权限初始化
 */
wx.ready(function () {

	// 自定义“分享给朋友”及“分享到QQ”按钮的分享内容
	wx.updateAppMessageShareData({
		title: shareTitle ? shareTitle:'', // 分享标题
		desc:shareintroduction,// 分享描述
		link: shareurl, // 分享链接,该链接域名或路径必须与当前页面对应的公众号JS安全域名一致
		imgUrl: sharepicture, // 分享图标
		success: function () {}
	});
	// 自定义“分享到朋友圈”及“分享到QQ空间”按钮的分享内容
	wx.updateTimelineShareData({
		title: shareTitle ? shareTitle:'', // 分享标题
		link: shareurl, // 分享链接,该链接域名或路径必须与当前页面对应的公众号JS安全域名一致
		imgUrl: sharepicture, // 分享图标
		success: function () { // 用户确认分享后执行的回调函数
		}
	});
	//share to weibo
	wx.onMenuShareWeibo({
		title: shareTitle ? shareTitle:'', // 分享标题
		desc: shareintroduction, // 分享描述
		link: shareurl, // 分享链接
		imgUrl: sharepicture, // 分享图标
		success: function () {}
	});

});

