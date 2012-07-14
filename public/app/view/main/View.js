Ext.define('Vmoss.view.main.View', {
    extend:'Ext.tab.Panel',
    alias:'widget.mainview',

    margins:'5 5 5 5',
    region:"center",

    items:[
        Ext.create('Vmoss.view.main.Welcome')
    ],

    createPanel:function (config) {
        var me = this,
            newView = Ext.create('Vmoss.view.main.major.' + config.model, {
            scaffold:config
        });
        me.add(newView);
        me.setActiveTab(newView);
    }
});