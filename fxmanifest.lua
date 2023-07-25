
shared_script '@FiveEye/FiveEye.lua'










fx_version 'adamant'

game 'gta5'



client_script {
    'config.lua',
    'client/client.lua'
    -- 'client/xpfkfh-client.lua'
}

server_script {
    'config.lua',
    'server/server.lua'
}


ui_page "html/index.html"



files {
    'html/*.html',
    'html/js/*.js',
    'html/js/*.ogg',
    'html/js/*.mp3',
    'html/css/img/*.png',
    'html/css/img/vehicles/*.png',
    'html/css/*.css',
    'html/music/*.ogg',
    'html/music/*.mp3',

}
