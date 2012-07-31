Ext.define('Vmoss.view.main.View', {
    extend:'Ext.tab.Panel',
    alias:'widget.mainview',

    margins:'5 5 5 5',
    region:"center",

    items:[
        Ext.create('Vmoss.view.main.Welcome')
    ],

    openPanel:function (config) {
        var me = this,
            panel,
            item = me.items.items || [];

        Ext.each(item, function(tab){
            if(tab.scaffold && tab.scaffold === config){
                panel = tab;
                return false;
            }
        });

        if(!panel){
            panel = Ext.create('Vmoss.view.main.major.' + config.model, {
                scaffold:config
            });
            me.add(panel);
        }

        me.setActiveTab(panel);
    }
});