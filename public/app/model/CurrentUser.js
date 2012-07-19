Ext.define('Vmoss.model.CurrentUser', {
    extend:'Vmoss.lib.CModel',

    fields:[
        {name:'userCd', type:'string'},
        {name:'name', type:'string'},
        {name:'role', type:'auto'},
        {name:'bumon', type:'auto'},
        {name:'password', type:'string'},
        {name:'alterPassword', type:'string'},
        {name:'confirmPassword', type:'string'}
    ],

    validations:[
        {type:'presence', field:'password'},
        {type:'length', field:'modifyPassword', min:6}
    ],

    fieldsExtend:[
        {field:'userCd', label:'用户编号', width:150},
        {field:'name', label:'用户名', width:150},
        {field:'password', label:'初始密码', inputType: 'password', allowBlank: false, blankText: '请填写初始密码！'},
        {field:'alterPassword', label:'修改密码', itemId: 'alterPassword', inputType: 'password', allowBlank: false, blankText: '请填写修改密码！'},
        {field:'confirmPassword', label:'确认密码', inputType: 'password', allowBlank: false, blankText: '请填写确认密码！', vtype: 'password', initialPassField: 'alterPassword'}
    ],

    searchFeature:{

    },

    gridFeature:{

    },

    save:function () {
        var currentUser = Ext.ComponentQuery.query('userwidget')[0].currentUser,
            currentUserData = Ext.JSON.encode(currentUser.getData());
        Ext.Ajax.request({
            url: '/main/alter_password',
            method: 'get',
            params: {
                current_user: currentUserData
            },
            success:function (response, options) {
                var obj = Ext.decode(response.responseText);
                if (obj.success){
                    Ext.Msg.alert("修改成功", "密码修改成功！");
                }else{
                    Ext.ComponentQuery.query('alterpwform')[0].getForm().markInvalid(obj.errors);
                }
            }
        })
    },

    clear:function () {
        var currentUser = Ext.ComponentQuery.query('userwidget')[0].currentUser;
        currentUser.set('password', '');
    },

    statics:{
        load:function () {
            var user = Ext.create('Vmoss.model.CurrentUser');
            Ext.Ajax.request({
                url:'/main/ext_current_user',
                success:function (response, options) {
                    var obj = Ext.decode(response.responseText);
                    for (var attr in obj) {
                        user.set(attr, obj[attr])
                    }
                }
            })
            return user;
        }
    }
});