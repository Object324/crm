<?php
crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
class ReportProductDetail_ListController extends ProductDetail_ListController{
    protected $listModuleType = 'Report';
}