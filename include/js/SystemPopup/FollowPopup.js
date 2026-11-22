/**
 * 跟随弹窗
 * @constructor
 */
function FollowPopup() {
    CrmPopup.call(this);


}
FollowPopup.prototype = Object.create(CrmPopup.prototype);
FollowPopup.prototype.constructor = FollowPopup;