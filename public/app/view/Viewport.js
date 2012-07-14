Ext.define('Vmoss.view.Viewport', {
    extend:'Ext.container.Viewport',

    layout:'fit',

    items:[
        {
            xtype:'panel',
            border:false,
            id:'viewport',

            layout:"border",

            items:[
                Ext.create('Vmoss.view.header.View'),
                Ext.create('Vmoss.view.menu.View'),
                Ext.create('Vmoss.view.main.View')
            ]
        }
    ],

    initComponent:function () {
        Vmoss.Tool.log('Viewport running.');
        Ext.tip.QuickTipManager.init();

        this.callParent(arguments);
    }
});