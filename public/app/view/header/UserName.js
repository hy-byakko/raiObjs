Ext.define('Vmoss.view.header.UserName', {
    extend:'Ext.button.Split',

    userWidget: Ext.ComponentQuery.query('userwidget')[0],
	
    initComponent:function () {
		Ext.apply(this, {
            menuAlign: 'tr-br',
			menu: {
				items: [
					{
						text: '<b>修改密码</b>',
                        handler: this.alterpw,
                        scope: this
					}, {
						text: '<b>退出</b>',
						handler: function() {window.location.href = '/admin/logout'}
					}
				]
			}
        });

		this.userWidget.currentUser.bindProperty({
			component: this,
			field: 'name',
			handle:{
				set: this.setText,
				get: this.getText
			}
		});

		this.callParent(arguments);
    },

	alterpw: function(){
		Ext.ComponentQuery.query('alterpwwidget')[0].show()
	} 
});