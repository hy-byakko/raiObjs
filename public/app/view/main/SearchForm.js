Ext.define('Vmoss.view.main.SearchForm', {
    extend:'Vmoss.lib.CForm',

    layout:'column',
    frame:true,

    defaults:{
        labelAlign:'right',
        labelWidth:80,
        columnWidth: 1/3,
        padding: '2'
    },

    feature: 'search',
    fireUpdate: 'blur',

    initComponent:function () {
        var me = this,
            inputHeight = 22, // input控件默认高度
            padding = 2,
            height;

        me.callParent(arguments);

        Ext.apply(me, {
            height: 26 * (Math.ceil(me.items.length / 3)) + 10
        });
    }
});