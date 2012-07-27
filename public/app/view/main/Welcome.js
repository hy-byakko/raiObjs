Ext.define('Vmoss.view.main.Welcome', {
    extend:'Ext.panel.Panel',
    title: 'Welcome',
    closable: true,

    layout:{
        type: 'vbox',
        align : 'stretch'
    },

//    layout:'fit',

    defaults:{
        autoScroll:true
    },

    items: [
        Ext.create('Ext.panel.Panel', {
            title: 'Normal Tab',
            height: 500,
            autoScroll:true
        }),
        Ext.create('Ext.panel.Panel', {
            title: 'Not Normal Tab',
            height: 500,
                autoScroll:true}
        )
    ]
});