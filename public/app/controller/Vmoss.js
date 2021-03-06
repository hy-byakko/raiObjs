Ext.define('Vmoss.controller.Vmoss', {
    extend: 'Ext.app.Controller',
    
    refs: [
        {ref: 'headerView', selector: 'headerview'},
        {ref: 'mainView', selector: 'mainview'},
        {ref: 'menuView', selector: 'menuview'}
    ],
    
    init: function() {
        Vmoss.Tool.log('Controller running.');

        var me = this;

        me.control({
            'menuview': {
                afterrender: this.menuTreeLoad
            }
        });
    },
    
    onLaunch: function() {
	
    },

    menuTreeLoad:function (menuView) {
        var controller = this;
        Ext.Ajax.request({
            method:'GET',
            url:'/main/menu',
            success:function (response, options) {
                var obj = Ext.decode(response.responseText);
                Ext.Array.each(obj.root, function (config) {
                    var tree = Ext.create('Vmoss.view.menu.Tree', {
                        title:config.title,
                        store:Ext.create('Vmoss.store.TreeStore', config.TreeStore)
                    });
                    controller.buildListener(tree);
                    menuView.add(tree);
                });
            }
        });
    },

    buildListener:function(tree){
        tree.on({
            itemclick:this.mainBuilder,
            scope: this
        });
    },

    mainBuilder:function(tree, instance){
        if (instance.data.leaf){
            this.getMainView().openPanel(instance.raw);
        }
        else{
            if(instance.isExpanded()){
                instance.collapse();
            }
            else{
                instance.expand();
            }
        }
    }
});