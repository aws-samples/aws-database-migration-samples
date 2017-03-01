use dms_sample
db.createUser({
    user: 'dms_user',
    pwd: 'dms_user',
    roles: [{ role: 'readWrite', db:'dms_sample'}]
})
