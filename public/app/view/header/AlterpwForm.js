Ext.define('Vmoss.view.header.AlterpwForm', {
	extend: 'Vmoss.lib.CForm',
    alias: 'widget.alterpwform',

    frame:true,
    layout:"form",
    width:300,
    bodyPadding: 5,
    fieldDefaults: {
        xtype: 'textfield',
        msgTarget: 'side',
        autoFitErrors: false
    },

	modelField: ['password', 'alterPassword', 'confirmPassword'],
	bind: Ext.ComponentQuery.query('userwidget')[0].currentUser,

    buttons:[
        { xtype:"button", text:"确定", handler:function (button) {
            var alterpwForm = button.up('alterpwform');
            if (alterpwForm.getForm().isValid()){
                Ext.ComponentQuery.query('userwidget')[0].currentUser.save()
            }
        }},
        { xtype:"button", text:"取消", handler:function (button) {
            button.up('alterpwwidget').hide();
//            Ext.ComponentQuery.query('alterpwform')[0].destroy();
//            button.up('alterpwwidget').add(Ext.create('Vmoss.view.header.AlterpwForm'));
//            Ext.ComponentQuery.query('userwidget')[0].currentUser.clear();
        }}
    ],
    buttonAlign:"center"
});