Ext.define('Vmoss.view.header.User', {
    extend:'Ext.panel.Panel',
    alias: 'widget.userwidget',

    dock:'right',
    height:50,
    cls:'loginbgimage',
    baseCls:'my-panel-no-border',
    layout: {
        type: 'hbox',
        padding:'15',
        pack:'end',
        align:'middle'
    },
    initComponent:function () {
		var me = this;
		this.currentUser = Vmoss.model.CurrentUser.load();
        Ext.applyIf(this, {
			//items: [Ext.create('Vmoss.view.header.UserName')]
        });

       this.callParent(arguments);
    },
	
	listeners: {
		afterrender:function (me) {
			me.add(Ext.create('Vmoss.view.header.UserName')),
			Ext.create('Vmoss.view.header.AlterpwView')
		}
	}
})
;