<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ArticlesLogic extends BaseLogic {
    //列表页的【更多】按钮、新建按钮
    public function getListMoreBtn()
    {
        parent::getListMoreBtn();
        $createBtn = array();
        //文本
        $createBtn['textArticles']['label'] = getFixedLabel('Text');
        $createBtn['textArticles']['permit'] = 'yes';
        $createBtn['textArticles']['btnkey'] = 'textArticles';
        //图片
        $createBtn['imageArticles']['label'] = getFixedLabel('Image');
        $createBtn['imageArticles']['permit'] = 'yes';
        $createBtn['imageArticles']['btnkey'] = 'imageArticles';
        //链接
        $createBtn['linkArticles']['label'] = getFixedLabel('LINK');
        $createBtn['linkArticles']['permit'] = 'yes';
        $createBtn['linkArticles']['btnkey'] = 'linkArticles';
        //PDF
        $createBtn['PDFArticles']['label'] = getFixedLabel('PDF');
        $createBtn['PDFArticles']['permit'] = 'yes';
        $createBtn['PDFArticles']['btnkey'] = 'PDFArticles';
        $this->list_buttons['Create']['list'] = $createBtn;
    }
}
