//Todo: 此处的请求完全没有进入封装, 一个裸露的请求和未经处理的数据直接使用
Ext.define('Vmoss.view.menu.View', {
    extend:'Vmoss.lib.CPanel',
    alias:'widget.menuview',

    initComponent:function () {
        var me = this;

        Ext.apply(this, {
            title:'导航菜单',
            region:'west',
            margins:'5 0 5 5',
            split:true,
            width:240,
            layout:'accordion',
            collapsible:true
        });

        this.callParent(arguments);
    }
});